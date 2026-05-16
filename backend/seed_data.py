import uuid

from api.core.config import settings
from api.core.db import db
from api.core.deps import hash_pwd


async def full_seed():
    async with db.pool.acquire() as conn:
        async with conn.transaction():
            print("Очистка старых данных...")
            # Удаляем данные каскадно, чтобы начать с чистого листа
            await conn.execute("""
                TRUNCATE TABLE users, authors, pubs, topics, cats, bindings, towns, streets, books, 
                carts, cart_items, orders, order_items, reviews, book_authors, book_topics, cat_topics 
                RESTART IDENTITY CASCADE;
            """)

            print("Заполнение справочников...")
            # 1. Авторы
            authors_data = [
                (
                    "Фёдор Достоевский",
                    "Русский писатель, мыслитель, философ и публицист.",
                    "/media/authors/dostoevsky.jpg",
                ),
                (
                    "Джордж Оруэлл",
                    "Британский писатель, публицист и критик.",
                    "/media/authors/orwell.jpg",
                ),
                (
                    "Говард Лавкрафт",
                    "Американский писатель и журналист, работавший в жанре ужасов.",
                    "/media/authors/lovecraft.jpg",
                ),
                (
                    "Лев Толстой",
                    "Один из наиболее известных писателей и мыслителей мира.",
                    "/media/authors/tolstoy.jpg",
                ),
            ]
            author_ids = []
            for name, bio, pic in authors_data:
                aid = await conn.fetchval(
                    "INSERT INTO authors (name, bio, picture_url) VALUES ($1, $2, $3) RETURNING id",
                    name,
                    bio,
                    pic,
                )
                author_ids.append(aid)

            # 2. Издательства
            pubs_data = [
                ("ЭКСМО", "Крупнейшее издательство в России.", "/media/pubs/eksmo.png"),
                (
                    "АСТ",
                    "Одно из крупнейших издательств на российском книжном рынке.",
                    "/media/pubs/ast.png",
                ),
                (
                    "Альпина Паблишер",
                    "Российское издательство, выпускающее деловую литературу.",
                    "/media/pubs/alpina.png",
                ),
            ]
            pub_ids = []
            for name, info, pic in pubs_data:
                pid = await conn.fetchval(
                    "INSERT INTO pubs (name, info, picture_url) VALUES ($1, $2, $3) RETURNING id",
                    name,
                    info,
                    pic,
                )
                pub_ids.append(pid)

            # 3. Темы (Теги)
            topics_data = ["Классика", "Антиутопия", "Ужасы", "Философия", "Детектив", "Психология"]
            topic_ids = []
            for name in topics_data:
                tid = await conn.fetchval(
                    "INSERT INTO topics (name) VALUES ($1) RETURNING id", name
                )
                topic_ids.append(tid)

            # 4. Категории (Иерархические)
            cat_fiction_id = await conn.fetchval(
                "INSERT INTO cats (name, parent_id) VALUES ($1, NULL) RETURNING id",
                "Художественная литература",
            )
            cat_nonfiction_id = await conn.fetchval(
                "INSERT INTO cats (name, parent_id) VALUES ($1, NULL) RETURNING id",
                "Нехудожественная литература",
            )

            cat_ids = [
                await conn.fetchval(
                    "INSERT INTO cats (name, parent_id) VALUES ($1, $2) RETURNING id",
                    "Русская классика",
                    cat_fiction_id,
                ),
                await conn.fetchval(
                    "INSERT INTO cats (name, parent_id) VALUES ($1, $2) RETURNING id",
                    "Зарубежная фантастика",
                    cat_fiction_id,
                ),
                await conn.fetchval(
                    "INSERT INTO cats (name, parent_id) VALUES ($1, $2) RETURNING id",
                    "Саморазвитие",
                    cat_nonfiction_id,
                ),
                await conn.fetchval(
                    "INSERT INTO cats (name, parent_id) VALUES ($1, $2) RETURNING id",
                    "Философские трактаты",
                    cat_nonfiction_id,
                ),
            ]

            # 5. Переплеты
            bindings_data = ["Твёрдый (7БЦ)", "Мягкий (КБС)", "Кожаный", "Интегральный"]
            for name in bindings_data:
                await conn.execute("INSERT INTO bindings (name) VALUES ($1)", name)

            # 6. География (Города и улицы через UUID)
            towns_data = [
                (uuid.uuid4(), "г. Оренбург"),
                (uuid.uuid4(), "г. Москва"),
                (uuid.uuid4(), "г. Санкт-Петербург"),
            ]
            for fias_id, name in towns_data:
                await conn.execute(
                    "INSERT INTO towns (fias_id, name) VALUES ($1, $2)", fias_id, name
                )

            streets_data = [
                (towns_data[0][0], uuid.uuid4(), "ул. Советская"),
                (towns_data[0][0], uuid.uuid4(), "ул. Новая"),
                (towns_data[1][0], uuid.uuid4(), "ул. Тверская"),
                (towns_data[2][0], uuid.uuid4(), "Невский проспект"),
            ]
            for town_id, fias_id, name in streets_data:
                await conn.execute(
                    "INSERT INTO streets (town_id, fias_id, name) VALUES ($1, $2, $3)",
                    town_id,
                    fias_id,
                    name,
                )

            print("Связывание Категорий и Тем...")
            # Таблица cat_topics
            await conn.executemany(
                "INSERT INTO cat_topics (cat_id, topic_id) VALUES ($1, $2)",
                [
                    (cat_ids[0], topic_ids[0]),
                    (cat_ids[0], topic_ids[3]),
                    (cat_ids[1], topic_ids[1]),
                    (cat_ids[1], topic_ids[2]),
                ],
            )

            print("Заполнение Книг...")
            # 7. Книги (Задаем базовые значения, счетчики накрутим апдейтом)
            books_data = [
                (
                    "Преступление и наказание",
                    "Роман о Родионе Раскольникове.",
                    450.00,
                    "978-5-699-90425-4",
                    672,
                    "Твёрдый (7БЦ)",
                    cat_ids[0],
                    pub_ids[0],
                ),
                (
                    "Идиот",
                    "Роман, в котором автор попытался изобразить прекрасного человека.",
                    520.00,
                    "978-5-17-112345-2",
                    640,
                    "Твёрдый (7БЦ)",
                    cat_ids[0],
                    pub_ids[1],
                ),
                (
                    "1984",
                    "Культовая антиутопия о тоталитарном государстве.",
                    320.00,
                    "978-5-17-080115-2",
                    320,
                    "Мягкий (КБС)",
                    cat_ids[1],
                    pub_ids[1],
                ),
                (
                    "Зов Ктулху",
                    "Сборник мистических и пугающих повестей.",
                    390.00,
                    "978-5-389-10522-5",
                    416,
                    "Твёрдый (7БЦ)",
                    cat_ids[1],
                    pub_ids[0],
                ),
                (
                    "Братья Карамазовы",
                    "Итоговый роман Федора Достоевского.",
                    600.00,
                    "978-5-699-95241-5",
                    800,
                    "Кожаный",
                    cat_ids[0],
                    pub_ids[2],
                ),
            ]
            book_ids = []
            for title, ann, price, isbn, pages, bind, cid, pid in books_data:
                bid = await conn.fetchval(
                    """
                    INSERT INTO books (title, annotation, price, isbn, page_count, binding, cat_id, pub_id)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id
                """,
                    title,
                    ann,
                    price,
                    isbn,
                    pages,
                    bind,
                    cid,
                    pid,
                )
                book_ids.append(bid)

            print("Связывание Книг с Авторами и Темами...")
            # M2M связи для книг
            await conn.executemany(
                "INSERT INTO book_authors (book_id, author_id) VALUES ($1, $2)",
                [
                    (book_ids[0], author_ids[0]),
                    (book_ids[1], author_ids[0]),
                    (book_ids[2], author_ids[1]),
                    (book_ids[3], author_ids[2]),
                    (book_ids[4], author_ids[0]),
                ],
            )
            await conn.executemany(
                "INSERT INTO book_topics (book_id, topic_id) VALUES ($1, $2)",
                [
                    (book_ids[0], topic_ids[0]),
                    (book_ids[0], topic_ids[3]),
                    (book_ids[0], topic_ids[5]),
                    (book_ids[1], topic_ids[0]),
                    (book_ids[1], topic_ids[5]),
                    (book_ids[2], topic_ids[1]),
                    (book_ids[2], topic_ids[3]),
                    (book_ids[3], topic_ids[2]),
                    (book_ids[4], topic_ids[0]),
                    (book_ids[4], topic_ids[3]),
                ],
            )

            print("Создание Пользователей и Адресов...")
            # 8. Пользователи
            hashed_pwd = hash_pwd("password123")
            users_data = [
                ("andrey@example.com", hashed_pwd, "/media/avatars/andrey.png"),
                (
                    settings.ADMIN_EMAIL,
                    hash_pwd(settings.ADMIN_PASSWORD),
                    "/media/avatars/admin.png",
                ),
                ("buyer@mail.ru", hashed_pwd, None),
            ]
            user_ids = []
            for email, hpwd, pic in users_data:
                uid = await conn.fetchval(
                    "INSERT INTO users (email, password_hash, picture_url) VALUES ($1, $2, $3) RETURNING id",
                    email,
                    hpwd,
                    pic,
                )
                user_ids.append(uid)

            # Адреса (Триггер func_build_full_address соберет строку full_address автоматически)
            await conn.execute(
                """
                INSERT INTO addresses (user_id, town_id, street_id, house, flat, fias_id, is_default)
                VALUES ($1, $2, $3, '15', '42', $4, TRUE)
            """,
                user_ids[0],
                streets_data[0][0],
                streets_data[0][1],
                uuid.uuid4(),
            )

            await conn.execute(
                """
                INSERT INTO addresses (user_id, town_id, street_id, house, flat, fias_id, is_default)
                VALUES ($1, $2, $3, '10', NULL, $4, TRUE)
            """,
                user_ids[2],
                streets_data[2][0],
                streets_data[2][1],
                uuid.uuid4(),
            )

            print("Создание Корзин и позиций...")
            # 9. Корзины
            cart_user_id = await conn.fetchval(
                "INSERT INTO carts (user_id) VALUES ($1) RETURNING id", user_ids[2]
            )
            cart_session_id = await conn.fetchval(
                "INSERT INTO carts (session_id) VALUES ($1) RETURNING id",
                "guest_session_uuid_example_123",
            )

            await conn.executemany(
                "INSERT INTO cart_items (cart_id, book_id, quantity) VALUES ($1, $2, $3)",
                [
                    (cart_user_id, book_ids[0], 1),
                    (cart_user_id, book_ids[2], 2),
                    (cart_session_id, book_ids[1], 1),
                ],
            )

            print("Заполнение Отзывов (Триггер рейтингов сработает здесь)...")
            # 10. Отзывы (Запускают триггер `trigger_update_rating` в таблице `books`)
            reviews_data = [
                (user_ids[0], book_ids[0], "Потрясающая глубина психологии героев. Шедевр!", 5),
                (user_ids[2], book_ids[0], "Немного затянуто, но развязка отличная.", 4),
                (user_ids[0], book_ids[2], "Пророческая книга, актуальная во все времена.", 5),
                (user_ids[2], book_ids[3], "Атмосферно, но язык автора тяжеловат.", 3),
            ]
            await conn.executemany(
                "INSERT INTO reviews (user_id, book_id, text, rating) VALUES ($1, $2, $3, $4)",
                reviews_data,
            )

            print("Заполнение Заказов...")
            # 11. Заказы и их позиции
            # Заказ 1
            o1_id = await conn.fetchval(
                """
                INSERT INTO orders (user_id, total_price, status, town_id, full_address)
                VALUES ($1, 1290.00, 'COMPLETED', $2, 'г. Оренбург, ул. Советская, д. 15, кв. 42') RETURNING id
            """,
                user_ids[0],
                streets_data[0][0],
            )
            await conn.executemany(
                "INSERT INTO order_items (order_id, book_id, price_at_purchase, quantity) VALUES ($1, $2, $3, $4)",
                [
                    (o1_id, book_ids[0], 450.00, 1),
                    (o1_id, book_ids[1], 520.00, 1),
                    (o1_id, book_ids[2], 320.00, 1),
                ],
            )

            # Заказ 2
            o2_id = await conn.fetchval(
                """
                INSERT INTO orders (user_id, total_price, status, town_id, full_address)
                VALUES ($1, 640.00, 'PENDING', $2, 'г. Москва, ул. Тверская, д. 10') RETURNING id
            """,
                user_ids[2],
                streets_data[2][0],
            )
            await conn.executemany(
                "INSERT INTO order_items (order_id, book_id, price_at_purchase, quantity) VALUES ($1, $2, $3, $4)",
                [(o2_id, book_ids[2], 320.00, 2)],
            )

            print("Накрутка просмотров и продаж для проверки триггера популярности...")
            # 12. Обновляем счетчики книг напрямую.
            # Это действие запустит триггер `trg_refresh_popularity`, который посчитает `popularity_score`.
            await conn.execute(
                "UPDATE books SET views_count = 142, sales_count = 12 WHERE id = $1", book_ids[0]
            )
            await conn.execute(
                "UPDATE books SET views_count = 89, sales_count = 5 WHERE id = $1", book_ids[1]
            )
            await conn.execute(
                "UPDATE books SET views_count = 310, sales_count = 45 WHERE id = $1", book_ids[2]
            )
            await conn.execute(
                "UPDATE books SET views_count = 64, sales_count = 2 WHERE id = $1", book_ids[3]
            )

            print("🚀 База данных успешно наполнена всеми тестовыми связями!")
