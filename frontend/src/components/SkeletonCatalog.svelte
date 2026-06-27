<!-- src/components/SkeletonCatalog.svelte -->
<script lang="ts">
  import SkeletonCard from './SkeletonCard.svelte';
</script>

<div class="max-w-7xl mx-auto px-4 py-6">
  <div class="flex flex-col md:flex-row gap-6">
    <!-- Сайдбар скелетон -->
    <aside class="w-full md:w-68 shrink-0 space-y-4">
      <div class="bg-white p-4 rounded-2xl border border-gray-200 space-y-4">
        <div class="h-6 bg-gray-200 rounded w-24"></div>
        <div class="space-y-2">
          {#each Array(6) as _}
            <div class="h-10 bg-gray-200 rounded"></div>
          {/each}
        </div>
      </div>
    </aside>
    
    <!-- Сетка книг -->
    <div class="flex-1">
      <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
        {#each Array(8) as _}
          <SkeletonCard />
        {/each}
      </div>
    </div>
  </div>
</div>