package certs

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"math/big"
	"net"
	"os"
	"path/filepath"
	"time"
)

type CertManager struct {
	certPath string
	keyPath  string
}

func NewCertManager(certPath, keyPath string) *CertManager {
	return &CertManager{
		certPath: certPath,
		keyPath:  keyPath,
	}
}

func (m *CertManager) GetFingerprint() (string, error) {
	certPEM, err := os.ReadFile(m.certPath)
	if err != nil {
		return "", fmt.Errorf("failed to read certificate: %w", err)
	}

	hash := sha256.Sum256(certPEM)
	fingerprint := hex.EncodeToString(hash[:])

	var formatted string
	for i := 0; i < len(fingerprint); i += 2 {
		if i > 0 {
			formatted += ":"
		}
		formatted += fingerprint[i : i+2]
	}

	return formatted, nil
}

func (m *CertManager) EnsureCerts() error {
	if _, err := os.Stat(m.certPath); os.IsNotExist(err) {
		return m.generateSelfSigned()
	}
	return nil
}

func (m *CertManager) generateSelfSigned() error {
	dir := filepath.Dir(m.certPath)
	if err := os.MkdirAll(dir, 0700); err != nil {
		return fmt.Errorf("failed to create cert directory: %w", err)
	}

	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return fmt.Errorf("failed to generate key: %w", err)
	}

	serialNumber, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		return fmt.Errorf("failed to generate serial number: %w", err)
	}

	template := x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			Organization: []string{"qwe1-agent"},
			CommonName:   "localhost",
		},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().Add(10 * 365 * 24 * time.Hour),
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		DNSNames:              []string{"localhost"},
		IPAddresses:           []net.IP{net.ParseIP("127.0.0.1"), net.ParseIP("::1")},
	}

	certDER, err := x509.CreateCertificate(rand.Reader, &template, &template, &key.PublicKey, key)
	if err != nil {
		return fmt.Errorf("failed to create certificate: %w", err)
	}

	certFile, err := os.Create(m.certPath)
	if err != nil {
		return fmt.Errorf("failed to create cert file: %w", err)
	}
	defer certFile.Close()

	if err := pem.Encode(certFile, &pem.Block{Type: "CERTIFICATE", Bytes: certDER}); err != nil {
		return fmt.Errorf("failed to write cert: %w", err)
	}

	keyDER, err := x509.MarshalECPrivateKey(key)
	if err != nil {
		return fmt.Errorf("failed to marshal key: %w", err)
	}

	keyFile, err := os.OpenFile(m.keyPath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		return fmt.Errorf("failed to create key file: %w", err)
	}
	defer keyFile.Close()

	if err := pem.Encode(keyFile, &pem.Block{Type: "EC PRIVATE KEY", Bytes: keyDER}); err != nil {
		return fmt.Errorf("failed to write key: %w", err)
	}

	return nil
}
