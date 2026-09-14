from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "ENQIVRA Intelligence API"
    app_env: str = "development"
    log_level: str = "INFO"
    postgres_dsn: str = "postgresql+asyncpg://enqivra:enqivra_dev_only@localhost:5432/enqivra"
    qdrant_url: str = "http://localhost:6333"
    neo4j_uri: str = "bolt://localhost:7687"
    neo4j_user: str = "neo4j"
    neo4j_password: str = "enqivra_dev_only"
    intelligence_data_path: str = "./data/intelligence.db"
    jwt_secret: str = "change-this-development-secret-before-production-use"
    auth_required: bool = False
    enforce_core_ownership: bool = False
    core_api_url: str = "http://localhost:8080/api/v1"
    rate_limit_per_minute: int = 120
    max_request_bytes: int = 25 * 1024 * 1024


@lru_cache
def get_settings() -> Settings:
    return Settings()
