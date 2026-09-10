# Data model

Only `platform_metadata` exists in Phase 0 to prove migrations and connectivity. Phase 1 will add identity, organization, asset, component, case, observation, and evidence entities through reviewed Flyway migrations.

The future universal ontology is compositional: Asset -> System -> Subsystem -> Assembly -> Component, connected to Failure Mode -> Symptom -> Evidence -> Diagnostic Test -> Resolution. Domain packs extend this shared model instead of creating domain-specific application classes.
