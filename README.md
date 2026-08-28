# OnlineOrder

A food ordering platform: browse restaurants and menus, manage a cart, check out, and (for admins) manage the restaurant/menu catalog.

## What It Does

- **Customers** sign up, log in, browse all restaurants and their menus, add items to a cart, adjust quantities, and check out.
- **Admins** (`ROLE_ADMIN`) additionally get create/update/delete access to restaurants and menu items — everyone else gets read-only access to that data, enforced at the Spring Security filter-chain level, not just hidden in the UI.
- Restaurant/menu reads are cached (Caffeine); writes evict the cache so changes show up immediately.

## Tech Stack

**Backend**
- Java 21, Spring Boot 4.1
- Spring Security — session-based auth with role-based authorization (`ROLE_USER` / `ROLE_ADMIN`)
- Spring Data JDBC + PostgreSQL
- Caffeine (in-memory response caching)

**Frontend**
- React 18 + Ant Design 4
- A production build is bundled into the backend's static resources, so the backend alone serves the full app

**Dev infra**
- Docker Compose (local Postgres)
- Gradle (auto-provisions the Java 21 toolchain)

## How to Run

### Prerequisites
- Docker (for Postgres)
- Java 21+ (Gradle will auto-provision the exact toolchain version)

### Quick Start

```bash
git clone https://github.com/brian061119/OnlineOrder.git
cd OnlineOrder

# start Postgres
docker compose up -d db

# start the app — also seeds a dev account: foo@mail.com / 123456, with ROLE_ADMIN
./gradlew bootRun
```

Open http://localhost:8080 — the backend serves the pre-built frontend directly, no separate frontend server needed.

### Frontend Development

Only needed if you're editing frontend code and want hot reload (requires Node.js):

```bash
cd frontend
npm install
npm start   # proxies API requests to localhost:8080
```
