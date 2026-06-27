import { apiFetch } from "./client";
import type {
  UserBase,
  UserInfo,
  ReviewCreate,
  AddressCreate,
  AddressRead,
  ReviewFilter,
  ReviewRead,
} from "../types/users";

const DADATA_TOKEN = import.meta.env.DADATA_TOKEN || "your token";
const DADATA_URL = import.meta.env.DADATA_URL ||
  "https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address";

export const usersApi = {
  async register(credentials: UserBase): Promise<{ status: string }> {
    return apiFetch("/users/register", {
      method: "POST",
      body: JSON.stringify(credentials),
    });
  },

  async login(credentials: UserBase): Promise<{ status: string }> {
    return apiFetch("/users/login", {
      method: "POST",
      body: JSON.stringify(credentials),
    });
  },

  async logout(): Promise<{ status: string }> {
    return apiFetch("/users/logout");
  },

  async refresh(): Promise<{ status: string }> {
    return apiFetch("/users/refresh");
  },

  async getMe(): Promise<UserInfo> {
    return apiFetch<UserInfo>("/users/me");
  },

  async getReviews(filter: ReviewFilter): Promise<ReviewRead[]> {
    const params = new URLSearchParams();
    if (filter.user_id !== null && filter.user_id !== undefined)
      params.append("user_id", String(filter.user_id));
    if (filter.bad_first !== null && filter.bad_first !== undefined)
      params.append("bad_first", String(filter.bad_first));
    else if (filter.good_first !== null && filter.good_first !== undefined)
      params.append("good_first", String(filter.good_first));
    if (filter.limit !== null && filter.limit !== undefined)
      params.append("limit", String(filter.limit));
    if (filter.offset !== null && filter.offset !== undefined)
      params.append("offset", String(filter.offset));

    return apiFetch<ReviewRead[]>("/users/reviews");
  },

  // POST /users/review
  async addReview(
    bookId: number,
    review: ReviewCreate,
  ): Promise<{ status: string }> {
    return apiFetch(`/users/reviews?book_id=${bookId}`, {
      method: "POST",
      body: JSON.stringify(review),
    });
  },

  // GET /users/addresses
  async getAddresses(): Promise<AddressRead[]> {
    return apiFetch<AddressRead[]>("/users/addresses");
  },

  async addAddress(address: AddressCreate): Promise<{ status: string }> {
    return apiFetch("/users/address", {
      method: "POST",
      body: JSON.stringify(address),
    });
  },

  async deleteAddress(fias_id: string): Promise<{ status: string }> {
    return apiFetch(`/users/address?fias_id=${fias_id}`, { method: "POST" });
  },

  // МЕТОД ЗАПРОСА ПОДСКАЗОК АДРЕСА ИЗ DADATA API
  async getAddressSuggestions(query: string): Promise<any[]> {
    if (!query || query.length < 3) return [];

    try {
      const response = await fetch(DADATA_URL, {
        method: "POST",
        mode: "cors",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          Authorization: `Token ${DADATA_TOKEN}`,
        },
        body: JSON.stringify({ query: query }),
      });

      if (!response.ok) return [];
      const data = await response.json();
      return data.suggestions || [];
    } catch (e) {
      console.error("Ошибка DaData:", e);
      return [];
    }
  },
  async uploadAvatar(file: File): Promise<{ picture_url: string }> {
    const formData = new FormData();
    formData.append("file", file);

    return apiFetch<{ picture_url: string }>("/media/avatar", {
      method: "POST",
      body: formData,
      // Не устанавливаем Content-Type, браузер сам добавит multipart/form-data с boundary
    });
  },
};
