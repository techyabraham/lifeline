# LifeLine Backend

Production-grade backend for the LifeLine emergency response directory.

## Stack
- Node.js (TypeScript)
- Fastify
- PostgreSQL + PostGIS
- Prisma ORM + migrations
- Docker Compose
- OpenAPI (Swagger)

## Setup

```bash
pnpm i
cp .env.example .env

docker compose up -d
pnpm prisma migrate dev
pnpm prisma generate

pnpm import:stateslgas
pnpm import:providers

pnpm dev
```

The API will start on `http://localhost:4000` and Swagger UI at `/docs`.

## Example Requests

```bash
curl http://localhost:4000/health

curl http://localhost:4000/v1/states

curl http://localhost:4000/v1/states/1/lgas

curl "http://localhost:4000/v1/providers/search?stateId=1&lgaId=10&providerType=HOSPITAL"

curl "http://localhost:4000/v1/providers/nearby?lat=6.45&lng=3.4&radiusKm=10&providerType=HOSPITAL"

curl -H "X-ADMIN-KEY: change_me" -H "Content-Type: application/json" \
  -d '{"path":"data/providers.csv"}' \
  http://localhost:4000/v1/admin/import/providers
```

## CSV Import

`pnpm import:providers` streams `data/providers.csv` and writes errors to
`data/import_errors.csv`. Import resumes from `data/import_checkpoint.json`.

Required columns:
- `name`
- `provider_type`
- `state`
- `lga`
- `latitude`
- `longitude`

Optional columns:
- `category`, `address`, `phone_primary`, `phone_secondary`, `email`,
  `external_id`, `source`, `verified`, `inactive`

## Contact Data Insertion

Providers are de-duplicated by:
`(name, provider_type, lga_id, latitude, longitude)`.

Insert real phone numbers by re-importing the CSV with those columns filled.

## Notes
- PostGIS is required for `/nearby` queries.
- `geo` is derived from latitude/longitude on insert.
