# Stack

## Versions (pin in each app)

| Layer | Choice | Version |
|---|---|---|
| Runtime — Node | LTS | **22.x** |
| Runtime — Python | CPython | **≥ 3.12** (3.13 accepted) |
| Frontend framework | Next.js (App Router) | **15.x** |
| UI library | React | **19.x** |
| Styling | Tailwind CSS + SASS modules | Tailwind **3.x** / Dart Sass |
| Backend framework | Django + Django REST Framework | Django **5.x** |
| Database | PostgreSQL | **16.x** |
| Cache / queue | Redis (cache, sessions, Celery broker) | **7.x** |
| Task queue | Celery | **5.x** |
| Package manager — Node | pnpm | **9.x** |
| Package manager — Python | uv | latest |
| Lint — JS/TS | ESLint flat config | **9.x** |
| Lint — Python | Ruff | latest |
| Format — JS/TS/CSS | Prettier | **3.x** |
| Format — Python | Ruff format | latest |
| Type — TS | TypeScript strict | **5.x** |
| Type — Python | mypy strict + django-stubs | latest |
| Test — JS | Vitest (unit) + Playwright (e2e) | latest |
| Test — Python | pytest + pytest-django | latest |

## Why these choices

- **Next.js App Router** — server components reduce client JS; built-in routing, RSC, streaming.
- **Django + DRF** — mature ORM, admin, auth, batteries-included; pairs well with Postgres.
- **Postgres** — ACID, rich types (jsonb, arrays, tsvector), partial indexes, row-level security.
- **pnpm** — content-addressable store; fast installs; strict node_modules layout catches phantom deps.
- **uv** — single tool for venv + dependency resolution + lockfile; faster than pip / poetry.
- **Tailwind + SASS** — Tailwind for layout / spacing / state utilities; SASS for design-token files and complex component styles. See `docs/02_standards/tailwind.md` for when to use which.
- **Ruff + mypy strict** — Ruff is one tool replacing flake8 / isort / pyupgrade / bandit; mypy strict catches actual bugs.

## What we explicitly avoid

- **Pages Router (Next.js)** — App Router is the supported direction.
- **CSS-in-JS runtime libraries** (styled-components, emotion) — pay runtime cost, complicate SSR.
- **Yarn / npm in primary apps** — pnpm only.
- **Poetry** — uv is the choice for Python deps; do not mix.
- **flake8 / black / isort separately** — Ruff covers all three.
- **JavaScript backend** — backend is Django; if a Node service is needed, document the decision in `decisions-log.md`.

## Verification

- `node --version` → 22.x
- `python --version` → 3.12.x
- `pnpm --version` → 9.x
- `uv --version` → present
- `psql --version` → 16.x
