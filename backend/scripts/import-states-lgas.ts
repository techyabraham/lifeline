import { importStatesLgas } from '../src/import/importStatesLgas.js';

const result = await importStatesLgas('data/states_lgas.json');
// eslint-disable-next-line no-console
console.log('Imported states/LGAs', result);
