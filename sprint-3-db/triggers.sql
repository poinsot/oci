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
   11. USO_CPU                       → KPI_VALUES (manual)  → (no trigger — fed by agent)
   12. USO_MEMORIA                   → KPI_VALUES (manual)  → (no trigger — fed by agent)
   13. INCIDENTES_SEGURIDAD          → INCIDENTS            → TRG_KPI_INCIDENTES_SEG

   Helper procedure used by all triggers to upsert KPI_VALUES.
   ============================================================ */


/* ============================================================
   HELPER PROCEDURE: UPSERT_KPI
   Inserts a new KPI_VALUES row or updates it if one already
   exists for the same (KPI_TYPE_ID, SCOPE_TYPE, SPRINT_ID,
   PROJECT_ID, USER_ID) combination recorded today.
   ============================================================ */
CREATE OR REPLACE PROCEDURE UPSERT_KPI (
    p_kpi_name   IN VARCHAR2,
    p_scope      IN VARCHAR2,   -- 'SPRINT' | 'PROJECT' | 'GLOBAL'
    p_value      IN NUMBER,
    p_sprint_id  IN NUMBER DEFAULT NULL,
    p_project_id IN NUMBER DEFAULT NULL,
    p_user_id    IN NUMBER DEFAULT NULL
) AS
    v_type_id   NUMBER;
    v_count     NUMBER;
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
   Recalculates count of DONE tasks per sprint
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_TAREAS_COMPLETADAS
AFTER INSERT OR UPDATE OF STATUS, IS_DELETED ON TASKS
FOR EACH ROW
DECLARE
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_count      NUMBER;
BEGIN
    v_sprint_id  := NVL(:NEW.SPRINT_ID,  :OLD.SPRINT_ID);
    v_project_id := NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID);

    IF v_sprint_id IS NULL THEN RETURN; END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM TASKS
    WHERE SPRINT_ID  = v_sprint_id
      AND STATUS     = 'DONE'
      AND NVL(IS_DELETED, 'N') = 'N';

    UPSERT_KPI('TAREAS_COMPLETADAS_SPRINT', 'SPRINT', v_count, v_sprint_id, v_project_id);
END;
/


/* ============================================================
   TRIGGER 2 — CUMPLIMIENTO_SPRINT
   Fires: after INSERT or UPDATE on TASKS
   Recalculates done/total percentage per sprint
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_CUMPLIMIENTO
AFTER INSERT OR UPDATE OF STATUS, IS_DELETED ON TASKS
FOR EACH ROW
DECLARE
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_done       NUMBER;
    v_total      NUMBER;
    v_pct        NUMBER;
BEGIN
    v_sprint_id  := NVL(:NEW.SPRINT_ID,  :OLD.SPRINT_ID);
    v_project_id := NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID);

    IF v_sprint_id IS NULL THEN RETURN; END IF;

    SELECT COUNT(*),
           SUM(CASE WHEN STATUS = 'DONE' THEN 1 ELSE 0 END)
    INTO v_total, v_done
    FROM TASKS
    WHERE SPRINT_ID          = v_sprint_id
      AND NVL(IS_DELETED,'N') = 'N';

    v_pct := CASE WHEN v_total > 0 THEN ROUND((v_done / v_total) * 100, 2) ELSE 0 END;

    UPSERT_KPI('CUMPLIMIENTO_SPRINT', 'SPRINT', v_pct, v_sprint_id, v_project_id);
END;
/


/* ============================================================
   TRIGGER 3 — TAREAS_REABIERTAS
   Fires: after INSERT on TASK_STATUS_HISTORY
   Counts transitions TO 'REOPENED' within the task's sprint
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_REABIERTAS
AFTER INSERT ON TASK_STATUS_HISTORY
FOR EACH ROW
DECLARE
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_count      NUMBER;
BEGIN
    IF :NEW.NEW_STATUS != 'REOPENED' THEN RETURN; END IF;

    SELECT t.SPRINT_ID, t.PROJECT_ID
    INTO v_sprint_id, v_project_id
    FROM TASKS t
    WHERE t.TASK_ID = :NEW.TASK_ID;

    IF v_sprint_id IS NULL THEN RETURN; END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM TASK_STATUS_HISTORY tsh
    JOIN TASKS t ON t.TASK_ID = tsh.TASK_ID
    WHERE tsh.NEW_STATUS = 'REOPENED'
      AND t.SPRINT_ID    = v_sprint_id;

    UPSERT_KPI('TAREAS_REABIERTAS', 'SPRINT', v_count, v_sprint_id, v_project_id);
END;
/


/* ============================================================
   TRIGGER 4 — ACTUALIZACION_TAREAS_DIA
   Fires: after UPDATE on TASKS
   Percent of active tasks touched today vs total active tasks
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_ACTUALIZACION_DIA
AFTER UPDATE OF STATUS, IS_DELETED, UPDATED_AT ON TASKS
FOR EACH ROW
DECLARE
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_updated    NUMBER;
    v_total      NUMBER;
    v_pct        NUMBER;
BEGIN
    v_sprint_id  := NVL(:NEW.SPRINT_ID,  :OLD.SPRINT_ID);
    v_project_id := NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID);

    IF v_sprint_id IS NULL THEN RETURN; END IF;

    -- If the task was just soft-deleted, exclude it from totals (already handled by IS_DELETED filter below)
    SELECT COUNT(*),
           SUM(CASE WHEN TRUNC(UPDATED_AT) = TRUNC(SYSTIMESTAMP) THEN 1 ELSE 0 END)
    INTO v_total, v_updated
    FROM TASKS
    WHERE SPRINT_ID           = v_sprint_id
      AND STATUS             != 'DONE'
      AND NVL(IS_DELETED,'N') = 'N';

    v_pct := CASE WHEN v_total > 0 THEN ROUND((v_updated / v_total) * 100, 2) ELSE 0 END;

    UPSERT_KPI('ACTUALIZACION_TAREAS_DIA', 'SPRINT', v_pct, v_sprint_id, v_project_id);
END;
/


/* ============================================================
   TRIGGER 5 — TRAZABILIDAD_TAREAS
   Fires: after INSERT on TASK_STATUS_HISTORY
   Counts tasks in the sprint that still have NO history entry
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_TRAZABILIDAD
AFTER INSERT ON TASK_STATUS_HISTORY
FOR EACH ROW
DECLARE
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_count      NUMBER;
BEGIN
    SELECT t.SPRINT_ID, t.PROJECT_ID
    INTO v_sprint_id, v_project_id
    FROM TASKS t
    WHERE t.TASK_ID = :NEW.TASK_ID;

    IF v_sprint_id IS NULL THEN RETURN; END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM TASKS t
    WHERE t.SPRINT_ID           = v_sprint_id
      AND NVL(t.IS_DELETED,'N') = 'N'
      AND NOT EXISTS (
          SELECT 1 FROM TASK_STATUS_HISTORY tsh
          WHERE tsh.TASK_ID = t.TASK_ID
      );

    UPSERT_KPI('TRAZABILIDAD_TAREAS', 'SPRINT', v_count, v_sprint_id, v_project_id);
END;
/


/* ============================================================
   TRIGGER 6 — DESPLIEGUES_PRODUCCION_SPRINT
   Fires: after INSERT or UPDATE on DEPLOYMENTS
   Counts SUCCESS deploys to PRODUCTION linked to active sprint
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_DESPLIEGUES_PROD
AFTER INSERT OR UPDATE OF STATUS, ENVIRONMENT ON DEPLOYMENTS
FOR EACH ROW
DECLARE
    v_sprint_id  NUMBER;
    v_project_id NUMBER;
    v_count      NUMBER;
BEGIN
    v_project_id := NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID);

    IF v_project_id IS NULL THEN RETURN; END IF;

    -- Resolve the currently active sprint for this project
    SELECT ps.SPRINT_ID
    INTO v_sprint_id
    FROM PROJECT_SPRINTS ps
    WHERE ps.PROJECT_ID = v_project_id
      AND ps.IS_ACTIVE  = 'Y'
      AND ROWNUM        = 1;

    SELECT COUNT(*)
    INTO v_count
    FROM DEPLOYMENTS
    WHERE PROJECT_ID  = v_project_id
      AND ENVIRONMENT = 'PRODUCTION'
      AND STATUS      = 'SUCCESS'
      AND DEPLOYED_AT >= (SELECT START_DATE FROM SPRINTS WHERE SPRINT_ID = v_sprint_id)
      AND DEPLOYED_AT <= (SELECT END_DATE   FROM SPRINTS WHERE SPRINT_ID = v_sprint_id);

    UPSERT_KPI('DESPLIEGUES_PRODUCCION_SPRINT', 'SPRINT', v_count, v_sprint_id, v_project_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL; -- no active sprint, skip
END;
/


/* ============================================================
   TRIGGER 7 — MTTR
   Fires: after UPDATE of RESOLVED_AT or IS_DELETED on INCIDENTS
   Mean time to recovery in minutes across resolved incidents
   IS_DELETED considered: soft-deleted incidents are excluded
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_MTTR
AFTER UPDATE OF RESOLVED_AT, IS_DELETED ON INCIDENTS
FOR EACH ROW
DECLARE
    v_mttr       NUMBER;
    v_project_id NUMBER;
BEGIN
    IF :NEW.RESOLVED_AT IS NULL THEN RETURN; END IF;

    v_project_id := NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID);

    SELECT ROUND(AVG(
               (CAST(RESOLVED_AT AS DATE) - CAST(OCCURRED_AT AS DATE)) * 1440
           ), 2)
    INTO v_mttr
    FROM INCIDENTS
    WHERE PROJECT_ID              = v_project_id
      AND RESOLVED_AT             IS NOT NULL
      AND NVL(IS_DELETED, 'N')   = 'N';

    UPSERT_KPI('MTTR', 'PROJECT', NVL(v_mttr, 0), NULL, v_project_id);
END;
/


/* ============================================================
   TRIGGER 8 — TASA_EXITO_DESPLIEGUES
   Fires: after INSERT or UPDATE on DEPLOYMENTS
   SUCCESS deploys / total deploys per project (percent)
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_TASA_EXITO
AFTER INSERT OR UPDATE OF STATUS ON DEPLOYMENTS
FOR EACH ROW
DECLARE
    v_project_id NUMBER;
    v_success    NUMBER;
    v_total      NUMBER;
    v_pct        NUMBER;
BEGIN
    v_project_id := NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID);

    IF v_project_id IS NULL THEN RETURN; END IF;

    SELECT COUNT(*),
           SUM(CASE WHEN STATUS = 'SUCCESS' THEN 1 ELSE 0 END)
    INTO v_total, v_success
    FROM DEPLOYMENTS
    WHERE PROJECT_ID = v_project_id;

    v_pct := CASE WHEN v_total > 0 THEN ROUND((v_success / v_total) * 100, 2) ELSE 0 END;

    UPSERT_KPI('TASA_EXITO_DESPLIEGUES', 'PROJECT', v_pct, NULL, v_project_id);
END;
/


/* ============================================================
   TRIGGER 9 — INTERACCIONES_BOT
   Fires: after INSERT on BOT_INTERACTIONS
   Count of bot messages processed today (global scope)
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_BOT
AFTER INSERT ON BOT_INTERACTIONS
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM BOT_INTERACTIONS
    WHERE TRUNC(CREATED_AT) = TRUNC(SYSTIMESTAMP);

    UPSERT_KPI('INTERACCIONES_BOT', 'GLOBAL', v_count);
END;
/


/* ============================================================
   TRIGGER 10 — DISPONIBILIDAD_SERVICIO
   Fires: after INSERT or UPDATE of RESOLVED_AT, IS_DELETED on INCIDENTS
   Uptime % = 100 - (total downtime minutes / total minutes in period * 100)
   Uses CRITICAL and HIGH incidents with a RESOLVED_AT
   IS_DELETED considered: soft-deleted incidents excluded from downtime
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_DISPONIBILIDAD
AFTER INSERT OR UPDATE OF RESOLVED_AT, IS_DELETED ON INCIDENTS
FOR EACH ROW
DECLARE
    v_project_id    NUMBER;
    v_downtime_min  NUMBER;
    v_period_min    NUMBER;
    v_uptime_pct    NUMBER;
    v_start         TIMESTAMP;
BEGIN
    v_project_id := NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID);

    IF v_project_id IS NULL THEN RETURN; END IF;

    -- Period start = first incident ever for this project
    SELECT MIN(OCCURRED_AT) INTO v_start
    FROM INCIDENTS
    WHERE PROJECT_ID = v_project_id;

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
END;
/


/* ============================================================
   TRIGGER 13 — INCIDENTES_SEGURIDAD
   Fires: after INSERT or UPDATE of IS_DELETED on INCIDENTS
   Count of TYPE='SECURITY' non-deleted incidents per project
   IS_DELETED considered: soft-deleting a security incident decrements the count
   ============================================================ */
CREATE OR REPLACE TRIGGER TRG_KPI_INCIDENTES_SEG
AFTER INSERT OR UPDATE OF IS_DELETED ON INCIDENTS
FOR EACH ROW
DECLARE
    v_project_id NUMBER;
    v_count      NUMBER;
BEGIN
    -- On INSERT only react to SECURITY type
    -- On UPDATE of IS_DELETED react regardless of type (to decrement if needed)
    IF INSERTING AND :NEW.TYPE != 'SECURITY' THEN RETURN; END IF;
    IF UPDATING AND NVL(:OLD.TYPE, :NEW.TYPE) != 'SECURITY' THEN RETURN; END IF;

    v_project_id := NVL(:NEW.PROJECT_ID, :OLD.PROJECT_ID);

    IF v_project_id IS NULL THEN RETURN; END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM INCIDENTS
    WHERE PROJECT_ID           = v_project_id
      AND TYPE                 = 'SECURITY'
      AND NVL(IS_DELETED,'N') = 'N';

    UPSERT_KPI('INCIDENTES_SEGURIDAD', 'PROJECT', v_count, NULL, v_project_id);
END;
/

/* ============================================================
   NOTE: KPIs 11 (USO_CPU) and 12 (USO_MEMORIA) are excluded.
   These are fed by an external infrastructure monitoring agent
   and cannot be derived from any table in the schema.
   They should be inserted directly into KPI_VALUES by the agent.
   ============================================================ */