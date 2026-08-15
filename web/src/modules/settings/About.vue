<template>
  <div class="min-h-screen bg-gray-950 text-gray-100">
    <!-- Header -->
    <div class="bg-gray-900 border-b border-gray-800 px-6 py-4">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 to-violet-700 flex items-center justify-center shadow-lg">
          <Info :size="20" class="text-white" />
        </div>
        <div>
          <h1 class="text-xl font-bold text-white">About Mab ERP</h1>
          <p class="text-xs text-gray-400 mt-0.5">Version, credits &amp; licensing</p>
        </div>
      </div>
    </div>

    <div class="p-6 space-y-6 max-w-4xl">

      <!-- Brand card -->
      <div class="bg-gray-900 border border-gray-800 rounded-2xl p-6 flex items-center gap-5">
        <div class="w-20 h-20 rounded-2xl flex items-center justify-center flex-shrink-0"
          style="background: rgba(99,102,241,0.15); border: 1px solid rgba(99,102,241,0.3);">
          <AppLogo :size="64" />
        </div>
        <div>
          <h2 class="text-2xl font-bold text-white">Mab ERP</h2>
          <p class="text-sm text-gray-400 mt-1">Enterprise Resource Planning — Algeria</p>
          <div class="flex items-center gap-2 mt-3">
            <span class="text-xs px-2.5 py-1 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 font-medium">Version 1.1.0</span>
            <span class="text-xs px-2.5 py-1 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 font-medium">MIT License</span>
            <span class="text-xs px-2.5 py-1 rounded-full bg-slate-700/40 text-slate-300 border border-slate-600/40 font-medium">Go + Vue 3</span>
          </div>
        </div>
      </div>

      <!-- Credits -->
      <div class="bg-gray-900 border border-gray-800 rounded-2xl p-6">
        <div class="flex items-center gap-2 mb-4">
          <Users :size="16" class="text-indigo-400" />
          <h3 class="text-sm font-semibold text-gray-200">Credits</h3>
        </div>
        <div class="space-y-4 text-sm">
          <div>
            <p class="text-gray-300 font-medium">Author &amp; lead developer</p>
            <p class="text-gray-400 mt-0.5">Brahim TIM</p>
          </div>
          <div>
            <p class="text-gray-300 font-medium">Origin</p>
            <p class="text-gray-400 mt-0.5 leading-relaxed">
              Mab ERP is a continuation of the <span class="text-gray-200">Nexus ERP</span> project,
              rebranded and rebuilt for Algerian enterprise requirements — Algerian SCF chart of accounts,
              IRG payroll brackets, CNAS contributions, and G29/G50 tax declarations.
            </p>
          </div>
          <div>
            <p class="text-gray-300 font-medium">Contributors</p>
            <p class="text-gray-400 mt-0.5">Brahim TIM · Nexus ERP community</p>
          </div>
        </div>
      </div>

      <!-- Technology -->
      <div class="bg-gray-900 border border-gray-800 rounded-2xl p-6">
        <div class="flex items-center gap-2 mb-4">
          <Boxes :size="16" class="text-indigo-400" />
          <h3 class="text-sm font-semibold text-gray-200">Technology Stack</h3>
        </div>
        <div class="flex flex-wrap gap-2">
          <span v-for="tech in techStack" :key="tech"
            class="text-xs px-3 py-1.5 rounded-lg bg-gray-800 border border-gray-700 text-gray-300">
            {{ tech }}
          </span>
        </div>
      </div>

      <!-- License -->
      <div class="bg-gray-900 border border-gray-800 rounded-2xl p-6">
        <div class="flex items-center gap-2 mb-4">
          <Scale :size="16" class="text-indigo-400" />
          <h3 class="text-sm font-semibold text-gray-200">License</h3>
        </div>
        <p class="text-sm text-gray-400 leading-relaxed">
          Mab ERP is released under the <span class="text-gray-200 font-medium">MIT License</span>.
          Copyright &copy; {{ new Date().getFullYear() }} Brahim TIM. You may use, copy, modify, merge,
          publish, distribute, sublicense, and sell copies of the software, provided the copyright and
          permission notice is included in all copies or substantial portions.
        </p>
        <p class="text-sm text-gray-500 mt-3">
          THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.
        </p>
      </div>

      <!-- Footer -->
      <p class="text-xs text-gray-500 text-center pt-2">
        Mab ERP v1.1.0 &copy; {{ new Date().getFullYear() }} — Built with &hearts; for Algerian businesses.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Info, Users, Boxes, Scale } from '@lucide/vue'
import AppLogo from '@/components/ui/AppLogo.vue'

const techStack = [
  'Go 1.21', 'Gin', 'pgx', 'PostgreSQL 16',
  'Vue 3', 'TypeScript', 'Vite', 'Tailwind CSS',
  'Axios', 'Pinia', 'Vue Router', 'Apache'
]
</script>