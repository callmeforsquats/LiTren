from api.core.deps import check_admin, get_catalog_repo, get_user_repo
from api.repos.catalog import CatalogRepo
from api.repos.users import UserRepo
from api.schemas.catalog import (
    AuthorCreate,
    AuthorInfo,
    AuthorUpdate,
    BookCreate,
    BookFilter,
    BookInfo,
    BookRead,
    BookUpdate,
    CatCreate,
    CatRead,
    PubCreate,
    PubUpdate,
    TopicCreate,
    TopicRead,
)
from api.schemas.users import ReviewFilter, ReviewRead
from fastapi import APIRouter, Depends, Query, Request, Response
from typing_extensions import Annotated

router = APIRouter(prefix="/catalog", tags=["Catalog"])


@router.get("/books", response_model=list[BookRead])
async def get_books_by_filter(
    filter: Annotated[BookFilter, Query()], repo: CatalogRepo = Depends(get_catalog_repo)
) -> list[BookRead]:
    return await repo.get_books(filter)


@router.get("/books/{id}", response_model=BookInfo)
async def get_book_by_id(
    request: Request, response: Response, id: int, repo: CatalogRepo = Depends(get_catalog_repo)
) -> BookInfo:
    book = await repo.get_book_by_id(id)
    viewed_raw = request.cookies.get("viewed_books", "")
    viewed_books = [int(x) for x in viewed_raw.split(",") if x.isdigit()]
    if book.id not in viewed_books:
        await repo.update_book_views_count(id)
        viewed_raw += f",{id}"
        response.set_cookie(
            "viewed_books", viewed_raw, httponly=True, samesite="lax", max_age=3600 * 24
        )
    return book


@router.post("/books")
async def add_book(
    book: BookCreate, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    id = await repo.create_book(book)
    return {"id": id, "status": "success"}


@router.patch("/books/{id}")
async def update_book(
    id: int,
    data: BookUpdate,
    admin=Depends(check_admin),
    repo: CatalogRepo = Depends(get_catalog_repo),
) -> dict:
    await repo.update_book(id, data)
    return {"status": "success"}


@router.delete("/books/{id}")
async def delete_book(
    id: int, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    await repo.delete_book(id)
    return {"status": "success"}


@router.get("/books/{id}/reviews", response_model=list[ReviewRead])
async def get_book_reviews(
    id: int, filter: Annotated[ReviewFilter, Query()], repo: UserRepo = Depends(get_user_repo)
) -> list[ReviewRead]:
    return await repo.get_reviews(filter)


@router.get("/cats", response_model=list[CatRead])
async def get_cats(repo: CatalogRepo = Depends(get_catalog_repo)) -> list[CatRead]:
    return await repo.get_cats()


@router.post("/cats")
async def add_cat(
    cat: CatCreate, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    id = await repo.create_cat(cat)
    return {"id": id, "status": "success"}


@router.delete("/cats/{id}")
async def delete_cat(
    id: int, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    await repo.delete_cat(id)
    return {"status": "success"}


@router.get("/cats/{cat_id}/topics")
async def get_cat_topics(
    cat_id: int, repo: CatalogRepo = Depends(get_catalog_repo)
) -> list[TopicRead]:
    return await repo.get_topics(cat_id)


@router.post("/cats/{cat_id}/topics/{topic_id}")
async def link_topic(
    cat_id: int,
    topic_id: int,
    admin=Depends(check_admin),
    repo: CatalogRepo = Depends(get_catalog_repo),
) -> dict:
    await repo.link_topic(topic_id, cat_id)
    return {"status": "success"}


@router.delete("/cats/{cat_id}/topics/{topic_id}")
async def delink_topic(
    cat_id: int,
    topic_id: int,
    admin=Depends(check_admin),
    repo: CatalogRepo = Depends(get_catalog_repo),
) -> dict:
    await repo.delink_topic(topic_id, cat_id)
    return {"status": "success"}


@router.get("/topics", response_model=list[TopicRead])
async def get_topics(repo: CatalogRepo = Depends(get_catalog_repo)) -> list[TopicRead]:
    return await repo.get_topics()


@router.post("/topics")
async def add_topic(
    topic: TopicCreate, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    id = await repo.create_topic(topic)
    return {"id": id, "status": "success"}


@router.delete("/topics/{id}")
async def delete_topic(
    id: int, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    await repo.delete_topic(id)
    return {"status": "success"}


@router.get("/pubs/{id}")
async def get_pub(id: int, repo: CatalogRepo = Depends(get_catalog_repo)) -> AuthorInfo:
    return await repo.get_pub_by_id(id)


@router.post("/pubs")
async def add_pub(
    pub: PubCreate, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    id = await repo.create_pub(pub)
    return {"id": id, "status": "success"}


@router.patch("/pubs/{id}")
async def update_pub(
    id: int,
    data: PubUpdate,
    admin=Depends(check_admin),
    repo: CatalogRepo = Depends(get_catalog_repo),
) -> dict:
    await repo.update_pub(id, data)
    return {"status": "success"}


@router.delete("/pubs/{id}")
async def delete_pub(
    id: int, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    await repo.delete_pub(id)
    return {"status": "success"}


@router.get("/authors/{id}")
async def get_author(id: int, repo: CatalogRepo = Depends(get_catalog_repo)):
    return await repo.get_author_by_id(id)


@router.post("/authors")
async def add_author(
    author: AuthorCreate, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    id = await repo.create_author(author)
    return {"id": id, "status": "success"}


@router.patch("/authors/{id}")
async def update_author(
    id: int,
    data: AuthorUpdate,
    admin=Depends(check_admin),
    repo: CatalogRepo = Depends(get_catalog_repo),
):
    await repo.update_author(id, data)
    return {"status": "success"}


@router.delete("/authors/{id}")
async def delete_author(
    id: int, admin=Depends(check_admin), repo: CatalogRepo = Depends(get_catalog_repo)
) -> dict:
    await repo.delete_author(id)
    return {"status": "success"}
