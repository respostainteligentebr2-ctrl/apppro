/**
 * Simple error logger for development and production
 */

type ErrorContext = Record<string, unknown>;

interface ErrorLogEntry {
  timestamp: string;
  error: string;
  stack?: string;
  context?: ErrorContext;
}

/**
 * Log errors to console and optionally to a remote service
 */
export function logError(error: unknown, context: ErrorContext = {}): void {
  const errorMessage = error instanceof Error ? error.message : String(error);
  const errorStack = error instanceof Error ? error.stack : undefined;

  const logEntry: ErrorLogEntry = {
    timestamp: new Date().toISOString(),
    error: errorMessage,
    stack: errorStack,
    context,
  };

  // Always log to console in development
  if (process.env.NODE_ENV === "development") {
    console.error("[ERROR LOG]", logEntry);
  }

  // In production, you could send this to a logging service
  // Example: Sentry, LogRocket, etc.
  // if (process.env.NODE_ENV === "production") {
  //   sendToLoggingService(logEntry);
  // }
}
