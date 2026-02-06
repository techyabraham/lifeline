import Fastify from 'fastify';
import cors from '@fastify/cors';
import rateLimit from '@fastify/rate-limit';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';
import { env } from './config/env.js';
import { healthRoutes } from './routes/health.js';
import { stateRoutes } from './routes/states.js';
import { providerRoutes } from './routes/providers.js';
import { adminRoutes } from './routes/admin.js';
import { errorResponse } from './utils/errors.js';

export function buildApp() {
  const app = Fastify({
    logger: {
      level: env.LOG_LEVEL,
    },
  });

  app.setErrorHandler((err, _req, reply) => {
    const { statusCode, payload } = errorResponse(err);
    reply.code(statusCode).send(payload);
  });

  app.register(cors, { origin: true });
  app.register(rateLimit, {
    max: env.RATE_LIMIT_MAX,
    timeWindow: env.RATE_LIMIT_TIME_WINDOW,
  });

  app.register(swagger, {
    openapi: {
      info: {
        title: 'LifeLine API',
        version: '1.0.0',
      },
    },
  });
  app.register(swaggerUi, {
    routePrefix: '/docs',
  });

  app.register(healthRoutes);
  app.register(stateRoutes);
  app.register(providerRoutes);
  app.register(adminRoutes);

  return app;
}
