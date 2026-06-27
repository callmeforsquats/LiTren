<!-- src/components/OrderCard.svelte -->
<script lang="ts">
  import type { OrderRead } from '../types/users';
  import { Status } from '../types/users';

  let { order, onViewDetails } = $props<{
    order: OrderRead;
    onViewDetails?: (order: OrderRead) => void;
  }>();

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

  function formatDate(dateString: string): string {
    return new Date(dateString).toLocaleDateString('ru-RU');
  }
</script>

<div class="bg-white border border-gray-200 rounded-xl hover:shadow-md transition-all">
  <div class="p-4">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <div class="space-y-1">
        <div class="flex items-center gap-2">
          <span class="text-sm font-black text-gray-900">Заказ #{order.id}</span>
          <span class="text-[10px] text-gray-400 font-medium">
            от {formatDate(order.created_at)}
          </span>
        </div>
        <div class="text-xs text-gray-500 flex items-center gap-2 flex-wrap">
          <span class="truncate max-w-xs">📍 {order.full_address}</span>
        </div>
      </div>
      <div class="flex items-center gap-3 flex-wrap">
        <span class="font-black text-base text-gray-900">{order.total_price.toLocaleString()} ₽</span>
        <span class="text-[10px] font-black uppercase px-2.5 py-1 rounded-full border {getStatusStyle(order.status)}">
          {getStatusLabel(order.status)}
        </span>
        <button 
          onclick={(e) => { e.stopPropagation(); onViewDetails?.(order); }}
          class="text-indigo-600 hover:text-indigo-700 text-xs font-bold transition whitespace-nowrap cursor-pointer"
        >
          Подробнее →
        </button>
      </div>
    </div>
  </div>
</div>