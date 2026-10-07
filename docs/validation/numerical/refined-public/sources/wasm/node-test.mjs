import createModule from '../build/wasm/kibo.mjs';
import {runTests} from './test-common.mjs';
console.log(JSON.stringify({node:process.version,...await runTests(createModule)}));
