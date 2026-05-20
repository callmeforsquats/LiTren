--=================== СПРАВОЧНИКИ =============================
-- АВТОРЫ -----
CREATE TABLE IF NOT EXISTS authors(
    id serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    bio text,
    picture_url varchar(255)
);

---- ИЗДАТЕЛЬСТВА -------
CREATE TABLE IF NOT EXISTS pubs(
    id serial PRIMARY KEY,
    name varchar(255) UNIQUE NOT NULL,
    info text,
    picture_url varchar(255)
);

-- ТЕМЫ ----
CREATE TABLE IF NOT EXISTS topics(
    id serial PRIMARY KEY,
    name varchar(100) UNIQUE NOT NULL
);

-- КАТЕГОРИИ --
CREATE TABLE IF NOT EXISTS cats(
    id serial PRIMARY KEY,
    name varchar(255) UNIQUE NOT NULL,
    parent_id int REFERENCES cats(id) ON DELETE CASCADE,
    path varchar(100)
);

CREATE INDEX IF NOT EXISTS cat_path_index ON cats(path);

-- ПЕРЕПЛЁТЫ --
CREATE TABLE IF NOT EXISTS bindings(
    id serial PRIMARY KEY,
    name varchar(255) UNIQUE NOT NULL
);

-- НАСЕЛЁННЫЕ ПУНКТЫ ----
CREATE TABLE IF NOT EXISTS towns(
    fias_id uuid UNIQUE,
    name varchar(255) NOT NULL
);

-- УЛИЦЫ ---
CREATE TABLE IF NOT EXISTS streets(
    town_id uuid REFERENCES towns(fias_id) ON DELETE CASCADE,
    fias_id uuid UNIQUE,
    name varchar(255) NOT NULL
);

-- ================================================================
-- ======= СУЩНОСТИ =================================
-- ПОЛЬЗОВАТЕЛИ
CREATE TABLE IF NOT EXISTS users(
    id serial PRIMARY KEY,
    email varchar(255) UNIQUE NOT NULL,
    password_hash varchar(255) NOT NULL,
    picture_url varchar(255),
    created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

-- АДРЕСА ПОЛЬЗОВАТЕЛЕЙ ---
CREATE TABLE IF NOT EXISTS addresses(
    user_id int REFERENCES users(id) ON DELETE CASCADE,
    town_id uuid REFERENCES towns(fias_id) ON DELETE CASCADE,
    street_id uuid REFERENCES streets(fias_id) ON DELETE CASCADE,
    house varchar(20) NOT NULL,
    flat varchar(20),
    full_address text,
    fias_id uuid,
    is_default boolean DEFAULT FALSE,
    UNIQUE (user_id, fias_id)
);

----- КНИГИ ------
CREATE TABLE IF NOT EXISTS books(
    id serial PRIMARY KEY,
    title varchar(255) NOT NULL,
    annotation text,
    price DECIMAL(10, 2) NOT NULL,
    isbn varchar(20) UNIQUE,
    page_count int,
    binding_id int REFERENCES bindings(id) ON DELETE SET NULL,
    is_bestseller boolean DEFAULT FALSE,
    is_new boolean DEFAULT TRUE,
    mean_rating DECIMAL(3, 2) DEFAULT 0,
    reviews_count int DEFAULT 0,
    views_count int DEFAULT 0,
    sales_count int DEFAULT 0,
    popularity_score DECIMAL(10, 2) DEFAULT 0,
    picture_url varchar(255),
    cat_id int REFERENCES cats(id) ON DELETE SET NULL,
    pub_id int REFERENCES pubs(id) ON DELETE SET NULL,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

-------- КОРЗИНЫ --------
CREATE TABLE IF NOT EXISTS carts(
    id serial PRIMARY KEY,
    session_id varchar(255) UNIQUE,
    user_id int UNIQUE REFERENCES users(id) ON DELETE CASCADE
);

------- ПОЗИЦИИ В КОРЗИНЕ -----
CREATE TABLE IF NOT EXISTS cart_items(
    id serial PRIMARY KEY,
    cart_id int REFERENCES carts(id) ON DELETE CASCADE,
    book_id int REFERENCES books(id) ON DELETE CASCADE,
    quantity int NOT NULL DEFAULT 1,
    UNIQUE (cart_id, book_id)
);

---- ЗАКАЗЫ ---------
CREATE TABLE IF NOT EXISTS orders(
    id serial PRIMARY KEY,
    user_id int REFERENCES users(id) ON DELETE SET NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status varchar(50) DEFAULT 'PENDING',
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    town_id uuid REFERENCES towns(fias_id) ON DELETE SET NULL,
    full_address varchar(255)
);

------- ПОЗИЦИИ ЗАКАЗА --------
CREATE TABLE IF NOT EXISTS order_items(
    id serial PRIMARY KEY,
    order_id int REFERENCES orders(id) ON DELETE CASCADE,
    book_id int REFERENCES books(id) ON DELETE SET NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    quantity int NOT NULL DEFAULT 1,
    UNIQUE (order_id, book_id)
);

-------- ОТЗЫВЫ ----------
CREATE TABLE IF NOT EXISTS reviews(
    id serial PRIMARY KEY,
    user_id int REFERENCES users(id) ON DELETE CASCADE,
    book_id int REFERENCES books(id) ON DELETE CASCADE,
    text text,
    rating int CHECK (rating >= 1 AND rating <= 5),
    created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
--================= ТАБЛИЦЫ СВЯЗЕЙ ======================
-- КНИГИ-АВТОРЫ
CREATE TABLE IF NOT EXISTS book_authors(
    book_id int REFERENCES books(id) ON DELETE CASCADE,
    author_id int REFERENCES authors(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);

-- КНИГИ-ТЕМЫ
CREATE TABLE IF NOT EXISTS book_topics(
    book_id int REFERENCES books(id) ON DELETE CASCADE,
    topic_id int REFERENCES topics(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, topic_id)
);

-- КАТЕГОРИИ-ТЕМЫ
CREATE TABLE IF NOT EXISTS cat_topics(
    cat_id int REFERENCES cats(id) ON DELETE CASCADE,
    topic_id int REFERENCES topics(id) ON DELETE CASCADE,
    PRIMARY KEY (cat_id, topic_id)
);

