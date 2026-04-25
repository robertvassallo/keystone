#!/usr/bin/env bash
# PostToolUse hook for Edit/Write — format the file Claude just touched.
# Receives the tool-call payload as JSON on stdin; we extract `tool_input.file_path`.
# Exits 0 even on error: a missing formatter must never block Claude.

set -u

# Need jq to parse the stdin payload. If absent, no-op.
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

file_path="$(jq -r '.tool_input.file_path // empty')"
[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.jsonc|*.css|*.scss|*.html|*.md|*.mdx|*.yml|*.yaml)
    command -v prettier >/dev/null 2>&1 && prettier --write --log-level=silent "$file_path" 2>/dev/null || true
    ;;
  *.py)
    command -v ruff >/dev/null 2>&1 && ruff format --quiet "$file_path" 2>/dev/null || true
    ;;
  *.sql)
    command -v sqlfluff >/dev/null 2>&1 && sqlfluff fix --disable-progress-bar "$file_path" 2>/dev/null || true
    ;;
esac

exit 0
