from ast import Nonlocal
from enum import Enum

from pydantic import BaseModel, Field


# --- Topics ---
class TopicCreate(BaseModel):
    name: str


class TopicRead(TopicCreate):
    id: int


# ------ Cats ---------


class CatCreate(BaseModel):
    name: str
    parent_id: int | None = None


class CatRead(CatCreate):
    id: int
    path: str | None = None


# ------- Authors ---------


class AuthorBase(BaseModel):
    name: str | None = None
    bio: str | None = None
    picture_url: str | None = None


class AuthorUpdate(AuthorBase):
    pass


class AuthorCreate(AuthorBase):
    name: str


class AuthorRead(BaseModel):
    id: int
    name: str


class AuthorInfo(AuthorRead, AuthorBase):
    pass


# ---------- Pubs ------------


class PubBase(BaseModel):
    name: str | None = None
    info: str | None = None
    picture_url: str | None = None


class PubUpdate(PubBase):
    pass


class PubCreate(PubUpdate):
    name: str


class PubRead(BaseModel):
    id: int
    name: str
    picture_url: str | None = None


class PubInfo(PubRead, PubBase):
    pass


# --- Books ---


class BookBase(BaseModel):
    title: str | None = None
    price: str | None = None
    isbn: str | None = None
    annotation: str | None = None
    page_count: int | None = None
    binding: str | None = None
    pub_id: int | None = None
    author_ids: list[int] | None = None
    topic_ids: list[int] | None = None


class BookUpdate(BookBase):
    pass


class BookCreate(BookBase):
    title: str
    price: float


class BookRead(BaseModel):
    id: int
    title: str
    price: float
    mean_rating: float
    reviews_count: int
    picture_url: str | None = None


class BookInfo(BookRead, BookBase):
    publisher: PubRead | None = None
    authors: list[AuthorRead] | None = None
    cat: CatRead | None = None
    topics: list[TopicRead] | None = None


# --- Filter ---


class Sortby(str, Enum):
    popularity = "popularity"
    rating = "rating"
    price = "price"


class BookFilter(BaseModel):
    cat_id: int | None = None
    topic_ids: list[int] | None = None
    min_price: float | None = Field(None, ge=0)
    max_price: float | None = Field(None, gt=0)
    bindings: list[str] | None = None
    is_new: bool | None = None
    min_rating: float | None = None
    author_ids: list[int] | None = None
    pub_ids: list[int] | None = None
    search: str | None = None
    limit: int = 10
    offset: int = 0
    sort_by: Sortby = Sortby.popularity
    reverse: bool = False
