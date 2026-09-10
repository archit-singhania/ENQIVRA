# ADR 002: Two initial service boundaries

Status: Accepted

Spring Boot owns transactional domain behavior. FastAPI owns ML and intelligence integrations. Workers are reserved directories until asynchronous workloads exist. This avoids decorative microservices while preserving a clean expansion path.
