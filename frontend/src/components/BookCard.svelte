<script lang="ts">
  import { cartState } from '../states/cart.svelte';
  import type { BookRead } from '../types/catalog';
  import { ItemCreate } from '../types/users';
  import RatingStars from './RatingStars.svelte'; // Импортируем наши новые звезды

  let { book, onCardClick }: { 
    book: BookRead; 
    onCardClick: (id: number) => void; 
  } = $props();

  let cartItem = $derived(cartState.items.find(item => item.book_id === book.id));
  let quantityInCart = $derived(cartItem ? cartItem.quantity : 0);
  let imageError =$state(false);

  async function handleQuantityChange(delta: number) {
    const newQty = quantityInCart + delta;
    if (newQty <= 0) {
      await cartState.removeItem(book.id);
    } else {
      await cartState.upsertItem({book_id:book.id, quantity:newQty});
    }
  }
</script>

<div class="bg-white border border-gray-100 rounded-2xl p-3 shadow-xs hover:shadow-md transition shrink-0 snap-start flex flex-col justify-between group relative w-full">
  
  <!-- Кликабельная зона книги -->
  <button 
    onclick={() => onCardClick(book.id)} 
    class="block text-left space-y-2 focus:outline-none w-full cursor-pointer group/btn"
  >
    <!-- Обложка -->
    <div class="aspect-3/4 w-full rounded-xl overflow-hidden relative shadow-inner bg-slate-100">
      {#if book.picture_url && !imageError}
        <!-- Реальная картинка -->
        <img 
          src={book.picture_url} 
          alt={book.title} 
          onerror={()=>{imageError=true;}}
          class="w-full h-full object-cover group-hover/btn:scale-102 transition duration-300" 
        />
      {:else}
        <img src="/frontend/src/assets/empty_book.jpg" alt = {book.title} class="w-full h-full object-cover group-hover/btn:scale-102 transition duration-300" />
        <!-- КРАСИВАЯ ДЕФОЛТНАЯ ЗАСТАВКА (Если обложка не найдена) -->
        <!-- <div class="w-full h-full bg-linear-to-br from-indigo-50 to-slate-200 p-4 flex flex-col justify-between items-center text-center relative border border-gray-200/50">
          <div class="text-xs font-bold text-indigo-400 tracking-wide mt-2 uppercase select-none">ЛиТрен</div>
          
          <div class="space-y-1 py-4">
            <div class="text-2xl opacity-80 select-none">📚</div>
            <div class="font-black text-xs text-gray-800 line-clamp-3 px-1 leading-tight">{book.title}</div>
          </div>
          
          <div class="text-[10px] font-bold text-gray-400 mb-2 select-none">Книжный магазин</div>
        </div> -->
      {/if}

      <!-- Лэйблы (Новинка / Хит) -->
      <div class="absolute top-1.5 left-1.5 flex flex-col gap-1 z-10">
        {#if book.is_new}
          <span class="bg-emerald-500 text-white text-[9px] font-black uppercase px-1.5 py-0.5 rounded shadow-sm">NEW</span>
        {/if}
        {#if book.is_bestseller}
          <span class="bg-amber-500 text-white text-[9px] font-black uppercase px-1.5 py-0.5 rounded shadow-sm">HIT</span>
        {/if}
      </div>
    </div>

    <!-- Обновленный блок рейтинга через компонент звезд -->
    <RatingStars rating={book.mean_rating} reviewsCount={book.reviews_count} />

    <!-- Название книги -->
    <h3 class="font-bold text-xs sm:text-sm text-gray-900 line-clamp-2 min-h-10 leading-tight group-hover/btn:text-indigo-600 transition" title={book.title}>
      {book.title}
    </h3>
  </button>
  
  <!-- Нижняя плашка (Цена и кнопки) -->
  <div class="mt-4 flex items-center justify-between gap-2 border-t border-gray-50 pt-2 min-h-9.5">
    <span class="font-black text-sm sm:text-base text-gray-900">{book.price} ₽</span>
    
    {#if quantityInCart > 0}
      <div class="flex items-center bg-indigo-50 border border-indigo-200/50 rounded-xl p-0.5 select-none">
        <button onclick={() => handleQuantityChange(-1)} class="w-7 h-7 flex items-center justify-center font-bold text-indigo-600 hover:text-indigo-900 transition active:scale-90 cursor-pointer">−</button>
        <span class="w-7 text-center text-xs font-black text-indigo-900">{quantityInCart}</span>
        <button onclick={() => handleQuantityChange(1)} class="w-7 h-7 flex items-center justify-center font-bold text-indigo-600 hover:text-indigo-900 transition active:scale-90 cursor-pointer">+</button>
      </div>
    {:else}
      <button 
        onclick={() => cartState.upsertItem(new ItemCreate({book_id:book.id}))} 
        class="bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-1.5 rounded-xl text-xs font-bold transition shadow-xs active:scale-95 cursor-pointer"
      >
        + 🛒
      </button>
    {/if}
  </div>

</div>
