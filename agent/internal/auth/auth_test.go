package auth

import (
	"crypto/rand"
	"crypto/rsa"
	"path/filepath"
	"testing"
	"time"
)

const (
	testTTL     = 15 * time.Minute
	testRefresh = 30 * time.Minute
	testEnroll  = 10 * time.Minute
)

func newTestService(t *testing.T) (*Service, *Store, time.Time) {
	t.Helper()
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	store, err := NewStore(filepath.Join(t.TempDir(), "data.json"))
	if err != nil {
		t.Fatal(err)
	}
	now := time.Date(2026, 1, 1, 12, 0, 0, 0, time.UTC)
	svc := New(&Keypair{Private: key, Public: &key.PublicKey}, store, testTTL, testRefresh, testEnroll, 8)
	svc.SetClock(func() time.Time { return now })
	return svc, store, now
}

func TestEnrollAndIssue(t *testing.T) {
	svc, _, now := newTestService(t)
	tok, err := svc.GenerateEnrollment()
	if err != nil {
		t.Fatal(err)
	}
	if len(tok) < 32 {
		t.Fatalf("token too short: %q", tok)
	}
	deviceID, err := svc.ConsumeEnrollment(tok)
	if err != nil {
		t.Fatal(err)
	}
	if deviceID == "" {
		t.Fatal("empty device id")
	}

	access, refresh, exp, err := svc.Issue(deviceID)
	if err != nil {
		t.Fatal(err)
	}
	if access == "" || refresh == "" {
		t.Fatal("empty tokens")
	}
	if !exp.After(now) {
		t.Fatal("expiry not in future")
	}
	claims, err := svc.ValidateAccess(access)
	if err != nil {
		t.Fatal(err)
	}
	if claims.DeviceID != deviceID {
		t.Fatalf("claims device = %q, want %q", claims.DeviceID, deviceID)
	}
}

func TestEnrollmentSingleUse(t *testing.T) {
	svc, _, _ := newTestService(t)
	tok, err := svc.GenerateEnrollment()
	if err != nil {
		t.Fatal(err)
	}
	if _, err := svc.ConsumeEnrollment(tok); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.ConsumeEnrollment(tok); err != ErrEnrollmentUsed {
		t.Fatalf("second consume = %v, want ErrEnrollmentUsed", err)
	}
}

func TestEnrollmentExpired(t *testing.T) {
	svc, _, now := newTestService(t)
	tok, err := svc.GenerateEnrollment()
	if err != nil {
		t.Fatal(err)
	}
	svc.SetClock(func() time.Time { return now.Add(testEnroll + time.Minute) })
	if _, err := svc.ConsumeEnrollment(tok); err != ErrInvalidEnrollment {
		t.Fatalf("expired consume = %v, want ErrInvalidEnrollment", err)
	}
}

func TestDeviceLimit(t *testing.T) {
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	store, err := NewStore(filepath.Join(t.TempDir(), "data.json"))
	if err != nil {
		t.Fatal(err)
	}
	svc := New(&Keypair{Private: key, Public: &key.PublicKey}, store, testTTL, testRefresh, testEnroll, 1)
	for i := 0; i < 2; i++ {
		tok, err := svc.GenerateEnrollment()
		if err != nil {
			t.Fatal(err)
		}
		_, err = svc.ConsumeEnrollment(tok)
		if i == 0 && err != nil {
			t.Fatalf("first enroll failed: %v", err)
		}
		if i == 1 && err != ErrDeviceLimit {
			t.Fatalf("second enroll = %v, want ErrDeviceLimit", err)
		}
	}
}

func TestRefreshRotationAndReuse(t *testing.T) {
	svc, _, _ := newTestService(t)
	tok, _ := svc.GenerateEnrollment()
	deviceID, err := svc.ConsumeEnrollment(tok)
	if err != nil {
		t.Fatal(err)
	}
	_, refresh, _, err := svc.Issue(deviceID)
	if err != nil {
		t.Fatal(err)
	}

	// First rotation succeeds.
	_, newRefresh, gotDevice, _, err := svc.Refresh(refresh)
	if err != nil {
		t.Fatal(err)
	}
	if gotDevice != deviceID {
		t.Fatalf("device = %q, want %q", gotDevice, deviceID)
	}

	// Reusing the old token is detected as reuse and revokes the device.
	_, _, _, _, err = svc.Refresh(refresh)
	if err != ErrRefreshReuse {
		t.Fatalf("reuse = %v, want ErrRefreshReuse", err)
	}

	// The new token is now invalid because the device was revoked.
	_, _, _, _, err = svc.Refresh(newRefresh)
	if err != ErrInvalidRefresh {
		t.Fatalf("post-revoke refresh = %v, want ErrInvalidRefresh", err)
	}
}

func TestRefreshExpiredRevokesDevice(t *testing.T) {
	svc, _, now := newTestService(t)
	tok, _ := svc.GenerateEnrollment()
	deviceID, err := svc.ConsumeEnrollment(tok)
	if err != nil {
		t.Fatal(err)
	}
	_, refresh, _, err := svc.Issue(deviceID)
	if err != nil {
		t.Fatal(err)
	}
	svc.SetClock(func() time.Time { return now.Add(testRefresh + time.Hour) })
	if _, _, _, _, err := svc.Refresh(refresh); err != ErrInvalidRefresh {
		t.Fatalf("expired refresh = %v, want ErrInvalidRefresh", err)
	}
}

func TestValidateAccessRejectsExpired(t *testing.T) {
	svc, _, now := newTestService(t)
	access, _, _, err := svc.Issue("dev-1")
	if err != nil {
		t.Fatal(err)
	}
	svc.SetClock(func() time.Time { return now.Add(testTTL + time.Minute) })
	if _, err := svc.ValidateAccess(access); err != ErrTokenExpired {
		t.Fatalf("validate = %v, want ErrTokenExpired", err)
	}
}

func TestRevokeAll(t *testing.T) {
	svc, _, _ := newTestService(t)
	tok, _ := svc.GenerateEnrollment()
	deviceID, err := svc.ConsumeEnrollment(tok)
	if err != nil {
		t.Fatal(err)
	}
	_, refresh, _, err := svc.Issue(deviceID)
	if err != nil {
		t.Fatal(err)
	}
	if err := svc.RevokeAll(); err != nil {
		t.Fatal(err)
	}
	if _, _, _, _, err := svc.Refresh(refresh); err != ErrInvalidRefresh {
		t.Fatalf("refresh after revoke-all = %v, want ErrInvalidRefresh", err)
	}
}

func TestStorePersistence(t *testing.T) {
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	path := filepath.Join(t.TempDir(), "data.json")
	store, err := NewStore(path)
	if err != nil {
		t.Fatal(err)
	}
	svc := New(&Keypair{Private: key, Public: &key.PublicKey}, store, testTTL, testRefresh, testEnroll, 8)
	tok, _ := svc.GenerateEnrollment()
	deviceID, err := svc.ConsumeEnrollment(tok)
	if err != nil {
		t.Fatal(err)
	}
	_, refresh, _, err := svc.Issue(deviceID)
	if err != nil {
		t.Fatal(err)
	}

	// Reload from disk.
	store2, err := NewStore(path)
	if err != nil {
		t.Fatal(err)
	}
	svc2 := New(&Keypair{Private: key, Public: &key.PublicKey}, store2, testTTL, testRefresh, testEnroll, 8)
	if _, _, gotDevice, _, err := svc2.Refresh(refresh); err != nil || gotDevice != deviceID {
		t.Fatalf("refresh after reload failed: %v", err)
	}
}

func TestHashTokenDeterministic(t *testing.T) {
	a := hashToken("secret-token")
	b := hashToken("secret-token")
	c := hashToken("other")
	if a != b {
		t.Fatal("hash not deterministic")
	}
	if a == c {
		t.Fatal("different inputs hashed equal")
	}
	if len(a) != 64 {
		t.Fatalf("hash length = %d", len(a))
	}
}
