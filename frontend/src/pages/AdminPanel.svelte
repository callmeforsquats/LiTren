<script lang="ts">
  import AdminSidebar from '../components/admin/AdminSidebar.svelte';
  import AdminDashboard from '../components/admin/AdminDashboard.svelte';
  import AdminBooksSection from '../components/admin/AdminBookSection.svelte';
  import TaxonomySection from '../components/admin/TaxonomySection.svelte';
  import AdminPersonSection from '../components/admin/AdminPersonSection.svelte';
  import AdminBookSection from '../components/admin/AdminBookSection.svelte';

  // Инициализируем реактивную переменную вкладки по умолчанию
  type AdminTab='dashboard'|'taxonomy'|'books'|'persons';
  let activeTab = $state<AdminTab>('dashboard');
</script>

<div class="max-w-7xl mx-auto px-4 py-8">
  <!-- Заголовок панели управления -->
  <div class="mb-8 border-b border-gray-200 pb-4">
    <h1 class="text-2xl font-black text-gray-900 tracking-tight flex items-center gap-2">
      <span>⚙️</span> Панель администратора <span class="text-xs font-bold bg-indigo-100 text-indigo-700 px-2.5 py-0.5 rounded-full uppercase tracking-wider">ЛиТрен v5</span>
    </h1>
    <p class="text-xs text-gray-400 mt-1 font-medium">Управление заказами, каталогом книг, авторами и справочниками таксономии магазина</p>
  </div>

  <div class="flex flex-col md:flex-row gap-6 items-start min-h-[calc(100vh-16rem)]">
    
    <!-- Левая колонка: Меню навигации админки (передаем activeTab через bind:) -->
    <AdminSidebar bind:activeTab />

    <!-- Правая колонка: Основной контейнер контента вкладок -->
    <main class="flex-1 w-full bg-white border border-gray-200 rounded-2xl p-6 shadow-xs min-h-125">
      {#if activeTab === 'dashboard'}
        <AdminDashboard />
      {:else if activeTab === 'books'}
        <AdminBookSection />
      {:else if activeTab === 'taxonomy'}
        <TaxonomySection />
      {:else if activeTab === 'persons'}
        <AdminPersonSection />
      {/if}
    </main>
    
  </div>
</div>
