<!-- src/components/AuthModal.svelte -->
<script lang="ts">
  import { uiState } from '../states/ui.svelte';
  import { userState } from '../states/user.svelte';
  import { untrack } from 'svelte';
  
  let isLoginMode = $state(true);
  let authError = $state('');
  let isSubmitting = $state(false);
  
  // Объявляем форму как простой реактивный объект для 100% стабильности bind:value
  let authForm = $state({
    email: '',
    password: ''
  });
  
  let onSuccessCallback = $state<(() => void) | null>(null);
  
  // Синхронизируем колбэк при открытии модалки
  $effect(() => {
    // Подписываемся только на статус активности модального окна
    if (uiState.activeModal === 'auth') {
      // Изолируем чтение данных, чтобы эффект не перезапускался, если внутри onSuccess что-то изменится
      untrack(() => {
        onSuccessCallback = uiState.modalData?.onSuccess || null;
      });
    }
  });
  
  async function handleSubmit(e: Event) {
    e.preventDefault();
    authError = '';
    isSubmitting = true;
    
    try {
      if (isLoginMode) {
        await userState.login(authForm);
      } else {
        // Динамический импорт API регистрации
        const { usersApi } = await import('../api/users');
        await usersApi.register(authForm);
        await userState.login(authForm);
      }
      
      // Сбрасываем форму к начальным пустым строкам
      authForm = { email: '', password: '' };
      
      // Закрываем окно
      uiState.closeModal();
      
      // Вызываем сохраненный колбэк (например, отправку отзыва или оформление заказа)
      if (onSuccessCallback) {
        onSuccessCallback();
      }
      
      uiState.success(`Добро пожаловать, ${userState.current?.email || 'пользователь'}!`);
    } catch (err: any) {
      // Забираем сообщение об ошибке, которое сформировал наш apiFetch
      authError = err.message || 'Ошибка авторизации';
    } finally {
      isSubmitting = false;
    }
  }
  
  function closeModal() {
    uiState.closeModal();
    authError = '';
    authForm = { email: '', password: '' };
  }
</script>


{#if uiState.activeModal === 'auth'}
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 animate-fade-in">
    <div class="bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 overflow-hidden animate-scale-in">
      
      <!-- Шапка -->
      <div class="flex justify-between items-center p-6 border-b border-gray-100">
        <h3 class="text-lg font-black text-gray-900">
          {isLoginMode ? 'Вход в аккаунт' : 'Регистрация'}
        </h3>
        <button onclick={closeModal} class="text-gray-400 hover:text-gray-600 transition text-xl leading-none">
          ✕
        </button>
      </div>
      
      <!-- Переключатель вкладок -->
      <div class="flex border-b border-gray-100 px-6 pt-2">
        <button 
          onclick={() => { isLoginMode = true; authError = ''; }} 
          class="flex-1 pb-3 font-black text-center border-b-2 text-sm transition cursor-pointer {isLoginMode ? 'border-indigo-600 text-indigo-600' : 'border-transparent text-gray-400'}"
        >
          Войти
        </button>
        <button 
          onclick={() => { isLoginMode = false; authError = ''; }} 
          class="flex-1 pb-3 font-black text-center border-b-2 text-sm transition cursor-pointer {!isLoginMode ? 'border-indigo-600 text-indigo-600' : 'border-transparent text-gray-400'}"
        >
          Создать аккаунт
        </button>
      </div>
      
      <!-- Форма -->
      <form onsubmit={handleSubmit} class="p-6 space-y-4">
        <div class="space-y-1">
          <label for="auth-email" class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">
            Email адрес
          </label>
          <input 
            id="auth-email"
            type="email" 
            required 
            bind:value={authForm.email} 
            placeholder="name@example.com" 
            class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-sm text-gray-900 focus:outline-none focus:border-indigo-500 focus:bg-white transition-all"
          />
        </div>
        
        <div class="space-y-1">
          <label for="auth-password" class="text-[10px] font-bold uppercase tracking-wider text-gray-400 block">
            Пароль
          </label>
          <input 
            id="auth-password"
            type="password" 
            required 
            bind:value={authForm.password} 
            placeholder="••••••••" 
            class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-sm text-gray-900 focus:outline-none focus:border-indigo-500 focus:bg-white transition-all"
          />
        </div>

        {#if authError}
          <div class="bg-red-50 border border-red-100 text-red-500 p-2.5 rounded-xl text-xs font-semibold text-center">
            {authError}
          </div>
        {/if}

        <button 
          type="submit" 
          disabled={isSubmitting}
          class="w-full bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-300 text-white font-black py-3 rounded-xl text-sm transition shadow-xs cursor-pointer"
        >
          {isSubmitting ? 'Обработка...' : (isLoginMode ? 'Войти' : 'Создать аккаунт')}
        </button>
      </form>
      
      <!-- Подсказка для тестирования -->
      <div class="px-6 pb-6 text-center text-[10px] text-gray-400 border-t border-gray-100 pt-4">
        {#if isLoginMode}
          Тестовый вход: demo@example.com / any password
        {:else}
          Зарегистрируйтесь, чтобы покупать книги
        {/if}
      </div>
    </div>
  </div>
{/if}