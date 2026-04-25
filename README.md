# Keystone — Full-Stack Starter

A reusable starter for full-stack web and dashboard projects. Carries the AI workflow, baseline configuration, and standards docs you want present from day one — no application code yet.

> The keystone is the central wedge that locks an arch in place. This template is the piece every project built on it rests on.

## What you get

- **AI workflow** — Claude Code config, five reviewer subagents, slash commands
- **Standards docs** — semantic HTML, CSS/SASS, Tailwind, JavaScript, TypeScript, React, Python (Django), SQL (Postgres), accessibility, testing, git workflow
- **Architecture docs** — stack, monorepo layout, data model, security, auth
- **UX docs** — design tokens, dashboard layout, forms, data display
- **Tooling configs** — ESLint flat config, Prettier, Stylelint, SQLFluff, ruff + mypy
- **Editor + GitHub** — VS Code workspace settings, recommended extensions, debug configs, PR + issue templates

## Stack

| Layer | Choice |
|---|---|
| Frontend | Next.js 15 (App Router) + React 19 + TypeScript |
| Styling | Tailwind 3 + SCSS modules + design tokens |
| Backend | Django 5 + DRF + Python 3.12 |
| Database | Postgres 16 |
| Package managers | pnpm + uv |

Detail and rationale: `docs/01_architecture/stack.md`.

## How to use this template

```bash
# Clone as a starting point
git clone <this-repo>.git my-new-project
cd my-new-project

# Reset history (optional — start fresh)
rm -rf .git && git init -b main

# Open in VS Code; install recommended extensions when prompted
code .
```

Read `CLAUDE.md` for the AI working agreement, then open `docs/00_overview.md` for a guided tour.

For the canonical install commands (Linux / macOS / WSL) and the Docker path for the dev DB, see `docs/01_architecture/dev-setup.md`.

## Layout

```
.
├── CLAUDE.md              # AI agreement + task router (read first)
├── README.md              # this file
├── .claude/               # Claude Code config + agents + commands
├── .vscode/               # editor workspace
├── .github/               # PR + issue templates
├── docs/
│   ├── 00_overview.md     # narrative guide to the doc tree
│   ├── 01_architecture/   # stack, monorepo, data-model, security, auth
│   ├── 02_standards/      # semantic-html, css-sass, tailwind, js, ts, react, python, sql, a11y, testing, git
│   ├── 03_ux/             # design tokens, dashboard layout, forms, data display
│   └── 04_ai/             # prompting, agents, review checklist, decisions log
└── (lint/format configs at root)
```

## What's intentionally NOT here yet

- Application code (`apps/web`, `apps/api`)
- CI workflows
- License (choose per-project)

These are deferred until the first real project lands. `docs/01_architecture/monorepo.md` describes the target shape.

## Adding to this template

1. Make the change.
2. Update the relevant standards doc.
3. Add a `decisions-log.md` entry if it's non-obvious.
4. PR with the standard checklist.

## Tooling expected on the dev machine

- Node 22 LTS · pnpm 9 · Python 3.12 · uv · Postgres 16 (or Docker) · VS Code

Full install commands for Linux / macOS / WSL plus a Docker path for the dev DB live in `docs/01_architecture/dev-setup.md`.

## License

Add a `LICENSE` file when you fork this template for a real project.
