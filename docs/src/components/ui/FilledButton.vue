<template>
  <a :target="props.target" :href="props.href" class="bg-[var(--md-sys-color-primary)] hover:bg-[var(--md-sys-color-primary-fixed-dim)] text-[var(--md-sys-color-on-primary)] rounded-3xl flex ps-7 pe-7 pt-2 pb-2 font-medium text-lg text-center justify-center place-items-center">
    {{ props.title }}
  </a>
</template>

<script lang="ts" setup>
import { defineProps } from 'vue'

interface Props {
  href: string;
  title: string;
  target?: string;
}

const props = defineProps<Props>()

</script>

<style></style>
