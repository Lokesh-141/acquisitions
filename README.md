# Acquisitions

## Running with Docker and Neon

### Environment variables

The application reads `DATABASE_URL` from the environment and uses it with the Neon serverless driver.

- **Development** (`.env.development`): point to Neon Local
  ```env
  DATABASE_URL=postgres://neon:npg@neon-local:5432/your_database_name?sslmode=require
  PORT=3000
  ```
- **Production** (`.env.production`): point to your Neon Cloud database
  ```env
  DATABASE_URL=postgres://<user>:<password>@<project-id>.neon.tech/<database_name>?sslmode=require
  PORT=3000
  ```

### Development with Neon Local

1. Ensure `.env.development` is created and has a `DATABASE_URL` pointing to `neon-local` as above.
2. Build and start the stack:
   ```bash
   docker compose -f docker-compose.dev.yml up --build
   ```
3. The API will be available at `http://localhost:3000`.

Neon Local will create ephemeral branches for your dev/testing workloads. The `neon-local` service is defined in `docker-compose.dev.yml` and shares a network with the `app` service.

### Production with Neon Cloud

1. Ensure `.env.production` contains your Neon Cloud `DATABASE_URL` and any other production secrets.
2. Build and start the stack:
   ```bash
   docker compose -f docker-compose.prod.yml up --build -d
   ```
3. The API will be available at `http://localhost:3000`.

In production, only the application container runs; it connects directly to the Neon Cloud database using the `DATABASE_URL` value from `.env.production`.
