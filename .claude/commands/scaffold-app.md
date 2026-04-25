---
description: Bootstrap the apps/web (Next.js) and apps/api (Django) workspaces. Run once per project, before the first feature.
argument-hint: ""
---

You are bootstrapping the application workspaces in a fresh project based on this template. This is the **one-time bootstrap** described in `docs/04_ai/first-project.md` (Phase 1).

## Pre-flight

Run these checks first; fail fast if any are wrong.

1. `apps/` directory does **not** yet exist (or contains no `web` / `api` subdirectory). If it does, ask the user before continuing — they may already have started.
2. Required tools on PATH: `node` (≥ 22), `pnpm` (≥ 9), `python3` (≥ 3.12), `uv`, plus **either** `psql` (≥ 16) locally **or** `docker` (the Compose path lives at `infra/docker/compose.dev.yml`). If anything is missing, list it and stop — point the user at `docs/01_architecture/dev-setup.md` for OS-specific install commands.
3. `.env.example` exists at the repo root. If not, create it from the template.

## Phase A — Repo-level workspace files

Create these at the root if they don't exist:

- `package.json`
  - `name`: ask user; default to the directory name
  - `private: true`
  - `engines: { "node": ">=22" }`
  - `packageManager: "pnpm@9.x"` (use latest 9 minor)
  - empty `scripts: {}` for now
- `pnpm-workspace.yaml`
  - `packages: ["apps/*", "packages/*"]`
- `.env` (copy from `.env.example`; mark to fill in)
- `LICENSE` (ask user for license; default MIT)

## Phase B — `apps/api` (Django)

Read `docs/01_architecture/monorepo.md`, `docs/02_standards/python.md`, `docs/02_standards/project-structure.md` first.

Create the structure exactly as specified in `docs/04_ai/first-project.md` §1.3. Specifically:

1. `uv init --no-readme --package apps/api` then add deps:
   `uv add --project apps/api django djangorestframework drf-spectacular django-environ structlog`
   `uv add --project apps/api --dev pytest pytest-django factory_boy mypy django-stubs`
2. `apps/api/manage.py` — standard Django entry point pointed at `config.settings`.
3. `apps/api/config/settings/{base,dev,test,prod}.py` — split per `docs/01_architecture/security.md`. `base.py` reads env via `django-environ`, no secrets. `prod.py` has the hardening flags.
4. `apps/api/config/urls.py` — root urlconf with `/api/v1/` mount and `/api/schema/` (drf-spectacular).
5. `apps/api/apps/__init__.py` — empty namespace package.

**Verify:** `uv run --project apps/api python manage.py migrate` succeeds against an empty Postgres named per `.env`.

## Phase C — `apps/web` (Next.js)

Read `docs/02_standards/react.md`, `docs/02_standards/typescript.md`, `docs/02_standards/tailwind.md`, `docs/02_standards/project-structure.md` first.

1. `pnpm create next-app@latest apps/web --ts --eslint --tailwind --app --src-dir --import-alias '@/*' --no-turbopack`
   - Strip the boilerplate page content and example files (don't ship the Next.js demo page).
2. Replace generated `eslint.config.mjs` with import from the root `eslint.config.mjs` (or extend it).
3. Replace generated `tailwind.config.ts` with one that consumes `packages/config/tailwind.preset.ts` once that package exists (Phase D); for now, scaffold a minimal config.
4. Configure `tsconfig.json` with the strict flags listed in `docs/02_standards/typescript.md`.
5. Add the security headers from `docs/01_architecture/security.md` to `next.config.mjs` `headers()`.
6. Create the empty feature/shared folders per `docs/02_standards/project-structure.md`:
   - `src/features/.gitkeep`
   - `src/shared/{ui,lib,hooks}/.gitkeep`
   - `src/shared/lib/cn.ts` (the one utility you need from day one)
7. Replace `app/page.tsx` with a minimal landing page that reads "Project bootstrap complete."

**Verify:** `pnpm --filter web dev` starts; `localhost:3000` shows the placeholder; `pnpm --filter web exec tsc --noEmit` passes.

## Phase D — `packages/`

Create the packages most likely needed first:

1. `packages/tokens/` — primitive + semantic tokens per `docs/03_ux/design-tokens.md`. Build script emits `dist/tokens.css`, `dist/tailwind.preset.ts`, `dist/tokens.d.ts`.
2. `packages/config/` — shared `tsconfig.base.json`, `eslint.preset.js`, `tailwind.preset.ts` (re-exports tokens).

Skip `packages/ui/` and `packages/types/` — create on first need.

**Verify:** `pnpm install` clean across the workspace.

## Phase E — Wire it together

1. Wire `apps/web/tailwind.config.ts` to `packages/config/tailwind.preset.ts`.
2. Wire `apps/web/src/app/globals.css` to `packages/tokens/dist/tokens.css` plus the Tailwind layers.
3. Wire `apps/api/config/settings/base.py` to read all env vars via `django-environ` from `.env`.
4. Add a top-level `package.json` `scripts` for the common dev tasks (`dev`, `build`, `lint`, `typecheck`, `test`) using `pnpm -r run` and `uv run --project apps/api ...`.

**Verify all of the following pass:**
```
pnpm install
uv sync
pnpm -r lint
pnpm -r exec tsc --noEmit
uv run --project apps/api ruff check .
uv run --project apps/api mypy .
uv run --project apps/api python manage.py check
uv run --project apps/api pytest
```

## Phase F — Open the bootstrap PR

- Branch: `chore/bootstrap`
- Commit: `chore: bootstrap workspaces (apps/web + apps/api + packages)`
- PR body: list everything created. Test plan = the verification commands above.
- Add an entry to `docs/04_ai/decisions-log.md` recording the chosen project name, multi-tenancy strategy, and license.

## Stop conditions — pause and ask the user

- Multi-tenancy strategy not yet decided (`docs/01_architecture/data-model.md` lists options).
- Secrets manager not yet picked.
- Auth flow other than Django sessions needed.
- Any verification step in Phase E fails for a reason that's not a typo.

Do not proceed to Phase 2 (first feature) in the same PR. The bootstrap merges first.
