# DB Setup Guide — EQUIPO65

Step-by-step instructions for initialising the Oracle ATP database from scratch using the files in `sprint-3-db/`.

---

## Prerequisites

- Access to **Oracle SQL Developer**, **SQLcl**, or the **ATP SQL Worksheet** (Database Actions).
- Connection credentials for the target schema (e.g. `EQUIPO65` / `ADMIN`).
- The schema must be **empty** before running Step 1. If re-initialising, drop all existing objects first.

---

## Execution Order

The files must be run in the exact order below. Each step depends on the previous one completing without errors.

```
sprint-3-db/
├── db_schema.sql                           ← Step 1
├── template_data/
│   ├── users.sql                           ← Step 2
│   ├── kpis.sql                            ← Step 3
│   └── kpi_seed_data.sql                   ← Step 8
├── triggers.sql                            ← Step 4
└── template_data/sprints/
    ├── sprint-1.sql                        ← Step 5
    ├── sprint-2.sql                        ← Step 6
    └── sprint-3.sql                        ← Step 7
```

---

## Step 1 — Create All Tables

**File:** `db_schema.sql`

Creates all 18 tables with their primary keys, foreign keys, and check constraints:

| # | Table |
|---|-------|
| 1 | ROLES |
| 2 | TEAMS |
| 3 | USERS |
| 4 | USER_CREDENTIALS |
| 5 | SPRINTS |
| 6 | PROJECTS |
| 7 | PROJECT_MEMBERS |
| 8 | PROJECT_SPRINTS |
| 9 | TASKS |
| 10 | TASK_STATUS_HISTORY |
| 11 | TASK_SPRINT_HISTORY |
| 12 | KPI_TYPES |
| 13 | KPI_VALUES |
| 14 | LLM_ANALYSIS |
| 15 | DEPLOYMENTS |
| 16 | INCIDENTS |
| 17 | BOT_INTERACTIONS |
| 18 | AUDIT_LOG |

**How to run:**
```sql
@db_schema.sql
```

**Verify:**
```sql
SELECT TABLE_NAME FROM USER_TABLES ORDER BY TABLE_NAME;
-- Should return 18 rows
```

---

## Step 2 — Insert Base Users

**File:** `template_data/users.sql`

Inserts the seed rows that every other data file depends on:

- 2 **ROLES**: `MANAGER` (ID 1), `DEVELOPER` (ID 2)
- 2 **TEAMS**: `Backend Team` (ID 1), `Frontend Team` (ID 2)
- 6 **USERS** (IDs 1–6): Inigo, Victor, Paolo, Miguel, Jinhyuk, Luis
- 6 **USER_CREDENTIALS** with bcrypt password hashes

> All `USER_ID` values (1–6) are referenced throughout every other data file. This step must complete before any sprint or task data is loaded.

**How to run:**
```sql
@template_data/users.sql
```

**Verify:**
```sql
SELECT COUNT(*) FROM ROLES;            -- 2
SELECT COUNT(*) FROM TEAMS;            -- 2
SELECT COUNT(*) FROM USERS;            -- 6
SELECT COUNT(*) FROM USER_CREDENTIALS; -- 6
```

---

## Step 3 — Insert KPI Types

**File:** `template_data/kpis.sql`

Inserts the 11 KPI type definitions into `KPI_TYPES`:

| Name | Category | Unit |
|------|----------|------|
| TAREAS_COMPLETADAS_SPRINT | DELIVERY | count |
| CUMPLIMIENTO_SPRINT | DELIVERY | percent |
| TAREAS_REABIERTAS | QUALITY | count |
| ACTUALIZACION_TAREAS_DIA | ACTIVITY | percent |
| TRAZABILIDAD_TAREAS | QUALITY | count |
| DESPLIEGUES_PRODUCCION_SPRINT | DEVOPS | count |
| MTTR | DEVOPS | minutes |
| TASA_EXITO_DESPLIEGUES | DEVOPS | percent |
| INTERACCIONES_BOT | ENGAGEMENT | count |
| DISPONIBILIDAD_SERVICIO | RELIABILITY | percent |
| INCIDENTES_SEGURIDAD | SECURITY | count |

> **This step must run before `triggers.sql` fires on any data.** The `UPSERT_KPI` helper procedure looks up `KPI_TYPE_ID` by name at runtime. If `KPI_TYPES` is empty when a trigger fires, it throws `NO_DATA_FOUND`.

**How to run:**
```sql
@template_data/kpis.sql
```

**Verify:**
```sql
SELECT COUNT(*) FROM KPI_TYPES; -- 11
```

---

## Step 4 — Create Triggers and Helper Procedure

**File:** `triggers.sql`

Creates:
- **`UPSERT_KPI`** — PL/SQL procedure used by all triggers to insert or update `KPI_VALUES`.
- **11 triggers** that automatically populate `KPI_VALUES` on DML events:

| Trigger | Source Table | KPI |
|---------|-------------|-----|
| TRG_KPI_TAREAS_COMPLETADAS | TASKS | TAREAS_COMPLETADAS_SPRINT |
| TRG_KPI_CUMPLIMIENTO | TASKS | CUMPLIMIENTO_SPRINT |
| TRG_KPI_REABIERTAS | TASK_STATUS_HISTORY | TAREAS_REABIERTAS |
| TRG_KPI_ACTUALIZACION_DIA | TASKS | ACTUALIZACION_TAREAS_DIA |
| TRG_KPI_TRAZABILIDAD | TASK_STATUS_HISTORY | TRAZABILIDAD_TAREAS |
| TRG_KPI_DESPLIEGUES_PROD | DEPLOYMENTS | DESPLIEGUES_PRODUCCION_SPRINT |
| TRG_KPI_MTTR | INCIDENTS | MTTR |
| TRG_KPI_TASA_EXITO | DEPLOYMENTS | TASA_EXITO_DESPLIEGUES |
| TRG_KPI_BOT | BOT_INTERACTIONS | INTERACCIONES_BOT |
| TRG_KPI_DISPONIBILIDAD | INCIDENTS | DISPONIBILIDAD_SERVICIO |
| TRG_KPI_INCIDENTES_SEG | INCIDENTS | INCIDENTES_SEGURIDAD |

**How to run:**
```sql
@triggers.sql
```

> If using the **SQL Worksheet** in Database Actions, the file uses PL/SQL blocks terminated with `/`. Use **Run Script** (not Run Statement) so all blocks execute.

**Verify:**
```sql
SELECT OBJECT_NAME, OBJECT_TYPE, STATUS
FROM USER_OBJECTS
WHERE OBJECT_TYPE IN ('PROCEDURE','TRIGGER')
ORDER BY OBJECT_TYPE, OBJECT_NAME;
-- Should show 1 PROCEDURE (UPSERT_KPI) and 11 TRIGGERS, all STATUS=VALID
```

---

## Step 5 — Load Sprint 1 Data

**File:** `template_data/sprints/sprint-1.sql`

Inserts:
- **PROJECT** `OCI Task Manager` (ID 1, managed by user 1)
- **PROJECT_MEMBERS** — all 6 users linked to project 1
- **SPRINT 1** (ID 1): *Plan, Requerimientos y Documentación Base* — CLOSED, Feb 11–25 2026
- **PROJECT_SPRINTS** — sprint 1 linked to project 1, `IS_ACTIVE='N'`
- **35 TASKS** (IDs 1–35) — all `COMPLETED / DONE`

> Each task INSERT fires `TRG_KPI_TAREAS_COMPLETADAS` and `TRG_KPI_CUMPLIMIENTO`, seeding the first `KPI_VALUES` rows.

**How to run:**
```sql
@template_data/sprints/sprint-1.sql
```

**Verify:**
```sql
SELECT COUNT(*) FROM TASKS WHERE SPRINT_ID = 1; -- 35
SELECT COUNT(*) FROM KPI_VALUES;                -- rows should appear
```

---

## Step 6 — Load Sprint 2 Data

**File:** `template_data/sprints/sprint-2.sql`

Inserts:
- **SPRINT 2** (ID 2): *Bot de Telegram y Operaciones de Tareas* — CLOSED, Apr 1–15 2026
- **PROJECT_SPRINTS** — sprint 2 linked to project 1, `IS_ACTIVE='N'`
- **20 TASKS** (IDs 36–55) — all `COMPLETED / DONE`

**How to run:**
```sql
@template_data/sprints/sprint-2.sql
```

**Verify:**
```sql
SELECT COUNT(*) FROM TASKS WHERE SPRINT_ID = 2; -- 20
```

---

## Step 7 — Load Sprint 3 Data

**File:** `template_data/sprints/sprint-3.sql`

Inserts:
- **SPRINT 3** (ID 3): *KPIs, Feature de IA y Video Demo* — **ACTIVE**, Apr 15–29 2026
- **PROJECT_SPRINTS** — sprint 3 linked to project 1, `IS_ACTIVE='Y'`
- **29 TASKS** (IDs 56–84) — all `SPRINT / PENDING`

**How to run:**
```sql
@template_data/sprints/sprint-3.sql
```

**Verify:**
```sql
SELECT COUNT(*) FROM TASKS WHERE SPRINT_ID = 3; -- 29
SELECT COUNT(*) FROM TASKS;                     -- 84 total
```

---

## Step 8 — Load KPI Seed Data

**File:** `template_data/kpi_seed_data.sql`

Seeds the source tables that the remaining 9 triggers depend on.
Without this step, only `TAREAS_COMPLETADAS_SPRINT` and `CUMPLIMIENTO_SPRINT` have values.

The file is split into 5 sections that each fire different triggers:

### Section 1 — TASK_STATUS_HISTORY
Inserts one `IN_PROGRESS → DONE` transition for every completed task (sprints 1 & 2, 55 records total) plus 2 `REOPENED` entries.

| Trigger fired | KPI populated | Expected value |
|---------------|---------------|----------------|
| TRG_KPI_TRAZABILIDAD | TRAZABILIDAD_TAREAS | 0 for sprints 1 & 2 (all tasks have history), 29 for sprint 3 |
| TRG_KPI_REABIERTAS | TAREAS_REABIERTAS | 1 for sprint 1, 1 for sprint 2 |

### Section 2 — TASK UPDATE (sprint 3)
Touches `UPDATED_AT` on all 29 active sprint tasks via `UPDATE`.

| Trigger fired | KPI populated | Expected value |
|---------------|---------------|----------------|
| TRG_KPI_ACTUALIZACION_DIA | ACTUALIZACION_TAREAS_DIA | 100% (all 29 updated today) |

### Section 3 — DEPLOYMENTS
Inserts 8 deployment records across sprints 1–3 (mix of environments and statuses).

| Trigger fired | KPI populated | Expected value |
|---------------|---------------|----------------|
| TRG_KPI_DESPLIEGUES_PROD | DESPLIEGUES_PRODUCCION_SPRINT | 1 (1 PRODUCTION SUCCESS in sprint 3 window) |
| TRG_KPI_TASA_EXITO | TASA_EXITO_DESPLIEGUES | ~87.5% (7 SUCCESS / 8 total) |

### Section 4 — INCIDENTS
Inserts 5 incidents, then resolves 3 via `UPDATE OF RESOLVED_AT`.

| Trigger fired | KPI populated | Expected value |
|---------------|---------------|----------------|
| TRG_KPI_INCIDENTES_SEG | INCIDENTES_SEGURIDAD | 2 (2 SECURITY-type incidents) |
| TRG_KPI_MTTR | MTTR | avg minutes to resolve 3 incidents |
| TRG_KPI_DISPONIBILIDAD | DISPONIBILIDAD_SERVICIO | uptime % calculated from CRITICAL/HIGH incidents |

### Section 5 — BOT_INTERACTIONS
Inserts 8 bot interaction records with `CREATED_AT = SYSTIMESTAMP`.

| Trigger fired | KPI populated | Expected value |
|---------------|---------------|----------------|
| TRG_KPI_BOT | INTERACCIONES_BOT | 8 (interactions today) |

**How to run:**
```sql
@template_data/kpi_seed_data.sql
```

**Verify:**
```sql
SELECT kt.NAME, kv.SCOPE_TYPE, kv.VALUE, kv.RECORDED_AT
FROM KPI_VALUES kv
JOIN KPI_TYPES kt ON kt.KPI_TYPE_ID = kv.KPI_TYPE_ID
ORDER BY kt.NAME, kv.RECORDED_AT DESC;
-- All 11 KPI names should appear with at least one row
```

---

## Full Verification Query

Run this after all 8 steps to confirm the complete state of the database:

```sql
SELECT 'ROLES'                AS tbl, COUNT(*) AS cnt FROM ROLES
UNION ALL SELECT 'TEAMS',                COUNT(*) FROM TEAMS
UNION ALL SELECT 'USERS',                COUNT(*) FROM USERS
UNION ALL SELECT 'USER_CREDENTIALS',     COUNT(*) FROM USER_CREDENTIALS
UNION ALL SELECT 'PROJECTS',             COUNT(*) FROM PROJECTS
UNION ALL SELECT 'PROJECT_MEMBERS',      COUNT(*) FROM PROJECT_MEMBERS
UNION ALL SELECT 'SPRINTS',              COUNT(*) FROM SPRINTS
UNION ALL SELECT 'PROJECT_SPRINTS',      COUNT(*) FROM PROJECT_SPRINTS
UNION ALL SELECT 'TASKS',                COUNT(*) FROM TASKS
UNION ALL SELECT 'TASK_STATUS_HISTORY',  COUNT(*) FROM TASK_STATUS_HISTORY
UNION ALL SELECT 'DEPLOYMENTS',          COUNT(*) FROM DEPLOYMENTS
UNION ALL SELECT 'INCIDENTS',            COUNT(*) FROM INCIDENTS
UNION ALL SELECT 'BOT_INTERACTIONS',     COUNT(*) FROM BOT_INTERACTIONS
UNION ALL SELECT 'KPI_TYPES',            COUNT(*) FROM KPI_TYPES
UNION ALL SELECT 'KPI_VALUES',           COUNT(*) FROM KPI_VALUES
ORDER BY 1;
```

Expected counts:

| Table | Expected |
|-------|----------|
| ROLES | 2 |
| TEAMS | 2 |
| USERS | 6 |
| USER_CREDENTIALS | 6 |
| PROJECTS | 1 |
| PROJECT_MEMBERS | 6 |
| SPRINTS | 3 |
| PROJECT_SPRINTS | 3 |
| TASKS | 84 |
| TASK_STATUS_HISTORY | 57 |
| DEPLOYMENTS | 8 |
| INCIDENTS | 5 |
| BOT_INTERACTIONS | 8 |
| KPI_TYPES | 11 |
| KPI_VALUES | ≥ 11 (one per KPI minimum) |

---

## Tooling Notes

### SQLcl (recommended for scripted runs)
```bash
sql admin/password@your-atp-tns @db_schema.sql
sql admin/password@your-atp-tns @template_data/users.sql
sql admin/password@your-atp-tns @template_data/kpis.sql
sql admin/password@your-atp-tns @triggers.sql
sql admin/password@your-atp-tns @template_data/sprints/sprint-1.sql
sql admin/password@your-atp-tns @template_data/sprints/sprint-2.sql
sql admin/password@your-atp-tns @template_data/sprints/sprint-3.sql
sql admin/password@your-atp-tns @template_data/kpi_seed_data.sql
```

### SQL Developer
- Open each file via **File → Open**
- Use **Run Script (F5)** — not **Run Statement (Ctrl+Enter)** — so PL/SQL blocks with `/` terminators execute correctly.

### Database Actions (ATP SQL Worksheet)
- Paste file contents into the worksheet
- Click **Run Script** (the triangle-with-lines icon, not the plain triangle)
- Check the **Script Output** tab for errors after each file
