<!-- src/components/ConfirmDialog.svelte -->
<script lang="ts">
  import { uiState } from '../states/ui.svelte';
  
  let isOpen = $derived(uiState.activeModal === 'confirm');
  let data = $derived(uiState.modalData as {
    title?: string;
    message: string;
    confirmText?: string;
    cancelText?: string;
    onConfirm: () => void | Promise<void>;
    onCancel?: () => void;
  });
  
  let isConfirming = $state(false);
  
  async function handleConfirm() {
    if (!data) return;
    
    isConfirming = true;
    try {
      await data.onConfirm();
      uiState.closeModal();
    } catch (error) {
      console.error('Confirm action failed:', error);
    } finally {
      isConfirming = false;
    }
  }
  
  function handleCancel() {
    data?.onCancel?.();
    uiState.closeModal();
  }
</script>

{#if isOpen && data}
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 animate-fade-in">
    <div class="bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 overflow-hidden animate-scale-in" >
      <div class="p-6">
        {#if data.title}
          <h3 class="text-lg font-bold text-gray-900 mb-2">{data.title}</h3>
        {/if}
        <p class="text-gray-600 text-sm">{data.message}</p>
      </div>
      
      <div class="flex gap-3 p-6 pt-0">
        <button
          onclick={handleConfirm}
          disabled={isConfirming}
          class="flex-1 bg-red-600 hover:bg-red-700 disabled:bg-gray-300 text-white font-bold py-2.5 rounded-xl transition text-sm"
        >
          {isConfirming ? '...' : (data.confirmText || 'Да, удалить')}
        </button>
        <button
          onclick={handleCancel}
          class="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold py-2.5 rounded-xl transition text-sm"
        >
          {data.cancelText || 'Отмена'}
        </button>
      </div>
    </div>
  </div>
{/if}

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