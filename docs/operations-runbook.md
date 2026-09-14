# ENQIVRA operations runbook

## Production gate

Copy `.env.production.example` to a secret-managed environment file and replace every placeholder. Never commit that file. Use one random JWT secret of at least 32 characters for both APIs, restrict `ALLOWED_ORIGINS`, terminate TLS at Caddy or an equivalent proxy, and expose only ports 80/443 through the host firewall. The database, graph, vector, cache, Core API, and Intelligence API ports in the development Compose file must remain on a private network in production.

## Health and observability

- Core liveness/readiness: `/actuator/health/liveness` and `/actuator/health/readiness`
- Core Prometheus metrics: `/actuator/prometheus` (authenticated)
- Intelligence liveness/dependencies: `/api/v1/health`
- Intelligence readiness/local store: `/api/v1/ready`
- Intelligence Prometheus text metrics: `/api/v1/metrics`
- Both services emit JSON logs and return `X-Request-ID` for correlation.

Alert on readiness failure, HTTP 5xx rate, sustained latency, storage exhaustion, database connection saturation, and backup failures. Do not log tokens, uploaded evidence, complaints, or manual contents.

## Backup and recovery

Back up PostgreSQL with `pg_dump`, the `intelligence_data` SQLite volume using SQLite's online backup mechanism, and evidence/object volumes using volume snapshots. Encrypt backups, retain them according to local policy, and test restoration quarterly. Stop writes or use database-native consistent snapshot mechanisms; copying a live SQLite file directly is not a guaranteed consistent backup.

## Verification

Run unit/integration tests in CI, dependency scanning, container scanning, and the bounded load smoke script. Against a running local service:

```powershell
cd services/intelligence-api
.\.venv\Scripts\python.exe scripts\load_smoke.py --requests 100 --concurrency 10
```

## Incident response

Revoke compromised credentials, rotate the shared JWT secret (which invalidates active access tokens), rotate database credentials, preserve request-ID-correlated logs, isolate affected services, restore from a verified backup if integrity is uncertain, and document scope and corrective actions. Production deployment and legal/privacy obligations remain the operator's responsibility.
