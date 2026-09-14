from pathlib import Path

import pytest

from enqivra.schemas.investigation import StartInvestigation
from enqivra.services.investigation import InvestigationService
from enqivra.services.knowledge import KnowledgeStore


def test_investigation_persists_questions_and_observations(tmp_path: Path):
    store = KnowledgeStore(str(tmp_path / "investigation.db"))
    service = InvestigationService(store)
    state = service.start(
        StartInvestigation(
            case_id="case-1",
            complaint="My split AC is not cooling",
            domain="HVAC",
            equipment_code="hvac.split-ac",
        )
    )

    assert state.status == "AWAITING_OBSERVATION"
    assert state.current_question
    assert state.citations
    assert state.reasoning

    initial_filter_probability = next(
        item.probability for item in state.reasoning.hypotheses if item.code == "hvac_filter"
    )

    for answer in ("It powers on", "After five minutes", "A humming sound", "Nothing changed"):
        state = service.observe(state.id, answer)

    assert state.status == "READY_FOR_REASONING"
    assert len(state.observations) == 4
    state = service.analyze(state.id)
    assert state.status == "ANALYZED"
    assert state.reasoning
    assert state.reasoning.hypotheses[0].code == "hvac_filter"
    assert state.reasoning.hypotheses[0].probability != initial_filter_probability
    assert sum(item.probability for item in state.reasoning.hypotheses) == pytest.approx(
        1, abs=0.001
    )
    assert state.reasoning.strategies
    assert "asset age" in state.reasoning.limitations[2]
    assert service.by_case("case-1").id == state.id
    store.close()


def test_critical_safety_complaint_stops_workflow(tmp_path: Path):
    store = KnowledgeStore(str(tmp_path / "safety.db"))
    service = InvestigationService(store)

    state = service.start(
        StartInvestigation(case_id="case-red", complaint="I smell gas near the equipment")
    )

    assert state.status == "STOPPED_SAFETY"
    assert state.safety_level == "RED"
    assert state.current_question is None
    assert state.reasoning is None
    with pytest.raises(ValueError, match="Safety-stopped"):
        service.observe(state.id, "I will inspect it")
    with pytest.raises(ValueError, match="Safety-stopped"):
        service.analyze(state.id)
    store.close()
