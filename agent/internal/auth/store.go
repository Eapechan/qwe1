package auth

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"sync"
	"time"
)

// Errors.
var (
	ErrTokenExpired = errors.New("auth: token expired")
	ErrTokenInvalid = errors.New("auth: token invalid")
)

// AccessClaims is the payload decoded from a valid access token.
type AccessClaims struct {
	DeviceID string
}

// Device is a registered enrolled device.
type Device struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	Platform  string    `json:"platform"`
	CreatedAt time.Time `json:"createdAt"`
	LastSeen  time.Time `json:"lastSeen"`
}

type refreshRecord struct {
	Hash      string    `json:"hash"`
	DeviceID  string    `json:"deviceId"`
	ExpiresAt time.Time `json:"expiresAt"`
	Used      bool      `json:"used"`
	Revoked   bool      `json:"revoked"`
}

type enrollRecord struct {
	Hash      string    `json:"hash"`
	ExpiresAt time.Time `json:"expiresAt"`
	Used      bool      `json:"used"`
}

type fileState struct {
	Refresh      []refreshRecord `json:"refresh"`
	Enroll       []enrollRecord  `json:"enroll"`
	Devices      []Device        `json:"devices"`
	SignerSecret string          `json:"signerSecret"`
}

// Store is a persisted, mutex-guarded store of token hashes and devices.
// Persisted as JSON (never containing plaintext tokens).
type Store struct {
	mu              sync.RWMutex
	path            string
	fs              fileState
	fileExisted     bool // true if the store file existed on disk when loaded
	secretGenerated bool // true if signer secret was auto-generated (needs persist)
}

// NewStore loads the store from path, creating an empty one if absent.
// If no signer secret is present, one is generated and persisted so tokens
// survive process restarts.
func NewStore(path string) (*Store, error) {
	s := &Store{path: path}
	b, err := os.ReadFile(path)
	if err == nil {
		s.fileExisted = true
		if err := json.Unmarshal(b, &s.fs); err != nil {
			return nil, err
		}
	} else if !os.IsNotExist(err) {
		return nil, err
	}
	if s.fs.Refresh == nil {
		s.fs.Refresh = []refreshRecord{}
	}
	if s.fs.Enroll == nil {
		s.fs.Enroll = []enrollRecord{}
	}
	if s.fs.Devices == nil {
		s.fs.Devices = []Device{}
	}
	// Ensure a signer secret exists so HMAC tokens survive restarts.
	if s.fs.SignerSecret == "" {
		secret := make([]byte, 32)
		if _, err := rand.Read(secret); err != nil {
			return nil, err
		}
		s.fs.SignerSecret = hex.EncodeToString(secret)
		s.secretGenerated = true
	}
	return s, nil
}

// NeedsPersist returns true if the signer secret was auto-generated and needs
// to be persisted to disk so it survives process restarts. Only returns true
// when the store file did not previously exist (first run).
func (s *Store) NeedsPersist() bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.secretGenerated && !s.fileExisted
}

// MarkPersisted clears the needs-persist flag after a successful Persist().
func (s *Store) MarkPersisted() {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.secretGenerated = false
}

// Reload re-reads the state file, picking up changes made by another process
// (e.g. `qwe1-agent enroll` writing a token while the agent is running). The
// file is the authority; every mutation persists before returning.
func (s *Store) Reload() error {
	b, err := os.ReadFile(s.path)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}
	var fs fileState
	if err := json.Unmarshal(b, &fs); err != nil {
		return err
	}
	if fs.Refresh == nil {
		fs.Refresh = []refreshRecord{}
	}
	if fs.Enroll == nil {
		fs.Enroll = []enrollRecord{}
	}
	if fs.Devices == nil {
		fs.Devices = []Device{}
	}
	s.mu.Lock()
	s.fs = fs
	s.mu.Unlock()
	return nil
}

// Persist writes the state to disk atomically. Takes the write lock so
// concurrent mutations and Reload cannot interleave with the marshal/rename.
func (s *Store) Persist() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.persistLocked()
}

// persistLocked writes the state to disk without acquiring the mutex.
// Caller must hold s.mu.
func (s *Store) persistLocked() error {
	b, err := json.Marshal(&s.fs)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(s.path), 0o700); err != nil {
		return err
	}
	tmp := s.path + ".tmp"
	if err := os.WriteFile(tmp, b, 0o600); err != nil {
		return err
	}
	return os.Rename(tmp, s.path)
}

// SignerSecret returns the hex-encoded HMAC signer secret.
func (s *Store) SignerSecret() string {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.fs.SignerSecret
}

// SetSignerSecret updates the signer secret in memory (call Persist to write).
func (s *Store) SetSignerSecret(hex string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.fs.SignerSecret = hex
}

// RotateRefresh atomically validates the old refresh token, marks it used,
// appends a new record, and touches the device — all under a single lock.
// Returns the deviceID on success; false if the old token is invalid.
func (s *Store) RotateRefresh(oldHash, newHash, deviceID string, expiresAt time.Time) bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.fs.Refresh {
		if s.fs.Refresh[i].Hash == oldHash {
			if s.fs.Refresh[i].Used || s.fs.Refresh[i].Revoked {
				return false
			}
			if time.Now().After(s.fs.Refresh[i].ExpiresAt) {
				return false
			}
			s.fs.Refresh[i].Used = true
			s.fs.Refresh = append(s.fs.Refresh, refreshRecord{
				Hash:      newHash,
				DeviceID:  deviceID,
				ExpiresAt: expiresAt,
			})
			s.touchDeviceLocked(deviceID)
			return true
		}
	}
	return false
}

// RotateRefreshAtomic looks up the old refresh token by hash, validates it,
// marks it used, appends a new record, and touches the device — all under a
// single lock. Returns (deviceID, true) on success; ("", false) if the token
// is invalid, used, revoked, or expired.
func (s *Store) RotateRefreshAtomic(oldHash, newHash string, expiresAt time.Time) (string, bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.fs.Refresh {
		if s.fs.Refresh[i].Hash == oldHash {
			if s.fs.Refresh[i].Used || s.fs.Refresh[i].Revoked {
				return "", false
			}
			if time.Now().After(s.fs.Refresh[i].ExpiresAt) {
				return "", false
			}
			deviceID := s.fs.Refresh[i].DeviceID
			s.fs.Refresh[i].Used = true
			s.fs.Refresh = append(s.fs.Refresh, refreshRecord{
				Hash:      newHash,
				DeviceID:  deviceID,
				ExpiresAt: expiresAt,
			})
			s.touchDeviceLocked(deviceID)
			return deviceID, true
		}
	}
	return "", false
}

func (s *Store) AddEnrollment(hash string, expiresAt time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.fs.Enroll = append(s.fs.Enroll, enrollRecord{Hash: hash, ExpiresAt: expiresAt})
}

func (s *Store) MarkEnrollmentUsed(hash string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.fs.Enroll {
		if s.fs.Enroll[i].Hash == hash {
			s.fs.Enroll[i].Used = true
			return
		}
	}
}

func (s *Store) EnrollByHash(hash string) (enrollRecord, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for _, e := range s.fs.Enroll {
		if e.Hash == hash {
			return e, true
		}
	}
	return enrollRecord{}, false
}

func (s *Store) AddRefresh(hash, deviceID string, expiresAt time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.fs.Refresh = append(s.fs.Refresh, refreshRecord{Hash: hash, DeviceID: deviceID, ExpiresAt: expiresAt})
	s.touchDeviceLocked(deviceID)
}

func (s *Store) refreshByHash(hash string) (refreshRecord, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for _, r := range s.fs.Refresh {
		if r.Hash == hash {
			return r, true
		}
	}
	return refreshRecord{}, false
}

// RefreshInfo is the public view of a refresh record.
type RefreshInfo struct {
	DeviceID  string
	ExpiresAt time.Time
	Used      bool
	Revoked   bool
}

func (s *Store) RefreshByHash(hash string) (RefreshInfo, bool) {
	r, ok := s.refreshByHash(hash)
	if !ok {
		return RefreshInfo{}, false
	}
	return RefreshInfo{
		DeviceID:  r.DeviceID,
		ExpiresAt: r.ExpiresAt,
		Used:      r.Used,
		Revoked:   r.Revoked,
	}, true
}

func (s *Store) MarkRefreshUsed(hash string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.fs.Refresh {
		if s.fs.Refresh[i].Hash == hash {
			s.fs.Refresh[i].Used = true
			return
		}
	}
}

// RevokeDevice marks every refresh record for the device as revoked and
// removes the device from the registry so its slot is freed.
func (s *Store) RevokeDevice(deviceID string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.fs.Refresh {
		if s.fs.Refresh[i].DeviceID == deviceID {
			s.fs.Refresh[i].Revoked = true
			s.fs.Refresh[i].Used = true
		}
	}
	kept := s.fs.Devices[:0]
	for _, d := range s.fs.Devices {
		if d.ID != deviceID {
			kept = append(kept, d)
		}
	}
	s.fs.Devices = kept
}

func (s *Store) RevokeAll() {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.fs.Refresh {
		s.fs.Refresh[i].Revoked = true
		s.fs.Refresh[i].Used = true
	}
	s.fs.Devices = []Device{}
}

func (s *Store) DeviceCount() int {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return len(s.fs.Devices)
}

func (s *Store) AddDevice(id, name string, createdAt time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.fs.Devices = append(s.fs.Devices, Device{ID: id, Name: name, CreatedAt: createdAt, LastSeen: createdAt})
}

// IsDeviceRevoked returns true if ALL refresh records for the device are revoked.
func (s *Store) IsDeviceRevoked(deviceID string) bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var found bool
	for _, r := range s.fs.Refresh {
		if r.DeviceID == deviceID {
			found = true
			if !r.Revoked {
				return false
			}
		}
	}
	return found
}

func (s *Store) touchDeviceLocked(deviceID string) {
	for i := range s.fs.Devices {
		if s.fs.Devices[i].ID == deviceID {
			s.fs.Devices[i].LastSeen = time.Now().UTC()
			return
		}
	}
}

func (s *Store) Devices() []Device {
	s.mu.RLock()
	defer s.mu.RUnlock()
	out := make([]Device, len(s.fs.Devices))
	copy(out, s.fs.Devices)
	return out
}

// ValidateAccess checks if the token hash corresponds to a valid, non-expired refresh record
// and returns claims for the associated device.
func (s *Store) ValidateAccess(token string) (*AccessClaims, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	for _, r := range s.fs.Refresh {
		if r.Hash == token {
			if r.Used {
				return nil, ErrTokenInvalid
			}
			if time.Now().After(r.ExpiresAt) {
				return nil, ErrTokenExpired
			}
			return &AccessClaims{DeviceID: r.DeviceID}, nil
		}
	}
	return nil, ErrTokenInvalid
}
