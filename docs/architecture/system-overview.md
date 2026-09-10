# System overview

ENQIVRA is a polyglot monorepo with clear ownership boundaries.

```text
Flutter / Angular
       |
       +--> Core API --------> PostgreSQL
       |
       +--> Intelligence API -> PostgreSQL / Qdrant / Neo4j
                                  |
                                  +--> future evidence and diagnostic modules
```

The Core API is the authoritative transactional boundary. The Intelligence API integrates evidence-processing and reasoning capabilities without owning operational records. PostgreSQL is the source of truth, Qdrant provides semantic retrieval, Neo4j represents physical-system relationships, and Valkey holds ephemeral state.

Phase 0 keeps this deliberately small. Workers and advanced infrastructure have documented boundaries but are not runnable services until a real workload requires them.
