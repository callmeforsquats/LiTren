<script lang="ts">
  import { onMount } from 'svelte';
  import { catalogApi } from '../api/catalog';
  import BookCard from '../components/BookCard.svelte';
  import type { BookRead, CatRead } from '../types/catalog';

  interface NavigationParams {
    bookId?: number;
    catId?: number;
    isNew?: boolean;
    isBestseller?: boolean;
  }

  // Принимаем строго типизированную функцию навигации из App.svelte
  let { onNavigate } = $props<{ 
    onNavigate: (view: 'home' | 'catalog' | 'book-details' | 'cart' | 'order' | 'profile' | 'admin', params?: NavigationParams) => void 
  }>();

  let cats = $state<CatRead[]>([]);
  let newBooks = $state<BookRead[]>([]);
  let bestsellerBooks = $state<BookRead[]>([]);
  let isLoading = $state(true);

  const banners = [
    {
      badge: "Акция недели",
      title: "Прокачай свой бэкенд со скидкой 20%!",
      description: "Лучшие книги по архитектуре, Python, FastAPI и базам данных уже ждут тебя.",
      bgClass: "from-indigo-600 to-purple-700",
      actionParams: {} 
    },
    {
      badge: "Новое поступление",
      title: "Свежие релизы по Frontend разработке",
      description: "Svelte 5, TypeScript 5.5 и продвинутый Tailwind CSS. Будь на волне трендов.",
      bgClass: "from-emerald-600 to-teal-700",
      actionParams: { isNew: true } 
    },
    {
      badge: "Рекомендация ЛиТрен",
      title: "Топ бестселлеров этого месяца",
      description: "Узнай, что читают ведущие инженеры из Яндекса, Сбера и Т-Банка.",
      bgClass: "from-amber-600 to-orange-700",
      actionParams: { isBestseller: true } 
    }
  ];

  let currentBannerIndex = $state(0);

  onMount(() => {
    isLoading = true;
    
    Promise.all([
      catalogApi.getCats(),
      catalogApi.getBooks({ is_new: true, limit: 10 }),
      catalogApi.getBooks({ is_bestseller: true, limit: 10 })
    ])
    .then(([catsData, newsData, hitsData]) => {
      cats = catsData;
      newBooks = newsData;
      bestsellerBooks = hitsData;
    })
    .catch(error => {
      console.error("Ошибка загрузки данных на Главной:", error);
    })
    .finally(() => {
      isLoading = false;
    });

    const interval = setInterval(() => {
      currentBannerIndex = (currentBannerIndex + 1) % banners.length;
    }, 5000);

    return () => clearInterval(interval);
  });
</script>


<div class="max-w-7xl mx-auto px-4 py-8 text-gray-800">
  <div class="space-y-12">
    
    <!-- Баннер (виден всегда, повышает LCP) -->
    <section class="relative bg-linear-to-r {banners[currentBannerIndex].bgClass} rounded-3xl p-8 md:p-12 text-white overflow-hidden shadow-lg transition-all duration-700 ease-in-out min-h-65 md:min-h-80 flex flex-col justify-center">
      
      <!-- Контент текущего баннера -->
      <div class="max-w-xl relative z-10 space-y-4">
        <span class="bg-white/20 text-xs font-bold uppercase tracking-wider px-3 py-1 rounded-full backdrop-blur-md">
          {banners[currentBannerIndex].badge}
        </span>
        <h1 class="text-3xl md:text-5xl font-black leading-tight tracking-tight min-h-[2.5em] md:min-h-[2em] flex items-center">
          {banners[currentBannerIndex].title}
        </h1>
        <p class="text-indigo-100 text-sm md:text-base min-h-[3em]">
          {banners[currentBannerIndex].description}
        </p>
        <button 
          onclick={() => onNavigate('catalog', banners[currentBannerIndex].actionParams)} 
          class="bg-white text-gray-900 font-bold px-6 py-3 rounded-xl shadow-md hover:bg-gray-50 transition transform hover:-translate-y-0.5 cursor-pointer inline-block"
        >
          В каталог →
        </button>
      </div>

      <!-- Декоративный размытый круг -->
      <div class="absolute -right-10 -bottom-10 w-64 h-64 bg-white/10 rounded-full blur-2xl pointer-events-none"></div>

      <!-- Стрелочки управления (на десктопе) -->
      <div class="absolute inset-x-4 top-1/2 -translate-y-1/2 justify-between items-center hidden md:flex z-20">
        <button 
          onclick={() => currentBannerIndex = (currentBannerIndex - 1 + banners.length) % banners.length} 
          class="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 backdrop-blur-xs flex items-center justify-center text-xl font-bold cursor-pointer transition"
          aria-label="Предыдущий слайд"
        >
          ←
        </button>
        <button 
          onclick={() => currentBannerIndex = (currentBannerIndex + 1) % banners.length} 
          class="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 backdrop-blur-xs flex items-center justify-center text-xl font-bold cursor-pointer transition"
          aria-label="Следующий слайд"
        >
          →
        </button>
      </div>

      <!-- Индикаторы (точки) -->
      <div class="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2 z-20">
        {#each banners as _, index}
          <button 
            onclick={() => currentBannerIndex = index}
            class="h-2 rounded-full transition-all duration-300 cursor-pointer {currentBannerIndex === index ? 'w-6 bg-white' : 'w-2 bg-white/40 hover:bg-white/60'}"
            aria-label="Перейти к слайду {index + 1}"
          ></button>
        {/each}
      </div>
    </section>

    {#if isLoading}
      <!-- Красивый Скелетон вместо скучного спиннера -->
      <div class="space-y-12 animate-pulse">
        <div class="h-8 bg-gray-200 rounded-lg w-48"></div>
        <div class="flex gap-4 overflow-x-auto pb-4">
          {#each Array(5) as _}
            <div class="w-40 sm:w-48 h-72 bg-gray-200 rounded-2xl shrink-0"></div>
          {/each}
        </div>
      </div>
    {:else}
      <!-- Жанры -->
      {#if cats.length > 0}
        <section class="space-y-4">
          <h2 class="text-xl font-bold tracking-tight text-gray-950">Популярные жанры</h2>
          <div class="flex gap-2 overflow-x-auto pb-2 no-scrollbar scroll-smooth">
            {#each cats as cat}
              <button 
                onclick={() => onNavigate('catalog', { catId: cat.id })} 
                class="bg-white border border-gray-200 hover:border-indigo-500 hover:text-indigo-600 px-5 py-2 rounded-xl text-sm font-medium shadow-xs shrink-0 transition cursor-pointer"
              >
                {cat.name}
              </button>
            {/each}
          </div>
        </section>
      {/if}

      <!-- Карусель: Новинки -->
      <section class="space-y-4">
        <div class="flex justify-between items-end">
          <div>
            <h2 class="text-2xl font-black tracking-tight text-gray-950">Свежие новинки ✨</h2>
            <p class="text-sm text-gray-500">Только что из типографии</p>
          </div>
          <button onclick={() => onNavigate('catalog', { isNew: true })} class="text-sm font-bold text-indigo-600 hover:text-indigo-700 transition cursor-pointer">Все новинки</button>
        </div>
        
        <div class="flex gap-4 overflow-x-auto pb-4 snap-x snap-mandatory scroll-smooth no-scrollbar select-none">
          {#each newBooks as book}
            <div class="w-40 sm:w-48 shrink-0 snap-start flex">
              <BookCard {book} onCardClick={(id) => onNavigate('book-details', { bookId: id })} />
            </div>
          {/each}
        </div>
      </section>

      <!-- Карусель: Бестселлеры -->
      <section class="space-y-4">
        <div class="flex justify-between items-end">
          <div>
            <h2 class="text-2xl font-black tracking-tight text-gray-950">Хиты продаж 🔥</h2>
            <p class="text-sm text-gray-500">То, что читают все</p>
          </div>
          <button onclick={() => onNavigate('catalog', { isBestseller: true })} class="text-sm font-bold text-indigo-600 hover:text-indigo-700 transition cursor-pointer">Все хиты</button>
        </div>
        
        <div class="flex gap-4 overflow-x-auto pb-4 snap-x snap-mandatory scroll-smooth no-scrollbar select-none">
          {#each bestsellerBooks as book}
            <div class="w-40 sm:w-48 shrink-0 snap-start flex">
              <BookCard {book} onCardClick={(id) => onNavigate('book-details', { bookId: id })} />
            </div>
          {/each}
        </div>
      </section>
    {/if}
  </div>
</div>

<style>
  :global(.no-scrollbar::-webkit-scrollbar) { display: none; }
  :global(.no-scrollbar) { -ms-overflow-style: none; scrollbar-width: none; }
</style>
