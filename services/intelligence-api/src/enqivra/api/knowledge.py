import io
from typing import Annotated

from fastapi import APIRouter, File, Form, HTTPException, Request, UploadFile
from pypdf import PdfReader

from enqivra.schemas.knowledge import DocumentResponse, KnowledgeAnswer, KnowledgeQuery

router = APIRouter(prefix="/knowledge", tags=["grounded-knowledge"])


@router.post("/documents", response_model=DocumentResponse)
async def ingest_document(
    request: Request,
    title: Annotated[str, Form()],
    domain: Annotated[str, Form()],
    file: Annotated[UploadFile, File()],
    equipment_code: Annotated[str | None, Form()] = None,
) -> DocumentResponse:
    content = await file.read()
    filename = file.filename or "document.txt"
    try:
        if filename.lower().endswith(".pdf"):
            reader = PdfReader(io.BytesIO(content))
            pages = [
                (index + 1, page.extract_text() or "") for index, page in enumerate(reader.pages)
            ]
        elif filename.lower().endswith((".txt", ".md")):
            pages = [(None, content.decode("utf-8-sig"))]
        else:
            raise ValueError("Knowledge documents must be PDF, TXT, or Markdown")
        document_id, chunks = request.app.state.knowledge.add_document(
            title.strip(), filename, domain, equipment_code, pages
        )
        return DocumentResponse(
            id=document_id,
            title=title.strip(),
            source=filename,
            domain=domain.upper(),
            equipment_code=equipment_code,
            chunks=chunks,
        )
    except (ValueError, OSError) as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc


@router.post("/query", response_model=KnowledgeAnswer)
async def query_knowledge(request: Request, query: KnowledgeQuery) -> KnowledgeAnswer:
    return request.app.state.knowledge.answer(
        query.query, query.domain, query.equipment_code, query.limit
    )
