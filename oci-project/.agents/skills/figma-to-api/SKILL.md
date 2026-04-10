---
name: figma-to-spring-api
description: >
  Interprets a Figma design (provided as exported Figma JSON) alongside existing
  Spring Boot backend artifacts (SQL schema, JPA entity, repository, service) and
  generates a complete, production-ready REST API layer. Outputs: a @RestController
  class with all endpoints, a generic ApiResponse wrapper, DTOs (Request/Response),
  springdoc-openapi (OpenAPI 3) Swagger annotations, and the springdoc Maven/Gradle
  dependency snippet. Use this skill whenever the user provides a Figma JSON export
  and wants Spring Boot (Java) controller code generated from it, or whenever they
  say things like "generate endpoints from my design", "create the API for this
  screen", "turn my Figma into a controller", or "I have my Figma JSON and my
  backend, generate the API".
---

# Figma → Spring Boot API Skill

## Overview

Given:
- A **Figma JSON export** describing one or more screens/components
- Existing backend: **SQL schema**, **JPA entity**, **repository interface**, **service class**

Produce:
1. `ApiResponse<T>` generic wrapper (if not already present in the project)
2. DTOs — one `*Request` and one `*Response` per logical resource
3. `@RestController` with all endpoints, fully annotated
4. springdoc-openapi Swagger annotations on every endpoint
5. The `pom.xml` / `build.gradle` dependency snippet for springdoc

---

## Step 1 — Ingest and Understand Inputs

### 1a. Read the Figma JSON

Focus on these keys in the Figma JSON tree:

| Figma key | What to extract |
|-----------|----------------|
| `name` on frame/component nodes | Screen name → maps to resource/controller name |
| Text nodes (`type: "TEXT"`) | Labels, field names, button labels, table column headers |
| Input/form nodes | Fields the user submits → drives `*Request` DTO fields |
| List/table/card nodes | Fields displayed → drives `*Response` DTO fields |
| Button labels | CRUD intent: "Save", "Create" → POST; "Edit" → PUT/PATCH; "Delete" → DELETE; "Search"/"Filter" → GET with params |
| Navigation / tab labels | Sub-resources or nested routes |

**Do not** generate endpoints for purely decorative nodes (icons, dividers, illustrations).

### 1b. Read the Backend Artifacts

When the user references their project folder, read (in order):
1. The SQL schema file — column names, types, nullability, PKs, FKs
2. The JPA entity — field names, types, relationships (`@OneToMany`, etc.)
3. The repository interface — existing query method signatures
4. The service class — existing method names and signatures

Cross-reference Figma field names against entity field names to confirm mapping. If a Figma label doesn't match any entity field, call it out and ask before proceeding.

---

## Step 2 — Plan the API Surface

Before writing any code, output a **brief API plan** in this format and ask the user to confirm:

```
Resource: <EntityName>
Base route: /api/v1/<resource-plural-kebab>

Endpoints:
  GET    /api/v1/...            → list (paginated)
  GET    /api/v1/.../{id}       → get by id
  POST   /api/v1/...            → create
  PUT    /api/v1/.../{id}       → full update
  PATCH  /api/v1/.../{id}       → partial update   [include only if Figma has an "edit" partial flow]
  DELETE /api/v1/.../{id}       → delete

DTOs:
  <Entity>Request  — fields: ...
  <Entity>Response — fields: ...
```

Only proceed to code generation after the user confirms (or adjusts) the plan.

---

## Step 3 — Generate Code

Generate files in this order. Each file should be a complete Java class.

### 3a. ApiResponse wrapper

Generate once per project. Skip if the user says it already exists.

```java
package <basePackage>.common;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {

    private boolean success;
    private String message;
    private T data;

    public static <T> ApiResponse<T> ok(T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .message("OK")
                .data(data)
                .build();
    }

    public static <T> ApiResponse<T> created(T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .message("Created")
                .data(data)
                .build();
    }

    public static ApiResponse<Void> noContent() {
        return ApiResponse.<Void>builder()
                .success(true)
                .message("Deleted")
                .build();
    }

    public static <T> ApiResponse<T> error(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .build();
    }
}
```

### 3b. DTOs

**Request DTO** — fields come from form/input nodes in Figma + entity field types from JPA:
```java
package <basePackage>.dto.<resource>;

import jakarta.validation.constraints.*;
import lombok.Data;
import io.swagger.v3.oas.annotations.media.Schema;

@Data
@Schema(description = "Request payload for creating/updating <Entity>")
public class <Entity>Request {
    // one field per Figma form input, typed from JPA entity
    @NotBlank
    @Schema(description = "<field description>", example = "<example value>")
    private String <fieldName>;
    // ...
}
```

**Response DTO** — fields come from list/card/table display nodes in Figma:
```java
package <basePackage>.dto.<resource>;

import lombok.Data;
import io.swagger.v3.oas.annotations.media.Schema;

@Data
@Schema(description = "Response payload for <Entity>")
public class <Entity>Response {
    private Long id;
    // one field per Figma display element, typed from JPA entity
    @Schema(description = "<field description>")
    private <Type> <fieldName>;
    // ...
}
```

### 3c. Controller

```java
package <basePackage>.controller;

import <basePackage>.common.ApiResponse;
import <basePackage>.dto.<resource>.<Entity>Request;
import <basePackage>.dto.<resource>.<Entity>Response;
import <basePackage>.service.<Entity>Service;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.responses.ApiResponse as SwaggerApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/<resource-plural-kebab>")
@RequiredArgsConstructor
@Tag(name = "<Entity>", description = "Endpoints for managing <Entity> resources")
public class <Entity>Controller {

    private final <Entity>Service <entity>Service;

    @GetMapping
    @Operation(summary = "List all <entities>", description = "Returns a paginated list of <entities>")
    @ApiResponses({
        @SwaggerApiResponse(responseCode = "200", description = "List retrieved successfully")
    })
    public ResponseEntity<ApiResponse<Page<<Entity>Response>>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(<entity>Service.findAll(pageable)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get <entity> by ID")
    @ApiResponses({
        @SwaggerApiResponse(responseCode = "200", description = "Found"),
        @SwaggerApiResponse(responseCode = "404", description = "Not found")
    })
    public ResponseEntity<ApiResponse<<Entity>Response>> getById(
            @Parameter(description = "<Entity> ID") @PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(<entity>Service.findById(id)));
    }

    @PostMapping
    @Operation(summary = "Create a new <entity>")
    @ApiResponses({
        @SwaggerApiResponse(responseCode = "201", description = "Created successfully"),
        @SwaggerApiResponse(responseCode = "400", description = "Validation error")
    })
    public ResponseEntity<ApiResponse<<Entity>Response>> create(
            @Valid @RequestBody <Entity>Request request) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.created(<entity>Service.create(request)));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update <entity> by ID")
    @ApiResponses({
        @SwaggerApiResponse(responseCode = "200", description = "Updated successfully"),
        @SwaggerApiResponse(responseCode = "404", description = "Not found"),
        @SwaggerApiResponse(responseCode = "400", description = "Validation error")
    })
    public ResponseEntity<ApiResponse<<Entity>Response>> update(
            @PathVariable Long id,
            @Valid @RequestBody <Entity>Request request) {
        return ResponseEntity.ok(ApiResponse.ok(<entity>Service.update(id, request)));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete <entity> by ID")
    @ApiResponses({
        @SwaggerApiResponse(responseCode = "204", description = "Deleted successfully"),
        @SwaggerApiResponse(responseCode = "404", description = "Not found")
    })
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        <entity>Service.delete(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body(ApiResponse.noContent());
    }
}
```

### 3d. springdoc-openapi Dependency

**Maven (`pom.xml`)**:
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.5.0</version>
</dependency>
```

**Gradle (`build.gradle`)**:
```groovy
implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.5.0'
```

After adding the dependency, Swagger UI is available at:
`http://localhost:8080/swagger-ui.html`

No extra `@Configuration` class is required for basic setup.

---

## Step 4 — Surface Gaps and Assumptions

After generating code, always include a **"Gaps & Assumptions"** section listing:

- Any Figma fields that could not be mapped to an entity field (needs user clarification)
- Any inferred field types (e.g., assumed `String` for a label that could be an enum)
- Service methods called in the controller that don't yet exist in the provided service class (the user must implement them)
- Any relationships (e.g., nested objects) that may require additional DTOs or endpoints

---

## Conventions Reference

| Concern | Convention |
|---------|-----------|
| Base path | `/api/v1/<resource>` |
| Package root | `<basePackage>` inferred from entity package |
| Response wrapper | `ApiResponse<T>` in `<basePackage>.common` |
| DTOs location | `<basePackage>.dto.<resourceName>` |
| Controller location | `<basePackage>.controller` |
| Validation | `@Valid` on all `@RequestBody` params |
| Pagination | `Pageable` + `Page<T>` on list endpoints |
| HTTP status | `201` on POST, `200` on GET/PUT/PATCH, `204` on DELETE |
| Naming | `camelCase` fields, `PascalCase` classes, `kebab-case` routes |
| Lombok | `@Data`, `@Builder`, `@RequiredArgsConstructor` assumed available |

See `references/figma-json-guide.md` for tips on navigating Figma JSON exports.
