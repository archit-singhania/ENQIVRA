CREATE TABLE platform_metadata (
    key VARCHAR(100) PRIMARY KEY,
    value VARCHAR(500) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO platform_metadata (key, value) VALUES ('schema_phase', 'foundation');
