import uuid
from datetime import datetime, timedelta, timezone

import bcrypt
from api.core.config import settings
from api.core.db import db
from api.core.exceptions import PermissionDeniedError, UnauthorizedError, UserNotFoundError
from api.repos.catalog import CatalogRepo
from api.repos.users import UserRepo
from api.schemas.users import UserRead
from fastapi import Depends, Request, Response
from jose import JWTError, jwt


def get_user_repo():
    return UserRepo(db.pool)


def get_catalog_repo():
    return CatalogRepo(db.pool)


# --- ХЭШИРОВАНИЕ ---
def hash_pwd(pwd: str) -> str:
    pwd_bytes = pwd.encode("utf-8")
    salt = bcrypt.gensalt()
    hash = bcrypt.hashpw(pwd_bytes, salt)
    return hash.decode("utf-8")


def verify_pwd(pwd: str, hash: str) -> bool:
    return bcrypt.checkpw(pwd.encode("utf-8"), hash.encode("utf-8"))


# --- РАБОТА С JWT ---
def create_access_token(user_id: int) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_MINUTES)
    to_encode = {"user_id": user_id, "exp": int(expire.timestamp()), "type": "access"}
    return jwt.encode(to_encode, settings.SECRET_KEY, settings.JWT_ALGORITHM)


def create_refresh_token(user_id: int) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_DAYS)
    to_encode = {"user_id": user_id, "exp": int(expire.timestamp()), "type": "refresh"}
    return jwt.encode(to_encode, settings.SECRET_KEY, settings.JWT_ALGORITHM)


def decode_token(token: str) -> dict | None:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, settings.JWT_ALGORITHM)
        return payload
    except JWTError:
        return None


def delete_cookies(response: Response):
    response.delete_cookie("access_token")
    response.delete_cookie("refresh_token")


# --- ЗАВИСИМОСТИ АВТОРИЗАЦИИ ---


def get_optional_user_id(request: Request) -> int | None:
    access_token = request.cookies.get("access_token")
    if not access_token:
        return None
    payload = decode_token(access_token)
    if not payload or payload.get("type") != "access":
        return None
    return payload.get("user_id")


def get_current_user_id(user_id: int | None = Depends(get_optional_user_id)) -> int:
    if not user_id:
        raise UnauthorizedError(message="Необходима авторизация")
    return user_id


async def get_current_user(
    user_id: int = Depends(get_current_user_id), repo: UserRepo = Depends(get_user_repo)
) -> UserRead:
    user = await repo.get_user_by_id(user_id)
    if not user:
        raise UserNotFoundError(message="Пользователь не найден")
    return user


def check_admin(user: UserRead = Depends(get_current_user)):
    if user.email != settings.ADMIN_EMAIL:
        raise PermissionDeniedError(message="Доступ запрещен. Вы не являетесь администратором")


# --- СЕССИИ И КОРЗИНЫ ---
def get_session_id(request: Request) -> str | None:
    return request.cookies.get("session_id")


def create_session_id(response: Response) -> str:
    session_id = str(uuid.uuid4())
    response.set_cookie(
        key="session_id",
        value=session_id,
        httponly=True,
        max_age=3600 * 24 * 30,
        samesite="lax",
    )
    return session_id
