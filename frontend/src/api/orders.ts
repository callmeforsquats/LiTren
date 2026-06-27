import { apiFetch } from "./client";
import {
  OrderCreate,
  OrderFilter,
  type OrderRead,
  type OrderInfo,
} from "../types/users";
const ORDER_URL = "/orders";

export const orderApi = {
  async createOrder(order: OrderCreate): Promise<{ status: string }> {
    return apiFetch<{ status: string }>(ORDER_URL, {
      method: "POST",
      body: JSON.stringify(order),
    });
  },
  async getOrders(filter: OrderFilter): Promise<OrderRead[]> {
    const params = new URLSearchParams();
    if (filter.book_id !== null && filter.book_id !== undefined)
      params.append("book_id", String(filter.book_id));
    if (filter.user_id !== null && filter.user_id !== undefined)
      params.append("user_id", String(filter.user_id));
    if (filter.status !== null && filter.status !== undefined)
      params.append("status", String(filter.status));
    if (filter.max_price !== null && filter.max_price !== undefined)
      params.append("max_price", String(filter.max_price));
    if (filter.min_price !== null && filter.min_price !== undefined)
      params.append("min_price", String(filter.min_price));
    if (filter.offset !== null && filter.offset !== undefined)
      params.append("offset", String(filter.offset));
    if (filter.limit !== null && filter.limit !== undefined)
      params.append("limit", String(filter.limit));
    if (filter.town_id !== null && filter.town_id !== undefined)
      params.append("town_id", String(filter.town_id));

    return apiFetch<OrderRead[]>(`${ORDER_URL}?${params.toString()}`);
  },

  async getOrder(id: number): Promise<OrderInfo> {
    return apiFetch<OrderInfo>(`${ORDER_URL}/${id}`);
  },
};
