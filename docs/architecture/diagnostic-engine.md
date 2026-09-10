# Diagnostic investigation engine

The planned engine identifies an asset, interprets a complaint, performs safety triage, ranks hypotheses, selects the next informative test, updates probabilities from evidence, verifies safety, and proposes ranked resolutions. This workflow is not implemented in Phase 0.

Deterministic rules will own safety and probability calculations; ML will analyze evidence; graph and retrieval systems will supply knowledge; an orchestrator will manage investigation state.
