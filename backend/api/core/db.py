import json
import random
import uuid

import asyncpg
from api.core.config import settings
from asyncpg import Pool


async def init_connection(conn):
    # Регистрируем встроенный кодек для типов json и jsonb
    await conn.set_type_codec("json", encoder=json.dumps, decoder=json.loads, schema="pg_catalog")
    await conn.set_type_codec("jsonb", encoder=json.dumps, decoder=json.loads, schema="pg_catalog")


class Database:
    def __init__(self):
        self.pool: asyncpg.Pool | None = None

    async def connect(self):
        self.pool = await asyncpg.create_pool(
            settings.DB_URL, min_size=5, max_size=20, max_queries=1000, init=init_connection
        )
        print("✅ Connection pool created")

    async def disconnect(self):
        if self.pool:
            await self.pool.close()
        print("🛑 Connection pool closed")

    async def init_db(self):
        with open("db.sql", "r") as f:
            db = f.read()
        with open("triggers.sql", "r") as f:
            triggers = f.read()
        async with self.pool.acquire() as conn:
            await conn.execute(db)
            await conn.execute(triggers)

    async def seed_data(self):
        with open("seed_data.sql", "r") as f:
            data = f.read()
        async with self.pool.acquire() as conn:
            await conn.execute(data)


db = Database()
