package middleware

import "testing"

func TestEntityTypeFromPath(t *testing.T) {
	cases := map[string]string{
		"/api/settings/companies":            "settings.companies",
		"/api/purchase/receipts/abc/validate": "purchase.receipts.abc.validate",
		"/api/purchase/receipts":             "purchase.receipts",
		"/api/health":                        "health",
		"/api/":                              "misc",
		"/api":                               "api",
		"/api/settings/companies/123":        "settings.companies.123",
	}
	for in, want := range cases {
		if got := entityTypeFromPath(in); got != want {
			t.Errorf("entityTypeFromPath(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestNullUUID(t *testing.T) {
	if nullUUID("") != nil {
		t.Fatal("nullUUID(\"\") should return nil")
	}
	if v := nullUUID("abc"); v != "abc" {
		t.Fatalf("nullUUID(\"abc\") = %v, want \"abc\"", v)
	}
}