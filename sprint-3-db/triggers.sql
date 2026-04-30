/* ============================================================
   KPI SYNC TRIGGERS — EQUIPO65
   ============================================================
   KPI → Source table → Trigger

   1.  TAREAS_COMPLETADAS_SPRINT     → TASKS                → TRG_KPI_TAREAS_COMPLETADAS
   2.  CUMPLIMIENTO_SPRINT           → TASKS                → TRG_KPI_CUMPLIMIENTO
   3.  TAREAS_REABIERTAS             → TASK_STATUS_HISTORY  → TRG_KPI_REABIERTAS
   4.  ACTUALIZACION_TAREAS_DIA      → TASKS                → TRG_KPI_ACTUALIZACION_DIA
   5.  TRAZABILIDAD_TAREAS           → TASK_STATUS_HISTORY  → TRG_KPI_TRAZABILIDAD
   6.  DESPLIEGUES_PRODUCCION_SPRINT → DEPLOYMENTS          → TRG_KPI_DESPLIEGUES_PROD
   7.  MTTR                          → INCIDENTS            → TRG_KPI_MTTR
   8.  TASA_EXITO_DESPLIEGUES        → DEPLOYMENTS          → TRG_KPI_TASA_EXITO
   9.  INTERACCIONES_BOT             → BOT_INTERACTIONS     → TRG_KPI_BOT
   10. DISPONIBILIDAD_SERVICIO       → INCIDENTS            → TRG_KPI_DISPONIBILIDAD
   11. INCIDENTES_SEGURIDAD          → INCIDENTS            → TRG_KPI_INCIDENTES_SEG

   All triggers are COMPOUND triggers to avoid ORA-04091 (mutating
   table). Affected keys are collected in AFTER EACH ROW with no
   table access; aggregate queries run in AFTER STATEMENT once the
   triggering table is stable.

   Helper procedure used by all triggers to upsert KPI_VALUES.
   ============================================================ */


/* ============================================================
   HELPER PROCEDURE: UPSERT_KPI
   ============================================================ */
CREATE OR REPLACE PROCEDURE UPSERT_KPI (
    p_kpi_name   IN VARCHAR2,
    p_scope      IN VARCHAR2,
    p_value      IN NUMBER,
    p_sprint_id  IN NUMBER DEFAULT NULL,
    p_project_id IN NUMBER DEFAULT NULL,
    p_user_id    IN NUMBER DEFAULT NULL
) AS
    v_type_id NUMBER;
    v_count   NUMBER;
BEGIN
    SELECT KPI_TYPE_ID INTO v_type_id
    FROM KPI_TYPES
    WHERE NAME = p_kpi_name;

    SELECT COUNT(*) INTO v_count
    FROM KPI_VALUES
    WHERE KPI_TYPE_ID = v_type_id
      AND SCOPE_TYPE  = p_scope
      AND NVL(SPRINT_ID,  -1) = NVL(p_sprint_id,  -1)
      AND NVL(PROJECT_ID, -1) = NVL(p_project_id, -1)
      AND NVL(USER_ID,    -1) = NVL(p_user_id,    -1)
      AND TRUNC(RECORDED_AT)  = TRUNC(SYSTIMESTAMP);

    IF v_count > 0 THEN
        UPDATE KPI_VALUES
        SET VALUE       = p_value,
            RECORDED_AT = SYSTIMESTAMP
        WHERE KPI_TYPE_ID = v_type_id
          AND SCOPE_TYPE  = p_scope
          AND NVL(SPRINT_ID,  -1) = NVL(p_sprint_id,  -1)
          AND NVL(PROJECT_ID, -1) = NVL(p_project_id, -1)
          AND NVL(USER_ID,    -1) = NVL(p_user_id,    -1)
          AND TRUNC(RECORDED_AT)  = TRUNC(SYSTIMESTAMP);
    ELSE
        INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, SPRINT_ID, PROJECT_ID, USER_ID, VALUE, RECORDED_AT)
        VALUES (v_type_id, p_scope, p_sprint_id, p_project_id, p_user_id, p_value, SYSTIMESTAMP);
    END IF;
END UPSERT_KPI;
/


/* ============================================================
   TRIGGER 1 — TAREAS_COMPLETADAS_SPRINT
   Fires: after INSERT or UPDATE on TASKS
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_TAREAS_COMPLETADAS
FOR INSERT OR UPDATE OF STATUS, IS_DELETED ON TASKS
COMPOUND TRIGGER

    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_sprints t_id_set;

AFTER EACH ROW IS
    v_sid VARCHAR2(20);
BEGIN
    v_sid := TO_CHAR(NVL(:NEW.SPRINT_ID, :OLD.SPRINT_ID));
    IF v_sid IS NOT NULL THEN
        v_sprints(v_sid) := TO_NUMBER(v_sid);
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_sid        VARCHAR2(20);
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_count      NUMBER;
BEGIN
    v_sid := v_sprints.FIRST;
    WHILE v_sid IS NOT NULL LOOP
        v_sprint_id := v_sprints(v_sid);

        SELECT COUNT(*), MAX(PROJECT_ID)
        INTO v_count, v_project_id
        FROM TASKS
        WHERE SPRINT_ID            = v_sprint_id
          AND STATUS               = 'DONE'
          AND NVL(IS_DELETED, 'N') = 'N';

        UPSERT_KPI('TAREAS_COMPLETADAS_SPRINT', 'SPRINT', v_count, v_sprint_id, v_project_id);
        v_sid := v_sprints.NEXT(v_sid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_TAREAS_COMPLETADAS;
/


/* ============================================================
   TRIGGER 2 — CUMPLIMIENTO_SPRINT
   Fires: after INSERT or UPDATE on TASKS
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_CUMPLIMIENTO
FOR INSERT OR UPDATE OF STATUS, IS_DELETED ON TASKS
COMPOUND TRIGGER

    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_sprints t_id_set;

AFTER EACH ROW IS
    v_sid VARCHAR2(20);
BEGIN
    v_sid := TO_CHAR(NVL(:NEW.SPRINT_ID, :OLD.SPRINT_ID));
    IF v_sid IS NOT NULL THEN
        v_sprints(v_sid) := TO_NUMBER(v_sid);
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_sid        VARCHAR2(20);
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_done       NUMBER;
    v_total      NUMBER;
    v_pct        NUMBER;
BEGIN
    v_sid := v_sprints.FIRST;
    WHILE v_sid IS NOT NULL LOOP
        v_sprint_id := v_sprints(v_sid);

        SELECT COUNT(*),
               SUM(CASE WHEN STATUS = 'DONE' THEN 1 ELSE 0 END),
               MAX(PROJECT_ID)
        INTO v_total, v_done, v_project_id
        FROM TASKS
        WHERE SPRINT_ID            = v_sprint_id
          AND NVL(IS_DELETED, 'N') = 'N';

        v_pct := CASE WHEN v_total > 0 THEN ROUND((v_done / v_total) * 100, 2) ELSE 0 END;
        UPSERT_KPI('CUMPLIMIENTO_SPRINT', 'SPRINT', v_pct, v_sprint_id, v_project_id);
        v_sid := v_sprints.NEXT(v_sid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_CUMPLIMIENTO;
/


/* ============================================================
   TRIGGER 3 — TAREAS_REABIERTAS
   Fires: after INSERT on TASK_STATUS_HISTORY
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_REABIERTAS
FOR INSERT ON TASK_STATUS_HISTORY
COMPOUND TRIGGER

    -- Keyed by sprint_id (as string) — only populated for REOPENED rows
    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_sprints  t_id_set;
    v_projects t_id_set;

AFTER EACH ROW IS
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_sid        VARCHAR2(20);
BEGIN
    IF :NEW.NEW_STATUS = 'REOPENED' THEN
        -- TASKS is not mutating here (different table), safe to query
        BEGIN
            SELECT t.SPRINT_ID, t.PROJECT_ID
            INTO v_sprint_id, v_project_id
            FROM TASKS t
            WHERE t.TASK_ID = :NEW.TASK_ID;

            IF v_sprint_id IS NOT NULL THEN
                v_sid := TO_CHAR(v_sprint_id);
                v_sprints(v_sid)  := v_sprint_id;
                v_projects(v_sid) := v_project_id;
            END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_sid   VARCHAR2(20);
    v_count NUMBER;
BEGIN
    v_sid := v_sprints.FIRST;
    WHILE v_sid IS NOT NULL LOOP
        SELECT COUNT(*)
        INTO v_count
        FROM TASK_STATUS_HISTORY tsh
        JOIN TASKS t ON t.TASK_ID = tsh.TASK_ID
        WHERE tsh.NEW_STATUS = 'REOPENED'
          AND t.SPRINT_ID    = v_sprints(v_sid);

        UPSERT_KPI('TAREAS_REABIERTAS', 'SPRINT', v_count, v_sprints(v_sid), v_projects(v_sid));
        v_sid := v_sprints.NEXT(v_sid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_REABIERTAS;
/


/* ============================================================
   TRIGGER 4 — ACTUALIZACION_TAREAS_DIA
   Fires: after UPDATE on TASKS
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_ACTUALIZACION_DIA
FOR UPDATE OF STATUS, IS_DELETED, UPDATED_AT ON TASKS
COMPOUND TRIGGER

    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_sprints t_id_set;

AFTER EACH ROW IS
    v_sid VARCHAR2(20);
BEGIN
    v_sid := TO_CHAR(NVL(:NEW.SPRINT_ID, :OLD.SPRINT_ID));
    IF v_sid IS NOT NULL THEN
        v_sprints(v_sid) := TO_NUMBER(v_sid);
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_sid        VARCHAR2(20);
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_updated    NUMBER;
    v_total      NUMBER;
    v_pct        NUMBER;
BEGIN
    v_sid := v_sprints.FIRST;
    WHILE v_sid IS NOT NULL LOOP
        v_sprint_id := v_sprints(v_sid);

        SELECT COUNT(*),
               SUM(CASE WHEN TRUNC(UPDATED_AT) = TRUNC(SYSTIMESTAMP) THEN 1 ELSE 0 END),
               MAX(PROJECT_ID)
        INTO v_total, v_updated, v_project_id
        FROM TASKS
        WHERE SPRINT_ID            = v_sprint_id
          AND STATUS              != 'DONE'
          AND NVL(IS_DELETED, 'N') = 'N';

        v_pct := CASE WHEN v_total > 0 THEN ROUND((v_updated / v_total) * 100, 2) ELSE 0 END;
        UPSERT_KPI('ACTUALIZACION_TAREAS_DIA', 'SPRINT', v_pct, v_sprint_id, v_project_id);
        v_sid := v_sprints.NEXT(v_sid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_ACTUALIZACION_DIA;
/


/* ============================================================
   TRIGGER 5 — TRAZABILIDAD_TAREAS
   Fires: after INSERT on TASK_STATUS_HISTORY
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_TRAZABILIDAD
FOR INSERT ON TASK_STATUS_HISTORY
COMPOUND TRIGGER

    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_sprints  t_id_set;
    v_projects t_id_set;

AFTER EACH ROW IS
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_sid        VARCHAR2(20);
BEGIN
    -- TASKS is not mutating here, safe to query
    SELECT t.SPRINT_ID, t.PROJECT_ID
    INTO v_sprint_id, v_project_id
    FROM TASKS t
    WHERE t.TASK_ID = :NEW.TASK_ID;

    IF v_sprint_id IS NOT NULL THEN
        v_sid := TO_CHAR(v_sprint_id);
        v_sprints(v_sid)  := v_sprint_id;
        v_projects(v_sid) := v_project_id;
    END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_sid   VARCHAR2(20);
    v_count NUMBER;
BEGIN
    v_sid := v_sprints.FIRST;
    WHILE v_sid IS NOT NULL LOOP
        SELECT COUNT(*)
        INTO v_count
        FROM TASKS t
        WHERE t.SPRINT_ID           = v_sprints(v_sid)
          AND NVL(t.IS_DELETED,'N') = 'N'
          AND NOT EXISTS (
              SELECT 1 FROM TASK_STATUS_HISTORY tsh
              WHERE tsh.TASK_ID = t.TASK_ID
          );

        UPSERT_KPI('TRAZABILIDAD_TAREAS', 'SPRINT', v_count, v_sprints(v_sid), v_projects(v_sid));
        v_sid := v_sprints.NEXT(v_sid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_TRAZABILIDAD;
/


/* ============================================================
   TRIGGER 6 — DESPLIEGUES_PRODUCCION_SPRINT
   Fires: after INSERT or UPDATE on DEPLOYMENTS
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_DESPLIEGUES_PROD
FOR INSERT OR UPDATE OF STATUS, ENVIRONMENT ON DEPLOYMENTS
COMPOUND TRIGGER

    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_projects t_id_set;

AFTER EACH ROW IS
    v_pid VARCHAR2(20);
BEGIN
    v_pid := TO_CHAR(NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID));
    IF v_pid IS NOT NULL THEN
        v_projects(v_pid) := TO_NUMBER(v_pid);
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_pid        VARCHAR2(20);
    v_project_id NUMBER;
    v_sprint_id  NUMBER;
    v_count      NUMBER;
BEGIN
    v_pid := v_projects.FIRST;
    WHILE v_pid IS NOT NULL LOOP
        v_project_id := v_projects(v_pid);

        BEGIN
            SELECT ps.SPRINT_ID INTO v_sprint_id
            FROM PROJECT_SPRINTS ps
            WHERE ps.PROJECT_ID = v_project_id
              AND ps.IS_ACTIVE  = 'Y'
              AND ROWNUM        = 1;

            SELECT COUNT(*) INTO v_count
            FROM DEPLOYMENTS
            WHERE PROJECT_ID  = v_project_id
              AND ENVIRONMENT = 'PRODUCTION'
              AND STATUS      = 'SUCCESS'
              AND DEPLOYED_AT >= (SELECT START_DATE FROM SPRINTS WHERE SPRINT_ID = v_sprint_id)
              AND DEPLOYED_AT <= (SELECT END_DATE   FROM SPRINTS WHERE SPRINT_ID = v_sprint_id);

            UPSERT_KPI('DESPLIEGUES_PRODUCCION_SPRINT', 'SPRINT', v_count, v_sprint_id, v_project_id);
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        v_pid := v_projects.NEXT(v_pid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_DESPLIEGUES_PROD;
/


/* ============================================================
   TRIGGER 7 — MTTR
   Fires: after UPDATE of RESOLVED_AT or IS_DELETED on INCIDENTS
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_MTTR
FOR UPDATE OF RESOLVED_AT, IS_DELETED ON INCIDENTS
COMPOUND TRIGGER

    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_projects t_id_set;

AFTER EACH ROW IS
    v_pid VARCHAR2(20);
BEGIN
    IF :NEW.RESOLVED_AT IS NOT NULL THEN
        v_pid := TO_CHAR(NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID));
        IF v_pid IS NOT NULL THEN
            v_projects(v_pid) := TO_NUMBER(v_pid);
        END IF;
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_pid        VARCHAR2(20);
    v_project_id NUMBER;
    v_mttr       NUMBER;
BEGIN
    v_pid := v_projects.FIRST;
    WHILE v_pid IS NOT NULL LOOP
        v_project_id := v_projects(v_pid);

        SELECT ROUND(AVG(
                   (CAST(RESOLVED_AT AS DATE) - CAST(OCCURRED_AT AS DATE)) * 1440
               ), 2)
        INTO v_mttr
        FROM INCIDENTS
        WHERE PROJECT_ID            = v_project_id
          AND RESOLVED_AT           IS NOT NULL
          AND NVL(IS_DELETED, 'N') = 'N';

        UPSERT_KPI('MTTR', 'PROJECT', NVL(v_mttr, 0), NULL, v_project_id);
        v_pid := v_projects.NEXT(v_pid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_MTTR;
/


/* ============================================================
   TRIGGER 8 — TASA_EXITO_DESPLIEGUES
   Fires: after INSERT or UPDATE on DEPLOYMENTS
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_TASA_EXITO
FOR INSERT OR UPDATE OF STATUS ON DEPLOYMENTS
COMPOUND TRIGGER

    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_projects t_id_set;

AFTER EACH ROW IS
    v_pid VARCHAR2(20);
BEGIN
    v_pid := TO_CHAR(NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID));
    IF v_pid IS NOT NULL THEN
        v_projects(v_pid) := TO_NUMBER(v_pid);
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_pid        VARCHAR2(20);
    v_project_id NUMBER;
    v_success    NUMBER;
    v_total      NUMBER;
    v_pct        NUMBER;
BEGIN
    v_pid := v_projects.FIRST;
    WHILE v_pid IS NOT NULL LOOP
        v_project_id := v_projects(v_pid);

        SELECT COUNT(*),
               SUM(CASE WHEN STATUS = 'SUCCESS' THEN 1 ELSE 0 END)
        INTO v_total, v_success
        FROM DEPLOYMENTS
        WHERE PROJECT_ID = v_project_id;

        v_pct := CASE WHEN v_total > 0 THEN ROUND((v_success / v_total) * 100, 2) ELSE 0 END;
        UPSERT_KPI('TASA_EXITO_DESPLIEGUES', 'PROJECT', v_pct, NULL, v_project_id);
        v_pid := v_projects.NEXT(v_pid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_TASA_EXITO;
/


/* ============================================================
   TRIGGER 9 — INTERACCIONES_BOT
   Fires: after INSERT on BOT_INTERACTIONS
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_BOT
FOR INSERT ON BOT_INTERACTIONS
COMPOUND TRIGGER

    v_fired BOOLEAN := FALSE;

AFTER EACH ROW IS
BEGIN
    v_fired := TRUE;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_count NUMBER;
BEGIN
    IF v_fired THEN
        SELECT COUNT(*) INTO v_count
        FROM BOT_INTERACTIONS
        WHERE TRUNC(CREATED_AT) = TRUNC(SYSTIMESTAMP);

        UPSERT_KPI('INTERACCIONES_BOT', 'GLOBAL', v_count);
    END IF;
END AFTER STATEMENT;

END TRG_KPI_BOT;
/


/* ============================================================
   TRIGGER 10 — DISPONIBILIDAD_SERVICIO
   Fires: after INSERT or UPDATE of RESOLVED_AT, IS_DELETED on INCIDENTS
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_DISPONIBILIDAD
FOR INSERT OR UPDATE OF RESOLVED_AT, IS_DELETED ON INCIDENTS
COMPOUND TRIGGER

    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_projects t_id_set;

AFTER EACH ROW IS
    v_pid VARCHAR2(20);
BEGIN
    v_pid := TO_CHAR(NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID));
    IF v_pid IS NOT NULL THEN
        v_projects(v_pid) := TO_NUMBER(v_pid);
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_pid          VARCHAR2(20);
    v_project_id   NUMBER;
    v_start        TIMESTAMP;
    v_downtime_min NUMBER;
    v_period_min   NUMBER;
    v_uptime_pct   NUMBER;
BEGIN
    v_pid := v_projects.FIRST;
    WHILE v_pid IS NOT NULL LOOP
        v_project_id := v_projects(v_pid);

        SELECT MIN(OCCURRED_AT) INTO v_start
        FROM INCIDENTS WHERE PROJECT_ID = v_project_id;

        v_period_min := (CAST(SYSTIMESTAMP AS DATE) - CAST(v_start AS DATE)) * 1440;

        SELECT NVL(SUM(
                   (CAST(RESOLVED_AT AS DATE) - CAST(OCCURRED_AT AS DATE)) * 1440
               ), 0)
        INTO v_downtime_min
        FROM INCIDENTS
        WHERE PROJECT_ID            = v_project_id
          AND SEVERITY              IN ('CRITICAL','HIGH')
          AND RESOLVED_AT           IS NOT NULL
          AND NVL(IS_DELETED,'N')  = 'N';

        v_uptime_pct := CASE
            WHEN v_period_min > 0
            THEN ROUND(((v_period_min - v_downtime_min) / v_period_min) * 100, 4)
            ELSE 100
        END;

        UPSERT_KPI('DISPONIBILIDAD_SERVICIO', 'PROJECT', v_uptime_pct, NULL, v_project_id);
        v_pid := v_projects.NEXT(v_pid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_DISPONIBILIDAD;
/


/* ============================================================
   TRIGGER 11 — INCIDENTES_SEGURIDAD
   Fires: after INSERT or UPDATE of IS_DELETED on INCIDENTS
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_INCIDENTES_SEG
FOR INSERT OR UPDATE OF IS_DELETED ON INCIDENTS
COMPOUND TRIGGER

    TYPE t_id_set IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    v_projects t_id_set;

AFTER EACH ROW IS
    v_pid VARCHAR2(20);
BEGIN
    IF (INSERTING AND :NEW.TYPE = 'SECURITY') OR
       (UPDATING  AND NVL(:OLD.TYPE, :NEW.TYPE) = 'SECURITY') THEN
        v_pid := TO_CHAR(NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID));
        IF v_pid IS NOT NULL THEN
            v_projects(v_pid) := TO_NUMBER(v_pid);
        END IF;
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_pid        VARCHAR2(20);
    v_project_id NUMBER;
    v_count      NUMBER;
BEGIN
    v_pid := v_projects.FIRST;
    WHILE v_pid IS NOT NULL LOOP
        v_project_id := v_projects(v_pid);

        SELECT COUNT(*) INTO v_count
        FROM INCIDENTS
        WHERE PROJECT_ID           = v_project_id
          AND TYPE                 = 'SECURITY'
          AND NVL(IS_DELETED,'N') = 'N';

        UPSERT_KPI('INCIDENTES_SEGURIDAD', 'PROJECT', v_count, NULL, v_project_id);
        v_pid := v_projects.NEXT(v_pid);
    END LOOP;
END AFTER STATEMENT;

END TRG_KPI_INCIDENTES_SEG;
/
