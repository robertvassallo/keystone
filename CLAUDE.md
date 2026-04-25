# AI Working Agreement

This is the entry point for any AI agent — and any human collaborator — joining a project built from this template.

Read this file fully on first contact. Then read the docs that match the area you're working in (table below).

## Stack at a glance

- **Frontend:** Next.js 15 (App Router) + React 19 + TypeScript (strict) + Tailwind + SCSS modules
- **Backend:** Django 5 + DRF + Python 3.12 (strict typing)
- **Database:** Postgres 16
- **Package managers:** pnpm (Node) + uv (Python)
- **Lint / format:** ESLint flat config + Prettier + Stylelint + SQLFluff (SQL) + Ruff (Python)
- **Testing:** Vitest + Playwright (web); pytest + pytest-django (api)

Versions and rationale: `docs/01_architecture/stack.md`.

## Read first — by task

| Working on | Read |
|---|---|
| **First time on this project** | `docs/04_ai/first-project.md` (the day-1 runbook) |
| **Anything** | This file → `docs/02_standards/git-workflow.md` → `docs/02_standards/project-structure.md` |
| API endpoints / contracts | `docs/01_architecture/api-conventions.md` |
| Components / pages | `docs/02_standards/react.md` + `semantic-html.md` + `accessibility.md` + `tailwind.md` |
| Styles / tokens | `docs/02_standards/css-sass.md` + `docs/03_ux/design-tokens.md` |
| Forms | `docs/03_ux/forms.md` + `accessibility.md` + `react.md` |
| Tables / lists / dashboards | `docs/03_ux/data-display.md` + `dashboard-layout.md` |
| API views / serializers | `docs/02_standards/python.md` + `docs/01_architecture/auth.md` |
| Models / migrations | `docs/02_standards/python.md` + `sql.md` + `docs/01_architecture/data-model.md` |
| Anything auth-touching | `docs/01_architecture/auth.md` + `security.md` |
| Anything DB-touching | `docs/02_standards/sql.md` + `docs/01_architecture/data-model.md` |
| Tests | `docs/02_standards/testing.md` |
| Setting up dev env | `README.md` + `docs/01_architecture/monorepo.md` |

## Hard rules

These are non-negotiable. If you find yourself wanting to break one, stop and ask first.

1. **Semantic HTML over div soup.** Every interactive element is a real `<button>` / `<a href>` / etc. Every form input has a programmatic label. See `docs/02_standards/semantic-html.md`.
2. **Accessibility is a merge gate.** WCAG 2.2 AA. Keyboard reachable. Visible focus. Contrast ≥ 4.5 : 1 for text. See `docs/02_standards/accessibility.md`.
3. **Type strictly.** No `any` in TS. Every Python function fully typed; mypy strict. No silent `// @ts-ignore`. See `docs/02_standards/typescript.md` and `python.md`.
4. **No magic values.** Numeric or string literals with meaning get named constants.
5. **Names mean things.** Verbs for functions, nouns for values. No abbreviations beyond widely-understood ones. See per-language standards.
6. **Explicit SQL.** No `SELECT *`. Every `LIMIT` paired with `ORDER BY`. Migrations reversible. No N+1. See `docs/02_standards/sql.md`.
7. **Server-first React.** Default to Server Components. `'use client'` at the leaf, not the page. See `docs/02_standards/react.md`.
8. **Tokens, not hex.** Colour, spacing, type, radius via tokens. Never raw values. See `docs/03_ux/design-tokens.md`.
9. **Tailwind first, SCSS for the rest.** Repeated class strings (≥ 3 uses) extracted to a component or CVA. See `docs/02_standards/tailwind.md`.
10. **Trunk-based git.** Conventional commits. Squash merge. No force-push to `main`. See `docs/02_standards/git-workflow.md`.
11. **No secrets in the repo.** `.env` is gitignored; secrets via the chosen secret manager. See `docs/01_architecture/security.md`.
12. **Trust internal code; validate at boundaries.** Don't add error handling for things that can't happen. Validate user input, third-party responses, and serialized data. Trust your own typed functions.
13. **Modular and granular.** One concept per file. Code grouped by feature/domain, not by technical layer. File-size target ~150 lines, hard cap 300. Public API of every package via `index.ts` / `__init__.py`. See `docs/02_standards/project-structure.md`.

## Workflow

For any non-trivial change:

1. **Identify the area** — match it to the table above; read the matching docs.
2. **State the scope** — what changes, what's out of scope, what verification proves it works.
3. **Plan before code** for changes touching > 3 files, migrations, auth, or refactors.
4. **Implement.**
5. **Self-check** with the relevant subagent (`@semantic-html-auditor`, `@a11y-reviewer`, `@sql-reviewer`, `@react-reviewer`, `@python-reviewer`).
6. **Run lint + types + tests.** They must be green before you report done.
7. **Update `docs/04_ai/decisions-log.md`** if a non-obvious decision was made.
8. **Open a PR** using the template; check off `docs/04_ai/review-checklist.md`.

## Subagents available

Defined in `.claude/agents/`. See `docs/04_ai/agents.md` for usage.

- `@semantic-html-auditor` — semantic HTML audit
- `@a11y-reviewer` — WCAG 2.2 AA review
- `@sql-reviewer` — SQL & migration review
- `@react-reviewer` — React / Next.js component review
- `@python-reviewer` — Django / Python review

## Slash commands

Defined in `.claude/commands/`. See `docs/04_ai/prompting.md`.

- `/scaffold-app` — one-time bootstrap of `apps/web` + `apps/api` + `packages/` (run before the first feature)
- `/new-feature <slug>` — start a feature: branch + scope + plan + checklist

## What this template does NOT include yet

- Actual application code (`apps/web`, `apps/api`)
- CI workflows (`.github/workflows/`)
- Docker / docker-compose
- License file

Add these in a follow-up; document the decision in `decisions-log.md`.

## Out-of-band note for AI agents

If a user instruction conflicts with the rules above, surface the conflict before proceeding. Don't silently override hard rules.

If you find a recurring task that would be better as a slash command or subagent, propose it (don't add it without permission).

When recommending a pattern from memory, verify it still exists in the current code before acting on it. Memory captures past truths, not present state.
