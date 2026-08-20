-- =============================================================================
-- Mab ERP — Settings: company_currencies reconciliation
-- Version: 0022 | Creates company-level currency config used by settings handler
-- Idempotent. Fixes fresh-install gap where embedded set lacked the table.
-- =============================================================================

CREATE TABLE IF NOT EXISTS company_currencies (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id    UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    code          VARCHAR(10) NOT NULL,
    name          VARCHAR(100) NOT NULL,
    symbol        VARCHAR(10) NOT NULL DEFAULT '',
    exchange_rate NUMERIC(18,6) NOT NULL DEFAULT 1,
    is_base       BOOLEAN NOT NULL DEFAULT FALSE,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(company_id, code)
);

-- Seed default currency for the default company
INSERT INTO company_currencies (company_id, code, name, symbol, exchange_rate, is_base, is_active)
SELECT id, 'DZD', 'Algerian Dinar', 'DA', 1.0, TRUE, TRUE
FROM companies
WHERE id = '00000000-0000-0000-0000-000000000002'
ON CONFLICT (company_id, code) DO NOTHING;

-- Also seed DZD for any company that has none yet
INSERT INTO company_currencies (company_id, code, name, symbol, exchange_rate, is_base, is_active)
SELECT c.id, 'DZD', 'Algerian Dinar', 'DA', 1.0, TRUE, TRUE
FROM companies c
WHERE NOT EXISTS (SELECT 1 FROM company_currencies cc WHERE cc.company_id = c.id AND cc.code = 'DZD')
ON CONFLICT (company_id, code) DO NOTHING;

-- Seed default Algerian taxes for the default company (if none exist yet)
INSERT INTO taxes (company_id, name, code, tax_type, rate, is_active)
SELECT '00000000-0000-0000-0000-000000000002', name, code, tax_type, rate, TRUE
FROM (VALUES
    ('TVA 19%', 'TVA19', 'percentage', 19.00),
    ('TVA 9%',  'TVA9',  'percentage', 9.00),
    ('TVA Exonéré', 'TVA0', 'percentage', 0.00),
    ('TAP 2%',  'TAP2',  'percentage', 2.00)
) AS s(name, code, tax_type, rate)
WHERE NOT EXISTS (SELECT 1 FROM taxes t WHERE t.company_id = '00000000-0000-0000-0000-000000000002')
ON CONFLICT (company_id, code) DO NOTHING;

-- ============================================================
-- END 0022_fix_company_currencies.sql
-- ============================================================