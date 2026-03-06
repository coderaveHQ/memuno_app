const ANSI_RESET = "\x1b[0m";
const ANSI_BLUE = "\x1b[34m";
const ANSI_GREEN = "\x1b[32m";
const ANSI_YELLOW = "\x1b[33m";
const ANSI_RED = "\x1b[31m";

export type LogLevel = "info" | "success" | "warn" | "error";

function getMeta(level: LogLevel): { color: string; emoji: string } {
  if (level === "success") {
    return { color: ANSI_GREEN, emoji: "✅" };
  }

  if (level === "warn") {
    return { color: ANSI_YELLOW, emoji: "⚠️" };
  }

  if (level === "error") {
    return { color: ANSI_RED, emoji: "❌" };
  }

  return { color: ANSI_BLUE, emoji: "ℹ️" };
}

export function toError(error: unknown): Error {
  if (error instanceof Error) {
    return error;
  }

  return new Error(String(error));
}

export function logEvent(
  level: LogLevel,
  event: string,
  details: Record<string, unknown> = {},
): void {
  const { color, emoji } = getMeta(level);
  const header = `${color}${emoji} ${event}${ANSI_RESET}`;
  const suffix = Object.keys(details).length === 0
    ? ""
    : ` ${JSON.stringify(details)}`;

  if (level === "error") {
    console.error(`${header}${suffix}`);
    return;
  }

  if (level === "warn") {
    console.warn(`${header}${suffix}`);
    return;
  }

  console.log(`${header}${suffix}`);
}

export function logLifecycleStart(
  functionName: string,
  details: Record<string, unknown> = {},
): void {
  logEvent("info", `${functionName}.invoked`, details);
}

export function logLifecycleSuccess(
  functionName: string,
  details: Record<string, unknown> = {},
): void {
  logEvent("success", `${functionName}.completed`, details);
}

export function logLifecycleFailure(
  functionName: string,
  error: unknown,
  details: Record<string, unknown> = {},
): void {
  const resolved = toError(error);
  logEvent("error", `${functionName}.failed`, {
    ...details,
    error: resolved.message,
  });
}
