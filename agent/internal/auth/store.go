package auth

import (
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
	Refresh []refreshRecord `json:"refresh"`
	Enroll  []enrollRecord  `json:"enroll"`
	Devices []Device        `json:"devices"`
}

// Store is a persisted, mutex-guarded store of token hashes and devices.
// Persisted as JSON (never containing plaintext tokens).
type Store struct {
	mu   sync.RWMutex
	path string
	fs   fileState
}

// NewStore loads the store from path, creating an empty one if absent.
func NewStore(path string) (*Store, error) {
	s := &Store{path: path}
	b, err := os.ReadFile(path)
	if err == nil {
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
	return s, nil
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

// Persist writes the state to disk atomically.
func (s *Store) Persist() error {
	s.mu.RLock()
	defer s.mu.RUnlock()
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

func (s *Store) enrollByHash(hash string) (enrollRecord, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for _, e := range s.fs.Enroll {
		if e.Hash == hash {
			return e, true
		}
	}
	return enrollRecord{}, false
}

func (s *Store) cleanupEnrollments(now time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()
	kept := s.fs.Enroll[:0]
	for _, e := range s.fs.Enroll {
		if now.Before(e.ExpiresAt) {
			kept = append(kept, e)
		}
	}
	s.fs.Enroll = kept
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
