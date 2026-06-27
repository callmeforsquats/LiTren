<!-- src/pages/Profile.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { userState } from '../states/user.svelte';
  import { uiState } from '../states/ui.svelte';
  import { usersApi } from '../api/users';
  import { orderApi } from '../api/orders';
  import { OrderFilter, ReviewFilter } from '../types/users';
  import type { OrderRead, AddressRead, ReviewRead } from '../types/users';
  import { Status } from '../types/users';
  import { catalogApi } from '../api/catalog';

  // Состояние переключения вкладок
  let activeTab = $state<'orders' | 'addresses' | 'reviews'>('reviews');
  
  // Списки данных
  let orders = $state<OrderRead[]>([]);
  let addresses = $state<AddressRead[]>([]);
  let userReviews = $state<ReviewRead[]>([]);
  
  // Состояния для отзывов
  let loadingReviewId = $state<number | null>(null);
  let expandedReviews = $state<Set<number>>(new Set());

  let isDataLoading = $state(false);
  
  // Аватар
  let avatarPreview = $state<string | null>(null);
  let avatarFile = $state<File | null>(null);
  let isUploadingAvatar = $state(false);

  function getStatusStyle(status: Status) {
    switch (status) {
      case Status.COMPLETED: return 'bg-emerald-50 text-emerald-700 border-emerald-200';
      case Status.SHIPPED: return 'bg-blue-50 text-blue-700 border-blue-200';
      case Status.PAID: return 'bg-indigo-50 text-indigo-700 border-indigo-200';
      case Status.PENDING: return 'bg-amber-50 text-amber-700 border-amber-200';
      case Status.CANCELED: return 'bg-red-50 text-red-700 border-red-200';
      default: return 'bg-gray-50 text-gray-700 border-gray-200';
    }
  }

  function getStatusLabel(status: Status): string {
    switch (status) {
      case Status.COMPLETED: return 'Выполнен';
      case Status.SHIPPED: return 'Доставляется';
      case Status.PAID: return 'Оплачен';
      case Status.PENDING: return 'В обработке';
      case Status.CANCELED: return 'Отменён';
      default: return 'Неизвестно';
    }
  }

  async function loadUserData() {
    if (!userState.current) return;
    
    isDataLoading = true;
    try {
      const [ordersData, addressesData, reviewsData] = await Promise.all([
        orderApi.getOrders(new OrderFilter({ user_id: userState.current.id })).catch(() => []),
        usersApi.getAddresses().catch(() => []),
        usersApi.getReviews(new ReviewFilter({ user_id: userState.current.id, limit: 100 })).catch(() => [])
      ]);
      orders = ordersData;
      addresses = addressesData;
      userReviews = reviewsData;
      
      // Устанавливаем превью аватара
      avatarPreview = userState.current.picture_url || null;
    } catch (e: any) {
      console.error('Ошибка загрузки данных профиля:', e);
      uiState.error('Не удалось загрузить данные профиля');
    } finally {
      isDataLoading = false;
    }
  }

  async function loadFullReview(review: ReviewRead) {
    if (review.text !== null && review.text !== undefined) return;
    if (loadingReviewId === review.id) return;
    
    loadingReviewId = review.id;
    
    try {
      const fullReview = (await catalogApi.getBookReviews(review.book_id,new ReviewFilter({user_id:userState.current?.id})))[0];
      const index = userReviews.findIndex(r => r.id === review.id);
      if (index !== -1) {
        userReviews[index] = { ...userReviews[index], text: fullReview.text };
        userReviews = [...userReviews];
      }
    } catch (err: any) {
      console.error(err);
      uiState.error('Не удалось загрузить текст отзыва');
    } finally {
      loadingReviewId = null;
    }
  }

  function toggleReviewExpand(reviewId: number) {
    if (expandedReviews.has(reviewId)) {
      expandedReviews.delete(reviewId);
    } else {
      expandedReviews.add(reviewId);
    }
    expandedReviews = new Set(expandedReviews);
  }

  // ========== АВАТАР ==========
  function handleAvatarSelect(e: Event) {
    const input = e.target as HTMLInputElement;
    if (!input.files?.length) return;
    
    const file = input.files[0];
    
    if (!file.type.startsWith('image/')) {
      uiState.warning('Пожалуйста, выберите изображение');
      return;
    }
    
    if (file.size > 5 * 1024 * 1024) {
      uiState.warning('Размер изображения не должен превышать 5MB');
      return;
    }
    
    avatarFile = file;
    
    const reader = new FileReader();
    reader.onload = (e) => {
      avatarPreview = e.target?.result as string;
    };
    reader.readAsDataURL(file);
  }

  async function uploadAvatar() {
    if (!avatarFile) return;
    
    isUploadingAvatar = true;
    try {
      const result = await usersApi.uploadAvatar(avatarFile);
      avatarPreview = result.picture_url;
      avatarFile = null;
      await userState.checkAuth();
      uiState.success('Аватар успешно обновлён');
    } catch (e: any) {
      uiState.error(e.message || 'Не удалось загрузить аватар');
    } finally {
      isUploadingAvatar = false;
    }
  }


  function openAuthModal() {
    uiState.openModal('auth', { 
      onSuccess: () => loadUserData() 
    });
  }

  async function handleLogout() {
    uiState.openModal('confirm', {
      title: 'Выход из аккаунта',
      message: 'Вы уверены, что хотите выйти?',
      confirmText: 'Да, выйти',
      cancelText: 'Отмена',
      onConfirm: async () => {
        try {
          await userState.logout();
          orders = [];
          addresses = [];
          userReviews = [];
          expandedReviews.clear();
          avatarPreview = null;
          avatarFile = null;
          uiState.success('Вы успешно вышли из аккаунта');
        } catch (e: any) {
          uiState.error('Ошибка при выходе');
        }
      }
    });
  }

  async function deleteAddress(fiasId: string, fullAddress: string) {
    uiState.openModal('confirm', {
      title: 'Удаление адреса',
      message: `Вы уверены, что хотите удалить адрес: "${fullAddress}"?`,
      confirmText: 'Да, удалить',
      cancelText: 'Отмена',
      onConfirm: async () => {
        try {
          await usersApi.deleteAddress(fiasId);
          await loadUserData();
          uiState.success('Адрес успешно удалён');
        } catch (e: any) {
          uiState.error(e.message || 'Не удалось удалить адрес');
          throw e;
        }
      }
    });
  }

  onMount(() => {
    if (userState.current) {
      loadUserData();
    }
  });
</script>

<div class="max-w-5xl mx-auto px-4 py-8 bg-slate-50 min-h-screen text-gray-800">
  
  {#if userState.isLoading}
    <div class="flex justify-center items-center py-32">
      <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600"></div>
    </div>
  
  {:else if !userState.current}
    <div class="max-w-md mx-auto text-center space-y-6">
      <div class="bg-white border border-gray-200 rounded-3xl p-8 shadow-xs">
        <div class="text-5xl mb-4">👤</div>
        <h2 class="text-xl font-black text-gray-900 mb-2">Вы не авторизованы</h2>
        <p class="text-sm text-gray-500 mb-6">Войдите или зарегистрируйтесь, чтобы увидеть свои заказы, адреса и отзывы</p>
        
        <button 
          onclick={openAuthModal}
          class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-black py-3 rounded-xl transition shadow-xs cursor-pointer"
        >
          Войти в аккаунт
        </button>
      </div>
    </div>

  {:else}
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 items-start">
      
      <!-- Боковое меню с аватаром -->
      <div class="bg-white border border-gray-200 rounded-2xl shadow-xs space-y-4 sticky top-24">
        
        <!-- Блок аватара -->
        <div class="p-4 border-b border-gray-100">
          <div class="flex flex-col items-center text-center">
            <div class="w-24 h-24 rounded-full bg-indigo-100 flex items-center justify-center overflow-hidden mb-3">
              {#if avatarPreview}
                <img src={avatarPreview} alt="Avatar" class="w-full h-full object-cover" />
              {:else}
                <span class="text-3xl font-bold text-indigo-600">
                  {userState.current.email.charAt(0).toUpperCase()}
                </span>
              {/if}
            </div>
            
            <div class="flex gap-2 flex-wrap justify-center">
              <label class="cursor-pointer">
                <span class="text-[10px] font-bold text-indigo-600 hover:text-indigo-700 bg-indigo-50 px-3 py-1 rounded-full">
                  📷 Изменить
                </span>
                <input 
                  type="file" 
                  accept="image/*" 
                  onchange={handleAvatarSelect} 
                  class="hidden" 
                />
              </label>
              
              {#if avatarFile}
                <button 
                  onclick={uploadAvatar}
                  disabled={isUploadingAvatar}
                  class="text-[10px] font-bold text-green-600 hover:text-green-700 disabled:opacity-50 bg-green-50 px-3 py-1 rounded-full"
                >
                  {isUploadingAvatar ? '⏳' : '💾 Сохранить'}
                </button>
              {/if}
            
            </div>
            
            <p class="text-[9px] text-gray-400 mt-2">
              JPEG, PNG, WEBP до 5MB
            </p>
          </div>
        </div>
        
        <div class="px-4 pb-3">
          <div class="text-[10px] text-gray-400 font-bold uppercase tracking-wider">Вы вошли как</div>
          <div class="font-black text-sm text-gray-900 truncate mt-0.5 flex items-center gap-2">
            <span class="w-6 h-6 rounded-full bg-indigo-100 text-indigo-600 flex items-center justify-center text-xs font-bold">
              {userState.current.email.charAt(0).toUpperCase()}
            </span>
            {userState.current.email}
          </div>
        </div>
        
        <div class="flex flex-col gap-1 px-2 pb-4 text-xs font-bold text-gray-600">
          <button 
            onclick={() => activeTab = 'orders'} 
            class="w-full text-left px-3 py-2 rounded-xl transition cursor-pointer {activeTab === 'orders' ? 'bg-indigo-50 text-indigo-600' : 'hover:bg-gray-50'}"
          >
            📦 Мои заказы ({orders.length})
          </button>
          <button 
            onclick={() => activeTab = 'addresses'} 
            class="w-full text-left px-3 py-2 rounded-xl transition cursor-pointer {activeTab === 'addresses' ? 'bg-indigo-50 text-indigo-600' : 'hover:bg-gray-50'}"
          >
            📍 Адреса доставки ({addresses.length})
          </button>
          <button 
            onclick={() => activeTab = 'reviews'} 
            class="w-full text-left px-3 py-2 rounded-xl transition cursor-pointer {activeTab === 'reviews' ? 'bg-indigo-50 text-indigo-600' : 'hover:bg-gray-50'}"
          >
            ✍️ Мои отзывы ({userReviews.length})
          </button>
        </div>

        <button 
          onclick={handleLogout} 
          class="w-full text-left px-4 py-3 border-t border-gray-100 text-xs font-bold text-red-500 hover:text-red-600 transition cursor-pointer"
        >
          🚪 Выйти из профиля
        </button>
      </div>

      <!-- Основная зона контента -->
      <div class="md:col-span-3 space-y-4">
        {#if isDataLoading}
          <div class="bg-white border border-gray-200 p-12 rounded-2xl text-center">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 mx-auto"></div>
          </div>
        
        {:else if activeTab === 'orders'}
          <div class="bg-white border border-gray-200 rounded-2xl shadow-xs p-5 space-y-4">
            <div class="flex justify-between items-center border-b border-gray-100 pb-2">
              <h2 class="text-lg font-black text-gray-900 tracking-tight">История заказов</h2>
              <span class="text-xs text-gray-400">Всего: {orders.length}</span>
            </div>
            
            {#if orders.length === 0}
              <div class="text-center py-12">
                <div class="text-4xl mb-2">📦</div>
                <p class="text-sm text-gray-400">Вы ещё не совершали покупок</p>
                <button 
                  onclick={() => window.location.hash = '#catalog'}
                  class="mt-4 text-indigo-600 text-sm font-bold hover:text-indigo-700"
                >
                  Перейти в каталог →
                </button>
              </div>
            {:else}
              <div class="space-y-3">
                {#each orders as order}
                  <div class="border border-gray-100 rounded-xl p-4 bg-gray-50/50 hover:bg-gray-50 transition">
                    <div class="flex flex-wrap items-center justify-between gap-4">
                      <div class="space-y-1">
                        <div class="text-sm font-black text-gray-900 flex items-center gap-2">
                          Заказ №{order.id}
                          <span class="text-[10px] font-normal text-gray-400">
                            от {new Date(order.created_at).toLocaleDateString('ru-RU')}
                          </span>
                        </div>
                        <div class="text-xs text-gray-500 max-w-sm">
                          📍 {order.full_address}
                        </div>
                      </div>
                      <div class="flex items-center gap-4">
                        <span class="font-black text-base text-gray-900">{order.total_price.toLocaleString()} ₽</span>
                        <span class="text-[10px] font-black uppercase px-2.5 py-1 rounded-full border {getStatusStyle(order.status)}">
                          {getStatusLabel(order.status)}
                        </span>
                      </div>
                    </div>
                  </div>
                {/each}
              </div>
            {/if}
          </div>

        {:else if activeTab === 'addresses'}
          <div class="bg-white border border-gray-200 rounded-2xl shadow-xs p-5 space-y-4">
            <div class="flex justify-between items-center border-b border-gray-100 pb-2">
              <h2 class="text-lg font-black text-gray-900 tracking-tight">Сохраненные адреса</h2>
              <button 
                onclick={() => uiState.info('Добавить адрес можно при оформлении заказа')}
                class="text-xs font-bold text-indigo-600 hover:text-indigo-700"
              >
                + Добавить
              </button>
            </div>
            
            {#if addresses.length === 0}
              <div class="text-center py-12">
                <div class="text-4xl mb-2">📍</div>
                <p class="text-sm text-gray-400">У вас пока нет сохранённых адресов</p>
                <p class="text-xs text-gray-400 mt-1">Добавьте адрес при оформлении первого заказа</p>
              </div>
            {:else}
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                {#each addresses as addr}
                  <div class="border border-gray-100 p-3.5 rounded-xl bg-gray-50/50 relative group">
                    <p class="text-sm font-semibold text-gray-700 leading-relaxed pr-16">
                      📍 {addr.full_address}
                    </p>
                    <div class="flex items-center justify-between mt-2">
                      <span class="text-[9px] text-gray-400 font-mono">
                        FIAS: {addr.fias_id.substring(0, 8)}...
                      </span>
                      <button 
                        onclick={() => deleteAddress(addr.fias_id, addr.full_address)}
                        class="text-[11px] font-bold text-red-400 hover:text-red-600 transition"
                      >
                        Удалить
                      </button>
                    </div>
                  </div>
                {/each}
              </div>
            {/if}
          </div>

        {:else if activeTab === 'reviews'}
          <div class="bg-white border border-gray-200 rounded-2xl shadow-xs p-5 space-y-4">
            <div class="border-b border-gray-100 pb-2">
              <h2 class="text-lg font-black text-gray-900 tracking-tight">Мои отзывы</h2>
              <p class="text-xs text-gray-400 mt-0.5">Нажмите «Развернуть», чтобы загрузить полный текст отзыва</p>
            </div>
            
            {#if userReviews.length === 0}
              <div class="text-center py-12">
                <div class="text-4xl mb-2">✍️</div>
                <p class="text-sm text-gray-400">Вы ещё не оставляли отзывы к книгам</p>
                <button 
                  onclick={() => window.location.hash = '#catalog'}
                  class="mt-4 text-indigo-600 text-sm font-bold hover:text-indigo-700"
                >
                  Оценить книгу →
                </button>
              </div>
            {:else}
              <div class="space-y-3">
                {#each userReviews as review}
                  {@const hasText = review.text !== null && review.text !== undefined}
                  {@const isLoading = loadingReviewId === review.id}
                  {@const isExpanded = expandedReviews.has(review.id)}
                  
                  <div class="border border-gray-100 rounded-xl p-4 bg-gray-50/50 hover:bg-gray-50 transition">
                    <div class="flex justify-between items-start gap-4 flex-wrap">
                      <div class="flex-1">
                        <div class="text-sm font-black text-gray-900">
                          Книга: «{review.book_title}»
                        </div>
                        <div class="flex items-center gap-2 mt-1">
                          <div class="text-amber-400 text-sm select-none">
                            {'★'.repeat(review.rating)}{'☆'.repeat(5 - review.rating)}
                          </div>
                          <span class="text-[10px] text-gray-400">
                            {new Date(review.created_at).toLocaleDateString('ru-RU')}
                          </span>
                        </div>
                      </div>
                      
                      {#if hasText}
                        <button 
                          onclick={() => toggleReviewExpand(review.id)}
                          class="text-xs font-bold text-indigo-600 hover:text-indigo-800 border border-indigo-200 bg-white px-3 py-1.5 rounded-lg transition"
                        >
                          {isExpanded ? '▲ Свернуть' : '▼ Развернуть'}
                        </button>
                      {:else if isLoading}
                        <button disabled class="text-xs font-bold text-gray-400 border border-gray-200 bg-gray-50 px-3 py-1.5 rounded-lg">
                          ⏳ Загрузка...
                        </button>
                      {:else}
                        <button 
                          onclick={() => loadFullReview(review)}
                          class="text-xs font-bold text-indigo-600 hover:text-indigo-800 border border-indigo-200 bg-white px-3 py-1.5 rounded-lg transition"
                        >
                          ▼ Развернуть
                        </button>
                      {/if}
                    </div>

                    {#if isExpanded && hasText}
                      <div class="pt-3 mt-2 border-t border-gray-200/60">
                        <p class="text-sm text-gray-600 leading-relaxed bg-white p-3 rounded-xl border border-gray-100 whitespace-pre-wrap">
                          {review.text}
                        </p>
                      </div>
                    {:else if isLoading}
                      <div class="pt-3 mt-2 border-t border-gray-200/60">
                        <div class="flex items-center justify-center gap-2 py-4">
                          <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-indigo-600"></div>
                          <span class="text-xs text-gray-400">Загрузка текста...</span>
                        </div>
                      </div>
                    {/if}
                  </div>
                {/each}
              </div>
            {/if}
          </div>
        {/if}
      </div>

    </div>
  {/if}
</div>

<style>
  .animate-spin {
    animation: spin 1s linear infinite;
  }
  
  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }
</style>