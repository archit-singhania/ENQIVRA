from pydantic import BaseModel, Field


class Citation(BaseModel):
    document_id: str
    title: str
    source: str
    page: int | None = None
    chunk: int
    excerpt: str
    score: float


class KnowledgeQuery(BaseModel):
    query: str = Field(min_length=2, max_length=2000)
    domain: str | None = None
    equipment_code: str | None = None
    limit: int = Field(default=5, ge=1, le=10)


class KnowledgeAnswer(BaseModel):
    answer: str
    grounded: bool
    citations: list[Citation]


class DocumentResponse(BaseModel):
    id: str
    title: str
    source: str
    domain: str
    equipment_code: str | None
    chunks: int
