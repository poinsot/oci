# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Spring Boot 3.3.4 / Java 21 backend for a project management and task tracking system with Telegram bot integration. Uses Oracle Database (XEPDB1) via Hibernate JPA. There is no REST controller layer — this is a service/data layer only.

## Commands

All commands run from `backend/`:

```bash
# Build
mvn clean package

# Run all unit tests
mvn test

# Run a single test class
mvn test -Dtest=TaskServiceTest

# Run integration tests (requires a live Oracle DB configured in src/test/resources/application-it.properties)
mvn test -Dtest="*IT"
```

No linting tool is configured. The project uses Lombok, so annotation processing must be enabled in the IDE.

## Architecture

**Package**: `com.ociproject`  
**Layers**: `model` → `repository` → `service` (no controllers)

### Key patterns applied everywhere

- **Soft delete**: All entities have `deleted` (boolean, mapped via `YnBooleanConverter` to Oracle `Y`/`N`) and `deletedAt` fields. Repository finders always filter on `deletedFalse`.
- **Lombok**: Entities use `@Getter`, `@Setter`, `@Builder`. Do not add constructors manually.
- **Lazy loading**: All JPA relationships use `FetchType.LAZY`.
- **Transactions**: Services are `@Transactional(readOnly = true)` by default; write methods carry their own `@Transactional`.
- **Composite keys**: `ProjectMember` (`ProjectMemberId`), `ProjectSprint` (`ProjectSprintId`), `BotInteraction` (`BotInteractionId`) use `@EmbeddedId`.

### Audit trails

`TaskService.updateStatus()` automatically writes a `TaskStatusHistory` row on every status change. Sprint assignment changes write `TaskSprintHistory`. `AuditLogService` is append-only for actor/entity/action/IP records.

### KPI and LLM scope pattern

`KpiValue` and `LlmAnalysis` share a scope model with four levels: `USER`, `PROJECT`, `SPRINT`, `GLOBAL`. Nullable FK columns (`userId`, `projectId`, `sprintId`) indicate which scope applies.

### Database

Schema and seed data live in `DB/schema.sql` (18 tables) and `DB/template_data.sql`. The schema is managed manually (`spring.jpa.hibernate.ddl-auto=none`). `BotInteraction` table is range-partitioned by month at the DB level.

### Testing conventions

Unit tests (`*Test`): JUnit 5 + Mockito. Repositories are `@Mock`, service is `@InjectMocks`. Assertions use AssertJ (`assertThat`) and `assertThrows` for exceptions.

Integration tests (`*IT`): live in `com.ociproject.integration`, use `application-it.properties` for a real Oracle datasource, and rely on Spring transactions that rollback after each test.
