# Data Migration Demo (Flyway)

Shows how schema AND data evolve safely across 5 versioned migrations,
including the "add column → backfill data → drop old column later" pattern
used for zero-downtime schema changes in production.

## Migrations included

| File | What it does |
|---|---|
| `V1__create_customer_table.sql` | Baseline: creates `customer` with `full_name`, `email` |
| `V2__add_phone_number.sql` | Additive column — safe, no data change needed |
| `V3__split_full_name.sql` | **Real data migration**: adds `first_name`/`last_name`, backfills them from existing `full_name` values for every row already in the table |
| `V4__create_customer_order_table.sql` | New table with a foreign key + index |
| `V5__drop_full_name.sql` | Drops the now-unused `full_name` column — done in its own migration, separately from V3, so there's a safe window between "data copied" and "old column removed" |

Flyway tracks which migrations have run in a `flyway_schema_history` table it
creates automatically — on startup it runs only the ones not yet applied, in
version order, and refuses to start if a previously-applied migration's file
has been edited (checksum mismatch) — this is what makes migrations safe to
trust across environments.

## Run
```bash
docker-compose up -d      # Postgres on 5432
mvn spring-boot:run       # app on 8093 — Flyway runs V1-V5 automatically on startup
```

Watch the startup logs — you'll see Flyway announce each migration as it applies it.

## Try it
```bash
curl -X POST http://localhost:8093/customers \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Asha","lastName":"Rao","email":"asha@example.com","phoneNumber":"555-0100"}'

curl http://localhost:8093/customers
```

**Inspect the migration history directly:**
```bash
docker exec -it data-migration-flyway-postgres-1 psql -U postgres -d migrationdb \
  -c "SELECT version, description, success FROM flyway_schema_history;"
```

## Why `ddl-auto: validate` and not `update`

Letting Hibernate auto-generate schema changes (`update`/`create`) is fine for
a single-developer prototype, but breaks down the moment more than one person
or environment is involved — there's no history, no order, no way to know
what actually ran in production. Flyway migrations are:
- **Versioned** — every change is a numbered, reviewable file in git
- **Repeatable across environments** — same files run in dev, staging, prod
- **Auditable** — `flyway_schema_history` is a permanent record of what ran, when

`ddl-auto: validate` keeps Hibernate from silently changing anything — it just
checks your `@Entity` classes match what the migrations actually produced, and
fails loudly at startup if they've drifted.

## Adding your own next migration

Create `V6__whatever_it_does.sql` — Flyway requires strictly increasing version
numbers and won't let you insert a V4.5 later, only append forward. Never edit
a migration that's already run in any shared environment; write a new one to
fix it instead.
