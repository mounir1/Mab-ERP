-- Migration: 0021_auth_hardening.sql
-- Auth hardening: refresh-token revocation, rate limiting support
-- Idempotent: safe to run multiple times

-- ============================================================
-- REVOKED TOKENS (JTI-based blacklist for refresh tokens)
-- ============================================================

CREATE TABLE IF NOT EXISTS revoked_tokens (
    id          BIGSERIAL PRIMARY KEY,
    jti         TEXT NOT NULL UNIQUE,
    user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
    reason      TEXT NOT NULL DEFAULT 'logout',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_revoked_tokens_user ON revoked_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_revoked_tokens_jti ON revoked_tokens(jti);
