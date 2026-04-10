/* ============================================================
   ORACLE JAVA BOT - FAKE DATA (ACTUALIZADO)
   ============================================================ */

/* ============================================================
   1. ROLES
   ============================================================ */
INSERT INTO ROLES (ROLE_NAME, DESCRIPTION)
VALUES ('MANAGER',   'Gestor de proyectos y sprints');

INSERT INTO ROLES (ROLE_NAME, DESCRIPTION)
VALUES ('DEVELOPER', 'Desarrollador asignado a tareas');

/* ============================================================
   2. TEAMS
   ============================================================ */
INSERT INTO TEAMS (NAME, DESCRIPTION)
VALUES ('Backend Team',  'Equipo de desarrollo de servicios y APIs');

INSERT INTO TEAMS (NAME, DESCRIPTION)
VALUES ('Frontend Team', 'Equipo de desarrollo de interfaces');

/* ============================================================
   3. USERS
   Usuario IDs:
     1 - Inigo Gonzalez    (A01723229) - MANAGER
     2 - Victor Martinez   (A01723093) - DEVELOPER
     3 - Paolo Gaya        (A01722922) - DEVELOPER
     4 - Miguel Angel Alvarez (A01722925) - DEVELOPER
     5 - Jinhyuk Park      (A01286288) - DEVELOPER
     6 - Luis Garza Gomez  (A00839388) - MANAGER
   ============================================================ */
INSERT INTO USERS (FULL_NAME, EMAIL, TELEGRAM_ID, ROLE_ID, TEAM_ID, STATUS)
VALUES ('Inigo Gonzalez', 'a01723229@tec.mx', '@inigogonzalez', 1, 1, 'ACTIVE');

INSERT INTO USERS (FULL_NAME, EMAIL, TELEGRAM_ID, ROLE_ID, TEAM_ID, STATUS)
VALUES ('Victor Martinez', 'a01723093@tec.mx', '@victormartinez', 2, 1, 'ACTIVE');

INSERT INTO USERS (FULL_NAME, EMAIL, TELEGRAM_ID, ROLE_ID, TEAM_ID, STATUS)
VALUES ('Paolo Gaya', 'a01722922@tec.mx', '@paologaya', 2, 2, 'ACTIVE');

INSERT INTO USERS (FULL_NAME, EMAIL, TELEGRAM_ID, ROLE_ID, TEAM_ID, STATUS)
VALUES ('Miguel Angel Alvarez', 'a01722925@tec.mx', '@miguelangelalvarez', 2, 1, 'ACTIVE');

INSERT INTO USERS (FULL_NAME, EMAIL, TELEGRAM_ID, ROLE_ID, TEAM_ID, STATUS)
VALUES ('Jinhyuk Park', 'a01286288@tec.mx', '@jinhyukpark', 2, 2, 'ACTIVE');

INSERT INTO USERS (FULL_NAME, EMAIL, TELEGRAM_ID, ROLE_ID, TEAM_ID, STATUS)
VALUES ('Luis Garza Gomez', 'a00839388@tec.mx', '@luisgarzagomez', 1, 1, 'ACTIVE');

/* ============================================================
   4. USER_CREDENTIALS
   ============================================================ */
INSERT INTO USER_CREDENTIALS (USER_ID, USERNAME, PASSWORD_HASH, PASSWORD_SALT, FAILED_ATTEMPTS, ACCOUNT_LOCKED)
VALUES (1, 'inigo.gonzalez',
        'b3a8e0e1f9ab1827e1f18c4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4',
        'SALT_B2C3D4E5F6A1', 0, 'N');

INSERT INTO USER_CREDENTIALS (USER_ID, USERNAME, PASSWORD_HASH, PASSWORD_SALT, FAILED_ATTEMPTS, ACCOUNT_LOCKED)
VALUES (2, 'victor.martinez',
        'c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5',
        'SALT_C3D4E5F6A1B2', 0, 'N');

INSERT INTO USER_CREDENTIALS (USER_ID, USERNAME, PASSWORD_HASH, PASSWORD_SALT, FAILED_ATTEMPTS, ACCOUNT_LOCKED)
VALUES (3, 'paolo.gaya',
        'd5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6',
        'SALT_D4E5F6A1B2C3', 0, 'N');

INSERT INTO USER_CREDENTIALS (USER_ID, USERNAME, PASSWORD_HASH, PASSWORD_SALT, FAILED_ATTEMPTS, ACCOUNT_LOCKED)
VALUES (4, 'miguel.alvarez',
        'f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8',
        'SALT_F6A1B2C3D4E5', 0, 'N');

INSERT INTO USER_CREDENTIALS (USER_ID, USERNAME, PASSWORD_HASH, PASSWORD_SALT, FAILED_ATTEMPTS, ACCOUNT_LOCKED)
VALUES (5, 'jinhyuk.park',
        'b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0',
        'SALT_B6C1D2E3F4A5', 0, 'N');

INSERT INTO USER_CREDENTIALS (USER_ID, USERNAME, PASSWORD_HASH, PASSWORD_SALT, FAILED_ATTEMPTS, ACCOUNT_LOCKED)
VALUES (6, 'luis.garza',
        'e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7',
        'SALT_E5F6A1B2C3D4', 0, 'N');

/* ============================================================
   5. SPRINTS
   Sprint 1: Desarrollo base del sistema
   Sprint 2: Implementación de KPIs y métricas
   ============================================================ */
-- Sprint 1: 13 días hábiles total aprox. → 1+2+3+2+3+2 = 13 días
INSERT INTO SPRINTS (NAME, START_DATE, END_DATE, STATUS)
VALUES ('Sprint 1 - Desarrollo base del sistema', DATE '2025-01-06', DATE '2025-01-24', 'CLOSED');

-- Sprint 2: 2+1+2+2+3+1+3+2 = 16 días
INSERT INTO SPRINTS (NAME, START_DATE, END_DATE, STATUS)
VALUES ('Sprint 2 - Implementacion de KPIs y metricas', DATE '2025-01-27', DATE '2025-02-17', 'ACTIVE');

/* ============================================================
   6. PROJECTS
   ============================================================ */
INSERT INTO PROJECTS (NAME, DESCRIPTION, MANAGER_ID, STATUS)
VALUES ('Proyecto Alpha',
        'Plataforma de gestión de tareas con integración de bot Telegram',
        1, 'ACTIVE');

INSERT INTO PROJECTS (NAME, DESCRIPTION, MANAGER_ID, STATUS)
VALUES ('Proyecto Beta',
        'Sistema de monitoreo de KPIs y reportes automatizados',
        6, 'ACTIVE');

/* ============================================================
   7. PROJECT_SPRINTS
   ============================================================ */
INSERT INTO PROJECT_SPRINTS (PROJECT_ID, SPRINT_ID, SPRINT_NUMBER, IS_ACTIVE)
VALUES (1, 1, 1, 'N');

INSERT INTO PROJECT_SPRINTS (PROJECT_ID, SPRINT_ID, SPRINT_NUMBER, IS_ACTIVE)
VALUES (1, 2, 2, 'Y');

/* ============================================================
   8. PROJECT_MEMBERS
   ============================================================ */
-- Proyecto Alpha (manager: Inigo, devs: Victor, Paolo, Miguel, Jinhyuk)
INSERT INTO PROJECT_MEMBERS (PROJECT_ID, USER_ID, ROLE_IN_PROJECT) VALUES (1, 1, 'MANAGER');
INSERT INTO PROJECT_MEMBERS (PROJECT_ID, USER_ID, ROLE_IN_PROJECT) VALUES (1, 2, 'DEVELOPER');
INSERT INTO PROJECT_MEMBERS (PROJECT_ID, USER_ID, ROLE_IN_PROJECT) VALUES (1, 3, 'DEVELOPER');
INSERT INTO PROJECT_MEMBERS (PROJECT_ID, USER_ID, ROLE_IN_PROJECT) VALUES (1, 4, 'DEVELOPER');
INSERT INTO PROJECT_MEMBERS (PROJECT_ID, USER_ID, ROLE_IN_PROJECT) VALUES (1, 5, 'DEVELOPER');

-- Proyecto Beta (manager: Luis, devs: Victor, Miguel, Jinhyuk)
INSERT INTO PROJECT_MEMBERS (PROJECT_ID, USER_ID, ROLE_IN_PROJECT) VALUES (2, 6, 'MANAGER');
INSERT INTO PROJECT_MEMBERS (PROJECT_ID, USER_ID, ROLE_IN_PROJECT) VALUES (2, 2, 'DEVELOPER');
INSERT INTO PROJECT_MEMBERS (PROJECT_ID, USER_ID, ROLE_IN_PROJECT) VALUES (2, 4, 'DEVELOPER');
INSERT INTO PROJECT_MEMBERS (PROJECT_ID, USER_ID, ROLE_IN_PROJECT) VALUES (2, 5, 'DEVELOPER');

/* ============================================================
   9. TASKS
   ============================================================

   Sprint 1 - Desarrollo base del sistema (SPRINT_ID=1):
     T1  Definir endpoints de la API              | 1 día  | DONE
     T2  Ajustar conexión de base de datos        | 2 días | DONE
     T3  Implementar endpoints básicos            | 3 días | DONE
     T4  Probar endpoints básicos                 | 2 días | DONE
     T5  Implementar endpoints adicionales        | 3 días | DONE
     T6  Pruebas generales de endpoints           | 2 días | DONE

   Sprint 2 - KPIs y métricas (SPRINT_ID=2):
     T7  Definir recolección/cálculo de métricas  | 2 días | DONE
     T8  Definir gráficas del dashboard           | 1 día  | DONE
     T9  Implementar lógica de KPIs               | 2 días | IN_PROGRESS
     T10 Crear endpoints CRUD para KPIs           | 2 días | IN_PROGRESS
     T11 Implementar interfaz del dashboard       | 3 días | PENDING
     T12 Implementar gráficas                     | 1 día  | PENDING
     T13 Integrar dashboard con el API            | 3 días | PENDING
     T14 Pruebas del dashboard y validación       | 2 días | PENDING
   ============================================================ */

-- ── Sprint 1 (CLOSED) ─────────────────────────────────────
INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 1, 'Definir endpoints de la API',
        'Especificar y documentar todos los endpoints REST que expone el sistema',
        'COMPLETED', 'DONE', 'HIGH', 1, 2, DATE '2025-01-07');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 1, 'Ajustar conexión de base de datos en proyecto base',
        'Configurar datasource, pool de conexiones y credenciales en el proyecto base',
        'COMPLETED', 'DONE', 'HIGH', 1, 4, DATE '2025-01-09');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 1, 'Implementar endpoints básicos',
        'Desarrollar los endpoints definidos en la etapa de diseño para las entidades principales',
        'COMPLETED', 'DONE', 'HIGH', 1, 3, DATE '2025-01-14');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 1, 'Probar endpoints básicos',
        'Ejecutar pruebas funcionales e integración sobre los endpoints básicos implementados',
        'COMPLETED', 'DONE', 'MEDIUM', 1, 5, DATE '2025-01-16');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 1, 'Implementar endpoints adicionales',
        'Desarrollar endpoints secundarios y de soporte identificados en el análisis',
        'COMPLETED', 'DONE', 'MEDIUM', 1, 2, DATE '2025-01-21');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 1, 'Pruebas generales de endpoints',
        'Suite completa de pruebas que valida todos los endpoints del sistema',
        'COMPLETED', 'DONE', 'MEDIUM', 1, 4, DATE '2025-01-24');

-- ── Sprint 2 (ACTIVE) ─────────────────────────────────────
INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 2, 'Definir cómo se recolectarán o calcularán las métricas en el sistema',
        'Documentar la estrategia de recolección y cálculo de métricas: eventos, queries y fuentes de datos',
        'COMPLETED', 'DONE', 'HIGH', 1, 2, DATE '2025-01-29');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 2, 'Definir gráficas que se usarán en el dashboard',
        'Seleccionar tipos de gráficas, variables y disposición visual del dashboard principal',
        'COMPLETED', 'DONE', 'MEDIUM', 1, 3, DATE '2025-01-28');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 2, 'Implementar lógica para calcular los KPIs',
        'Desarrollar los cálculos de cada KPI definido: tareas completadas, cumplimiento, MTTR, etc.',
        'SPRINT', 'IN_PROGRESS', 'HIGH', 1, 4, DATE '2025-01-31');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 2, 'Crear endpoints CRUD para los KPIs',
        'Exponer endpoints REST para crear, leer, actualizar y eliminar registros de KPI_VALUES y KPI_TYPES',
        'SPRINT', 'IN_PROGRESS', 'HIGH', 1, 5, DATE '2025-02-04');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 2, 'Implementar interfaz del dashboard',
        'Desarrollar las vistas y componentes frontend del dashboard de métricas',
        'SPRINT', 'PENDING', 'HIGH', 1, 3, DATE '2025-02-07');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 2, 'Implementar gráficas',
        'Integrar la librería de gráficas y renderizar cada visualización definida en el diseño',
        'SPRINT', 'PENDING', 'MEDIUM', 1, 3, DATE '2025-02-10');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 2, 'Integrar dashboard con el API',
        'Conectar las vistas del dashboard con los endpoints CRUD de KPIs mediante llamadas HTTP',
        'SPRINT', 'PENDING', 'HIGH', 1, 2, DATE '2025-02-13');

INSERT INTO TASKS (PROJECT_ID, SPRINT_ID, TITLE, DESCRIPTION, TASK_STAGE, STATUS, PRIORITY, CREATED_BY, ASSIGNED_TO, DUE_DATE)
VALUES (1, 2, 'Pruebas del dashboard y validación de métricas',
        'Verificar que las métricas mostradas en el dashboard coinciden con los valores calculados en el backend',
        'SPRINT', 'PENDING', 'MEDIUM', 1, 5, DATE '2025-02-17');

/* ============================================================
   10. TASK_STATUS_HISTORY
   ============================================================ */
-- Task 1: Definir endpoints de la API
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (1, 'PENDING', 'IN_PROGRESS', 2, TIMESTAMP '2025-01-06 09:00:00');
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (1, 'IN_PROGRESS', 'DONE', 2, TIMESTAMP '2025-01-07 17:00:00');

-- Task 2: Ajustar conexión de base de datos
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (2, 'PENDING', 'IN_PROGRESS', 4, TIMESTAMP '2025-01-07 09:00:00');
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (2, 'IN_PROGRESS', 'DONE', 4, TIMESTAMP '2025-01-09 17:00:00');

-- Task 3: Implementar endpoints básicos
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (3, 'PENDING', 'IN_PROGRESS', 3, TIMESTAMP '2025-01-09 09:00:00');
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (3, 'IN_PROGRESS', 'DONE', 3, TIMESTAMP '2025-01-14 17:00:00');

-- Task 4: Probar endpoints básicos
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (4, 'PENDING', 'IN_PROGRESS', 5, TIMESTAMP '2025-01-14 09:00:00');
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (4, 'IN_PROGRESS', 'DONE', 5, TIMESTAMP '2025-01-16 17:00:00');

-- Task 5: Implementar endpoints adicionales
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (5, 'PENDING', 'IN_PROGRESS', 2, TIMESTAMP '2025-01-16 09:00:00');
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (5, 'IN_PROGRESS', 'DONE', 2, TIMESTAMP '2025-01-21 17:00:00');

-- Task 6: Pruebas generales de endpoints
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (6, 'PENDING', 'IN_PROGRESS', 4, TIMESTAMP '2025-01-21 09:00:00');
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (6, 'IN_PROGRESS', 'DONE', 4, TIMESTAMP '2025-01-24 17:00:00');

-- Task 7: Definir recolección de métricas
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (7, 'PENDING', 'IN_PROGRESS', 2, TIMESTAMP '2025-01-27 09:00:00');
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (7, 'IN_PROGRESS', 'DONE', 2, TIMESTAMP '2025-01-29 17:00:00');

-- Task 8: Definir gráficas del dashboard
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (8, 'PENDING', 'IN_PROGRESS', 3, TIMESTAMP '2025-01-27 09:00:00');
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (8, 'IN_PROGRESS', 'DONE', 3, TIMESTAMP '2025-01-28 17:00:00');

-- Task 9: Implementar lógica de KPIs
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (9, 'PENDING', 'IN_PROGRESS', 4, TIMESTAMP '2025-01-29 09:00:00');

-- Task 10: Endpoints CRUD para KPIs
INSERT INTO TASK_STATUS_HISTORY (TASK_ID, OLD_STATUS, NEW_STATUS, CHANGED_BY, CHANGED_AT)
VALUES (10, 'PENDING', 'IN_PROGRESS', 5, TIMESTAMP '2025-01-30 09:00:00');

/* ============================================================
   11. TASK_SPRINT_HISTORY
   ============================================================ */
INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (1, NULL, 1, 1, TIMESTAMP '2025-01-06 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (2, NULL, 1, 1, TIMESTAMP '2025-01-06 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (3, NULL, 1, 1, TIMESTAMP '2025-01-06 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (4, NULL, 1, 1, TIMESTAMP '2025-01-06 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (5, NULL, 1, 1, TIMESTAMP '2025-01-06 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (6, NULL, 1, 1, TIMESTAMP '2025-01-06 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (7, NULL, 2, 1, TIMESTAMP '2025-01-27 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (8, NULL, 2, 1, TIMESTAMP '2025-01-27 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (9, NULL, 2, 1, TIMESTAMP '2025-01-27 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (10, NULL, 2, 1, TIMESTAMP '2025-01-27 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (11, NULL, 2, 1, TIMESTAMP '2025-01-27 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (12, NULL, 2, 1, TIMESTAMP '2025-01-27 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (13, NULL, 2, 1, TIMESTAMP '2025-01-27 08:00:00');

INSERT INTO TASK_SPRINT_HISTORY (TASK_ID, OLD_SPRINT_ID, NEW_SPRINT_ID, CHANGED_BY, CHANGED_AT)
VALUES (14, NULL, 2, 1, TIMESTAMP '2025-01-27 08:00:00');

/* ============================================================
   12. KPI_TYPES
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
VALUES ('USO_CPU',                       'INFRA',       'percent', 'Uso promedio de CPU reportado por agente');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('USO_MEMORIA',                   'INFRA',       'percent', 'Uso promedio de memoria RAM reportado por agente');

INSERT INTO KPI_TYPES (NAME, CATEGORY, UNIT, DESCRIPTION)
VALUES ('INCIDENTES_SEGURIDAD',          'SECURITY',    'count',   'Incidentes con TYPE=SECURITY registrados');

/* ============================================================
   13. KPI_VALUES
   ============================================================ */
-- Sprint 1 cerrado: 6 tareas completadas, 100% cumplimiento
INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, SPRINT_ID, VALUE, RECORDED_AT)
VALUES (1, 'SPRINT', 1, 6, TIMESTAMP '2025-01-24 23:59:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, SPRINT_ID, VALUE, RECORDED_AT)
VALUES (2, 'SPRINT', 1, 100.00, TIMESTAMP '2025-01-24 23:59:00');

-- Sprint 2 activo: 2 tareas done de 8
INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, SPRINT_ID, VALUE, RECORDED_AT)
VALUES (1, 'SPRINT', 2, 2, TIMESTAMP '2025-02-06 23:59:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, SPRINT_ID, VALUE, RECORDED_AT)
VALUES (2, 'SPRINT', 2, 25.00, TIMESTAMP '2025-02-06 23:59:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, PROJECT_ID, VALUE, RECORDED_AT)
VALUES (4, 'PROJECT', 1, 50.00, TIMESTAMP '2025-02-05 23:59:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, PROJECT_ID, VALUE, RECORDED_AT)
VALUES (5, 'PROJECT', 1, 0, TIMESTAMP '2025-02-06 00:00:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, SPRINT_ID, VALUE, RECORDED_AT)
VALUES (6, 'SPRINT', 1, 1, TIMESTAMP '2025-01-24 23:59:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, PROJECT_ID, VALUE, RECORDED_AT)
VALUES (7, 'PROJECT', 1, 47.50, TIMESTAMP '2025-02-06 00:00:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, PROJECT_ID, VALUE, RECORDED_AT)
VALUES (8, 'PROJECT', 1, 85.71, TIMESTAMP '2025-02-06 00:00:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, VALUE, RECORDED_AT)
VALUES (9, 'GLOBAL', 42, TIMESTAMP '2025-02-05 23:59:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, SPRINT_ID, VALUE, RECORDED_AT)
VALUES (10, 'SPRINT', 1, 99.95, TIMESTAMP '2025-01-24 23:59:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, PROJECT_ID, VALUE, RECORDED_AT)
VALUES (11, 'PROJECT', 1, 68.40, TIMESTAMP '2025-02-06 10:00:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, PROJECT_ID, VALUE, RECORDED_AT)
VALUES (12, 'PROJECT', 1, 54.30, TIMESTAMP '2025-02-06 10:00:00');

INSERT INTO KPI_VALUES (KPI_TYPE_ID, SCOPE_TYPE, PROJECT_ID, VALUE, RECORDED_AT)
VALUES (13, 'PROJECT', 1, 0, TIMESTAMP '2025-02-06 00:00:00');

/* ============================================================
   14. LLM_ANALYSIS
   ============================================================ */
INSERT INTO LLM_ANALYSIS (SCOPE_TYPE, SPRINT_ID, ANOMALY_DETECTED, ANOMALY_TYPE, CONFIDENCE_SCORE, RECOMMENDATION)
VALUES ('SPRINT', 1, 'N', NULL, 97.00,
        'Sprint 1 cerrado con 100% de cumplimiento. Todas las tareas de desarrollo base fueron completadas en tiempo. No se detectan anomalías.');

INSERT INTO LLM_ANALYSIS (SCOPE_TYPE, PROJECT_ID, ANOMALY_DETECTED, ANOMALY_TYPE, CONFIDENCE_SCORE, RECOMMENDATION)
VALUES ('PROJECT', 1, 'Y', 'LOW_SPRINT_PROGRESS', 82.50,
        'Sprint 2 muestra 25% de cumplimiento al cierre de la primera semana. Se recomienda revisar el avance de las tareas de implementación de KPIs y coordinar con el equipo para identificar bloqueos.');

INSERT INTO LLM_ANALYSIS (SCOPE_TYPE, USER_ID, ANOMALY_DETECTED, ANOMALY_TYPE, CONFIDENCE_SCORE, RECOMMENDATION)
VALUES ('USER', 2, 'N', NULL, 95.00,
        'Victor Martinez mantiene una velocidad constante de entrega. No se detectan anomalías en su ritmo de trabajo.');

INSERT INTO LLM_ANALYSIS (SCOPE_TYPE, ANOMALY_DETECTED, CONFIDENCE_SCORE, RECOMMENDATION)
VALUES ('GLOBAL', 'N', 99.00,
        'El sistema opera dentro de parámetros normales. Las interacciones del bot se mantienen estables con tendencia positiva de adopción.');

/* ============================================================
   15. DEPLOYMENTS
   ============================================================ */
INSERT INTO DEPLOYMENTS (PROJECT_ID, VERSION, ENVIRONMENT, STATUS, DEPLOYED_AT, RECOVERY_TIME_MIN)
VALUES (1, 'v1.0.0', 'DEV',        'SUCCESS',     TIMESTAMP '2025-01-08 14:00:00', NULL);

INSERT INTO DEPLOYMENTS (PROJECT_ID, VERSION, ENVIRONMENT, STATUS, DEPLOYED_AT, RECOVERY_TIME_MIN)
VALUES (1, 'v1.0.0', 'QA',         'SUCCESS',     TIMESTAMP '2025-01-10 15:00:00', NULL);

INSERT INTO DEPLOYMENTS (PROJECT_ID, VERSION, ENVIRONMENT, STATUS, DEPLOYED_AT, RECOVERY_TIME_MIN)
VALUES (1, 'v1.0.0', 'STAGING',    'SUCCESS',     TIMESTAMP '2025-01-14 16:00:00', NULL);

INSERT INTO DEPLOYMENTS (PROJECT_ID, VERSION, ENVIRONMENT, STATUS, DEPLOYED_AT, RECOVERY_TIME_MIN)
VALUES (1, 'v1.0.0', 'PRODUCTION', 'SUCCESS',     TIMESTAMP '2025-01-24 20:00:00', NULL);

INSERT INTO DEPLOYMENTS (PROJECT_ID, VERSION, ENVIRONMENT, STATUS, DEPLOYED_AT, RECOVERY_TIME_MIN)
VALUES (1, 'v1.1.0', 'DEV',        'SUCCESS',     TIMESTAMP '2025-01-28 10:00:00', NULL);

INSERT INTO DEPLOYMENTS (PROJECT_ID, VERSION, ENVIRONMENT, STATUS, DEPLOYED_AT, RECOVERY_TIME_MIN)
VALUES (1, 'v1.1.0', 'QA',         'FAILED',      TIMESTAMP '2025-01-29 11:00:00', 35.00);

INSERT INTO DEPLOYMENTS (PROJECT_ID, VERSION, ENVIRONMENT, STATUS, DEPLOYED_AT, RECOVERY_TIME_MIN)
VALUES (1, 'v1.1.1', 'QA',         'SUCCESS',     TIMESTAMP '2025-01-30 13:00:00', NULL);

INSERT INTO DEPLOYMENTS (PROJECT_ID, VERSION, ENVIRONMENT, STATUS, DEPLOYED_AT, RECOVERY_TIME_MIN)
VALUES (1, 'v1.2.0', 'DEV',        'IN_PROGRESS', TIMESTAMP '2025-02-06 09:00:00', NULL);

/* ============================================================
   16. INCIDENTS
   ============================================================ */
INSERT INTO INCIDENTS (PROJECT_ID, TYPE, DESCRIPTION, SEVERITY, OCCURRED_AT, RESOLVED_AT)
VALUES (1, 'PERFORMANCE',
        'Latencia elevada en endpoint /api/tasks durante hora pico. P95 superó 3 segundos.',
        'HIGH', TIMESTAMP '2025-01-22 14:30:00', TIMESTAMP '2025-01-22 15:15:00');

INSERT INTO INCIDENTS (PROJECT_ID, TYPE, DESCRIPTION, SEVERITY, OCCURRED_AT, RESOLVED_AT)
VALUES (1, 'SECURITY',
        'Intento de acceso no autorizado detectado en endpoint /api/admin desde IP externa.',
        'CRITICAL', TIMESTAMP '2025-01-28 03:10:00', TIMESTAMP '2025-01-28 04:00:00');

INSERT INTO INCIDENTS (PROJECT_ID, TYPE, DESCRIPTION, SEVERITY, OCCURRED_AT, RESOLVED_AT)
VALUES (1, 'DEPLOYMENT',
        'Fallo en pipeline de QA al desplegar v1.1.0. Error en script de migración de BD.',
        'HIGH', TIMESTAMP '2025-01-29 11:00:00', TIMESTAMP '2025-01-29 12:30:00');

INSERT INTO INCIDENTS (PROJECT_ID, TYPE, DESCRIPTION, SEVERITY, OCCURRED_AT, RESOLVED_AT)
VALUES (1, 'PERFORMANCE',
        'Incremento sostenido en uso de CPU por encima del 70% desde las 09:00.',
        'HIGH', TIMESTAMP '2025-02-06 09:00:00', NULL);

/* ============================================================
   17. BOT_INTERACTIONS
   ============================================================ */
INSERT INTO BOT_INTERACTIONS (USER_ID, MESSAGE, RESPONSE, CREATED_AT)
VALUES (2, '/tareas pendientes',
        'Tienes 2 tareas activas en Sprint 2: "Implementar lógica para calcular los KPIs" (IN_PROGRESS) y "Integrar dashboard con el API" (PENDING).',
        TIMESTAMP '2025-02-05 09:15:00');

INSERT INTO BOT_INTERACTIONS (USER_ID, MESSAGE, RESPONSE, CREATED_AT)
VALUES (3, '/sprint actual',
        'Sprint 2 del Proyecto Alpha está activo (27-Ene al 17-Feb). Objetivo: Implementación de KPIs y métricas. Progreso: 2/8 tareas completadas.',
        TIMESTAMP '2025-02-05 09:30:00');

INSERT INTO BOT_INTERACTIONS (USER_ID, MESSAGE, RESPONSE, CREATED_AT)
VALUES (1, '/incidentes abiertos',
        'Hay 1 incidente abierto: CPU elevada en Proyecto Alpha (SEVERITY: HIGH) desde las 09:00.',
        TIMESTAMP '2025-02-06 10:05:00');

INSERT INTO BOT_INTERACTIONS (USER_ID, MESSAGE, RESPONSE, CREATED_AT)
VALUES (1, '/kpi cumplimiento sprint 1',
        'Sprint 1 - Proyecto Alpha: Cumplimiento 100% (6 de 6 tareas completadas). Sprint cerrado exitosamente.',
        TIMESTAMP '2025-02-06 10:20:00');

INSERT INTO BOT_INTERACTIONS (USER_ID, MESSAGE, RESPONSE, CREATED_AT)
VALUES (4, '/mis tareas',
        'Miguel Angel Alvarez tiene 1 tarea activa: "Implementar lógica para calcular los KPIs" (IN_PROGRESS, Sprint 2).',
        TIMESTAMP '2025-02-06 11:00:00');

INSERT INTO BOT_INTERACTIONS (USER_ID, MESSAGE, RESPONSE, CREATED_AT)
VALUES (NULL, '/ayuda',
        'Comandos disponibles: /tareas, /sprint, /kpi, /incidentes, /despliegues, /dashboard.',
        TIMESTAMP '2025-02-06 11:30:00');

/* ============================================================
   18. AUDIT_LOG
   ============================================================ */
INSERT INTO AUDIT_LOG (USER_ID, ACTION_TYPE, ENTITY_NAME, ENTITY_ID, IP_ADDRESS)
VALUES (1, 'CREATE', 'PROJECTS', 1, '192.168.1.10');

INSERT INTO AUDIT_LOG (USER_ID, ACTION_TYPE, ENTITY_NAME, ENTITY_ID, IP_ADDRESS)
VALUES (1, 'CREATE', 'SPRINTS', 1, '192.168.1.10');

INSERT INTO AUDIT_LOG (USER_ID, ACTION_TYPE, ENTITY_NAME, ENTITY_ID, IP_ADDRESS)
VALUES (1, 'CREATE', 'SPRINTS', 2, '192.168.1.10');

INSERT INTO AUDIT_LOG (USER_ID, ACTION_TYPE, ENTITY_NAME, ENTITY_ID, IP_ADDRESS)
VALUES (1, 'CREATE', 'TASKS', 1, '192.168.1.10');

INSERT INTO AUDIT_LOG (USER_ID, ACTION_TYPE, ENTITY_NAME, ENTITY_ID, IP_ADDRESS)
VALUES (4, 'UPDATE', 'TASKS', 9, '192.168.1.25');

INSERT INTO AUDIT_LOG (USER_ID, ACTION_TYPE, ENTITY_NAME, ENTITY_ID, IP_ADDRESS)
VALUES (5, 'UPDATE', 'TASKS', 10, '192.168.1.30');

INSERT INTO AUDIT_LOG (USER_ID, ACTION_TYPE, ENTITY_NAME, ENTITY_ID, IP_ADDRESS)
VALUES (2, 'UPDATE', 'DEPLOYMENTS', 6, '10.0.0.5');

INSERT INTO AUDIT_LOG (USER_ID, ACTION_TYPE, ENTITY_NAME, ENTITY_ID, IP_ADDRESS)
VALUES (NULL, 'LOGIN_ATTEMPT', 'USER_CREDENTIALS', NULL, '203.0.113.42');

INSERT INTO AUDIT_LOG (USER_ID, ACTION_TYPE, ENTITY_NAME, ENTITY_ID, IP_ADDRESS)
VALUES (1, 'CREATE', 'INCIDENTS', 2, '192.168.1.10');

COMMIT;
