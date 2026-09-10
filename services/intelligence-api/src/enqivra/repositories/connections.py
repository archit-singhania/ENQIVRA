from dataclasses import dataclass

from neo4j import AsyncDriver, AsyncGraphDatabase
from qdrant_client import AsyncQdrantClient
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine

from enqivra.core.config import Settings


@dataclass
class Connections:
    postgres: AsyncEngine
    qdrant: AsyncQdrantClient
    neo4j: AsyncDriver

    @classmethod
    def create(cls, settings: Settings) -> "Connections":
        return cls(
            postgres=create_async_engine(settings.postgres_dsn, pool_pre_ping=True),
            qdrant=AsyncQdrantClient(url=settings.qdrant_url),
            neo4j=AsyncGraphDatabase.driver(
                settings.neo4j_uri,
                auth=(settings.neo4j_user, settings.neo4j_password),
            ),
        )

    async def close(self) -> None:
        await self.postgres.dispose()
        await self.qdrant.close()
        await self.neo4j.close()
