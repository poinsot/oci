
/* ============================================================
   KPI_TYPES
   ============================================================ */
INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('TAREAS_COMPLETADAS_SPRINT',     'DELIVERY',    'count',   'Tareas con STATUS=DONE por sprint');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('CUMPLIMIENTO_SPRINT',           'DELIVERY',    'percent', 'Tareas done / total tareas del sprint');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('TAREAS_REABIERTAS',             'QUALITY',     'count',   'Tareas que pasaron a REOPENED en el sprint');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('ACTUALIZACION_TAREAS_DIA',      'ACTIVITY',    'percent', 'Tareas actualizadas hoy / total activas');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('TRAZABILIDAD_TAREAS',           'QUALITY',     'count',   'Tareas sin ningún registro en TASK_STATUS_HISTORY');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('DESPLIEGUES_PRODUCCION_SPRINT', 'DEVOPS',      'count',   'Deploys a PRODUCTION exitosos por sprint');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('MTTR',                          'DEVOPS',      'minutes', 'Tiempo medio de recuperación de incidentes');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('TASA_EXITO_DESPLIEGUES',        'DEVOPS',      'percent', 'Despliegues SUCCESS / total despliegues');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('INTERACCIONES_BOT',             'ENGAGEMENT',  'count',   'Mensajes procesados por el bot por día');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('DISPONIBILIDAD_SERVICIO',       'RELIABILITY', 'percent', 'Uptime calculado desde incidentes CRITICAL/HIGH');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('INCIDENTES_SEGURIDAD',          'SECURITY',    'count',   'Incidentes con TYPE=SECURITY registrados');

COMMIT;
