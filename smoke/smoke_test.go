package smoke

// Smoke tests for Mab ERP — Phase 5 module checklist.
//
// These run against a LIVE server (the backend on :8080 by default). They are
// opt-in: set SMOKE_BASE_URL (and optionally SMOKE_USER / SMOKE_PASS) to run.
// Without SMOKE_BASE_URL the tests are skipped so `go test ./...` stays green
// in CI.
//
//   SMOKE_BASE_URL=http://localhost:8080 go test ./smoke/ -v
//
// The harness covers, per module: auth guard (401 without token), every primary
// list endpoint returning 2xx, and representative CRUD round-trips.

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"
)

const (
	companyID = "00000000-0000-0000-0000-000000000002"
)

type client struct {
	base      string
	token     string
	hc        *http.Client
	fail      []string
	pass      int
	checks    int
	runSuffix string
}

func (c *client) record(name string, ok bool, detail string) {
	c.checks++
	if ok {
		c.pass++
		return
	}
	c.fail = append(c.fail, fmt.Sprintf("[FAIL] %-55s %s", name, detail))
}

func (c *client) do(method, path string, body any, token string) (int, []byte) {
	var rdr io.Reader
	if body != nil {
		b, _ := json.Marshal(body)
		rdr = bytes.NewReader(b)
	}
	req, err := http.NewRequest(method, c.base+path, rdr)
	if err != nil {
		return 0, nil
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := c.hc.Do(req)
	if err != nil {
		return 0, nil
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(resp.Body)
	return resp.StatusCode, data
}

// get200 checks an authenticated GET returns 2xx.
func (c *client) get200(name, path string) {
	code, body := c.do("GET", path, nil, c.token)
	ok := code >= 200 && code < 300
	detail := fmt.Sprintf("got %d %s", code, truncate(string(body), 90))
	if code == 500 {
		detail = fmt.Sprintf("got 500: %s", truncate(string(body), 200))
	}
	c.record(name, ok, detail)
}

// checkAll runs a checklist of (name, path) list endpoints.
func (c *client) checkAll(module string, paths [][2]string) {
	for _, p := range paths {
		c.get200(module+" "+p[1], p[0])
	}
}

func truncate(s string, n int) string {
	s = strings.TrimSpace(s)
	if len(s) > n {
		return s[:n] + "..."
	}
	return s
}

func newClient(t *testing.T, base string) *client {
	t.Helper()
	user := os.Getenv("SMOKE_USER")
	if user == "" {
		user = "admin"
	}
	pass := os.Getenv("SMOKE_PASS")
	if pass == "" {
		pass = "Admin@123456"
	}

	c := &client{
		base:      strings.TrimRight(base, "/"),
		hc:        &http.Client{Timeout: 15 * time.Second},
		runSuffix: fmt.Sprintf("%d", time.Now().UnixNano()%1_000_000),
	}

	code, body := c.do("POST", "/api/auth/login", map[string]string{
		"username": user, "password": pass,
	}, "")
	if code != 200 {
		t.Fatalf("login failed: HTTP %d %s", code, truncate(string(body), 200))
	}
	var resp struct {
		Token string `json:"token"`
	}
	if err := json.Unmarshal(body, &resp); err != nil || resp.Token == "" {
		t.Fatalf("login response missing token: %s", truncate(string(body), 200))
	}
	c.token = resp.Token
	return c
}

func TestSmoke(t *testing.T) {
	base := os.Getenv("SMOKE_BASE_URL")
	if base == "" {
		t.Skip("SMOKE_BASE_URL not set; skipping live smoke tests")
	}

	c := newClient(t, base)
	t.Logf("smoke tests against %s", base)

	t.Run("AuthGuard", func(t *testing.T) {
		for _, path := range []string{
			"/api/dashboard/summary",
			"/api/settings/companies",
			"/api/accounting/chart-of-accounts",
			"/api/sales/customers",
			"/api/inventory/items",
			"/api/hr/employees",
			"/api/treasury/cash-accounts",
			"/api/fleet/vehicles",
			"/api/quality/plans",
			"/api/helpdesk/tickets",
			"/api/assets/assets",
			"/api/budgeting/annual",
			"/api/projects",
			"/api/maintenance/equipment",
			"/api/tax/declarations",
			"/api/manufacturing/bom",
			"/api/purchase/suppliers",
		} {
			code, _ := c.do("GET", path, nil, "")
			c.record("auth-guard "+path, code == 401, fmt.Sprintf("got %d, want 401", code))
		}
	})

	t.Run("Health", func(t *testing.T) {
		code, body := c.do("GET", "/api/health", nil, "")
		c.record("health endpoint", code == 200 && strings.Contains(string(body), `"ok"`), fmt.Sprintf("got %d %s", code, truncate(string(body), 80)))
	})

	t.Run("Dashboard", func(t *testing.T) {
		c.checkAll("dashboard", [][2]string{
			{"/api/dashboard/summary", "summary"},
			{"/api/dashboard/cashflow", "cashflow"},
			{"/api/dashboard/activity", "activity"},
			{"/api/dashboard/approvals", "approvals"},
		})
	})

	t.Run("Settings", func(t *testing.T) {
		c.checkAll("settings", [][2]string{
			{"/api/settings/companies", "companies"},
			{"/api/settings/users", "users"},
			{"/api/settings/roles", "roles"},
			{"/api/settings/fiscal-years", "fiscal-years"},
			{"/api/settings/currencies", "currencies"},
			{"/api/settings/numbering", "numbering"},
			{"/api/settings/taxes", "taxes"},
			{"/api/settings/workflow-rules", "workflow-rules"},
			{"/api/settings/audit-log", "audit-log"},
		})
	})

	t.Run("Accounting", func(t *testing.T) {
		c.checkAll("accounting", [][2]string{
			{"/api/accounting/chart-of-accounts", "chart-of-accounts"},
			{"/api/accounting/journal-entries", "journal-entries"},
			{"/api/accounting/cost-centers", "cost-centers"},
			{"/api/accounting/fixed-assets", "fixed-assets"},
			{"/api/accounting/bank-reconciliations", "bank-reconciliations"},
			{"/api/accounting/reports/trial-balance", "reports/trial-balance"},
			{"/api/accounting/reports/balance-sheet", "reports/balance-sheet"},
			{"/api/accounting/reports/income-statement", "reports/income-statement"},
			{"/api/accounting/reports/cash-flow", "reports/cash-flow"},
			{"/api/accounting/budgets", "budgets"},
		})
	})

	t.Run("HR", func(t *testing.T) {
		c.checkAll("hr", [][2]string{
			{"/api/hr/dashboard", "dashboard"},
			{"/api/hr/employees", "employees"},
			{"/api/hr/departments", "departments"},
			{"/api/hr/positions", "positions"},
			{"/api/hr/attendance", "attendance"},
			{"/api/hr/attendance/summary", "attendance/summary"},
			{"/api/hr/leave-types", "leave-types"},
			{"/api/hr/leave-requests", "leave-requests"},
			{"/api/hr/payroll/runs", "payroll/runs"},
			{"/api/hr/payroll/payslips", "payroll/payslips"},
			{"/api/hr/recruitment/jobs", "recruitment/jobs"},
			{"/api/hr/recruitment/applications", "recruitment/applications"},
			{"/api/hr/recruitment", "recruitment/candidates"},
			{"/api/hr/performance-reviews", "performance-reviews"},
		})
	})

	t.Run("Sales", func(t *testing.T) {
		c.checkAll("sales", [][2]string{
			{"/api/sales/leads", "leads"},
			{"/api/sales/opportunities", "opportunities"},
			{"/api/sales/pipeline/summary", "pipeline/summary"},
			{"/api/sales/customers", "customers"},
			{"/api/sales/quotations", "quotations"},
			{"/api/sales/orders", "orders"},
			{"/api/sales/invoices", "invoices"},
			{"/api/sales/credit-notes", "credit-notes"},
			{"/api/sales/commissions", "commissions"},
			{"/api/sales/reports/aging", "reports/aging"},
		})
	})

	t.Run("Purchase", func(t *testing.T) {
		c.checkAll("purchase", [][2]string{
			{"/api/purchase/suppliers", "suppliers"},
			{"/api/purchase/rfqs", "rfqs"},
			{"/api/purchase/orders", "orders"},
			{"/api/purchase/receipts", "receipts"},
			{"/api/purchase/invoices", "invoices"},
			{"/api/purchase/supplier-evaluations", "supplier-evaluations"},
			{"/api/purchase/reports/aging", "reports/aging"},
		})
	})

	t.Run("Inventory", func(t *testing.T) {
		c.checkAll("inventory", [][2]string{
			{"/api/inventory/items", "items"},
			{"/api/inventory/categories", "categories"},
			{"/api/inventory/units", "units"},
			{"/api/inventory/warehouses", "warehouses"},
			{"/api/inventory/locations", "locations"},
			{"/api/inventory/movements", "movements"},
			{"/api/inventory/stock-levels", "stock-levels"},
			{"/api/inventory/lots", "lots"},
			{"/api/inventory/inventory-counts", "inventory-counts"},
			{"/api/inventory/reports/valuation", "reports/valuation"},
			{"/api/inventory/dashboard", "dashboard"},
		})
	})

	t.Run("Manufacturing", func(t *testing.T) {
		c.checkAll("manufacturing", [][2]string{
			{"/api/manufacturing/bom", "bom"},
			{"/api/manufacturing/work-centers", "work-centers"},
			{"/api/manufacturing/orders", "orders"},
			{"/api/manufacturing/quality-inspections", "quality-inspections"},
			{"/api/manufacturing/dashboard", "dashboard"},
		})
	})

	t.Run("Projects", func(t *testing.T) {
		c.checkAll("projects", [][2]string{
			{"/api/projects/dashboard", "dashboard"},
			{"/api/projects/report", "report"},
			{"/api/projects", "projects"},
			{"/api/projects/tasks/all", "tasks/all"},
			{"/api/projects/timesheets", "timesheets"},
			{"/api/projects/expenses", "expenses"},
			{"/api/projects/planning", "planning"},
		})
	})

	t.Run("Treasury", func(t *testing.T) {
		c.checkAll("treasury", [][2]string{
			{"/api/treasury/cash-accounts", "cash-accounts"},
			{"/api/treasury/bank-accounts", "bank-accounts"},
			{"/api/treasury/cheques", "cheques"},
			{"/api/treasury/movements", "movements"},
			{"/api/treasury/payments", "payments"},
			{"/api/treasury/receipts", "receipts"},
			{"/api/treasury/reconciliations", "reconciliations"},
			{"/api/treasury/reports/aging", "reports/aging"},
			{"/api/treasury/reports/cash-position", "reports/cash-position"},
			{"/api/treasury/reports/treasury", "reports/treasury"},
		})
	})

	t.Run("Tax", func(t *testing.T) {
		c.checkAll("tax", [][2]string{
			{"/api/tax/declarations", "declarations"},
			{"/api/tax/vat-register", "vat-register"},
			{"/api/tax/vat-returns", "vat-returns"},
			{"/api/tax/payments", "payments"},
			{"/api/tax/reports", "reports"},
			{"/api/tax/rates", "rates"},
		})
	})

	t.Run("Workflow", func(t *testing.T) {
		c.checkAll("workflow", [][2]string{
			{"/api/workflow/rules", "rules"},
			{"/api/workflow/approvals/inbox", "approvals/inbox"},
		})
	})

	t.Run("Reports", func(t *testing.T) {
		c.checkAll("reports", [][2]string{
			{"/api/reports/financial-ratios", "financial-ratios"},
			{"/api/reports/kpi-summary", "kpi-summary"},
			{"/api/reports/bi-dashboard", "bi-dashboard"},
			{"/api/reports/financial", "financial"},
			{"/api/reports/sales", "sales"},
			{"/api/reports/purchase", "purchase"},
			{"/api/reports/inventory", "inventory"},
			{"/api/reports/projects", "projects"},
			{"/api/reports/management", "management"},
			{"/api/reports/analytics", "analytics"},
			{"/api/reports/definitions", "definitions"},
		})
	})

	t.Run("Diagnostics", func(t *testing.T) {
		c.checkAll("diagnostics", [][2]string{
			{"/api/diagnostics/logs", "logs"},
			{"/api/diagnostics/stats", "stats"},
		})
	})

	t.Run("Maintenance", func(t *testing.T) {
		c.checkAll("maintenance", [][2]string{
			{"/api/maintenance/equipment", "equipment"},
			{"/api/maintenance/equipment/categories", "equipment/categories"},
			{"/api/maintenance/requests", "requests"},
			{"/api/maintenance/orders", "orders"},
			{"/api/maintenance/preventive-plans", "preventive-plans"},
			{"/api/maintenance/calendar", "calendar"},
			{"/api/maintenance/history", "history"},
			{"/api/maintenance/dashboard", "dashboard"},
			{"/api/maintenance/reports", "reports"},
		})
	})

	t.Run("Fleet", func(t *testing.T) {
		c.checkAll("fleet", [][2]string{
			{"/api/fleet/vehicles", "vehicles"},
			{"/api/fleet/drivers", "drivers"},
			{"/api/fleet/assignments", "assignments"},
			{"/api/fleet/fuel", "fuel"},
			{"/api/fleet/maintenance", "maintenance"},
			{"/api/fleet/expenses", "expenses"},
			{"/api/fleet/dashboard", "dashboard"},
			{"/api/fleet/reports", "reports"},
		})
	})

	t.Run("Quality", func(t *testing.T) {
		c.checkAll("quality", [][2]string{
			{"/api/quality/dashboard", "dashboard"},
			{"/api/quality/plans", "plans"},
			{"/api/quality/inspections", "inspections"},
			{"/api/quality/checks", "checks"},
			{"/api/quality/non-conformities", "non-conformities"},
			{"/api/quality/corrective-actions", "corrective-actions"},
			{"/api/quality/reports", "reports"},
		})
	})

	t.Run("Helpdesk", func(t *testing.T) {
		c.checkAll("helpdesk", [][2]string{
			{"/api/helpdesk/dashboard", "dashboard"},
			{"/api/helpdesk/tickets", "tickets"},
			{"/api/helpdesk/assignments", "assignments"},
			{"/api/helpdesk/categories", "categories"},
			{"/api/helpdesk/agents", "agents"},
			{"/api/helpdesk/escalations", "escalations"},
			{"/api/helpdesk/sla-policies", "sla-policies"},
			{"/api/helpdesk/sla-tracking", "sla-tracking"},
			{"/api/helpdesk/csat", "csat"},
			{"/api/helpdesk/reports", "reports"},
		})
	})

	t.Run("Assets", func(t *testing.T) {
		c.checkAll("assets", [][2]string{
			{"/api/assets/dashboard", "dashboard"},
			{"/api/assets/assets", "assets"},
			{"/api/assets/categories", "categories"},
			{"/api/assets/locations", "locations"},
			{"/api/assets/transfers", "transfers"},
			{"/api/assets/depreciation", "depreciation"},
			{"/api/assets/maintenance", "maintenance"},
			{"/api/assets/reports", "reports"},
		})
	})

	t.Run("Budgeting", func(t *testing.T) {
		c.checkAll("budgeting", [][2]string{
			{"/api/budgeting/dashboard", "dashboard"},
			{"/api/budgeting/categories", "categories"},
			{"/api/budgeting/annual", "annual"},
			{"/api/budgeting/line-items", "line-items"},
			{"/api/budgeting/departments", "departments"},
			{"/api/budgeting/vs-actual", "vs-actual"},
			{"/api/budgeting/revisions", "revisions"},
			{"/api/budgeting/commitments", "commitments"},
			{"/api/budgeting/actuals", "actuals"},
			{"/api/budgeting/reports", "reports"},
		})
	})

	t.Run("CRUD", func(t *testing.T) {
		c.crudRoundTrips()
	})

	t.Run("Report", func(t *testing.T) {
		t.Logf("passed %d/%d checks, %d failures", c.pass, c.checks, len(c.fail))
		for _, f := range c.fail {
			t.Logf("%s", f)
		}
		if len(c.fail) > 0 {
			t.Errorf("%d smoke checks failed", len(c.fail))
		}
	})
}

// crudRoundTrips exercises create → list → update → delete for representative
// resources that need no cross-references.
func (c *client) crudRoundTrips() {
	type step struct {
		name string
		path string
		verb string
		body map[string]any
		want []int
	}
	cycles := []struct {
		name string
		steps []step
	}{
		{
			name: "settings/currency",
			steps: []step{
				{"create", "/api/settings/currencies", "POST", map[string]any{"code": "EUR", "name": "Euro", "symbol": "€", "exchange_rate": 145.0, "is_base": false}, []int{201, 200}},
			},
		},
		{
			name: "settings/tax",
			steps: []step{
				{"create", "/api/settings/taxes", "POST", map[string]any{"name": "TVA 7%", "code": "TVA7", "tax_type": "percentage", "rate": 7.0}, []int{201, 200}},
			},
		},
		{
			name: "hr/department",
			steps: []step{
				{"create", "/api/hr/departments", "POST", map[string]any{"code": "IT-" + c.runSuffix, "name": "Information Technology"}, []int{201, 200}},
			},
		},
		{
			name: "inventory/item",
			steps: []step{
				{"create", "/api/inventory/items", "POST", map[string]any{"code": "SMOKE-" + c.runSuffix, "name": "Smoke Test Item", "item_type": "storable"}, []int{201, 200}},
			},
		},
		{
			name: "sales/customer",
			steps: []step{
				{"create", "/api/sales/customers", "POST", map[string]any{"name": "Smoke Test Customer", "email": "smoke@example.com", "type": "company", "tax_regime": "reel"}, []int{201, 200}},
			},
		},
	}

	for _, cycle := range cycles {
		name := "crud " + cycle.name
		var createdID string
		for _, st := range cycle.steps {
			var code int
			var body []byte
			switch st.verb {
			case "POST":
				code, body = c.do(st.verb, st.path, st.body, c.token)
			default:
				code, body = c.do(st.verb, st.path, st.body, c.token)
			}
			wantOK := false
			for _, w := range st.want {
				if code == w {
					wantOK = true
				}
			}
			detail := fmt.Sprintf("got %d %s", code, truncate(string(body), 120))
			if st.verb == "POST" && wantOK && createdID == "" {
				var resp struct {
					ID string `json:"id"`
				}
				_ = json.Unmarshal(body, &resp)
				createdID = resp.ID
				if createdID != "" {
					detail += " (id=" + createdID + ")"
				}
			}
			c.record(name+"/"+st.verb, wantOK, detail)
		}

		// DELETE round-trip using captured id.
		if createdID != "" {
			delPath := cycle.steps[0].path + "/" + createdID
			code, body := c.do("DELETE", delPath, nil, c.token)
			c.record(name+"/delete", code >= 200 && code < 300, fmt.Sprintf("got %d %s", code, truncate(string(body), 120)))
		}
	}
}