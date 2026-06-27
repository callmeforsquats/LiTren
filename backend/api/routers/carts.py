from fastapi import APIRouter, Depends, Request, Response, status

from api.core.deps import (
    create_session_id,
    get_optional_user_id,
    get_session_id,
    get_user_repo,
)
from api.repos.users import UserRepo
from api.schemas.users import ItemCreate, ItemRead  # Схемы из нашего общего файла

router = APIRouter(prefix="/cart", tags=["Cart"])


@router.get("", response_model=list[ItemRead])
async def get_cart(
    request: Request,
    user_id: int | None = Depends(get_optional_user_id),
    repo: UserRepo = Depends(get_user_repo),
):
    """Посмотреть состав текущей корзины (работает и для гостей, и для юзеров)."""
    if user_id:
        cart_id = await repo.get_or_create_cart_id(user_id=user_id)
        return await repo.get_cart(cart_id)

    session_id = get_session_id(request)
    if not session_id:
        return []

    cart_id = await repo.get_or_create_cart_id(session_id=session_id)
    return await repo.get_cart(cart_id)


@router.post("/items", response_model=list[ItemRead])
async def upsert_cart_item(
    item: ItemCreate,
    request: Request,
    response: Response,
    user_id: int | None = Depends(get_optional_user_id),
    repo: UserRepo = Depends(get_user_repo),
):
    """Добавить книгу в корзину или изменить её количество (Upsert)."""
    if user_id:
        cart_id = await repo.get_or_create_cart_id(user_id=user_id)
    else:
        session_id = get_session_id(request)
        if not session_id:
            session_id = create_session_id(response)
        cart_id = await repo.get_or_create_cart_id(session_id=session_id)
    await repo.upsert_cart_item(cart_id, item)
    return await repo.get_cart(cart_id)


@router.delete("/items/{book_id}", response_model=list[ItemRead])
async def delete_cart_item(
    book_id: int,
    request: Request,
    user_id: int | None = Depends(get_optional_user_id),
    repo: UserRepo = Depends(get_user_repo),
):
    """Удалить книгу из корзины."""
    if user_id:
        cart_id = await repo.get_or_create_cart_id(user_id=user_id)
        await repo.delete_cart_item(cart_id=cart_id, book_id=book_id)
        return await repo.get_cart(cart_id)

    session_id = get_session_id(request)
    if session_id:
        cart_id = await repo.get_or_create_cart_id(session_id=session_id)
        await repo.delete_cart_item(cart_id=cart_id, book_id=book_id)
        return await repo.get_cart(cart_id)
