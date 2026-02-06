-- prisma/migrations/0001_init/migration.sql

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE "ProviderType" AS ENUM ('HOSPITAL', 'POLICE', 'FRSC', 'FIRE', 'AGENCY', 'OTHER');
CREATE TYPE "ProviderStatus" AS ENUM ('active', 'inactive');

CREATE TABLE "State" (
  "id" INTEGER PRIMARY KEY,
  "name" TEXT NOT NULL UNIQUE,
  "slug" TEXT NOT NULL UNIQUE
);

CREATE TABLE "Lga" (
  "id" INTEGER PRIMARY KEY,
  "state_id" INTEGER NOT NULL REFERENCES "State"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL,
  UNIQUE ("state_id", "slug")
);

CREATE TABLE "Provider" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "external_id" TEXT,
  "provider_type" "ProviderType" NOT NULL,
  "category" TEXT,
  "name" TEXT NOT NULL,
  "phone_primary" TEXT,
  "phone_secondary" TEXT,
  "email" TEXT,
  "address" TEXT,
  "state_id" INTEGER NOT NULL REFERENCES "State"("id") ON DELETE RESTRICT,
  "lga_id" INTEGER NOT NULL REFERENCES "Lga"("id") ON DELETE RESTRICT,
  "latitude" DOUBLE PRECISION NOT NULL,
  "longitude" DOUBLE PRECISION NOT NULL,
  "geo" geography(Point, 4326),
  "source" TEXT,
  "verified" BOOLEAN NOT NULL DEFAULT FALSE,
  "status" "ProviderStatus" NOT NULL DEFAULT 'active',
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "ProviderAlias" (
  "id" SERIAL PRIMARY KEY,
  "provider_id" UUID NOT NULL REFERENCES "Provider"("id") ON DELETE CASCADE,
  "alias" TEXT NOT NULL,
  UNIQUE ("provider_id", "alias")
);

CREATE UNIQUE INDEX "Provider_unique_key" ON "Provider" ("name", "provider_type", "lga_id", "latitude", "longitude");
CREATE INDEX "Provider_provider_type_idx" ON "Provider" ("provider_type");
CREATE INDEX "Provider_category_idx" ON "Provider" ("category");
CREATE INDEX "Provider_state_idx" ON "Provider" ("state_id");
CREATE INDEX "Provider_lga_idx" ON "Provider" ("lga_id");
CREATE INDEX "Provider_verified_idx" ON "Provider" ("verified");
CREATE INDEX "Provider_status_idx" ON "Provider" ("status");
CREATE INDEX "Provider_geo_idx" ON "Provider" USING GIST ("geo");

CREATE INDEX "Lga_state_idx" ON "Lga" ("state_id");
CREATE INDEX "ProviderAlias_alias_idx" ON "ProviderAlias" ("alias");
