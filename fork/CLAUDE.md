# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**OCI Project Management API** deployed through the OCI DevOps pipeline. The backend is a Spring Boot 3.5.6 / Java 21 REST API (package `com.ociproject`) replacing the original MyTodoList app. The React frontend is still served by Spring Boot from the same JAR. Infrastructure and deployment scripts remain unchanged.

## Repository Layout

```
oci_devops/
├── backend/         ← Spring Boot app (Java sources, pom.xml, Dockerfile, scripts)
├── frontend/        ← React sources (built by Maven and embedded into the JAR)
├── infrastructure/  ← Terraform (OCI), utility scripts, env.sh
└── build_spec.yaml  ← OCI Build Pipeline spec
```

## Commands

### Build (run from `oci_devops/backend/`)

```bash
# Build JAR (also builds frontend via Maven)
mvn clean package spring-boot:repackage

# Build + push Docker image
./build.sh
```

### Run

```bash
# Backend (requires Oracle DB configured in application.properties)
cd oci_devops/backend && mvn spring-boot:run

# Frontend dev server only (proxies API to localhost:8080)
cd oci_devops/frontend && npm start
```

### Deploy / Undeploy (run from `oci_devops/backend/`)

```bash
./deploy.sh    # kubectl apply to mtdrworkshop namespace
./undeploy.sh  # kubectl delete
```

### Tests

```bash
# Unit tests
mvn test

# Single test class
mvn test -Dtest=TaskServiceTest

# Integration tests (requires live Oracle DB in application-it.properties)
mvn test -Dtest="*IT"
```

## Architecture

### Backend (`oci_devops/backend/src/main/java/com/ociproject/`)

Spring Boot 3.5.6 / Java 21 layered application:

- **`controller/`** — 16 REST controllers under `/api/v1`: Auth, Users, Teams, Roles, Projects, Sprints, Tasks, KPI Types, KPI Values, Dashboard, Reports, Deployments, Incidents, Bot, LLM Analysis, Audit Log
- **`service/`** — Business logic services
- **`model/`** — JPA entities (18 tables, soft-delete pattern with `deleted`/`deletedAt`)
- **`repository/`** — Spring Data JPA repositories
- **`security/`** — JWT auth (`JwtTokenProvider`, `JwtAuthenticationFilter`, `SecurityConfig`)
- **`dto/`** — Request/response DTOs
- **`exception/`** — Global exception handler
- **`converter/`** — `YnBooleanConverter` (Oracle Y/N ↔ boolean)
- **`config/`** — `OpenApiConfig` (Swagger)

### Telegram bot util (preserved from original)

`backend/src/main/java/com/springboot/MyTodoList/util/` — Bot helper classes kept as-is. These are standalone Telegram bot utilities.

### Frontend (`oci_devops/frontend/src/`)

React SPA built by Maven via `frontend-maven-plugin` and served statically from the JAR.

### Database

Oracle ATP (production) / XEPDB1 (local). Schema managed manually via `DB/schema.sql` (`ddl-auto=none`). Connection pooling via Oracle UCP.

### Infrastructure (`oci_devops/infrastructure/`)

Terraform + shell scripts for full OCI stack: VCN, OKE, ATP, API Gateway, Object Storage, Container Registry.

### Key Patterns

- **Soft delete**: entities have `deleted` (Y/N via `YnBooleanConverter`) + `deletedAt`
- **Audit trail**: `TaskService.updateStatus()` writes `TaskStatusHistory`; sprint changes write `TaskSprintHistory`; all mutations log to `AuditLog`
- **JWT**: stateless, `Authorization: Bearer <token>`, refresh tokens supported
- **API base**: `server.servlet.context-path=/api/v1`
- **Transactions**: services default to `@Transactional(readOnly=true)`; write methods carry their own `@Transactional`
