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
    binding varchar(50),
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

-- ==========================================================
-- -------------------  ТРИГГЕРЫ ----------------------------
-- ==========================================================
-- 1. СБОРКА СТРОКИ АДРЕСА (user_addresses)
CREATE OR REPLACE FUNCTION func_build_full_address()
    RETURNS TRIGGER
    AS $$
DECLARE
    t_name text;
    st_name text;
BEGIN
    SELECT
        name
    INTO
        t_name
    FROM
        towns t
    WHERE
        t.fias_id = NEW.town_id;
    SELECT
        name
    INTO
        st_name
    FROM
        streets s
    WHERE
        s.fias_id = NEW.street_id;
    NEW.full_address := t_name || ', ' || st_name || ', д. ' || NEW.house;
    IF NEW.flat IS NOT NULL AND NEW.flat != '' THEN
        NEW.full_address := NEW.full_address || ', кв. ' || NEW.flat;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_build_address ON addresses;

CREATE TRIGGER trg_build_address
    BEFORE INSERT OR UPDATE ON addresses
    FOR EACH ROW
    EXECUTE PROCEDURE func_build_full_address();

-- 2. ОБНОВЛЕНИЕ РЕЙТИНГА КНИГИ (books)
CREATE OR REPLACE FUNCTION update_book_rating()
    RETURNS TRIGGER
    AS $$
DECLARE
    _book_id int;
BEGIN
    _book_id := COALESCE(NEW.book_id, OLD.book_id);
    UPDATE
        books
    SET
        (mean_rating,
            reviews_count) =(
            SELECT
                COALESCE(round(avg(rating), 2), 0),
                count(*)
            FROM
                reviews
            WHERE
                book_id = _book_id)
    WHERE
        id = _book_id;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_rating ON reviews;

CREATE TRIGGER trigger_update_rating
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW
    EXECUTE PROCEDURE update_book_rating();

-- 4. ПЕРЕСЧЕТ ПОПУЛЯРНОСТИ (popularity_score)
CREATE OR REPLACE FUNCTION update_popularity_score()
    RETURNS TRIGGER
    AS $$
BEGIN
    -- Формула учитывает mean_rating
    NEW.popularity_score :=((NEW.views_count * 1) +(NEW.sales_count * 10)) +(NEW.mean_rating * NEW.reviews_count);
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_refresh_popularity ON books;

CREATE TRIGGER trg_refresh_popularity
    BEFORE UPDATE OF views_count,
    sales_count,
    mean_rating ON books
    FOR EACH ROW
    EXECUTE PROCEDURE update_popularity_score();

-- 5. ПОСТРОЕНИЕ ПУТИ ДЛЯ КАТЕГОРИИ
CREATE OR REPLACE FUNCTION build_cat_path()
    RETURNS TRIGGER
    AS $$
DECLARE
    temp_path text;
BEGIN
    IF NEW.parent_id IS NULL THEN
        UPDATE
            cats
        SET
            path = NEW.id::varchar
        WHERE
            id = NEW.id;
    ELSE
        SELECT
            path
        INTO
            temp_path
        FROM
            cats
        WHERE
            cats.id = NEW.parent_id;
        UPDATE
            cats
        SET
            path = temp_path || '/' || NEW.id::varchar
        WHERE
            id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_build_cat_path ON cats;

CREATE TRIGGER trg_build_cat_path
    AFTER INSERT ON cats
    FOR EACH ROW
    EXECUTE PROCEDURE build_cat_path();

