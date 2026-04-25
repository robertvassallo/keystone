# First Project Runbook

You — a Claude Code agent — are starting work on a **fresh project** based on this template. The repo currently holds workflow + standards docs only; there is no application code yet. This document is the explicit step-by-step path from "empty template" to "shipping the first feature."

Read in full **once** before taking any action. Then execute the phases in order.

## Pre-flight

Before doing anything, confirm:

1. The user has cloned this template into a project directory and reset its history if they want a fresh git log.
2. The dev tools are installed per `docs/01_architecture/dev-setup.md` (`node` ≥ 22, `pnpm` ≥ 9, `python3` ≥ 3.12, `uv`, plus either local `psql` 16 **or** Docker for the Compose path).
3. The user has run `cp .env.example .env` and filled in `DJANGO_SECRET_KEY`.
4. You've read `CLAUDE.md` — task router, hard rules, workflow.
5. You've read `docs/02_standards/project-structure.md` — the granularity principle.
6. You've read the standards docs that match the first feature's area.

If anything in the user's request conflicts with the hard rules in `CLAUDE.md`, **surface the conflict before proceeding**.

## Phase 1 — Establish the project basics

These are one-time bootstrap tasks. Do them in a single PR titled `chore: project bootstrap`.

### 1.1 Pick the project name and identity

Ask the user (one message, multiple questions):

- Project name — used for `package.json` `name`, Django `config` directory name (default: `config`), and DB name.
- Default tenant model — single-tenant (no `tenant_id`) or multi-tenant (per-account isolation via `tenant_id` + RLS)? See `docs/01_architecture/data-model.md`.
- License — MIT, Apache-2.0, proprietary?

Record the answers in `docs/04_ai/decisions-log.md` as the first new entry.

### 1.2 Workspace files

Create at the repo root:

- `package.json` — minimal, with `name`, `private: true`, `engines.node`: `>=22`, `packageManager`: `pnpm@9.x`.
- `pnpm-workspace.yaml` — declares `apps/*` and `packages/*`.
- `.env.example` — start from the template; replace placeholders. Document every var.
- `LICENSE` — chosen license text.

### 1.3 Scaffold `apps/api` (Django)

Use the granular layout from `docs/01_architecture/monorepo.md`. Create:

```
apps/api/
├── manage.py
├── pyproject.toml             # extends root tooling; lists Django + DRF + drf-spectacular + django-environ
├── config/
│   ├── __init__.py
│   ├── asgi.py / wsgi.py
│   ├── urls.py
│   └── settings/
│       ├── __init__.py
│       ├── base.py
│       ├── dev.py
│       ├── test.py
│       └── prod.py
└── apps/
    └── __init__.py            # empty namespace package
```

`config/settings/base.py` follows `docs/01_architecture/security.md` (no secrets, safe defaults). `prod.py` sets the hardening flags listed there.

Run `uv run python manage.py migrate` to confirm Django boots against an empty Postgres.

### 1.4 Scaffold `apps/web` (Next.js)

```
apps/web/
├── package.json
├── tsconfig.json              # strict + the additions in docs/02_standards/typescript.md
├── next.config.mjs            # security headers from docs/01_architecture/security.md
├── tailwind.config.ts         # extends @keystone/config preset (from packages/config)
├── postcss.config.mjs
└── src/
    ├── app/
    │   ├── layout.tsx
    │   ├── page.tsx           # placeholder root
    │   └── globals.css        # imports tokens.css and tailwind layers
    ├── features/              # empty; first feature lands in 1.6
    ├── shared/
    │   ├── ui/                # empty until first primitive needed
    │   ├── lib/
    │   │   └── cn.ts          # the only utility you'll definitely need
    │   └── hooks/
    └── styles/
```

Run `pnpm dev` to confirm `localhost:3000` renders.

### 1.5 Scaffold `packages/`

In order of "definitely needed first":

1. `packages/tokens/` — primitive + semantic token files; build script that emits `tokens.css`, `tailwind.preset.ts`, `tokens.d.ts`. See `docs/03_ux/design-tokens.md` for the schema.
2. `packages/config/` — shared `tailwind.preset.ts`, base `tsconfig.json`, ESLint flat-config preset.
3. `packages/ui/` — empty until the second feature needs a shared primitive.
4. `packages/types/` — empty until the OpenAPI client is generated.

### 1.6 Bootstrap PR — exit criteria

- [ ] `pnpm install` clean
- [ ] `uv sync` clean
- [ ] `pnpm dev` brings up Next.js on `:3000`
- [ ] `uv run python manage.py runserver` brings up Django on `:8000`
- [ ] `pnpm lint`, `ruff check .`, `tsc --noEmit`, `mypy .` all clean (no source code yet — they pass trivially)
- [ ] Decision recorded in `decisions-log.md`
- [ ] PR template fully filled in
- [ ] No secrets committed

Ship the bootstrap PR. **Do not bundle the first feature into it.**

## Phase 2 — First feature

After bootstrap merges, start the first user-visible feature. Pick something small enough to finish in a day — the goal is to validate the standards on real code, not to ship the dashboard.

Suggested first features (ranked):

1. **Authentication** — sign-up, log-in, log-out (Django sessions + a Next.js sign-in form). Touches every layer; validates auth.md, security.md, forms.md, react.md.
2. **Account list** — read-only list of accounts visible to the logged-in admin. Lighter than auth; validates the granular layout end-to-end.

### 2.1 Use `/new-feature`

Run the slash command. It walks through scope, plans, and produces the pre-merge checklist:

```
/new-feature accounts-list
```

Follow the standards docs it surfaces.

### 2.2 Create the Django app

Create one app per domain. For "accounts":

```
apps/api/apps/accounts/
├── __init__.py
├── apps.py                       # AppConfig
├── admin.py
├── urls.py
├── models/
│   ├── __init__.py               # re-exports
│   └── account.py                # one model
├── managers/
├── services/
├── selectors/
│   ├── __init__.py
│   └── list_accounts.py          # one function
├── api/
│   ├── views/
│   │   ├── __init__.py
│   │   └── account_list_view.py
│   ├── serializers/
│   │   ├── __init__.py
│   │   └── account_serializer.py
│   └── urls.py
├── migrations/
└── tests/
```

Add the app to `INSTALLED_APPS` in `config/settings/base.py`. Include the app's URLs in `config/urls.py`. Generate the initial migration with `manage.py makemigrations`. Run `migrate`. Write at least one test.

### 2.3 Create the Next.js feature folder

```
apps/web/src/features/accounts/
├── index.ts
├── types.ts
├── components/
│   └── AccountList/
│       ├── AccountList.tsx
│       ├── AccountList.test.tsx
│       └── index.ts
├── hooks/
└── api/
    └── listAccounts.ts            # calls the Django endpoint
```

Add a route in `app/(dashboard)/accounts/page.tsx` that imports from the feature.

### 2.4 Run the relevant subagents

Before requesting human review:

```
@semantic-html-auditor: review apps/web/src/features/accounts and the route page
@a11y-reviewer:         review same change set
@react-reviewer:        review same change set
@python-reviewer:       review apps/api/apps/accounts
@sql-reviewer:          review apps/api/apps/accounts (migrations + selectors)
```

Address blockers before opening the PR.

### 2.5 Pre-merge checklist

Use `docs/04_ai/review-checklist.md`. Don't skip; mark N/A for sections that don't apply.

## Phase 3 — Establish the cadence

Once Phase 2 ships, repeat the `/new-feature` workflow for every feature. The standards are now load-bearing — keep them updated when patterns evolve.

For any decision that wasn't pre-determined by the docs (a tradeoff you made, a library you picked, a deviation from the template), add an entry to `docs/04_ai/decisions-log.md` in the same PR.

## What NOT to do during the first project

- Don't build a full design system before the first feature ships. Add primitives to `packages/ui` only when a second consumer appears.
- Don't add CI / Docker / observability before there's anything to test or run. They're worth their weight only after some code exists.
- Don't introduce new docs unless an existing one is wrong or incomplete.
- Don't skip the subagent reviews — they're the cheapest part of the loop.
- Don't ship a 1000-line PR. Split.

## When to escalate to the user

Pause and ask the user before:

- Choosing a multi-tenancy strategy (1.1).
- Picking the auth flow if it's not Django sessions (`docs/01_architecture/auth.md`).
- Adding a new top-level dependency that solves a problem the docs didn't anticipate.
- Diverging from any **hard rule** in `CLAUDE.md`.
- Any change that touches secrets, payments, or PII.

The rest you can decide using the standards docs.
