# API Conventions

How HTTP endpoints are shaped, named, versioned, and how they respond. Backend is Django + DRF; frontend consumes via a generated TypeScript client.

## URL structure

```
/api/v<MAJOR>/<resource>/                       list  / create
/api/v<MAJOR>/<resource>/<id>/                  detail / update / delete
/api/v<MAJOR>/<resource>/<id>/<sub-resource>/   nested
/api/v<MAJOR>/<resource>/<id>:<action>/         non-CRUD verb (rare)
```

- `MAJOR` — single integer, starts at `1`. Bumped only on breaking changes.
- Resources: lower-snake-case nouns, **plural** (`accounts`, `project_milestones`).
- IDs: UUID v7, embedded in path.
- Trailing slash always (Django convention; configure DRF to enforce).
- Non-CRUD actions: `POST /api/v1/projects/<id>:archive/` — colon separates the verb. Keep these rare; prefer state changes via `PATCH`.

## HTTP methods

| Method | Use | Idempotent |
|---|---|---|
| `GET` | List, retrieve | yes |
| `POST` | Create, action | no |
| `PUT` | Full replace (rare; use `PATCH`) | yes |
| `PATCH` | Partial update | no (DRF default) |
| `DELETE` | Delete (or soft-delete) | yes |

`HEAD` and `OPTIONS` are wired by DRF automatically.

## Status codes

| Code | When |
|---|---|
| `200 OK` | Success with body |
| `201 Created` | Resource created (return the new resource) |
| `202 Accepted` | Async work queued |
| `204 No Content` | Success with no body (DELETE, idempotent action) |
| `400 Bad Request` | Validation failure |
| `401 Unauthorized` | Not authenticated |
| `403 Forbidden` | Authenticated but not authorised |
| `404 Not Found` | Resource doesn't exist or user can't see it |
| `409 Conflict` | State mismatch (optimistic-locking failure, duplicate) |
| `422 Unprocessable Entity` | Domain rule failure (quota, business invariant) |
| `429 Too Many Requests` | Rate-limited |
| `500 Internal Server Error` | Unexpected; never includes stack |

For tenant isolation, **return `404` rather than `403`** when a user attempts to access another tenant's resource — don't leak existence.

## Error response shape

Every non-2xx response uses **RFC 7807 Problem Details (JSON)**:

```json
{
  "type": "https://errors.example.com/validation",
  "title": "Validation failed",
  "status": 400,
  "detail": "One or more fields were invalid.",
  "instance": "/api/v1/projects/",
  "request_id": "req_01HXYZ...",
  "errors": {
    "name": ["This field may not be blank."],
    "due_date": ["Date has an invalid format. Use YYYY-MM-DD."]
  }
}
```

- `type` — stable URL identifier for the error class (used by clients to switch behaviour).
- `title` — human-readable summary; stable for a given `type`.
- `status` — repeats the HTTP status.
- `detail` — context for this specific occurrence; safe to display.
- `instance` — request path.
- `request_id` — correlates to logs; safe to display to users for support.
- `errors` — present on `400` validation failures. Field name → list of messages. Nested objects use dotted paths (`address.postal_code`).

Implementation: a DRF exception handler maps Django + DRF exceptions to this shape. See `docs/01_architecture/security.md` for what fields **never** appear (no stack traces, no SQL, no full PII).

## Successful responses

### Single resource

```json
{
  "id": "01HXYZ...",
  "name": "Acme Project",
  "status": "active",
  "created_at": "2026-04-24T18:42:11Z",
  "updated_at": "2026-04-24T18:42:11Z"
}
```

- ISO-8601 UTC timestamps with `Z` suffix.
- IDs always strings (UUIDs), never numbers.
- Money: `{ "amount_cents": 1234, "currency_code": "USD" }`.
- Enums as strings, lowercase snake (`active`, `archived`).
- `null` for absent values, **not** missing keys (response shape stable).

### List response

```json
{
  "data": [ { ... }, { ... } ],
  "page": {
    "next_cursor": "eyJpZCI6Ii4uLiJ9",
    "prev_cursor": null,
    "total": 142,
    "page_size": 25
  }
}
```

- Cursor pagination by default (see `docs/02_standards/sql.md`). `next_cursor` / `prev_cursor` are opaque strings.
- `total` is the count after filters; can be `null` for very large or expensive lists.

## Filtering, sorting, search

| Param | Convention | Example |
|---|---|---|
| Filter | Query param matching a field name | `?status=active&account_id=01HX...` |
| Multiple values | Repeated param **or** comma-separated | `?status=active&status=draft` |
| Range | `<field>__gte` / `<field>__lte` | `?created_at__gte=2026-04-01` |
| Search | `q=<term>` | `?q=acme` |
| Sort | `sort=<field>` (prefix `-` for desc) | `?sort=-created_at` |
| Multi-sort | Comma-separated | `?sort=-status,name` |
| Cursor | `cursor=<opaque>` | `?cursor=eyJp...` |
| Page size | `page_size=<n>` (max 100) | `?page_size=50` |

Filtering is **opt-in** per field — list the filterable fields explicitly in the view, never accept arbitrary query params as filters.

## Versioning

- Path-based major version (`/api/v1/...`).
- Breaking changes → new version. Non-breaking (additive fields, new endpoints, new optional params) → same version.
- Keep one previous major in production until clients migrate; document the deprecation date in `decisions-log.md`.
- `Deprecation` and `Sunset` HTTP response headers on endpoints scheduled for removal.

## Schema generation

- **drf-spectacular** generates the OpenAPI 3.1 schema from DRF views + serializers.
- Schema served at `/api/schema/`; Swagger UI at `/api/docs/` (dev only).
- The frontend's `packages/types` regenerates a typed client from this schema (`openapi-typescript`). Regen is a CI step; the generated file is committed.

## Authentication

- Same-origin frontend: **DRF SessionAuthentication + CSRF** (default for the dashboard).
- Non-browser clients: **TokenAuthentication** with hashed tokens (see `docs/01_architecture/auth.md`).
- Every API view declares its `permission_classes` and `authentication_classes` explicitly — no relying on global defaults.

## Rate limiting

- DRF throttle classes per scope:
  - `anon` — 60 req/min/IP
  - `user` — 600 req/min/user
  - `auth` — 5 req/min/IP for login + signup endpoints
- 429 responses include a `Retry-After` header.

## Idempotency

- `GET`, `PUT`, `DELETE` are idempotent by definition.
- For `POST` operations that must be safely retryable (payments, sends), accept an `Idempotency-Key` request header; cache the response for 24 h keyed on `(user, endpoint, key)`.

## Pagination edge cases

- Empty result: `data: [], page.total: 0`.
- Cursor invalid: `400` with `type: ".../invalid_cursor"`.
- Page beyond data: empty `data`, no `next_cursor`.

## Webhooks

- Outbound webhooks (when added) sign payloads with HMAC-SHA-256 over the raw body, header `X-Signature: t=<ts>,v1=<hex>`.
- Retry with exponential backoff for 5xx + 429 responses for 24 h.
- Document the signing scheme and event shapes alongside the producing service.

## Anti-patterns

| Don't | Do |
|---|---|
| Verbs in URLs (`/getProject/`, `/createUser/`) | Resource + HTTP method |
| Mixing query and body for the same intent | Body for write, query for filter |
| Returning different shapes for "list of one" vs "single" | Always the list shape on list endpoints |
| Numeric IDs in JSON | UUID strings |
| `created_at` as a Unix timestamp | ISO-8601 with `Z` |
| Stack traces in error responses | Generic message + `request_id` |
| `403` for tenant isolation breach | `404` (don't leak existence) |
| Catching all exceptions and returning `200 { ok: false }` | Use the right HTTP status |

## Review checklist

- [ ] URL is plural lower-snake-case noun + UUID + (optional) sub-resource
- [ ] HTTP method matches semantics; status code matches outcome
- [ ] Error response is RFC 7807 with `request_id`
- [ ] Tenant-isolation errors return `404`, not `403`
- [ ] List responses use cursor pagination + the `data`/`page` shape
- [ ] Permission + authentication classes declared on the view
- [ ] Throttle scope set
- [ ] Schema appears in `/api/schema/` after the change
- [ ] Frontend client regenerated and committed
- [ ] Idempotency key honoured if the endpoint must support retry
