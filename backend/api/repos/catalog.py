from asyncpg import ForeignKeyViolationError, Pool, UniqueViolationError

from api.core.exceptions import AlreadExistsError, NotFoundError
from api.schemas.catalog import (
    AuthorCreate,
    AuthorInfo,
    AuthorRead,
    AuthorUpdate,
    BookCreate,
    BookFilter,
    BookInfo,
    BookRead,
    BookUpdate,
    CatCreate,
    CatRead,
    PubCreate,
    PubInfo,
    PubRead,
    PubUpdate,
    Sortby,
    TopicCreate,
    TopicRead,
)


class CatalogRepo:
    def __init__(self, pool: Pool):
        self.pool = pool

    async def get_books(self, filter: BookFilter) -> list[BookRead]:
        cat_path = None
        if filter.cat_id is not None:
            async with self.pool.acquire() as conn:
                cat_path = await conn.fetchval("SELECT path FROM cats WHERE id = $1", filter.cat_id)

        query = """--sql
        SELECT b.id, b.title, b.price, b.picture_url, b.mean_rating, b.reviews_count, b.is_new, b.is_bestseller
        FROM books b LEFT JOIN cats c ON b.cat_id = c.id 
        WHERE TRUE
        """
        params = []

        def add_condition(sql: str, value):
            nonlocal query
            if value is not None:
                params.append(value)
                query += f" AND {sql.replace('?', f'${len(params)}')} "

        if filter.cat_id is not None:
            cat_path = None
            async with self.pool.acquire() as conn:
                cat_path = await conn.fetchval("SELECT path FROM cats WHERE id = $1", filter.cat_id)
            if cat_path:
                params.extend([filter.cat_id, cat_path + "%"])
                query += f" AND (b.cat_id = ${len(params) - 1} OR c.path ILIKE ${len(params)})"
            else:
                add_condition("b.cat_id = ?", filter.cat_id)

        add_condition("b.price >= ?", filter.min_price)
        add_condition("b.price <= ?", filter.max_price)
        add_condition("b.is_new = ?", filter.is_new)
        add_condition("b.mean_rating >= ?", filter.min_rating)
        add_condition("b.pub_id = ANY(?::int[])", filter.pub_id)
        add_condition("b.binding_id = ANY(?::int[])", filter.binding_id)
        add_condition("b.is_new = ?", filter.is_new)
        add_condition("b.is_bestseller = ?", filter.is_bestseller)
        add_condition(
            """--sql 
            (SELECT array_agg(topic_id) FROM book_topics
            WHERE book_id = b.id) %% ?::int[] 
            """,
            filter.topic_id,
        )
        add_condition(
            """--sql 
            (SELECT array_agg(author_id) FROM book_authors 
            WHERE book_id = b.id) %% ?::int[] 
            """,
            filter.author_id,
        )
        if filter.search:
            params.append(f"%{filter.search}%")
            query += f" AND (b.title ILIKE ${len(params)} OR b.isbn ILIKE ${len(params)})"

        allowed_sorts = {"price": "price", "rating": "mean_rating"}
        sort = allowed_sorts.get(filter.sort_by, "popularity_score")
        direction = "DESC" if filter.reverse else "ASC"

        query += f" ORDER BY {sort} {direction} LIMIT ${len(params) + 1} OFFSET ${len(params) + 2}"
        params.extend([filter.limit, filter.offset])
        print(query)
        print(params[1])

        async with self.pool.acquire() as con:
            rows = await con.fetch(query, *params)
            return [BookRead(**dict(row)) for row in rows]

    async def get_book_by_id(self, id: int) -> BookInfo:
        query = """--sql 
            SELECT b.*,bi.name AS binding,
            (
                SELECT json_build_object(
                    'id',c.id,
                    'name',c.name,
                    'parent_id',c.parent_id )
                FROM cats c
                WHERE b.cat_id = c.id
            ) as cat,
            (
                SELECT json_build_object(
                'id',p.id,'name',p.name,'picture_url',p.picture_url)
                FROM pubs p
                WHERE b.pub_id = p.id
            ) as pub,
            (
                SELECT json_agg(
                    json_build_object(
                        'id',a.id,
                        'name',a.name))
                FROM authors a
                JOIN book_authors ba ON a.id = ba.author_id
                WHERE ba.book_id = b.id
            ) as authors,
            (
                SELECT json_agg(
                    json_build_object(
                        'id',t.id,
                        'name',t.name))
                FROM topics t
                JOIN book_topics bt ON t.id = bt.topic_id
                WHERE bt.book_id = b.id
            ) as topics
            FROM books b
            LEFT JOIN bindings bi ON b.binding_id = bi.id
            WHERE b.id = $1
        """
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, id)
            if not row:
                raise NotFoundError(f"Книга с ID {id} не найдена")
            return BookInfo(**dict(row))

    async def create_book(self, data: BookCreate) -> int:
        data_dict = data.model_dump(exclude=("author_ids", "topic_ids"))
        keys = data_dict.keys()
        values = [data_dict[k] for k in keys]
        cols = ",".join(keys)
        placeholders = ",".join([f"${i + 1}" for i in range(len(data_dict))])

        query = f"INSERT INTO books ({cols}) VALUES ({placeholders}) RETURNING id"
        try:
            async with self.pool.acquire() as conn:
                async with conn.transaction():
                    book_id = await conn.fetchval(query, *values)
                    if book_id and data.author_ids:
                        conn.executemany(
                            "INSERT INTO book_authors VALUES ($1, $2)",
                            [(book_id, a) for a in data.author_ids],
                        )
                    if book_id and data.topic_ids:
                        conn.executemany(
                            "INSERT INTO book_topics VALUES ($1, $2)",
                            [(book_id, t) for t in data.topic_ids],
                        )
                    return book_id
        except UniqueViolationError:
            raise AlreadExistsError(
                f"Не удалось добавить книгу. Книга с ISBN {data.isbn} уже существует"
            )
        except ForeignKeyViolationError:
            raise NotFoundError(
                "Не удалось добавить книгу, указанные категории, темы, авторы или издательства не найдены"
            )

    async def update_book(self, book_id: int, data: BookUpdate) -> bool:
        update_data = data.model_dump(exclude_unset=True)
        if not update_data:
            return False
        authors = update_data.pop("author_ids", None)
        topics = update_data.pop("topic_ids", None)
        try:
            async with self.pool.acquire() as conn:
                async with conn.transaction():
                    if update_data:
                        keys = list(update_data.keys())
                        set_clause = ", ".join([f"{k} = ${i + 2}" for i, k in enumerate(keys)])
                        values = [update_data[k] for k in keys]
                        query = f"UPDATE books SET {set_clause} WHERE id = $1"
                        result = await conn.execute(query, book_id, *values)
                        if result == "UPDATE 0":
                            return False
                    if authors is not None:
                        await conn.execute("DELETE FROM book_authors WHERE book_id = $1", book_id)
                        await conn.executemany(
                            "INSERT INTO book_authors (book_id, author_id) VALUES ($1, $2)",
                            [(book_id, a_id) for a_id in authors],
                        )
                    if topics is not None:
                        await conn.execute("DELETE FROM book_topics WHERE book_id = $1", book_id)
                        await conn.executemany(
                            "INSERT INTO book_topics (book_id, topic_id) VALUES ($1, $2)",
                            [(book_id, t_id) for t_id in topics],
                        )
                    return True
        except UniqueViolationError:
            raise AlreadExistsError(f"Не удалось обновить книгу. ISBN {data.isbn} уже есть в базе")
        except ForeignKeyViolationError:
            raise NotFoundError(
                "Не удалось обновить книгу. Указанные категории, темы, авторы или издательства отстуствуют в базе"
            )

    async def delete_book(self, book_id: int):
        query = "DELETE FROM books WHERE id = $1"
        async with self.pool.acquire() as conn:
            res = await conn.execute(query, book_id)

    async def update_book_views_count(self, id: int, count: int | None = None):
        query = "UPDATE books SET views_count = views_count + $2 WHERE id = $1"
        async with self.pool.acquire() as conn:
            await conn.execute(query, id, count if count and count > 0 else 1)

    async def get_author_by_id(self, id: int) -> AuthorInfo:
        query = "SELECT a.id, a.name, a.picture_url, a.bio FROM authors a WHERE a.id = $1"
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, id)
            if not row:
                raise NotFoundError("Автор не найден")
            return AuthorInfo(**dict(row))

    async def create_author(self, author: AuthorCreate) -> int:
        query = "INSERT INTO authors (name, picture_url, bio )VALUES ($1, $2, $3) RETURNING id"
        async with self.pool.acquire() as conn:
            return await conn.fetchval(query, author.name, author.picture_url, author.bio)

    async def update_author(self, id: int, author: AuthorUpdate) -> bool:
        data = author.model_dump(exclude_unset=True)
        if data:
            keys = list(data.keys())
            set_clause = ", ".join([f"{k} = ${i + 2}" for i, k in enumerate(keys)])
            values = [data[k] for k in keys]
            query = f"UPDATE authors SET {set_clause} WHERE id = $1"
            async with self.pool.acquire() as conn:
                res = await conn.execute(query, id, *values)
                return res == "UPDATE 1"

    async def delete_author(self, id: int) -> bool:
        async with self.pool.acquire() as conn:
            res = await conn.execute("DELETE FROM authors WHERE id = $1", id)
            return res == "DELETE 1"

    async def create_pub(self, pub: PubCreate) -> int:
        query = "INSERT INTO pubs (name,info,picture_url) VALUES ($1, $2, $3) RETURNING id"
        try:
            async with self.pool.acquire() as conn:
                return await conn.fetchval(query, pub.name, pub.info, pub.picture_url)
        except UniqueViolationError:
            raise AlreadExistsError(f"Издательство с названием {pub.name} уже существует")

    async def update_pub(self, id: int, pub: PubUpdate):
        data = pub.model_dump(exclude_unset=True)
        keys = list(data.keys())
        values = [data[k] for k in keys]
        set_clause = ",".join([f"{k} = ${i + 2}" for i, k in enumerate(data.keys())])
        query = f"""UPDATE pubs SET {set_clause} WHERE id = $1"""
        try:
            async with self.pool.acquire() as conn:
                await conn.execute(query, id, *values)
        except UniqueViolationError:
            raise AlreadExistsError(
                f"Не удалось обновить издательство. Издательство с названием {pub.name} уже существует"
            )

    async def get_pub_by_id(self, id: int) -> PubInfo:
        query = "SELECT p.id, p.name, p.picture_url, p.info FROM pubs p WHERE p.id = $1"
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, id)
            if row is None:
                raise NotFoundError("Издательство не найдено")
            return PubInfo(**dict(row))

    async def delete_pub(self, id: int) -> bool:
        async with self.pool.acquire() as conn:
            res = await conn.execute("DELETE FROM pubs WHERE id = $1", id)
            return res == "DELETE 1"

    async def create_topic(self, topic: TopicCreate) -> int:
        query = """--sql
        INSERT INTO topics (name) VALUES ($1) 
        ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
        RETURNING id
        """
        async with self.pool.acquire() as conn:
            return await conn.fetchval(query, topic.name)

    async def delete_topic(self, id: int):
        async with self.pool.acquire() as conn:
            await conn.execute("DELETE FROM topics WHERE id = $1", id)

    async def get_topics(self, cat_id: int | None = None) -> list[TopicRead]:
        async with self.pool.acquire() as conn:
            if cat_id is None:
                res = await conn.fetch("SELECT t.* from topics t")
                return [TopicRead(**dict(row)) for row in res]
            else:
                query = """--sql
                SELECT DISTINCT t.id, t.name FROM topics t
                JOIN cat_topics ct ON t.id = ct.topic_id
                JOIN cats c on ct.cat_id = c.id
                WHERE c.id = $1
                """
                path = await conn.fetchval("SELECT path FROM cats WHERE id = $1", cat_id)
                if path:
                    query += "OR c.path LIKE $2"
                    res = await conn.fetch(query, cat_id, path + "%")
                else:
                    res = await conn.fetch(query, cat_id)
                return [TopicRead(**dict(row)) for row in res]

    async def link_topic(self, topic_id: int, cat_id: int):
        query = """--sql
        INSERT INTO cat_topics (topic_id,cat_id) VALUES ($1, $2)
        ON CONFLICT (topic_id,cat_id) DO NOTHING
        """
        try:
            async with self.pool.acquire() as conn:
                await conn.execute(query, topic_id, cat_id)
        except ForeignKeyViolationError:
            raise NotFoundError(
                "Не удалось связать тему и категория. Тема или категория отсутствует в базе"
            )

    async def delink_topic(self, topic_id: int, cat_id: int):
        async with self.pool.acquire() as conn:
            await conn.execute(
                "DELETE FROM cat_topics WHERE topic_id = $1 and cat_id = $2", topic_id, cat_id
            )

    async def create_cat(self, cat: CatCreate) -> int:
        query = """--sql
        INSERT INTO cats (name,parent_id) VALUES ($1, $2) 
        ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
        RETURNING id
        """
        try:
            async with self.pool.acquire() as conn:
                return await conn.fetchval(query, cat.name, cat.parent_id)
        except ForeignKeyViolationError:
            raise NotFoundError("Не удалось добавить категорию. Не найдена родительская категория")

    async def delete_cat(self, id: int):
        async with self.pool.acquire() as conn:
            await conn.execute("DELETE FROM cats WHERE id = $1", id)

    async def get_cats(self) -> CatRead:
        async with self.pool.acquire() as conn:
            rows = await conn.fetch("SELECT * FROM cats ORDER BY path")
            return [CatRead(**dict(row)) for row in rows]

    async def update_book_picture(self, book_id: int, url: str) -> str:
        query = """--sql
        WITH old AS (SELECT picture_url FROM books WHERE id = $2)
        UPDATE books SET picture_url = $1 WHERE id = $1
        RETURNING (SELECT picture_url FROM old)
        """
        async with self.pool.acquire() as conn:
            return await conn.fetchval(query, url, book_id)

    async def update_author_picture(self, author_id: int, url: str) -> str:
        query = """--sql
        WITH old AS (SELECT picture_url FROM authors WHERE id = $2)
        UPDATE authors SET picture_url = $1 WHERE id = $1
        RETURNING (SELECT picture_url FROM old)
        """
        async with self.pool.acquire() as conn:
            await conn.fetchval(query, url, author_id)

    async def update_pub_picture(self, pub_id: int, url: str) -> str:
        query = """--sql
        WITH old AS (SELECT picture_url FROM pubs WHERE id = $2)
        UPDATE pubs SET picture_url = $1 WHERE id = $1
        RETURNING (SELECT picture_url FROM old)
        """
        async with self.pool.acquire() as conn:
            return await conn.fetchval(query, url, pub_id)
