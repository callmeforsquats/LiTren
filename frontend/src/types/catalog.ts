// ==========================================
// 1. TOPICS (Темы)
// ==========================================
export class TopicCreate {
  name: string = "";

  constructor(init?: Partial<TopicCreate>) {
    Object.assign(this, init);
  }
}

export interface TopicRead extends TopicCreate {
  id: number;
}

// ==========================================
// 2. CATS (Категории / Жанры)
// ==========================================
export class CatCreate {
  name: string = "";
  parent_id: number | null = null;

  constructor(init?: Partial<CatCreate>) {
    Object.assign(this, init);
  }
}

export interface CatRead extends CatCreate {
  id: number;
  path: string | null;
}

// ==========================================
// 3. AUTHORS (Авторы)
// ==========================================

// Классы для форм создания и редактирования автора
export class AuthorCreate {
  name: string = ""; // Обязательное поле для создания
  bio: string | null = null;

  constructor(init?: Partial<AuthorCreate>) {
    Object.assign(this, init);
  }
}

export class AuthorUpdate {
  name: string | null = null;
  bio: string | null = null;

  constructor(init?: Partial<AuthorUpdate>) {
    Object.assign(this, init);
  }
}

// Интерфейсы только для чтения данных из API
export interface AuthorRead {
  id: number;
  name: string;
}

export interface AuthorInfo extends AuthorRead {
  bio: string | null;
  picture_url: string | null;
}

// ==========================================
// 4. PUBS (Издательства)
// ==========================================

export class PubCreate {
  name: string = ""; // Обязательное при создании
  info: string | null = null;

  constructor(init?: Partial<PubCreate>) {
    Object.assign(this, init);
  }
}

export class PubUpdate {
  name: string | null = null;
  info: string | null = null;

  constructor(init?: Partial<PubUpdate>) {
    Object.assign(this, init);
  }
}

export interface PubRead {
  id: number;
  name: string;
  picture_url: string | null;
}

export interface PubInfo extends PubRead {
  info: string | null;
}

export interface BindingRead {
  id: number;
  name: string;
}

// ==========================================
// 5. BOOKS (Книги)
// ==========================================

// Классы для админки (Создание и редактирование книг)
export class BookCreate {
  title: string = ""; // Обязательное
  price: number = 0; // Обязательное
  isbn: string | null = null;
  is_new: boolean = false;
  is_bestseller: boolean = false;
  annotation: string | null = null;
  page_count: number | null = null;
  binding_id: number | null = null;
  pub_id: number | null = null;
  author_ids: number[] | null = null;
  topic_ids: number[] | null = null;

  constructor(init?: Partial<BookCreate>) {
    Object.assign(this, init);
  }
}

export class BookUpdate {
  cat_id: number | null = null;
  title: string | null = null;
  price: number | null = null;
  isbn: string | null = null;
  is_new: boolean | null = null;
  is_bestseller: boolean | null = null;
  annotation: string | null = null;
  page_count: number | null = null;
  binding_id: number | null = null;
  pub_id: number | null = null;
  author_ids: number[] | null = null;
  topic_ids: number[] | null = null;

  constructor(init?: Partial<BookUpdate>) {
    Object.assign(this, init);
  }
}

// Интерфейсы только для чтения каталога
export interface BookRead {
  id: number;
  title: string;
  price: number;
  mean_rating: number;
  reviews_count: number; // не забудьте добавить, она была на вашем скриншоте ошибок
  picture_url: string | null;
  is_new: boolean;
  is_bestseller: boolean;
}

export interface BookInfo extends BookRead {
  isbn: string | null;
  page_count: number | null;
  annotation: string | null;
  binding: BindingRead | null;
  pub: PubRead | null;
  authors: AuthorRead[] | null;
  cat: CatRead | null;
  topics: TopicRead[] | null;
}

// ==========================================
// 6. FILTER (Фильтрация каталога)
// ==========================================
export enum SortBy {
  popularity = "popularity",
  rating = "rating",
  price = "price",
}

export class BookFilter {
  cat_id: number | null = null;
  topic_id: number[] | null = null;
  min_price: number | null = null;
  max_price: number | null = null;
  binding_id: number[] | null = null;
  is_new: boolean | null = null;
  is_bestseller: boolean | null = null;
  min_rating: number | null = null;
  author_id: number[] | null = null;
  pub_id: number[] | null = null;
  search: string = "";
  limit: number = 12;
  offset: number = 0;
  sort_by: SortBy = SortBy.popularity;
  reverse: boolean | null = null;

  constructor(init?: Partial<BookFilter>) {
    Object.assign(this, init);
  }
}
