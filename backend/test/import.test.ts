import { describe, expect, it } from 'vitest';
import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { GeoDataService } from '../src/services/geoData.js';
import { mapRowToProvider } from '../src/import/importProviders.js';

const sampleData = {
  states: [
    {
      id: 1,
      name: 'Lagos',
      slug: 'lagos',
      lgas: [
        { id: 10, name: 'Ikeja', slug: 'ikeja' },
        { id: 11, name: 'Eti-Osa', slug: 'eti-osa' },
      ],
    },
  ],
};

describe('import mapping', () => {
  it('maps a valid row into provider input', async () => {
    const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'lifeline-'));
    const jsonPath = path.join(dir, 'states.json');
    await fs.writeFile(jsonPath, JSON.stringify(sampleData));

    const geo = new GeoDataService();
    await geo.init(jsonPath);

    const row = {
      name: 'Test Clinic',
      provider_type: 'Hospital',
      state: 'Lagos State',
      lga: 'Ikeja',
      latitude: '6.5',
      longitude: '3.3',
      phone_primary: '123',
    };

    const mapped = mapRowToProvider(row, geo);
    expect(mapped.ok).toBe(true);
    if (mapped.ok) {
      expect(mapped.data.stateId).toBe(1);
      expect(mapped.data.lgaId).toBe(10);
      expect(mapped.data.providerType).toBeDefined();
    }
  });

  it('fails when required fields are missing', async () => {
    const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'lifeline-'));
    const jsonPath = path.join(dir, 'states.json');
    await fs.writeFile(jsonPath, JSON.stringify(sampleData));

    const geo = new GeoDataService();
    await geo.init(jsonPath);

    const row = {
      name: 'Missing Lat',
      provider_type: 'Hospital',
      state: 'Lagos',
      lga: 'Ikeja',
    } as Record<string, string>;

    const mapped = mapRowToProvider(row, geo);
    expect(mapped.ok).toBe(false);
  });
});
