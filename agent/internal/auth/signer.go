package auth

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"strconv"
	"strings"
	"time"
)

// Signer generates and validates signed tokens.
type Signer struct {
	secret []byte
}

// Secret returns the raw HMAC secret bytes (for persistence).
func (s *Signer) Secret() []byte {
	return s.secret
}

// NewSigner creates a signer with the given hex-encoded secret.
// If secret is empty, a random one is generated (for single-instance use).
func NewSigner(secretHex string) (*Signer, error) {
	if secretHex != "" {
		decoded, err := hex.DecodeString(secretHex)
		if err != nil {
			return nil, fmt.Errorf("invalid secret hex: %w", err)
		}
		return &Signer{secret: decoded}, nil
	}
	secret := make([]byte, 32)
	if _, err := rand.Read(secret); err != nil {
		return nil, err
	}
	return &Signer{secret: secret}, nil
}

// GenerateAccessToken creates a signed opaque token for the given device ID.
func (s *Signer) GenerateAccessToken(deviceID string, ttl time.Duration) (string, error) {
	payload := fmt.Sprintf("%s:%d", deviceID, time.Now().Add(ttl).Unix())
	mac := hmac.New(sha256.New, s.secret)
	mac.Write([]byte(payload))
	sig := mac.Sum(nil)
	return base64.RawURLEncoding.EncodeToString([]byte(payload)) + "." + base64.RawURLEncoding.EncodeToString(sig), nil
}

// ValidateAccessToken verifies the token signature and returns the device ID.
func (s *Signer) ValidateAccessToken(token string) (string, error) {
	parts := strings.SplitN(token, ".", 2)
	if len(parts) != 2 {
		return "", ErrTokenInvalid
	}

	payloadBytes, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		return "", ErrTokenInvalid
	}

	sigBytes, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return "", ErrTokenInvalid
	}

	mac := hmac.New(sha256.New, s.secret)
	mac.Write(payloadBytes)
	expected := mac.Sum(nil)
	if !hmac.Equal(sigBytes, expected) {
		return "", ErrTokenInvalid
	}

	payload := string(payloadBytes)
	parts2 := strings.SplitN(payload, ":", 2)
	if len(parts2) != 2 {
		return "", ErrTokenInvalid
	}

	deviceID := parts2[0]

	exp, err := strconv.ParseInt(parts2[1], 10, 64)
	if err != nil {
		return "", ErrTokenInvalid
	}
	if time.Now().Unix() > exp {
		return "", ErrTokenExpired
	}

	return deviceID, nil
}

// GenerateRefreshToken creates a random refresh token string.
func GenerateRefreshToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(b), nil
}

// HashToken returns a hex SHA-256 hash of the token for storage.
func HashToken(token string) string {
	h := sha256.Sum256([]byte(token))
	return hex.EncodeToString(h[:])
}
