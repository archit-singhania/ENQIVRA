CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(320) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    display_name VARCHAR(120) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organizations (
    id UUID PRIMARY KEY,
    name VARCHAR(160) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organization_members (
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(30) NOT NULL CHECK (role IN ('OWNER', 'ADMIN', 'TECHNICIAN', 'VIEWER')),
    PRIMARY KEY (organization_id, user_id)
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE manufacturers (
    id UUID PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(160) NOT NULL,
    website VARCHAR(500),
    UNIQUE (organization_id, name)
);

CREATE TABLE assets (
    id UUID PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    manufacturer_id UUID REFERENCES manufacturers(id) ON DELETE SET NULL,
    name VARCHAR(160) NOT NULL,
    category VARCHAR(100) NOT NULL,
    model VARCHAR(160),
    serial_number VARCHAR(160),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    installed_at DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_assets_organization ON assets(organization_id);

CREATE TABLE asset_components (
    id UUID PRIMARY KEY,
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    name VARCHAR(160) NOT NULL,
    component_type VARCHAR(100) NOT NULL,
    model VARCHAR(160),
    serial_number VARCHAR(160),
    parent_component_id UUID REFERENCES asset_components(id) ON DELETE SET NULL
);

CREATE TABLE diagnostic_cases (
    id UUID PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    complaint TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    safety_level VARCHAR(20) NOT NULL DEFAULT 'GREEN',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_cases_organization ON diagnostic_cases(organization_id);

CREATE TABLE evidence (
    id UUID PRIMARY KEY,
    case_id UUID NOT NULL REFERENCES diagnostic_cases(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id),
    evidence_type VARCHAR(30) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    content_type VARCHAR(120) NOT NULL,
    size_bytes BIGINT NOT NULL,
    storage_key VARCHAR(500) NOT NULL UNIQUE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_evidence_case ON evidence(case_id);
