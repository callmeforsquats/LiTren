<script lang="ts">
  import { onMount, untrack } from 'svelte';
  import { catalogApi } from '../api/catalog';
  import { SortBy } from '../types/catalog';
  import type { BookRead, CatRead, TopicRead, AuthorRead, PubRead, BookFilter, BindingRead } from '../types/catalog';
  import BookCard from '../components/BookCard.svelte';
  import SkeletonCard from '../components/SkeletonCard.svelte';
  import {debounce} from '../api/client'

  // Описываем входящие пропсы: параметры из URL и колбэк отправки фильтров наверх
  let { onNavigate, initialFilters = null, onFiltersChange } = $props<{ 
    onNavigate: (view: 'home' | 'catalog' | 'book-details' | 'cart' | 'order' | 'profile' | 'admin', params?: any) => void;
    initialFilters?: { 
      catId?: number; 
      isNew?: boolean;
      isBestseller?: boolean;
      topicId?: number[];
      authorId?: number[];
      pubId?: number[];
      bindingId?: number[];
      minRating?:number;
      sortBy?:SortBy;
      reverse?:boolean;
    } | null;
    onFiltersChange: (filters: any) => void;
  }>();

  let filters = $state<BookFilter>({
    cat_id: null,
    topic_id: [],
    min_price: null,
    max_price: null,
    binding_id: [],
    is_new: null,
    is_bestseller: null,
    min_rating: null,
    author_id: [],
    pub_id: [],
    search: '',
    limit: 12,
    offset: 0,
    sort_by: SortBy.popularity,
    reverse: null
  });

  const debouncedApplyFilters = debounce((currentFilters: any) => {
    // Тихо обновляем строку URL в App.svelte
    onFiltersChange({
      catId: currentFilters.cat_id ?? undefined,
      isNew: currentFilters.is_new ?? undefined,
      isBestseller: currentFilters.is_bestseller ?? undefined,
      minRating: currentFilters.min_rating ?? undefined,
      topicIds: currentFilters.topic_id.length > 0 ? currentFilters.topic_id : undefined,
      authorIds: currentFilters.author_id.length > 0 ? currentFilters.author_id : undefined,
      pubId: currentFilters.pub_id.length > 0 ? currentFilters.pub_id : undefined,
      bindingId: currentFilters.binding_id.length > 0 ? currentFilters.binding_id : undefined,
      sortBy: currentFilters.sort_by ?? undefined,
      reverse: currentFilters.reverse ? true : undefined,
    });

    // Запускаем сетевой запрос за книгами
    loadBooks();
  }, 5000);

  let books = $state<BookRead[]>([]);
  let allCategories = $state<CatRead[]>([]);
  let availableTopics = $state<TopicRead[]>([]);
  let availableAuthors = $state<AuthorRead[]>([]);
  let allPubs = $state<PubRead[]>([]);
  let allBindings = $state<BindingRead[]>([]);
  
  let isLoading = $state(true);
  let isLoadMoreLoading = $state(false);
  let hasMore = $state(true);
  let errorMessage = $state('');
  let loadMoreTrigger = $state<HTMLElement | null>(null);

  // Флаг блокировки, чтобы избежать двойных циклов при первичной вычитке пропсов
  let isInitializing = false;

  let currentCategory = $derived(allCategories.find(c => c.id === filters.cat_id) || null);

  let breadcrumbs = $derived.by(() => {
    if (!filters.cat_id || allCategories.length === 0) return [];
    const crumbs: CatRead[] = [];
    let current = allCategories.find(c => c.id === filters.cat_id);
    while (current) { crumbs.unshift(current); current = allCategories.find(c => c.id === current?.parent_id); }
    return crumbs;
  });

  let availableCategories = $derived.by(() => {
    if (allCategories.length === 0) return [];
    if (!filters.cat_id) return allCategories.filter(c => c.parent_id === null);
    const children = allCategories.filter(c => c.parent_id === filters.cat_id);
    if (children.length > 0) return children;
    return allCategories.filter(c => c.parent_id === currentCategory?.parent_id);
  });

  let activeBadges = $derived.by(() => {
    const badges = [];
    if (filters.search) badges.push({ type: 'search', label: `Поиск: ${filters.search}` });
    if (currentCategory) badges.push({ type: 'cat_id', label: `Жанр: ${currentCategory.name}` });
    if (filters.min_price) badges.push({ type: 'min_price', label: `От ${filters.min_price} ₽` });
    if (filters.max_price) badges.push({ type: 'max_price', label: `До ${filters.max_price} ₽` });
    if (filters.min_rating) badges.push({ type: 'min_rating', label: `Рейтинг от ⭐ ${filters.min_rating}` });
    if (filters.is_new) badges.push({ type: 'is_new', label: '✨ Новинка' });
    if (filters.is_bestseller) badges.push({ type: 'is_bestseller', label: '🔥 Бестселлер' });
    
    filters.topic_id?.forEach(id => { const x = availableTopics.find(t => t.id === id); if (x) badges.push({ type: 'topic_id', id, label: `#${x.name}` }); });
    filters.binding_id?.forEach(id => { const x = allBindings.find(b => b.id === id); if (x) badges.push({ type: 'binding_id', id, label: `Переплет: ${x.name}` }); });
    filters.author_id?.forEach(id => { const x = availableAuthors.find(a => a.id === id); if (x) badges.push({ type: 'author_id', id, label: `Автор: ${x.name}` }); });
    filters.pub_id?.forEach(id => { const x = allPubs.find(p => p.id === id); if (x) badges.push({ type: 'pub_id', id, label: `Изд: ${x.name}` }); });
    
    return badges;
  });

  async function loadBooks() {
    isLoading = true;
    errorMessage = '';
    hasMore = true;
    filters.offset = 0;
    try {
      books = await catalogApi.getBooks(filters);
      if (books.length < filters.limit) hasMore = false;
    } catch (err: any) {
      errorMessage = err.message || 'Ошибка загрузки';
    } finally {
      isLoading = false;
    }
  }

  async function loadMoreBooks() {
    if (isLoadMoreLoading || !hasMore || isLoading) return;
    isLoadMoreLoading = true;
    filters.offset += filters.limit;
    try {
      const nextBatch = await catalogApi.getBooks(filters);
      if (nextBatch.length < filters.limit) hasMore = false;
      books = [...books, ...nextBatch];
    } catch (e) { console.error(e); } finally { isLoadMoreLoading = false; }
  }

  function toggleArrayFilter(field: 'topic_id' | 'binding_id' | 'author_id' | 'pub_id', id: number) {
    if (!filters[field]) filters[field] = [];
    if (filters[field]!.includes(id)) {
      filters[field] = filters[field]!.filter(x => x !== id);
    } else {
      filters[field]=[...filters[field]!,id];
    }
  }

  function handleCheckboxChange(type: 'is_new' | 'is_bestseller'|'reverse', event: Event) {
    filters[type] = (event.target as HTMLInputElement).checked ? true : null;
  }


  function removeBadge(badge: any) {
    if (badge.type === 'search') filters.search = '';
    if (badge.type === 'cat_id') filters.cat_id = currentCategory?.parent_id || null;
    if (badge.type === 'min_price') filters.min_price = null;
    if (badge.type === 'max_price') filters.max_price = null;
    if (badge.type === 'min_rating') filters.min_rating = null;
    if (badge.type === 'is_new') filters.is_new = null;
    if (badge.type === 'is_bestseller') filters.is_bestseller = null;
    if (['topic_id', 'binding_id', 'author_id', 'pub_id'].includes(badge.type)) {
      filters[badge.type as 'topic_id'] = filters[badge.type as 'topic_id']!.filter(x => x !== badge.id);
    }
    loadBooks();
  }

  function resetFilters() {
    filters = { cat_id: null, topic_id: [], min_price: null, max_price: null, binding_id: [], is_new: null, is_bestseller: null, min_rating: null, author_id: [], pub_id: [], search: '', limit: 12, offset: 0, sort_by: SortBy.popularity, reverse: false };
    onFiltersChange({});
    loadBooks();
  }

  // ЭФФЕКТ СВЕРХУ-ВНИЗ: Срабатывает, когда App.svelte передает новые пропсы (например, переход с главной)
  function areFiltersEqual(a: any, b: any) {
    return JSON.stringify(a) === JSON.stringify(b);
  }

  let lastIncomingFilters = $state<string|null>(null)

  // ЭФФЕКТ СВЕРХУ-ВНИЗ: Накатываем параметры из URL в локальный стейт каталога
  $effect(() => {
    const incoming = initialFilters;
    if (areFiltersEqual(incoming, lastIncomingFilters?JSON.parse(lastIncomingFilters):null)) return;
    
    lastIncomingFilters = JSON.stringify(incoming);
    isInitializing = true;

    filters.cat_id = incoming?.catId ?? null;
    filters.topic_id = incoming?.topicIds ?? [];
    filters.binding_id = incoming?.bindingId ?? [];
    filters.is_new = incoming?.isNew ?? null;
    filters.is_bestseller = incoming?.isBestseller ?? null;
    filters.min_rating = incoming?.minRating ?? null;
    filters.author_id = incoming?.authorIds ?? [];
    filters.pub_id = incoming?.pubId ?? [];
    filters.sort_by = (incoming?.sortBy as SortBy) ?? SortBy.popularity;
    filters.reverse = incoming?.reverse ?? false;
    
    // Сбрасываем offset в 0 только при реальной смене глобального фильтра из URL
    filters.offset = 0; 

    untrack(() => {
      loadBooks();
    });

    setTimeout(() => { isInitializing = false; }, 0);
  });

  // ЭФФЕКТ СНИЗУ-ВВЕРХ: Срабатывает при кликах в каталоге, передавая новые фильтры в URL
  $effect(() => {
    // Явно перечисляем абсолютно ВСЕ поля, которые должны приводить к обновлению URL и перезагрузке книг
    const trigger = {
      search: filters.search,         
      cat: filters.cat_id,           
      in_price: filters.min_price,   
      max_price: filters.max_price,   
      is_new: filters.is_new,
      is_bestseller: filters.is_bestseller,
      rating: filters.min_rating,
      topics: filters.topic_id?.length,
      authors: filters.author_id?.length,
      pubs: filters.pub_id?.length,
      bindings: filters.binding_id?.length,
      sort_by: filters.sort_by,
      reverse: filters.reverse,
    };

    if (isInitializing) return;

    untrack(() => {
      // Делаем чистый снимок состояния без Proxy для передачи в дебаунс
      const currentSnapshot = $state.snapshot(filters);
      debouncedApplyFilters(currentSnapshot);
    });
  });

  $effect(() => {
    catalogApi.getTopics(filters.cat_id).then(t => { availableTopics = t; }).catch(e => console.error(e));
  });

  $effect(() => {
    catalogApi.getAuthors(filters.cat_id).then(t => { availableAuthors = t; }).catch(e => console.error(e));
  });

  $effect(() => {
    if (!loadMoreTrigger) return;
    const observer = new IntersectionObserver((entries) => { if (entries[0].isIntersecting) loadMoreBooks(); }, { rootMargin: '200px' });
    observer.observe(loadMoreTrigger);
    return () => observer.disconnect();
  });

  onMount(async () => {
    try {
      const [cats, authors, publishers, bindings] = await Promise.all([
        catalogApi.getCats(),
        catalogApi.getAuthors().catch(() => []),
        catalogApi.getPubs().catch(() => []),
        catalogApi.getBindings().catch(() => [])
      ]);
      allCategories = cats;
      allPubs = publishers;
      allBindings = bindings;
      availableAuthors = authors;
    } catch (e) { console.error(e); }
  });
</script>


<div class="max-w-7xl mx-auto px-4 py-6 bg-slate-50 min-h-screen text-gray-800">
  <!-- Крошки -->
  <nav class="flex items-center gap-2 text-xs text-gray-500 mb-4 bg-white px-4 py-2.5 rounded-xl border border-gray-200/60 shadow-xs">
    <button onclick={() => { filters.cat_id = null; loadBooks(); }} class="hover:text-indigo-600 font-medium cursor-pointer">Главная</button>
    {#each breadcrumbs as crumb, index}
      <span class="text-gray-300">/</span>
      <button onclick={() => { filters.cat_id = crumb.id; loadBooks(); }} class="hover:text-indigo-600 font-medium cursor-pointer {index === breadcrumbs.length - 1 ? 'text-gray-900 font-bold' : ''}" disabled={index === breadcrumbs.length - 1}>{crumb.name}</button>
    {/each}
  </nav>

  <div class="flex flex-col md:flex-row gap-6 items-start relative">
    
    <!-- ПОЛНЫЙ САЙДБАР С НЕЗАВИСИМЫМ СКРОЛЛОМ -->
    <aside class="w-full md:w-68 shrink-0 bg-white p-4 rounded-2xl border border-gray-200 shadow-xs space-y-5 sticky top-24 max-h-[calc(100vh-7rem)] overflow-y-auto no-scrollbar z-30">
      <div class="flex justify-between items-center border-b border-gray-100 pb-2">
        <h2 class="text-sm font-black text-gray-900">Фильтры</h2>
        <button onclick={resetFilters} class="text-xs font-bold text-indigo-600 hover:text-indigo-700 cursor-pointer">Сбросить</button>
      </div>

      <!-- Поиск -->
      <div class="space-y-1">
        <label for="search" class="text-[10px] font-bold uppercase tracking-wider text-gray-400">Поиск</label>
        <input id="search" type="text" bind:value={filters.search} placeholder="Название..." class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-1.5 text-sm focus:outline-none focus:border-indigo-500 focus:bg-white transition-all" />
      </div>

      <!-- Разделы -->
      <div class="space-y-1">
        <label for="category" class="text-[10px] font-bold uppercase tracking-wider text-gray-400">Раздел</label>
        <select id="category" bind:value={filters.cat_id} class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-1.5 text-sm text-gray-900 focus:outline-none focus:border-indigo-500 cursor-pointer">
          <option value={currentCategory?.parent_id || null}>{filters.cat_id ? '← Наверх' : 'Все разделы'}</option>
          {#each availableCategories as cat} <option value={cat.id}>{cat.name}</option> {/each}
        </select>
      </div>

      <!-- Цена -->
      <div class="space-y-1">
        <span class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Цена, ₽</span>
        <div class="flex items-center gap-1.5">
          <input type="number" placeholder="от" bind:value={filters.min_price}  class="w-full bg-gray-50 border border-gray-200 rounded-xl px-2 py-1 text-sm text-center focus:outline-none focus:border-indigo-500 focus:bg-white" />
          <input type="number" placeholder="до" bind:value={filters.max_price}  class="w-full bg-gray-50 border border-gray-200 rounded-xl px-2 py-1 text-sm text-center focus:outline-none focus:border-indigo-500 focus:bg-white" />
        </div>
      </div>

      <!-- Минимальный рейтинг -->
      <div class="space-y-1">
        <label for="rating" class="text-[10px] font-bold uppercase tracking-wider text-gray-400">Рейтинг от</label>
        <select id="rating" bind:value={filters.min_rating} class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-1.5 text-sm cursor-pointer focus:outline-none">
          <option value={null}>Любой рейтинг</option>
          <option value={4.5}>⭐ 4.5 и выше</option>
          <option value={4.0}>⭐ 4.0 и выше</option>
          <option value={3.0}>⭐ 3.0 и выше</option>
        </select>
      </div>

      <!-- Тип переплета -->
      <div class="space-y-1">
        <span class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Переплет</span>
        <div class="flex flex-col gap-1.5 text-xs text-gray-700">
          {#each allBindings as b}
            <label class="flex items-center gap-2 cursor-pointer select-none">
              <input type="checkbox" checked={filters.binding_id?.includes(b.id)} onchange={() => toggleArrayFilter('binding_id', b.id)} class="rounded text-indigo-600 border-gray-300 h-3.5 w-3.5 accent-indigo-600" />
              <span>{b.name}</span>
            </label>
          {/each}
        </div>
      </div>

      <!-- Тематика (Динамическая) -->
      {#if availableTopics.length > 0}
        <div class="space-y-1.5 pt-2 border-t border-gray-100">
          <span class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Тематика</span>
          <div class="flex flex-wrap gap-1 max-h-36 overflow-y-auto pr-1 no-scrollbar">
            {#each availableTopics as topic}
              <button onclick={() => toggleArrayFilter('topic_id', topic.id)} class="text-[11px] px-2 py-0.5 rounded-lg border transition cursor-pointer {filters.topic_id?.includes(topic.id) ? 'bg-indigo-50 border-indigo-300 text-indigo-700 font-bold' : 'bg-gray-50 border-gray-200 text-gray-600'}">#{topic.name}</button>
            {/each}
          </div>
        </div>
      {/if}

      <!-- Фильтр по авторам -->
      {#if availableAuthors.length > 0}
        <div class="space-y-1.5 pt-2 border-t border-gray-100">
          <span class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Авторы</span>
          <div class="flex flex-col gap-1.5 max-h-36 overflow-y-auto text-xs text-gray-700 pr-1 no-scrollbar">
            {#each availableAuthors as author}
              <label class="flex items-center gap-2 cursor-pointer select-none">
                <input type="checkbox" checked={filters.author_id?.includes(author.id)} onchange={() => toggleArrayFilter('author_id', author.id)} class="rounded text-indigo-600 border-gray-300 h-3.5 w-3.5 accent-indigo-600" />
                <span class="line-clamp-1">{author.name}</span>
              </label>
            {/each}
          </div>
        </div>
      {/if}

      <!-- Фильтр по издательствам -->
      {#if allPubs.length > 0}
        <div class="space-y-1.5 pt-2 border-t border-gray-100">
          <span class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Издательства</span>
          <div class="flex flex-col gap-1.5 max-h-36 overflow-y-auto text-xs text-gray-700 pr-1 no-scrollbar">
            {#each allPubs as pub}
              <label class="flex items-center gap-2 cursor-pointer select-none">
                <input type="checkbox" checked={filters.pub_id?.includes(pub.id)} onchange={() => toggleArrayFilter('pub_id', pub.id)} class="rounded text-indigo-600 border-gray-300 h-3.5 w-3.5 accent-indigo-600" />
                <span class="line-clamp-1">{pub.name}</span>
              </label>
            {/each}
          </div>
        </div>
      {/if}

      <!-- Быстрые флаги -->
      <div class="space-y-2 pt-3 border-t border-gray-100">
        <label class="flex items-center gap-2.5 text-xs font-medium text-gray-700 cursor-pointer select-none"><input type="checkbox" checked={!!filters.is_new} onchange={(e) => handleCheckboxChange('is_new', e)} class="rounded text-indigo-600 h-3.5 w-3.5 border-gray-300 accent-indigo-600" /> <span>✨ Свежие новинки</span></label>
        <label class="flex items-center gap-2.5 text-xs font-medium text-gray-700 cursor-pointer select-none"><input type="checkbox" checked={!!filters.is_bestseller} onchange={(e) => handleCheckboxChange('is_bestseller', e)} class="rounded text-indigo-600 h-3.5 w-3.5 border-gray-300 accent-indigo-600" /> <span>🔥 Бестселлеры</span></label>
      </div>
    </aside>

    <!-- ОСНОВНАЯ ЗОНА ТОВАРОВ -->
    <div class="grow space-y-3">
      <!-- Бейджи -->
      {#if activeBadges.length > 0}
        <div class="bg-white p-2.5 rounded-xl border border-gray-200 shadow-xs flex flex-wrap items-center gap-1.5">
          <span class="text-xs font-bold text-gray-400 mr-1">Выбрано:</span>
          {#each activeBadges as badge}
            <span class="inline-flex items-center gap-1 bg-gray-50 text-gray-800 text-xs font-semibold px-2 py-0.5 rounded-lg border border-gray-200">
              {badge.label}
              <button onclick={() => removeBadge(badge)} class="hover:text-red-500 font-bold ml-1 text-[10px] cursor-pointer">✕</button>
            </span>
          {/each}
        </div>
      {/if}

      <!-- Сортировка -->
      <div class="bg-white p-3 rounded-xl border border-gray-200 shadow-xs flex items-center justify-between gap-4">
        <div class="flex items-center gap-2 text-xs sm:text-sm">
          <span class="text-gray-400 font-medium">Сортировка:</span>
          <select bind:value={filters.sort_by}  class="bg-transparent font-bold text-indigo-600 focus:outline-none cursor-pointer">
            <option value={SortBy.popularity}>По популярности</option>
            <option value={SortBy.rating}>По рейтингу</option>
            <option value={SortBy.price}>По цене</option>
          </select>
        </div>
        <label class="flex items-center gap-2 cursor-pointer text-gray-500 text-xs sm:text-sm font-medium select-none">
          <input type="checkbox" checked={!!filters.reverse} onchange={(e)=>handleCheckboxChange("reverse",e)}  class="accent-indigo-600 h-3.5 w-3.5" />
          <span>По убыванию</span>
        </label>
      </div>

      <!-- Вывод книг -->
      {#if isLoading}
  <!-- 1. Заменили центральный спиннер на красивую сетку дефолтных скелетонов -->
  <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
    {#each Array(8) as _}
      <SkeletonCard />
    {/each}
  </div>
{:else if errorMessage}
  <div class="bg-red-50 border border-red-200 text-red-600 p-4 rounded-xl text-center font-medium">{errorMessage}</div>
{:else if books.length === 0}
  <div class="text-center py-24 text-gray-400 bg-white rounded-xl border border-dashed border-gray-200 font-medium">Книг не найдено.</div>
{:else}
  <!-- Реальная сетка книг -->
  <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
    {#each books as book} 
      <BookCard {book} onCardClick={(id) => onNavigate('book-details', { bookId: id })} /> 
    {/each}
    
    <!-- 2. Внедряем скелетоны прямо внутрь сетки при догрузке нижней пачки (Infinite Scroll UX) -->
    {#if isLoadMoreLoading}
      {#each Array(4) as _}
        <SkeletonCard />
      {/each}
    {/if}
  </div>

  <!-- Триггер для Intersection Observer -->
  {#if hasMore}
    <div bind:this={loadMoreTrigger} class="w-full h-10 flex justify-center py-4">
      <!-- Контент внутри триггера убран, так как скелетоны рендерятся выше в сетке -->
    </div>
  {:else}
    <p class="text-center text-[11px] text-gray-400 font-medium py-6">🎉 Вы просмотрели все доступные книги раздела</p>
  {/if}
{/if}
    </div>

  </div>
</div>

<style>
  :global(.no-scrollbar::-webkit-scrollbar) { display: none; }
  :global(.no-scrollbar) { -ms-overflow-style: none; scrollbar-width: none; }
</style>
