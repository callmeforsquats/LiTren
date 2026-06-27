import type { ItemRead, ItemCreate } from "../types/users";
import { apiFetch } from "../api/client";

class CartState {
  // Реактивный массив элементов в корзине
  items = $state<ItemRead[]>([]);
  isLoading = $state(true);

  // Вычисляемые свойства (автоматически обновляются)
  totalItems = $derived(
    this.items.reduce((sum, item) => sum + item.quantity, 0),
  );
  totalPrice = $derived(
    this.items.reduce((sum, item) => sum + item.price * item.quantity, 0),
  );

  async upsertItem(item: ItemCreate) {
    this.isLoading = true;
    this.items = await apiFetch<ItemRead[]>("/cart/items", {
      method: "POST",
      body: JSON.stringify(item),
    });
    this.isLoading = false;
  }

  async removeItem(book_id: number) {
    this.isLoading = true;
    this.items = await apiFetch<ItemRead[]>(`/cart/items/${book_id}`, {
      method: "DELETE",
    });
    this.isLoading = false;
  }
  async getCart() {
    this.isLoading = true;
    this.items = await apiFetch<ItemRead[]>(`/cart`);
    this.isLoading = false;
  }
}

// Экспортируем единый синглтон на всё приложение
export const cartState = new CartState();
