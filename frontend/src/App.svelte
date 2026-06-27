<!-- src/App.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { cartState } from './states/cart.svelte';
  import { userState } from './states/user.svelte';
  import { uiState } from './states/ui.svelte';
  
  import Home from './pages/Home.svelte';
  import Catalog from './pages/Catalog.svelte';
  import BookDetail from './pages/BookDetail.svelte';
  import Cart from './pages/Cart.svelte';
  import Profile from './pages/Profile.svelte';
  import AdminPanel from './pages/AdminPanel.svelte';
  import Order from './pages/Order.svelte';
  
  import ToastContainer from './components/ToastContainer.svelte';
  import ConfirmDialog from './components/ConfirmDialog.svelte';
  import GlobalLoader from './components/GlobalLoader.svelte';
  import AuthModal from './components/AuthModal.svelte';
  import ChatSearch from './components/ChatSearch.svelte';
  import { SortBy } from './types/catalog';

  type View = 'home' | 'catalog' | 'book-details' | 'cart' | 'order' | 'profile' | 'admin';

  interface ViewParams {
    bookId?: number;
    catId?: number;
    isNew?: boolean;
    isBestseller?: boolean;
    minRating?:number;
    topicId?: number[];
    authorId?: number[];
    pubId?: number[];
    bindingId?: number[];
    selectedBookId?: number[];
    sortBy?:SortBy,
    reverse?:boolean
  }

  let currentView = $state<View>('home'); 
  let viewParams = $state<ViewParams>({});

  function canAccessAdmin(): boolean {
    return userState.isAdmin;
  }

  // Вспомогательная функция для сборки красивой Query-строки параметров
  function buildQueryString(params: ViewParams): string {
    const searchParams = new URLSearchParams();
    
    if (params.catId) searchParams.set('catId', params.catId.toString());
    if (params.isNew) searchParams.set('isNew', 'true');
    if (params.isBestseller) searchParams.set('isBestseller', 'true');
    if (params.minRating) searchParams.set('minRating',params.minRating.toString())
    
    // Проверяем и упаковываем массивы (переводим [1, 2] в строку "1,2")
    if (params.authorId && params.authorId.length > 0) searchParams.set('authorId', params.authorId.join(','));
    if (params.topicId && params.topicId.length > 0) searchParams.set('topicId', params.topicId.join(','));
    if (params.pubId && params.pubId.length > 0) searchParams.set('pubId', params.pubId.join(','));       // 👈 Исправлено на pubId
    if (params.bindingId && params.bindingId.length > 0) searchParams.set('bindingId', params.bindingId.join(',')); // 👈 Исправлено на bindingId
    if (params.sortBy) searchParams.set('sortBy', params.sortBy);
    if (params.reverse) searchParams.set('reverse', 'true');
    
    if (params.selectedBookId && params.selectedBookId.length > 0) searchParams.set('id', params.selectedBookId.join(','));
    
    const str = searchParams.toString();
    return str ? `?${str}` : '';
  }


  // 1. Извлекаем параметры из хэша при загрузке или навигации кнопками браузера "Назад/Вперед"
  function parseLocation() {
    const hashString = window.location.hash || '#/';
    const [path, queryString] = hashString.split('?');
    const searchParams = new URLSearchParams(queryString || '');
    
    if (path === '#/' || path === '') {
      currentView = 'home';
      viewParams = {};
    } else if (path.startsWith('#books/')) {
      const parts = path.split('/');
      const id = parseInt(parts[1], 10);
      currentView = 'book-details';
      viewParams = { bookId: isNaN(id) ? undefined : id };
    } else if (path === '#catalog') {
      currentView = 'catalog';
      const catId = searchParams.get('catId') ? parseInt(searchParams.get('catId')!, 10) : undefined;
      const isNew = searchParams.get('isNew') === 'true' ? true : undefined;
      const isBestseller = searchParams.get('isBestseller') === 'true' ? true : undefined;
      const minRating = searchParams.get('minRating')? parseFloat(searchParams.get('minRating')!):undefined;
      const authorId = searchParams.get('authorId') ? searchParams.get('authorId')!.split(',').map(Number) : undefined;
      const topicId = searchParams.get('topicId') ? searchParams.get('topicId')!.split(',').map(Number) : undefined;
      const pubId = searchParams.get('pubId') ? searchParams.get('pubId')!.split(',').map(Number) : undefined;
      const bindingId = searchParams.get('bindingId') ? searchParams.get('bindingId')!.split(',').map(Number) : undefined;
      const reverse = searchParams.get('reverse') === 'true' ? true : undefined;
      const rawSortBy = searchParams.get('sortBy');
      
      // 2. Проверяем, входит ли эта строка в значения нашего Enum, чтобы избежать runtime-ошибок
      const sortBy = Object.values(SortBy).includes(rawSortBy as SortBy) 
        ? (rawSortBy as SortBy) 
        : undefined;

      viewParams = { catId, isNew, isBestseller,minRating, authorId, topicId, pubId, bindingId, sortBy, reverse };
    } else if (path === '#cart') { 
      currentView = 'cart'; 
      viewParams = {}; 
    } else if (path === '#profile') { 
      currentView = 'profile'; 
      viewParams = {}; 
    } else if (path === '#admin') { 
      currentView = 'admin'; 
      viewParams = {}; 
    } else if (path === '#order') {
      currentView = 'order';
      const idStr = searchParams.get('id');
      viewParams = { selectedBookId: idStr ? idStr.split(',').map(Number) : [] };
    }
  }

  // 2. Функция перехода между страницами (создает новую точку в истории браузера)
  function navigate(view: View, params: ViewParams = {}) {
    if (view === 'admin' && !canAccessAdmin()) {
      uiState.error('Доступ запрещен. Требуются права администратора.');
      view = 'home';
      params = {};
    }
    
    viewParams = params;
    const suffix = buildQueryString(params); // 👈 Соберет URL с учетом всех новых массивов
    
    if (view === 'home') window.location.hash = '#/';
    else if (view === 'book-details' && params.bookId) window.location.hash = `#books/${params.bookId}`;
    else window.location.hash = `#${view}${suffix}`;

    window.scrollTo({ top: 0, behavior: 'smooth' });
  }


  // 3. Функция "тихого" обновления URL при кликах по фильтрам внутри каталога (БЕЗ создания новой точки в истории)
  function handleCatalogFiltersChange(updatedFilters: ViewParams) {
    console.log("фильтры поменялись")
    viewParams = updatedFilters;
    const suffix = buildQueryString(updatedFilters);
    const newHash = `#catalog${suffix}`;
    
    if (window.location.hash !== newHash) {
      window.history.replaceState(null, '', newHash);
    }
  }

  onMount(() => {
    parseLocation();
    window.addEventListener('hashchange', parseLocation);

    Promise.all([
      userState.checkAuth(),
      cartState.getCart()
    ]).catch(err => {
      console.error("Ошибка инициализации приложения:", err);
      uiState.error("Не удалось загрузить данные приложения");
    });

    return () => {
      window.removeEventListener('hashchange', parseLocation);
    };
  });
</script>



<GlobalLoader />
<ToastContainer />
<ConfirmDialog />
<AuthModal/>
<ChatSearch/>

<header class="bg-white text-gray-800 border-b border-gray-200 sticky top-0 z-50 shadow-sm">
  <div class="max-w-7xl mx-auto px-4 flex items-center justify-between py-4 gap-4">
    
    <button onclick={() => navigate('home')} class="text-2xl font-black tracking-wider text-indigo-600 focus:outline-none cursor-pointer">
      ЛИТРЕН
    </button>

    <nav class="hidden md:flex items-center gap-6 text-sm font-semibold text-gray-600">
      <button onclick={() => navigate('home')} class="hover:text-indigo-600 transition-colors cursor-pointer {currentView === 'home' ? 'text-indigo-600 font-bold' : ''}">Главная</button>
      <button onclick={() => navigate('catalog')} class="hover:text-indigo-600 transition-colors cursor-pointer {currentView === 'catalog' ? 'text-indigo-600 font-bold' : ''}">Каталог</button>
      
      {#if userState.isAdmin}
        <button onclick={() => navigate('admin')} class="hover:text-gray-900 transition-colors text-gray-400 cursor-pointer {currentView === 'admin' ? 'text-indigo-600 font-bold' : ''}">
          Админка
        </button>
      {/if}
    </nav>

    <div class="flex items-center gap-4">
      <button onclick={() => navigate('profile')} class="px-4 py-2 text-sm font-medium border border-gray-200 hover:border-gray-300 rounded-xl text-gray-700 transition-colors cursor-pointer">
        {userState.current ? `👤 ${userState.current.email}` : '👤 Профиль'}
      </button>
      
      <button onclick={() => navigate('cart')} class="px-4 py-2 text-sm bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-xl transition-all relative flex items-center gap-2 shadow-sm cursor-pointer">
        <span>🛒 Корзина</span>
        {#if cartState.totalItems > 0}
          <span class="bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full">{cartState.totalItems}</span>
        {/if}
      </button>
    </div>

  </div>
</header>

<div class="bg-gray-50 min-h-screen">
  {#if currentView === 'home'}
    <Home onNavigate={navigate} />
  {/if}
  <div class:hidden={currentView!=='catalog'}>
    <Catalog onNavigate={navigate} initialFilters={viewParams}  onFiltersChange={handleCatalogFiltersChange}/>
  </div>
  {#if currentView === 'book-details'}
    {#if viewParams.bookId !== undefined}
      <BookDetail bookId={viewParams.bookId} onNavigate={navigate} />
    {:else}
      <div class="p-8 text-center text-red-500 font-bold">Книга не выбрана или не найдена.</div>
    {/if}
  {:else if currentView === 'cart'}
    <Cart onNavigate={navigate} />
  {:else if currentView === 'order'}
    <Order onNavigate={navigate} selectedBookId={viewParams.selectedBookId || []} />
  {:else if currentView === 'profile'}
    <Profile />
  {:else if currentView === 'admin'}
    <AdminPanel />
  {/if}
</div>

<footer class="bg-white border-t border-gray-200 text-gray-400 text-xs text-center py-8">
  &copy; 2026 ЛиТрен. Интернет-магазин на FastAPI и Svelte 5.
</footer>