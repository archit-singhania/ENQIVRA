# Security model

- Secrets enter through environment variables and are never committed.
- Containers use non-root users where application images permit it.
- Only development ports are exposed by Compose.
- Authentication, JWT rotation, RBAC, upload validation, audit events, rate limiting, and production network policies are Phase 1/10 work, not Phase 0 claims.
- Safety classification is a core product boundary: red-category systems must stop consumer DIY guidance and escalate.
