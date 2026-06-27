<!-- src/components/GlobalLoader.svelte -->
<script lang="ts">
  import { uiState } from '../states/ui.svelte';
</script>

{#if uiState.isGlobalLoading}
  <div class="fixed top-0 left-0 right-0 z-50">
    <div class="h-1 bg-indigo-600 animate-progress"></div>
  </div>
{/if}

<style>
  @keyframes progress {
    0% {
      width: 0%;
      transform: translateX(-100%);
    }
    50% {
      width: 70%;
      transform: translateX(0%);
    }
    100% {
      width: 100%;
      transform: translateX(100%);
    }
  }
  
  .animate-progress {
    animation: progress 1.5s ease-in-out infinite;
  }
</style>