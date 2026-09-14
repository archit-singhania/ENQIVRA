# Delivery roadmap and audit baseline

## Phase status

| Phase | Scope | Status |
|---|---|---|
| 0 | Monorepo, service/client shells, local data stack, CI, docs | Implemented foundation; full container runtime verification pending local Docker |
| 1 | Auth, organizations, asset registry, cases, evidence | Complete |
| 2 | Universal ontology and HVAC/automotive/appliance packs | Complete |
| 3 | Vision, audio, video, telemetry evidence intelligence and label OCR | Complete |
| 4 | Local hybrid retrieval, metadata, citations, grounding | Complete |
| 5 | Stateful diagnostic investigation workflow | Complete |
| 6 | Bayesian hypothesis updates and next-best test | Complete |
| 7 | Ranked resolutions and repair-vs-replace | Complete |
| 8 | Digital twins and prediction | Complete |
| 9 | MLflow/DVC evaluation and model lifecycle | Complete |
| 10 | Observability, load/security testing, deployment | Not started |

## What a user can see now

- Angular: one operations-dashboard foundation page with the ENQIVRA value proposition and Phase 0 metrics.
- Flutter: one mobile home shell with brand statement and honest phase messaging.
- FastAPI: OpenAPI documentation and a dependency-aware health endpoint.
- Spring Boot: an API health endpoint and Actuator health.

Phase 1 adds login/registration, home, equipment list/add/scan placeholder, new-case/history, and profile screens. Camera OCR remains explicitly deferred to Phase 3. Diagnosis, AI chat, live evidence analysis, and the full operations dashboard do not exist yet.

## Phase 1 audit

Implemented: JWT access tokens, BCrypt passwords, rotating opaque refresh tokens stored as SHA-256 hashes, secure mobile session persistence, organization membership roles, tenant authorization, manufacturers, assets, nested components, diagnostic cases, local evidence-file storage, upload metadata, browser/mobile CORS, input validation, and a second Flyway migration.

The Flutter application is connected to the Core API for registration, login, startup token refresh, logout, workspace counts, asset creation/listing, case creation/history, case evidence listing, and file evidence uploads. Empty, loading, and error states are included. Flutter web builds successfully and the source passes analysis and tests.

The current RBAC policy allows OWNER, ADMIN, and TECHNICIAN to write while VIEWER is read-only. Registration creates one owner organization. The Phase 1 hardening increment adds seven-day email-bound invitation codes, acceptance and revocation, role changes, member removal, final-owner safeguards, and multi-organization workspace switching. It remains fully local: invitation codes are copied and shared manually rather than sent through a paid email provider.

## Phase 2 audit

Implemented: a relational universal ontology with typed nodes for equipment, systems, subsystems, assemblies, component types, functions, failure modes, symptoms, diagnostic tests, resolutions, and safety rules. Directed relationships support reusable composition and future graph projection. Every node has a stable code, domain, description, and GREEN/YELLOW/ORANGE/RED safety classification.

The first versioned seed contains Common, HVAC, Automotive, and Appliance knowledge. It connects representative AC filter obstruction, automotive misfire, refrigerator door-seal leakage, and reusable motor/compressor concepts to symptoms, safe tests, resolutions, and escalation rules. Assets and nested components have nullable ontology references. The mobile asset and component forms can classify records against known types without preventing unknown equipment from being registered.

The Core API exposes pack summaries, filtered full-text-like catalogue search, and connected-node detail. Flutter adds a searchable, domain-filtered Knowledge Library with safety indicators and relationship navigation, plus asset detail and component-registry screens. This phase deliberately does not rank causes, analyze evidence, or generate repair instructions; those capabilities begin in Phases 3–7.

Phases 1 and 2 have no remaining implementation gaps in their defined scope. Automated diagnosis, probability updates, and generated repair guidance are later-phase work rather than incomplete Phase 1/2 features.

## Phase 3 audit

Implemented: Android camera/gallery label capture, local OCR integration, manufacturer/model candidate extraction, image brightness/focus quality checks, PCM WAV duration/sample-rate/channel/RMS features, video codec/dimension/frame-rate/duration extraction, and CSV telemetry min/max/mean/standard-deviation with simple outlier observations. The FastAPI endpoint returns versioned structured signals, observations, limitations, and explicit COMPLETED/PARTIAL/UNSUPPORTED states.

All analysis is local and free/open-source. Docker installs Tesseract OCR; host-mode OCR requires a local Tesseract executable and otherwise returns a truthful PARTIAL response while retaining image-quality analysis. Phase 3 extracts evidence signals only. It does not infer a root cause or prescribe repair; RAG, investigation, probability, resolution, and prediction remain Phases 4–8.

## Phase 4 audit

Implemented: persistent document ingestion for PDF, TXT, and Markdown; document/domain/equipment metadata; deterministic chunking; SQLite FTS5/BM25 lexical retrieval; token-overlap reranking; built-in Common/HVAC/Automotive safety and intake knowledge; extractive grounded answers; and citations containing source, page, chunk, excerpt, and score. Empty retrieval returns an explicit ungrounded response instead of invented content.

The local SQLite index is the zero-cost host-mode authority and persists in `data/intelligence.db`. Its service boundary can later add Qdrant semantic candidates without changing the API. The Flutter Knowledge Library includes technical-document upload and reports the indexed chunk count.

## Phase 5 audit

Implemented: persistent investigation creation and lookup by Core API case ID; deterministic complaint safety triage; RED workflow stop for gas, fire/smoke, live electrical, and vehicle-control hazards; ORANGE professional-inspection restrictions; a recorded question/observation timeline; retrieval refreshed after each observation; citation-bearing evidence summaries; resume semantics; and an explicit `READY_FOR_REASONING` handoff after evidence intake.

The Flutter case detail page now starts/resumes the investigation, displays safety state, asks one observation at a time, records answers, and shows grounded citations. Phase 5 deliberately does not attach probabilities or prescribe solutions; those remain Phases 6 and 7.

## Phase 6 audit

Implemented: a persistent, deterministic Bayesian-style hypothesis engine with domain inference for HVAC, automotive, and appliance complaints; explicit priors and evidence likelihood updates; normalized probabilities; supporting and contradicting evidence; recalculation after every observation; and next-best safe-test selection using a bounded information-gain score. Results clearly state that probabilities are estimates rather than proof.

RED safety investigations cannot enter reasoning. The rule engine is fully local, inspectable, and free/open-source; it does not call a hosted LLM or conceal its evidence model.

## Phase 7 audit

Implemented: ranked repair strategies linked to hypothesis codes, safety classification, LOW/MEDIUM/HIGH/UNKNOWN cost bands, user-safe versus professional-work boundaries, verification-first rationale, and repair-versus-replace guidance. Strategies are withheld until evidence intake is complete and the user explicitly calculates the result. Exact currency estimates are deliberately not invented: the output explains that asset age, condition, local quotes, parts availability, recurrence, and replacement price are required for an economic decision.

The Flutter case page displays changing cause probabilities and the next-best test during investigation. At `READY_FOR_REASONING`, it exposes a calculation action; the completed `ANALYZED` view adds ranked strategies, professional requirements, repair-versus-replace factors, and limitations.

## Phase 8 audit

Implemented: persistent per-asset digital-twin readings; metric, unit, source, timestamp, warning and critical thresholds; health-index/state calculation; grouped condition timelines; least-squares trend estimation; threshold-crossing forecasts; confidence derived from sample volume and fit error; and NORMAL/WATCH/WARNING/CRITICAL/INSUFFICIENT_DATA states. Fewer than three readings explicitly produces `UNKNOWN` health and no forecast.

The Flutter equipment-detail page displays the twin and permits condition readings without requiring paid telemetry infrastructure. This baseline accepts manual or API-fed readings and is ready for later device adapters; it does not claim remaining-useful-life precision from sparse data.

## Phase 9 audit

Implemented: a versioned diagnostic evaluation dataset, parameter file, reproducible DVC pipeline, standalone evaluation runner, local MLflow logging when the optional FOC MLOps dependencies are installed, persistent SQLite evaluation/model registry, top-1 accuracy and mean-confidence metrics, comparison with the preceding run, regression detection, CANDIDATE/STAGING/PRODUCTION/ARCHIVED stages, a minimum production quality gate, and automatic archival of an older production version.

The built-in v1 dataset currently contains four representative regression cases and scores 100%; this is a software regression baseline, not proof of real-world clinical-grade accuracy. Production promotion requires at least 60% on the selected dataset, while larger curated and field-labelled datasets remain ongoing operational work.
