<script lang="ts">
  let { rating, reviewsCount = null }: { rating: number; reviewsCount?: number | null } = $props();

  // Переводим рейтинг в проценты для ширины золотого блока (например, 4.5 из 5 = 90%)
  let fillPercentage = $derived(Math.min(Math.max((rating / 5) * 100, 0), 100));
</script>

<div class="flex items-center gap-1.5 select-none">
  <!-- Контейнер звезд -->
  <div class="relative inline-block text-lg leading-none" title="Рейтинг: {rating.toFixed(1)} из 5">
    
    <!-- Задний план: 5 пустых (серых) звезд -->
    <div class="text-gray-200 flex gap-0.5">
      <span>★</span><span>★</span><span>★</span><span>★</span><span>★</span>
    </div>
    
    <!-- Передний план: 5 заполненных (золотых) звезд с динамической шириной -->
    <div 
      class="absolute top-0 left-0 text-amber-400 flex gap-0.5 overflow-hidden whitespace-nowrap transition-all duration-300"
      style="width: {fillPercentage}%"
    >
      <span>★</span><span>★</span><span>★</span><span>★</span><span>★</span>
    </div>

  </div>

  <!-- Опциональный вывод текстового рейтинга и количества отзывов -->
  <div class="flex items-baseline gap-1 text-xs font-bold text-gray-600">
    <span class="text-gray-900">{rating.toFixed(1)}</span>
    {#if reviewsCount !== null}
      <span class="text-gray-400 font-medium">({reviewsCount})</span>
    {/if}
  </div>
</div>
