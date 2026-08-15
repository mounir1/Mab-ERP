package middleware

import (
	"context"
	"log"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"os"
)

type Claims struct {
	UserID    string `json:"sub"`
	Role      string `json:"role"`
	CompanyID string `json:"company_id"`
	BranchID  string `json:"branch_id"`
	TenantID  string `json:"tenant_id"`
	jwt.RegisteredClaims
}

// JWTAuth middleware validates bearer tokens
func JWTAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		header := c.GetHeader("Authorization")
		if header == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			return
		}

		parts := strings.SplitN(header, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization format"})
			return
		}

		tokenStr := parts[1]
		claims := &Claims{}

		token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrSignatureInvalid
			}
			return jwtSecret(), nil
		})

		if err != nil || !token.Valid {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			return
		}

		// Set user context
		c.Set("user_id", claims.UserID)
		c.Set("role", claims.Role)
		c.Set("company_id", claims.CompanyID)
		c.Set("branch_id", claims.BranchID)
		c.Set("tenant_id", claims.TenantID)
		c.Next()
	}
}

// RequireRole enforces role-based access
func RequireRole(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		role, _ := c.Get("role")
		roleStr, _ := role.(string)

		for _, r := range roles {
			if r == roleStr || roleStr == "admin" || roleStr == "superadmin" {
				c.Next()
				return
			}
		}

		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "Insufficient permissions"})
	}
}

// AuditLog middleware records every mutating request to the audit_logs table.
func AuditLog(db *pgxpool.Pool) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		method := c.Request.Method
		if method == http.MethodGet || method == http.MethodOptions {
			return
		}

		action := strings.ToUpper(method)
		entityType := entityTypeFromPath(c.Request.URL.Path)
		entityID := c.Param("id")
		userID, _ := c.Get("user_id")
		companyID, _ := c.Get("company_id")
		tenantID, _ := c.Get("tenant_id")

		userIDStr, _ := userID.(string)
		companyIDStr, _ := companyID.(string)
		tenantIDStr, _ := tenantID.(string)

		// tenant_id is NOT NULL in audit_logs; skip if unavailable
		if tenantIDStr == "" {
			return
		}

		ctx, cancel := context.WithTimeout(c.Request.Context(), 3*time.Second)
		defer cancel()

		_, err := db.Exec(ctx, `
			INSERT INTO audit_logs (tenant_id, company_id, user_id, action, entity_type, entity_id, ip_address, user_agent)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
			tenantIDStr, nullUUID(companyIDStr), nullUUID(userIDStr),
			action, entityType, entityID, c.ClientIP(), c.Request.UserAgent())
		if err != nil {
			log.Printf("[AUDIT] failed to record %s %s: %v", action, c.Request.URL.Path, err)
		}
	}
}

// entityTypeFromPath derives a stable entity type from the API route path,
// e.g. "/api/settings/companies" -> "settings.companies".
func entityTypeFromPath(path string) string {
	trimmed := strings.TrimPrefix(path, "/api/")
	trimmed = strings.Trim(trimmed, "/")
	parts := strings.Split(trimmed, "/")
	if len(parts) == 0 || parts[0] == "" {
		return "misc"
	}
	return strings.Join(parts, ".")
}

// nullUUID returns nil for empty strings so nullable UUID columns accept NULL.
func nullUUID(s string) interface{} {
	if s == "" {
		return nil
	}
	return s
}

// RateLimit is a simple in-memory fixed-window limiter keyed by client IP.
func RateLimit(limit int, window time.Duration) gin.HandlerFunc {
	var mu sync.Mutex
	buckets := make(map[string][]time.Time)

	return func(c *gin.Context) {
		ip := c.ClientIP()
		now := time.Now()

		mu.Lock()
		recent := buckets[ip]
		cutoff := now.Add(-window)
		kept := recent[:0]
		for _, t := range recent {
			if t.After(cutoff) {
				kept = append(kept, t)
			}
		}
		if len(kept) >= limit {
			mu.Unlock()
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{"error": "Too many requests, please try again later"})
			return
		}
		kept = append(kept, now)
		buckets[ip] = kept
		mu.Unlock()

		c.Next()
	}
}

func jwtSecret() []byte {
	return []byte(os.Getenv("JWT_SECRET"))
}

// GetUserID extracts the user ID from context
func GetUserID(c *gin.Context) string {
	v, _ := c.Get("user_id")
	s, _ := v.(string)
	return s
}

// GetCompanyID extracts the company ID from context
func GetCompanyID(c *gin.Context) string {
	v, _ := c.Get("company_id")
	s, _ := v.(string)
	return s
}
