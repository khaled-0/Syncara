<template>
  <a :target="props.target" :href="props.href" class="bg-[var(--md-sys-color-secondary-container)] hover:bg-[#4e563d] text-[var(--md-sys-color-on-secondary-container)] rounded-3xl flex ps-7 pe-7 pt-2 pb-2 font-medium text-lg text-center justify-center place-items-center">
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
