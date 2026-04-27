# OCI Task Manager — Sprints & Tasks
> Source: PDF export parsed and distributed across team members.
> To be used as reference for SQL generation.

---

## Team Reference

| USER_ID | Name | Role | Team |
|---------|------|------|------|
| 1 | Iñigo González | MANAGER | Backend |
| 2 | Víctor Martínez | DEVELOPER | Backend |
| 3 | Paolo Gaya | DEVELOPER | Frontend |
| 4 | Miguel Ángel Álvarez | DEVELOPER | Backend |
| 5 | Jinhyuk Park | DEVELOPER | Frontend |
| 6 | Luis Garza Gómez | MANAGER | Backend (Scrum Master) |

---

## TYPE column values used

| Code | Description |
|------|-------------|
| `Doc` | Documentation |
| `Req` | Requirements |
| `UX` | User Experience / Design |
| `KPI` | KPI / Metrics |
| `Data` | Data / SQL |
| `Arch` | Architecture |
| `PM` | Project Management |
| `Bot` | Bot / Backend development |
| `IA` | Artificial Intelligence |
| `Demo` | Demo / Video |
| `Val` | Validation |

---

## Sprint 1
- **NAME:** Sprint 1 - Plan, Requerimientos y Documentación Base
- **START_DATE:** 2026-02-11
- **END_DATE:** 2026-02-25
- **STATUS:** CLOSED
- **TOTAL_HOURS:** 35 (1h average per task × 35 tasks)

> Distribution strategy: round-robin across all 6 members (~5-6 tasks each).
> CREATED_BY: Iñigo (1) or Luis (6) alternating.

### Tasks

| ID | Title | Description | Type | Status | Assigned To (ID) | Created By (ID) | Est. Hours |
|----|-------|-------------|------|--------|-----------------|-----------------|------------|
| S1-01 | Visión y alcance del proyecto | Redactar visión y alcance del proyecto (propósito y resultado esperado) | Doc | DONE | 1 - Iñigo | 6 | 1 |
| S1-02 | Objetivos y entregables de alto nivel | Definir objetivos y entregables de alto nivel; indicar qué está dentro y fuera del alcance | Doc | DONE | 2 - Víctor | 6 | 1 |
| S1-03 | Impacto económico inicial | Calcular impacto económico inicial (puede adelantarse desde punto 7) | Doc | DONE | 3 - Paolo | 1 | 1 |
| S1-04 | Objetivo del Sprint 1 | Establecer objetivo del Sprint 1 con metas y entregables específicos | Doc | DONE | 4 - Miguel | 1 | 1 |
| S1-05 | Sprint Backlog priorizado | Construir Sprint Backlog priorizando tareas del product backlog | Doc | DONE | 5 - Jinhyuk | 6 | 1 |
| S1-06 | Capacidad del equipo | Estimar capacidad del equipo para asegurar carga de trabajo realista | Doc | DONE | 6 - Luis | 6 | 1 |
| S1-07 | Cronograma e hitos | Definir cronograma con línea de tiempo e hitos clave | Doc | DONE | 1 - Iñigo | 1 | 1 |
| S1-08 | Requerimientos funcionales | Levantar y numerar todos los requerimientos funcionales | Req | DONE | 2 - Víctor | 6 | 1 |
| S1-09 | Verificación de FRs | Verificar que cada FR sea claro, no ambiguo, verificable y trazable | Req | DONE | 3 - Paolo | 1 | 1 |
| S1-10 | Requerimientos no funcionales | Levantar y numerar todos los requerimientos no funcionales | Req | DONE | 4 - Miguel | 1 | 1 |
| S1-11 | NFR Oracle | Incluir todos los NFR solicitados por Oracle | Req | DONE | 5 - Jinhyuk | 6 | 1 |
| S1-12 | Verificación de NFRs | Verificar que cada NFR sea claro, no ambiguo, verificable y trazable | Req | DONE | 6 - Luis | 6 | 1 |
| S1-13 | Historias de usuario | Redactar una historia de usuario por diapositiva | UX | DONE | 1 - Iñigo | 1 | 1 |
| S1-14 | Top 3 historias de usuario | Seleccionar las 3 historias de usuario de mayor prioridad | UX | DONE | 2 - Víctor | 6 | 1 |
| S1-15 | Criterios de aceptación HU | Agregar criterios de aceptación a cada historia de usuario seleccionada | UX | DONE | 3 - Paolo | 1 | 1 |
| S1-16 | Propuesta KPI productividad | Elaborar propuesta de KPI de productividad dirigida a Oracle | KPI | DONE | 4 - Miguel | 1 | 1 |
| S1-17 | Ejemplos KPI productividad | Preparar ejemplos con datos recolectados en las primeras 5 semanas | KPI | DONE | 5 - Jinhyuk | 6 | 1 |
| S1-18 | KPIs adicionales | Definir KPI adicionales (tareas completadas, horas reales, recursos utilizados) | KPI | DONE | 6 - Luis | 6 | 1 |
| S1-19 | Ejemplos KPIs adicionales | Mostrar ejemplos con datos propios del proyecto | KPI | DONE | 1 - Iñigo | 1 | 1 |
| S1-20 | Costos OCI acumulados | Listar servicios OCI utilizados con costos acumulados hasta semana 5 | Data | DONE | 2 - Víctor | 6 | 1 |
| S1-21 | Proyección costos OCI | Proyectar estimación de costos OCI para todo el proyecto | Data | DONE | 3 - Paolo | 1 | 1 |
| S1-22 | Costo de recursos humanos | Calcular costo de recursos humanos en dólares (fórmula: horas × costo/hora) | Data | DONE | 4 - Miguel | 1 | 1 |
| S1-23 | Evidencia horas trabajadas | Recopilar evidencia de horas trabajadas por cada desarrollador (24 h/sem) | Data | DONE | 5 - Jinhyuk | 6 | 1 |
| S1-24 | Diagrama de arquitectura | Elaborar diagrama de arquitectura en formato Oracle | Arch | DONE | 6 - Luis | 6 | 1 |
| S1-25 | Diagrama modelo relacional | Generar diagrama de modelo relacional desde OCI Autonomous Database | Arch | DONE | 1 - Iñigo | 1 | 1 |
| S1-26 | Verificación modelo relacional | Verificar que incluya nombres de tablas, atributos, PK y FK (sin ERD ni UML) | Arch | DONE | 2 - Víctor | 6 | 1 |
| S1-27 | Consultas SQL con tablas anidadas | Redactar consultas SQL usando tablas anidadas (semanas 4 y 5) | Data | DONE | 3 - Paolo | 1 | 1 |
| S1-28 | Evidencia integridad de datos | Evidenciar integridad de datos con datos reales del proyecto | Data | DONE | 4 - Miguel | 1 | 1 |
| S1-29 | Demo servicio cloud | Preparar demostración del servicio cloud implementado | UX | DONE | 5 - Jinhyuk | 6 | 1 |
| S1-30 | Backlog en demo | Mostrar backlog con tareas en la demo | UX | DONE | 6 - Luis | 6 | 1 |
| S1-31 | Capturas de pantalla ejecución | Incluir capturas de pantalla que evidencien la ejecución del servicio | UX | DONE | 1 - Iñigo | 1 | 1 |
| S1-32 | Gestión del proyecto | Documentar gestión del proyecto: Backlog y reportes de equipo | PM | DONE | 2 - Víctor | 6 | 1 |
| S1-33 | Plan de calidad | Definir plan de calidad: estrategias, procesos y estándares de entrega | PM | DONE | 3 - Paolo | 1 | 1 |
| S1-34 | Plan de pruebas | Elaborar plan de pruebas: Aceptación, Unitarias e Integración | PM | DONE | 4 - Miguel | 1 | 1 |
| S1-35 | Matriz de trazabilidad | Construir matriz de trazabilidad | PM | DONE | 5 - Jinhyuk | 6 | 1 |

---

## Sprint 2
- **NAME:** Sprint 2 - Bot de Telegram y Operaciones de Tareas
- **START_DATE:** 2026-04-01
- **END_DATE:** 2026-04-15
- **STATUS:** CLOSED
- **TOTAL_HOURS:** 27

> Distribution strategy: Bot/Backend → Iñigo, Víctor, Miguel | Frontend/UX → Paolo, Jinhyuk | PM/Val → Luis.
> CREATED_BY: Iñigo (1) or Luis (6).

### Tasks

| ID | Title | Description | Type | Status | Assigned To (ID) | Created By (ID) | Est. Hours |
|----|-------|-------------|------|--------|-----------------|-----------------|------------|
| S2-02 | Comando /start | Implementar comando /start — captura telegram_id y username del usuario | Bot | DONE | 1 - Iñigo | 6 | 2 |
| S2-03 | Lógica validación usuario | Lógica de validación: usuario existente → bienvenida; nuevo → registro | Bot | DONE | 4 - Miguel | 6 | 3 |
| S2-04 | Confirmación de registro | Confirmar registro con respuesta del bot (mensaje con datos guardados) | Bot | DONE | 2 - Víctor | 1 | 1 |
| S2-07 | Comando /addtask | Implementar comando /addtask con parámetros: titulo, descripcion, horas_estimadas, prioridad | Bot | DONE | 1 - Iñigo | 6 | 3 |
| S2-08 | Validación horas estimadas | Validación: si horas_estimadas > 4 → el bot rechaza y solicita subdividir la tarea | Bot | DONE | 4 - Miguel | 6 | 2 |
| S2-09 | Asignación por telegram_id | Asignar developer_id automáticamente por telegram_id del usuario que envía el comando | Bot | DONE | 2 - Víctor | 1 | 2 |
| S2-13 | Comando /assigntask | Implementar comando /assigntask con parámetro: task_id | Bot | DONE | 1 - Iñigo | 6 | 2 |
| S2-14 | Detección sprint activo | Obtener automáticamente el sprint con status = ACTIVE para asignación | Bot | DONE | 4 - Miguel | 6 | 2 |
| S2-15 | UPDATE tarea a IN_PROGRESS | UPDATE en TASKS: status → IN_PROGRESS, sprint_id asignado, fecha_inicio = SYSDATE | Bot | DONE | 2 - Víctor | 1 | 2 |
| S2-17 | Comando /completetask | Implementar comando /completetask con parámetros: task_id, horas_reales, comentario (opcional) | Bot | DONE | 1 - Iñigo | 6 | 3 |
| S2-18 | Validación propietario tarea | Validar que el developer que ejecuta el comando sea el propietario de la tarea | Bot | DONE | 4 - Miguel | 6 | 2 |
| S2-19 | UPDATE tarea a COMPLETED | UPDATE en TASKS: status → COMPLETED, horas_reales, fecha_fin = SYSDATE, comentario | Bot | DONE | 2 - Víctor | 1 | 2 |
| S2-20 | Cálculo de varianza | Calcular y almacenar varianza = horas_reales - horas_estimadas (campo en TASKS) | Bot | DONE | 4 - Miguel | 1 | 1 |
| S2-26 | Comando /kpi | Implementar comando /kpi: tareas completadas, horas estimadas vs reales, varianza promedio por developer | KPI | DONE | 3 - Paolo | 6 | 4 |
| S2-27 | KPI por developer | Mostrar KPI por developer (% cumplimiento, total horas invertidas) | KPI | DONE | 5 - Jinhyuk | 6 | 2 |
| S2-29 | Evidencia SQL KPI | Mostrar evidencia SQL del query KPI ejecutado directamente en ATP | KPI | DONE | 3 - Paolo | 1 | 1 |
| S2-30 | Verificar IP pública | Verificar y documentar IP pública del servidor (debe iniciar con 140.) | Val | DONE | 6 - Luis | 6 | 1 |
| S2-31 | Demo bot conectado a ATP | Demostrar que el bot de Telegram funciona conectado a la BD ATP actualizada | Val | DONE | 6 - Luis | 6 | 1 |
| S2-32 | Cambios en Cloud BD con SQL | Mostrar cambios en la Cloud BD con SQL en cada operación (add, assign, complete) | Val | DONE | 6 - Luis | 1 | 2 |
| S2-35 | Alta de tasks en Oracle Bot | Dar de alta TODAS las tasks del sprint en el Oracle Bot antes de iniciar trabajo | Val | DONE | 6 - Luis | 1 | 1 |

---

## Sprint 3
- **NAME:** Sprint 3 - KPIs, Feature de IA y Video Demo
- **START_DATE:** 2026-04-15
- **END_DATE:** 2026-04-29
- **STATUS:** ACTIVE
- **TOTAL_HOURS:** 47

> Distribution strategy: KPI/Data/Bot → Víctor, Miguel, Iñigo | IA/UX/Demo → Paolo, Jinhyuk | PM/Val/Arch → Luis.
> CREATED_BY: Iñigo (1) or Luis (6).

### Tasks

| ID | Title | Description | Type | Status | Assigned To (ID) | Created By (ID) | Est. Hours |
|----|-------|-------------|------|--------|-----------------|-----------------|------------|
| S3-01 | Query SQL KPIs reales | Ejecutar query SQL: tasks completadas y horas reales agrupadas por developer y sprint | KPI | PENDING | 2 - Víctor | 1 | 2 |
| S3-02 | Gráfica de barras KPI | Generar gráfica de barras: tasks terminadas por usuario/sprint (herramienta a elección) | KPI | PENDING | 5 - Jinhyuk | 6 | 3 |
| S3-03 | Screenshot KPIs en app | Tomar screenshot legible de la app con los KPIs visibles (anticipado, no en presentación) | KPI | PENDING | 3 - Paolo | 6 | 1 |
| S3-04 | Slide respaldo KPIs | Preparar slide de respaldo con foto/imagen de los KPIs en caso de fallo de conexión OCI | KPI | PENDING | 3 - Paolo | 1 | 1 |
| S3-05 | Verificar datos reales en BD | Verificar que todos los datos en la BD sean tareas reales del reto (eliminar datos de prueba) | KPI | PENDING | 2 - Víctor | 1 | 2 |
| S3-06 | Insertar slide KPIs en video | Insertar slide de KPIs al inicio del video demo (ver sección 5) | KPI | PENDING | 5 - Jinhyuk | 6 | 1 |
| S3-07 | Descripción ejecutiva IA | Redactar descripción ejecutiva del feature de IA: problema que resuelve y valor de negocio | IA | PENDING | 3 - Paolo | 6 | 2 |
| S3-08 | Diapositiva feature IA | Diseñar la diapositiva con formato limpio: título, descripción en 3-4 puntos, ícono o imagen de apoyo | IA | PENDING | 5 - Jinhyuk | 6 | 2 |
| S3-09 | Caso de uso IA | Identificar el caso de uso principal del feature de IA con datos reales del proyecto | IA | PENDING | 3 - Paolo | 1 | 2 |
| S3-10 | Slide INPUT/OUTPUT IA | Diseñar la slide con sección INPUT (dato de entrada real) y sección OUTPUT (resultado generado) | IA | PENDING | 5 - Jinhyuk | 1 | 2 |
| S3-11 | Validar ejemplo IA reproducible | Validar que el ejemplo mostrado sea reproducible y corresponda a datos del reto | IA | PENDING | 3 - Paolo | 6 | 1 |
| S3-12 | Actualizar diagrama arquitectura | Actualizar diagrama de arquitectura Oracle para incluir el componente de IA | Arch | PENDING | 6 - Luis | 6 | 3 |
| S3-13 | Flujo de datos IA en arquitectura | Marcar claramente el flujo de datos hacia y desde el feature de IA | Arch | PENDING | 6 - Luis | 1 | 2 |
| S3-14 | Verificar consistencia arquitectura | Verificar consistencia entre el diagrama y la arquitectura real desplegada en OCI | Arch | PENDING | 6 - Luis | 6 | 1 |
| S3-15 | Grabar segmento KPI video | Grabar segmento inicial del video: mostrar gráficas de KPI (tasks completadas y horas reales) | Demo | PENDING | 5 - Jinhyuk | 6 | 2 |
| S3-16 | Grabar demo feature IA | Grabar demo del feature de IA: INPUT real → procesamiento → OUTPUT visible | Demo | PENDING | 3 - Paolo | 1 | 3 |
| S3-17 | Editar video final | Editar y unir los segmentos en un video final coherente y sin cortes abruptos | Demo | PENDING | 5 - Jinhyuk | 6 | 2 |
| S3-18 | IP pública visible en video | Verificar que la IP pública del servidor sea visible en algún momento del video | Demo | PENDING | 4 - Miguel | 1 | 1 |
| S3-19 | Prueba reproducción video | Hacer prueba de reproducción del video completo antes de la presentación | Demo | PENDING | 4 - Miguel | 6 | 1 |
| S3-20 | Documentar dificultades sprint | Documentar dificultades actuales del sprint con descripción y causa raíz | PM | PENDING | 6 - Luis | 6 | 2 |
| S3-21 | Plan de contingencia | Redactar plan de contingencia para cada dificultad identificada | PM | PENDING | 6 - Luis | 1 | 2 |
| S3-22 | Plan siguiente sprint | Definir plan para el siguiente sprint: objetivos, entregables y responsables | PM | PENDING | 6 - Luis | 6 | 2 |
| S3-23 | Estrategia DevOps CI/CD | Documentar estrategia DevOps: pipeline CI/CD, herramientas usadas (GitHub Actions, OCI DevOps) | PM | PENDING | 6 - Luis | 1 | 3 |
| S3-24 | Diapositiva siguientes pasos | Diseñar la diapositiva de siguientes pasos con formato claro y visual | PM | PENDING | 6 - Luis | 6 | 1 |
| S3-28 | Verificar página en producción | Verificar que la página web esté en producción y la IP pública sea accesible al momento de presentar | Val | PENDING | 2 - Víctor | 1 | 1 |
| S3-29 | Confirmar video grabado | Confirmar que el video demo esté grabado y listo para reproducirse sin depender de conexión en vivo | Val | PENDING | 4 - Miguel | 6 | 1 |
| S3-30 | Auditar BD tareas reales | Auditar la BD: eliminar tasks que no sean del reto o capacitaciones Oracle (no clases) | Val | PENDING | 2 - Víctor | 1 | 2 |
| S3-31 | Verificar horas_reales en KPI | Verificar que las horas mostradas en KPI sean horas_reales de la BD (no estimadas ni inventadas) | Val | PENDING | 4 - Miguel | 6 | 1 |
| S3-32 | Confirmar demo inmediata | Confirmar que la demo inicie de forma inmediata al comenzar la presentación | Val | PENDING | 2 - Víctor | 1 | 1 |

---

## SQL Generation Notes

When converting this markdown to SQL keep in mind:

- **STATUS mapping:** `Completo → DONE`, `Pendiente → PENDING`
- **TASK_STAGE mapping:** All Sprint 1 & 2 tasks → `COMPLETED`. Sprint 3 tasks → `SPRINT`
- **TYPE column:** Use the code values exactly as listed in the TYPE reference table above
- **IS_SUBTASK:** All tasks are `'N'` — no subtasks in this batch
- **PARENT_TASK_ID:** `NULL` for all
- **ACTUAL_HOURS:** Set equal to `ESTIMATED_HOURS` for DONE tasks (Sprint 1 & 2). `NULL` for PENDING tasks (Sprint 3)
- **DUE_DATE:** Use `END_DATE` of the corresponding sprint as the due date for all tasks
- **CREATED_AT / UPDATED_AT:** Use `START_DATE` of sprint as `CREATED_AT`. Use `END_DATE` as `UPDATED_AT` for DONE tasks
- **SPRINT_IDs:** Sprint 1 = 1, Sprint 2 = 2, Sprint 3 = 3
- **PROJECT_ID:** 1 for all tasks
