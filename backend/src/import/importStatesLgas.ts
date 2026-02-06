import fs from 'node:fs/promises';
import path from 'node:path';
import { prisma } from '../db/prisma.js';
import { GeoDataService } from '../services/geoData.js';

export async function importStatesLgas(jsonPath: string) {
  const service = new GeoDataService();
  await service.init(jsonPath);
  const states = service.getStates();

  await prisma.$transaction(async (tx) => {
    for (const state of states) {
      await tx.state.upsert({
        where: { id: state.id },
        update: { name: state.name, slug: state.slug },
        create: { id: state.id, name: state.name, slug: state.slug },
      });

      for (const lga of state.lgas) {
        await tx.lga.upsert({
          where: { id: lga.id },
          update: { name: lga.name, slug: lga.slug, stateId: state.id },
          create: {
            id: lga.id,
            name: lga.name,
            slug: lga.slug,
            stateId: state.id,
          },
        });
      }
    }
  });

  const summary = {
    states: states.length,
    lgas: states.reduce((acc, s) => acc + s.lgas.length, 0),
  };

  const absolute = path.resolve(jsonPath);
  await fs.writeFile(
    path.join(path.dirname(absolute), 'states_lgas_imported.json'),
    JSON.stringify(summary, null, 2),
  );

  return summary;
}
