import {chromium,firefox,webkit} from 'playwright';
import {createServer} from 'node:http';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {resolve,sep,extname} from 'node:path';
const root=resolve('..');
const server=createServer(async(request,response)=>{
    try {
        const path=resolve(root,'.'+decodeURIComponent(new URL(request.url,'http://localhost').pathname));
        if (!path.startsWith(root+sep)) {response.writeHead(403).end();return;}
        const type={'.mjs':'text/javascript','.wasm':'application/wasm','.html':'text/html'}[extname(path)] ?? 'application/octet-stream';
        const contents=await readFile(path);
        response.writeHead(200,{'Content-Type':type});response.end(contents);
    } catch {response.writeHead(404).end();}
});
await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
const port=server.address().port;
const results=[];
try {
    for(const [name,engine] of Object.entries({chromium,firefox,webkit})) {
        const browser=await engine.launch({headless:true});
        try {
            const page=await browser.newPage();
            await page.goto(`http://127.0.0.1:${port}/wasm/index.html`);
            const result=await page.evaluate(async()=>{
                const {default:createModule}=await import('/build/wasm/kibo.mjs');
                const {runTests}=await import('/wasm/test-common.mjs');
                return runTests(createModule);
            });
            results.push({engine:name,version:browser.version(),...result});
            console.log(JSON.stringify(results.at(-1)));
        } finally {await browser.close();}
    }
    await mkdir('../build/wasm',{recursive:true});
    await writeFile('../build/wasm/browser-results.json',JSON.stringify(results,null,2)+'\n');
} finally {server.close();}
