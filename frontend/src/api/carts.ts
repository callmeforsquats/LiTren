import { apiFetch } from "./client";
import { ItemCreate, type ItemRead } from "../types/users";

const CART_URL = "/cart";

export const cartApi = {
  async getCart(): Promise<ItemRead[]> {
    return apiFetch<ItemRead[]>(CART_URL);
  },

  async upsertCartItem(item: ItemCreate): Promise<ItemRead[]> {
    return apiFetch<ItemRead[]>(`${CART_URL}/items`, {
      method: "POST",
      body: JSON.stringify(item),
    });
  },

  async deleteCartItem(book_id: number): Promise<ItemRead[]> {
    return apiFetch<ItemRead[]>(`${CART_URL}/items/${book_id}`);
  },
};
