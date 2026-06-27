<script lang="ts">
  import { onMount, untrack } from 'svelte';
  import { cartState } from '../states/cart.svelte';
  import { usersApi } from '../api/users';
  import { AddressCreate, OrderCreate, TownCreate, StreetCreate } from '../types/users';
  import type { ItemRead, AddressRead } from '../types/users';
  import { orderApi } from '../api/orders';

  // Строго описываем типы страниц для навигации в соответствии с App.svelte
  type View = 'home' | 'catalog' | 'book-details' | 'cart' | 'order' | 'profile' | 'admin';

  let { onNavigate, selectedBookId = [] } = $props<{
    onNavigate: (view: View, params?: any) => void;
    selectedBookId: number[];
  }>();

  // Списки элементов
  let checkoutItems = $state<ItemRead[]>([]);
  let userAddresses = $state<AddressRead[]>([]);
  let isLoading = $state(true);

  // Состояние выбора адреса
  let selectedAddressFiasId = $state<string>('');
  
  // Состояние формы добавления нового адреса
  let isAddingNewAddress = $state(false);
  let dadataQuery = $state('');
  let dadataSuggestions = $state<any[]>([]);
  
  // Функция-хелпер для создания чистой структуры формы
  const createEmptyAddressForm = (): AddressCreate => ({
    town: { name: '', fias_id: '' },
    street: { name: '', fias_id: '' },
    house: '',
    flat: null,
    fias_id: '',
    is_default: false
  });

  // Локальное реактивное состояние формы в виде чистого объекта
  let newAddressForm = $state<AddressCreate>(createEmptyAddressForm());
  let addressSuccessMessage = $state('');

  let isSubmittingOrder = $state(false);
  let orderError = $state('');
  let orderSuccess = $state(false);

  // Вычисляемые финансовые итоги через руну $derived
  let totalPrice = $derived(checkoutItems.reduce((sum, item) => sum + (item.price * item.quantity), 0));

  // 1. ЖИВОЙ ПОИСК ПОДСКАЗОК В DADATA (Исправлена типизация таймаута)
  let dadataTimeout: ReturnType<typeof setTimeout> | undefined;
  
  function handleAddressInput() {
    clearTimeout(dadataTimeout);
    dadataTimeout = setTimeout(async () => {
      // Изолируем чтение строки ввода, чтобы таймаут не перезапускался бесконтрольно
      const query = dadataQuery; 
      if (query.length >= 3) {
        try {
          dadataSuggestions = await usersApi.getAddressSuggestions(query);
        } catch (e) {
          console.error('Ошибка DaData:', e);
          dadataSuggestions = [];
        }
      } else {
        dadataSuggestions = [];
      }
    }, 400); // 400мс — оптимальный стандарт дебаунса для живого поиска
  }

  // 2. ВЫБОР ПОДСКАЗКИ
  function selectSuggestion(suggestion: any) {
    const data = suggestion.data;
    
    if (!data.city && !data.settlement) {
      alert('Пожалуйста, уточните город или населенный пункт');
      return;
    }
    if (!data.street) {
      alert('Пожалуйста, укажите улицу в поиске');
      return;
    }

    newAddressForm.town = {
      name: data.city || data.settlement,
      fias_id: data.city_fias_id || data.settlement_fias_id || data.fias_id
    };

    newAddressForm.street = {
      name: data.street,
      fias_id: data.street_fias_id || data.fias_id
    };

    newAddressForm.house = data.house || '';
    newAddressForm.flat = data.flat || null;
    newAddressForm.fias_id = data.fias_id;

    dadataQuery = suggestion.value;
    dadataSuggestions = [];
  }

  // 3. СОХРАНЕНИЕ АДРЕСА НА БЭКЕНД
  async function saveNewAddress() {
    if (!newAddressForm.fias_id) {
      alert('Выберите адрес из выпадающего списка подсказок DaData!');
      return;
    }
    if (!newAddressForm.house) {
      alert('Укажите номер дома!');
      return;
    }

    try {
      // Передаем снимок состояния во избежание сайд-эффектов проксирования Svelte 5
      await usersApi.addAddress($state.snapshot(newAddressForm));
      addressSuccessMessage = 'Адрес успешно сохранен!';
      isAddingNewAddress = false;
      dadataQuery = '';
      
      userAddresses = await usersApi.getAddresses();
      selectedAddressFiasId = newAddressForm.fias_id;
      
      // Сбрасываем форму к чистому литералу объекта
      newAddressForm = createEmptyAddressForm();
    } catch (e: any) {
      alert(e.message || 'Не удалось сохранить адрес');
    }
  }

  // 4. ФИНАЛЬНАЯ ОТПРАВКА ЗАКАЗА
  async function submitOrder() {
    if (!selectedAddressFiasId) {
      orderError = 'Пожалуйста, выберите или добавьте адрес доставки';
      return;
    }

    isSubmittingOrder = true;
    orderError = '';

    try {
      const orderPayload = new OrderCreate({
        items: selectedBookId,
        address_id: selectedAddressFiasId
      });

      await orderApi.createOrder(orderPayload);
      
      // Удаляем купленные книги из глобального реактивного состояния корзины
      cartState.items = cartState.items.filter(item => !selectedBookId.includes(item.book_id));
      orderSuccess = true;
    } catch (err: any) {
      orderError = err.message || 'Ошибка при оформлении заказа';
    } finally {
      isSubmittingOrder = false;
    }
  }

  onMount(async () => {
    isLoading = true;
    try {
      checkoutItems = cartState.items.filter(item => selectedBookId.includes(item.book_id));
      
      userAddresses = await usersApi.getAddresses();
      if (userAddresses.length > 0) {
        selectedAddressFiasId = userAddresses[0].fias_id;
      }
    } catch (e) {
      console.error(e);
    } finally {
      isLoading = false;
    }
  });
</script>


<div class="max-w-7xl mx-auto px-4 py-6 bg-slate-50 min-h-screen text-gray-800">
  <button onclick={() => onNavigate('cart')} class="text-sm font-semibold text-indigo-600 hover:text-indigo-700 mb-6 flex items-center gap-1 cursor-pointer focus:outline-none">
    ← Вернуться в корзину
  </button>

  <h1 class="text-2xl font-black text-gray-900 mb-6 tracking-tight">Оформление заказа</h1>

  {#if orderSuccess}
    <div class="bg-white border border-gray-200 rounded-2xl p-8 text-center shadow-xs max-w-sm mx-auto space-y-4">
      <div class="text-4xl">🎉</div>
      <h2 class="text-xl font-bold text-gray-900">Заказ успешно создан!</h2>
      <p class="text-xs text-gray-500">Бэкенд FastAPI принял ваш заказ. Ожидайте доставку книжных новинок.</p>
      <button onclick={() => onNavigate('profile')} class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2 rounded-xl text-sm cursor-pointer">
        Перейти в личный кабинет
      </button>
    </div>
  {:else if isLoading}
    <div class="flex justify-center items-center py-24"><div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div></div>
  {:else}
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
      
      <!-- ЛЕВАЯ СЕКЦИЯ (2 колонки): Адреса и Товары -->
      <div class="lg:col-span-2 space-y-4">
        
        <!-- БЛОК АДРЕСОВ ДОСТАВКИ -->
        <div class="bg-white p-5 rounded-2xl border border-gray-200 shadow-3xs space-y-4">
          <h2 class="text-base font-black text-gray-900 border-b border-gray-100 pb-2">1. Адрес доставки</h2>
          
          {#if addressSuccessMessage}
            <div class="bg-emerald-50 border border-emerald-100 text-emerald-600 p-2 rounded-xl text-xs font-bold text-center">{addressSuccessMessage}</div>
          {/if}

          <!-- Список существующих адресов -->
          {#if userAddresses.length > 0}
            <div class="space-y-2">
              {#each userAddresses as addr}
                <label class="flex items-start gap-3 p-3 rounded-xl border border-gray-100 bg-gray-50/40 hover:bg-gray-50 cursor-pointer transition select-none">
                  <input type="radio" name="address" value={addr.fias_id} bind:group={selectedAddressFiasId} class="mt-0.5 text-indigo-600 h-4 w-4 border-gray-300 accent-indigo-600" />
                  <span class="text-sm font-semibold text-gray-700 leading-tight">{addr.full_address}</span>
                </label>
              {/each}
            </div>
          {/if}

          <!-- Кнопка раскрытия формы DaData -->
          <div class="pt-1">
            <button 
              onclick={() => { isAddingNewAddress = !isAddingNewAddress; addressSuccessMessage = ''; }}
              class="text-xs font-bold text-indigo-600 hover:text-indigo-800 flex items-center gap-1 cursor-pointer"
            >
              {isAddingNewAddress ? '✕ Отменить добавление' : '➕ Добавить новый адрес через DaData'}
            </button>
          </div>

          <!-- ИНТЕГРАЦИЯ ФОРМЫ DADATA -->
          {#if isAddingNewAddress}
            <div class="bg-gray-50/70 p-4 rounded-xl border border-gray-200/60 space-y-4 relative animate-fade-in">
              <div class="space-y-1 relative">
                <label for="dadata-search" class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Начните вводить адрес (Город, улица, дом)</label>
                <input 
                  id="dadata-search"
                  type="text" 
                  bind:value={dadataQuery}
                  oninput={handleAddressInput}
                  placeholder="Пример: г Москва, ул Ленина, д 10" 
                  class="w-full bg-white border border-gray-200 rounded-xl px-3 py-2 text-sm text-gray-900 focus:outline-none focus:border-indigo-500 transition-all shadow-2xs"
                />

                <!-- ВЫПАДАЮЩИЙ СПИСОК ПОДСКАЗОК DADATA -->
                {#if dadataSuggestions.length > 0}
                  <div class="absolute left-0 right-0 bg-white border border-gray-200 mt-1 rounded-xl shadow-lg z-50 overflow-hidden divide-y divide-gray-100">
                    {#each dadataSuggestions as suggestion}
                      <button 
                        type="button"
                        onclick={() => selectSuggestion(suggestion)}
                        class="w-full text-left px-4 py-2.5 text-xs text-gray-700 hover:bg-indigo-50 font-medium transition cursor-pointer"
                      >
                        {suggestion.value}
                      </button>
                    {/each}
                  </div>
                {/if}
              </div>

              <!-- Поля ручного уточнения квартиры (если дом уже выбран через DaData) -->
              <div class="grid grid-cols-2 gap-3">
                <div class="space-y-1">
                  <label for="house" class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Дом</label>
                  <input id="house" type="text" readonly bind:value={newAddressForm.house} class="w-full bg-gray-100 border border-gray-200 rounded-xl px-3 py-1.5 text-xs text-gray-500 font-bold" />
                </div>
                <div class="space-y-1">
                  <label for="flat" class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Квартира/Офис</label>
                  <input id="flat" type="text" bind:value={newAddressForm.flat} placeholder="Кв. 45" class="w-full bg-white border border-gray-200 rounded-xl px-3 py-1.5 text-xs text-gray-900 focus:outline-none focus:border-indigo-500" />
                </div>
              </div>

              <button onclick={saveNewAddress} type="button" class="bg-indigo-600 hover:bg-indigo-700 text-white font-bold px-4 py-1.5 rounded-xl text-xs shadow-xs cursor-pointer">
                Подтвердить и сохранить адрес
              </button>
            </div>
          {/if}
        </div>

        <!-- КРАТКИЙ СПИСОК ТОВАРОВ ДЛЯ ПРОВЕРКИ -->
        <div class="bg-white p-5 rounded-2xl border border-gray-200 shadow-3xs space-y-3">
          <h2 class="text-base font-black text-gray-900 border-b border-gray-100 pb-2">2. Состав заказа</h2>
          <div class="divide-y divide-gray-50">
            {#each checkoutItems as item}
              <div class="py-2.5 flex items-center justify-between gap-4 text-xs font-semibold">
                <div class="flex items-center gap-3">
                  <span class="text-gray-400 select-none">📚</span>
                  <span class="text-gray-900 font-bold line-clamp-1 max-w-sm">{item.title}</span>
                  <span class="text-gray-400 font-medium">× {item.quantity} шт.</span>
                </div>
                <span class="text-gray-900 font-black shrink-0">{(item.price * item.quantity)} ₽</span>
              </div>
            {/each}
          </div>
        </div>

      </div>

      <!-- ПРАВАЯ СЕКЦИЯ: Итог чека и кнопка создания заказа -->
      <div class="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs space-y-4 sticky top-24">
        <h2 class="text-base font-black text-gray-900 border-b border-gray-100 pb-2">Итоговый чек</h2>
        
        <div class="space-y-1.5 text-xs font-medium text-gray-500">
          <div class="flex justify-between">
            <span>Выбранные позиции:</span>
            <span class="text-gray-900 font-bold">{totalPrice} ₽</span>
          </div>
          <div class="flex justify-between">
            <span>Способ получения:</span>
            <span class="text-indigo-600 font-bold">Курьерская доставка</span>
          </div>
        </div>

        <div class="flex justify-between items-end pt-3 border-t border-gray-100">
          <span class="text-xs font-bold text-gray-900">Сумма к оплате:</span>
          <span class="text-xl font-black text-indigo-600 leading-none">{totalPrice} ₽</span>
        </div>

        {#if orderError}
          <div class="bg-red-50 border border-red-200 text-red-600 p-2.5 rounded-xl text-xs font-semibold text-center">{orderError}</div>
        {/if}

        <button 
          onclick={submitOrder}
          disabled={isSubmittingOrder || !selectedAddressFiasId}
          class="w-full bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-300 text-white font-black py-3 rounded-xl transition text-center shadow-xs text-xs cursor-pointer active:scale-98"
        >
          {isSubmittingOrder ? 'Создание заказа...' : 'Подтвердить и заказать книгу'}
        </button>
      </div>

    </div>
  {/if}
</div>
