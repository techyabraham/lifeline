export function normalizeName(input: string) {
  return input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

export function ensureStateSuffix(name: string) {
  const trimmed = name.trim();
  if (!trimmed) return trimmed;
  return trimmed.toLowerCase().endsWith('state') ? trimmed : `${trimmed} State`;
}

export function normalizeStateName(input: string) {
  const normalized = normalizeName(input);
  if (normalized.endsWith(' state')) {
    return normalized.replace(/ state$/, '').trim();
  }
  return normalized;
}

export function isFctQuery(input: string) {
  const normalized = normalizeName(input);
  return (
    normalized === 'fct' ||
    normalized.includes('abuja') ||
    normalized.includes('federal capital territory')
  );
}
