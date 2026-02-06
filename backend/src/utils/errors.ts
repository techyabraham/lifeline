export class ApiError extends Error {
  code: string;
  statusCode: number;
  details?: unknown;

  constructor(code: string, message: string, statusCode = 400, details?: unknown) {
    super(message);
    this.code = code;
    this.statusCode = statusCode;
    this.details = details;
  }
}

export function errorResponse(err: unknown) {
  if (err instanceof ApiError) {
    return {
      statusCode: err.statusCode,
      payload: {
        error: {
          code: err.code,
          message: err.message,
          details: err.details ?? null,
        },
      },
    };
  }

  return {
    statusCode: 500,
    payload: {
      error: {
        code: 'internal_error',
        message: 'Unexpected server error',
        details: null,
      },
    },
  };
}
