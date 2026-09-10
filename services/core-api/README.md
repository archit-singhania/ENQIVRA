# Core API

Spring Boot owns transactional business data including Phase 1 identity, organizations, assets, components, diagnostic cases, and evidence.

Registration creates a user, an organization, and an OWNER membership. Send the returned access token as `Authorization: Bearer <token>`. Evidence uploads are limited to 20 MB and stored beneath the configured evidence directory.

```bash
mvn spring-boot:run
mvn test
mvn spotless:check
```

Set `DB_URL`, `DB_USER`, and `DB_PASSWORD`, or use Docker Compose from the repository root.

For a persistent zero-setup local database without Docker:

```powershell
mvn "-Dspring-boot.run.profiles=local" spring-boot:run
```
