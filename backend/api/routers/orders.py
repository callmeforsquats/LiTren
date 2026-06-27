from fastapi import APIRouter, Depends, Query
from typing_extensions import Annotated

from api.core.config import settings
from api.core.deps import check_admin, get_current_user, get_current_user_id, get_user_repo
from api.repos.users import UserRepo
from api.schemas.users import ItemRead, OrderCreate, OrderFilter, OrderInfo, OrderRead, UserRead

router = APIRouter(prefix="/orders", tags=["Orders"])


@router.post("", response_model=OrderInfo)
async def create_order(
    order: OrderCreate,
    user: UserRead = Depends(get_current_user),
    repo: UserRepo = Depends(get_user_repo),
) -> OrderInfo:
    order_id = await repo.create_order(order, user.id)
    return await repo.get_order(order_id, user.id)


@router.get("", response_model=list[OrderRead])
async def get_orders(
    filter: Annotated[OrderFilter, Query()],
    user: UserRead = Depends(get_current_user),
    repo: UserRepo = Depends(get_user_repo),
) -> list[OrderRead]:
    if user.email == settings.ADMIN_EMAIL:
        return await repo.get_orders(filter)
    else:
        filter.user_id = user.id
    return await repo.get_orders(filter)


@router.get("/{id}", response_model=OrderInfo)
async def get_order(
    id: int,
    user: UserRead = Depends(get_current_user),
    repo: UserRepo = Depends(get_user_repo),
) -> OrderInfo:
    if user.email == settings.ADMIN_EMAIL:
        return await repo.get_order(id)
    else:
        return await repo.get_order(id, user.id)
