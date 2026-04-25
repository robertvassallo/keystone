# Dev Setup

The single source of truth for getting a clone of this template ready to run. If you're scaffolding a new project, `/scaffold-app` runs the same checks automatically.

## Required tools

| Tool | Version | Why |
|---|---|---|
| **Node** | ≥ 22 LTS | Next.js 15 + React 19 |
| **pnpm** | ≥ 9 | Workspace manager |
| **Python** | ≥ 3.12 | Django + Ruff + mypy |
| **uv** | latest | Python package manager |
| **Postgres 16** *or* **Docker** | — | DB; install locally **or** run via Compose |

The repo ships with `.nvmrc` (Node) and `.python-version` (uv) — both tools auto-detect when you `cd` in.

## Install — Linux (Ubuntu / Debian / WSL)

```bash
# Node — via nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
exec $SHELL                       # reload shell so nvm is on PATH
nvm install 22 && nvm use 22      # picks up .nvmrc going forward

# pnpm — via Corepack (ships with Node)
corepack enable
corepack prepare pnpm@latest --activate

# uv — official installer
curl -LsSf https://astral.sh/uv/install.sh | sh
exec $SHELL

# Python 3.12 — let uv manage it
uv python install 3.12

# Postgres — pick ONE of:
sudo apt install -y postgresql-16 postgresql-client-16   # local install
# ── or ──
sudo apt install -y docker.io docker-compose-plugin      # use Docker (see below)
```

## Install — macOS

```bash
# Node
brew install nvm
nvm install 22 && nvm use 22

# pnpm
corepack enable && corepack prepare pnpm@latest --activate

# uv
brew install uv
uv python install 3.12

# Postgres — pick ONE of:
brew install postgresql@16        # local install
brew services start postgresql@16
# ── or ──
brew install --cask docker        # use Docker Desktop (see below)
```

## Install — Windows

Use **WSL 2** with Ubuntu and follow the Linux instructions. Native Windows isn't supported by this template.

## Verify

```bash
node --version       # v22.x
pnpm --version       # 9.x
python3 --version    # 3.12.x or 3.13.x (≥ 3.12 accepted)
uv --version
psql --version || echo "psql not installed — using Docker"
```

If any line fails, scroll up to the install step for that tool.

## Postgres — local vs Docker

### Option A: local Postgres

After installing, create the dev DB and role to match `.env.example`:

```bash
createuser -d keystone
createdb -O keystone keystone_dev
psql -d keystone_dev -c "ALTER USER keystone WITH PASSWORD 'keystone';"
```

### Option B: Docker (recommended for new dev machines)

Bring up Postgres 16 + Redis 7 with one command:

```bash
cp .env.example .env       # if you haven't already
docker compose -f infra/docker/compose.dev.yml up -d
```

Verify:

```bash
docker compose -f infra/docker/compose.dev.yml ps      # both services healthy
psql "$DATABASE_URL" -c 'SELECT 1;'                    # if you have psql installed
# or via the container:
docker exec -it keystone-postgres psql -U keystone -d keystone_dev -c 'SELECT 1;'
```

Stop without losing data:

```bash
docker compose -f infra/docker/compose.dev.yml down
```

Wipe data (irreversible):

```bash
docker compose -f infra/docker/compose.dev.yml down -v
```

## After install — bootstrap the project

```bash
cp .env.example .env
# fill in DJANGO_SECRET_KEY:
python3 -c "import secrets; print(secrets.token_urlsafe(50))"
```

Then run `/scaffold-app` from Claude Code — it does the rest (creates `apps/web`, `apps/api`, `packages/`, runs `pnpm install` + `uv sync`, brings up dev servers).

## Troubleshooting

### `corepack` says permission denied

On some Node installs, Corepack writes to a system path. Either re-run with `sudo corepack enable`, or install pnpm directly: `npm install -g pnpm@9`.

### `uv` not found after install

The installer drops `uv` in `~/.local/bin`. If that's not on `PATH`, add to your shell rc:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc   # or ~/.zshrc
exec $SHELL
```

### Postgres role `keystone` doesn't exist

You skipped the `createuser` step in Option A. Run it now or switch to the Docker path.

### Docker daemon not running (Linux)

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
exec $SHELL                 # reload group membership
```

### `agent refused operation` from SSH on `git push`

Gnome-keyring locked the SSH agent. Reset it:

```bash
ssh-add -D
ssh-add ~/.ssh/id_ed25519
```

If your key has a passphrase your TTY isn't propagating, see "SSH key without passphrase" below.

### SSH key without passphrase (for git ops)

If you want to remove a passphrase from an existing key (keeps the key, removes the prompt):

```bash
ssh-keygen -p -f ~/.ssh/id_ed25519 -N ""    # run in a real terminal, not via wrappers
```

Or generate a new dedicated GitHub key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -N "" -C "github.com/<your-username>"
```

Add the new public key to GitHub at https://github.com/settings/ssh/new, then point your `~/.ssh/config`:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
```
