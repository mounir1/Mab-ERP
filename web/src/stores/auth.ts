import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authAPI } from '@/api/client'

interface User {
  id: string
  username: string
  email: string
  full_name: string
  role: string
  role_id: string
  company_id: string
  branch_id: string
  tenant_id: string
}

const ADMIN_ROLES = ['admin', 'superadmin']

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('mab_token'))
  const refreshToken = ref<string | null>(localStorage.getItem('mab_refresh_token'))
  const user = ref<User | null>(null)
  const permissions = ref<string[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  const isAuthenticated = computed(() => !!token.value)
  const userName = computed(() => user.value?.full_name ?? '')
  const userRole = computed(() => user.value?.role ?? user.value?.role_id ?? '')
  const companyId = computed(() => user.value?.company_id ?? '')

  async function login(username: string, password: string, companyId?: string) {
    loading.value = true
    error.value = null
    try {
      const response = await authAPI.login(username, password, companyId)
      const data = response.data
      token.value = data.token
      refreshToken.value = data.refresh_token
      user.value = data.user
      permissions.value = Array.isArray(data.permissions) ? data.permissions : []
      localStorage.setItem('mab_token', data.token)
      localStorage.setItem('mab_refresh_token', data.refresh_token)
      if (data.user) localStorage.setItem('mab_user', JSON.stringify(data.user))
      return data
    } catch (err: unknown) {
      const e = err as { response?: { data?: { error?: string } } }
      error.value = e.response?.data?.error ?? 'Login failed'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    const rt = refreshToken.value
    try {
      await authAPI.logout(rt ?? undefined)
    } catch {
      // Ignore
    } finally {
      token.value = null
      refreshToken.value = null
      user.value = null
      permissions.value = []
      localStorage.removeItem('mab_token')
      localStorage.removeItem('mab_refresh_token')
      localStorage.removeItem('mab_user')
    }
  }

  async function refresh() {
    if (!refreshToken.value) throw new Error('No refresh token')
    const response = await authAPI.refresh(refreshToken.value)
    token.value = response.data.token
    if (response.data.refresh_token) {
      refreshToken.value = response.data.refresh_token
      localStorage.setItem('mab_refresh_token', response.data.refresh_token)
    }
    localStorage.setItem('mab_token', response.data.token)
  }

  async function fetchCurrentUser() {
    const stored = localStorage.getItem('mab_user')
    if (stored) {
      try {
        const parsed = JSON.parse(stored)
        user.value = parsed
        if (ADMIN_ROLES.includes(parsed.role ?? '')) {
          permissions.value = ['*']
        }
      } catch {
        // Invalid stored data
      }
    }
  }

  function hasPermission(permission: string): boolean {
    if (ADMIN_ROLES.includes(userRole.value)) return true
    if (permissions.value.includes('*')) return true
    return permissions.value.includes(permission)
  }

  return {
    token, refreshToken, user, permissions, loading, error,
    isAuthenticated, userName, userRole, companyId,
    login, logout, refresh, fetchCurrentUser, hasPermission
  }
}, {
  persist: false
})
