from datetime import datetime
from enum import Enum
from uuid import UUID

from pydantic import BaseModel, Field, computed_field

from api.core.config import settings

# ------ Users ------


class UserBase(BaseModel):
    email: str
    password: str


class UserRead(UserBase):
    id: int


class UserInfo(BaseModel):
    id: int
    email: str
    picture_url: str | None = None
    created_at: datetime

    @computed_field
    def is_admin(self) -> bool:
        return self.email == settings.ADMIN_EMAIL


# ------- Towns ---------


class TownCreate(BaseModel):
    name: str
    fias_id: UUID


# --------- Streets ---------


class StreetCreate(BaseModel):
    name: str
    fias_id: UUID


# ------- Addresses --------


class AddressCreate(BaseModel):
    town: TownCreate
    street: StreetCreate
    house: str
    flat: str | None = None
    fias_id: UUID
    is_default: bool | None = None


class AddressRead(BaseModel):
    full_address: str
    fias_id: UUID


# ------ Carts ----------


class ItemCreate(BaseModel):
    quantity: int
    book_id: int


class ItemRead(ItemCreate):
    title: str
    price: float
    picture_url: str | None = None


# --------- Orders ----------


class Status(str, Enum):
    CANCELED = "CANCELED"
    PAID = "PAID"
    PENDING = "PENDING"
    SHIPPED = "SHIPPED"
    COMPLETED = "COMPLETED"


class OrderCreate(BaseModel):
    items: list[int]
    address_id: str


class OrderRead(BaseModel):
    id: int
    status: Status
    total_price: float
    full_address: str
    created_at: datetime


class OrderInfo(OrderRead):
    items: list[ItemRead]


# ------ Reviews --------


class ReviewCreate(BaseModel):
    rating: int
    text: str | None = None


class ReviewRead(BaseModel):
    id: int
    rating: int
    created_at: datetime
    book_id: int
    book_title: str
    text: str | None = None


class ReviewFilter(BaseModel):
    user_id: int | None = None
    limit: int = 10
    offset: int = 0
    good_first: bool = False
    bad_first: bool = False


class OrderFilter(BaseModel):
    book_id: int | None = None
    user_id: int | None = None
    town_id: UUID | None = None
    min_price: float | None = Field(None, ge=0)
    max_price: float | None = Field(None, gt=0)
    status: Status | None = None
    limit: int = 10
    offset: int = 0
