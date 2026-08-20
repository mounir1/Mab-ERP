<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import {
  BarChart2, RefreshCw, Calendar, DollarSign,
  Wrench, CheckCircle, Clock, AlertTriangle,
  TrendingUp, Shield, Settings, FileText, Package
} from '@lucide/vue'
import { maintenanceAPI } from '@/api/client'
import { useAppStore } from '@/stores/app'

const app = useAppStore()

// ─── types (mirror /maintenance/reports response) ────────────────────────────
interface ReportsData {
  year: number
  kpis: {
    total_orders: number
    completed_orders: number
    preventive_count: number
    corrective_count: number
    total_cost: number
    labor_cost: number
    parts_cost: number
    avg_duration_hours: number
    completion_rate: number
  }
  monthly: Array<{ month: string; orders: number; completed: number; total_cost: number }>
  by_category: Array<{ category: string; count: number; cost: number; hours: number }>
  by_status: Array<{ status: string; count: number }>
  mtbf: Array<{ id: string; name: string; code: string; failure_count: number; total_downtime_hours: number; total_cost: number; mtbf_days: number }>
  upcoming_pm: Array<{ id: string; name: string; next_due: string; equipment: string; days_left: number }>
}

// ─── state ────────────────────────────────────────────────────────────────────
const data    = ref<ReportsData | null>(null)
const loading = ref(false)
const year    = ref(new Date().getFullYear())

const years = computed(() => {
  const y = new Date().getFullYear()
  return [y, y-1, y-2, y-3]
})

// ─── computed ─────────────────────────────────────────────────────────────────
const dk = (a: string, b: string) => app.darkMode ? a : b

const kpis = computed(() => data.value?.kpis ?? {
  total_orders: 0, completed_orders: 0, preventive_count: 0, corrective_count: 0,
  total_cost: 0, labor_cost: 0, parts_cost: 0, avg_duration_hours: 0, completion_rate: 0,
})

const byCategory = computed(() => data.value?.by_category ?? [])

const byStatus = computed(() => data.value?.by_status ?? [])

const monthly = computed(() => data.value?.monthly ?? [])

const maxMonthlyCost = computed(() =>
  Math.max(...monthly.value.map(m => m.total_cost), 1)
)

const mtbf = computed(() => data.value?.mtbf ?? [])

const upcomingPM = computed(() => data.value?.upcoming_pm ?? [])

const otherCost = computed(() =>
  Math.max(0, kpis.value.total_cost - kpis.value.labor_cost - kpis.value.parts_cost)
)

const avgCostPerOrder = computed(() =>
  kpis.value.total_orders > 0 ? kpis.value.total_cost / kpis.value.total_orders : 0
)

// ─── helpers ─────────────────────────────────────────────────────────────────
const fmt = (n: number) =>
  new Intl.NumberFormat('fr-DZ', { maximumFractionDigits: 0 }).format(n) + ' DZD'

const fmtDate = (s?: string) => {
  if (!s) return '—'
  return new Date(s).toLocaleDateString('fr-DZ', { day:'2-digit', month:'short' })
}

const pct = (n: number, total: number) =>
  total > 0 ? Math.round((n / total) * 100) : 0

const statusBadge = (s: string) => ({
  draft:'bg-slate-500/15 text-slate-400',
  planned:'bg-indigo-500/15 text-indigo-400',
  in_progress:'bg-blue-500/15 text-blue-400',
  on_hold:'bg-amber-500/15 text-amber-400',
  completed:'bg-emerald-500/15 text-emerald-400',
  cancelled:'bg-rose-500/15 text-rose-400',
}[s] ?? 'bg-slate-500/15 text-slate-400')

const statusLabel = (s: string) => ({
  draft:'Draft', planned:'Planned', in_progress:'In Progress', on_hold:'On Hold',
  completed:'Completed', cancelled:'Cancelled',
}[s] ?? s)

const monthShort = (m: string) => {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  const idx = parseInt(m.split('-')[1] || '1') - 1
  return months[idx] ?? m
}

// ─── data loading ─────────────────────────────────────────────────────────────
const load = async () => {
  loading.value = true
  try {
    const res = await maintenanceAPI.getReports({ year: String(year.value) })
    data.value = res.data
  } catch {
    app.addToast('Failed to load maintenance reports', 'error')
  } finally {
    loading.value = false
  }
}

watch(year, load)
onMounted(load)
</script>

<template>
  <div :class="['min-h-screen p-6 space-y-6', dk('bg-slate-950 text-slate-100','bg-slate-50 text-slate-900')]">

    <!-- Header -->
    <div class="flex items-center justify-between flex-wrap gap-4">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-violet-500/15 flex items-center justify-center">
          <BarChart2 class="w-5 h-5 text-violet-400" />
        </div>
        <div>
          <h1 class="text-xl font-bold">Maintenance Reports</h1>
          <p :class="['text-sm', dk('text-slate-400','text-slate-500')]">KPIs, costs, and performance analytics</p>
        </div>
      </div>
      <div class="flex items-center gap-3">
        <select v-model="year"
          :class="['px-3 py-2 rounded-lg border text-sm',
            dk('bg-slate-900 border-slate-700 text-slate-100','bg-white border-slate-200 text-slate-900')]">
          <option v-for="y in years" :key="y" :value="y">{{ y }}</option>
        </select>
        <button @click="load"
          :class="['p-2 rounded-lg border transition-colors',
            dk('bg-slate-900 border-slate-700 text-slate-300 hover:bg-slate-800',
               'bg-white border-slate-200 text-slate-700 hover:bg-slate-50')]">
          <RefreshCw :class="['w-4 h-4', loading && 'animate-spin']" />
        </button>
      </div>
    </div>

    <div v-if="loading" class="flex items-center justify-center py-20">
      <RefreshCw class="w-8 h-8 animate-spin text-violet-400" />
    </div>

    <template v-else-if="data">

      <!-- ── Top KPI Row ─────────────────────────────────────────────────── -->
      <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
        <div :class="['rounded-xl border p-4', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
          <div class="flex items-center justify-between mb-3">
            <span :class="['text-xs font-medium', dk('text-slate-400','text-slate-500')]">Total Cost</span>
            <div class="w-8 h-8 rounded-lg bg-teal-500/10 flex items-center justify-center">
              <DollarSign class="w-4 h-4 text-teal-400" />
            </div>
          </div>
          <div class="text-xl font-bold">{{ fmt(kpis.total_cost) }}</div>
          <div :class="['text-xs mt-1', dk('text-slate-500','text-slate-400')]">Avg {{ fmt(avgCostPerOrder) }} / order</div>
        </div>

        <div :class="['rounded-xl border p-4', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
          <div class="flex items-center justify-between mb-3">
            <span :class="['text-xs font-medium', dk('text-slate-400','text-slate-500')]">Completion Rate</span>
            <div class="w-8 h-8 rounded-lg bg-emerald-500/10 flex items-center justify-center">
              <CheckCircle class="w-4 h-4 text-emerald-400" />
            </div>
          </div>
          <div class="text-xl font-bold">{{ kpis.completion_rate?.toFixed(1) ?? '—' }}%</div>
          <div class="mt-2 h-1.5 rounded-full" :class="dk('bg-slate-700','bg-slate-200')">
            <div class="h-full rounded-full bg-emerald-400 transition-all"
              :style="{ width: (kpis.completion_rate || 0) + '%' }"></div>
          </div>
        </div>

        <div :class="['rounded-xl border p-4', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
          <div class="flex items-center justify-between mb-3">
            <span :class="['text-xs font-medium', dk('text-slate-400','text-slate-500')]">Avg Duration</span>
            <div class="w-8 h-8 rounded-lg bg-amber-500/10 flex items-center justify-center">
              <Clock class="w-4 h-4 text-amber-400" />
            </div>
          </div>
          <div class="text-xl font-bold">{{ kpis.avg_duration_hours?.toFixed(1) ?? '—' }}h</div>
          <div :class="['text-xs mt-1', dk('text-slate-500','text-slate-400')]">Mean repair time</div>
        </div>

        <div :class="['rounded-xl border p-4', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
          <div class="flex items-center justify-between mb-3">
            <span :class="['text-xs font-medium', dk('text-slate-400','text-slate-500')]">Preventive</span>
            <div class="w-8 h-8 rounded-lg bg-violet-500/10 flex items-center justify-center">
              <Shield class="w-4 h-4 text-violet-400" />
            </div>
          </div>
          <div class="text-xl font-bold">{{ kpis.preventive_count }}</div>
          <div :class="['text-xs mt-1', dk('text-slate-500','text-slate-400')]">scheduled orders</div>
        </div>

        <div :class="['rounded-xl border p-4', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
          <div class="flex items-center justify-between mb-3">
            <span :class="['text-xs font-medium', dk('text-slate-400','text-slate-500')]">Corrective</span>
            <div class="w-8 h-8 rounded-lg bg-rose-500/10 flex items-center justify-center">
              <Wrench class="w-4 h-4 text-rose-400" />
            </div>
          </div>
          <div class="text-xl font-bold">{{ kpis.corrective_count }}</div>
          <div :class="['text-xs mt-1', dk('text-slate-500','text-slate-400')]">unplanned orders</div>
        </div>
      </div>

      <!-- ── Orders by Status + Cost Breakdown ───────────────────────────── -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">

        <!-- Orders by Status -->
        <div :class="['rounded-xl border p-5', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
          <div class="flex items-center gap-2 mb-4">
            <Wrench class="w-4 h-4 text-slate-400" />
            <h2 class="font-semibold text-sm">Work Orders by Status — {{ year }}</h2>
            <span :class="['ml-auto text-xs font-bold', dk('text-slate-400','text-slate-500')]">
              {{ kpis.total_orders }} total
            </span>
          </div>
          <div class="space-y-3">
            <div v-for="s in byStatus" :key="s.status">
              <div class="flex items-center justify-between text-xs mb-1">
                <span :class="dk('text-slate-300','text-slate-700')">{{ statusLabel(s.status) }}</span>
                <span :class="['font-semibold', dk('text-slate-400','text-slate-500')]">{{ s.count }}</span>
              </div>
              <div class="h-1.5 rounded-full" :class="dk('bg-slate-800','bg-slate-200')">
                <div class="h-full rounded-full bg-violet-400 transition-all"
                  :style="{ width: pct(s.count, kpis.total_orders) + '%' }"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Cost Breakdown -->
        <div :class="['rounded-xl border p-5', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
          <div class="flex items-center gap-2 mb-4">
            <DollarSign class="w-4 h-4 text-teal-400" />
            <h2 class="font-semibold text-sm">Cost Breakdown — {{ year }}</h2>
          </div>
          <div class="space-y-4">
            <div v-for="item in [
              { label: 'Labor Cost',  value: kpis.labor_cost,  color: 'bg-blue-400',    text: 'text-blue-400' },
              { label: 'Parts Cost',  value: kpis.parts_cost,  color: 'bg-amber-400',   text: 'text-amber-400' },
              { label: 'Other Cost',  value: otherCost,        color: 'bg-violet-400',  text: 'text-violet-400' },
            ]" :key="item.label">
              <div class="flex items-center justify-between text-xs mb-1">
                <span :class="dk('text-slate-400','text-slate-500')">{{ item.label }}</span>
                <span :class="['font-semibold', item.text]">{{ fmt(item.value) }}</span>
              </div>
              <div class="h-2 rounded-full" :class="dk('bg-slate-800','bg-slate-200')">
                <div :class="['h-full rounded-full transition-all', item.color]"
                  :style="{ width: pct(item.value, kpis.total_cost) + '%' }"></div>
              </div>
              <div :class="['text-xs mt-0.5 text-right', dk('text-slate-500','text-slate-400')]">
                {{ pct(item.value, kpis.total_cost) }}%
              </div>
            </div>
            <div :class="['pt-3 border-t flex items-center justify-between', dk('border-slate-700','border-slate-200')]">
              <span :class="['text-xs font-medium', dk('text-slate-300','text-slate-700')]">Total</span>
              <span class="font-bold text-teal-400">{{ fmt(kpis.total_cost) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- ── Monthly Cost Chart ─────────────────────────────────────────── -->
      <div :class="['rounded-xl border p-5', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
        <div class="flex items-center gap-2 mb-5">
          <TrendingUp class="w-4 h-4 text-violet-400" />
          <h2 class="font-semibold text-sm">Monthly Cost Trend — {{ year }}</h2>
        </div>
        <div v-if="!monthly.length" class="text-center py-8">
          <p :class="['text-sm', dk('text-slate-500','text-slate-400')]">No monthly data available</p>
        </div>
        <div v-else class="flex items-end gap-2 h-40">
          <div v-for="m in monthly" :key="m.month"
            class="flex-1 flex flex-col items-center gap-1 min-w-0">
            <div :class="['text-xs font-medium', dk('text-slate-400','text-slate-500')]" style="writing-mode:initial">
              {{ m.orders }}
            </div>
            <div class="w-full relative flex items-end" style="height:100px">
              <div class="w-full rounded-t-md transition-all bg-violet-500/70 hover:bg-violet-500 cursor-default"
                :style="{ height: Math.max(4, (m.total_cost / maxMonthlyCost) * 100) + 'px' }"
                :title="`${monthShort(m.month)}: ${m.orders} orders, ${m.total_cost.toLocaleString('fr-DZ')} DZD`">
              </div>
            </div>
            <div :class="['text-xs', dk('text-slate-400','text-slate-500')]">{{ monthShort(m.month) }}</div>
          </div>
        </div>
      </div>

      <!-- ── By Category + MTBF ──────────────────────────────────────────── -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">

        <!-- By Category -->
        <div :class="['rounded-xl border p-5', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
          <div class="flex items-center gap-2 mb-4">
            <Package class="w-4 h-4 text-amber-400" />
            <h2 class="font-semibold text-sm">Orders by Equipment Category</h2>
          </div>
          <div v-if="!byCategory.length" class="text-center py-8">
            <p :class="['text-sm', dk('text-slate-500','text-slate-400')]">No category data</p>
          </div>
          <div v-else class="space-y-3">
            <div v-for="c in byCategory" :key="c.category">
              <div class="flex items-center justify-between text-xs mb-1">
                <span :class="dk('text-slate-300','text-slate-700')">{{ c.category }}</span>
                <div class="flex items-center gap-3">
                  <span :class="['font-medium', dk('text-slate-400','text-slate-500')]">{{ c.count }} orders</span>
                  <span class="font-semibold text-teal-400">{{ fmt(c.cost) }}</span>
                </div>
              </div>
              <div class="h-1.5 rounded-full" :class="dk('bg-slate-800','bg-slate-200')">
                <div class="h-full rounded-full bg-amber-400 transition-all"
                  :style="{ width: pct(c.count, kpis.total_orders) + '%' }"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- MTBF -->
        <div :class="['rounded-xl border p-5', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
          <div class="flex items-center gap-2 mb-4">
            <BarChart2 class="w-4 h-4 text-violet-400" />
            <h2 class="font-semibold text-sm">Equipment Reliability (MTBF)</h2>
          </div>
          <div v-if="!mtbf.length" class="text-center py-8">
            <p :class="['text-sm', dk('text-slate-500','text-slate-400')]">No failure history</p>
          </div>
          <div v-else class="space-y-2">
            <div v-for="(e, idx) in mtbf" :key="e.id"
              :class="['flex items-center gap-3 p-2.5 rounded-xl text-sm',
                dk('hover:bg-slate-800','hover:bg-slate-50')]">
              <div :class="['w-6 h-6 rounded-lg flex items-center justify-center text-xs font-bold flex-shrink-0',
                idx === 0 ? 'bg-amber-500/20 text-amber-400' :
                idx === 1 ? 'bg-slate-600/40 text-slate-300' :
                idx === 2 ? 'bg-orange-700/20 text-orange-400' :
                dk('bg-slate-800 text-slate-500','bg-slate-100 text-slate-400')]">
                {{ idx+1 }}
              </div>
              <div class="flex-1 min-w-0">
                <div class="font-medium text-sm truncate">{{ e.name }}</div>
                <div :class="['text-xs', dk('text-slate-500','text-slate-400')]">
                  {{ e.failure_count }} failures • {{ e.total_downtime_hours.toFixed(1) }}h downtime
                </div>
              </div>
              <div class="text-right flex-shrink-0">
                <div class="font-semibold text-teal-400 text-sm">{{ fmt(e.total_cost) }}</div>
                <div :class="['text-xs', dk('text-slate-500','text-slate-400')]">{{ e.mtbf_days.toFixed(1) }}d MTBF</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ── Upcoming Preventive Maintenance ────────────────────────────── -->
      <div :class="['rounded-xl border p-5', dk('bg-slate-900 border-slate-800','bg-white border-slate-200')]">
        <div class="flex items-center gap-2 mb-4">
          <Calendar class="w-4 h-4 text-cyan-400" />
          <h2 class="font-semibold text-sm">Upcoming Preventive Maintenance (next 60 days)</h2>
        </div>
        <div v-if="!upcomingPM.length" class="text-center py-8">
          <p :class="['text-sm', dk('text-slate-500','text-slate-400')]">No upcoming PM scheduled</p>
        </div>
        <div v-else class="space-y-2">
          <div v-for="p in upcomingPM" :key="p.id"
            :class="['flex items-center gap-3 p-2.5 rounded-xl text-sm',
              dk('hover:bg-slate-800','hover:bg-slate-50')]">
            <div class="w-9 h-9 rounded-lg bg-emerald-500/10 flex items-center justify-center flex-shrink-0">
              <FileText class="w-4 h-4 text-emerald-400" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="font-medium text-sm truncate">{{ p.name }}</div>
              <div :class="['text-xs', dk('text-slate-500','text-slate-400')]">Equipment: {{ p.equipment }}</div>
            </div>
            <div class="text-right flex-shrink-0">
              <div class="font-medium text-sm">{{ fmtDate(p.next_due) }}</div>
              <div :class="['text-xs', p.days_left < 0 ? 'text-rose-400' : dk('text-slate-500','text-slate-400')]">
                {{ p.days_left < 0 ? 'overdue' : p.days_left + ' days left' }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- Empty state -->
    <div v-else-if="!loading" class="text-center py-20">
      <BarChart2 class="w-12 h-12 mx-auto mb-3 text-slate-500" />
      <p :class="['font-medium', dk('text-slate-300','text-slate-700')]">No report data available</p>
      <button @click="load" class="mt-3 text-sm text-violet-400 hover:underline">Retry</button>
    </div>

  </div>
</template>