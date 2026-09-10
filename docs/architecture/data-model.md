# Data model

Phase 1 added identity, organization, asset, component, case, and evidence entities through Flyway migrations. Phase 2 adds ontology nodes and directed ontology edges, plus optional ontology references from registered assets and components.

The universal ontology is compositional: Equipment Type -> System -> Subsystem -> Assembly -> Component Type, connected to Function, Failure Mode -> Symptom -> Diagnostic Test -> Resolution and Safety Rule. Stable codes such as `hvac.filter-obstruction` are external identifiers; UUIDs remain database identifiers. Domain packs extend this shared model instead of creating domain-specific application classes.

The SQL representation is authoritative for Phase 2 local runtime. Its directed edges are intentionally graph-shaped so a later phase can project the same concepts into Neo4j without making Neo4j part of transactional asset registration.
