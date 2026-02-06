import fs from 'node:fs/promises';
import path from 'node:path';
import { ensureStateSuffix, isFctQuery, normalizeName, normalizeStateName } from '../utils/normalize.js';

export type GeoLga = {
  id: number;
  name: string;
  slug: string;
  stateId: number;
  stateSlug: string;
};

export type GeoState = {
  id: number;
  name: string;
  slug: string;
  displayName: string;
  lgas: GeoLga[];
};

export class GeoDataService {
  private states: GeoState[] = [];
  private initialized = false;

  async init(dataPath: string) {
    if (this.initialized) return;
    const absolute = path.resolve(dataPath);
    const raw = await fs.readFile(absolute, 'utf-8');
    const decoded = JSON.parse(raw);

    const stateList = Array.isArray(decoded) ? decoded : decoded.states ?? [];
    const parsed: GeoState[] = [];

    for (const entry of stateList) {
      if (!entry || typeof entry !== 'object') continue;
      const id = Number(entry.id);
      const name = String(entry.name ?? '');
      const slug = String(entry.slug ?? '');
      const displayRaw = String(entry.display_name ?? name);
      const displayName = ensureStateSuffix(displayRaw || name);

      const lgas: GeoLga[] = [];
      const lgaList = Array.isArray(entry.lgas) ? entry.lgas : [];
      for (const lga of lgaList) {
        if (!lga || typeof lga !== 'object') continue;
        lgas.push({
          id: Number(lga.id),
          name: String(lga.name ?? ''),
          slug: String(lga.slug ?? ''),
          stateId: id,
          stateSlug: slug,
        });
      }

      parsed.push({
        id,
        name,
        slug,
        displayName,
        lgas,
      });
    }

    this.states = parsed;
    this.initialized = true;
  }

  getStates() {
    return this.states;
  }

  matchStateByName(input: string) {
    if (!input) return null;
    const query = normalizeStateName(input);

    if (isFctQuery(query)) {
      return (
        this.states.find((s) => normalizeName(s.name).includes('federal capital territory')) ||
        this.states.find((s) => s.slug === 'fct') ||
        null
      );
    }

    const exact = this.states.find((s) => normalizeStateName(s.name) === query);
    if (exact) return exact;

    return (
      this.states.find((s) => {
        const norm = normalizeStateName(s.name);
        return norm.includes(query) || query.includes(norm);
      }) || null
    );
  }

  matchLgaByName(stateId: number | null, input: string) {
    if (!input) return null;
    const query = normalizeName(input);

    const candidates = stateId
      ? this.states.find((s) => s.id === stateId)?.lgas ?? []
      : this.states.flatMap((s) => s.lgas);

    let contains: GeoLga | null = null;
    for (const lga of candidates) {
      const norm = normalizeName(lga.name);
      if (norm === query) return lga;
      if (!contains && (norm.includes(query) || query.includes(norm))) {
        contains = lga;
      }
    }
    return contains;
  }
}
