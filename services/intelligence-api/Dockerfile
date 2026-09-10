FROM python:3.13-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN groupadd --system enqivra && useradd --system --gid enqivra --create-home enqivra
WORKDIR /app
COPY pyproject.toml README.md ./
COPY src ./src
RUN pip install --no-cache-dir .
USER enqivra
EXPOSE 8000
CMD ["uvicorn", "enqivra.main:app", "--host", "0.0.0.0", "--port", "8000"]
