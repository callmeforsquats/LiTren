<script lang="ts">
  import { cartState } from '../states/cart.svelte';
  import { userState } from '../states/user.svelte';
  import { usersApi } from '../api/users';
  import { OrderCreate } from '../types/users';
  import { uiState } from '../states/ui.svelte';

  let { onNavigate } = $props<{ 
    onNavigate: (view: 'catalog' | 'profile' | 'book-details', params?: any) => void 
  }>();

  let isSubmitting = $state(false);
  let orderError = $state('');
  let orderSuccess = $state(false);

  // Глобальный реактивный массив для хранения ID только тех книг, у которых нажат чекбокс
  let selectedBookId = $state<number[]>([]);

  // Автоматически отмечаем все товары при первой загрузке корзины
  // $effect(() => {
  //   if (cartState.items.length > 0 && selectedBookId.length === 0 && !orderSuccess) {
  //     selectedBookId = cartState.items.map(item => item.book_id);
  //   }
  // });

  // ВЫЧИСЛЯЕМЫЕ СВОЙСТВА ДЛЯ ВЫБРАННЫХ ТОВАРОВ (Руна $derived)
  let selectedItems = $derived(cartState.items.filter(item => selectedBookId.includes(item.book_id)));
  let totalSelectedItemsCount = $derived(selectedItems.reduce((sum, item) => sum + item.quantity, 0));
  let totalSelectedPrice = $derived(selectedItems.reduce((sum, item) => sum + (item.price * item.quantity), 0));
  
  // Флаг чекбокса "Выбрать все"
  let isAllSelected = $derived(cartState.items.length > 0 && selectedBookId.length === cartState.items.length);

  // Переключатель "Выбрать все / Снять выделение"
  function toggleSelectAll() {
    if (isAllSelected) {
      selectedBookId = []; // Снимаем все галочки
    } else {
      selectedBookId = cartState.items.map(item => item.book_id); // Отмечаем все
    }
  }

  // Переключение индивидуального чекбокса книги
  function toggleSelectItem(bookId: number) {
    if (selectedBookId.includes(bookId)) {
      selectedBookId = selectedBookId.filter(id => id !== bookId);
    } else {
      selectedBookId.push(bookId);
    }
  }

  async function handleQuantityChange(bookId: number, currentQty: number, delta: number) {
    const newQty = currentQty + delta;
    if (newQty <= 0) {
      // При удалении товара убираем его ID и из списка выбранных
      selectedBookId = selectedBookId.filter(id => id !== bookId);
      await cartState.removeItem(bookId);
    } else {
      await cartState.upsertItem({book_id:bookId, quantity:newQty});
    }
  }

// Внутри функции checkout() в Cart.svelte вместо отправки shopApi.createOrder:
function proceedToOrder() {
    if (!userState.current) {
      // Открываем модалку авторизации с callback
      uiState.openModal('auth', {
        onSuccess: () => {
          // После успешной авторизации переходим к оформлению
          goToOrder();
        }
      });
    } else {
      goToOrder();
    }
  }
  function goToOrder() {
    onNavigate('order', { selectedBookId: selectedBookId });
  }

</script>

<div class="max-w-7xl mx-auto px-4 py-6 bg-slate-50 min-h-screen text-gray-800">
  <h1 class="text-2xl font-black text-gray-900 mb-6 tracking-tight">Корзина</h1>

  {#if orderSuccess}
    <div class="bg-white border border-gray-200 rounded-2xl p-8 text-center shadow-xs max-w-sm mx-auto space-y-4">
      <div class="text-4xl">🎉</div>
      <h2 class="text-xl font-bold text-gray-900">Заказ оформлен!</h2>
      <p class="text-xs text-gray-500">Вы можете отслеживать статус заказа в личном кабинете.</p>
      <div class="flex flex-col gap-2 pt-2">
        <button onclick={() => onNavigate('profile')} class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2 rounded-xl text-sm transition cursor-pointer">
          В личный cabinet
        </button>
        <button onclick={() => { orderSuccess = false; onNavigate('catalog'); }} class="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold py-2 rounded-xl text-sm transition cursor-pointer">
          Продолжить покупки
        </button>
      </div>
    </div>

  {:else if cartState.isLoading}
    <div class="flex justify-center items-center py-24">
      <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600"></div>
    </div>

  {:else if cartState.items.length === 0}
    <div class="text-center py-16 bg-white rounded-2xl border border-gray-200 shadow-xs max-w-md mx-auto space-y-4">
      <div class="text-5xl select-none">🛒</div>
      <h2 class="text-lg font-bold text-gray-900">Корзина пуста</h2>
      <button onclick={() => onNavigate('catalog')} class="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-bold px-5 py-2.5 rounded-xl shadow-xs transition cursor-pointer">
        Перейти в каталог
      </button>
    </div>

  {:else}
    <!-- Чекбокс управления всеми товарами (Майшоп/Литрес стайл) -->
    <div class="bg-white p-3 mb-4 rounded-xl border border-gray-200 shadow-3xs flex items-center max-w-2xl">
      <label class="flex items-center gap-3 text-xs font-bold uppercase tracking-wider text-gray-500 cursor-pointer select-none">
        <input 
          type="checkbox" 
          checked={isAllSelected} 
          onchange={toggleSelectAll}
          class="rounded text-indigo-600 h-4 w-4 border-gray-300 accent-indigo-600 cursor-pointer" 
        />
        <span>Выбрать все предметы ({cartState.items.length})</span>
      </label>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
      
      <!-- ЛЕВАЯ ЧАСТЬ: Компактный список книг с индивидуальными чекбоксами -->
      <div class="lg:col-span-2 space-y-3 max-w-2xl w-full">
        {#each cartState.items as item}
          {@const imageState = { error: false }}
          {@const isChecked = selectedBookId.includes(item.book_id)}
          
          <div class="bg-white p-3 rounded-2xl border border-gray-200 shadow-3xs flex gap-3 relative group h-36 items-center">
            
            <!-- Индивидуальный чекбокс выбора товара -->
            <div class="pl-1">
              <input 
                type="checkbox" 
                checked={isChecked}
                onchange={() => toggleSelectItem(item.book_id)}
                class="rounded text-indigo-600 h-4 w-4 border-gray-300 accent-indigo-600 cursor-pointer"
              />
            </div>

            <!-- Картинка 3:4 -->
            <button 
              onclick={() => onNavigate('book-details', { bookId: item.book_id })}
              class="w-20 h-full bg-gray-50 rounded-xl overflow-hidden border border-gray-100 shadow-inner shrink-0 cursor-pointer focus:outline-none block relative"
            >
              {#if item.picture_url && !imageState.error}
                <img src={item.picture_url} alt={item.title} onerror={(e) => { imageState.error = true; (e.target as HTMLElement).style.display = 'none'; }} class="w-full h-full object-cover" />
              {/if}
              {#if !item.picture_url || imageState.error}
                <div class="absolute inset-0 bg-linear-to-br from-indigo-50 to-slate-200 p-2 flex flex-col justify-between items-center text-center border border-gray-200/50">
                  <div class="text-[8px] font-bold text-indigo-400 uppercase select-none tracking-tight">ЛиТрен</div>
                  <div class="text-base select-none">📚</div>
                  <div class="text-[9px] font-bold text-gray-400 select-none leading-none mb-1">Заставка</div>
                </div>
              {/if}
            </button>

            <!-- Контентная зона книги -->
            <div class="flex flex-col justify-between max-w-md py-0.5 grow h-full">
              <div class="space-y-1">
                <button 
                  onclick={() => onNavigate('book-details', { bookId: item.book_id })}
                  class="font-extrabold text-sm sm:text-base text-gray-900 hover:text-indigo-600 transition text-left focus:outline-none cursor-pointer line-clamp-2 leading-tight pr-6"
                >
                  {item.title}
                </button>
                <span class="text-[10px] text-gray-400 font-semibold uppercase tracking-wider block">ID: {item.book_id}</span>
              </div>

              <div class="flex items-center gap-6">
                <!-- Степпер +/- -->
                <div class="flex items-center bg-gray-100 rounded-lg p-0.5 border border-gray-200/30 select-none">
                  <button onclick={() => handleQuantityChange(item.book_id, item.quantity, -1)} class="w-6 h-6 flex items-center justify-center font-bold text-gray-400 hover:text-gray-800 transition active:scale-90 cursor-pointer">−</button>
                  <span class="w-8 text-center text-xs font-black text-gray-900">{item.quantity}</span>
                  <button onclick={() => handleQuantityChange(item.book_id, item.quantity, 1)} class="w-6 h-6 flex items-center justify-center font-bold text-gray-400 hover:text-gray-800 transition active:scale-90 cursor-pointer">+</button>
                </div>

                <!-- Блок цены -->
                <div class="flex items-baseline gap-2">
                  <span class="font-black text-lg text-indigo-600">{(item.price * item.quantity)} ₽</span>
                  {#if item.quantity > 1}
                    <span class="text-xs text-gray-400 font-medium">({item.price} ₽/шт.)</span>
                  {/if}
                </div>
              </div>
            </div>

            <!-- Кнопка удаления -->
            <button onclick={() => cartState.removeItem(item.book_id)} class="absolute top-3 right-3 text-gray-300 hover:text-red-500 transition text-xs font-bold focus:outline-none p-1 cursor-pointer" title="Удалить товар">✕</button>

          </div>
        {/each}
      </div>

      <!-- ПРАВАЯ ЧАСТЬ: Динамический расчет стоимости НА БАЗЕ СВОЙСТВА selectedItems -->
      <div class="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs space-y-4 sticky top-24 w-full">
        <h2 class="text-base font-black text-gray-900 border-b border-gray-100 pb-2">Детали заказа</h2>
        
        <div class="space-y-1.5 text-xs font-medium text-gray-500">
          <div class="flex justify-between">
            <!-- Динамически выводим количество только отмеченных книг -->
            <span>Выбрано книг ({totalSelectedItemsCount}):</span>
            <span class="text-gray-900 font-bold">{totalSelectedPrice} ₽</span>
          </div>
          <div class="flex justify-between">
            <span>Доставка:</span>
            <span class="text-emerald-600 font-bold">Бесплатно</span>
          </div>
        </div>

        <div class="flex justify-between items-end pt-3 border-t border-gray-100">
          <span class="text-xs font-bold text-gray-900">Итого к оплате:</span>
          <!-- Сумма пересчитывается мгновенно при снятии/установке любой галочки -->
          <span class="text-xl font-black text-indigo-600 leading-none">{totalSelectedPrice} ₽</span>
        </div>

        {#if orderError}
          <div class="bg-red-50 border border-red-200 text-red-600 p-2.5 rounded-xl text-xs font-semibold text-center">
            {orderError}
          </div>
        {/if}

        <button 
          onclick={proceedToOrder}
          disabled={isSubmitting || selectedBookId.length === 0}
          class="w-full bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-300 text-white font-black py-3 rounded-xl transition text-center shadow-xs active:scale-98 cursor-pointer text-xs"
        >
          {#if isSubmitting}
            Оформление...
          {:else if selectedBookId.length === 0}
            Выберите товары
          {:else if !userState.current}
            Войти и оформить ({selectedBookId.length})
          {:else}
            Оформить заказ ({selectedBookId.length})
          {/if}
        </button>
      </div>

    </div>
  {/if}
</div>
