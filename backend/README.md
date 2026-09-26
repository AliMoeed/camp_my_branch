# CAMP — Backend Services & Cloud Functions

Backend services providing offline-sync endpoints, telemetry processing, route calculation, and predictive maintenance rule evaluation for the CAMP mobile client.

## Directory Structure

```text
backend/
├── config/              # Server configuration & environment validation
├── functions/           # Cloud Functions / Serverless handlers
│   └── src/
│       ├── maintenance_rules/ # Automated maintenance triggers
│       └── sync/        # Cloud-to-local bidirectional sync
└── src/
    ├── middlewares/     # Auth, validation, error-handling middlewares
    ├── modules/         # Domain modules (elevation, mechanics, routes)
    └── routes/          # REST & WebSocket endpoint definitions
```
