<script lang="ts">
  import { onMount } from 'svelte';
  import { catalogApi } from '../../api/catalog';
  import { AuthorCreate, PubCreate, AuthorUpdate, PubUpdate } from '../../types/catalog';
  import type { AuthorRead, PubRead, AuthorInfo, PubInfo } from '../../types/catalog';
  import { uiState } from '../../states/ui.svelte';

  // Списки (Read-сущности)
  let authors = $state<AuthorRead[]>([]);
  let publishers = $state<PubRead[]>([]);
  
  let isLoading = $state(true);

  // Состояния для модалки
  let isModalOpen = $state(false);
  let modalMode = $state<'create' | 'edit'>('create');
  let modalType = $state<'author' | 'publisher'>('author');
  let currentId = $state<number | null>(null);
  
  // Формы
  let authorForm = $state(new AuthorCreate({ name: '', bio: null }));
  let pubForm = $state(new PubCreate({ name: '', info: null }));

  // Загрузка списков
  async function loadData() {
    isLoading = true;
    try {
      const [authorsData, publishersData] = await Promise.all([
        catalogApi.getAuthors().catch(() => []),
        catalogApi.getPubs().catch(() => [])
      ]);
      authors = authorsData;
      publishers = publishersData;
    } catch (e) {
      console.error(e);
      uiState.error('Ошибка загрузки данных');
    } finally {
      isLoading = false;
    }
  }

  // Загрузка полной Info-сущности для редактирования
  async function loadAuthorForEdit(id: number) {
    try {
      uiState.startGlobalLoading();
      const fullAuthor = await catalogApi.getAuthor(id);
      authorForm = new AuthorCreate({
        name: fullAuthor.name,
        bio: fullAuthor.bio
      });
      currentId = id;
      modalMode = 'edit';
      modalType = 'author';
      isModalOpen = true;
    } catch (e: any) {
      uiState.error(e.message || 'Не удалось загрузить данные автора');
    } finally {
      uiState.stopGlobalLoading();
    }
  }

  async function loadPublisherForEdit(id: number) {
    try {
      uiState.startGlobalLoading();
      const fullPublisher = await catalogApi.getPub(id);
      pubForm = new PubCreate({
        name: fullPublisher.name,
        info: fullPublisher.info
      });
      currentId = id;
      modalMode = 'edit';
      modalType = 'publisher';
      isModalOpen = true;
    } catch (e: any) {
      uiState.error(e.message || 'Не удалось загрузить данные издательства');
    } finally {
      uiState.stopGlobalLoading();
    }
  }

  // Создание
  function openCreateAuthor() {
    authorForm = new AuthorCreate({ name: '', bio: null });
    modalMode = 'create';
    modalType = 'author';
    currentId = null;
    isModalOpen = true;
  }

  function openCreatePublisher() {
    pubForm = new PubCreate({ name: '', info: null });
    modalMode = 'create';
    modalType = 'publisher';
    currentId = null;
    isModalOpen = true;
  }

  // Сохранение
  async function saveAuthor() {
    if (!authorForm.name.trim()) {
      uiState.warning('Введите имя автора');
      return;
    }
    
    try {
      if (modalMode === 'edit' && currentId) {
        const updateData = new AuthorUpdate({
          name: authorForm.name,
          bio: authorForm.bio
        });
        await catalogApi.updateAuthor(currentId, updateData);
        uiState.success('Автор успешно обновлён');
      } else {
        await catalogApi.addAuthor(authorForm);
        uiState.success('Автор успешно добавлен');
      }
      isModalOpen = false;
      await loadData();
    } catch (e: any) {
      uiState.error(e.message || 'Ошибка сохранения');
    }
  }

  async function savePublisher() {
    if (!pubForm.name.trim()) {
      uiState.warning('Введите название издательства');
      return;
    }
    
    try {
      if (modalMode === 'edit' && currentId) {
        const updateData = new PubUpdate({
          name: pubForm.name,
          info: pubForm.info
        });
        await catalogApi.updatePub(currentId, updateData);
        uiState.success('Издательство успешно обновлено');
      } else {
        await catalogApi.addPub(pubForm);
        uiState.success('Издательство успешно добавлено');
      }
      isModalOpen = false;
      await loadData();
    } catch (e: any) {
      uiState.error(e.message || 'Ошибка сохранения');
    }
  }

  // Удаление
  async function deleteAuthor(id: number, name: string) {
    uiState.openModal('confirm', {
      title: 'Удаление автора',
      message: `Вы уверены, что хотите удалить автора "${name}"?`,
      confirmText: 'Да, удалить',
      cancelText: 'Отмена',
      onConfirm: async () => {
        try {
          await catalogApi.deleteAuthor(id);
          await loadData();
          uiState.success('Автор удалён');
        } catch (e: any) {
          uiState.error(e.message || 'Не удалось удалить автора');
          throw e;
        }
      }
    });
  }

  async function deletePublisher(id: number, name: string) {
    uiState.openModal('confirm', {
      title: 'Удаление издательства',
      message: `Вы уверены, что хотите удалить издательство "${name}"?`,
      confirmText: 'Да, удалить',
      cancelText: 'Отмена',
      onConfirm: async () => {
        try {
          await catalogApi.deletePub(id);
          await loadData();
          uiState.success('Издательство удалено');
        } catch (e: any) {
          uiState.error(e.message || 'Не удалось удалить издательство');
          throw e;
        }
      }
    });
  }

  onMount(() => {
    loadData();
  });
</script>

<div>
  <!-- Заголовок и кнопки -->
  <div class="flex flex-wrap justify-between items-center gap-3 mb-6">
    <h2 class="text-xl font-black text-gray-900 tracking-tight">Управление авторами и издательствами</h2>
    <div class="flex gap-2">
      <button 
        onclick={openCreateAuthor} 
        class="bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-black px-4 py-2 rounded-xl transition shadow-xs cursor-pointer"
      >
        + Добавить автора
      </button>
      <button 
        onclick={openCreatePublisher} 
        class="bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-black px-4 py-2 rounded-xl transition shadow-xs cursor-pointer"
      >
        + Добавить издательство
      </button>
    </div>
  </div>

  {#if isLoading}
    <div class="p-12 text-center text-sm font-bold text-gray-400 animate-pulse">Загрузка данных...</div>
  {:else}
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      
      <!-- БЛОК АВТОРОВ -->
      <div class="bg-white border border-gray-200 rounded-2xl shadow-sm overflow-hidden flex flex-col">
        <div class="p-4 border-b border-gray-100 bg-gradient-to-r from-indigo-50 to-white sticky top-0">
          <h3 class="font-black text-base text-gray-800 flex items-center gap-2">
            <span class="text-xl">✍️</span> Авторы
            <span class="text-xs font-normal text-gray-400 ml-auto">{authors.length} {authors.length === 1 ? 'автор' : (authors.length >= 2 && authors.length <= 4 ? 'автора' : 'авторов')}</span>
          </h3>
        </div>

        <div class="divide-y divide-gray-100 max-h-[500px] overflow-y-auto">
          {#if authors.length === 0}
            <div class="text-center py-12 text-gray-400 text-sm">
              Нет авторов. Добавьте первого!
            </div>
          {:else}
            {#each authors as author}
              <div class="flex items-center justify-between gap-3 p-4 hover:bg-gray-50 transition group">
                <div class="flex-1 min-w-0">
                  <p class="font-bold text-gray-900 text-sm truncate">{author.name}</p>
                  <p class="text-[11px] text-gray-400 mt-0.5">ID: {author.id}</p>
                </div>
                <div class="flex gap-1 opacity-0 group-hover:opacity-100 transition">
                  <button 
                    onclick={() => loadAuthorForEdit(author.id)} 
                    class="px-3 py-1.5 text-xs font-bold text-indigo-600 hover:text-indigo-800 hover:bg-indigo-50 rounded-lg transition cursor-pointer"
                    title="Редактировать"
                  >
                    ✏️ Изменить
                  </button>
                  <button 
                    onclick={() => deleteAuthor(author.id, author.name)} 
                    class="px-3 py-1.5 text-xs font-bold text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg transition cursor-pointer"
                    title="Удалить"
                  >
                    🗑️ Удалить
                  </button>
                </div>
              </div>
            {/each}
          {/if}
        </div>
      </div>

      <!-- БЛОК ИЗДАТЕЛЬСТВ -->
      <div class="bg-white border border-gray-200 rounded-2xl shadow-sm overflow-hidden flex flex-col">
        <div class="p-4 border-b border-gray-100 bg-linear-to-r from-emerald-50 to-white sticky top-0">
          <h3 class="font-black text-base text-gray-800 flex items-center gap-2">
            <span class="text-xl">🏢</span> Издательства
            <span class="text-xs font-normal text-gray-400 ml-auto">{publishers.length} {publishers.length === 1 ? 'издательство' : (publishers.length >= 2 && publishers.length <= 4 ? 'издательства' : 'издательств')}</span>
          </h3>
        </div>

        <div class="divide-y divide-gray-100 max-h-125 overflow-y-auto">
          {#if publishers.length === 0}
            <div class="text-center py-12 text-gray-400 text-sm">
              Нет издательств. Добавьте первое!
            </div>
          {:else}
            {#each publishers as pub}
              <div class="flex items-center justify-between gap-3 p-4 hover:bg-gray-50 transition group">
                <div class="flex-1 min-w-0">
                  <p class="font-bold text-gray-900 text-sm truncate">{pub.name}</p>
                  <p class="text-[11px] text-gray-400 mt-0.5">ID: {pub.id}</p>
                </div>
                <div class="flex gap-1 opacity-0 group-hover:opacity-100 transition">
                  <button 
                    onclick={() => loadPublisherForEdit(pub.id)} 
                    class="px-3 py-1.5 text-xs font-bold text-emerald-600 hover:text-emerald-800 hover:bg-emerald-50 rounded-lg transition cursor-pointer"
                    title="Редактировать"
                  >
                    ✏️ Изменить
                  </button>
                  <button 
                    onclick={() => deletePublisher(pub.id, pub.name)} 
                    class="px-3 py-1.5 text-xs font-bold text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg transition cursor-pointer"
                    title="Удалить"
                  >
                    🗑️ Удалить
                  </button>
                </div>
              </div>
            {/each}
          {/if}
        </div>
      </div>

    </div>
  {/if}

  <!-- МОДАЛЬНОЕ ОКНО ФОРМЫ -->
  {#if isModalOpen}
    <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 animate-fade-in p-4">
      <div class="bg-white rounded-2xl shadow-xl max-w-md w-full overflow-hidden animate-scale-in">
        
        <div class="flex justify-between items-center p-5 border-b border-gray-100 bg-gray-50">
          <h3 class="text-base font-black text-gray-900">
            {#if modalType === 'author'}
              {modalMode === 'create' ? '✍️ Добавить автора' : '✏️ Редактировать автора'}
            {:else}
              {modalMode === 'create' ? '🏢 Добавить издательство' : '✏️ Редактировать издательство'}
            {/if}
          </h3>
          <button type="button" onclick={() => isModalOpen = false} class="text-gray-400 hover:text-gray-600 text-lg cursor-pointer">✕</button>
        </div>
        
        <div class="p-5 space-y-4">
          {#if modalType === 'author'}
            <div class="space-y-1">
              <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Имя автора *</label>
              <input 
                type="text" 
                bind:value={authorForm.name} 
                placeholder="Например: Лев Толстой" 
                class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-sm font-semibold focus:outline-none focus:border-indigo-500 focus:bg-white transition-all"
              />
            </div>
            <div class="space-y-1">
              <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Биография</label>
              <textarea 
                bind:value={authorForm.bio} 
                rows="4" 
                placeholder="Краткая информация об авторе..." 
                class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-sm resize-none focus:outline-none focus:border-indigo-500 focus:bg-white transition-all"
              ></textarea>
            </div>
          {:else}
            <div class="space-y-1">
              <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Название издательства *</label>
              <input 
                type="text" 
                bind:value={pubForm.name} 
                placeholder="Например: Эксмо" 
                class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-sm font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all"
              />
            </div>
            <div class="space-y-1">
              <label class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">Информация</label>
              <textarea 
                bind:value={pubForm.info} 
                rows="4" 
                placeholder="Дополнительная информация об издательстве..." 
                class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-sm resize-none focus:outline-none focus:border-emerald-500 focus:bg-white transition-all"
              ></textarea>
            </div>
          {/if}
        </div>

        <div class="p-5 border-t border-gray-100 bg-gray-50 flex justify-end gap-3">
          <button type="button" onclick={() => isModalOpen = false} class="border border-gray-200 bg-white text-gray-700 font-bold px-4 py-2 rounded-xl cursor-pointer hover:bg-gray-50 transition text-sm">
            Отмена
          </button>
          <button 
            type="button" 
            onclick={modalType === 'author' ? saveAuthor : savePublisher}
            class="bg-indigo-600 hover:bg-indigo-700 text-white font-black px-5 py-2 rounded-xl shadow-xs cursor-pointer transition text-sm"
          >
            {modalMode === 'create' ? 'Создать' : 'Сохранить'}
          </button>
        </div>

      </div>
    </div>
  {/if}
</div>

<style>
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
</style>