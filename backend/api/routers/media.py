import os
import shutil
import uuid

from api.core.deps import (
    check_admin,
    get_catalog_repo,
    get_current_user,
    get_current_user_id,
    get_user_repo,
)
from api.repos.catalog import CatalogRepo
from api.repos.users import UserRepo
from api.schemas.users import UserRead
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status

router = APIRouter(prefix="/media", tags=["Media"])

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}


def save_file_to_disk(file: UploadFile, entity_type: str) -> str:
    """Хелпер для сохранения файла. Возвращает готовый URL."""
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Разрешены только картинки (jpg, png, webp)")

    upload_dir = f"media/{entity_type}"
    os.makedirs(upload_dir, exist_ok=True)

    filename = f"{uuid.uuid4()}{ext}"
    file_path = os.path.join(upload_dir, filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return f"/media/{entity_type}/{filename}"


# 1. ДЛЯ ПОЛЬЗОВАТЕЛЕЙ (Доступно любому авторизованному для своего аватара)
@router.patch("/avatar")
async def upload_user_avatar(
    file: UploadFile = File(...),
    user: UserRead = Depends(get_current_user),
    repo: UserRepo = Depends(get_user_repo),
):
    """Обновить аватар текущего пользователя."""
    url = save_file_to_disk(file, "avatars")

    # Вызываем точечный метод обновления одной колонки, который мы заложили в UserRepo
    await repo.update_user_picture(user.id, url)
    return {"status": "success", "url": url}


# 2. ДЛЯ КАТАЛОГА (Доступно ТОЛЬКО админу для книг, авторов и издательств)
@router.patch("/catalog/{entity_type}/{id}", dependencies=[Depends(check_admin)])
async def upload_catalog_image(
    entity_type: str,
    id: int,
    file: UploadFile = File(...),
    repo: CatalogRepo = Depends(get_catalog_repo),
):
    """Обновить картинку сущности каталога (books, authors, publishers). Только для админа."""
    if entity_type not in {"books", "authors", "publishers"}:
        raise HTTPException(status_code=400, detail="Неверный тип сущности")

    url = save_file_to_disk(file, entity_type)

    # Динамически вызываем нужный метод обновления одной колонки в CatalogRepo
    if entity_type == "books":
        await repo.update_book_picture(id, url)
    elif entity_type == "authors":
        await repo.update_author_picture(id, url)
    elif entity_type == "publishers":
        await repo.update_publisher_picture(id, url)

    return {"status": "success", "url": url}
