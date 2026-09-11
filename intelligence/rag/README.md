# Retrieval

Phase 4 implements local PDF/TXT/Markdown ingestion, deterministic chunking, FTS5/BM25 retrieval, token-overlap reranking, metadata filtering, grounded extractive answers, and page/chunk citations in the Intelligence API. Qdrant remains the later semantic-candidate backend; the API contract does not depend on it.
