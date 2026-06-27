<!-- src/components/ChatSearch.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { catalogApi } from '../api/catalog';
  import { uiState } from '../states/ui.svelte';
  import type { BookRead } from '../types/catalog';

  let isOpen = $state(false);
  let query = $state('');
  let isLoading = $state(false);
  let messages = $state<{ role: 'user' | 'assistant', content: string, books?: BookRead[] }[]>([]);
  
  // Рефы для авто-высоты textarea
  let textareaRef: HTMLTextAreaElement | null = null;
  
  // Лимит токенов (примерная оценка: 1 токен ≈ 0.75 символа для русского)
  const MAX_TOKENS = 64;
  let charCount = $derived(query.length);
  let tokenEstimate = $derived(Math.ceil(query.length / 0.75));
  let isOverLimit = $derived(tokenEstimate > MAX_TOKENS);

  // Функция для оценки токенов
  function estimateTokens(text: string): number {
    const cyrillicChars = (text.match(/[а-яА-ЯёЁ]/g) || []).length;
    const otherChars = text.length - cyrillicChars;
    return Math.ceil(cyrillicChars / 0.75 + otherChars / 4);
  }

  // Проверка и обрезка текста
  function truncateToTokenLimit(text: string): string {
    let truncated = text;
    while (estimateTokens(truncated) > MAX_TOKENS && truncated.length > 0) {
      truncated = truncated.slice(0, -1);
    }
    return truncated;
  }

  function handleInput(e: Event) {
    const target = e.target as HTMLTextAreaElement;
    let value = target.value;
    
    if (estimateTokens(value) > MAX_TOKENS) {
      value = truncateToTokenLimit(value);
      uiState.warning(`Запрос превышает лимит в ${MAX_TOKENS} токенов. Текст обрезан.`);
    }
    
    query = value;
    
    if (textareaRef) {
      textareaRef.style.height = 'auto';
      textareaRef.style.height = Math.min(textareaRef.scrollHeight, 120) + 'px';
    }
  }

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      if (!isLoading && query.trim() && !isOverLimit) {
        sendMessage();
      }
    }
  }

  onMount(() => {
    const saved = localStorage.getItem('chatSearchHistory');
    if (saved) {
      try {
        messages = JSON.parse(saved);
      } catch (e) {}
    }
  });

  function saveHistory() {
    const toSave = messages.slice(-10);
    localStorage.setItem('chatSearchHistory', JSON.stringify(toSave));
  }

  async function sendMessage() {
    if (!query.trim()) return;
    if (isOverLimit) {
      uiState.warning(`Запрос превышает лимит в ${MAX_TOKENS} токенов. Сократите текст.`);
      return;
    }
    
    const currentQuery = query.trim();
    
    messages = [...messages, { role: 'user', content: currentQuery }];
    query = '';
    
    if (textareaRef) {
      textareaRef.style.height = 'auto';
    }
    
    isLoading = true;
    
    try {
      // ✅ Используем API метод вместо прямого fetch
      const books = await catalogApi.getBooksByQuery(currentQuery);
      
      let assistantContent = '';
      if (!books || books.length === 0) {
        assistantContent = '😔 Не нашёл книг по вашему запросу. Попробуйте переформулировать или использовать другие слова.';
      } else if (books.length === 1) {
        assistantContent = '📚 Нашёл одну книгу, которая может вам подойти:';
      } else {
        assistantContent = `📚 Нашёл ${books.length} книг, которые могут вам подойти:`;
      }
      
      const assistantMessage = {
        role: 'assistant' as const,
        content: assistantContent,
        books: books
      };
      messages = [...messages, assistantMessage];
      saveHistory();
      
    } catch (err: any) {
      console.error(err);
      messages = [...messages, { 
        role: 'assistant', 
        content: '❌ Извините, произошла ошибка при поиске. Попробуйте позже.' 
      }];
      uiState.error(err.message || 'Ошибка поиска');
    } finally {
      isLoading = false;
    }
  }

  function clearHistory() {
    messages = [];
    localStorage.removeItem('chatSearchHistory');
    uiState.success('История поиска очищена');
  }

  function goToBook(bookId: number) {
    window.location.hash = `#books/${bookId}`;
    isOpen = false;
  }

  const examples = [
    'книга чтобы разбогатеть',
    'детектив про маньяка в Питере',
    'научпоп про мозг и нейроны',
    'романтика про любовь в Париже',
    'фэнтези про попаданца',
    'бизнес книга по маркетингу'
  ];

  function useExample(example: string) {
    query = example;
    sendMessage();
  }

  function getTokenColor() {
    if (isOverLimit) return 'text-red-500';
    if (tokenEstimate > MAX_TOKENS * 0.8) return 'text-amber-500';
    return 'text-gray-400';
  }
</script>

<!-- Кнопка-триггер -->
<button
  onclick={() => isOpen = !isOpen}
  class="fixed bottom-6 right-6 w-14 h-14 bg-linear-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 rounded-full shadow-lg flex items-center justify-center text-white text-2xl transition-all z-50 cursor-pointer group"
>
  {#if isOpen}
    <span class="text-xl">✕</span>
  {:else}
    <span class="group-hover:scale-110 transition">💬</span>
    <span class="absolute -top-1 -right-1 w-3 h-3 bg-green-500 rounded-full animate-pulse"></span>
  {/if}
</button>

<!-- Виджет чата -->
{#if isOpen}
  <div class="fixed bottom-24 right-6 w-96 max-w-[calc(100vw-2rem)] h-150 bg-white rounded-2xl shadow-2xl border border-gray-200 flex flex-col z-50 overflow-hidden animate-slide-up">
    
    <!-- Шапка -->
    <div class="p-4 bg-linear-to-r from-indigo-600 to-purple-600 text-white shrink-0">
      <div class="flex justify-between items-center">
        <div>
          <h3 class="font-bold flex items-center gap-1">
            <span>🧠</span> Умный поиск книг
          </h3>
          <p class="text-xs opacity-90">Опишите словами, что хотите почитать</p>
        </div>
        <button 
          onclick={clearHistory}
          class="text-xs text-white/80 hover:text-white transition p-1"
          title="Очистить историю"
        >
          🗑️
        </button>
      </div>
    </div>
    
    <!-- Сообщения -->
    <div class="flex-1 overflow-y-auto p-3 space-y-3 bg-gray-50">
      {#if messages.length === 0}
        <div class="text-center text-gray-400 text-sm py-6">
          <div class="text-4xl mb-2">🤖</div>
          <p class="font-medium text-gray-600">Привет! Я помогу найти книги по описанию.</p>
          <p class="text-xs mt-1">Просто напишите, что вы хотите почитать:</p>
          
          <div class="mt-4 space-y-1.5">
            {#each examples as example}
              <button 
                onclick={() => useExample(example)} 
                class="block w-full text-left px-3 py-2 bg-white border border-gray-200 rounded-xl text-xs hover:border-indigo-300 hover:bg-indigo-50 transition text-gray-700"
              >
                " {example} "
              </button>
            {/each}
          </div>
        </div>
      {:else}
        {#each messages as msg}
          <div class="{msg.role === 'user' ? 'flex justify-end' : 'flex justify-start'}">
            <div class="max-w-[85%]">
              <div class="text-xs text-gray-400 mb-0.5 px-1">
                {msg.role === 'user' ? 'Вы' : '🤖 Поиск'}
              </div>
              <div class="{msg.role === 'user' 
                ? 'bg-indigo-600 text-white rounded-br-none' 
                : 'bg-white text-gray-800 border border-gray-200 rounded-bl-none'} rounded-2xl p-2.5 text-sm shadow-sm whitespace-pre-wrap">
                {msg.content}
              </div>
              
              <!-- Результаты поиска (книги) -->
              {#if msg.books && msg.books.length > 0}
                <div class="mt-2 space-y-2">
                  {#each msg.books as book}
                    <button
                      onclick={() => goToBook(book.id)}
                      class="w-full text-left p-2 bg-white border border-gray-200 rounded-xl hover:shadow-md hover:border-indigo-200 transition group"
                    >
                      <div class="flex gap-2">
                        {#if book.picture_url}
                          <img src={book.picture_url} alt={book.title} class="w-10 h-14 object-cover rounded-lg bg-gray-100" />
                        {:else}
                          <div class="w-10 h-14 bg-gray-100 rounded-lg flex items-center justify-center text-lg shrink-0">📚</div>
                        {/if}
                        <div class="flex-1 min-w-0">
                          <div class="font-bold text-sm text-gray-900 group-hover:text-indigo-600 line-clamp-1">
                            {book.title}
                          </div>
                          <div class="text-xs text-gray-500 mt-0.5">
                            {book.price.toLocaleString()} ₽
                          </div>
                          <div class="text-[10px] text-gray-400 mt-0.5">
                            ⭐ {book.mean_rating.toFixed(1)} ({book.reviews_count})
                          </div>
                        </div>
                      </div>
                    </button>
                  {/each}
                </div>
              {/if}
            </div>
          </div>
        {/each}
      {/if}
      
      <!-- Индикатор загрузки -->
      {#if isLoading}
        <div class="flex justify-start">
          <div>
            <div class="text-xs text-gray-400 mb-0.5 px-1">🤖 Поиск</div>
            <div class="bg-white border border-gray-200 rounded-2xl rounded-bl-none p-3 shadow-sm">
              <div class="flex gap-1.5">
                <span class="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style="animation-delay: 0ms"></span>
                <span class="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style="animation-delay: 150ms"></span>
                <span class="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style="animation-delay: 300ms"></span>
              </div>
            </div>
          </div>
        </div>
      {/if}
      
      <!-- Кнопка показать ещё примеров -->
      {#if messages.length > 0 && messages.length < 3}
        <div class="flex justify-center pt-2">
          <button 
            onclick={() => {
              query = examples[Math.floor(Math.random() * examples.length)];
              sendMessage();
            }}
            class="text-xs text-indigo-500 hover:text-indigo-700 bg-white px-3 py-1.5 rounded-full border border-gray-200"
          >
            💡 Попробовать другой запрос
          </button>
        </div>
      {/if}
    </div>
    
    <!-- Поле ввода -->
    <div class="p-3 border-t border-gray-100 bg-white shrink-0">
      <div class="relative">
        <textarea
          bind:this={textareaRef}
          bind:value={query}
          oninput={handleInput}
          onkeydown={handleKeydown}
          placeholder="Например: детектив про маньяка в Питере..."
          rows="1"
          class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 pr-10 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition resize-none overflow-y-auto"
          style="max-height: 120px;"
        ></textarea>
        
        <button
          onclick={sendMessage}
          disabled={isLoading || !query.trim() || isOverLimit}
          class="absolute right-2 bottom-2 bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-300 text-white font-bold w-8 h-8 rounded-lg transition flex items-center justify-center"
        >
          ➤
        </button>
      </div>
      
      <div class="flex justify-between items-center mt-2">
        <div class="flex items-center gap-2">
          <span class="text-[9px] text-gray-400">
            🔤 токены: 
            <span class="font-mono {getTokenColor()}">
              {tokenEstimate}/{MAX_TOKENS}
            </span>
          </span>
          {#if isOverLimit}
            <span class="text-[9px] text-red-500">
              ⚠️ Превышен лимит
            </span>
          {:else if tokenEstimate > MAX_TOKENS * 0.8}
            <span class="text-[9px] text-amber-500">
              ⚡接近 лимита
            </span>
          {/if}
        </div>
        <p class="text-[9px] text-gray-400">
          Shift+Enter для новой строки
        </p>
      </div>
      
      <p class="text-[9px] text-gray-400 text-center mt-1">
        🔍 Поиск по аннотациям книг с помощью AI
      </p>
    </div>
  </div>
{/if}

<style>
  @keyframes slideUp {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  
  @keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-4px); }
  }
  
  .animate-slide-up {
    animation: slideUp 0.2s ease-out;
  }
  
  .animate-bounce {
    animation: bounce 0.6s ease-in-out infinite;
  }
  
  .animate-pulse {
    animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  }
  
  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5;}
  }
  
  textarea::-webkit-scrollbar {
    width: 4px;
  }
  
  textarea::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
  }
  
  textarea::-webkit-scrollbar-thumb {
    background: #c7d2fe;
    border-radius: 4px;
  }
</style>