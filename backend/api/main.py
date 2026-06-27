import os
from contextlib import asynccontextmanager

import uvicorn
from api.core.config import settings
from api.core.db import db
from api.core.exceptions import BaseError
from api.core.ml import index_db
from api.routers import carts, catalog, media, orders, users
from fastapi import APIRouter, FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles


@asynccontextmanager
async def lifespan(app: FastAPI):
    await db.connect()
    await db.init_db()
    if settings.DB_SEED:
        await db.seed_data()
    if settings.ENABLE_ML:
        await index_db()
    yield
    await db.disconnect()


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    # Укажи точный адрес своего фронтенда (например, ["http://localhost:3000"])
    # Вместо "*" при работе с куками обязательно нужен явный список хостов!
    allow_origins=["*"],
    allow_credentials=True,  # РАЗРЕШАЕТ передавать HttpOnly куки между фронтом и бэком
    allow_methods=["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)
main_router = APIRouter(prefix="/api")

main_router.include_router(users.router)
main_router.include_router(orders.router)
main_router.include_router(catalog.router)
main_router.include_router(carts.router)
main_router.include_router(media.router)
app.include_router(main_router)


media_path = os.path.join(os.path.dirname(__file__), "..", "media")
os.makedirs(media_path, exist_ok=True)
app.mount("/media", StaticFiles(directory=media_path), name="media")


@app.exception_handler(BaseError)
async def error_handler(request: Request, exc: BaseError):
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": exc.__class__.__name__, "details": exc.message},
    )


@app.get("/health")
async def health_check():
    async with db.pool.acquire() as conn:
        result = await conn.fetchval("SELECT 1")
        return {"status": "ok", "db": result == 1}


if __name__ == "__main__":
    uvicorn.run("api.main:app", host=settings.API_HOST, port=settings.API_PORT, reload=True)
