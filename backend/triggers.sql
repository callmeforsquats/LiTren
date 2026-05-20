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

-- ==========================================================
-- 6. АВТОМАТИЧЕСКОЕ ДОБАВЛЕНИЕ ТЕМЫ В КАТЕГОРИЮ (только при вставке)
-- ==========================================================
CREATE OR REPLACE FUNCTION auto_add_topic_to_category()
    RETURNS TRIGGER
    AS $$
DECLARE
    _cat_id int;
BEGIN
    SELECT
        cat_id
    INTO
        _cat_id
    FROM
        books
    WHERE
        id = NEW.book_id;
    IF _cat_id IS NOT NULL THEN
        INSERT INTO cat_topics(cat_id, topic_id)
            VALUES (_cat_id, NEW.topic_id)
        ON CONFLICT
            DO NOTHING;
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
-- 7. АВТОМАТИЧЕСКОЕ УДАЛЕНИЕ ТЕМЫ ИЗ КАТЕГОРИИ
-- ==========================================================
CREATE OR REPLACE FUNCTION auto_remove_topic_from_category()
    RETURNS TRIGGER
    AS $$
DECLARE
    _cat_id int;
    _count int;
BEGIN
    SELECT
        cat_id
    INTO
        _cat_id
    FROM
        books
    WHERE
        id = OLD.book_id;
    IF _cat_id IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            _count
        FROM
            book_topics bt
            JOIN books b ON b.id = bt.book_id
        WHERE
            bt.topic_id = OLD.topic_id
            AND b.cat_id = _cat_id;
        IF _count = 0 THEN
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
-- 8. ПРИ СМЕНЕ КАТЕГОРИИ КНИГИ
-- ==========================================================
CREATE OR REPLACE FUNCTION recalc_topics_on_category_change()
    RETURNS TRIGGER
    AS $$
BEGIN
    -- Если категория не изменилась, выходим
    IF OLD.cat_id IS NOT DISTINCT FROM NEW.cat_id THEN
        RETURN NEW;
    END IF;
    -- Удаляем темы из старой категории, если их больше нет
    IF OLD.cat_id IS NOT NULL THEN
        DELETE FROM cat_topics ct
        WHERE ct.cat_id = OLD.cat_id
            AND NOT EXISTS(
                SELECT
                    1
                FROM
                    book_topics bt
                    JOIN books b ON b.id = bt.book_id
                WHERE
                    bt.topic_id = ct.topic_id
                    AND b.cat_id = OLD.cat_id);
    END IF;
    -- Добавляем все темы книги в новую категорию
    IF NEW.cat_id IS NOT NULL THEN
        INSERT INTO cat_topics(cat_id, topic_id)
        SELECT
            NEW.cat_id,
            bt.topic_id
        FROM
            book_topics bt
        WHERE
            bt.book_id = NEW.id
        ON CONFLICT
            DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_recalc_topics_on_category_change ON books;

CREATE TRIGGER trg_recalc_topics_on_category_change
    AFTER UPDATE OF cat_id ON books
    FOR EACH ROW
    EXECUTE FUNCTION recalc_topics_on_category_change();

