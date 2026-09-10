# Delivery roadmap and audit baseline

## Phase status

| Phase | Scope | Status |
|---|---|---|
| 0 | Monorepo, service/client shells, local data stack, CI, docs | Implemented foundation; full container runtime verification pending local Docker |
| 1 | Auth, organizations, asset registry, cases, evidence | Complete |
| 2 | Universal ontology and HVAC/automotive/appliance packs | Complete |
| 3 | Vision, audio, telemetry evidence intelligence | Not started |
| 4 | Hybrid RAG, metadata, citations, evaluation | Not started |
| 5 | Stateful diagnostic investigation workflow | Not started |
| 6 | Bayesian hypothesis updates and next-best test | Not started |
| 7 | Ranked resolutions and repair-vs-replace | Not started |
| 8 | Digital twins and prediction | Not started |
| 9 | MLflow/DVC evaluation and model lifecycle | Not started |
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

The current RBAC policy allows OWNER, ADMIN, and TECHNICIAN to write while VIEWER is read-only. Registration creates one owner organization. Multi-organization invitation and membership management are intentionally left for the next Phase 1 hardening increment.

## Phase 2 audit

Implemented: a relational universal ontology with typed nodes for equipment, systems, subsystems, assemblies, component types, functions, failure modes, symptoms, diagnostic tests, resolutions, and safety rules. Directed relationships support reusable composition and future graph projection. Every node has a stable code, domain, description, and GREEN/YELLOW/ORANGE/RED safety classification.

The first versioned seed contains Common, HVAC, Automotive, and Appliance knowledge. It connects representative AC filter obstruction, automotive misfire, refrigerator door-seal leakage, and reusable motor/compressor concepts to symptoms, safe tests, resolutions, and escalation rules. Assets and components now have nullable ontology references, and new mobile assets can be classified against known equipment types without preventing unknown equipment from being registered.

The Core API exposes pack summaries, filtered full-text-like catalogue search, and connected-node detail. Flutter adds a searchable, domain-filtered Knowledge Library with safety indicators and relationship navigation. This phase deliberately does not rank causes, analyze evidence, or generate repair instructions; those capabilities begin in Phases 3–7.
