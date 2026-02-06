import { FastifyInstance } from 'fastify';
import { prisma } from '../db/prisma.js';

export async function stateRoutes(app: FastifyInstance) {
  app.get('/v1/states', async () => {
    const states = await prisma.state.findMany({ orderBy: { name: 'asc' } });
    return { data: states };
  });

  app.get('/v1/states/:stateId/lgas', async (req) => {
    const { stateId } = req.params as { stateId: string };
    const id = Number(stateId);
    const lgas = await prisma.lga.findMany({
      where: { stateId: id },
      orderBy: { name: 'asc' },
    });
    return { data: lgas };
  });
}
