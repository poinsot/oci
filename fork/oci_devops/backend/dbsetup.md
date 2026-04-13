# Database Setup Guide

The application compiles and is fully functional. The only thing required before
running it is providing real database credentials. This guide covers every file
you need to touch for each scenario.

> **Schema note:** `ddl-auto=none` — Hibernate will NOT create tables automatically.
> You must run `oci-project/DB/schema.sql` against your Oracle schema before the
> first startup.

---

## Scenario 1 — Local development (`mvn spring-boot:run`)

**File:** `backend/src/main/resources/application.properties`

Uncomment and fill in the three lines near the top:

```properties
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/XEPDB1
spring.datasource.username=YOUR_SCHEMA_USER
spring.datasource.password=YOUR_PASSWORD
```

For Oracle ATP (wallet-based), use:

```properties
spring.datasource.url=jdbc:oracle:thin:@<tns_alias>?TNS_ADMIN=/path/to/wallet
spring.datasource.username=ADMIN
spring.datasource.password=YOUR_PASSWORD
```

Everything else in `application.properties` (UCP pool, JWT, Swagger, Telegram) is
already configured. No other changes needed to start the app.

Once the URL is set, run from `oci_devops/backend/`:

```bash
mvn spring-boot:run
```

The API will be available at `http://localhost:8080/api/v1`.
Swagger UI: `http://localhost:8080/api/v1/swagger-ui.html`

---

## Scenario 2 — Integration tests (`mvn test -Dtest="*IT"`)

**File:** `backend/src/test/resources/application-it.properties`

```properties
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/XEPDB1
spring.datasource.username=OCI_TEST_USER
spring.datasource.password=YOUR_TEST_PASSWORD
```

Replace `OCI_TEST_USER` and `YOUR_TEST_PASSWORD` with credentials for your local
Oracle XE test schema. The integration tests roll back each transaction so they are
safe to run against a shared dev schema.

Run with:

```bash
mvn test -Dtest="*IT" -Dspring.profiles.active=it
```

---

## Scenario 3 — Kubernetes / OCI deployment (`deploy.sh`)

For the full OCI deployment the datasource URL and password are **not** stored in
`application.properties` — they are injected at runtime via Kubernetes environment
variables and secrets.

### 3a. `backend/src/main/resources/todolistapp-springboot.yaml`

| Placeholder | Replace with |
|-------------|--------------|
| `db_user: "EQUIPO65"` | Your ATP schema username |
| `%TODO_PDB_NAME%` | Your ATP database name (also set the `TODO_PDB_NAME` env var before running `deploy.sh`) |
| `%DOCKER_REGISTRY%` | Your OCI Container Registry URL |
| `%OCI_REGION%` | Your OCI region code (e.g. `us-ashburn-1`) |

`%`-placeholders are substituted automatically by `deploy.sh` when you export the
corresponding environment variables before running the script.

### 3b. Kubernetes secrets (must exist in the `mtdrworkshop` namespace)

| Secret name | Key | Value |
|-------------|-----|-------|
| `dbuser` | `dbpassword` | ATP admin password (base64-encoded) |
| `frontendadmin` | `password` | UI admin password (base64-encoded) |
| `db-wallet-secret` | — | Oracle wallet files volume |

These are created by `infrastructure/utils/main-setup.sh` (interactive script —
run it once during initial infrastructure provisioning).

### 3c. `infrastructure/utils/db-setup.sh`

Line 33 contains a hardcoded wallet password (`Welcome1`). Replace it with a
secure value before running the script for any non-demo environment:

```bash
# line 33 — change Welcome1 to your chosen wallet password
--password 'YOUR_SECURE_WALLET_PASSWORD'
```

---

## Quick-reference: all files that need credentials

| File | Scenario | What to set |
|------|----------|-------------|
| `backend/src/main/resources/application.properties` | Local dev | `spring.datasource.url`, `username`, `password` |
| `backend/src/test/resources/application-it.properties` | IT tests | `spring.datasource.url`, `username`, `password` |
| `backend/src/main/resources/todolistapp-springboot.yaml` | K8s deploy | `db_user`, `%TODO_PDB_NAME%`, `%DOCKER_REGISTRY%`, `%OCI_REGION%` |
| `infrastructure/utils/db-setup.sh` line 33 | K8s infra setup | wallet password |
| K8s secrets (`dbuser`, `frontendadmin`, `db-wallet-secret`) | K8s deploy | created by `main-setup.sh` |
