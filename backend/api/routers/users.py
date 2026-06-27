from fastapi import APIRouter, Depends, Query, Request, Response
from typing_extensions import Annotated

from api.core.config import settings
from api.core.deps import (
    create_access_token,
    create_refresh_token,
    decode_token,
    delete_cookies,
    get_current_user,
    get_current_user_id,
    get_optional_user_id,
    get_session_id,
    get_user_repo,
    hash_pwd,
    verify_pwd,
)
from api.core.exceptions import UnauthorizedError
from api.repos.users import UserRepo
from api.schemas.users import (
    AddressCreate,
    ReviewCreate,
    ReviewFilter,
    ReviewRead,
    UserBase,
    UserInfo,
    UserRead,
)

router = APIRouter(prefix="/users", tags=["Users"])


@router.post("/register")
async def register(
    response: Response,
    user: UserBase,
    session_id: str | None = Depends(get_session_id),
    repo: UserRepo = Depends(get_user_repo),
) -> dict:
    user.password = hash_pwd(user.password)
    user_id = await repo.create_user(user)
    access, refresh = create_access_token(user_id), create_refresh_token(user_id)
    response.set_cookie("access_token", access, httponly=True)
    response.set_cookie("refresh_token", refresh, httponly=True)
    user_cart_id = await repo.get_or_create_cart_id(user_id=user_id)
    session_cart_id = await repo.get_or_create_cart_id(session_id=session_id)
    if session_cart_id:
        await repo.merge_carts(session_cart_id, user_cart_id)
        response.delete_cookie("session_id")
    return {"status": "success"}


@router.post("/login")
async def login(
    response: Response,
    user: UserBase,
    session_id: str | None = Depends(get_session_id),
    repo: UserRepo = Depends(get_user_repo),
) -> dict:
    data = await repo.get_user_by_email(user.email)
    if not data or not verify_pwd(user.password, data.password):
        raise UnauthorizedError("You are not authorized")
    access, refresh = create_access_token(data.id), create_refresh_token(data.id)
    response.set_cookie("access_token", access, httponly=True)
    response.set_cookie("refresh_token", refresh, httponly=True)
    user_cart_id = await repo.get_or_create_cart_id(user_id=data.id)
    session_cart_id = await repo.get_or_create_cart_id(session_id=session_id)
    if session_cart_id:
        await repo.merge_carts(session_cart_id, user_cart_id)
        response.delete_cookie("session_id")
    return {"status": "success"}


@router.get("/logout")
async def logout(response: Response, user_id: int = Depends(get_current_user_id)) -> dict:
    delete_cookies(response)
    return {"status": "success"}


@router.get("/refresh")
async def refresh(request: Request, response: Response) -> dict:
    refresh_token = request.cookies.get("refresh_token")
    if not refresh_token:
        raise UnauthorizedError("Отсутствует refresh-токен")
    payload = decode_token(refresh_token)
    if not payload or payload["type"] != "refresh":
        raise UnauthorizedError("Невалидный refresh-токен. Авторизуйтесь заново")
    access = create_access_token(payload["user_id"])
    response.set_cookie("access_token", access, httponly=True)
    return {"status": "success"}


@router.get("/me", response_model=UserInfo)
async def get_me(
    user: UserRead = Depends(get_current_user), repo: UserRepo = Depends(get_user_repo)
) -> UserInfo:
    return await repo.get_user_by_id(user.id)


@router.post("/reviews")
async def add_review(
    book_id: int,
    review: ReviewCreate,
    user: UserRead = Depends(get_current_user),
    repo: UserRepo = Depends(get_user_repo),
) -> dict:
    await repo.create_review(user.id, id, review)
    return {"status": "success"}


@router.get("/reviews", response_model=list[ReviewRead])
async def get_reviews(
    filter: Annotated[ReviewFilter, Query()],
    user_id: int | None = Depends(get_optional_user_id),
    repo: UserRepo = Depends(get_user_repo),
) -> list[ReviewRead]:
    if filter.user_id is not None:
        if not user_id or filter.user_id != user_id:
            filter.user_id = user_id
    return await repo.get_reviews(filter)


@router.post("/address")
async def add_address(
    address: AddressCreate,
    user: UserRead = Depends(get_current_user),
    repo: UserRepo = Depends(get_user_repo),
):
    await repo.create_address(user.id, address)
    return {"status": "success"}


@router.get("/addresses")
async def get_addresses(
    user: UserRead = Depends(get_current_user), repo: UserRepo = Depends(get_user_repo)
):
    if user.email != settings.ADMIN_EMAIL:
        return await repo.get_addresses(user.id)
    else:
        return await repo.get_addresses()


@router.delete("/address")
async def delete_address(
    fias_id: str,
    user: UserRead = Depends(get_current_user),
    repo: UserRepo = Depends(get_user_repo),
):
    await repo.delete_address(user.id, fias_id)
