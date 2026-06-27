<script lang="ts">
  import { onMount } from 'svelte';
  import { catalogApi } from '../../api/catalog';
  import { CatCreate, TopicCreate } from '../../types/catalog';
  import type { CatRead, TopicRead, BindingRead } from '../../types/catalog';

  let categories = $state<CatRead[]>([]);
  let topics = $state<TopicRead[]>([]);
  let bindings = $state<BindingRead[]>([]);

  let isLoading = $state(true);

  let newCatForm = $state(new CatCreate({ name: '', parent_id: null }));
  let newTopicName = $state('');
  let newBindingName = $state('');

  async function loadTaxonomy() {
    isLoading = true;
    try {
      const [cats, tops, binds] = await Promise.all([
        catalogApi.getCats(),
        catalogApi.getTopics(),
        catalogApi.getBindings()
      ]);
      categories = cats;
      topics = tops;
      bindings = binds;
    } catch (e) { console.error(e); } finally { isLoading = false; }
  }

  async function addCategory() {
    if (!newCatForm.name.trim()) return;
    try {
      const payload = $state.snapshot(newCatForm);
      // const created = await catalogApi.createCategory(payload);
      const created: CatRead = { id: Date.now(), name: payload.name, parent_id: payload.parent_id, path: payload.name };
      categories = [...categories, created];
      newCatForm = new CatCreate({ name: '', parent_id: null });
    } catch (e) { alert('Ошибка'); }
  }

  async function addTopic() {
    if (!newTopicName.trim()) return;
    try {
      const created: TopicRead = { id: Date.now(), name: newTopicName.trim() };
      topics = [...topics, created];
      newTopicName = '';
    } catch (e) { alert('Ошибка'); }
  }
async function addBinding() {
    if (!newBindingName.trim()) return;
    try {
      const created = { id: Date.now(), name: newBindingName.trim() };
      bindings = [...bindings, created];
      newBindingName = '';
    } catch (e) { alert('Не удалось добавить переплет'); }
  }

  // УДАЛЕНИЕ СУЩНОСТЕЙ (с нативным confirm)
  async function deleteCategory(id: number) {
    if (!confirm('Удалить категорию? Убедитесь, что к ней не привязаны книги!')) return;
    categories = categories.filter(c => c.id !== id);
    // На сервер: await catalogApi.deleteCategory(id);
  }

  async function deleteTopic(id: number) {
    if (!confirm('Удалить тематический тег?')) return;
    topics = topics.filter(t => t.id !== id);
    // На сервер: await catalogApi.deleteTopic(id);
  }

  async function deleteBinding(id: number) {
    if (!confirm('Удалить тип переплета?')) return;
    bindings = bindings.filter(b => b.id !== id);
    // На сервер: await catalogApi.deleteBinding(id);
  }

  onMount(() => {
    loadTaxonomy();
  });
</script>

<div>
  <!-- Заголовки и UI-разметка колонок точно соответствуют предыдущей версии, 
       но инпут категории теперь поддерживает выбор родительского раздела parent_id -->
  <div class="grid grid-cols-1 md:grid-cols-3 gap-6 text-xs font-semibold">
    <div class="border border-gray-100 rounded-2xl p-4 bg-gray-50/50 flex flex-col h-100">
      <h3 class="font-black text-sm text-gray-800 mb-3">📁 Жанры / Разделы</h3>
      
      <div class="space-y-1.5 mb-3 bg-white p-2.5 border rounded-xl">
        <input bind:value={newCatForm.name} placeholder="Имя жанра..." class="w-full bg-gray-50 border p-1.5 text-xs rounded-lg" />
        <div class="flex gap-1.5">
          <select bind:value={newCatForm.parent_id} class="w-full bg-gray-50 border p-1.5 text-xs rounded-lg cursor-pointer">
            <option value={null}>Корневой раздел</option>
            {#each categories.filter(c => c.parent_id === null) as parent}
              <option value={parent.id}>под раздел: {parent.name}</option>
            {/each}
          </select>
          <button onclick={addCategory} class="bg-indigo-600 text-white px-3 font-black rounded-lg text-xs cursor-pointer">ОК</button>
        </div>
      </div>

      <ul class="space-y-1.5 overflow-y-auto flex-1 pr-1 no-scrollbar">
        {#each categories as cat}
          <li class="flex justify-between items-center bg-white p-2.5 border border-gray-100 rounded-xl">
            <span class="text-gray-700 font-bold">{cat.parent_id ? '└ ' : ''}{cat.name} 
              {#if cat.path}<span class="text-[9px] text-gray-400 font-normal">({cat.path})</span>{/if}
            </span>
            <button onclick={() => catalogApi.deleteCat(cat.id)} class="text-gray-400 hover:text-red-500 font-bold cursor-pointer">✕</button>
          </li>
        {/each}
      </ul>
    </div>
    <div class="border border-gray-100 rounded-2xl p-4 bg-gray-50/50 flex flex-col h-100">
        <h3 class="font-black text-sm text-gray-800 mb-3 flex items-center gap-1.5">#️⃣ Тематические теги</h3>
        <div class="flex gap-1.5 mb-3">
          <input bind:value={newTopicName} placeholder="Новый тег..." class="w-full bg-white border border-gray-200 rounded-xl px-3 py-1.5 text-xs text-gray-900 focus:outline-none focus:border-indigo-500" />
          <button onclick={addTopic} class="bg-indigo-600 hover:bg-indigo-700 text-white px-3 font-black rounded-xl cursor-pointer">ОК</button>
        </div>
        <ul class="space-y-1.5 overflow-y-auto flex-1 pr-1 no-scrollbar">
          {#each topics as topic}
            <li class="flex justify-between items-center bg-white p-2.5 border border-gray-100 rounded-xl hover:border-gray-200 transition-colors">
              <span class="text-gray-600 font-medium">#{topic.name}</span>
              <button onclick={() => deleteTopic(topic.id)} class="text-gray-400 hover:text-red-500 transition text-sm font-bold cursor-pointer">✕</button>
            </li>
          {/each}
        </ul>
      </div>

      <!-- Справочник 3: Переплеты -->
      <div class="border border-gray-100 rounded-2xl p-4 bg-gray-50/50 flex flex-col h-100">
        <h3 class="font-black text-sm text-gray-800 mb-3 flex items-center gap-1.5">📖 Типы переплетов</h3>
        <div class="flex gap-1.5 mb-3">
          <input bind:value={newBindingName} placeholder="Твердый, мягкий..." class="w-full bg-white border border-gray-200 rounded-xl px-3 py-1.5 text-xs text-gray-900 focus:outline-none focus:border-indigo-500" />
          <button onclick={addBinding} class="bg-indigo-600 hover:bg-indigo-700 text-white px-3 font-black rounded-xl cursor-pointer">ОК</button>
        </div>
        <ul class="space-y-1.5 overflow-y-auto flex-1 pr-1 no-scrollbar">
          {#each bindings as b}
            <li class="flex justify-between items-center bg-white p-2.5 border border-gray-100 rounded-xl hover:border-gray-200 transition-colors">
              <span class="text-gray-700 font-bold">{b.name}</span>
              <button onclick={() => deleteBinding(b.id)} class="text-gray-400 hover:text-red-500 transition text-sm font-bold cursor-pointer">✕</button>
            </li>
          {/each}
        </ul>
      </div>

    </div>
</div>

