<!-- src/components/OrderDetailsModal.svelte -->
<script lang="ts">
  import type { OrderRead, OrderInfo, ItemRead } from '../types/users';
  import { Status } from '../types/users';
  import { orderApi } from '../api/orders';
  import { uiState } from '../states/ui.svelte';

  let { isOpen, order, onClose } = $props<{
    isOpen: boolean;
    order: OrderRead | null;
    onClose: () => void;
  }>();

  let fullOrder = $state<OrderInfo | null>(null);
  let isLoading = $state(false);
  let error = $state('');

  async function loadOrderDetails() {
    if (!order) return;
    if (fullOrder) return;
    
    isLoading = true;
    error = '';
    
    try {
      const details = await orderApi.getOrder(order.id);
      fullOrder = details;
    } catch (err: any) {
      error = err.message || 'Не удалось загрузить детали заказа';
      uiState.error(error);
    } finally {
      isLoading = false;
    }
  }

  // Загружаем детали при открытии модалки
  $effect(() => {
    if (isOpen && order && !fullOrder && !isLoading) {
      loadOrderDetails();
    }
  });

  // Сбрасываем состояние при закрытии
  function handleClose() {
    fullOrder = null;
    error = '';
    onClose();
  }

  function handleBackdropClick(e: MouseEvent) {
    if (e.target === e.currentTarget) {
      handleClose();
    }
  }

  function getStatusLabel(status: Status): string {
    switch (status) {
      case Status.PENDING: return '⏳ Ожидает';
      case Status.PAID: return '✅ Оплачен';
      case Status.SHIPPED: return '📦 Доставляется';
      case Status.COMPLETED: return '🎉 Выполнен';
      case Status.CANCELED: return '❌ Отменён';
      default: return '❓ Неизвестно';
    }
  }

  function getStatusStyle(status: Status): string {
    switch (status) {
      case Status.PAID:
      case Status.COMPLETED:
        return 'bg-emerald-100 text-emerald-700 border-emerald-200';
      case Status.PENDING:
        return 'bg-amber-100 text-amber-700 border-amber-200';
      case Status.SHIPPED:
        return 'bg-indigo-100 text-indigo-700 border-indigo-200';
      case Status.CANCELED:
        return 'bg-red-100 text-red-700 border-red-200';
      default:
        return 'bg-gray-100 text-gray-700 border-gray-200';
    }
  }

  function formatDateTime(dateString: string): string {
    return new Date(dateString).toLocaleString('ru-RU');
  }

  function getItemsCountText(count: number): string {
    if (count === 0) return 'нет товаров';
    if (count === 1) return '1 товар';
    if (count >= 2 && count <= 4) return `${count} товара`;
    return `${count} товаров`;
  }
</script>

{#if isOpen && order}
  <div 
    class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
  >
    <div class="bg-white rounded-2xl shadow-xl max-w-2xl w-full flex flex-col max-h-[90vh] animate-scale-in">
      
      <!-- Фиксированная шапка -->
      <div class="sticky top-0 bg-white border-b border-gray-100 p-4 flex justify-between items-center z-10 rounded-t-2xl shrink-0">
        <div>
          <h2 class="text-lg font-black text-gray-900">Заказ #{order.id}</h2>
          <p class="text-[10px] text-gray-400 mt-0.5">
            от {formatDateTime(order.created_at)}
          </p>
        </div>
        <button 
          onclick={handleClose}
          class="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition cursor-pointer"
        >
          ✕
        </button>
      </div>

      <!-- Скроллируемая область с содержимым -->
      <div class="flex-1 overflow-y-auto p-5 space-y-5">
        {#if isLoading}
          <!-- Скелетон загрузки -->
          <div class="space-y-4">
            <div class="h-20 bg-gray-100 rounded-xl animate-pulse"></div>
            <div class="space-y-2">
              {#each [1, 2] as _}
                <div class="flex items-center gap-3 p-3 bg-gray-50 rounded-xl animate-pulse">
                  <div class="w-12 h-16 bg-gray-200 rounded-lg"></div>
                  <div class="flex-1 space-y-2">
                    <div class="h-4 bg-gray-200 rounded w-3/4"></div>
                    <div class="h-3 bg-gray-200 rounded w-1/2"></div>
                  </div>
                  <div class="w-20 h-5 bg-gray-200 rounded"></div>
                </div>
              {/each}
            </div>
          </div>
          
        {:else if error}
          <div class="text-center py-8">
            <div class="text-red-500 text-4xl mb-3">⚠️</div>
            <p class="text-red-500 text-sm mb-4">{error}</p>
            <button 
              onclick={loadOrderDetails}
              class="bg-indigo-600 hover:bg-indigo-700 text-white font-bold px-4 py-2 rounded-xl text-sm transition"
            >
              Попробовать снова
            </button>
          </div>
          
        {:else if fullOrder}
          <!-- Адрес доставки -->
          <div class="p-4 bg-indigo-50/20 rounded-xl border border-indigo-100">
            <div class="flex items-start gap-2">
              <span class="text-lg">📍</span>
              <div>
                <p class="text-[10px] font-black uppercase tracking-wider text-indigo-500">Адрес доставки</p>
                <p class="text-sm font-semibold text-gray-800 mt-0.5">{fullOrder.full_address}</p>
              </div>
            </div>
          </div>

          <!-- Статус -->
          <div class="flex justify-between items-center p-3 bg-gray-50 rounded-xl">
            <span class="text-sm font-semibold text-gray-600">Статус заказа</span>
            <span class="text-[11px] font-black uppercase px-3 py-1.5 rounded-full border {getStatusStyle(fullOrder.status)}">
              {getStatusLabel(fullOrder.status)}
            </span>
          </div>

          <!-- Список товаров -->
          <div>
            <p class="text-[10px] font-black uppercase tracking-wider text-gray-400 mb-3 sticky top-0 bg-white py-2">
              Состав заказа ({getItemsCountText(fullOrder.items?.length || 0)})
            </p>
            <div class="space-y-2">
              {#each fullOrder.items || [] as item}
                <div class="flex items-center gap-3 p-3 bg-gray-50 rounded-xl border border-gray-100 hover:bg-gray-100 transition">
                  {#if item.picture_url}
                    <img 
                      src={item.picture_url} 
                      alt={item.title} 
                      class="w-12 h-16 object-cover rounded-lg bg-gray-100 shrink-0"
                      loading="lazy"
                    />
                  {:else}
                    <div class="w-12 h-16 bg-gray-200 rounded-lg shrink-0 flex items-center justify-center text-xl">
                      📚
                    </div>
                  {/if}
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-bold text-gray-900 truncate">{item.title}</p>
                    <p class="text-[11px] text-gray-500 font-medium mt-0.5">
                      {item.price.toLocaleString()} ₽ × {item.quantity} шт.
                    </p>
                  </div>
                  <div class="text-right">
                    <p class="text-sm font-black text-gray-900">
                      {(item.price * item.quantity).toLocaleString()} ₽
                    </p>
                  </div>
                </div>
              {:else}
                <p class="text-center text-gray-400 text-sm py-8">Нет данных о товарах</p>
              {/each}
            </div>
          </div>
        {/if}
      </div>

      <!-- Фиксированный футер с итоговой суммой -->
      {#if fullOrder && !isLoading && !error}
        <div class="sticky bottom-0 bg-white border-t border-gray-200 p-4 flex justify-between items-center shrink-0 rounded-b-2xl shadow-lg">
          <span class="text-base font-bold text-gray-600">Общая стоимость</span>
          <span class="text-2xl font-black text-indigo-600">{fullOrder.total_price.toLocaleString()} ₽</span>
        </div>
      {:else if !isLoading && !error}
        <div class="sticky bottom-0 bg-white border-t border-gray-200 p-4 flex justify-between items-center shrink-0 rounded-b-2xl">
          <span class="text-base font-bold text-gray-600">Общая стоимость</span>
          <span class="text-2xl font-black text-gray-400">— ₽</span>
        </div>
      {/if}

    </div>
  </div>
{/if}

<style>
  @keyframes scaleIn {
    from {
      transform: scale(0.95);
      opacity: 0;
    }
    to {
      transform: scale(1);
      opacity: 1;
    }
  }
  
  .animate-scale-in {
    animation: scaleIn 0.2s ease-out;
  }
</style>