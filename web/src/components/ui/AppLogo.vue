<script setup lang="ts">
defineProps<{ size?: number }>()
</script>

<template>
  <img :src="'/logo.svg'" :width="size ?? 32" :height="size ?? 32"
    alt="Mab ERP logo" class="flex-shrink-0" draggable="false" />
</template>