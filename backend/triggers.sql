-- ==========================================================
-- 1. СБОРКА СТРОКИ АДРЕСА (user_addresses)
-- ==========================================================
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

-- ==========================================================
-- 2. ОБНОВЛЕНИЕ РЕЙТИНГА КНИГИ (books)
-- ==========================================================
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

-- ==========================================================
-- 3. ПЕРЕСЧЕТ ПОПУЛЯРНОСТИ (popularity_score)
-- ==========================================================
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

-- ==========================================================
-- 4. ПОСТРОЕНИЕ ПУТИ ДЛЯ КАТЕГОРИИ
-- ==========================================================
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

-- ==========================================================
-- 5. АВТОМАТИЧЕСКОЕ УМЕНЬШЕНИЕ/УДАЛЕНИЕ ТЕМЫ ИЗ КАТЕГОРИИ (ПРИ УДАЛЕНИИ ТЕМЫ У КНИГИ)
-- ==========================================================
CREATE OR REPLACE FUNCTION auto_add_topic_to_category()
    RETURNS TRIGGER
    AS $$
DECLARE
    _cat_id int;
BEGIN
    -- Получаем категорию книги
    SELECT
        cat_id
    INTO
        _cat_id
    FROM
        books
    WHERE
        id = NEW.book_id;
    -- Если у книги есть категория
    IF _cat_id IS NOT NULL THEN
        -- Добавляем или увеличиваем счётчик
        INSERT INTO cat_topics(cat_id, topic_id, books_count)
            VALUES (_cat_id, NEW.topic_id, 1)
        ON CONFLICT (cat_id, topic_id)
            DO UPDATE SET
                books_count = cat_topics.books_count + 1;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_add_topic_to_category ON book_topics;

CREATE TRIGGER trg_auto_add_topic_to_category
    AFTER INSERT ON book_topics
    FOR EACH ROW
    EXECUTE FUNCTION auto_add_topic_to_category();

-- ==========================================================
-- 6. АВТОМАТИЧЕСКОЕ УМЕНЬШЕНИЕ/УДАЛЕНИЕ ТЕМЫ ИЗ КАТЕГОРИИ (ПРИ УДАЛЕНИИ ТЕМЫ У КНИГИ)
-- ==========================================================
CREATE OR REPLACE FUNCTION auto_remove_topic_from_category()
    RETURNS TRIGGER
    AS $$
DECLARE
    _cat_id int;
    _new_count int;
BEGIN
    -- Получаем категорию книги
    SELECT
        cat_id
    INTO
        _cat_id
    FROM
        books
    WHERE
        id = OLD.book_id;
    IF _cat_id IS NOT NULL THEN
        -- Уменьшаем счётчик
        UPDATE
            cat_topics
        SET
            books_count = books_count - 1
        WHERE
            cat_id = _cat_id
            AND topic_id = OLD.topic_id
        RETURNING
            books_count
        INTO
            _new_count;
        -- Если книг больше нет, удаляем связь
        IF _new_count <= 0 THEN
            DELETE FROM cat_topics
            WHERE cat_id = _cat_id
                AND topic_id = OLD.topic_id;
        END IF;
    END IF;
    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_remove_topic_from_category ON book_topics;

CREATE TRIGGER trg_auto_remove_topic_from_category
    AFTER DELETE ON book_topics
    FOR EACH ROW
    EXECUTE FUNCTION auto_remove_topic_from_category();

-- ==========================================================
-- 7. ОБНОВЛЕНИЕ ТЕМ ПРИ СМЕНЕ КАТЕГОРИИ КНИГИ
-- ==========================================================
CREATE OR REPLACE FUNCTION update_topics_on_category_change()
    RETURNS TRIGGER
    AS $$
DECLARE
    topic_record RECORD;
    _new_count int;
BEGIN
    -- Если категория не изменилась, выходим
    IF OLD.cat_id IS NOT DISTINCT FROM NEW.cat_id THEN
        RETURN NEW;
    END IF;
    -- Для каждой темы книги
    FOR topic_record IN
    SELECT
        topic_id
    FROM
        book_topics
    WHERE
        book_id = NEW.id LOOP
            -- Удаляем из старой категории
            IF OLD.cat_id IS NOT NULL THEN
                UPDATE
                    cat_topics
                SET
                    books_count = books_count - 1
                WHERE
                    cat_id = OLD.cat_id
                    AND topic_id = topic_record.topic_id
                RETURNING
                    books_count
                INTO
                    _new_count;
                IF _new_count <= 0 THEN
                    DELETE FROM cat_topics
                    WHERE cat_id = OLD.cat_id
                        AND topic_id = topic_record.topic_id;
                END IF;
            END IF;
            -- Добавляем в новую категорию
            IF NEW.cat_id IS NOT NULL THEN
                INSERT INTO cat_topics(cat_id, topic_id, books_count)
                    VALUES (NEW.cat_id, topic_record.topic_id, 1)
                ON CONFLICT (cat_id, topic_id)
                    DO UPDATE SET
                        books_count = cat_topics.books_count + 1;
            END IF;
        END LOOP;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_topics_on_category_change ON books;

CREATE TRIGGER trg_update_topics_on_category_change
    AFTER UPDATE OF cat_id ON books
    FOR EACH ROW
    EXECUTE FUNCTION update_topics_on_category_change();

-- ==========================================================
-- 8. АВТОМАТИЧЕСКОЕ ДОБАВЛЕНИЕ АВТОРА В КАТЕГОРИЮ
-- ==========================================================
CREATE OR REPLACE FUNCTION auto_add_author_to_category()
    RETURNS TRIGGER
    AS $$
DECLARE
    _cat_id int;
BEGIN
    -- Получаем категорию книги
    SELECT
        cat_id
    INTO
        _cat_id
    FROM
        books
    WHERE
        id = NEW.book_id;
    -- Если у книги есть категория
    IF _cat_id IS NOT NULL THEN
        -- Добавляем или обновляем счётчик
        INSERT INTO cat_authors(author_id, cat_id, books_count)
            VALUES (NEW.author_id, _cat_id, 1)
        ON CONFLICT (author_id, cat_id)
            DO UPDATE SET
                books_count = cat_authors.books_count + 1;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_add_author_to_category ON book_authors;

CREATE TRIGGER trg_auto_add_author_to_category
    AFTER INSERT ON book_authors
    FOR EACH ROW
    EXECUTE FUNCTION auto_add_author_to_category();

-- ==========================================================
-- 9. АВТОМАТИЧЕСКОЕ УДАЛЕНИЕ АВТОРА ИЗ КАТЕГОРИИ
-- ==========================================================
CREATE OR REPLACE FUNCTION auto_remove_author_from_category()
    RETURNS TRIGGER
    AS $$
DECLARE
    _cat_id int;
    _new_count int;
BEGIN
    -- Получаем категорию книги
    SELECT
        cat_id
    INTO
        _cat_id
    FROM
        books
    WHERE
        id = OLD.book_id;
    IF _cat_id IS NOT NULL THEN
        -- Уменьшаем счётчик
        UPDATE
            cat_authors
        SET
            books_count = books_count - 1
        WHERE
            author_id = OLD.author_id
            AND cat_id = _cat_id
        RETURNING
            books_count
        INTO
            _new_count;
        -- Если книг больше нет, удаляем связь
        IF _new_count <= 0 THEN
            DELETE FROM cat_authors
            WHERE author_id = OLD.author_id
                AND cat_id = _cat_id;
        END IF;
    END IF;
    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_remove_author_from_category ON book_authors;

CREATE TRIGGER trg_auto_remove_author_from_category
    AFTER DELETE ON book_authors
    FOR EACH ROW
    EXECUTE FUNCTION auto_remove_author_from_category();

-- ==========================================================
-- 10. ОБНОВЛЕНИЕ ПРИ СМЕНЕ КАТЕГОРИИ КНИГИ
-- ==========================================================
CREATE OR REPLACE FUNCTION update_authors_on_category_change()
    RETURNS TRIGGER
    AS $$
DECLARE
    author_record RECORD;
BEGIN
    -- Если категория не изменилась, выходим
    IF OLD.cat_id IS NOT DISTINCT FROM NEW.cat_id THEN
        RETURN NEW;
    END IF;
    -- Для каждого автора книги
    FOR author_record IN
    SELECT
        author_id
    FROM
        book_authors
    WHERE
        book_id = NEW.id LOOP
            -- Удаляем из старой категории
            IF OLD.cat_id IS NOT NULL THEN
                UPDATE
                    cat_authors
                SET
                    books_count = books_count - 1
                WHERE
                    author_id = author_record.author_id
                    AND cat_id = OLD.cat_id;
                DELETE FROM cat_authors
                WHERE author_id = author_record.author_id
                    AND cat_id = OLD.cat_id
                    AND books_count <= 0;
            END IF;
            -- Добавляем в новую категорию
            IF NEW.cat_id IS NOT NULL THEN
                INSERT INTO cat_authors(author_id, cat_id, books_count)
                    VALUES (author_record.author_id, NEW.cat_id, 1)
                ON CONFLICT (author_id, cat_id)
                    DO UPDATE SET
                        books_count = cat_authors.books_count + 1;
            END IF;
        END LOOP;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_authors_on_category_change ON books;

CREATE TRIGGER trg_update_authors_on_category_change
    AFTER UPDATE OF cat_id ON books
    FOR EACH ROW
    EXECUTE FUNCTION update_authors_on_category_change();

