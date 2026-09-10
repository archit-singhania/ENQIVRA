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


@lru_cache
def get_settings() -> Settings:
    return Settings()
