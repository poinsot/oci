# Figma JSON Export — Navigation Guide

This guide explains the structure of a Figma JSON export and how to extract
API-relevant information from it.

## How to Export from Figma

1. Open your Figma file
2. Go to **Plugins →** or use the Figma REST API
3. For a local export: use the **"Export"** option on a frame, or use the
   community plugin **"Figma to JSON"** / **"Design Tokens"**
4. The result is a nested JSON tree rooted at a `document` node

---

## Top-Level Structure

```json
{
  "document": { ... },       // root canvas
  "components": { ... },     // reusable components library
  "styles": { ... },         // color/text styles
  "name": "My File",
  "version": "..."
}
```

Navigate into `document.children` → `CANVAS` nodes → `children` → `FRAME` nodes
(these are your screens).

---

## Key Node Types and What They Mean for APIs

| `type` value | UI element | API implication |
|---|---|---|
| `FRAME` | A screen or container | One controller per top-level FRAME |
| `TEXT` | A label or heading | Field name, button label, column header |
| `INSTANCE` | Component instance (button, input, card) | Check `name` for semantic meaning |
| `RECTANGLE` / `VECTOR` | Visual decoration | Ignore for API purposes |
| `GROUP` | Logical grouping | Traverse children; group `name` may hint at resource |
| `COMPONENT` | Reusable component definition | Check if it's a form, table, or card |

---

## Extracting Field Names

Text nodes contain the actual label text:

```json
{
  "type": "TEXT",
  "name": "Email Address",
  "characters": "Email Address"
}
```

Use `characters` (the displayed text) to infer the field name:
- `"Email Address"` → `email` (camelCase, strip spaces)
- `"First Name"` → `firstName`
- `"Date of Birth"` → `dateOfBirth`

---

## Identifying Forms (Request DTOs)

Look for frames/groups whose `name` contains: `"Form"`, `"Modal"`, `"Dialog"`,
`"Create"`, `"Edit"`, `"Add"`, `"Input"`.

Within them, TEXT children whose siblings are `RECTANGLE` (input box background)
or `INSTANCE` (input component) are form fields → become `*Request` DTO fields.

---

## Identifying Display Data (Response DTOs)

Look for frames/groups whose `name` contains: `"List"`, `"Table"`, `"Card"`,
`"Detail"`, `"View"`, `"Row"`, `"Item"`.

TEXT children inside these are display fields → become `*Response` DTO fields.

---

## Identifying CRUD Intent from Button Labels

| Button `characters` | HTTP Method | Status |
|---|---|---|
| Save, Create, Add, Submit, New | `POST` | 201 |
| Edit, Update, Modify | `PUT` or `PATCH` | 200 |
| Delete, Remove, Archive | `DELETE` | 204 |
| Search, Filter, Find | `GET` with query params | 200 |
| View, Open, Detail | `GET /{id}` | 200 |
| List, All, Browse | `GET` (paginated) | 200 |

---

## Handling Nested / Relational Data

If a card or table row contains a **sub-section** with its own list (e.g.,
"Order Items" inside an "Order" screen), this signals:
- A nested resource: `/api/v1/orders/{id}/items`
- Or an embedded DTO field: `List<OrderItemResponse>` inside `OrderResponse`

Choose embedded DTO if the sub-data is always fetched with the parent.
Choose nested route if the sub-data can be managed independently.

---

## Common Pitfalls

- **Icon-only buttons**: buttons with no `characters` child are icon buttons —
  infer intent from the parent frame name or sibling label.
- **Placeholder text**: inputs often show placeholder text like `"Enter email..."` —
  strip the prefix and use the core noun (`email`).
- **Repeated components**: a list of identical `INSTANCE` nodes is a table row —
  only extract fields once.
- **Tabs**: top-level tab components often map to **separate endpoints or
  query parameters**, not separate controllers.
