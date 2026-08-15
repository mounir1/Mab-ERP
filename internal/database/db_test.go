package database

import (
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"
)

// TestEmbeddedMigrationsPresent verifies the runner actually embeds SQL files.
func TestEmbeddedMigrationsPresent(t *testing.T) {
	entries, err := migrationFiles.ReadDir("migrations")
	if err != nil {
		t.Fatalf("failed to read embedded migrations: %v", err)
	}
	if len(entries) == 0 {
		t.Fatal("no embedded migrations found")
	}
}

// TestEmbeddedMigrationsSorted verifies the runner's sort ordering matches a
// plain lexicographic sort (the runner relies on sort.Strings).
func TestEmbeddedMigrationsSorted(t *testing.T) {
	entries, err := migrationFiles.ReadDir("migrations")
	if err != nil {
		t.Fatalf("failed to read embedded migrations: %v", err)
	}
	var names []string
	for _, e := range entries {
		if !e.IsDir() && strings.HasSuffix(e.Name(), ".sql") {
			names = append(names, e.Name())
		}
	}
	if !sort.StringsAreSorted(names) {
		t.Fatalf("embedded migrations are not sorted: %v", names)
	}
}

// TestEmbeddedMigrationsNonEmpty ensures every embedded migration has content.
func TestEmbeddedMigrationsNonEmpty(t *testing.T) {
	entries, err := migrationFiles.ReadDir("migrations")
	if err != nil {
		t.Fatalf("failed to read embedded migrations: %v", err)
	}
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".sql") {
			continue
		}
		content, err := migrationFiles.ReadFile("migrations/" + e.Name())
		if err != nil {
			t.Fatalf("failed to read %s: %v", e.Name(), err)
		}
		if strings.TrimSpace(string(content)) == "" {
			t.Errorf("embedded migration %s is empty", e.Name())
		}
	}
}

// TestRootMigrationsInSync verifies the checked-in root migrations/ directory
// mirrors the embedded (governing) set, so developers don't drift them apart.
func TestRootMigrationsInSync(t *testing.T) {
	entries, err := migrationFiles.ReadDir("migrations")
	if err != nil {
		t.Fatalf("failed to read embedded migrations: %v", err)
	}

	root := filepath.Join("..", "..", "migrations")
	rootEntries, err := os.ReadDir(root)
	if err != nil {
		t.Skipf("root migrations dir not readable, skipping sync check: %v", err)
	}

	rootNames := map[string]bool{}
	for _, e := range rootEntries {
		if !e.IsDir() && strings.HasSuffix(e.Name(), ".sql") {
			rootNames[e.Name()] = true
		}
	}

	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		if !rootNames[e.Name()] {
			t.Errorf("embedded migration %s is missing from root migrations/", e.Name())
		}
	}
}

// TestGetEnv covers the env-with-fallback helper.
func TestGetEnv(t *testing.T) {
	if got := getEnv("MAB_TEST_ENV_UNSET", "fallback"); got != "fallback" {
		t.Fatalf("getEnv(unset) = %q, want fallback", got)
	}
	t.Setenv("MAB_TEST_ENV_SET", "value")
	if got := getEnv("MAB_TEST_ENV_SET", "fallback"); got != "value" {
		t.Fatalf("getEnv(set) = %q, want value", got)
	}
}

// TestDefaultDSN verifies the DSN builder.
func TestDefaultDSN(t *testing.T) {
	t.Setenv("DB_HOST", "dbhost")
	t.Setenv("DB_PORT", "5433")
	t.Setenv("DB_USER", "dbuser")
	t.Setenv("DB_PASSWORD", "dbpass")
	t.Setenv("DB_NAME", "dbname")
	t.Setenv("DB_SSLMODE", "require")
	got := defaultDSN()
	want := "postgres://dbuser:dbpass@dbhost:5433/dbname?sslmode=require"
	if got != want {
		t.Fatalf("defaultDSN() = %q, want %q", got, want)
	}
}

// TestRunMigrationsIntegration applies all migrations to a real database.
// Skips when TEST_DATABASE_URL is unset so CI without Postgres stays green.
func TestRunMigrationsIntegration(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping integration test")
	}

	pool, err := NewPool(dsn)
	if err != nil {
		t.Fatalf("failed to connect to test database: %v", err)
	}
	defer pool.Close()

	if err := RunMigrations(pool); err != nil {
		t.Fatalf("RunMigrations failed: %v", err)
	}

	// Idempotent — running again must succeed.
	if err := RunMigrations(pool); err != nil {
		t.Fatalf("RunMigrations (second pass) failed: %v", err)
	}
}