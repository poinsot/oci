# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**MyTodoList** is a full-stack Todo application built for Oracle Cloud Infrastructure (OCI) deployment. It consists of a Spring Boot REST API backend, a React frontend (served by Spring Boot), and an Oracle Autonomous Database (ATP).

## Repository Layout

```
oci_devops/
├── backend/         ← Spring Boot app (Java sources, pom.xml, Dockerfile, scripts)
├── frontend/        ← React sources (built by Maven and embedded into the JAR)
├── infrastructure/  ← Terraform (OCI), utility scripts, env.sh
└── build_spec.yaml  ← OCI Build Pipeline spec
```

The frontend is **not deployed separately** — Maven builds it via `frontend-maven-plugin` and copies the output into `backend/target/classes/static/`, so it's served by Spring Boot from the single JAR.

## Commands

### Build (run from `oci_devops/backend/`)

```bash
# Build JAR (also builds frontend via Maven)
mvn clean package spring-boot:repackage

# Build, push Docker image
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

### Frontend only

```bash
cd oci_devops/frontend
npm install
npm start       # dev server on :3000
npm run build   # production build (also triggered by Maven)
```

## Architecture

### Backend (`oci_devops/backend/src/main/java/com/springboot/MyTodoList/`)

Layered Spring Boot application:

- **`controller/`** — REST controllers:
  - `ToDoItemController` — CRUD for `/todolist` endpoints (GET, POST, PUT, DELETE)
  - `ToDoItemBotController` — Telegram bot webhook endpoints
  - `UserController` — User management
- **`service/`** — Business logic: `ToDoItemService`, `UserService`, `DeepSeekService` (AI integration)
- **`model/`** — JPA entities: `ToDoItem` (id, description, creation_ts, done), `User` (id, phonenumber, password)
- **`repository/`** — Spring Data JPA repositories
- **`config/`** — Configuration beans: `OracleConfiguration` (DB connection), `CorsConfig`, `BotProps`, `DeepSeekConfig`, `DbSettings`
- **`security/`** — Spring Security setup (`WebSecurityConfiguration`)
- **`util/`** — Telegram bot helper utilities

### Frontend (`oci_devops/frontend/src/`)

Simple React SPA:
- `App.js` — Main component: manages state (items, loading, errors), renders two tables (done vs. pending)
- `NewItem.js` — Form for adding todo items
- `API.js` — Single constant: API base URL (`localhost:8080/todolist`)

Maven property `frontend-src-dir` in `pom.xml` points to `${project.basedir}/../frontend` so the build picks up sources from the sibling `frontend/` directory.

### Database

Oracle ATP with two tables: `TODOITEM` and `USERS`. Connection pooling via Oracle UCP. Hibernate dialect: `OracleDialect`.

### Infrastructure (`oci_devops/infrastructure/`)

- **`terraform/`** — Full OCI infrastructure: VCN, OKE cluster, Oracle ATP, API Gateway, Object Storage, Container Registry
- **`utils/`** — Shell scripts for infrastructure setup/teardown (`main-setup.sh`, `db-setup.sh`, `oke-setup.sh`, etc.)
- **`env.sh`** — Environment variables sourced by build and deploy scripts
- **`setup.sh` / `destroy.sh`** — Top-level infrastructure lifecycle scripts

The Kubernetes deployment manifest lives at `oci_devops/backend/src/main/resources/todolistapp-springboot.yaml` (2 replicas, LoadBalancer on port 80→8080, `mtdrworkshop` namespace).

### Key Configuration

`oci_devops/backend/src/main/resources/application.properties` contains DB connection settings, Hibernate config, Telegram bot credentials, and the DeepSeek API key. In production, secrets are injected via Kubernetes secrets.
