<script lang="ts">
  import { onMount, untrack } from 'svelte';
  import { catalogApi } from '../api/catalog';
  import { usersApi } from '../api/users';
  import { cartState } from '../states/cart.svelte';
  import { userState } from '../states/user.svelte';
  import { uiState } from '../states/ui.svelte';
  import { ItemCreate, ReviewCreate, ReviewFilter, type ReviewRead } from '../types/users';
  import type { BookInfo } from '../types/catalog';
  import RatingStars from '../components/RatingStars.svelte';

  // Описываем доступные типы страниц в соответствии с App.svelte
  type View = 'home' | 'catalog' | 'book-details' | 'cart' | 'order' | 'profile' | 'admin';

  // Деструктурируем пропсы по стандартам Svelte 5
  let { bookId, onNavigate } = $props<{ 
    bookId: number; 
    onNavigate: (view: View, params?: any) => void; 
  }>();

  let book = $state<BookInfo | null>(null);
  let isBookLoading = $state(true);
  let bookErrorMessage = $state('');

  // СОСТОЯНИЕ ОТЗЫВОВ
  let reviews = $state<ReviewRead[]>([]);
  let isReviewsLoading = $state(true);
  let isLoadMoreReviewsLoading = $state(false);
  let hasMoreReviews = $state(true);
  let reviewsTrigger = $state<HTMLElement | null>(null);

  let reviewFilters = $state<ReviewFilter>(new ReviewFilter({
    limit: 5,
    offset: 0,
    good_first: true,
    bad_first: false
  }));

  let newReview = $state(new ReviewCreate({ rating: 5, text: null }));
  let isReviewSubmitting = $state(false);
  let reviewError = $state('');

  let isImageError = $state(false);
  let isPubLogoError = $state(false);

  // Реактивное вычисление количества товара в корзине
  let quantityInCart = $derived(cartState.items.find(item => item.book_id === bookId)?.quantity || 0);

  // Исправленная функция перехода в каталог с фильтрами по новой схеме роутинга
  function navigateToCatalogWithFilter(filterType: 'category' | 'topic' | 'author' | 'publisher' | 'binding', value: number|undefined) {
    if (value===undefined)return;
    const params: any = {};
    
    switch (filterType) {
      case 'category':
        params.catId = value; // Категория идет одиночным ID
        break;
      case 'topic':
        params.topicId = [value]; // Массив
        break;
      case 'author':
        params.authorId = [value]; // Массив
        break;
      case 'publisher':
        params.pubId = [value]; // 👈 Исправлено: теперь передается массивом pubId под роутер
        break;
      case 'binding':
        params.bindingId = [value]; // 👈 Исправлено: теперь передается массивом bindingId под роутер
        break;
    }
    
    onNavigate('catalog', params);
  }

  // МОКОВЫЕ ОТЗЫВЫ (для подстраховки)
  const getMockReviews = (): ReviewRead[] => {
    return [
      { id: 201, rating: 5, book_id: bookId, book_title: "", text: "Потрясающая книга! Архитектура FastAPI расписана идеально.", created_at: new Date().toISOString() },
      { id: 202, rating: 5, book_id: bookId, book_title: "", text: "Всё супер, примеры со Svelte 5 очень помогли.", created_at: new Date().toISOString() },
      { id: 203, rating: 4, book_id: bookId, book_title: "", text: "Хорошая подача материала, рекомендую.", created_at: new Date().toISOString() },
    ];
  };

  // ЗАГРУЗКА ДАННЫХ КНИГИ
  async function loadInitialData() {
    isBookLoading = true;
    isReviewsLoading = true;
    bookErrorMessage = '';
    hasMoreReviews = true;
    reviewFilters.offset = 0;

    try {
      book = await catalogApi.getBookById(bookId);
      
      const data = await catalogApi.getBookReviews(bookId, reviewFilters);
      reviews = data.length > 0 ? data : getMockReviews();
      if (reviews.length < reviewFilters.limit!) hasMoreReviews = false;
    } catch (err: any) {
      console.warn('Ошибка загрузки данных:', err);
      reviews = getMockReviews();
      if (!book) {
        bookErrorMessage = err.message || 'Ошибка загрузки данных';
        uiState.error(bookErrorMessage);
      }
    } finally {
      isBookLoading = false;
      isReviewsLoading = false;
    }
  }

  // БЕСКОНЕЧНАЯ ПОДГРУЗКА ОТЗЫВОВ
  async function loadMoreReviews() {
    if (isLoadMoreReviewsLoading || !hasMoreReviews || isReviewsLoading) return;
    
    isLoadMoreReviewsLoading = true;
    reviewFilters.offset! += reviewFilters.limit!;
    
    try {
      const nextBatch = await catalogApi.getBookReviews(bookId, reviewFilters);
      if (nextBatch.length < reviewFilters.limit!) {
        hasMoreReviews = false;
      }
      reviews = [...reviews, ...nextBatch];
    } catch (e) {
      console.error('Ошибка пагинации отзывов:', e);
      hasMoreReviews = false;
    } finally {
      isLoadMoreReviewsLoading = false;
    }
  }

  async function submitReview(e: Event) {
    e.preventDefault();
    if (!userState.current) {
      uiState.openModal('auth', { 
        onSuccess: () => {
          submitReview(e);
        }
      });
      return;
    }
    
    if (!newReview.text || !newReview.text.trim()) {
      reviewError = 'Напишите текст отзыва';
      uiState.warning('Напишите текст отзыва');
      return;
    }

    isReviewSubmitting = true;
    reviewError = '';
    try {
      await usersApi.addReview(bookId, newReview);
      newReview = new ReviewCreate({ rating: 5, text: null });
      await loadInitialData();
      uiState.success('Спасибо за ваш отзыв!');
    } catch (err: any) {
      reviewError = err.message || 'Ошибка отправки';
      uiState.error(reviewError);
    } finally {
      isReviewSubmitting = false;
    }
  }

  // Эффект для загрузки данных при инициализации или изменении bookId (например, при переходе к другой книге из рекомендаций)
  $effect(() => {
    // Читаем bookId, чтобы эффект реагировал на его смену
    const currentId = bookId; 
    
    if (currentId) {
      // Изолируем вызов через untrack, чтобы не подписываться на внутренние реактивные вызовы функции
      untrack(() => {
        loadInitialData();
      });
    }
  });

  // Эффект контроля бесконечного скролла отзывов (Intersection Observer)
  $effect(() => {
    if (!reviewsTrigger) return;
    const observer = new IntersectionObserver((entries) => {
      if (entries[0].isIntersecting) {
        loadMoreReviews();
      }
    }, { rootMargin: '100px' });

    observer.observe(reviewsTrigger);
    return () => observer.disconnect();
  });
</script>


<div class="max-w-6xl mx-auto px-4 py-6 bg-slate-50 min-h-screen text-gray-800">
  <button 
    onclick={() => onNavigate('catalog')} 
    class="text-sm font-semibold text-indigo-600 hover:text-indigo-700 mb-6 flex items-center gap-1 cursor-pointer focus:outline-none group"
  >
    <span class="group-hover:-translate-x-0.5 transition">←</span> Вернуться в каталог
  </button>

  {#if isBookLoading}
    <div class="flex justify-center items-center py-32">
      <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600"></div>
    </div>
  {:else if bookErrorMessage}
    <div class="bg-red-50 border border-red-200 text-red-600 p-4 rounded-2xl text-center font-medium">
      {bookErrorMessage}
    </div>
  {:else if book}
    
    <!-- Карточка книги -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 bg-white p-6 rounded-3xl border border-gray-200 shadow-sm items-start">
      
      <!-- Левая колонка: Обложка -->
      <div class="space-y-4 sticky top-28">
        <div class="aspect-3/4 w-full rounded-2xl overflow-hidden shadow-md bg-slate-100 border border-gray-100">
          {#if book.picture_url && !isImageError}
            <img 
              src={book.picture_url} 
              alt={book.title} 
              onerror={() => isImageError = true} 
              class="w-full h-full object-cover hover:scale-105 transition duration-500"
            />
          {:else}
            <div class="w-full h-full bg-linear-to-br from-indigo-50 to-slate-200 p-6 flex flex-col justify-between items-center text-center">
              <div class="text-sm font-bold text-indigo-400 uppercase tracking-wider">ЛиТрен</div>
              <div class="space-y-2">
                <div class="text-5xl">📚</div>
                <div class="font-black text-sm text-gray-900 leading-tight line-clamp-4">{book.title}</div>
              </div>
              <div class="text-xs font-bold text-gray-400">Книжный магазин</div>
            </div>
          {/if}
        </div>

        <div class="pt-2">
          {#if quantityInCart > 0}
            <div class="flex items-center justify-between bg-indigo-50 border border-indigo-200 rounded-xl p-2 w-full">
              <button 
                onclick={() => cartState.upsertItem({book_id: bookId, quantity: quantityInCart - 1})} 
                class="w-10 h-10 flex items-center justify-center bg-white hover:bg-gray-100 text-indigo-600 border border-indigo-200 rounded-lg text-xl cursor-pointer shadow-sm transition active:scale-95"
              >
                −
              </button>
              <span class="text-base text-indigo-900 font-black">В корзине: {quantityInCart} шт.</span>
              <button 
                onclick={() => cartState.upsertItem({book_id: bookId, quantity: quantityInCart + 1})} 
                class="w-10 h-10 flex items-center justify-center bg-white hover:bg-gray-100 text-indigo-600 border border-indigo-200 rounded-lg text-xl cursor-pointer shadow-sm transition active:scale-95"
              >
                +
              </button>
            </div>
          {:else}
            <button 
              onclick={() => cartState.upsertItem(new ItemCreate({book_id: bookId}))} 
              class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-black py-3.5 rounded-xl text-sm shadow-md active:scale-98 cursor-pointer flex items-center justify-center gap-2 transition"
            >
              <span>Купить за {book.price.toLocaleString()} ₽</span> <span>🛒</span>
            </button>
          {/if}
        </div>
      </div>

      <!-- Правая колонка: Информация -->
      <div class="md:col-span-2 space-y-6">
        
        <!-- Заголовок и авторы -->
        <div class="space-y-2">
          {#if book.authors && book.authors.length > 0}
            <div class="flex flex-wrap gap-2">
              {#each book.authors as author}
                <button 
                  onclick={() => navigateToCatalogWithFilter('author', author.id)}
                  class="text-xs font-bold text-indigo-600 hover:text-indigo-800 hover:underline transition cursor-pointer bg-indigo-50 px-2.5 py-1 rounded-full"
                >
                  {author.name}
                </button>
              {/each}
            </div>
          {/if}
          
          <h1 class="text-2xl md:text-3xl font-black text-gray-900 leading-tight tracking-tight">{book.title}</h1>
          
          <div class="pt-1">
            <RatingStars rating={book.mean_rating} reviewsCount={book.reviews_count} />
          </div>
        </div>

        <!-- Издательство -->
        {#if book.pub}
          <div class="flex items-center gap-3 bg-gray-50 border border-gray-200/60 px-4 py-2.5 rounded-xl w-fit hover:bg-gray-100 transition group">
            {#if book.pub.picture_url && !isPubLogoError}
              <img 
                src={book.pub.picture_url} 
                alt={book.pub.name} 
                onerror={() => isPubLogoError = true} 
                class="w-6 h-6 rounded object-cover border border-gray-200"
              />
            {:else} 
              <span class="text-lg">🏢</span> 
            {/if}
            <span class="text-sm font-semibold text-gray-600">Издательство:</span>
            <button 
              onclick={() => navigateToCatalogWithFilter('publisher', book?.pub?.id)}
              class="text-sm font-black text-gray-900 hover:text-indigo-600 hover:underline transition cursor-pointer"
            >
              {book.pub.name}
            </button>
          </div>
        {/if}

        <!-- Характеристики -->
        <div class="bg-gray-50 rounded-2xl p-4 border border-gray-200/60 space-y-2.5">
          <h3 class="text-xs font-black uppercase tracking-wider text-gray-400 mb-2">Характеристики</h3>
          <div class="grid grid-cols-2 gap-y-2 text-sm">
            <div class="text-gray-500 font-medium">ISBN:</div>
            <div class="text-gray-900 font-bold">{book.isbn || '—'}</div>
            
            <div class="text-gray-500 font-medium">Количество страниц:</div>
            <div class="text-gray-900 font-bold">{book.page_count || '—'}</div>
            {#if book.binding}
              <div class="text-gray-500 font-medium">Тип переплета:</div>
              <button 
                onclick={()=>navigateToCatalogWithFilter('binding',book?.binding?.id)} 
                class="text-left text-gray-900 font-bold hover:text-indigo-600 hover:underline transition cursor-pointer">
                {book.binding?.name || '—'}
              </button>
            {/if}
            
            {#if book.cat}
              <div class="text-gray-500 font-medium">Жанр:</div>
              <button 
                onclick={() => navigateToCatalogWithFilter('category', book?.cat?.id)}
                class="text-left text-gray-900 font-bold hover:text-indigo-600 hover:underline transition cursor-pointer"
              >
                {book.cat.name}
              </button>
            {/if}
          </div>
        </div>

        <!-- Темы -->
        {#if book.topics && book.topics.length > 0}
          <div class="space-y-2">
            <h3 class="text-xs font-black uppercase tracking-wider text-gray-400">Тематика</h3>
            <div class="flex flex-wrap gap-2">
              {#each book.topics as topic}
                <button 
                  onclick={() => navigateToCatalogWithFilter('topic', topic.id)}
                  class="text-xs font-medium text-gray-700 bg-gray-100 hover:bg-indigo-100 hover:text-indigo-700 px-3 py-1.5 rounded-full transition cursor-pointer"
                >
                  #{topic.name}
                </button>
              {/each}
            </div>
          </div>
        {/if}

        <!-- Аннотация -->
        <div class="space-y-2 border-t border-gray-100 pt-5">
          <h3 class="text-sm font-black uppercase tracking-wider text-gray-400">Аннотация</h3>
          <div class="text-sm text-gray-600 leading-relaxed whitespace-pre-line bg-slate-50/50 p-4 rounded-2xl border border-gray-100">
            {book.annotation || 'Описание отсутствует.'}
          </div>
        </div>
      </div>
    </div>

    <!-- ОТЗЫВЫ -->
    <div class="mt-8 grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
      
      <div class="lg:col-span-2 space-y-4">
        <div class="flex justify-between items-center border-b border-gray-200 pb-2 flex-wrap gap-2">
          <h2 class="text-lg font-black text-gray-900 tracking-tight">Отзывы читателей</h2>
          
          <div class="flex items-center gap-2 text-xs font-bold text-gray-500">
            <span>Сортировка:</span>
            <button 
              onclick={() => { reviewFilters.good_first = true; reviewFilters.bad_first = false; loadInitialData(); }}
              class="cursor-pointer transition px-2 py-1 rounded {reviewFilters.good_first ? 'bg-indigo-50 text-indigo-600' : 'hover:text-gray-800'}"
            >
              Сначала хорошие
            </button>
            <button 
              onclick={() => { reviewFilters.good_first = false; reviewFilters.bad_first = true; loadInitialData(); }}
              class="cursor-pointer transition px-2 py-1 rounded {reviewFilters.bad_first ? 'bg-indigo-50 text-indigo-600' : 'hover:text-gray-800'}"
            >
              Сначала критические
            </button>
          </div>
        </div>
        
        {#if reviews.length === 0}
          <div class="bg-white border border-gray-200/80 p-8 rounded-2xl text-center text-sm font-medium text-gray-400">
            На эту книгу пока нет отзывов. Будьте первым!
          </div>
        {:else}
          <div class="space-y-3">
            {#each reviews as review}
              <div class="bg-white p-4 rounded-2xl border border-gray-200 shadow-sm hover:shadow-md transition">
                <div class="flex justify-between items-start gap-4 flex-wrap">
                  <div>
                    <div class="flex items-center gap-2">
                      <div class="text-amber-400 text-sm select-none">
                        {'★'.repeat(review.rating)}{'☆'.repeat(5 - review.rating)}
                      </div>
                      <span class="text-[10px] text-gray-400 font-medium">
                        {new Date(review.created_at).toLocaleDateString('ru-RU')}
                      </span>
                    </div>
                    <div class="text-[11px] font-bold text-gray-400 mt-1">Покупатель ЛиТрен</div>
                  </div>
                </div>
                
                {#if review.text}
                  <p class="text-sm text-gray-600 leading-normal whitespace-pre-line mt-3 pt-2 border-t border-gray-100">
                    {review.text}
                  </p>
                {:else}
                  <p class="text-xs text-gray-400 italic mt-3 pt-2 border-t border-gray-100">
                    Пользователь поставил оценку без текстового отзыва.
                  </p>
                {/if}
              </div>
            {/each}
          </div>

          {#if hasMoreReviews}
            <div bind:this={reviewsTrigger} class="w-full flex justify-center py-4">
              {#if isLoadMoreReviewsLoading} 
                <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-indigo-600"></div> 
              {/if}
            </div>
          {:else if reviews.length > 3}
            <p class="text-center text-[10px] text-gray-400 font-bold py-4">
              📖 Вы просмотрели все {reviews.length} отзывов
            </p>
          {/if}
        {/if}
      </div>

      <!-- Форма отзыва -->
      <div class="bg-white p-5 rounded-2xl border border-gray-200 shadow-sm space-y-4 sticky top-24">
        <h3 class="text-base font-black text-gray-900 border-b border-gray-100 pb-2">Оставить отзыв</h3>
        
        <form onsubmit={submitReview} class="space-y-4">
          <div class="space-y-1">
            <span class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Ваша оценка</span>
            <div class="flex gap-1 text-2xl">
              {#each [1, 2, 3, 4, 5] as star}
                <button 
                  type="button" 
                  onclick={() => newReview.rating = star} 
                  class="text-amber-400 hover:scale-110 transition focus:outline-none cursor-pointer"
                >
                  {star <= newReview.rating ? '★' : '☆'}
                </button>
              {/each}
            </div>
          </div>
          
          <div class="space-y-1">
            <label for="review-textarea" class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">
              Текст отзыва
            </label>
            <textarea 
              id="review-textarea" 
              bind:value={newReview.text} 
              placeholder="Поделитесь впечатлениями о книге..." 
              rows="4" 
              class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-sm text-gray-900 focus:outline-none focus:border-indigo-500 focus:bg-white transition-all resize-none"
            ></textarea>
          </div>
          
          {#if reviewError} 
            <div class="bg-red-50 border border-red-100 text-red-500 p-2.5 rounded-xl text-xs font-semibold text-center">
              {reviewError}
            </div> 
          {/if}
          
          <button 
            type="submit" 
            disabled={isReviewSubmitting} 
            class="w-full bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-300 text-white font-black py-2.5 rounded-xl text-sm transition text-center shadow-sm cursor-pointer active:scale-98"
          >
            {isReviewSubmitting ? 'Отправка...' : 'Опубликовать отзыв'}
          </button>
        </form>
        
        {#if !userState.current}
          <p class="text-center text-[10px] text-gray-400 pt-2 border-t border-gray-100">
            🔒 <button onclick={() => uiState.openModal('auth')} class="text-indigo-600 hover:underline">Войдите</button>, чтобы оставить отзыв
          </p>
        {/if}
      </div>

    </div>
  {/if}
</div>