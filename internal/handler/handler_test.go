package handler

import (
	"os"
	"strings"
	"testing"
	"time"
)

func TestAccessTokenTTL(t *testing.T) {
	t.Run("defaults to 8h when unset", func(t *testing.T) {
		os.Unsetenv("JWT_EXPIRY_HOURS")
		if got := accessTokenTTL(); got != 8*time.Hour {
			t.Fatalf("expected 8h, got %v", got)
		}
	})

	t.Run("uses env value", func(t *testing.T) {
		t.Setenv("JWT_EXPIRY_HOURS", "24")
		if got := accessTokenTTL(); got != 24*time.Hour {
			t.Fatalf("expected 24h, got %v", got)
		}
	})

	t.Run("falls back on invalid value", func(t *testing.T) {
		t.Setenv("JWT_EXPIRY_HOURS", "abc")
		if got := accessTokenTTL(); got != 8*time.Hour {
			t.Fatalf("expected 8h, got %v", got)
		}
	})

	t.Run("falls back on non-positive value", func(t *testing.T) {
		t.Setenv("JWT_EXPIRY_HOURS", "0")
		if got := accessTokenTTL(); got != 8*time.Hour {
			t.Fatalf("expected 8h, got %v", got)
		}
	})
}

func TestRefreshTokenTTL(t *testing.T) {
	t.Run("defaults to 30d when unset", func(t *testing.T) {
		os.Unsetenv("REFRESH_TOKEN_EXPIRY_DAYS")
		if got := refreshTokenTTL(); got != 30*24*time.Hour {
			t.Fatalf("expected 30d, got %v", got)
		}
	})

	t.Run("uses env value", func(t *testing.T) {
		t.Setenv("REFRESH_TOKEN_EXPIRY_DAYS", "7")
		if got := refreshTokenTTL(); got != 7*24*time.Hour {
			t.Fatalf("expected 7d, got %v", got)
		}
	})

	t.Run("falls back on invalid value", func(t *testing.T) {
		t.Setenv("REFRESH_TOKEN_EXPIRY_DAYS", "x")
		if got := refreshTokenTTL(); got != 30*24*time.Hour {
			t.Fatalf("expected 30d, got %v", got)
		}
	})
}

func TestDocTypeForPrefix(t *testing.T) {
	cases := map[string]string{
		"PO":    "purchase_order",
		"PINV":  "invoice",
		"INV":   "invoice",
		"QT":    "quotation",
		"GRN":   "receipt",
		"RCT":   "receipt",
		"PAY":   "payment",
		"CHQ":   "cheque",
		"EXP":   "expense",
		"CUSTOM": "custom",
	}
	for prefix, want := range cases {
		if got := docTypeForPrefix(prefix); got != want {
			t.Errorf("docTypeForPrefix(%q) = %q, want %q", prefix, got, want)
		}
	}
}

func TestRandomToken(t *testing.T) {
	a := randomToken(32)
	b := randomToken(32)
	if len(a) != 64 {
		t.Fatalf("randomToken(32) produced %d hex chars, want 64", len(a))
	}
	if a == b {
		t.Fatal("randomToken produced identical tokens")
	}
	if strings.ContainsAny(a, "-") {
		t.Fatalf("randomToken leaked a non-hex character (uuid fallback): %q", a)
	}
}

func TestSHA256Hex(t *testing.T) {
	// Known vector: sha256("abc") = ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
	got := sha256Hex("abc")
	want := "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
	if got != want {
		t.Fatalf("sha256Hex(abc) = %q, want %q", got, want)
	}
	// Deterministic
	if sha256Hex("abc") != sha256Hex("abc") {
		t.Fatal("sha256Hex is not deterministic")
	}
}