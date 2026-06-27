import faiss
import numpy as np
import onnxruntime as ort
from api.core.deps import get_catalog_repo
from api.repos.catalog import CatalogRepo
from api.schemas.catalog import BookRead
from fastapi import APIRouter, Depends, Query
from tokenizers import Tokenizer

ort_session = None
tokenizer = None
vector_index = None


# 1. Загружаем ONNX сессию и токенизатор
async def index_db(repo: CatalogRepo = Depends(get_catalog_repo)):
    global ort_session, tokenizer, vector_index
    ort_session = ort.InferenceSession("search_model.onnx")
    tokenizer = Tokenizer.from_file("bpe_tokenizer.json")

    # 2. Имитация вашей SQL базы данных (замените на реальный SELECT id, annotation FROM books)
    repo = get_catalog_repo()
    annotations = await repo.get_all_annotiations()

    encoded_vectors = []
    book_ids = []

    # 3. Кодируем все аннотации в векторы через ONNX
    for book in annotations:
        output = tokenizer.encode(str(book["annotation"]))

        inputs = {
            "input_ids": np.array([output.ids], dtype=np.int64),
            "attention_mask": np.array([output.attention_mask], dtype=np.int64),
        }

        # Прямой инференс на CPU за доли миллисекунды
        onnx_outputs = ort_session.run(None, inputs)
        vector = onnx_outputs[0][0]  # Вытаскиваем нормализованный вектор [256]

        encoded_vectors.append(vector)
        book_ids.append(book["id"])

    # 4. Создаем индекс FAISS с жесткой привязкой к ID ваших книг из SQL
    dimension = 512
    index = faiss.IndexIDMap(
        faiss.IndexFlatIP(dimension)
    )  # IndexFlatIP считает косинусное сходство

    vectors_np = np.array(encoded_vectors).astype("float32")
    ids_np = np.array(book_ids).astype("int64")

    index.add_with_ids(vectors_np, ids_np)

    # 5. Сохраняем векторную базу на диск
    faiss.write_index(index, "books_index.faiss")
    print("Индекс books_index.faiss успешно создан!")
    vector_index = faiss.read_index("books_index.faiss")


async def get_books_with_ml(
    q: str = Query(...), repo: CatalogRepo = Depends(get_catalog_repo)
) -> list[BookRead]:
    output = tokenizer.encode(q.lower())
    inputs = {
        "input_ids": np.array([output.ids], dtype=np.int64),
        "attention_mask": np.array([output.attention_mask], dtype=np.int64),
    }
    onnx_outputs = ort_session.run(None, inputs)
    query_vector = onnx_outputs[0].astype("float32")
    scores, ids = vector_index.search(query_vector, k=5)
    result_book_ids = []
    for score, book_id in zip(scores[0], ids[0]):
        if book_id == -1:  # Защита от полупустой базы
            continue
        result_book_ids.append(int(book_id))
    books = await repo.get_books_by_ids(result_book_ids)
    return sorted(books, key=lambda b: result_book_ids.index(b.id))
