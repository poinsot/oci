# API Endpoints Reference
## Oracle Java Bot — Project Studio

> **Source mapping:** Every endpoint is derived from two sources:
> 1. The Oracle database schema (`Script_DB.sql`) — tables, constraints, and relationships.
> 2. The five UI screens in the PDF — *Developer Dashboard*, *Workspace Overview*, *Project Backlog*, *Performance Reports*, and *Team Management*.
>
> Each section notes which screen(s) consume that endpoint.

---

## Conventions

| Convention | Detail |
|---|---|
| Base URL | `/api/v1` |
| Content-Type | `application/json` |
| Authentication | `Authorization: Bearer <JWT>` on all endpoints except `/auth/*` |
| Timestamps | ISO 8601 — `2025-01-27T08:00:00Z` |
| Dates | `YYYY-MM-DD` |
| Soft deletes | Records with `IS_DELETED = 'Y'` are excluded from all `GET` responses unless `include_deleted=true` is passed |
| Side effects | Any `PUT /tasks/{id}` that changes `STATUS` auto-inserts into `TASK_STATUS_HISTORY`. Any change to `SPRINT_ID` auto-inserts into `TASK_SPRINT_HISTORY`. All mutating calls auto-write to `AUDIT_LOG`. |

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Users](#2-users)
3. [Teams](#3-teams)
4. [Roles](#4-roles)
5. [Projects](#5-projects)
6. [Sprints](#6-sprints)
7. [Tasks](#7-tasks)
8. [KPI Types](#8-kpi-types)
9. [KPI Values](#9-kpi-values)
10. [Dashboard (Aggregated)](#10-dashboard-aggregated)
11. [Reports & Analytics](#11-reports--analytics)
12. [Deployments](#12-deployments)
13. [Incidents](#13-incidents)
14. [Bot Interactions](#14-bot-interactions)
15. [LLM Analysis](#15-llm-analysis)
16. [Audit Log](#16-audit-log)
17. [HTTP Status Code Reference](#17-http-status-code-reference)

---

## 1. Authentication

> **Screens:** All screens (session management, navbar user chip)

---

### `POST /auth/login`
Authenticates a user with username and password. Returns a signed JWT and basic profile.

**Request Body**
```json
{
  "username": "inigo.gonzalez",
  "password": "plaintextPassword"
}
```

**Response `200 OK`**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
  "user_id": 1,
  "full_name": "Inigo Gonzalez",
  "email": "a01723229@tec.mx",
  "role": "MANAGER",
  "team_id": 1,
  "expires_at": "2025-01-07T09:00:00Z"
}
```

**Response `401 Unauthorized`**
```json
{
  "error": "Invalid credentials",
  "failed_attempts": 2,
  "account_locked": false
}
```

---

### `POST /auth/logout`
Invalidates the current session.

**Headers** `Authorization: Bearer <token>`

**Response `200 OK`**
```json
{ "message": "Session terminated successfully." }
```

---

### `POST /auth/refresh`
Issues a new access token using a valid refresh token.

**Request Body**
```json
{ "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g..." }
```

**Response `200 OK`**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2025-01-08T09:00:00Z"
}
```

---

## 2. Users

> **Screens:** Team Management (member cards, workload bars, Invite Member), Developer Dashboard (task assignee avatars), Performance Reports (task completion by member)

---

### `GET /users`
Returns all non-deleted users. Supports filtering and pagination.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `team_id` | integer | Filter by team |
| `role_id` | integer | Filter by role |
| `status` | string | `ACTIVE` \| `INACTIVE` \| `LOCKED` |
| `page` | integer | Default `1` |
| `limit` | integer | Default `20`, max `100` |
| `include_deleted` | boolean | Default `false` |

**Response `200 OK`**
```json
{
  "total": 6,
  "page": 1,
  "limit": 20,
  "data": [
    {
      "user_id": 1,
      "full_name": "Inigo Gonzalez",
      "email": "a01723229@tec.mx",
      "telegram_id": "@inigogonzalez",
      "role_id": 1,
      "role_name": "MANAGER",
      "team_id": 1,
      "team_name": "Backend Team",
      "status": "ACTIVE",
      "created_at": "2025-01-06T08:00:00Z",
      "updated_at": null
    },
    {
      "user_id": 2,
      "full_name": "Victor Martinez",
      "email": "a01723093@tec.mx",
      "telegram_id": "@victormartinez",
      "role_id": 2,
      "role_name": "DEVELOPER",
      "team_id": 1,
      "team_name": "Backend Team",
      "status": "ACTIVE",
      "created_at": "2025-01-06T08:00:00Z",
      "updated_at": null
    }
  ]
}
```

---

### `GET /users/{user_id}`
Returns full profile for one user. Used by the **View Details** button on Team Management cards.

**Path Parameters**

| Parameter | Type | Description |
|---|---|---|
| `user_id` | integer | Target user ID |

**Response `200 OK`**
```json
{
  "user_id": 4,
  "full_name": "Miguel Angel Alvarez",
  "email": "a01722925@tec.mx",
  "telegram_id": "@miguelangelalvarez",
  "role_id": 2,
  "role_name": "DEVELOPER",
  "team_id": 1,
  "team_name": "Backend Team",
  "status": "ACTIVE",
  "created_at": "2025-01-06T08:00:00Z",
  "updated_at": null,
  "is_deleted": false
}
```

**Response `404 Not Found`**
```json
{ "error": "User not found." }
```

---

### `POST /users`
Creates a new user and their credentials record simultaneously. Triggered by the **Invite Team Member** button.

**Request Body**
```json
{
  "full_name": "Jinhyuk Park",
  "email": "a01286288@tec.mx",
  "telegram_id": "@jinhyukpark",
  "role_id": 2,
  "team_id": 2,
  "username": "jinhyuk.park",
  "password": "initialPassword123"
}
```

**Response `201 Created`**
```json
{
  "user_id": 5,
  "full_name": "Jinhyuk Park",
  "email": "a01286288@tec.mx",
  "telegram_id": "@jinhyukpark",
  "role_id": 2,
  "role_name": "DEVELOPER",
  "team_id": 2,
  "team_name": "Frontend Team",
  "status": "ACTIVE",
  "created_at": "2025-04-09T10:00:00Z"
}
```

**Response `409 Conflict`**
```json
{ "error": "Email or username already in use." }
```

---

### `PUT /users/{user_id}`
Updates user profile. All fields are optional.

**Request Body**
```json
{
  "full_name": "Jinhyuk Park",
  "email": "a01286288@tec.mx",
  "telegram_id": "@jinhyukpark",
  "role_id": 2,
  "team_id": 1,
  "status": "ACTIVE"
}
```

**Response `200 OK`** — returns updated user object (same shape as `GET /users/{user_id}`).

---

### `DELETE /users/{user_id}`
Soft-deletes a user (`IS_DELETED = 'Y'`, `DELETED_AT = now()`).

**Response `200 OK`**
```json
{
  "message": "User soft-deleted successfully.",
  "user_id": 5,
  "deleted_at": "2025-04-09T10:00:00Z"
}
```

---

### `GET /users/{user_id}/workload`
Calculates live workload percentage for a team member. Powers the **workload progress bars** on Team Management cards.

**Response `200 OK`**
```json
{
  "user_id": 3,
  "full_name": "Paolo Gaya",
  "assigned_tasks_total": 7,
  "in_progress_tasks": 2,
  "pending_tasks": 5,
  "done_tasks": 0,
  "workload_percent": 68,
  "at_capacity": false
}
```

---

## 3. Teams

> **Screens:** Team Management (team labels on member cards), User creation flow

---

### `GET /teams`

**Response `200 OK`**
```json
{
  "data": [
    {
      "team_id": 1,
      "name": "Backend Team",
      "description": "Equipo de desarrollo de servicios y APIs",
      "member_count": 4
    },
    {
      "team_id": 2,
      "name": "Frontend Team",
      "description": "Equipo de desarrollo de interfaces",
      "member_count": 2
    }
  ]
}
```

---

### `GET /teams/{team_id}`

**Response `200 OK`**
```json
{
  "team_id": 1,
  "name": "Backend Team",
  "description": "Equipo de desarrollo de servicios y APIs",
  "members": [
    { "user_id": 1, "full_name": "Inigo Gonzalez", "role_name": "MANAGER" },
    { "user_id": 2, "full_name": "Victor Martinez", "role_name": "DEVELOPER" }
  ]
}
```

---

### `POST /teams`

**Request Body**
```json
{
  "name": "QA Team",
  "description": "Equipo de pruebas y aseguramiento de calidad"
}
```

**Response `201 Created`** — returns created team object.

---

### `PUT /teams/{team_id}`

**Request Body**
```json
{
  "name": "Backend Team",
  "description": "Updated description"
}
```

**Response `200 OK`** — returns updated team object.

---

### `DELETE /teams/{team_id}`
Soft-deletes a team.

**Response `200 OK`**
```json
{ "message": "Team soft-deleted successfully." }
```

---

## 4. Roles

> **Screens:** User creation/edit forms, member role badges (PM / DESIGNER / DEVELOPER) on Team Management cards

---

### `GET /roles`

**Response `200 OK`**
```json
{
  "data": [
    {
      "role_id": 1,
      "role_name": "MANAGER",
      "description": "Gestor de proyectos y sprints"
    },
    {
      "role_id": 2,
      "role_name": "DEVELOPER",
      "description": "Desarrollador asignado a tareas"
    }
  ]
}
```

---

### `POST /roles`

**Request Body**
```json
{
  "role_name": "QA_ENGINEER",
  "description": "Ingeniero de pruebas y calidad"
}
```

**Response `201 Created`** — returns created role object.

---

### `PUT /roles/{role_id}`

**Request Body**
```json
{ "description": "Updated description" }
```

**Response `200 OK`** — returns updated role object.

---

### `DELETE /roles/{role_id}`

**Response `200 OK`**
```json
{ "message": "Role soft-deleted successfully." }
```

---

## 5. Projects

> **Screens:** Workspace Overview (project list, spotlight card, health badge), Project Backlog (header breadcrumb), sidebar navigation (all screens)

---

### `GET /projects`
Lists all projects with summary info. Feeds the Workspace Overview project attention list.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `status` | string | `ACTIVE` \| `ON_HOLD` \| `COMPLETED` \| `CANCELLED` |
| `manager_id` | integer | Filter by manager |
| `page` | integer | Default `1` |
| `limit` | integer | Default `20` |

**Response `200 OK`**
```json
{
  "total": 2,
  "page": 1,
  "limit": 20,
  "data": [
    {
      "project_id": 1,
      "name": "Proyecto Alpha",
      "description": "Plataforma de gestión de tareas con integración de bot Telegram",
      "manager_id": 1,
      "manager_name": "Inigo Gonzalez",
      "status": "ACTIVE",
      "active_sprint_id": 2,
      "active_sprint_name": "Sprint 2 - Implementacion de KPIs y metricas",
      "member_count": 5,
      "created_at": "2025-01-06T08:00:00Z",
      "updated_at": null
    },
    {
      "project_id": 2,
      "name": "Proyecto Beta",
      "description": "Sistema de monitoreo de KPIs y reportes automatizados",
      "manager_id": 6,
      "manager_name": "Luis Garza Gomez",
      "status": "ACTIVE",
      "active_sprint_id": null,
      "active_sprint_name": null,
      "member_count": 4,
      "created_at": "2025-01-06T08:00:00Z",
      "updated_at": null
    }
  ]
}
```

---

### `GET /projects/{project_id}`
Full project detail including active sprint, members summary, and health snapshot.

**Response `200 OK`**
```json
{
  "project_id": 1,
  "name": "Proyecto Alpha",
  "description": "Plataforma de gestión de tareas con integración de bot Telegram",
  "manager_id": 1,
  "manager_name": "Inigo Gonzalez",
  "status": "ACTIVE",
  "active_sprint": {
    "sprint_id": 2,
    "name": "Sprint 2 - Implementacion de KPIs y metricas",
    "start_date": "2025-01-27",
    "end_date": "2025-02-17",
    "status": "ACTIVE",
    "days_left": 4,
    "velocity_percent": 72,
    "completed_story_points": 18,
    "total_story_points": 25
  },
  "member_count": 5,
  "health": {
    "on_time_delivery_rate": 84.0,
    "tickets_resolved_7d": 42,
    "efficiency_rating": "ELITE",
    "overdue_tasks": 12,
    "status": "Excellent"
  },
  "created_at": "2025-01-06T08:00:00Z",
  "updated_at": null
}
```

---

### `POST /projects`
Creates a new project. Triggered by the **+ New Project** button.

**Request Body**
```json
{
  "name": "Proyecto Gamma",
  "description": "Migración de infraestructura a contenedores",
  "manager_id": 1,
  "status": "ACTIVE"
}
```

**Response `201 Created`**
```json
{
  "project_id": 3,
  "name": "Proyecto Gamma",
  "description": "Migración de infraestructura a contenedores",
  "manager_id": 1,
  "manager_name": "Inigo Gonzalez",
  "status": "ACTIVE",
  "created_at": "2025-04-09T10:00:00Z"
}
```

---

### `PUT /projects/{project_id}`
Updates a project. All fields optional.

**Request Body**
```json
{
  "name": "Proyecto Alpha v2",
  "description": "Updated description",
  "manager_id": 6,
  "status": "ON_HOLD"
}
```

**Response `200 OK`** — returns updated project object (same shape as `GET /projects/{project_id}`).

---

### `DELETE /projects/{project_id}`
Soft-deletes a project.

**Response `200 OK`**
```json
{ "message": "Project soft-deleted successfully.", "project_id": 3, "deleted_at": "2025-04-09T10:00:00Z" }
```

---

### `GET /projects/{project_id}/members`
Lists all members assigned to a project. Used by the Project Backlog assignee avatars (+N overflow).

**Response `200 OK`**
```json
{
  "project_id": 1,
  "total": 5,
  "members": [
    {
      "user_id": 1,
      "full_name": "Inigo Gonzalez",
      "email": "a01723229@tec.mx",
      "role_in_project": "MANAGER",
      "joined_at": "2025-01-06T08:00:00Z",
      "is_deleted": false
    },
    {
      "user_id": 2,
      "full_name": "Victor Martinez",
      "email": "a01723093@tec.mx",
      "role_in_project": "DEVELOPER",
      "joined_at": "2025-01-06T08:00:00Z",
      "is_deleted": false
    }
  ]
}
```

---

### `POST /projects/{project_id}/members`
Adds a member to a project.

**Request Body**
```json
{
  "user_id": 5,
  "role_in_project": "DEVELOPER"
}
```

**Response `201 Created`**
```json
{
  "project_id": 1,
  "user_id": 5,
  "full_name": "Jinhyuk Park",
  "role_in_project": "DEVELOPER",
  "joined_at": "2025-04-09T10:00:00Z"
}
```

---

### `DELETE /projects/{project_id}/members/{user_id}`
Soft-removes a member from a project.

**Response `200 OK`**
```json
{ "message": "Member removed from project.", "project_id": 1, "user_id": 5 }
```

---

### `GET /projects/{project_id}/health`
Returns the project health panel shown in the **Project Backlog** bottom-right card.

**Response `200 OK`**
```json
{
  "project_id": 1,
  "on_time_delivery_rate": 84.0,
  "tickets_resolved_7d": 42,
  "efficiency_rating": "ELITE",
  "overdue_tasks_this_week": 12,
  "project_health_label": "Excellent"
}
```

---

## 6. Sprints

> **Screens:** Developer Dashboard (Sprint card — velocity %, days left, story points progress bar), Performance Reports (burndown, velocity chart), Project Backlog (implicit sprint context for tasks)

---

### `GET /sprints`
Lists sprints, optionally scoped to a project.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `project_id` | integer | Filter sprints belonging to this project |
| `status` | string | `PLANNED` \| `ACTIVE` \| `CLOSED` |
| `page` | integer | Default `1` |
| `limit` | integer | Default `20` |

**Response `200 OK`**
```json
{
  "total": 2,
  "data": [
    {
      "sprint_id": 1,
      "name": "Sprint 1 - Desarrollo base del sistema",
      "start_date": "2025-01-06",
      "end_date": "2025-01-24",
      "status": "CLOSED",
      "project_id": 1,
      "sprint_number": 1,
      "is_active": false,
      "created_at": "2025-01-06T08:00:00Z"
    },
    {
      "sprint_id": 2,
      "name": "Sprint 2 - Implementacion de KPIs y metricas",
      "start_date": "2025-01-27",
      "end_date": "2025-02-17",
      "status": "ACTIVE",
      "project_id": 1,
      "sprint_number": 2,
      "is_active": true,
      "created_at": "2025-01-27T08:00:00Z"
    }
  ]
}
```

---

### `GET /sprints/{sprint_id}`
Full sprint detail. Powers the **Sprint 12 Alpha** card on the Developer Dashboard showing velocity %, days left, and story points.

**Response `200 OK`**
```json
{
  "sprint_id": 2,
  "name": "Sprint 2 - Implementacion de KPIs y metricas",
  "start_date": "2025-01-27",
  "end_date": "2025-02-17",
  "status": "ACTIVE",
  "project_id": 1,
  "project_name": "Proyecto Alpha",
  "sprint_number": 2,
  "is_active": true,
  "days_left": 4,
  "total_story_points": 25,
  "completed_story_points": 18,
  "velocity_percent": 72,
  "total_tasks": 8,
  "completed_tasks": 2,
  "in_progress_tasks": 2,
  "pending_tasks": 4,
  "on_track": true
}
```

---

### `POST /sprints`
Creates a new sprint and links it to a project via `PROJECT_SPRINTS`.

**Request Body**
```json
{
  "name": "Sprint 3 - Despliegue y estabilización",
  "start_date": "2025-02-18",
  "end_date": "2025-03-07",
  "status": "PLANNED",
  "project_id": 1
}
```

**Response `201 Created`**
```json
{
  "sprint_id": 3,
  "name": "Sprint 3 - Despliegue y estabilización",
  "start_date": "2025-02-18",
  "end_date": "2025-03-07",
  "status": "PLANNED",
  "project_id": 1,
  "sprint_number": 3,
  "is_active": false,
  "created_at": "2025-04-09T10:00:00Z"
}
```

**Response `400 Bad Request`**
```json
{ "error": "END_DATE must be greater than or equal to START_DATE." }
```

---

### `PUT /sprints/{sprint_id}`
Updates sprint fields. Closing a sprint (`status: CLOSED`) triggers KPI aggregation server-side.

**Request Body**
```json
{
  "name": "Sprint 2 - KPIs y métricas (rev)",
  "end_date": "2025-02-20",
  "status": "CLOSED"
}
```

**Response `200 OK`** — returns updated sprint object (same shape as `GET /sprints/{sprint_id}`).

---

### `DELETE /sprints/{sprint_id}`
Soft-deletes a sprint.

**Response `200 OK`**
```json
{ "message": "Sprint soft-deleted successfully.", "sprint_id": 3 }
```

---

## 7. Tasks

> **Screens:** Developer Dashboard (My Tasks list — next 5 due, time tracking active task), Project Backlog (full paginated task table with filters, priority badges, status icons, assignee avatars, due dates), Performance Reports (task completion counts per member)

---

### `GET /tasks`
Returns tasks with rich filtering. Backbone of the **Project Backlog** table.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `project_id` | integer | Filter by project |
| `sprint_id` | integer | Filter by sprint |
| `assigned_to` | integer | Filter by assignee user ID |
| `created_by` | integer | Filter by creator |
| `task_stage` | string | `BACKLOG` \| `SPRINT` \| `COMPLETED` |
| `status` | string | `PENDING` \| `IN_PROGRESS` \| `DONE` \| `CANCELLED` \| `REOPENED` |
| `priority` | string | `LOW` \| `MEDIUM` \| `HIGH` |
| `due_before` | date | Filter tasks with due date ≤ this value |
| `due_after` | date | Filter tasks with due date ≥ this value |
| `page` | integer | Default `1` |
| `limit` | integer | Default `20`, max `100` |

**Response `200 OK`**
```json
{
  "total": 124,
  "page": 1,
  "limit": 20,
  "data": [
    {
      "task_id": 1,
      "project_id": 1,
      "project_name": "Proyecto Alpha",
      "sprint_id": 1,
      "sprint_name": "Sprint 1 - Desarrollo base del sistema",
      "title": "Definir endpoints de la API",
      "description": "Especificar y documentar todos los endpoints REST que expone el sistema",
      "task_stage": "COMPLETED",
      "status": "DONE",
      "priority": "HIGH",
      "created_by": 1,
      "creator_name": "Inigo Gonzalez",
      "assigned_to": 2,
      "assignee_name": "Victor Martinez",
      "due_date": "2025-01-07",
      "created_at": "2025-01-06T08:00:00Z",
      "updated_at": null,
      "is_deleted": false
    },
    {
      "task_id": 9,
      "project_id": 1,
      "project_name": "Proyecto Alpha",
      "sprint_id": 2,
      "sprint_name": "Sprint 2 - Implementacion de KPIs y metricas",
      "title": "Implementar lógica para calcular los KPIs",
      "description": "Desarrollar los cálculos de cada KPI definido",
      "task_stage": "SPRINT",
      "status": "IN_PROGRESS",
      "priority": "HIGH",
      "created_by": 1,
      "creator_name": "Inigo Gonzalez",
      "assigned_to": 4,
      "assignee_name": "Miguel Angel Alvarez",
      "due_date": "2025-01-31",
      "created_at": "2025-01-27T08:00:00Z",
      "updated_at": "2025-01-29T09:00:00Z",
      "is_deleted": false
    }
  ]
}
```

---

### `GET /tasks/{task_id}`
Full task detail including complete status and sprint history.

**Response `200 OK`**
```json
{
  "task_id": 9,
  "project_id": 1,
  "project_name": "Proyecto Alpha",
  "sprint_id": 2,
  "sprint_name": "Sprint 2 - Implementacion de KPIs y metricas",
  "title": "Implementar lógica para calcular los KPIs",
  "description": "Desarrollar los cálculos de cada KPI definido: tareas completadas, cumplimiento, MTTR, etc.",
  "task_stage": "SPRINT",
  "status": "IN_PROGRESS",
  "priority": "HIGH",
  "created_by": 1,
  "creator_name": "Inigo Gonzalez",
  "assigned_to": 4,
  "assignee_name": "Miguel Angel Alvarez",
  "due_date": "2025-01-31",
  "created_at": "2025-01-27T08:00:00Z",
  "updated_at": "2025-01-29T09:00:00Z",
  "is_deleted": false,
  "status_history": [
    {
      "history_id": 9,
      "old_status": "PENDING",
      "new_status": "IN_PROGRESS",
      "changed_by": 4,
      "changed_by_name": "Miguel Angel Alvarez",
      "changed_at": "2025-01-29T09:00:00Z"
    }
  ],
  "sprint_history": [
    {
      "history_id": 9,
      "old_sprint_id": null,
      "old_sprint_name": null,
      "new_sprint_id": 2,
      "new_sprint_name": "Sprint 2 - Implementacion de KPIs y metricas",
      "changed_by": 1,
      "changed_by_name": "Inigo Gonzalez",
      "changed_at": "2025-01-27T08:00:00Z"
    }
  ]
}
```

---

### `GET /tasks/my`
Returns the **next N tasks due** for the currently authenticated user. Directly feeds the **My Tasks (Next 5 Due)** panel and the **Time Tracking** active task on the Developer Dashboard.

**Headers** `Authorization: Bearer <token>`

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `limit` | integer | Default `5` |
| `sprint_id` | integer | Optionally restrict to a specific sprint |

**Response `200 OK`**
```json
{
  "user_id": 2,
  "user_name": "Victor Martinez",
  "tasks": [
    {
      "task_id": 7,
      "title": "Definir cómo se recolectarán las métricas",
      "project_name": "Proyecto Alpha",
      "sprint_name": "Sprint 2 - Implementacion de KPIs y metricas",
      "issue_number": 402,
      "task_stage": "SPRINT",
      "status": "DONE",
      "priority": "HIGH",
      "due_date": "2025-01-29",
      "is_today": false,
      "is_tomorrow": false,
      "is_overdue": false
    },
    {
      "task_id": 13,
      "title": "Integrar dashboard con el API",
      "project_name": "Proyecto Alpha",
      "sprint_name": "Sprint 2 - Implementacion de KPIs y metricas",
      "issue_number": 388,
      "task_stage": "SPRINT",
      "status": "PENDING",
      "priority": "HIGH",
      "due_date": "2025-02-13",
      "is_today": false,
      "is_tomorrow": true,
      "is_overdue": false
    }
  ]
}
```

---

### `POST /tasks`
Creates a new task. Triggered by the **+ New Task** button in the Project Backlog screen.

**Request Body**
```json
{
  "project_id": 1,
  "sprint_id": 2,
  "title": "Pruebas del dashboard y validación de métricas",
  "description": "Verificar que las métricas mostradas coinciden con los valores calculados en el backend",
  "task_stage": "SPRINT",
  "status": "PENDING",
  "priority": "MEDIUM",
  "created_by": 1,
  "assigned_to": 5,
  "due_date": "2025-02-17"
}
```

**Response `201 Created`**
```json
{
  "task_id": 14,
  "project_id": 1,
  "sprint_id": 2,
  "title": "Pruebas del dashboard y validación de métricas",
  "task_stage": "SPRINT",
  "status": "PENDING",
  "priority": "MEDIUM",
  "created_by": 1,
  "assigned_to": 5,
  "assignee_name": "Jinhyuk Park",
  "due_date": "2025-02-17",
  "created_at": "2025-04-09T10:00:00Z"
}
```

---

### `PUT /tasks/{task_id}`
Updates any task field. Used for status changes, reassignment, priority edits, and sprint moves from the Backlog.

> **Side effects:**
> - If `status` changes → auto-inserts row into `TASK_STATUS_HISTORY`
> - If `sprint_id` changes → auto-inserts row into `TASK_SPRINT_HISTORY`
> - Always writes to `AUDIT_LOG`

**Request Body** *(all fields optional)*
```json
{
  "title": "Pruebas del dashboard y validación de métricas",
  "sprint_id": 2,
  "task_stage": "SPRINT",
  "status": "IN_PROGRESS",
  "priority": "HIGH",
  "assigned_to": 5,
  "due_date": "2025-02-17"
}
```

**Response `200 OK`** — returns updated task object (same shape as `GET /tasks/{task_id}`).

---

### `DELETE /tasks/{task_id}`
Soft-deletes a task.

**Response `200 OK`**
```json
{ "message": "Task soft-deleted successfully.", "task_id": 14, "deleted_at": "2025-04-09T10:00:00Z" }
```

---

### `GET /tasks/{task_id}/status-history`
Returns the complete status change log for a task.

**Response `200 OK`**
```json
{
  "task_id": 1,
  "history": [
    {
      "history_id": 1,
      "old_status": "PENDING",
      "new_status": "IN_PROGRESS",
      "changed_by": 2,
      "changed_by_name": "Victor Martinez",
      "changed_at": "2025-01-06T09:00:00Z"
    },
    {
      "history_id": 2,
      "old_status": "IN_PROGRESS",
      "new_status": "DONE",
      "changed_by": 2,
      "changed_by_name": "Victor Martinez",
      "changed_at": "2025-01-07T17:00:00Z"
    }
  ]
}
```

---

### `GET /tasks/{task_id}/sprint-history`
Returns the sprint reassignment history for a task (carryover across sprints).

**Response `200 OK`**
```json
{
  "task_id": 7,
  "history": [
    {
      "history_id": 7,
      "old_sprint_id": null,
      "old_sprint_name": null,
      "new_sprint_id": 2,
      "new_sprint_name": "Sprint 2 - Implementacion de KPIs y metricas",
      "changed_by": 1,
      "changed_by_name": "Inigo Gonzalez",
      "changed_at": "2025-01-27T08:00:00Z"
    }
  ]
}
```

---

## 8. KPI Types

> **Screens:** Performance Reports (KPI category labels), Dashboard KPI panels

---

### `GET /kpi-types`
Returns all KPI type definitions.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `category` | string | `DELIVERY` \| `QUALITY` \| `ACTIVITY` \| `DEVOPS` \| `ENGAGEMENT` \| `RELIABILITY` \| `INFRA` \| `SECURITY` |

**Response `200 OK`**
```json
{
  "data": [
    {
      "kpi_type_id": 1,
      "name": "TAREAS_COMPLETADAS_SPRINT",
      "description": "Tareas con STATUS=DONE por sprint",
      "category": "DELIVERY",
      "unit": "count"
    },
    {
      "kpi_type_id": 2,
      "name": "CUMPLIMIENTO_SPRINT",
      "description": "Tareas done / total tareas del sprint",
      "category": "DELIVERY",
      "unit": "percent"
    },
    {
      "kpi_type_id": 7,
      "name": "MTTR",
      "description": "Tiempo medio de recuperación de incidentes",
      "category": "DEVOPS",
      "unit": "minutes"
    }
  ]
}
```

---

### `POST /kpi-types`

**Request Body**
```json
{
  "name": "VELOCIDAD_EQUIPO",
  "description": "Story points entregados por sprint",
  "category": "DELIVERY",
  "unit": "points"
}
```

**Response `201 Created`** — returns created KPI type object.

---

### `PUT /kpi-types/{kpi_type_id}`

**Request Body**
```json
{
  "description": "Updated description",
  "unit": "percent"
}
```

**Response `200 OK`** — returns updated KPI type object.

---

### `DELETE /kpi-types/{kpi_type_id}`

**Response `200 OK`**
```json
{ "message": "KPI type deleted successfully." }
```

---

## 9. KPI Values

> **Screens:** Workspace Overview (budget, velocity, quality score KPI cards), Performance Reports (sprint compliance trends)

---

### `GET /kpi-values`
Returns KPI measurements filtered by scope. Primary data source for all metric displays.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `kpi_type_id` | integer | Filter by KPI type |
| `scope_type` | string | `USER` \| `PROJECT` \| `SPRINT` \| `GLOBAL` |
| `user_id` | integer | Required when `scope_type=USER` |
| `project_id` | integer | Required when `scope_type=PROJECT` |
| `sprint_id` | integer | Required when `scope_type=SPRINT` |
| `from` | datetime | Recorded-at range start (ISO 8601) |
| `to` | datetime | Recorded-at range end (ISO 8601) |
| `page` | integer | Default `1` |
| `limit` | integer | Default `50` |

**Response `200 OK`**
```json
{
  "total": 13,
  "data": [
    {
      "kpi_value_id": 1,
      "kpi_type_id": 1,
      "kpi_name": "TAREAS_COMPLETADAS_SPRINT",
      "category": "DELIVERY",
      "unit": "count",
      "scope_type": "SPRINT",
      "sprint_id": 1,
      "sprint_name": "Sprint 1 - Desarrollo base del sistema",
      "project_id": null,
      "user_id": null,
      "value": 6,
      "recorded_at": "2025-01-24T23:59:00Z"
    },
    {
      "kpi_value_id": 3,
      "kpi_type_id": 2,
      "kpi_name": "CUMPLIMIENTO_SPRINT",
      "category": "DELIVERY",
      "unit": "percent",
      "scope_type": "SPRINT",
      "sprint_id": 1,
      "sprint_name": "Sprint 1 - Desarrollo base del sistema",
      "project_id": null,
      "user_id": null,
      "value": 100.00,
      "recorded_at": "2025-01-24T23:59:00Z"
    }
  ]
}
```

---

### `POST /kpi-values`
Records a new KPI measurement.

**Request Body**
```json
{
  "kpi_type_id": 1,
  "scope_type": "SPRINT",
  "sprint_id": 2,
  "value": 2,
  "recorded_at": "2025-02-06T23:59:00Z"
}
```

**Response `201 Created`**
```json
{
  "kpi_value_id": 14,
  "kpi_type_id": 1,
  "kpi_name": "TAREAS_COMPLETADAS_SPRINT",
  "scope_type": "SPRINT",
  "sprint_id": 2,
  "value": 2,
  "recorded_at": "2025-02-06T23:59:00Z"
}
```

**Response `400 Bad Request`**
```json
{ "error": "scope_type=SPRINT requires sprint_id to be provided." }
```

---

### `PUT /kpi-values/{kpi_value_id}`

**Request Body**
```json
{
  "value": 3,
  "recorded_at": "2025-02-07T00:00:00Z"
}
```

**Response `200 OK`** — returns updated KPI value object.

---

### `DELETE /kpi-values/{kpi_value_id}`

**Response `200 OK`**
```json
{ "message": "KPI value deleted successfully.", "kpi_value_id": 14 }
```

---

## 10. Dashboard (Aggregated)

> **Screens:** Developer Dashboard (all widgets), Workspace Overview (all cards, spotlight strip, critical notifications)

These endpoints combine data from multiple tables into a single call to avoid N+1 round trips.

---

### `GET /dashboard`
Master aggregation endpoint. Returns everything both dashboard screens need in one response.

**Headers** `Authorization: Bearer <token>`

**Response `200 OK`**
```json
{
  "user": {
    "user_id": 1,
    "full_name": "Inigo Gonzalez",
    "role": "MANAGER",
    "team_name": "Backend Team"
  },
  "greeting_summary": {
    "high_priority_task_count": 3,
    "pending_review_count": 2,
    "current_sprint_name": "Sprint 2 - Implementacion de KPIs y metricas"
  },
  "current_sprint": {
    "sprint_id": 2,
    "name": "Sprint 2 - Implementacion de KPIs y metricas",
    "status": "ACTIVE",
    "days_left": 4,
    "velocity_percent": 72,
    "completed_story_points": 18,
    "total_story_points": 25,
    "on_track": true
  },
  "my_tasks_next5": [
    {
      "task_id": 9,
      "title": "Implementar lógica para calcular los KPIs",
      "project_name": "Proyecto Alpha",
      "issue_number": 415,
      "status": "IN_PROGRESS",
      "priority": "HIGH",
      "due_date": "2025-01-31",
      "is_today": false,
      "is_tomorrow": false,
      "is_overdue": false
    }
  ],
  "time_tracking": {
    "active_task_id": 9,
    "active_task_title": "Implementar lógica para calcular los KPIs",
    "session_seconds": 15735,
    "started_at": "2025-02-06T05:37:45Z"
  },
  "workspace": {
    "budget_utilization_usd": 428500,
    "budget_percent_used": 68,
    "budget_status": "ON_TRACK",
    "team_velocity_pts_wk": 54.2,
    "velocity_change_pct": 12,
    "quality_score": 9.8,
    "quality_max": 10,
    "project_health_label": "Excellent",
    "team_capacity_percent": 84,
    "active_seats": 24,
    "resource_allocation": {
      "engineering_pct": 40,
      "design_pct": 30,
      "management_pct": 30
    }
  },
  "recent_activity": [
    {
      "author": "Sarah Chen",
      "entity_type": "PR",
      "entity_ref": "PR #882",
      "comment": "Optimize DB query on line 142 by indexing project_id.",
      "timestamp": "2025-02-06T09:36:00Z",
      "minutes_ago": 24
    },
    {
      "author": "Marcus Thorne",
      "entity_type": "PR",
      "entity_ref": "PR #879",
      "comment": "Security headers must be included. Check middleware config.",
      "timestamp": "2025-02-06T07:36:00Z",
      "minutes_ago": 120
    },
    {
      "author": "Elena Rodriguez",
      "entity_type": "ISSUE",
      "entity_ref": "Issue #402",
      "comment": "@dev-alpha please verify deployment schedule. Client wants it by Friday.",
      "timestamp": "2025-02-06T05:00:00Z",
      "minutes_ago": 300
    }
  ],
  "critical_notifications": [
    {
      "type": "RESOURCE_CONFLICT",
      "message": "Marcus assigned to 3 overlapping tasks in Project Nexus.",
      "timestamp": "2025-02-06T08:00:00Z",
      "is_read": false
    },
    {
      "type": "BUDGET_MILESTONE",
      "message": "Design phase billing approved by Client: Enterprise Corp.",
      "timestamp": "2025-02-06T06:00:00Z",
      "is_read": false
    },
    {
      "type": "SECURITY",
      "message": "Updated access controls for Horizon internal repository.",
      "timestamp": "2025-02-05T10:00:00Z",
      "is_read": false
    }
  ],
  "spotlight_project": {
    "project_id": 1,
    "name": "Project Meridian: Sustainable Urban Campus",
    "phase": "Phase 2",
    "status_note": "Ahead of schedule. Reviewing environmental impact reports.",
    "team_member_count": 12,
    "team_avatar_overflow": 12
  }
}
```

---

### `POST /dashboard/notifications/clear`
Clears all unread notifications. Triggered by the **Clear Notifications** button in Workspace Overview.

**Response `200 OK`**
```json
{ "message": "All notifications cleared.", "cleared_count": 3 }
```

---

### `GET /dashboard/time-tracking`
Returns only the active time tracking session. Used to render the live timer in the **Time Tracking** card.

**Headers** `Authorization: Bearer <token>`

**Response `200 OK`**
```json
{
  "user_id": 2,
  "active_task": {
    "task_id": 9,
    "title": "Implementar lógica para calcular los KPIs",
    "project_name": "Proyecto Alpha",
    "sprint_name": "Sprint 2 - Implementacion de KPIs y metricas"
  },
  "session_seconds": 15735,
  "started_at": "2025-02-06T05:37:45Z"
}
```

---

### `POST /dashboard/time-tracking/pause`
Pauses the active time session. Triggered by the **Pause** button.

**Request Body**
```json
{ "task_id": 9 }
```

**Response `200 OK`**
```json
{
  "task_id": 9,
  "session_seconds": 15800,
  "paused_at": "2025-04-09T10:00:00Z",
  "status": "PAUSED"
}
```

---

### `POST /dashboard/time-tracking/complete`
Marks the session complete and logs time. Triggered by the **Complete** button.

**Request Body**
```json
{ "task_id": 9 }
```

**Response `200 OK`**
```json
{
  "task_id": 9,
  "total_session_seconds": 16050,
  "completed_at": "2025-04-09T10:00:00Z",
  "status": "COMPLETED"
}
```

---

## 11. Reports & Analytics

> **Screens:** Performance Reports (burndown chart, cumulative flow widget, sprint velocity bar chart, task completion rate table), Workspace Overview (next milestones timeline)

---

### `GET /reports/burndown`
Returns ideal and actual remaining work per day for a sprint's burndown chart.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `sprint_id` | integer | **Required** |

**Response `200 OK`**
```json
{
  "sprint_id": 2,
  "sprint_name": "Sprint 2 - Implementacion de KPIs y metricas",
  "on_track": true,
  "total_points": 25,
  "ideal_line": [
    { "day": "Mon", "ideal_remaining": 25 },
    { "day": "Tue", "ideal_remaining": 21 },
    { "day": "Wed", "ideal_remaining": 17 },
    { "day": "Thu", "ideal_remaining": 13 },
    { "day": "Fri", "ideal_remaining": 9  },
    { "day": "Sat", "ideal_remaining": 5  },
    { "day": "Sun", "ideal_remaining": 0  }
  ],
  "actual_line": [
    { "day": "Mon", "actual_remaining": 25 },
    { "day": "Tue", "actual_remaining": 20 },
    { "day": "Wed", "actual_remaining": 16 },
    { "day": "Thu", "actual_remaining": 12 },
    { "day": "Fri", "actual_remaining": 7  },
    { "day": "Sat", "actual_remaining": 4  }
  ]
}
```

---

### `GET /reports/sprint-velocity`
Returns story points delivered per sprint iteration. Powers the **Sprint Velocity** bar chart.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `project_id` | integer | **Required** |
| `last_n` | integer | Number of past sprints to return (default `6`) |

**Response `200 OK`**
```json
{
  "project_id": 1,
  "current_velocity": 42.8,
  "change_vs_last_pct": 12,
  "sprints": [
    { "sprint_id": 1, "label": "SPR 19", "points_delivered": 45, "is_current": false },
    { "sprint_id": 2, "label": "SPR 20", "points_delivered": 38, "is_current": false },
    { "sprint_id": 3, "label": "SPR 21", "points_delivered": 41, "is_current": false },
    { "sprint_id": 4, "label": "SPR 22", "points_delivered": 52, "is_current": false },
    { "sprint_id": 5, "label": "SPR 23", "points_delivered": 39, "is_current": false },
    { "sprint_id": 6, "label": "CURR",   "points_delivered": 42, "is_current": true  }
  ]
}
```

---

### `GET /reports/cumulative-flow`
Returns task count by stage per week. Powers the **Cumulative Flow** stacked bar widget.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `project_id` | integer | **Required** |
| `weeks` | integer | Number of weeks to include (default `7`) |

**Response `200 OK`**
```json
{
  "project_id": 1,
  "weeks": [
    { "week": "W1", "backlog": 12, "in_progress": 5, "done": 3  },
    { "week": "W2", "backlog": 10, "in_progress": 7, "done": 6  },
    { "week": "W3", "backlog": 9,  "in_progress": 4, "done": 9  },
    { "week": "W4", "backlog": 7,  "in_progress": 6, "done": 11 },
    { "week": "W5", "backlog": 8,  "in_progress": 5, "done": 12 },
    { "week": "W6", "backlog": 5,  "in_progress": 8, "done": 14 },
    { "week": "W7", "backlog": 4,  "in_progress": 3, "done": 16 }
  ]
}
```

---

### `GET /reports/task-completion`
Returns per-member task assignment and completion stats. Powers the **Task Completion Rate** table with efficiency % and trend arrows.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `project_id` | integer | Filter by project |
| `sprint_id` | integer | Filter by sprint |

**Response `200 OK`**
```json
{
  "data": [
    {
      "user_id": 2,
      "full_name": "Victor Martinez",
      "role": "DEVELOPER",
      "assigned": 24,
      "completed": 22,
      "efficiency_percent": 92,
      "trend": "UP",
      "trend_delta_pct": 5
    },
    {
      "user_id": 3,
      "full_name": "Paolo Gaya",
      "role": "DEVELOPER",
      "assigned": 18,
      "completed": 17,
      "efficiency_percent": 94,
      "trend": "UP",
      "trend_delta_pct": 3
    },
    {
      "user_id": 4,
      "full_name": "Miguel Angel Alvarez",
      "role": "DEVELOPER",
      "assigned": 32,
      "completed": 25,
      "efficiency_percent": 78,
      "trend": "FLAT",
      "trend_delta_pct": 0
    }
  ]
}
```

---

### `GET /reports/milestones`
Returns the ordered milestone timeline. Powers the **Next Milestones** roadmap strip in Workspace Overview.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `project_id` | integer | **Required** |

**Response `200 OK`**
```json
{
  "project_id": 1,
  "milestones": [
    { "name": "Concept",    "date": "2025-05-12", "status": "DONE",        "is_current": false },
    { "name": "Wireframes", "date": "2025-05-24", "status": "DONE",        "is_current": false },
    { "name": "UI Phase",   "date": "2025-06-10", "status": "IN_PROGRESS", "is_current": true  },
    { "name": "Prototype",  "date": "2025-06-15", "status": "PENDING",     "is_current": false },
    { "name": "Delivery",   "date": "2025-06-30", "status": "PENDING",     "is_current": false }
  ]
}
```

---

### `GET /reports/export`
Exports the current sprint's performance report as a PDF binary stream. Triggered by the **Export PDF** button.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `sprint_id` | integer | **Required** |

**Response `200 OK`**
- `Content-Type: application/pdf`
- `Content-Disposition: attachment; filename="sprint_2_report.pdf"`

---

## 12. Deployments

> **Screens:** Workspace Overview (critical activity — budget milestone and deployment events), Developer Dashboard (activity feed)

---

### `GET /deployments`
Returns deployment records filtered by project, environment, or status.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `project_id` | integer | Filter by project |
| `environment` | string | `DEV` \| `QA` \| `STAGING` \| `PRODUCTION` |
| `status` | string | `SUCCESS` \| `FAILED` \| `IN_PROGRESS` |
| `page` | integer | Default `1` |
| `limit` | integer | Default `20` |

**Response `200 OK`**
```json
{
  "total": 8,
  "data": [
    {
      "deployment_id": 4,
      "project_id": 1,
      "project_name": "Proyecto Alpha",
      "version": "v1.0.0",
      "environment": "PRODUCTION",
      "status": "SUCCESS",
      "deployed_at": "2025-01-24T20:00:00Z",
      "recovery_time_min": null
    },
    {
      "deployment_id": 6,
      "project_id": 1,
      "project_name": "Proyecto Alpha",
      "version": "v1.1.0",
      "environment": "QA",
      "status": "FAILED",
      "deployed_at": "2025-01-29T11:00:00Z",
      "recovery_time_min": 35.0
    }
  ]
}
```

---

### `POST /deployments`

**Request Body**
```json
{
  "project_id": 1,
  "version": "v1.2.0",
  "environment": "DEV",
  "status": "IN_PROGRESS",
  "deployed_at": "2025-02-06T09:00:00Z"
}
```

**Response `201 Created`** — returns created deployment object.

---

### `PUT /deployments/{deployment_id}`
Updates a deployment, typically to mark it `SUCCESS` or `FAILED` after completion.

**Request Body**
```json
{
  "status": "SUCCESS",
  "recovery_time_min": null
}
```

**Response `200 OK`** — returns updated deployment object.

---

## 13. Incidents

> **Screens:** Workspace Overview (critical activity — security and performance incident references), Developer Dashboard (activity feed)

---

### `GET /incidents`

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `project_id` | integer | Filter by project |
| `severity` | string | `LOW` \| `MEDIUM` \| `HIGH` \| `CRITICAL` |
| `resolved` | boolean | `true` = resolved only; `false` = open only |
| `page` | integer | Default `1` |
| `limit` | integer | Default `20` |

**Response `200 OK`**
```json
{
  "total": 4,
  "data": [
    {
      "incident_id": 4,
      "project_id": 1,
      "project_name": "Proyecto Alpha",
      "type": "PERFORMANCE",
      "description": "Incremento sostenido en uso de CPU por encima del 70% desde las 09:00.",
      "severity": "HIGH",
      "occurred_at": "2025-02-06T09:00:00Z",
      "resolved_at": null,
      "is_open": true,
      "is_deleted": false
    }
  ]
}
```

---

### `POST /incidents`

**Request Body**
```json
{
  "project_id": 1,
  "type": "SECURITY",
  "description": "Intento de acceso no autorizado detectado en /api/admin desde IP externa.",
  "severity": "CRITICAL",
  "occurred_at": "2025-02-06T03:10:00Z"
}
```

**Response `201 Created`** — returns created incident object.

---

### `PUT /incidents/{incident_id}`
Resolves or updates an incident. Set `resolved_at` to mark it closed.

**Request Body**
```json
{ "resolved_at": "2025-02-06T04:00:00Z" }
```

**Response `200 OK`** — returns updated incident object.

---

### `DELETE /incidents/{incident_id}`
Soft-deletes an incident.

**Response `200 OK`**
```json
{ "message": "Incident soft-deleted successfully." }
```

---

## 14. Bot Interactions

> **Screens:** Developer Dashboard (activity feed may surface bot responses), all screens via Telegram-initiated queries

---

### `GET /bot/interactions`
Returns the bot conversation history.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `user_id` | integer | Filter to a specific user's history |
| `from` | datetime | Range start |
| `to` | datetime | Range end |
| `page` | integer | Default `1` |
| `limit` | integer | Default `20` |

**Response `200 OK`**
```json
{
  "total": 6,
  "data": [
    {
      "interaction_id": 1,
      "user_id": 2,
      "user_name": "Victor Martinez",
      "message": "/tareas pendientes",
      "response": "Tienes 2 tareas activas en Sprint 2: 'Implementar lógica para calcular los KPIs' (IN_PROGRESS) y 'Integrar dashboard con el API' (PENDING).",
      "created_at": "2025-02-05T09:15:00Z"
    }
  ]
}
```

---

### `POST /bot/message`
Primary Telegram webhook entry point. Receives a message, queries the system, returns a natural language response. Also used by the web chat interface.

**Request Body**
```json
{
  "user_id": 1,
  "message": "/sprint actual"
}
```

**Response `200 OK`**
```json
{
  "interaction_id": 7,
  "user_id": 1,
  "user_name": "Inigo Gonzalez",
  "message": "/sprint actual",
  "response": "Sprint 2 del Proyecto Alpha está activo (27-Ene al 17-Feb). Objetivo: Implementación de KPIs y métricas. Progreso: 2/8 tareas completadas. Velocidad actual: 72%.",
  "created_at": "2025-04-09T10:00:00Z"
}
```

---

## 15. LLM Analysis

> **Screens:** Team Management (Architect AI Tip card), Workspace Overview (critical anomaly alerts in notifications)

---

### `GET /llm-analysis`
Returns stored AI analysis records filtered by scope.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `scope_type` | string | `USER` \| `PROJECT` \| `SPRINT` \| `GLOBAL` |
| `user_id` | integer | Required when `scope_type=USER` |
| `project_id` | integer | Required when `scope_type=PROJECT` |
| `sprint_id` | integer | Required when `scope_type=SPRINT` |
| `anomaly_only` | boolean | If `true`, returns only records where `anomaly_detected=true` |
| `page` | integer | Default `1` |
| `limit` | integer | Default `20` |

**Response `200 OK`**
```json
{
  "total": 4,
  "data": [
    {
      "analysis_id": 2,
      "scope_type": "PROJECT",
      "project_id": 1,
      "project_name": "Proyecto Alpha",
      "user_id": null,
      "sprint_id": null,
      "anomaly_detected": true,
      "anomaly_type": "LOW_SPRINT_PROGRESS",
      "confidence_score": 82.50,
      "recommendation": "Sprint 2 muestra 25% de cumplimiento al cierre de la primera semana. Se recomienda revisar avance y coordinar con el equipo para identificar bloqueos.",
      "analysis_date": "2025-02-06T10:00:00Z"
    },
    {
      "analysis_id": 4,
      "scope_type": "GLOBAL",
      "project_id": null,
      "user_id": null,
      "sprint_id": null,
      "anomaly_detected": false,
      "anomaly_type": null,
      "confidence_score": 99.00,
      "recommendation": "El sistema opera dentro de parámetros normales. Interacciones del bot estables con tendencia positiva de adopción.",
      "analysis_date": "2025-02-06T09:00:00Z"
    }
  ]
}
```

---

### `POST /llm-analysis/trigger`
Triggers a fresh AI analysis for a given scope. Executes asynchronously and stores the result in `LLM_ANALYSIS`.

**Request Body**
```json
{
  "scope_type": "SPRINT",
  "sprint_id": 2
}
```

**Response `202 Accepted`**
```json
{
  "message": "Analysis triggered. Result will be available shortly.",
  "scope_type": "SPRINT",
  "sprint_id": 2,
  "estimated_completion_seconds": 10
}
```

---

## 16. Audit Log

> **Screens:** Not directly rendered in the UI but backs all security and compliance reviews referenced by incident and security notifications

---

### `GET /audit-log`
Returns the full audit trail with filtering.

**Query Parameters**

| Parameter | Type | Description |
|---|---|---|
| `user_id` | integer | Filter by actor |
| `entity_name` | string | e.g. `TASKS`, `DEPLOYMENTS`, `USERS` |
| `action_type` | string | `CREATE` \| `UPDATE` \| `DELETE` \| `LOGIN_ATTEMPT` |
| `from` | datetime | Range start |
| `to` | datetime | Range end |
| `page` | integer | Default `1` |
| `limit` | integer | Default `50` |

**Response `200 OK`**
```json
{
  "total": 9,
  "data": [
    {
      "audit_id": 1,
      "user_id": 1,
      "user_name": "Inigo Gonzalez",
      "action_type": "CREATE",
      "entity_name": "PROJECTS",
      "entity_id": 1,
      "action_date": "2025-01-06T08:00:00Z",
      "ip_address": "192.168.1.10"
    },
    {
      "audit_id": 8,
      "user_id": null,
      "user_name": null,
      "action_type": "LOGIN_ATTEMPT",
      "entity_name": "USER_CREDENTIALS",
      "entity_id": null,
      "action_date": "2025-01-28T03:10:00Z",
      "ip_address": "203.0.113.42"
    }
  ]
}
```

---

## 17. HTTP Status Code Reference

| Code | Meaning | When used |
|---|---|---|
| `200 OK` | Successful read or update | `GET`, `PUT`, `DELETE` success |
| `201 Created` | Resource created | `POST` success |
| `202 Accepted` | Async operation queued | LLM analysis trigger |
| `400 Bad Request` | Invalid or missing parameters | Constraint violations, scope mismatches, date errors |
| `401 Unauthorized` | Missing or invalid JWT | No token or expired token |
| `403 Forbidden` | Authenticated but not permitted | Role-based access violation |
| `404 Not Found` | Resource doesn't exist or is soft-deleted | ID not found |
| `409 Conflict` | Duplicate unique value | Duplicate email, username, sprint number |
| `500 Internal Server Error` | Unhandled server exception | Unexpected failures |

---

## Side Effects Summary

| Trigger | Automatic Side Effect |
|---|---|
| `PUT /tasks/{id}` with a new `status` value | Inserts row in `TASK_STATUS_HISTORY` |
| `PUT /tasks/{id}` with a new `sprint_id` value | Inserts row in `TASK_SPRINT_HISTORY` |
| `PUT /sprints/{id}` with `status: CLOSED` | Triggers KPI aggregation job server-side |
| Any `POST`, `PUT`, `DELETE` call | Inserts row in `AUDIT_LOG` |
| `POST /bot/message` | Inserts row in `BOT_INTERACTIONS` |
| `POST /llm-analysis/trigger` | Inserts row in `LLM_ANALYSIS` on completion |
