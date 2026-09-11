import re
import sqlite3
import threading
import uuid
from dataclasses import dataclass
from pathlib import Path

from enqivra.schemas.knowledge import Citation, KnowledgeAnswer


@dataclass
class Chunk:
    document_id: str
    title: str
    source: str
    page: int | None
    position: int
    text: str
    score: float


class KnowledgeStore:
    def __init__(self, path: str) -> None:
        database = Path(path)
        database.parent.mkdir(parents=True, exist_ok=True)
        self.connection = sqlite3.connect(database, check_same_thread=False)
        self.connection.row_factory = sqlite3.Row
        self.lock = threading.Lock()
        self._migrate()
        self._seed()

    def _migrate(self) -> None:
        with self.connection:
            self.connection.executescript(
                """
                CREATE TABLE IF NOT EXISTS knowledge_documents (
                    id TEXT PRIMARY KEY, title TEXT NOT NULL, source TEXT NOT NULL,
                    domain TEXT NOT NULL, equipment_code TEXT, created_at TEXT NOT NULL
                );
                CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_chunks USING fts5(
                    document_id UNINDEXED, title UNINDEXED, source UNINDEXED,
                    domain UNINDEXED, equipment_code UNINDEXED, page UNINDEXED,
                    position UNINDEXED, text, tokenize='porter unicode61'
                );
                CREATE TABLE IF NOT EXISTS investigations (
                    id TEXT PRIMARY KEY, case_id TEXT NOT NULL UNIQUE, complaint TEXT NOT NULL,
                    domain TEXT, equipment_code TEXT, status TEXT NOT NULL,
                    safety_level TEXT NOT NULL, safety_message TEXT, current_question TEXT,
                    observations_json TEXT NOT NULL, evidence_summary TEXT NOT NULL,
                    citations_json TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
                );
                """
            )

    def _seed(self) -> None:
        if self.connection.execute("SELECT COUNT(*) FROM knowledge_documents").fetchone()[0]:
            return
        self.add_document(
            "ENQIVRA safe diagnostic foundation",
            "builtin://common/safety",
            "COMMON",
            None,
            [
                (
                    1,
                    "Disconnect and isolate power before opening user-serviceable covers. Never touch exposed live conductors. Gas smell, smoke, fire, severe overheating, high voltage, braking, steering, pressure-vessel, or refrigerant-line work requires immediate stop and professional escalation.",
                ),
                (
                    2,
                    "Record when the symptom occurs, visible warnings, abnormal sound, smell, temperature, recent changes, and whether the equipment starts. Prefer non-invasive observations before disassembly.",
                ),
            ],
        )
        self.add_document(
            "Split air conditioner inspection notes",
            "builtin://hvac/split-ac",
            "HVAC",
            "hvac.split-ac",
            [
                (
                    1,
                    "For insufficient cooling, check the user-serviceable indoor filter for visible obstruction with power disconnected. Confirm whether indoor and outdoor fans operate and record error codes.",
                ),
                (
                    2,
                    "Do not open the sealed refrigerant circuit. Refrigerant pressure, electrical capacitor, compressor, and live-panel tests require a qualified HVAC technician.",
                ),
            ],
        )
        self.add_document(
            "Passenger car symptom intake",
            "builtin://automotive/passenger-car",
            "AUTOMOTIVE",
            "automotive.passenger-car",
            [
                (
                    1,
                    "Record dashboard warning lights, stored OBD-II codes, operating temperature, speed and engine load when jerking or power loss occurs. Stop driving for smoke, fuel smell, brake, steering, or severe power-loss symptoms.",
                )
            ],
        )

    def add_document(
        self,
        title: str,
        source: str,
        domain: str,
        equipment_code: str | None,
        pages: list[tuple[int | None, str]],
    ) -> tuple[str, int]:
        document_id = str(uuid.uuid4())
        chunks: list[tuple[int | None, str]] = []
        for page, text in pages:
            chunks.extend((page, value) for value in _chunks(text))
        with self.lock, self.connection:
            self.connection.execute(
                "INSERT INTO knowledge_documents VALUES (?, ?, ?, ?, ?, datetime('now'))",
                (document_id, title, source, domain.upper(), equipment_code),
            )
            self.connection.executemany(
                "INSERT INTO knowledge_chunks VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                [
                    (document_id, title, source, domain.upper(), equipment_code, page, index, text)
                    for index, (page, text) in enumerate(chunks)
                ],
            )
        return document_id, len(chunks)

    def search(
        self,
        query: str,
        domain: str | None = None,
        equipment_code: str | None = None,
        limit: int = 5,
    ) -> list[Chunk]:
        terms = [term for term in re.findall(r"[a-zA-Z0-9]+", query.lower()) if len(term) > 1]
        if not terms:
            return []
        fts_query = " OR ".join(f'"{term}"' for term in terms[:20])
        sql = "SELECT *, bm25(knowledge_chunks) AS rank FROM knowledge_chunks WHERE knowledge_chunks MATCH ?"
        parameters: list[object] = [fts_query]
        if domain:
            sql += " AND domain = ?"
            parameters.append(domain.upper())
        if equipment_code:
            sql += " AND (equipment_code = ? OR equipment_code IS NULL)"
            parameters.append(equipment_code)
        sql += " ORDER BY rank LIMIT ?"
        parameters.append(limit * 3)
        rows = self.connection.execute(sql, parameters).fetchall()
        query_terms = set(terms)
        ranked = []
        for row in rows:
            tokens = set(re.findall(r"[a-zA-Z0-9]+", row["text"].lower()))
            overlap = len(query_terms & tokens) / len(query_terms)
            score = overlap + max(0.0, -float(row["rank"])) / 10
            ranked.append(
                Chunk(
                    row["document_id"],
                    row["title"],
                    row["source"],
                    int(row["page"]) if row["page"] else None,
                    int(row["position"]),
                    row["text"],
                    round(score, 4),
                )
            )
        return sorted(ranked, key=lambda item: item.score, reverse=True)[:limit]

    def answer(
        self,
        query: str,
        domain: str | None = None,
        equipment_code: str | None = None,
        limit: int = 5,
    ) -> KnowledgeAnswer:
        matches = self.search(query, domain, equipment_code, limit)
        citations = [
            Citation(
                document_id=item.document_id,
                title=item.title,
                source=item.source,
                page=item.page,
                chunk=item.position,
                excerpt=item.text[:320],
                score=item.score,
            )
            for item in matches
        ]
        if not citations:
            return KnowledgeAnswer(
                answer="No grounded local knowledge matched this question.",
                grounded=False,
                citations=[],
            )
        answer = " ".join(citation.excerpt for citation in citations[:2])
        return KnowledgeAnswer(answer=answer, grounded=True, citations=citations)

    def close(self) -> None:
        self.connection.close()


def _chunks(text: str, maximum: int = 700) -> list[str]:
    paragraphs = [value.strip() for value in re.split(r"\n\s*\n", text) if value.strip()]
    output = []
    for paragraph in paragraphs:
        while len(paragraph) > maximum:
            boundary = paragraph.rfind(". ", 0, maximum)
            boundary = boundary + 1 if boundary > maximum // 2 else maximum
            output.append(paragraph[:boundary].strip())
            paragraph = paragraph[boundary:].strip()
        if paragraph:
            output.append(paragraph)
    return output
