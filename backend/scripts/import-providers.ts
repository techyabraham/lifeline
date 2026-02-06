import { importProviders } from '../src/import/importProviders.js';

const result = await importProviders({
  csvPath: 'data/providers.csv',
  jsonPath: 'data/states_lgas.json',
  checkpointPath: 'data/import_checkpoint.json',
  errorCsvPath: 'data/import_errors.csv',
});
// eslint-disable-next-line no-console
console.log('Import result', result);
