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

-- -- 5. АВТО-РАСЧЕТ СУММЫ ЗАКАЗА
-- CREATE OR REPLACE FUNCTION calculate_order_total()
--     RETURNS TRIGGER
--     AS $$
-- BEGIN
--     UPDATE
--         orders
--     SET
--         total_price =(
--             SELECT
--                 SUM(price_at_purchase * quantity)
--             FROM
--                 order_items
--             WHERE
--                 order_id = COALESCE(NEW.order_id, OLD.order_id))
--     WHERE
--         id = COALESCE(NEW.order_id, OLD.order_id);
--     RETURN NULL;
-- END;
-- $$
-- LANGUAGE plpgsql;
-- DROP TRIGGER IF EXISTS trigger_update_order_total ON order_items;
-- CREATE TRIGGER trigger_update_order_total
--     AFTER INSERT OR UPDATE OR DELETE ON order_items
--     FOR EACH ROW
--     EXECUTE PROCEDURE calculate_order_total();
