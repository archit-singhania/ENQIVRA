from pathlib import Path

from enqivra.services.knowledge import KnowledgeStore


def test_ingestion_and_grounded_query_return_citations(tmp_path: Path):
    store = KnowledgeStore(str(tmp_path / "knowledge.db"))
    document_id, chunks = store.add_document(
        "Pump manual",
        "pump-manual.txt",
        "COMMON",
        "common.pump",
        [(4, "A blocked inlet can reduce pump flow. Isolate power before inspecting the inlet.")],
    )

    answer = store.answer("Why is pump flow reduced?", equipment_code="common.pump")

    assert chunks == 1
    assert answer.grounded is True
    assert answer.citations[0].document_id == document_id
    assert answer.citations[0].page == 4
    store.close()


def test_unknown_query_is_explicitly_ungrounded(tmp_path: Path):
    store = KnowledgeStore(str(tmp_path / "knowledge.db"))

    answer = store.answer("quantum telescope calibration")

    assert answer.grounded is False
    assert answer.citations == []
    store.close()
