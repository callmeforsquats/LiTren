import { apiFetch } from "./client";
import type {
  BookRead,
  BookInfo,
  BookFilter,
  CatRead,
  TopicRead,
  AuthorRead,
  PubRead,
  BookCreate,
  BookUpdate,
  CatCreate,
  PubCreate,
  PubUpdate,
  PubInfo,
  AuthorCreate,
  AuthorUpdate,
  AuthorInfo,
  BindingRead,
} from "../types/catalog";
import type { ReviewFilter, ReviewRead } from "../types/users";

const BOOKS_REL = "/catalog/books";
const AUTHORS_REL = "/catalog/authors";
const CATS_REL = "/catalog/cats";
const PUBS_REL = "/catalog/pubs";
const TOPICS_REL = "/catalog/topics";
const BINDING_REL = "/catalog/bindings";

export const catalogApi = {
  // GET /catalog/books
  async getBooks(filters: Partial<BookFilter> = {}): Promise<BookRead[]> {
    const params = new URLSearchParams();

    // Одиночные значения
    if (filters.cat_id !== null && filters.cat_id !== undefined)
      params.append("cat_id", String(filters.cat_id));
    if (filters.min_price !== null && filters.min_price !== undefined)
      params.append("min_price", String(filters.min_price));
    if (filters.max_price !== null && filters.max_price !== undefined)
      params.append("max_price", String(filters.max_price));
    if (filters.is_new !== null && filters.is_new !== undefined)
      params.append("is_new", String(filters.is_new));
    if (filters.is_bestseller !== null && filters.is_bestseller !== undefined)
      params.append("is_bestseller", String(filters.is_bestseller));
    if (filters.min_rating !== null && filters.min_rating !== undefined)
      params.append("min_rating", String(filters.min_rating));
    if (filters.search) params.append("search", filters.search);

    // Пагинация и сортировка
    if (filters.limit) params.append("limit", String(filters.limit));
    if (filters.offset !== null && filters.offset !== undefined)
      params.append("offset", String(filters.offset));
    if (filters.sort_by) params.append("sort_by", filters.sort_by);
    if (filters.reverse !== null && filters.reverse !== undefined)
      params.append("reverse", String(filters.reverse));

    // Массивы (list[int] в FastAPI передаются через повторение ключа)
    if (filters.topic_id && filters.topic_id.length > 0) {
      filters.topic_id.forEach((id) => params.append("topic_id", String(id)));
    }
    if (filters.binding_id && filters.binding_id.length > 0) {
      filters.binding_id.forEach((id) =>
        params.append("binding_id", String(id)),
      );
    }
    if (filters.author_id && filters.author_id.length > 0) {
      filters.author_id.forEach((id) => params.append("author_id", String(id)));
    }
    if (filters.pub_id && filters.pub_id.length > 0) {
      filters.pub_id.forEach((id) => params.append("pub_id", String(id)));
    }

    return apiFetch<BookRead[]>(`${BOOKS_REL}?${params.toString()}`);
  },

  async addBook(book: any): Promise<{ id: number; status: string }> {
    return apiFetch(BOOKS_REL, {
      method: "POST",
      body: JSON.stringify(book),
    });
  },
  // GET /catalog/books/{id}
  async getBookById(id: number): Promise<BookInfo> {
    return apiFetch<BookInfo>(`${BOOKS_REL}/${id}`);
  },

  async updateBook(id: number, data: BookUpdate): Promise<{ status: string }> {
    return apiFetch(`${BOOKS_REL}/${id}`, {
      method: "PATCH",
      body: JSON.stringify(data),
    });
  },

  async deleteBook(id: number): Promise<{ status: string }> {
    return apiFetch(`${BOOKS_REL}/${id}`, { method: "DELETE" });
  },

  async getBookReviews(
    book_id: number,
    filter: Partial<ReviewFilter> = {},
  ): Promise<ReviewRead[]> {
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
    return apiFetch<ReviewRead[]>(`${BOOKS_REL}/${book_id}/reviews`);
  },

  async getCats(): Promise<CatRead[]> {
    return apiFetch<CatRead[]>("/catalog/cats");
  },

  async addCat(cat: CatCreate): Promise<{ status: string }> {
    return apiFetch(`${CATS_REL}`, {
      method: "POST",
      body: JSON.stringify(cat),
    });
  },

  async deleteCat(cat_id: number): Promise<{ status: string }> {
    return apiFetch(`${CATS_REL}/${cat_id}`, { method: "DELETE" });
  },

  async getTopics(cat_id: number | null = null): Promise<TopicRead[]> {
    if (cat_id !== null && cat_id !== undefined) {
      return apiFetch<TopicRead[]>(`${CATS_REL}/${cat_id}/topics`);
    } else {
      return apiFetch<TopicRead[]>(`${TOPICS_REL}`);
    }
  },

  async getAuthors(cat_id: number | null = null): Promise<AuthorRead[]> {
    if (cat_id !== null && cat_id !== undefined)
      return apiFetch<AuthorRead[]>(`${CATS_REL}/${cat_id}/authors/`);
    else return apiFetch<AuthorRead[]>(`${AUTHORS_REL}`);
  },
  async getPubs(): Promise<PubRead[]> {
    return apiFetch<PubRead[]>(PUBS_REL);
  },

  async addPub(pub: PubCreate): Promise<{ status: string }> {
    return apiFetch(PUBS_REL, { method: "POST", body: JSON.stringify(pub) });
  },

  async updatePub(
    pub_id: number,
    data: PubUpdate,
  ): Promise<{ status: string }> {
    return apiFetch(`${PUBS_REL}/${pub_id}`, {
      method: "PATCH",
      body: JSON.stringify(data),
    });
  },

  async getPub(pub_id: number): Promise<PubInfo> {
    return apiFetch<PubInfo>(`${PUBS_REL}/${pub_id}`);
  },

  async deletePub(pub_id: number): Promise<{ status: string }> {
    return apiFetch(`${PUBS_REL}/${pub_id}`, { method: "DELETE" });
  },

  async getAuthor(id: number): Promise<AuthorInfo> {
    return apiFetch<AuthorInfo>(`${AUTHORS_REL}/${id}`);
  },

  async addAuthor(author: AuthorCreate): Promise<{ status: string }> {
    return apiFetch(AUTHORS_REL, {
      method: "POST",
      body: JSON.stringify(author),
    });
  },

  async updateAuthor(
    id: number,
    data: AuthorUpdate,
  ): Promise<{ status: string }> {
    return apiFetch(`${AUTHORS_REL}/${id}`, {
      method: "PATCH",
      body: JSON.stringify(data),
    });
  },

  async deleteAuthor(id: number): Promise<{ status: string }> {
    return apiFetch(`${AUTHORS_REL}/${id}`, { method: "DELETE" });
  },

  async getBindings(): Promise<BindingRead[]> {
    return apiFetch<BindingRead[]>(BINDING_REL);
  },

  async addBinding(name: string): Promise<{ status: string }> {
    return apiFetch(BINDING_REL, {
      method: "POST",
      body: JSON.stringify(name),
    });
  },

  async deleteBindind(id: number): Promise<{ status: string }> {
    return apiFetch(`${BINDING_REL}/${id}`, { method: "DELETE" });
  },
  async uploadBookCover(
    bookId: number,
    file: File,
  ): Promise<{ picture_url: string }> {
    const formData = new FormData();
    formData.append("file", file);

    return apiFetch<{ picture_url: string }>(`/media/catalog/books/${bookId}`, {
      method: "PATCH",
      body: formData,
    });
  },
  async getBooksByQuery(q: string): Promise<BookRead[]> {
    return apiFetch<BookRead[]>(
      `${BOOKS_REL}/by_query?q=${encodeURIComponent(q)}`,
    );
  },
};
