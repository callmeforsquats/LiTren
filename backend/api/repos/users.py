from curses import nonl
from uuid import UUID

from api.core.exceptions import AlreadExistsError, NotFoundError
from api.schemas.catalog import BookRead
from api.schemas.users import (
    AddressCreate,
    AddressRead,
    ItemCreate,
    ItemRead,
    OrderCreate,
    OrderFilter,
    OrderInfo,
    OrderRead,
    ReviewCreate,
    ReviewFilter,
    ReviewInfo,
    ReviewRead,
    UserBase,
    UserInfo,
    UserRead,
)
from asyncpg import ForeignKeyViolationError, Pool, UniqueViolationError


class UserRepo:
    def __init__(self, pool: Pool):
        self.pool = pool

    async def get_user_by_id(self, id: int) -> UserInfo | None:
        query = "SELECT u.id, u.email,u.picture_url,u.created_at FROM users u WHERE u.id = $1"
        async with self.pool.acquire() as conn:
            res = await conn.fetchrow(query, id)
            return UserInfo(**dict(res))

    async def create_user(self, user: UserBase) -> int:
        query = "INSERT INTO users (email,password_hash) VALUES ($1, $2) RETURNING id"
        try:
            async with self.pool.acquire() as conn:
                return await conn.fetchval(query, user.email, user.password)
        except UniqueViolationError:
            raise AlreadExistsError(
                f"Не удалось добавить пользователя. Пользователь с email {user.email} уже зарегистрирован"
            )

    async def get_user_by_email(self, email: str) -> UserRead | None:
        query = "SELECT u.id, u.email, u.password_hash AS password FROM users u WHERE u.email = $1"
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, email)
            return UserRead(**dict(row)) if row else None

    async def delete_user(self, id: int):
        query = "DELETE FROM users WHERE id = $1"
        async with self.pool.acquire() as conn:
            await conn.execute(query, id)

    async def get_session_cart_id(self, session_id: int | None = None) -> int | None:
        if not session_id:
            return None
        async with self.pool.acquire() as conn:
            return await conn.fetchval("SELECT id FROM carts WHERE session_id = $1", session_id)

    async def get_or_create_cart_id(
        self, user_id: int | None = None, session_id: int | None = None
    ) -> int:
        async with self.pool.acquire() as conn:
            if user_id:
                query = """--sql
                INSERT INTO carts (user_id) VALUES ($1)
                ON CONFLICT (user_id) DO UPDATE SET user_id = EXCLUDED.user_id
                RETURNING id
                """
                return await conn.fetchval(query, user_id)
            elif session_id:
                query = """--sql
                INSERT INTO carts (session_id) VALUES ($1)
                ON CONFLICT (session_id) DO UPDATE SET session_id = EXCLUDED.session_id
                RETURNING id
                """
                return await conn.fetchval(query, session_id)

    async def get_cart(self, cart_id: int) -> list[ItemRead]:
        query = """--sql
        SELECT b.id AS book_id, b.title, b.price, b.picture_url, ci.quantity
        FROM cart_items ci
        JOIN books b ON ci.book_id = b.id
        WHERE ci.cart_id = $1
        """
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, cart_id)
            return [ItemRead(**dict(row)) for row in rows]

    async def upsert_cart_item(self, cart_id: int, item: ItemCreate):
        query = """--sql 
        INSERT INTO cart_items (cart_id,book_id,quantity) VALUES ($1, $2, $3)
        ON CONFLICT (cart_id,book_id) DO UPDATE SET quantity = $3
        """
        try:
            async with self.pool.acquire() as conn:
                await conn.execute(query, cart_id, item.book_id, item.quantity)
        except ForeignKeyViolationError:
            raise NotFoundError(
                "Не удалось добавить/обновить товар в корзине. Указанный товар или корзина отсутствуют"
            )

    async def delete_cart_item(self, cart_id: int, book_id: int):
        query = "DELETE FROM cart_items WHERE cart_id = $1 AND book_id = $2"
        async with self.pool.acquire() as conn:
            await conn.execute(query, cart_id, book_id)

    async def merge_carts(self, source_id: int, target_id: int):
        query = """--sql
        INSERT INTO cart_items (cart_id,book_id,quantity)
        SELECT $2,book_id,quantity FROM cart_items WHERE cart_id = $1
        ON CONFLICT (cart_id, book_id) DO UPDATE SET quantity = cart_items.quantity + EXCLUDED.quantity
        """
        try:
            async with self.pool.acquire() as conn:
                async with conn.transaction():
                    await conn.execute(query, source_id, target_id)
                    await conn.execute("DELETE FROM carts WHERE id = $1", source_id)
        except ForeignKeyViolationError:
            raise NotFoundError(
                "Не удалось соединить корзины. Одна или несколько корзин отсутствуют"
            )

    async def create_order(self, order: OrderCreate, user_id: int) -> int:
        order_query = "INSERT INTO orders (user_id,total_price,full_address,town_id) VALUES ($1, $2,$3,$4) RETURNING id"
        address_query = "SELECT DISTINCT full_address, town_id FROM addresses WHERE fias_id = $1"
        prices_query = "SELECT id, price FROM books  WHERE id = ANY($1::int[])"
        quantity_query = "SELECT book_id, quantity FROM cart_items WHERE cart_id = $1 AND book_id = ANY($2::int[])"
        order_items_query = """INSERT INTO order_items (order_id,book_id,price_at_purchase,quantity) 
                               VALUES ($1,$2,$3,$4)"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                addr_row = await conn.fetchrow(address_query, order.address_id)
                if not addr_row:
                    raise NotFoundError("Не удалось создать заказ. Указан несуществующий адрес")
                full_address, town_id = addr_row["full_address"], addr_row["town_id"]
                cart_id = await conn.fetchval("SELECT id FROM carts WHERE user_id = $1", user_id)
                prows = await conn.fetch(prices_query, order.items)
                qrows = await conn.fetch(quantity_query, cart_id, order.items)
                if len(order.items) != len(prows) or len(order.items) != len(qrows):
                    raise NotFoundError("Не удалось создать заказ. Указанные товары отсутствуют")
                prices = {r["id"]: r["price"] for r in prows}
                quantities = {r["book_id"]: r["quantity"] for r in qrows}
                total_price = sum(prices[id] * quantities[id] for id in order.items)
                order_id = await conn.fetchval(
                    order_query, user_id, total_price, full_address, town_id
                )
                order_items = [
                    (order_id, id, prices[id], quantities[id])
                    for id in order.items
                    if id in quantities
                ]
                sales_updates = [(item[1], item[3]) for item in order_items]
                await conn.executemany(order_items_query, order_items)
                await conn.execute("DELETE FROM cart_items WHERE cart_id = $1", cart_id)
                await conn.executemany(
                    "UPDATE books SET sales_count = books.sales_count + $2 WHERE id = $1",
                    sales_updates,
                )

                return order_id

    async def get_orders(self, filter: OrderFilter) -> list[OrderRead]:
        query = """--sql
        SELECT o.id, o.status, o.total_price, o.full_address, o.created_at
        FROM orders o
        LEFT JOIN order_items oi ON o.id = oi.order_id
        WHERE TRUE
        """
        params = []

        def add_condition(sql: str, value):
            nonlocal query
            if value is not None:
                params.append(value)
                query += f" AND {sql.replace('?', f'${len(params)}')} "

        add_condition("oi.book_id = ?", filter.book_id)
        add_condition("o.user_id = ?", filter.user_id)
        add_condition("o.town_id = ?", filter.town_id)
        add_condition("o.total_price >= ?", filter.min_price)
        add_condition("o.total_price <= ?", filter.max_price)
        if filter.status:
            params.append(f"%{filter.status}%")
            query += f"o.status ILIKE  ${len(params)} "
        query += """--sql
        GROUP BY o.id, o.status, o.total_price, o.full_address, o.created_at 
        ORDER BY o.created_at DESC
        """
        if filter.limit is not None:
            params.extend([filter.limit, filter.offset])
            query += f"LIMIT ${len(params) - 1} OFFSET ${len(params)} "

        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, *params)
            return [OrderRead(**dict(row)) for row in rows]

    async def get_order(self, id: int, user_id: int | None = None) -> OrderInfo:
        query = """--sql
        SELECT o.id, o.status, o.total_price, o.full_address, o.created_at,
        COALESCE(
            (
                SELECT json_agg(json_build_object(
                    'book_id',b.id,
                    'title',b.title,
                    'price',oi.price_at_purchase,
                    'picture_url',b.picture_url,
                    'quantity',oi.quantity
                ))
                FROM order_items oi
                JOIN books b ON oi.book_id = b.id
                WHERE oi.order_id = o.id
            ),'[]'::json
        ) as items
        FROM orders o WHERE o.id = $1
        """
        params = [id]
        if user_id is not None:
            query += " AND o.user_id = $2"
            params.append(user_id)
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, *params)
            if not row:
                raise NotFoundError("Заказ не найден")
            return OrderInfo(**dict(row))

    async def create_address(self, user_id: int, address: AddressCreate) -> str:
        town_query = """--sql
        INSERT INTO towns (fias_id,name) VALUES ($1, $2)
        ON CONFLICT (fias_id) DO NOTHING
        """
        street_query = """--sql
        INSERT INTO streets (town_id,fias_id,name) VALUES ($1,$2,$3)
        ON CONFLICT (fias_id) DO NOTHING
        """
        address_query = """--sql
        INSERT INTO addresses (user_id,town_id,street_id,house,flat,fias_id,is_default)
        VALUES ($1,$2,$3,$4,$5,$6,$7)
        ON CONFLICT (user_id,fias_id) DO UPDATE SET fias_id = EXCLUDED.fias_id
        RETURNING fias_id
        """
        a, t, s = address, address.town, address.street
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.fetchval(town_query, t.fias_id, t.name)
                await conn.fetchval(street_query, t.fias_id, s.fias_id, s.name)
                return await conn.fetchval(
                    address_query,
                    user_id,
                    t.fias_id,
                    s.fias_id,
                    a.house,
                    a.flat,
                    a.fias_id,
                    a.is_default or False,
                )

    async def delete_address(self, user_id: int, fias_id: UUID):
        query = "DELETE FROM addresses WHERE fias_id = $1 AND user_id = $2"
        async with self.pool.acquire() as conn:
            await conn.execute(query, fias_id, user_id)

    async def get_addresses(self, user_id: int | None = None) -> list[AddressRead]:
        query = "SELECT a.full_address, a.fias_id FROM addresses a WHERE TRUE"
        async with self.pool.acquire() as conn:
            rows = None
            if user_id is not None:
                query += " AND a.user_id = $1"
                rows = await conn.fetch(query, user_id)
            else:
                rows = await conn.fetch(query)
            return [AddressRead(**dict(row)) for row in rows]

    async def set_default_address(self, user_id: int, fias_id: UUID):
        query = "UPDATE addresses SET is_default = (fias_id = $1) WHERE user_id = $2"
        async with self.pool.acquire() as conn:
            res = await conn.execute(query, fias_id, user_id)
            if res == "UPDATE = 0":
                raise NotFoundError(
                    "Не удалось установить адрес по умолчанию. Указанный адрес отсутствует"
                )

    async def create_review(self, user_id: int, book_id, review: ReviewCreate):
        query = (
            "INSERT INTO reviews (user_id,book_id,rating,text) VALUES ($1, $2, $3, $4) RETURNING id"
        )
        try:
            async with self.pool.acquire() as conn:
                await conn.execute(query, user_id, book_id, review.rating, review.text)
        except ForeignKeyViolationError:
            raise NotFoundError("Не удалось добавить отзыв. Указанная книга отсутствует")

    async def get_reviews(self, filter: ReviewFilter) -> list[ReviewRead]:
        query = """--sql
        SELECT r.id, r.rating, r.created_at, r.book_id,b.title AS book_title
        FROM reviews JOIN books b ON r.book_id = b.id 
        WHERE TRUE
        """
        params = []

        def add_condition(sql: str, value):
            nonlocal query
            if value is not None:
                params.append(value)
                query += f" AND {sql.replace('?', f'${len(params)}')} "

        add_condition("user_id = ?", filter.user_id)
        add_condition("book_id = ?", filter.book_id)
        add_condition("rating >= ?", filter.min_rating)
        add_condition("rating <= ?", filter.max_rating)
        sort = "rating" if filter.bad_first or filter.good_first else "created_at"
        order = "ASC" if filter.bad_first else "DESC"
        query += f"ORDER BY {order} {sort} LIMIT ${len(params) + 1} OFFSET {len(params) + 2}"
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, *filter.model_dump(exclude_unset=True))
            return [ReviewRead(**row) for row in rows]

    async def get_review_by_id(self, id: int):
        query = """--sql
        SELECT r.id, r.rating, r.created_at, r.book_id, b.title AS book_title, r.text
        FROM reviews JOIN books b ON r.book_id = b.id 
        WHERE r.id = $1
        """
        async with self.pool.acquire() as conn:
            row = await conn.fetch(query, id)
            if not row:
                raise NotFoundError("Отзыв не найден")
            return ReviewInfo(**row)

    async def update_user_picture(self, user_id: int, url: str):
        async with self.pool.acquire() as conn:
            await conn.execute("UPDATE users SET picture_url = $1 WHERE id = $2", url, user_id)
