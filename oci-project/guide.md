# Running the API and Accessing Swagger

## Prerequisites

- Java 21
- Maven 3.x
- Oracle Database XE running locally on port `1521` with the pluggable database `XEPDB1`

---

## 1. Database Setup

If the schema has not been created yet, connect to Oracle as the `OCI_USER` schema owner and run the scripts in order:

```sql
-- 1. Create tables
@DB/schema.sql

-- 2. Load seed/template data (optional)
@DB/template_data.sql
```

---

## 2. Configure the datasource

Open `backend/src/main/resources/application.properties` and set the correct password for your Oracle user:

```properties
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/XEPDB1
spring.datasource.username=OCI_USER
spring.datasource.password=CHANGE_ME   # <-- replace this
```

> The JWT secret and token expiry can also be changed in the same file if needed.

---

## 3. Build and run

All commands run from the `backend/` directory.

```bash
cd backend

# Build (skips tests for a faster startup)
mvn clean package -DskipTests

# Run
mvn spring-boot:run
```

The server starts on **http://localhost:8080** with the context path `/api/v1`.

---

## 4. Access the Swagger UI

Open your browser and go to:

```
http://localhost:8080/api/v1/swagger-ui.html
```

The raw OpenAPI JSON spec is available at:

```
http://localhost:8080/api/v1/v3/api-docs
```

---

## 5. Authenticate in Swagger

All endpoints except `/auth/login` require a Bearer token.

1. Call **POST /auth/login** with your credentials:

```json
{
  "username": "your_username",
  "password": "your_password"
}
```

2. Copy the `token` value from the response.

3. Click **Authorize** (top-right of the Swagger UI).

4. In the dialog, enter:

```
Bearer <paste your token here>
```

5. Click **Authorize** and close the dialog. All subsequent requests will include the token automatically.

> Tokens expire after **1 hour** (`app.jwt.expiration-ms=3600000`). Use **POST /auth/refresh** with your `refreshToken` to get a new access token without re-logging in. Refresh tokens are valid for **24 hours**.

---

## 6. Running tests

```bash
# Unit tests only
mvn test

# Single test class
mvn test -Dtest=TaskServiceTest

# Integration tests (requires a live Oracle DB configured in src/test/resources/application-it.properties)
mvn test -Dtest="*IT"
```
