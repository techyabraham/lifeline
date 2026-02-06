import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { prisma } from '../src/db/prisma.js';
import { nearbyProviders } from '../src/services/providerService.js';
import { ProviderStatus, ProviderType } from '@prisma/client';

const hasDb = Boolean(process.env.DATABASE_URL);

const stateId = 999001;
const lgaId = 999002;
const providerName = `Test Provider ${Date.now()}`;

(hasDb ? describe : describe.skip)('nearby providers', () => {
  beforeAll(async () => {
    await prisma.state.create({
      data: { id: stateId, name: 'Test State', slug: 'test-state' },
    });
    await prisma.lga.create({
      data: { id: lgaId, name: 'Test LGA', slug: 'test-lga', stateId },
    });

    const provider = await prisma.provider.create({
      data: {
        name: providerName,
        providerType: ProviderType.HOSPITAL,
        category: 'health',
        address: 'Test Address',
        stateId,
        lgaId,
        latitude: 6.5,
        longitude: 3.3,
        verified: true,
        status: ProviderStatus.active,
      },
    });

    await prisma.$executeRaw`
      UPDATE "Provider"
      SET "geo" = ST_SetSRID(ST_MakePoint("longitude", "latitude"), 4326)::geography
      WHERE "id" = ${provider.id}
    `;
  });

  afterAll(async () => {
    await prisma.provider.deleteMany({ where: { name: providerName } });
    await prisma.lga.deleteMany({ where: { id: lgaId } });
    await prisma.state.deleteMany({ where: { id: stateId } });
    await prisma.$disconnect();
  });

  it('returns nearest providers', async () => {
    const results = await nearbyProviders({
      lat: 6.501,
      lng: 3.301,
      radiusKm: 5,
      limit: 5,
      providerType: ProviderType.HOSPITAL,
    });

    expect(results.length).toBeGreaterThan(0);
    expect(results[0].name).toBe(providerName);
    expect(results[0].distance_km).toBeLessThan(5);
  });
});
