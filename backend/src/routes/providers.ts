import { FastifyInstance } from 'fastify';
import { ProviderType } from '@prisma/client';
import { ApiError } from '../utils/errors.js';
import { getProviderById, nearbyProviders, searchProviders } from '../services/providerService.js';

function parseProviderType(value?: string) {
  if (!value) return undefined;
  const normalized = value.toUpperCase();
  if (!(normalized in ProviderType)) {
    throw new ApiError('invalid_provider_type', 'Invalid providerType');
  }
  return ProviderType[normalized as keyof typeof ProviderType];
}

export async function providerRoutes(app: FastifyInstance) {
  app.get('/v1/providers/:id', async (req) => {
    const { id } = req.params as { id: string };
    const provider = await getProviderById(id);
    return { data: provider };
  });

  app.get('/v1/providers/search', async (req) => {
    const query = req.query as {
      stateId?: string;
      lgaId?: string;
      providerType?: string;
      category?: string;
      q?: string;
      page?: string;
      pageSize?: string;
    };

    const page = Math.max(Number(query.page ?? 1), 1);
    const pageSize = Math.min(Math.max(Number(query.pageSize ?? 20), 1), 100);

    const result = await searchProviders({
      stateId: query.stateId ? Number(query.stateId) : undefined,
      lgaId: query.lgaId ? Number(query.lgaId) : undefined,
      providerType: parseProviderType(query.providerType),
      category: query.category,
      q: query.q,
      page,
      pageSize,
    });

    return {
      data: result.items,
      meta: {
        page,
        pageSize,
        total: result.total,
      },
    };
  });

  app.get('/v1/providers/nearby', async (req) => {
    const query = req.query as {
      lat?: string;
      lng?: string;
      radiusKm?: string;
      providerType?: string;
      category?: string;
      limit?: string;
    };

    if (!query.lat || !query.lng) {
      throw new ApiError('missing_coordinates', 'lat and lng are required');
    }

    const lat = Number(query.lat);
    const lng = Number(query.lng);
    const radiusKm = query.radiusKm ? Number(query.radiusKm) : 10;
    const limit = query.limit ? Number(query.limit) : 25;

    const rows = await nearbyProviders({
      lat,
      lng,
      radiusKm,
      providerType: parseProviderType(query.providerType),
      category: query.category,
      limit: Math.min(Math.max(limit, 1), 100),
    });

    return {
      data: rows.map((row) => {
        const { distance_km, ...rest } = row;
        return {
          ...rest,
          distanceKm: distance_km,
        };
      }),
    };
  });
}
