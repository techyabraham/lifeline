import { buildApp } from './app.js';
import { env } from './config/env.js';
import { prisma } from './db/prisma.js';

const app = buildApp();

const shutdown = async () => {
  try {
    await app.close();
  } finally {
    await prisma.$disconnect();
    process.exit(0);
  }
};

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

app.listen({ port: env.PORT, host: '0.0.0.0' }).catch((err) => {
  app.log.error(err);
  process.exit(1);
});
