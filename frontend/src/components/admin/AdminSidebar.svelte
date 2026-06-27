<script lang="ts">
  // Объявляем привязываемый пропс вкладки по стандартам Svelte 5
  type AdminTab = 'dashboard' | 'taxonomy' | 'books' | 'persons';
  let { activeTab = $bindable('dashboard') } = $props<{
    activeTab: AdminTab;
  }>();

  // Массив конфигурации пунктов меню для удобного рендеринга
  const menuItems = [
    { id: 'dashboard' as AdminTab, label: 'Мониторинг и Заказы', icon: '📊' },
    { id: 'books' as AdminTab, label: 'Управление книгами', icon: '📚' },
    { id: 'taxonomy' as AdminTab, label: 'Жанры и Характеристики', icon: '🏷️' },
    { id: 'persons' as AdminTab, label: 'Авторы и Издательства', icon: '✍️' },
  ];
</script>

<aside class="w-full md:w-64 shrink-0 sticky top-24 self-start max-h-[calc(100vh-7rem)] overflow-y-auto no-scrollbar">
  <div class="bg-white border border-gray-200 rounded-2xl p-3 shadow-xs space-y-1">
    <div class="text-[10px] font-black uppercase tracking-wider text-gray-400 px-3 py-2 sticky top-0 bg-white z-10">
      Навигация
    </div>
    
    {#each menuItems as item}
      <button
        onclick={() => activeTab = item.id}
        class="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-bold transition-all text-left cursor-pointer group
          {activeTab === item.id 
            ? 'bg-indigo-600 text-white shadow-sm shadow-indigo-100' 
            : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'}"
      >
        <span class="text-base transition-transform group-hover:scale-110">{item.icon}</span>
        <span class="flex-1">{item.label}</span>
        
        {#if activeTab === item.id}
          <span class="text-xs bg-indigo-500 text-white px-1.5 py-0.5 rounded-md font-black">✓</span>
        {/if}
      </button>
    {/each}
  </div>
</aside>

<style>
  /* Скрываем скроллбар но оставляем возможность скролла */
  .no-scrollbar::-webkit-scrollbar {
    display: none;
  }
  .no-scrollbar {
    -ms-overflow-style: none;
    scrollbar-width: none;
  }
</style>