<!-- src/pages/admin/AdminBookSection.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { catalogApi } from '../../api/catalog';
  import { SortBy, BookCreate, BookUpdate } from '../../types/catalog';
  import type { BookRead, CatRead, AuthorRead, PubRead, BindingRead, TopicRead } from '../../types/catalog';
  import { uiState } from '../../states/ui.svelte';

  let books = $state<BookRead[]>([]);
  let categories = $state<CatRead[]>([]);
  let authors = $state<AuthorRead[]>([]);
  let publishers = $state<PubRead[]>([]);
  let bindings = $state<BindingRead[]>([]);
  let topics = $state<TopicRead[]>([]);

  let isLoading = $state(true);
  let isSubmitting = $state(false);
  let errorMessage = $state('');

  let limit = 10;
  let offset = $state(0);
  let hasMore = $state(true);

  let isModalOpen = $state(false);
  
  // Обложка
  let coverPreview = $state<string | null>(null);
  let coverFile = $state<File | null>(null);
  let isUploadingCover = $state(false);
  
  const createEmptyBookForm = (): any => ({
    id: null,
    title: '',
    price: '',
    isbn: null,
    is_new: false,
    is_bestseller: false,
    annotation: null,
    page_count: null,
    binding_id: null,
    pub_id: null,
    cat_id: null,
    author_ids: [] as number[],
    topic_ids: [] as number[]
  });

  let bookForm = $state<any>(createEmptyBookForm());

  async function loadAdminBooks(append = false) {
    if (!append) isLoading = true;
    try {
      const data = await catalogApi.getBooks({
        limit,
        offset,
        sort_by: SortBy.popularity,
        reverse: false
      });
      if (data.length < limit) hasMore = false;
      books = append ? [...books, ...data] : data;
    } catch (e: any) {
      errorMessage = e.message || 'Ошибка загрузки книг';
    } finally {
      isLoading = false;
    }
  }

  function loadNextPage() {
    offset += limit;
    loadAdminBooks(true);
  }

  async function loadFormDictionaries() {
    try {
      const [catsData, authorsData, pubsData, bindingsData, topicsData] = await Promise.all([
        catalogApi.getCats(),
        catalogApi.getAuthors(),
        catalogApi.getPubs(),
        catalogApi.getBindings(),
        catalogApi.getTopics()
      ]);
      categories = catsData;
      authors = authorsData;
      publishers = pubsData;
      bindings = bindingsData;
      topics = topicsData;
    } catch (e) {
      console.error('Ошибка загрузки справочников:', e);
    }
  }

  function openCreateModal() {
    bookForm = createEmptyBookForm();
    coverPreview = null;
    coverFile = null;
    isModalOpen = true;
  }

  async function openEditModal(bookId: number) {
    try {
      uiState.startGlobalLoading();
      const fullBook = await catalogApi.getBookById(bookId);
      
      bookForm = {
        id: fullBook.id,
        title: fullBook.title,
        price: String(fullBook.price),
        isbn: fullBook.isbn,
        is_new: fullBook.is_new,
        is_bestseller: fullBook.is_bestseller,
        annotation: fullBook.annotation,
        page_count: fullBook.page_count,
        binding_id: fullBook.binding?.id ?? null,
        pub_id: fullBook.pub?.id ?? null,
        cat_id: fullBook.cat?.id ?? null,
        author_ids: fullBook.authors?.map(a => a.id) || [],
        topic_ids: fullBook.topics?.map(t => t.id) || []
      };
      
      coverPreview = fullBook.picture_url;
      coverFile = null;
      
      isModalOpen = true;
    } catch (e) {
      uiState.error('Не удалось загрузить параметры книги');
    } finally {
      uiState.stopGlobalLoading();
    }
  }

  async function deleteBook(id: number) {
    uiState.openModal('confirm', {
      title: 'Удаление книги',
      message: 'Вы уверены, что хотите навсегда удалить эту книгу из каталога?',
      confirmText: 'Да, удалить',
      cancelText: 'Отмена',
      onConfirm: async () => {
        const backup = books;
        books = books.filter(b => b.id !== id);

        try {
          await catalogApi.deleteBook(id);
          uiState.success('Книга успешно удалена');
        } catch (e: any) {
          books = backup;
          uiState.error(e.message || 'Не удалось удалить книгу');
          throw e;
        }
      }
    });
  }

  function toggleAuthor(authorId: number) {
    if (bookForm.author_ids.includes(authorId)) {
      bookForm.author_ids = bookForm.author_ids.filter((id: number) => id !== authorId);
    } else {
      bookForm.author_ids = [...bookForm.author_ids, authorId];
    }
  }

  function toggleTopic(topicId: number) {
    if (bookForm.topic_ids.includes(topicId)) {
      bookForm.topic_ids = bookForm.topic_ids.filter((id: number) => id !== topicId);
    } else {
      bookForm.topic_ids = [...bookForm.topic_ids, topicId];
    }
  }

  // ========== ОБЛОЖКА ==========
  function handleCoverSelect(e: Event) {
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
    
    coverFile = file;
    
    const reader = new FileReader();
    reader.onload = (e) => {
      coverPreview = e.target?.result as string;
    };
    reader.readAsDataURL(file);
  }


  async function uploadCover() {
    if (!bookForm.id || !coverFile) return;
    
    isUploadingCover = true;
    try {
      await catalogApi.uploadBookCover(bookForm.id, coverFile);
      uiState.success('Обложка загружена');
      coverFile = null;
      await loadAdminBooks(false);
    } catch (e: any) {
      uiState.error(e.message || 'Не удалось загрузить обложку');
    } finally {
      isUploadingCover = false;
    }
  }

  async function handleSubmit(e: Event) {
    e.preventDefault();
    isSubmitting = true;
    try {
      const payload: any = {
        title: bookForm.title,
        price: String(bookForm.price),
        isbn: bookForm.isbn || null,
        is_new: bookForm.is_new,
        is_bestseller: bookForm.is_bestseller,
        annotation: bookForm.annotation || null,
        page_count: bookForm.page_count ? Number(bookForm.page_count) : null,
        binding_id: bookForm.binding_id ? Number(bookForm.binding_id) : null,
        pub_id: bookForm.pub_id ? Number(bookForm.pub_id) : null,
        cat_id: bookForm.cat_id ? Number(bookForm.cat_id) : null,
        author_ids: bookForm.author_ids || [],
        topic_ids: bookForm.topic_ids || []
      };

      if (payload.isbn === null) delete payload.isbn;
      if (payload.annotation === null) delete payload.annotation;
      if (payload.page_count === null) delete payload.page_count;
      if (payload.binding_id === null) delete payload.binding_id;
      if (payload.pub_id === null) delete payload.pub_id;
      if (payload.cat_id === null) delete payload.cat_id;

      if (bookForm.id) {
        await catalogApi.updateBook(bookForm.id, payload);
        uiState.success('Книга успешно обновлена');
      } else {
        const result = await catalogApi.addBook(payload);
        bookForm.id = result.id;
        uiState.success('Книга успешно добавлена');
      }
      
      if (coverFile) {
        await uploadCover();
      }
      
      isModalOpen = false;
      offset = 0;
      hasMore = true;
      await loadAdminBooks(false);
    } catch (err: any) {
      console.error('Submit error:', err);
      uiState.error(err.message || 'Ошибка сохранения');
    } finally {
      isSubmitting = false;
    }
  }

  function getCategoryName(catId: number | null): string {
    if (!catId) return '— Не выбрана —';
    const cat = categories.find(c => c.id === catId);
    return cat?.name || '— Не выбрана —';
  }

  onMount(() => {
    loadAdminBooks();
    loadFormDictionaries();
  });
</script>

<div>
  <div class="flex justify-between items-center mb-6">
    <h2 class="text-xl font-black text-gray-900 tracking-tight">Управление каталогом книг</h2>
    <button onclick={openCreateModal} class="bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-black px-4 py-2.5 rounded-xl transition shadow-xs cursor-pointer">
      + Добавить книгу
    </button>
  </div>

  <div class="border border-gray-100 rounded-2xl overflow-hidden bg-white shadow-xs">
    {#if isLoading}
      <div class="p-12 text-center text-sm font-bold text-gray-400 animate-pulse">Загрузка списка книг...</div>
    {:else if errorMessage}
      <div class="p-6 text-center text-xs font-semibold text-red-500 bg-red-50">{errorMessage}</div>
    {:else if books.length === 0}
      <div class="p-12 text-center text-sm font-medium text-gray-400">Каталог пуст.</div>
    {:else}
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs border-collapse">
          <thead>
            <tr class="bg-gray-50 border-b border-gray-100 text-gray-400 uppercase font-bold tracking-wider text-[10px]">
              <th class="p-4 w-16">ID</th>
              <th class="p-4">Обложка</th>
              <th class="p-4">Название книги</th>
              <th class="p-4">Цена</th>
              <th class="p-4">Рейтинг</th>
              <th class="p-4 text-right">Действия</th>
            </tr>
          </thead>
          <tbody>
            {#each books as book}
              <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                <td class="p-4 font-bold text-gray-400">#{book.id}</td>
                <td class="p-4">
                  {#if book.picture_url}
                    <img src={book.picture_url} alt={book.title} class="w-10 h-14 object-cover rounded-lg bg-gray-100" />
                  {:else}
                    <div class="w-10 h-14 bg-gray-100 rounded-lg flex items-center justify-center text-lg">📚</div>
                  {/if}
                </td>
                <td class="p-4">
                  <p class="font-bold text-gray-900 line-clamp-1">{book.title}</p>
                </td>
                <td class="p-4 font-black text-gray-900">{book.price} ₽</td>
                <td class="p-4 text-gray-500 font-bold">⭐ {book.mean_rating.toFixed(1)} ({book.reviews_count})</td>
                <td class="p-4 text-right space-x-3 whitespace-nowrap">
                  <button onclick={() => openEditModal(book.id)} class="text-indigo-600 hover:text-indigo-800 font-bold transition cursor-pointer">
                    Редактировать
                  </button>
                  <button onclick={() => deleteBook(book.id)} class="text-red-500 hover:text-red-700 font-bold transition cursor-pointer">
                    Удалить
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
      {#if hasMore}
        <div class="p-4 bg-gray-50/50 border-t border-gray-50 text-center">
          <button onclick={loadNextPage} class="text-xs font-bold text-gray-600 hover:text-gray-900 cursor-pointer">Показать ещё книги...</button>
        </div>
      {/if}
    {/if}
  </div>

  <!-- МОДАЛЬНОЕ ОКНО ФОРМЫ -->
  {#if isModalOpen}
    <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 animate-fade-in p-4">
      <form onsubmit={handleSubmit} class="bg-white rounded-2xl shadow-xl max-w-2xl w-full overflow-hidden animate-scale-in flex flex-col max-h-[90vh]">
        
        <div class="flex justify-between items-center p-5 border-b border-gray-100 bg-gray-50 shrink-0">
          <h3 class="text-base font-black text-gray-900">
            {bookForm.id ? '📝 Редактировать книгу' : '✨ Добавить книгу'}
          </h3>
          <button type="button" onclick={() => isModalOpen = false} class="text-gray-400 hover:text-gray-600 text-lg cursor-pointer">✕</button>
        </div>
        
        <div class="p-5 overflow-y-auto space-y-4 flex-1 no-scrollbar">
          
          <div class="space-y-1">
            <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block" for="title">Название *</label>
            <input id="title" type="text" required bind:value={bookForm.title} class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 font-semibold focus:outline-none focus:border-indigo-500 focus:bg-white transition-all" />
          </div>

          <div class="grid grid-cols-3 gap-3">
            <div>
              <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block mb-1" for="price">Цена, ₽ *</label>
              <input id="price" type="text" required bind:value={bookForm.price} placeholder="1000" class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 font-bold focus:outline-none focus:border-indigo-500 focus:bg-white transition-all" />
            </div>
            <div>
              <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block mb-1" for="isbn">ISBN код</label>
              <input id="isbn" type="text" bind:value={bookForm.isbn} placeholder="978-5-..." class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 focus:outline-none focus:border-indigo-500 focus:bg-white transition-all" />
            </div>
            <div>
              <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block mb-1" for="pages">Страниц</label>
              <input id="pages" type="number" min="0" bind:value={bookForm.page_count} class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 focus:outline-none focus:border-indigo-500 focus:bg-white transition-all" />
            </div>
          </div>

          <!-- Обложка -->
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Обложка книги</label>
            
            <div class="flex gap-4 items-start">
              <div class="w-24 h-32 bg-gray-100 rounded-xl border border-gray-200 overflow-hidden shrink-0">
                {#if coverPreview}
                  <img src={coverPreview} alt="Обложка" class="w-full h-full object-cover" />
                {:else}
                  <div class="w-full h-full flex items-center justify-center text-3xl text-gray-300">📚</div>
                {/if}
              </div>
              
              <div class="flex-1 space-y-2">
                <label class="block">
                  <span class="text-xs font-medium text-gray-600 bg-gray-100 px-3 py-1.5 rounded-lg cursor-pointer hover:bg-gray-200 transition inline-block">
                    📁 Выбрать изображение
                  </span>
                  <input type="file" accept="image/*" onchange={handleCoverSelect} class="hidden" />
                </label>
                
                {#if coverFile}
                  <p class="text-[10px] text-green-600">✅ Выбрано: {coverFile.name}</p>
                {/if}
                
                <p class="text-[9px] text-gray-400">Поддерживаются JPEG, PNG, WEBP. Максимум 5MB.</p>
              </div>
            </div>
          </div>

          <!-- Категория -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block mb-1" for="category">Категория / Жанр</label>
            <select id="category" bind:value={bookForm.cat_id} class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 cursor-pointer font-medium text-gray-700 focus:outline-none focus:border-indigo-500 focus:bg-white transition-all">
              <option value={null}>— Не выбрана —</option>
              {#each categories as cat}
                <option value={cat.id}>{cat.name}</option>
              {/each}
            </select>
          </div>

          <!-- Издательство и переплёт -->
          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1">
              <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block mb-1" for="pub">Издательство</label>
              <select id="pub" bind:value={bookForm.pub_id} class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 cursor-pointer font-medium text-gray-700 focus:outline-none focus:border-indigo-500 focus:bg-white transition-all">
                <option value={null}>— Не указано —</option>
                {#each publishers as p} <option value={p.id}>{p.name}</option> {/each}
              </select>
            </div>
            <div class="space-y-1">
              <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block mb-1" for="binding">Тип обложки</label>
              <select id="binding" bind:value={bookForm.binding_id} class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 cursor-pointer font-medium text-gray-700 focus:outline-none focus:border-indigo-500 focus:bg-white transition-all">
                <option value={null}>— Не указано —</option>
                {#each bindings as b} <option value={b.id}>{b.name}</option> {/each}
              </select>
            </div>
          </div>

          <!-- Авторы (бейджи) -->
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Авторы</label>
            <div class="flex flex-wrap gap-2 max-h-32 overflow-y-auto p-2 bg-gray-50 rounded-xl border border-gray-200">
              {#each authors as author}
                <button
                  type="button"
                  onclick={() => toggleAuthor(author.id)}
                  class="px-3 py-1.5 rounded-full text-xs font-medium transition-all cursor-pointer
                    {bookForm.author_ids.includes(author.id) 
                      ? 'bg-indigo-600 text-white shadow-md scale-105' 
                      : 'bg-gray-200 text-gray-700 hover:bg-gray-300'}"
                >
                  {author.name}
                  {#if bookForm.author_ids.includes(author.id)}
                    <span class="ml-1 text-white opacity-70">✕</span>
                  {/if}
                </button>
              {/each}
            </div>
            <p class="text-[9px] text-gray-400">Кликните на авторе, чтобы добавить/удалить</p>
          </div>

          <!-- Темы (бейджи) -->
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Темы / Теги</label>
            <div class="flex flex-wrap gap-2 max-h-32 overflow-y-auto p-2 bg-gray-50 rounded-xl border border-gray-200">
              {#each topics as topic}
                <button
                  type="button"
                  onclick={() => toggleTopic(topic.id)}
                  class="px-3 py-1.5 rounded-full text-xs font-medium transition-all cursor-pointer
                    {bookForm.topic_ids.includes(topic.id) 
                      ? 'bg-emerald-600 text-white shadow-md scale-105' 
                      : 'bg-gray-200 text-gray-700 hover:bg-gray-300'}"
                >
                  #{topic.name}
                  {#if bookForm.topic_ids.includes(topic.id)}
                    <span class="ml-1 text-white opacity-70">✕</span>
                  {/if}
                </button>
              {/each}
            </div>
            <p class="text-[9px] text-gray-400">Кликните на теме, чтобы добавить/удалить</p>
          </div>

          <!-- Аннотация -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block" for="annotation">Аннотация</label>
            <textarea id="annotation" rows="3" bind:value={bookForm.annotation} placeholder="Описание книги..." class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 resize-none text-gray-700 focus:outline-none focus:border-indigo-500 focus:bg-white transition-all"></textarea>
          </div>

          <!-- Флаги -->
          <div class="flex items-center gap-6 p-2">
            <label class="flex items-center gap-2 font-bold text-gray-700 cursor-pointer select-none">
              <input type="checkbox" bind:checked={bookForm.is_new} class="rounded text-indigo-600 h-4 w-4 border-gray-300 accent-indigo-600" />
              <span>✨ Новинка</span>
            </label>
            <label class="flex items-center gap-2 font-bold text-gray-700 cursor-pointer select-none">
              <input type="checkbox" bind:checked={bookForm.is_bestseller} class="rounded text-indigo-600 h-4 w-4 border-gray-300 accent-indigo-600" />
              <span>🔥 Бестселлер</span>
            </label>
          </div>

        </div>

        <div class="p-5 border-t border-gray-100 bg-gray-50 flex justify-end gap-3 shrink-0">
          <button type="button" onclick={() => isModalOpen = false} class="border border-gray-200 bg-white text-gray-700 font-bold px-4 py-2 rounded-xl cursor-pointer hover:bg-gray-50 transition text-sm">
            Отмена
          </button>
          <button type="submit" disabled={isSubmitting} class="bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-300 text-white font-black px-5 py-2 rounded-xl shadow-xs cursor-pointer transition text-sm">
            {isSubmitting ? 'Сохранение...' : 'Сохранить книгу'}
          </button>
        </div>

      </form>
    </div>
  {/if}
</div>

<style>
  .no-scrollbar::-webkit-scrollbar { display: none; }
  .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
  
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
  
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
  
  .animate-fade-in {
    animation: fadeIn 0.2s ease-out;
  }
  
  .animate-scale-in {
    animation: scaleIn 0.2s ease-out;
  }
  
  .animate-pulse {
    animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  }
  
  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
  }
</style>