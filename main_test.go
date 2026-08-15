package main

import (
	"os"
	"reflect"
	"testing"
)

func TestCorsOrigins(t *testing.T) {
	t.Run("falls back to localhost defaults when unset", func(t *testing.T) {
		os.Unsetenv("CORS_ORIGINS")
		got := corsOrigins()
		want := []string{"http://localhost:5173", "http://localhost:4173", "http://localhost:8080"}
		if !reflect.DeepEqual(got, want) {
			t.Fatalf("corsOrigins() = %v, want %v", got, want)
		}
	})

	t.Run("parses comma-separated list and trims whitespace", func(t *testing.T) {
		t.Setenv("CORS_ORIGINS", "https://erp.example.com, http://localhost:5173 ")
		got := corsOrigins()
		want := []string{"https://erp.example.com", "http://localhost:5173"}
		if !reflect.DeepEqual(got, want) {
			t.Fatalf("corsOrigins() = %v, want %v", got, want)
		}
	})

	t.Run("filters empty entries", func(t *testing.T) {
		t.Setenv("CORS_ORIGINS", "http://a.example.com,,http://b.example.com")
		got := corsOrigins()
		want := []string{"http://a.example.com", "http://b.example.com"}
		if !reflect.DeepEqual(got, want) {
			t.Fatalf("corsOrigins() = %v, want %v", got, want)
		}
	})

	t.Run("falls back to defaults when only empties provided", func(t *testing.T) {
		t.Setenv("CORS_ORIGINS", " , , ")
		got := corsOrigins()
		want := []string{"http://localhost:5173", "http://localhost:4173", "http://localhost:8080"}
		if !reflect.DeepEqual(got, want) {
			t.Fatalf("corsOrigins() = %v, want %v", got, want)
		}
	})
}