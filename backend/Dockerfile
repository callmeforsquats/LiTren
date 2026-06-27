FROM python:3.11-slim
WORKDIR /app
COPY pyproject.toml uv.lock db.sql triggers.sql seed_data.sql ./
RUN pip install uv && uv venv && uv pip install -e .
COPY  ./api ./api
EXPOSE 8000
ENV PATH="/app/.venv/bin:$PATH"
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]