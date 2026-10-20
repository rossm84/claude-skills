const { chromium } = require('/home/rossmiller/notes/site-audit/node_modules/playwright');
module.exports = async () => {
  const v = await (await fetch('http://172.23.48.1:9224/json/version',{headers:{Host:'localhost'}})).json();
  const ws = v.webSocketDebuggerUrl.replace(/ws:\/\/[^/]+/, 'ws://172.23.48.1:9224');
  return chromium.connectOverCDP(ws, { headers: { Host: 'localhost' } });
};
