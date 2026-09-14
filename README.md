# ENQIVRA

**Evidence-native Networked Quantified Intelligence for Verification, Reasoning & Action**

ENQIVRA is a local-first Universal Physical Intelligence Platform. This repository currently contains the Phase 0 engineering foundation: mobile and web client shells, transactional and intelligence APIs, local data services, shared contracts, documentation, and CI.

> ENQIVRA does not just answer what might be wrong. It determines what evidence is missing, decides what to inspect next, tests competing hypotheses, and converges on the safest resolution.

## Current scope

Phases 0–10 are implemented: authenticated equipment/case workflows, ontology, local evidence intelligence, grounded retrieval, investigations, probability and repair guidance, digital twins, predictive trends, model evaluation/lifecycle, and production hardening. Deployment remains operator-controlled because domains, TLS certificates, secrets, backups, alerts, and legal policy are environment-specific. See [docs/ROADMAP.md](docs/ROADMAP.md) and [docs/operations-runbook.md](docs/operations-runbook.md).

## Free and open-source stack

- Flutter mobile client
- Angular web operations shell
- Java 21 + Spring Boot core API
- Python + FastAPI intelligence API
- PostgreSQL, Qdrant, Neo4j Community, and Valkey
- Docker Compose for local orchestration

No paid API, account, or cloud service is required.

## Quick start

Prerequisites: Docker Desktop (Compose v2) and GNU Make. Copy `.env.example` to `.env`, then run:

```bash
make dev
make health
make test
make logs
make stop
```

On Windows without Make:

```powershell
Copy-Item .env.example .env
docker compose up --build -d
docker compose ps
```

Endpoints after a healthy startup:

- Core API: <http://localhost:8080/api/v1/health>
- Core API actuator: <http://localhost:8080/actuator/health>
- Intelligence API: <http://localhost:8000/api/v1/health>
- Intelligence OpenAPI: <http://localhost:8000/docs>
- Qdrant dashboard: <http://localhost:6333/dashboard>
- Neo4j Browser: <http://localhost:7474>

## Local development

Each runnable service has its own README. Infrastructure credentials are development-only and configured through `.env`; do not reuse them in production.

Architecture decisions live under `docs/architecture` and `docs/adr`. The complete repository tree can be printed with `make tree`.
