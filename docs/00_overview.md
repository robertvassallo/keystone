# Overview

A guided tour of the docs tree. Start here if you've cloned the template and want to understand what's where before you build.

## How the docs are organised

```
docs/
├── 00_overview.md          ← you are here
├── 01_architecture/        ← what we're building on
├── 02_standards/           ← how we write code
├── 03_ux/                  ← how the UI behaves
└── 04_ai/                  ← how AI agents (and humans) collaborate
```

- **`01_architecture`** — load-bearing facts about the stack and the system shape. Read once, refer back when you're touching infrastructure or making cross-cutting choices.
- **`02_standards`** — the rules you write code against. The reviewer subagents enforce these.
- **`03_ux`** — the rules you design against. The form, the table, the empty state.
- **`04_ai`** — how to get good work out of Claude Code, what subagents exist, and the canonical pre-merge checklist.

## A new contributor's path

1. **`CLAUDE.md`** — the AI working agreement, hard rules, and task router.
2. **`docs/00_overview.md`** — this file.
3. **`docs/01_architecture/stack.md`** — what we picked and why.
4. **`docs/01_architecture/monorepo.md`** — where things live.
5. **`docs/02_standards/git-workflow.md`** — branch / commit / PR conventions.
6. **`docs/02_standards/project-structure.md`** — modular & granular file/folder principle (applies to every part of the codebase).
7. The standards docs that match the area you'll touch.

## A new project's path (Claude on day 1)

1. **`docs/01_architecture/dev-setup.md`** — install the toolchain; verify with the listed checks.
2. **`docs/04_ai/first-project.md`** — read fully before doing anything.
3. `/scaffold-app` — bootstrap the workspaces (one-time, before any feature).
4. Land the bootstrap PR; verify all lint / type / test commands run clean against the empty scaffolding.
5. Move to "A new feature's path" below.

## A new feature's path

1. `/new-feature <slug>` — the slash command opens a branch and walks through scope.
2. Read the relevant standards docs (the slash command tells you which).
3. Plan, implement, self-review.
4. Run the matching reviewer subagent (`@react-reviewer`, `@sql-reviewer`, `@a11y-reviewer`, etc.).
5. Open a PR using `.github/pull_request_template.md` — checks off `docs/04_ai/review-checklist.md`.

## When to update the docs

- A standards doc is **wrong** or **outdated** → update it before merging the change that exposed the issue.
- A non-obvious decision was made → entry in `docs/04_ai/decisions-log.md`.
- A pattern has repeated 3+ times → consider adding to a standards doc or extracting to a shared package.
- A new agent or slash command would help → propose it; don't add silently.

## Conventions across the docs

- Each standards doc ends with a **Review checklist** that mirrors what the matching agent enforces.
- Each architecture doc gives the **why** before the **what** — context first, mechanics second.
- Cross-references link to the file, not the section anchor (paths are stabler than anchor text).
- No content is duplicated across docs — one source of truth per topic.

## When something contradicts

If two docs conflict:

1. **Hard rules in `CLAUDE.md`** win.
2. Otherwise, the **more specific doc** wins (e.g. `react.md` over `javascript.md`).
3. Resolve the conflict by editing one of them — don't leave it for the next reader.

## What this template doesn't cover

- Specific business logic or domain models — those land per-project in `apps/`.
- Operational runbooks (deploys, incident response) — those land in `infra/` once an app exists.
- Personal coding preferences — codified rules only.

If you find yourself wishing for a doc that doesn't exist, open a PR adding it. Keep it tight, match the existing style, and end it with a review checklist.
