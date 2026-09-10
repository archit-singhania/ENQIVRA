.PHONY: dev stop test lint logs health clean tree

dev:
	docker compose up --build -d
	docker compose ps

stop:
	docker compose down

test:
	docker compose run --rm core-api ./mvnw test
	docker compose run --rm intelligence-api pytest

lint:
	docker compose run --rm core-api ./mvnw spotless:check
	docker compose run --rm intelligence-api ruff check src tests
	docker compose run --rm intelligence-api ruff format --check src tests

logs:
	docker compose logs -f --tail=200

health:
	docker compose ps

clean:
	docker compose down --remove-orphans

tree:
	find . -path './.git' -prune -o -path '*/node_modules' -prune -o -path '*/target' -prune -o -print
