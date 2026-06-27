<script lang="ts">
  import { onMount, untrack } from 'svelte';
  import { orderApi } from '../../api/orders';
  import { debounce } from '../../api/client';
  import { OrderFilter, Status } from '../../types/users';
  import type { OrderRead } from '../../types/users';
  import OrderCard from '../../components/OrderCard.svelte';
  import OrderDetailsModal from '../../components/OrderDetailModal.svelte';

  let filters = $state(new OrderFilter({
    min_price: null,
    max_price: null,
    status: null,
    limit: 20,
    offset: 0
  }));

  let orders = $state<OrderRead[]>([]);
  let isLoading = $state(true);
  let errorMessage = $state('');

  // Состояния для модалки
  let selectedOrder = $state<OrderRead | null>(null);
  let isDetailsOpen = $state(false);

  // Вычисляемые метрики
  let totalSum = $derived(orders.reduce((sum, order) => sum + order.total_price, 0));
  let averageOrderValue = $derived(orders.length > 0 ? Math.round(totalSum / orders.length) : 0);

  async function fetchOrders() {
    isLoading = true;
    errorMessage = '';
    try {
      const payload = $state.snapshot(filters);
      const data = await orderApi.getOrders(payload);
      orders = data;
    } catch (err: any) {
      console.error(err);
      errorMessage = err.message || 'Не удалось загрузить реестр заказов';
    } finally {
      isLoading = false;
    }
  }

  const debouncedFetch = debounce(() => {
    fetchOrders();
  }, 450);

  $effect(() => {
    untrack(() => {
      debouncedFetch();
    });
  });

  function openOrderDetails(order: OrderRead) {
    selectedOrder = order;
    isDetailsOpen = true;
  }

  function closeDetails() {
    isDetailsOpen = false;
    selectedOrder = null;
  }

  function resetFilters() {
    filters.min_price = null;
    filters.max_price = null;
    filters.status = null;
    filters.offset = 0;
  }

  onMount(() => {
    fetchOrders();
    return () => debouncedFetch.cancel();
  });
</script>

<div>
  <!-- Заголовок и фильтры (без изменений) -->
  <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
    <div>
      <h2 class="text-xl font-black text-gray-900 tracking-tight">Мониторинг продаж и заказов</h2>
      <p class="text-xs text-gray-400 mt-0.5">Управление и аналитика заказов интернет-магазина</p>
    </div>
    <button 
      onclick={resetFilters} 
      class="text-xs font-bold text-indigo-600 hover:text-indigo-700 bg-indigo-50 px-3 py-1.5 rounded-xl transition cursor-pointer"
    >
      Сбросить фильтры
    </button>
  </div>

  <!-- Блок фильтрации -->
  <div class="grid grid-cols-1 sm:grid-cols-4 gap-3 bg-gray-50 p-4 rounded-2xl border border-gray-100 mb-6 text-xs">
    <div class="space-y-1">
      <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Статус заказа</label>
      <select 
        bind:value={filters.status} 
        class="w-full bg-white border border-gray-200 rounded-xl px-3 py-1.5 text-xs text-gray-900 focus:outline-none focus:border-indigo-500 cursor-pointer font-semibold"
      >
        <option value={null}>Все статусы</option>
        <option value={Status.PENDING}>⏳ Ожидает оплаты</option>
        <option value={Status.PAID}>✅ Оплачен</option>
        <option value={Status.SHIPPED}>📦 Отправлен</option>
        <option value={Status.COMPLETED}>🎉 Выполнен</option>
        <option value={Status.CANCELED}>❌ Отменён</option>
      </select>
    </div>
    <div class="space-y-1">
      <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Цена от, ₽</label>
      <input 
        type="number" 
        placeholder="Мин. стоимость" 
        bind:value={filters.min_price} 
        class="w-full bg-white border border-gray-200 rounded-xl px-3 py-1.5 text-xs text-gray-900 focus:outline-none focus:border-indigo-500 font-medium"
      />
    </div>
    <div class="space-y-1">
      <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Цена до, ₽</label>
      <input 
        type="number" 
        placeholder="Макс. стоимость" 
        bind:value={filters.max_price} 
        class="w-full bg-white border border-gray-200 rounded-xl px-3 py-1.5 text-xs text-gray-900 focus:outline-none focus:border-indigo-500 font-medium"
      />
    </div>
    <div class="flex items-end">
      <button 
        onclick={fetchOrders}
        class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-1.5 rounded-xl text-xs transition cursor-pointer"
      >
        Применить фильтры
      </button>
    </div>
  </div>

  <!-- KPI карточки -->
  <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
    <div class="p-4 bg-indigo-50/40 border border-indigo-100 rounded-2xl">
      <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider block">Общая выручка</span>
      <p class="text-2xl font-black text-indigo-600 mt-1">{totalSum.toLocaleString()} ₽</p>
    </div>
    <div class="p-4 bg-emerald-50/40 border border-emerald-100 rounded-2xl">
      <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider block">Количество заказов</span>
      <p class="text-2xl font-black text-emerald-600 mt-1">{orders.length}</p>
    </div>
    <div class="p-4 bg-amber-50/40 border border-amber-100 rounded-2xl">
      <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider block">Средний чек</span>
      <p class="text-2xl font-black text-amber-600 mt-1">{averageOrderValue.toLocaleString()} ₽</p>
    </div>
  </div>

  <!-- Список заказов -->
  {#if isLoading}
    <div class="space-y-3">
      {#each [1, 2, 3] as _}
        <div class="bg-white border border-gray-200 rounded-xl p-4 animate-pulse">
          <div class="flex justify-between items-center">
            <div class="space-y-2">
              <div class="h-5 bg-gray-200 rounded w-32"></div>
              <div class="h-4 bg-gray-200 rounded w-48"></div>
            </div>
            <div class="flex gap-3">
              <div class="h-6 bg-gray-200 rounded w-20"></div>
              <div class="h-6 bg-gray-200 rounded w-24"></div>
            </div>
          </div>
        </div>
      {/each}
    </div>
  {:else if errorMessage}
    <div class="bg-red-50 border border-red-200 text-red-600 p-4 rounded-xl text-center font-medium">
      {errorMessage}
    </div>
  {:else if orders.length === 0}
    <div class="text-center py-12 bg-white rounded-xl border border-gray-200">
      <div class="text-5xl mb-3">📦</div>
      <p class="text-gray-400 font-medium">Заказов по заданным критериям не найдено</p>
      <button 
        onclick={resetFilters}
        class="mt-4 text-indigo-600 text-sm font-bold hover:text-indigo-700"
      >
        Сбросить фильтры
      </button>
    </div>
  {:else}
    <div class="space-y-3">
      {#each orders as order}
        <OrderCard 
          order={order}
          onViewDetails={openOrderDetails}
        />
      {/each}
    </div>
  {/if}

  <!-- Модалка деталей заказа -->
  <OrderDetailsModal 
    isOpen={isDetailsOpen}
    order={selectedOrder}
    onClose={closeDetails}
  />
</div>