import { FastifyInstance } from 'fastify';
import { env } from '../config/env.js';
import { ApiError } from '../utils/errors.js';
import { prisma } from '../db/prisma.js';
import { importProviders } from '../import/importProviders.js';
import { ProviderStatus, ProviderType } from '@prisma/client';

function requireAdmin(req: { headers: Record<string, string | string[] | undefined> }) {
  const header = req.headers['x-admin-key'];
  const key = Array.isArray(header) ? header[0] : header;
  if (!key || key !== env.ADMIN_KEY) {
    throw new ApiError('unauthorized', 'Invalid admin key', 401);
  }
}

function parseProviderType(value: string) {
  const normalized = value.toUpperCase();
  if (!(normalized in ProviderType)) {
    throw new ApiError('invalid_provider_type', 'Invalid providerType');
  }
  return ProviderType[normalized as keyof typeof ProviderType];
}

export async function adminRoutes(app: FastifyInstance) {
  app.addHook('preHandler', async (req) => {
    requireAdmin(req);
  });

  app.post('/v1/admin/import/providers', async (req) => {
    const body = req.body as { path?: string } | undefined;
    const result = await importProviders({
      csvPath: body?.path ?? 'data/providers.csv',
      jsonPath: 'data/states_lgas.json',
      checkpointPath: 'data/import_checkpoint.json',
      errorCsvPath: 'data/import_errors.csv',
    });
    return { data: result };
  });

  app.post('/v1/admin/providers', async (req) => {
    const body = req.body as {
      name: string;
      providerType: string;
      category?: string;
      address?: string;
      stateId: number;
      lgaId: number;
      latitude: number;
      longitude: number;
      phonePrimary?: string;
      phoneSecondary?: string;
      email?: string;
      source?: string;
      verified?: boolean;
      status?: ProviderStatus;
    };

    const created = await prisma.$transaction(async (tx) => {
      const provider = await tx.provider.create({
        data: {
          name: body.name,
          providerType: parseProviderType(body.providerType),
          category: body.category,
          address: body.address,
          stateId: body.stateId,
          lgaId: body.lgaId,
          latitude: body.latitude,
          longitude: body.longitude,
          phonePrimary: body.phonePrimary,
          phoneSecondary: body.phoneSecondary,
          email: body.email,
          source: body.source,
          verified: body.verified ?? false,
          status: body.status ?? ProviderStatus.active,
          geo: undefined as never,
        },
      });

      await tx.$executeRaw`
        UPDATE "Provider"
        SET "geo" = ST_SetSRID(ST_MakePoint("longitude", "latitude"), 4326)::geography
        WHERE "id" = ${provider.id}
      `;

      return provider;
    });

    return { data: created };
  });

  app.patch('/v1/admin/providers/:id', async (req) => {
    const { id } = req.params as { id: string };
    const body = req.body as {
      phonePrimary?: string | null;
      phoneSecondary?: string | null;
      verified?: boolean;
      status?: ProviderStatus;
      category?: string | null;
    };

    const updated = await prisma.provider.update({
      where: { id },
      data: {
        phonePrimary: body.phonePrimary ?? undefined,
        phoneSecondary: body.phoneSecondary ?? undefined,
        verified: body.verified ?? undefined,
        status: body.status ?? undefined,
        category: body.category ?? undefined,
      },
    });

    return { data: updated };
  });
}
