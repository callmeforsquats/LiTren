<!-- src/components/SkeletonCard.svelte -->
<script lang="ts">
  let { variant = 'default' }: { variant?: 'default' | 'cart' | 'review' } = $props();
</script>

{#if variant === 'cart'}
  <div class="bg-white p-3 rounded-2xl border border-gray-200 flex gap-3 h-36 animate-pulse">
    <div class="w-20 bg-gray-200 rounded-xl"></div>
    <div class="flex-1 space-y-2">
      <div class="h-5 bg-gray-200 rounded-lg w-3/4"></div>
      <div class="h-4 bg-gray-200 rounded-lg w-1/2"></div>
      <div class="h-8 bg-gray-200 rounded-lg w-32 mt-4"></div>
    </div>
  </div>
{:else if variant === 'review'}
  <div class="bg-white p-4 rounded-2xl border border-gray-200 space-y-3 animate-pulse">
    <div class="flex justify-between">
      <div class="h-4 bg-gray-200 rounded w-32"></div>
      <div class="h-4 bg-gray-200 rounded w-24"></div>
    </div>
    <div class="h-4 bg-gray-200 rounded w-full"></div>
    <div class="h-4 bg-gray-200 rounded w-3/4"></div>
  </div>
{:else}
  <!-- Дефолтный скелетон для карточки книги -->
  <div class="bg-white border border-gray-100 rounded-2xl p-3 shadow-xs animate-pulse">
    <div class="aspect-3/4 w-full rounded-xl bg-gray-200"></div>
    <div class="mt-2 space-y-2">
      <div class="h-3 bg-gray-200 rounded w-24"></div>
      <div class="h-4 bg-gray-200 rounded w-full"></div>
      <div class="h-4 bg-gray-200 rounded w-3/4"></div>
      <div class="flex justify-between items-center mt-3">
        <div class="h-5 bg-gray-200 rounded w-16"></div>
        <div class="h-8 bg-gray-200 rounded w-16"></div>
      </div>
    </div>
  </div>
{/if}