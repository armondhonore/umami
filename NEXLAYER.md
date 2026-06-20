# Nexlayer — umami

<!-- nexlayer:meta version=1 analyzed=2026-06-20T17:20:31Z repo=https://github.com/armondhonore/umami branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
Umami is a modern, privacy-focused, self-hosted alternative to Google Analytics that provides website analytics without tracking users.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Next.js | framework | latest | package.json, next.config.ts |
| PostgreSQL | database | 15 | docker-compose.yml |
| Prisma | tool | 7.3.0 | Dockerfile, prisma.config.ts |
| Node.js | language | 22-alpine | Dockerfile |
| pnpm | build | latest | pnpm-lock.yaml |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- src/ — Main application source code
- prisma/ — Database schema and migration files
- scripts/ — Build and maintenance scripts
- public/ — Static assets
- generated/ — Prisma client and build artifacts
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
_No external services detected._
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Node.js >= 18.18
- pnpm
- PostgreSQL >= 12.14

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
DATABASE_URL=postgresql://username:mypassword@localhost:5432/umami
APP_SECRET=random-string
```

### Steps

1. `pnpm install` — Install project dependencies
2. `pnpm run build` — Build application and initialize database schema
3. `pnpm run dev` — Start development server on http://localhost:3000

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `app` | `NODE_ENV` | `"production"` | plain |
| `app` | `PORT` | `"3000"` | plain |
| `app` | `HOSTNAME` | `"0.0.0.0"` | plain |
| `app` | `DATABASE_URL` | `"postgresql://umami:umami@postgres.pod:5432/umami"` | plain |
| `app` | `APP_SECRET` | _(set via Nexlayer dashboard)_ | secret |
| `postgres` | `POSTGRES_USER` | `umami` | plain |
| `postgres` | `POSTGRES_PASSWORD` | _(set via Nexlayer dashboard)_ | secret |
| `postgres` | `POSTGRES_DB` | `umami` | plain |
| `postgres-data` | `size` | `10Gi` | plain |
| `postgres-data` | `mountPath` | `/var/lib/postgresql/data` | plain |

### Secrets Required

Set these in the Nexlayer dashboard before deploying:

- `APP_SECRET` (`app` pod)
- `POSTGRES_PASSWORD` (`postgres` pod)

### nexlayer.yaml

```yaml
application:
  name: umami
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/umami:9ee60bf-fix8"
      path: /
      servicePorts:
        - 3000
      vars:
        NODE_ENV: "production"
        PORT: "3000"
        HOSTNAME: "0.0.0.0"
        DATABASE_URL: "postgresql://umami:umami@postgres.pod:5432/umami"
        APP_SECRET: "replace-me-with-a-random-string"
    - name: postgres
      image: mirror.gcr.io/library/postgres:16-alpine
      servicePorts:
        - 5432
      vars:
        POSTGRES_USER: umami
        POSTGRES_PASSWORD: umami
        POSTGRES_DB: umami
      volumes:
        - name: postgres-data
          size: 10Gi
          mountPath: /var/lib/postgresql/data
```

<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| umami | mirror.gcr.io/library/node:22-alpine | 3000 | web |
| db | mirror.gcr.io/library/postgres:15-alpine | 5432 | database |

### Deployment notes

- The application pod connects to the database pod using the Nexlayer convention: db.pod:5432
- Images are mirrored from gcr.io to comply with Docker Hub namespacing rules
- Prisma migrations are handled via pnpm run update-db during deployment

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-06-20T17:34:44Z  
**Live URL:** https://relaxed-weasel-umami.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: umami
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/umami:9ee60bf-fix8"
      path: /
      servicePorts:
        - 3000
      vars:
        NODE_ENV: "production"
        PORT: "3000"
        HOSTNAME: "0.0.0.0"
        DATABASE_URL: "postgresql://umami:umami@postgres.pod:5432/umami"
        APP_SECRET: "replace-me-with-a-random-string"
    - name: postgres
      image: mirror.gcr.io/library/postgres:16-alpine
      servicePorts:
        - 5432
      vars:
        POSTGRES_USER: umami
        POSTGRES_PASSWORD: umami
        POSTGRES_DB: umami
      volumes:
        - name: postgres-data
          size: 10Gi
          mountPath: /var/lib/postgresql/data
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-20T17:20:31Z | analyzed | initial repo analysis |
| 2026-06-20T17:34:44Z | success | deployed https://relaxed-weasel-umami.cloud.nexlayer.ai |
<!-- nexlayer:end -->
