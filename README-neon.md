# Running the App with Neon Database
This project uses Neon for Postgres, with different setups for development and production:
- Development: Neon Local (Docker proxy) + ephemeral branches
- Production: Neon Cloud serverless Postgres (no local proxy)

## Prerequisites
- Docker & Docker Compose (`docker compose` CLI)
- A Neon account and project
- A Neon API key (for development only)
- A parent branch ID in Neon (usually your `main` branch) for dev/test clones

## Local Development (Neon Local + Ephemeral Branches)

### 1. Get Neon credentials
In the Neon console:
1. Create (or choose) a project.
2. Copy:
   - Project ID
   - Parent branch ID (e.g. your `main` branch)
3. Create an API key for Neon Local.

### 2. Create `.env.development`
Create a file named `.env.development` in the project root (already created by default, edit values as needed):

```bash
NODE_ENV=development
PORT=3000

# Local Postgres via Neon Local
DATABASE_URL=postgres://neon:npg@neon-local:5432/app_db?sslmode=require

# Neon Local configuration
NEON_API_KEY=your_neon_api_key_here
NEON_PROJECT_ID=your_neon_project_id_here
PARENT_BRANCH_ID=your_parent_branch_id_here
```

> Note: Do not commit `.env.development`. Add it to `.gitignore`.

### 3. Start the dev stack
From the project root:

```bash
docker compose -f docker-compose.dev.yml up --build
```

This will:
- Start the `neon-local` proxy on port `5432`.
- Start the app on port `3000`.
- When `neon-local` starts, it creates a new ephemeral Neon branch cloned from `PARENT_BRANCH_ID`.
- When the stack stops, the ephemeral branch is deleted.

You can now access the app at:
- `http://localhost:3000`

If you need direct DB access from your host (psql, DBeaver, etc.), use:
- `postgres://neon:npg@localhost:5432/app_db?sslmode=require`

### 4. Stopping and re-creating dev environments
Stop:

```bash
docker compose -f docker-compose.dev.yml down
```

Restarting `up` will create a new ephemeral branch again, giving you a fresh DB.

## Production (Neon Cloud serverless Postgres)

In production, we connect directly to Neon’s serverless Postgres. Do not run Neon Local in production.

### 1. Configure Neon production database
1. In the Neon console, create a production branch and database.
2. Copy its `DATABASE_URL` (connection string).

Example (do not copy this literally):

```text
postgres://prod_user:prod_password@ep-something.us-east-2.aws.neon.tech/prod_db?sslmode=require
```

### 2. Provide `DATABASE_URL` to the app
In real deployments, you should set `DATABASE_URL` as a secret / env var in your platform:
- Kubernetes: Secret + envFrom
- ECS: Task definition secrets
- Render/Fly/Heroku-like: app config env vars

To simulate production with Docker Compose locally, edit `.env.production`:

```bash
NODE_ENV=production
PORT=3000
DATABASE_URL=postgres://prod_user:prod_password@ep-something.us-east-2.aws.neon.tech/prod_db?sslmode=require
```

> Security: Do not commit `.env.production`. Use your platform’s secret manager in real deployments.

### 3. Run with production configuration via Docker Compose
For a simple single-host deployment (e.g., a VM):

```bash
docker compose -f docker-compose.prod.yml up --build -d
```

- This runs only the `app` service.
- The app connects directly to Neon’s serverless Postgres using the production `DATABASE_URL`.
- No Neon Local proxy is involved.

## Switching Between Dev and Prod
- Dev: Use `docker-compose.dev.yml` and `.env.development`.
  - `docker compose -f docker-compose.dev.yml up --build`
  - `DATABASE_URL` → Neon Local (`neon-local` service) → Neon ephemeral branch
- Prod: Use `docker-compose.prod.yml` and environment-managed secrets / `.env.production`.
  - `docker compose -f docker-compose.prod.yml up --build -d`
  - `DATABASE_URL` → Neon Cloud serverless Postgres (no local proxy)

The application itself just reads `DATABASE_URL` from the environment. The Docker Compose file and env files decide whether it’s pointing to Neon Local (dev) or Neon Cloud (prod).

## Docker setup overview
This repository includes the following Docker-related files:
- `Dockerfile` – builds the application image.
- `docker-compose.dev.yml` – runs the app + Neon Local for development.
- `docker-compose.prod.yml` – runs the app only, connecting directly to Neon Cloud.
- `.dockerignore` – keeps unnecessary files out of the Docker build context.
- `.env.development` / `.env.production` – environment variable files (do not commit).

## Running with Docker Compose

### Development (Neon Local)
Use this to run the app and Neon Local proxy together with ephemeral branches:

```bash
docker compose -f docker-compose.dev.yml up --build
```

To stop and clean up containers:

```bash
docker compose -f docker-compose.dev.yml down
```

### Production-like (local simulation)
Use this to simulate production locally, with the app connecting directly to your Neon Cloud `DATABASE_URL` defined in `.env.production`:

```bash
docker compose -f docker-compose.prod.yml up --build -d
```

To stop it:

```bash
docker compose -f docker-compose.prod.yml down
```

## Building and running the image manually
If you want to build and run the image without Docker Compose:

```bash
docker build -t acquisitions-app .
```

Run against development config (connecting to Neon Local running elsewhere):

```bash
docker run --env-file .env.development -p 3000:3000 acquisitions-app
```

Run against production config (connecting directly to Neon Cloud):

```bash
docker run --env-file .env.production -p 3000:3000 acquisitions-app
```
