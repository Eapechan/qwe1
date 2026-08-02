package auth

import (
	"path/filepath"
	"testing"
	"time"
)

func TestStoreEnrollmentLifecycle(t *testing.T) {
	store, err := NewStore(filepath.Join(t.TempDir(), "data.json"))
	if err != nil {
		t.Fatal(err)
	}
	hash := HashToken("qwe1-secret")

	if _, ok := store.EnrollByHash(hash); ok {
		t.Fatal("enrollment should not exist yet")
	}

	store.AddEnrollment(hash, time.Now().Add(time.Hour))
	if rec, ok := store.EnrollByHash(hash); !ok {
		t.Fatal("enrollment should exist after add")
	} else if rec.Used {
		t.Fatal("new enrollment should not be marked used")
	}

	store.MarkEnrollmentUsed(hash)
	if rec, ok := store.EnrollByHash(hash); !ok {
		t.Fatal("enrollment should still exist")
	} else if !rec.Used {
		t.Fatal("enrollment should be marked used")
	}
}

func TestSignerRoundTrip(t *testing.T) {
	s, err := NewSigner("")
	if err != nil {
		t.Fatal(err)
	}
	tok, err := s.GenerateAccessToken("dev-123", time.Minute)
	if err != nil {
		t.Fatal(err)
	}
	got, err := s.ValidateAccessToken(tok)
	if err != nil {
		t.Fatal(err)
	}
	if got != "dev-123" {
		t.Fatalf("device = %q, want dev-123", got)
	}
}

func TestSignerDerivesSameSecretFromHex(t *testing.T) {
	a, err := NewSigner("ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00")
	if err != nil {
		t.Fatal(err)
	}
	b, err := NewSigner("ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00")
	if err != nil {
		t.Fatal(err)
	}
	tok, _ := a.GenerateAccessToken("dev", time.Minute)
	if _, err := b.ValidateAccessToken(tok); err != nil {
		t.Fatalf("token not valid across same-secret signers: %v", err)
	}
}

func TestSignerRejectsTamperedToken(t *testing.T) {
	s, err := NewSigner("")
	if err != nil {
		t.Fatal(err)
	}
	tok, _ := s.GenerateAccessToken("dev", time.Minute)
	if _, err := s.ValidateAccessToken(tok + "x"); err != ErrTokenInvalid {
		t.Fatalf("tampered token err = %v, want ErrTokenInvalid", err)
	}
	if _, err := s.ValidateAccessToken("not.a.token"); err != ErrTokenInvalid {
		t.Fatalf("malformed token err = %v, want ErrTokenInvalid", err)
	}
}

func TestValidateAccess(t *testing.T) {
	store, err := NewStore(filepath.Join(t.TempDir(), "data.json"))
	if err != nil {
		t.Fatal(err)
	}
	refresh := "some-refresh-token"
	store.AddRefresh(HashToken(refresh), "device-1", time.Now().Add(time.Hour))

	claims, err := store.ValidateAccess(HashToken(refresh))
	if err != nil {
		t.Fatal(err)
	}
	if claims.DeviceID != "device-1" {
		t.Fatalf("device = %q, want device-1", claims.DeviceID)
	}

	store.MarkRefreshUsed(HashToken(refresh))
	if _, err := store.ValidateAccess(HashToken(refresh)); err != ErrTokenInvalid {
		t.Fatalf("used token err = %v, want ErrTokenInvalid", err)
	}
}

func TestValidateAccessExpired(t *testing.T) {
	store, err := NewStore(filepath.Join(t.TempDir(), "data.json"))
	if err != nil {
		t.Fatal(err)
	}
	refresh := "expired-token"
	store.AddRefresh(HashToken(refresh), "device-1", time.Now().Add(-time.Hour))

	if _, err := store.ValidateAccess(HashToken(refresh)); err != ErrTokenExpired {
		t.Fatalf("expired token err = %v, want ErrTokenExpired", err)
	}
}

func TestRefreshRotationAndRevoke(t *testing.T) {
	store, err := NewStore(filepath.Join(t.TempDir(), "data.json"))
	if err != nil {
		t.Fatal(err)
	}
	store.AddDevice("device-1", "test", time.Now().UTC())
	old := "old-refresh"
	store.AddRefresh(HashToken(old), "device-1", time.Now().Add(time.Hour))

	if _, ok := store.RefreshByHash(HashToken(old)); !ok {
		t.Fatal("old refresh should be found")
	}

	store.MarkRefreshUsed(HashToken(old))
	// Reuse of the old token revokes the device.
	store.RevokeDevice("device-1")
	if n := store.DeviceCount(); n != 0 {
		t.Fatalf("devices after revoke = %d, want 0", n)
	}
	if info, ok := store.RefreshByHash(HashToken(old)); !ok || !info.Revoked {
		t.Fatal("old refresh should be revoked")
	}
}

func TestRevokeAll(t *testing.T) {
	store, err := NewStore(filepath.Join(t.TempDir(), "data.json"))
	if err != nil {
		t.Fatal(err)
	}
	store.AddDevice("device-1", "test", time.Now().UTC())
	store.AddRefresh(HashToken("r1"), "device-1", time.Now().Add(time.Hour))

	store.RevokeAll()
	if n := store.DeviceCount(); n != 0 {
		t.Fatalf("devices after revoke-all = %d, want 0", n)
	}
}

func TestStorePersistence(t *testing.T) {
	path := filepath.Join(t.TempDir(), "data.json")
	store, err := NewStore(path)
	if err != nil {
		t.Fatal(err)
	}
	store.AddEnrollment(HashToken("tok"), time.Now().Add(time.Hour))
	if err := store.Persist(); err != nil {
		t.Fatal(err)
	}

	store2, err := NewStore(path)
	if err != nil {
		t.Fatal(err)
	}
	if _, ok := store2.EnrollByHash(HashToken("tok")); !ok {
		t.Fatal("enrollment not found after reload")
	}
}

func TestAttemptTrackerLockout(t *testing.T) {
	tr := NewAttemptTracker(2, time.Second, time.Second)
	if tr.Locked("1.2.3.4") {
		t.Fatal("should start unlocked")
	}
	tr.Fail("1.2.3.4")
	tr.Fail("1.2.3.4")
	if !tr.Locked("1.2.3.4") {
		t.Fatal("should be locked after 2 failures")
	}
	tr.Success("1.2.3.4")
	if tr.Locked("1.2.3.4") {
		t.Fatal("should unlock on success")
	}
}

func TestHashTokenDeterministic(t *testing.T) {
	a := HashToken("secret-token")
	b := HashToken("secret-token")
	c := HashToken("other")
	if a != b {
		t.Fatal("hash not deterministic")
	}
	if a == c {
		t.Fatal("different inputs hashed equal")
	}
	if len(a) != 64 {
		t.Fatalf("hash length = %d, want 64", len(a))
	}
}
