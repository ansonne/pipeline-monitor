# Pipeline Monitor

A real-time AI agent pipeline monitoring platform. Define pipelines with sequential steps, trigger runs, and watch execution stream live in the browser.

Built as a portfolio project showcasing **Hexagonal Architecture** and **Spec-Driven Design** with Elixir, Next.js 16, and PostgreSQL.

## Stack

| Layer | Technology |
|---|---|
| Backend | Elixir 1.17 + Phoenix 1.8 |
| Database | PostgreSQL 16 |
| Real-time | Phoenix Channels (WebSocket) |
| Frontend | Next.js 16 (App Router) + TypeScript |
| Styling | Tailwind CSS |
| Dev env | Docker Compose |

## Architecture

### Hexagonal (Ports & Adapters)

The core domain has **zero framework dependencies**. Phoenix and Ecto are adapters that plug into the domain via behaviour contracts.

```
server/lib/pipeline_monitor/
  domain/          ← Pure Elixir structs + typespecs
    pipeline.ex
    run.ex
    step.ex
    step_result.ex
  ports/           ← @behaviour contracts
    pipeline_repository.ex
    run_repository.ex
    step_executor.ex
    notifier.ex
  use_cases/       ← Business logic, depends only on ports
    create_pipeline.ex
    trigger_run.ex
    get_run_status.ex
  adapters/
    ecto/          ← Persistence adapter
    executors/     ← Step execution adapters
    phoenix/       ← WebSocket notifier adapter
```

### Spec-Driven Design

Every use case has `@spec` annotations. Tests are written **before** implementation using in-memory fakes that implement the port behaviours — no database required for unit tests.

### Pipeline Execution

Each run spawns an isolated supervised process via `Task.Supervisor`. A crash in one run does not affect others. Steps execute sequentially; each step result is broadcast live to the browser via Phoenix Channels.

```
TriggerRun
  → insert Run (pending)
  → spawn Task.Supervisor child
      → update Run (running)
      → for each step:
          → execute via StepExecutor adapter
          → broadcast StepResult via Phoenix Channel
          → persist StepResult
          → on error: mark run failed, stop
      → update Run (completed | failed)
```

## Step Types

| Type | Description |
|---|---|
| `mock_ai` | Simulates AI processing with canned output — no API cost |
| `http` | Calls an external URL (GET/POST) |
| `transform` | Maps, drops, or merges keys in the data payload |
| `notification` | Logs a message (extends to webhooks/email) |

## Getting Started

### With Docker (recommended)

```bash
git clone https://github.com/ansonne/pipeline-monitor
cd pipeline-monitor
docker compose up
```

Open http://localhost:3000.

### Local development

**Backend:**

```bash
cd server
mix deps.get
mix ecto.setup   # requires Postgres running on localhost:5432
mix phx.server
```

**Frontend:**

```bash
cd client
npm install
npm run dev
```

Backend runs on http://localhost:4000, frontend on http://localhost:3000.

### Environment variables

Copy `.env.example` and adjust as needed:

```bash
cp .env.example .env
```

| Variable | Default | Description |
|---|---|---|
| `NEXT_PUBLIC_API_URL` | `http://localhost:4000/api` | Backend API base URL |
| `NEXT_PUBLIC_WS_URL` | `ws://localhost:4000` | WebSocket URL |
| `SECRET_KEY_BASE` | — | Phoenix secret (generate with `mix phx.gen.secret`) |

## Running Tests

Use case tests run without a database using in-memory fakes:

```bash
cd server
mix test test/pipeline_monitor/use_cases/
```

Full test suite (requires Postgres):

```bash
cd server
mix test.db
```

## Project Structure

```
pipeline-monitor/
  server/                  ← Elixir/Phoenix backend
  client/                  ← Next.js 16 frontend
  docker-compose.yml
  .env.example
```

### Frontend pages

| Route | Description |
|---|---|
| `/pipelines` | Pipeline list (SSR) |
| `/pipelines/new` | Create pipeline form |
| `/pipelines/:id` | Pipeline detail + run history |
| `/runs/:id` | Live run execution viewer |
