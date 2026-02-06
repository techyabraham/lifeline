import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import { parse } from 'csv-parse';
import { Prisma, ProviderStatus, ProviderType } from '@prisma/client';
import { prisma } from '../db/prisma.js';
import { GeoDataService } from '../services/geoData.js';
import { importStatesLgas } from './importStatesLgas.js';
import { normalizeName } from '../utils/normalize.js';

export type ImportResult = {
  totalRows: number;
  inserted: number;
  skipped: number;
  invalid: number;
};

type ImportOptions = {
  csvPath: string;
  jsonPath: string;
  checkpointPath: string;
  errorCsvPath: string;
};

type CsvRow = Record<string, string>;

export type ProviderInput = {
  name: string;
  providerType: ProviderType;
  category?: string;
  address?: string;
  stateId: number;
  lgaId: number;
  latitude: number;
  longitude: number;
  phonePrimary?: string;
  phoneSecondary?: string;
  email?: string;
  externalId?: string;
  source?: string;
  verified: boolean;
  status: ProviderStatus;
};

function parseProviderType(value: string) {
  const normalized = normalizeName(value).replace(/\s+/g, '_').toUpperCase();
  const map: Record<string, ProviderType> = {
    HOSPITAL: ProviderType.HOSPITAL,
    CLINIC: ProviderType.HOSPITAL,
    POLICE: ProviderType.POLICE,
    FRSC: ProviderType.FRSC,
    FIRE: ProviderType.FIRE,
    AGENCY: ProviderType.AGENCY,
    OTHER: ProviderType.OTHER,
  };
  return map[normalized] ?? ProviderType.OTHER;
}

function parseBool(value?: string) {
  if (!value) return false;
  return ['1', 'true', 'yes', 'y'].includes(value.toLowerCase());
}

function getField(row: CsvRow, key: string) {
  const found = Object.keys(row).find((k) => normalizeName(k) === normalizeName(key));
  return found ? row[found] : undefined;
}

function parseNumber(value?: string) {
  if (!value) return undefined;
  const n = Number(value);
  return Number.isFinite(n) ? n : undefined;
}

async function readCheckpoint(checkpointPath: string) {
  try {
    const raw = await fsp.readFile(checkpointPath, 'utf-8');
    const parsed = JSON.parse(raw);
    return Number(parsed.lastRow ?? 0);
  } catch {
    return 0;
  }
}

async function writeCheckpoint(checkpointPath: string, lastRow: number) {
  await fsp.writeFile(
    checkpointPath,
    JSON.stringify({ lastRow, updatedAt: new Date().toISOString() }, null, 2),
  );
}

function buildInsertSql(batch: ProviderInput[]) {
  const rows = batch.map((p) =>
    Prisma.sql`(
      ${p.externalId ?? null},
      ${p.providerType},
      ${p.category ?? null},
      ${p.name},
      ${p.phonePrimary ?? null},
      ${p.phoneSecondary ?? null},
      ${p.email ?? null},
      ${p.address ?? null},
      ${p.stateId},
      ${p.lgaId},
      ${p.latitude},
      ${p.longitude},
      ST_SetSRID(ST_MakePoint(${p.longitude}, ${p.latitude}), 4326)::geography,
      ${p.source ?? null},
      ${p.verified},
      ${p.status}
    )`,
  );

  return Prisma.sql`
    INSERT INTO "Provider" (
      "external_id",
      "provider_type",
      "category",
      "name",
      "phone_primary",
      "phone_secondary",
      "email",
      "address",
      "state_id",
      "lga_id",
      "latitude",
      "longitude",
      "geo",
      "source",
      "verified",
      "status"
    )
    VALUES ${Prisma.join(rows)}
    ON CONFLICT ("name", "provider_type", "lga_id", "latitude", "longitude") DO NOTHING
  `;
}

export function mapRowToProvider(row: CsvRow, geo: GeoDataService) {
  const name = getField(row, 'name');
  const providerTypeRaw = getField(row, 'provider_type') ?? getField(row, 'type');
  const stateRaw = getField(row, 'state');
  const lgaRaw = getField(row, 'lga');
  const latitude = parseNumber(getField(row, 'latitude'));
  const longitude = parseNumber(getField(row, 'longitude'));

  if (!name || !providerTypeRaw || !stateRaw || !lgaRaw || latitude == null || longitude == null) {
    return { ok: false, error: 'Missing required fields' as const };
  }

  const stateMatch = geo.matchStateByName(stateRaw);
  if (!stateMatch) {
    return { ok: false, error: 'State not found' as const };
  }

  const lgaMatch = geo.matchLgaByName(stateMatch.id, lgaRaw);
  if (!lgaMatch) {
    return { ok: false, error: 'LGA not found' as const };
  }

  const record: ProviderInput = {
    name: String(name).trim(),
    providerType: parseProviderType(providerTypeRaw),
    category: getField(row, 'category'),
    address: getField(row, 'address'),
    stateId: stateMatch.id,
    lgaId: lgaMatch.id,
    latitude,
    longitude,
    phonePrimary: getField(row, 'phone_primary'),
    phoneSecondary: getField(row, 'phone_secondary'),
    email: getField(row, 'email'),
    externalId: getField(row, 'external_id'),
    source: getField(row, 'source'),
    verified: parseBool(getField(row, 'verified')),
    status: parseBool(getField(row, 'inactive')) ? ProviderStatus.inactive : ProviderStatus.active,
  };

  return { ok: true, data: record };
}

export async function importProviders(options: ImportOptions): Promise<ImportResult> {
  await importStatesLgas(options.jsonPath);
  const geo = new GeoDataService();
  await geo.init(options.jsonPath);

  const checkpoint = await readCheckpoint(options.checkpointPath);
  const errorRows: CsvRow[] = [];

  let totalRows = 0;
  let inserted = 0;
  let skipped = 0;
  let invalid = 0;

  const batch: ProviderInput[] = [];
  const batchSize = 1000;

  const parser = parse({
    columns: true,
    skip_empty_lines: true,
    trim: true,
  });

  const input = fs.createReadStream(options.csvPath);
  input.pipe(parser);

  for await (const row of parser) {
    totalRows += 1;
    if (totalRows <= checkpoint) {
      skipped += 1;
      continue;
    }

    const mapped = mapRowToProvider(row, geo);
    if (!mapped.ok) {
      invalid += 1;
      errorRows.push({ ...row, error: mapped.error });
      await writeCheckpoint(options.checkpointPath, totalRows);
      continue;
    }

    batch.push(mapped.data);

    if (batch.length >= batchSize) {
      const sql = buildInsertSql(batch);
      const result = await prisma.$executeRaw(sql);
      inserted += Number(result);
      batch.length = 0;
      await writeCheckpoint(options.checkpointPath, totalRows);
    }
  }

  if (batch.length > 0) {
    const sql = buildInsertSql(batch);
    const result = await prisma.$executeRaw(sql);
    inserted += Number(result);
    batch.length = 0;
    await writeCheckpoint(options.checkpointPath, totalRows);
  }

  if (errorRows.length > 0) {
    const header = Object.keys(errorRows[0]);
    const lines = [header.join(',')];
    for (const row of errorRows) {
      lines.push(header.map((h) => JSON.stringify(row[h] ?? '')).join(','));
    }
    await fsp.writeFile(options.errorCsvPath, lines.join('\n'));
  }

  return { totalRows, inserted, skipped, invalid };
}
