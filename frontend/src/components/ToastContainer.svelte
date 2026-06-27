<!-- src/components/ToastContainer.svelte -->
<script lang="ts">
  import { uiState } from '../states/ui.svelte';
  
  function getToastStyles(type: string) {
    switch (type) {
      case 'success':
        return 'bg-emerald-50 border-emerald-200 text-emerald-800';
      case 'error':
        return 'bg-red-50 border-red-200 text-red-800';
      case 'warning':
        return 'bg-amber-50 border-amber-200 text-amber-800';
      default:
        return 'bg-blue-50 border-blue-200 text-blue-800';
    }
  }
  
  function getIcon(type: string) {
    switch (type) {
      case 'success': return '✓';
      case 'error': return '✕';
      case 'warning': return '⚠';
      default: return 'ℹ';
    }
  }
</script>

{#if uiState.toasts.length > 0}
  <div class="fixed bottom-4 right-4 z-50 space-y-2">
    {#each uiState.toasts as toast}
      <div
        class="animate-slide-in-right max-w-sm bg-white border rounded-xl shadow-lg p-4 flex items-start gap-3 {getToastStyles(toast.type)}"
        role="alert"
      >
        <div class="shrink-0 w-6 h-6 rounded-full flex items-center justify-center font-bold text-sm">
          {getIcon(toast.type)}
        </div>
        <div class="flex-1 text-sm font-medium">
          {toast.message}
        </div>
        <button
          onclick={() => uiState.hideToast(toast.id)}
          class="shrink-0 text-gray-400 hover:text-gray-600 transition"
        >
          ✕
        </button>
      </div>
    {/each}
  </div>
{/if}

<style>
  @keyframes slideInRight {
    from {
      transform: translateX(100%);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }
  
  .animate-slide-in-right {
    animation: slideInRight 0.3s ease-out;
  }
</style>