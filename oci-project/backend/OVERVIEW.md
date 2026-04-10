# Backend Overview

## Models

JPA entities under `com.ociproject.model`, mapped to Oracle tables via `@Entity`.
All use Lombok (`@Getter`, `@Setter`, `@Builder`) and follow soft-delete (`deleted` / `deletedAt`).

| Model | Table | Notes |
|---|---|---|
| `Role` | `ROLES` | User roles |
| `Team` | `TEAMS` | Team groupings |
| `User` | `USERS` | Has `Status` enum: ACTIVE, INACTIVE, LOCKED |
| `UserCredential` | `USER_CREDENTIALS` | Password hash/salt, lockout tracking |
| `Sprint` | `SPRINTS` | Has `Status` enum: PLANNED, ACTIVE, CLOSED |
| `Project` | `PROJECTS` | Has `Status` enum: ACTIVE, ON_HOLD, COMPLETED, CANCELLED |
| `ProjectMember` | `PROJECT_MEMBERS` | Composite key `ProjectMemberId` |
| `ProjectSprint` | `PROJECT_SPRINTS` | Composite key `ProjectSprintId` |
| `Task` | `TASKS` | Enums: `Stage` (BACKLOG→SPRINT→COMPLETED), `Status`, `Priority` |
| `TaskStatusHistory` | `TASK_STATUS_HISTORY` | Audit trail for status changes |
| `TaskSprintHistory` | `TASK_SPRINT_HISTORY` | Audit trail for sprint assignments |
| `KpiType` | `KPI_TYPES` | KPI definitions |
| `KpiValue` | `KPI_VALUES` | Scope-based (USER, PROJECT, SPRINT, GLOBAL) |
| `LlmAnalysis` | `LLM_ANALYSIS` | LLM-generated insights, same scope pattern |
| `Deployment` | `DEPLOYMENTS` | Enums: `Environment`, `Status` |
| `Incident` | `INCIDENTS` | `Severity` enum |
| `BotInteraction` | `BOT_INTERACTIONS` | Composite key; table is range-partitioned by month |
| `AuditLog` | `AUDIT_LOG` | Actor, entity type/ID, action, IP |

---

## Repositories

Spring Data JPA interfaces under `com.ociproject.repository`, all extending `JpaRepository`.
Custom finders follow Spring Data naming conventions; soft-delete queries filter on `deletedFalse`.

| Repository | Entity (PK type) | Notable custom methods |
|---|---|---|
| `RoleRepository` | `Role` (Long) | `findByRoleNameAndDeletedFalse` |
| `TeamRepository` | `Team` (Long) | `findAllByDeletedFalse` |
| `UserRepository` | `User` (Long) | Find by email, Telegram ID, role, team, status |
| `UserCredentialRepository` | `UserCredential` (Long) | `findByUsernameAndDeletedFalse`, `findByUserUserId...` |
| `SprintRepository` | `Sprint` (Long) | `findByStatusAndDeletedFalse` |
| `ProjectRepository` | `Project` (Long) | Find by status, manager |
| `ProjectMemberRepository` | `ProjectMember` (composite `ProjectMemberId`) | Existence check by project+user |
| `ProjectSprintRepository` | `ProjectSprint` (composite `ProjectSprintId`) | Active sprint lookup, sprint-number existence check |
| `TaskRepository` | `Task` (Long) | Find by project, sprint, assignee, status, stage |
| `TaskStatusHistoryRepository` | `TaskStatusHistory` (Long) | `findByTaskTaskIdOrderByChangedAtAsc` |
| `TaskSprintHistoryRepository` | `TaskSprintHistory` (Long) | `findByTaskTaskIdOrderByChangedAtAsc` |
| `KpiTypeRepository` | `KpiType` (Long) | `findByName`, `findByCategory` |
| `KpiValueRepository` | `KpiValue` (Long) | Find by scope type, user, project, sprint; KPI type + scope combos |
| `LlmAnalysisRepository` | `LlmAnalysis` (Long) | Find by scope, `findByAnomalyDetectedTrue` |
| `DeploymentRepository` | `Deployment` (Long) | Find by project, status, environment |
| `IncidentRepository` | `Incident` (Long) | Find open incidents, filter by severity |
| `BotInteractionRepository` | `BotInteraction` (composite `BotInteractionId`) | `findByUserUserId` (paginated) |
| `AuditLogRepository` | `AuditLog` (Long) | Find by user, entity name+ID, action type (all paginated) |

---

## Services

Spring `@Service` beans under `com.ociproject.service`. All are `@Transactional(readOnly = true)`
by default; write methods carry their own `@Transactional`.

| Service | Responsibilities |
|---|---|
| `RoleService` / `TeamService` | CRUD for roles and teams |
| `UserService` | Lookup, creation, soft-delete, status updates |
| `UserCredentialService` | Password management, failed-attempt tracking, account locking |
| `SprintService` | Sprint lifecycle: create, activate, close |
| `ProjectService` | Project CRUD, member management |
| `TaskService` | Queries by project/sprint/assignee/stage; `updateStatus` writes `TaskStatusHistory` |
| `KpiService` | KPI type registry and value recording |
| `LlmAnalysisService` | Store and retrieve LLM analysis by scope |
| `DeploymentService` | Deployment tracking per environment |
| `IncidentService` | Incident creation and resolution |
| `BotInteractionService` | Persist and query Telegram bot interactions |
| `AuditLogService` | Append-only audit log writes |

---

## Test Services

Unit tests under `com.ociproject.service` (suffix `*Test`) using JUnit 5 + Mockito.
Repositories are `@Mock`; the service under test uses `@InjectMocks`.
Assertions use AssertJ (`assertThat`) and `assertThrows` for exception paths.

| Test class | Key scenarios covered |
|---|---|
| `RoleServiceTest` | Save, find by name, not-found throws |
| `TeamServiceTest` | Save, find, soft-delete |
| `UserServiceTest` | Create, status update, soft-delete |
| `UserCredentialServiceTest` | Password check, failed attempts, account lock |
| `SprintServiceTest` | Activate/close lifecycle, date validation |
| `ProjectServiceTest` | CRUD, member add/remove |
| `TaskServiceTest` | Find by project/sprint/assignee, `updateStatus` persists history |
| `KpiServiceTest` | Record value, scope filtering |
| `LlmAnalysisServiceTest` | Save analysis, find by scope |
| `DeploymentServiceTest` | Create deployment, environment filtering |
| `IncidentServiceTest` | Open/resolve incident |
| `BotInteractionServiceTest` | Save and retrieve by Telegram ID |
| `AuditLogServiceTest` | Log entry creation |

Integration tests (`UserServiceIT`) live in `com.ociproject.integration` and use `application-it.properties` for a real datasource.
