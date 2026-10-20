const { chromium } = require('/home/rossmiller/notes/site-audit/node_modules/playwright');
(async () => {
  const v = await (await fetch('http://172.23.48.1:9224/json/version',{headers:{Host:'localhost'}})).json();
  const ws = v.webSocketDebuggerUrl.replace(/ws:\/\/[^/]+/, 'ws://172.23.48.1:9224');
  const b = await chromium.connectOverCDP(ws, { headers: { Host: 'localhost' } });
  const p = b.contexts().flatMap(c => c.pages()).find(p => p.url().includes('concursolutions'));
  console.log(p.url());
  await p.screenshot({ path: process.argv[2] || 'concur.png' });
  console.log((await p.innerText('body')).slice(0, 4000));
  await b.close().catch(()=>{});
})();
