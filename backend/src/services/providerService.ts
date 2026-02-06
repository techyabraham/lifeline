import { prisma } from '../db/prisma.js';
import { Prisma, ProviderStatus, ProviderType } from '@prisma/client';
import { ApiError } from '../utils/errors.js';

export type NearbyQuery = {
  lat: number;
  lng: number;
  radiusKm: number;
  providerType?: ProviderType;
  category?: string;
  limit: number;
};

export async function getProviderById(id: string) {
  const provider = await prisma.provider.findUnique({
    where: { id },
    include: { state: true, lga: true },
  });
  if (!provider) throw new ApiError('not_found', 'Provider not found', 404);
  return provider;
}

export async function searchProviders(params: {
  stateId?: number;
  lgaId?: number;
  providerType?: ProviderType;
  category?: string;
  q?: string;
  page: number;
  pageSize: number;
}) {
  const { stateId, lgaId, providerType, category, q, page, pageSize } = params;
  const where: Prisma.ProviderWhereInput = {
    status: ProviderStatus.active,
  };

  if (stateId) where.stateId = stateId;
  if (lgaId) where.lgaId = lgaId;
  if (providerType) where.providerType = providerType;
  if (category) where.category = { equals: category, mode: 'insensitive' };
  if (q) {
    where.OR = [
      { name: { contains: q, mode: 'insensitive' } },
      { address: { contains: q, mode: 'insensitive' } },
      { category: { contains: q, mode: 'insensitive' } },
    ];
  }

  const [total, items] = await Promise.all([
    prisma.provider.count({ where }),
    prisma.provider.findMany({
      where,
      include: { state: true, lga: true },
      orderBy: { name: 'asc' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    }),
  ]);

  return { total, items };
}

export async function nearbyProviders(query: NearbyQuery) {
  const radiusMeters = query.radiusKm * 1000;
  const limit = query.limit;
  const providerType = query.providerType;
  const category = query.category;

  const whereParts: Prisma.Sql[] = [Prisma.sql`"status" = 'active'`];
  if (providerType) {
    whereParts.push(Prisma.sql`"provider_type" = ${providerType}`);
  }
  if (category) {
    whereParts.push(Prisma.sql`"category" ILIKE ${category}`);
  }

  const whereSql = Prisma.join(whereParts, ' AND ');

  const rows = await prisma.$queryRaw<
    Array<{
      id: string;
      name: string;
      provider_type: ProviderType;
      category: string | null;
      phone_primary: string | null;
      phone_secondary: string | null;
      address: string | null;
      state_id: number;
      lga_id: number;
      latitude: number;
      longitude: number;
      verified: boolean;
      status: ProviderStatus;
      distance_km: number;
    }>
  >(
    Prisma.sql`
      SELECT
        "id",
        "name",
        "provider_type",
        "category",
        "phone_primary",
        "phone_secondary",
        "address",
        "state_id",
        "lga_id",
        "latitude",
        "longitude",
        "verified",
        "status",
        ST_Distance(
          "geo",
          ST_SetSRID(ST_MakePoint(${query.lng}, ${query.lat}), 4326)::geography
        ) / 1000 AS distance_km
      FROM "Provider"
      WHERE ${whereSql}
        AND ST_DWithin(
          "geo",
          ST_SetSRID(ST_MakePoint(${query.lng}, ${query.lat}), 4326)::geography,
          ${radiusMeters}
        )
      ORDER BY distance_km ASC
      LIMIT ${limit}
    `,
  );

  return rows;
}
