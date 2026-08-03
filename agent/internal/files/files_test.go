package files

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestNewManager(t *testing.T) {
	tmpDir := t.TempDir()
	m, err := New([]string{tmpDir}, false, 0, 0)
	if err != nil {
		t.Fatalf("New() error = %v", err)
	}
	if len(m.Roots()) != 1 {
		t.Errorf("Roots() length = %d, want 1", len(m.Roots()))
	}
}

func TestNewManagerNoRoots(t *testing.T) {
	_, err := New([]string{}, false, 0, 0)
	if err == nil {
		t.Error("New() with no roots should return error")
	}
}

func TestListEmptyDir(t *testing.T) {
	tmpDir := t.TempDir()
	m, err := New([]string{tmpDir}, false, 0, 0)
	if err != nil {
		t.Fatalf("New() error = %v", err)
	}

	entries, err := m.List("")
	if err != nil {
		t.Fatalf("List() error = %v", err)
	}
	if len(entries) != 0 {
		t.Errorf("List() returned %d entries, want 0", len(entries))
	}
}

func TestListAndWrite(t *testing.T) {
	tmpDir := t.TempDir()
	m, err := New([]string{tmpDir}, false, 0, 0)
	if err != nil {
		t.Fatalf("New() error = %v", err)
	}

	// Write a file
	err = m.Write("test.txt", strings.NewReader("hello world"))
	if err != nil {
		t.Fatalf("Write() error = %v", err)
	}

	// List should show the file
	entries, err := m.List("")
	if err != nil {
		t.Fatalf("List() error = %v", err)
	}
	found := false
	for _, e := range entries {
		if e.Name == "test.txt" {
			found = true
			if e.Size != 11 {
				t.Errorf("test.txt size = %d, want 11", e.Size)
			}
		}
	}
	if !found {
		t.Error("test.txt not found in listing")
	}

	// Read the file
	reader, entry, err := m.Open("test.txt")
	if err != nil {
		t.Fatalf("Open() error = %v", err)
	}
	defer reader.Close()
	if entry.Name != "test.txt" {
		t.Errorf("Open() name = %q, want test.txt", entry.Name)
	}
}

func TestResolveTraversal(t *testing.T) {
	tmpDir := t.TempDir()
	m, err := New([]string{tmpDir}, false, 0, 0)
	if err != nil {
		t.Fatalf("New() error = %v", err)
	}

	// Path traversal should be rejected
	_, err = m.Resolve("/etc/passwd")
	if err == nil {
		t.Error("Resolve(/etc/passwd) should return error")
	}

	// Symlink escape should be rejected
	linkPath := filepath.Join(tmpDir, "link")
	if err := os.Symlink("/etc", linkPath); err == nil {
		defer os.Remove(linkPath)
		_, err = m.Resolve("link/passwd")
		if err == nil {
			t.Error("Resolve through symlink escape should return error")
		}
	}
}

func TestMkdir(t *testing.T) {
	tmpDir := t.TempDir()
	m, err := New([]string{tmpDir}, false, 0, 0)
	if err != nil {
		t.Fatalf("New() error = %v", err)
	}

	err = m.Mkdir("subdir")
	if err != nil {
		t.Fatalf("Mkdir() error = %v", err)
	}

	// Verify it exists
	info, err := os.Stat(filepath.Join(tmpDir, "subdir"))
	if err != nil {
		t.Fatalf("Stat() error = %v", err)
	}
	if !info.IsDir() {
		t.Error("subdir should be a directory")
	}
}

func TestRename(t *testing.T) {
	tmpDir := t.TempDir()
	m, err := New([]string{tmpDir}, false, 0, 0)
	if err != nil {
		t.Fatalf("New() error = %v", err)
	}

	// Create a file
	err = m.Write("old.txt", strings.NewReader("content"))
	if err != nil {
		t.Fatalf("Write() error = %v", err)
	}

	// Rename it
	err = m.Rename("old.txt", "new.txt")
	if err != nil {
		t.Fatalf("Rename() error = %v", err)
	}

	// Verify old doesn't exist
	_, _, err = m.Open("old.txt")
	if err == nil {
		t.Error("old.txt should not exist after rename")
	}

	// Verify new exists
	_, _, err = m.Open("new.txt")
	if err != nil {
		t.Errorf("new.txt should exist after rename: %v", err)
	}
}

func TestDelete(t *testing.T) {
	tmpDir := t.TempDir()
	m, err := New([]string{tmpDir}, false, 0, 0)
	if err != nil {
		t.Fatalf("New() error = %v", err)
	}

	// Create a file
	err = m.Write("delete.txt", strings.NewReader("content"))
	if err != nil {
		t.Fatalf("Write() error = %v", err)
	}

	// Delete it
	err = m.Delete("delete.txt", false)
	if err != nil {
		t.Fatalf("Delete() error = %v", err)
	}

	// Verify it's gone
	_, err = os.Stat(filepath.Join(tmpDir, "delete.txt"))
	if !os.IsNotExist(err) {
		t.Errorf("delete.txt should not exist after delete: %v", err)
	}
}