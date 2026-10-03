const { chromium } = require('playwright');
const fs = require('fs');
const OUT = process.env.OUT || ('/tmp/cookie-livetest-' + new Date().toISOString().slice(0,10));
fs.mkdirSync(OUT, { recursive: true });
const ALLOWED = [/^__cf_bm$/, /^_cfuvid$/, /^cf_clearance$/, /^vf_.*_ENDTX$/, /-tk$/, /-sid$/, /^ssostatetoken$/, /^vfo_s$/, /-Volatile$/, /-AnonymizeData$/, /^OptanonConsent$/, /^OptanonAlertBoxClosed$/, /^sp_t$/, /^sp_landing$/, /^sp_new$/];
const isAllowed = n => ALLOWED.some(r => r.test(n));
const locales = [{ locale: 'de-DE', timezoneId: 'Europe/Berlin', tag: 'de' }, { locale: 'en-GB', timezoneId: 'Europe/London', tag: 'gb' }];

const initScript = () => {
  window.__cookieWrites = [];
  try {
    const desc = Object.getOwnPropertyDescriptor(Document.prototype, 'cookie');
    Object.defineProperty(document, 'cookie', {
      configurable: true,
      get() { return desc.get.call(document); },
      set(v) { window.__cookieWrites.push({ v: String(v).slice(0, 300), t: Date.now(), stack: (new Error().stack || '').split('\n').slice(2, 6).join(' | ') }); return desc.set.call(document, v); }
    });
  } catch (e) {}
};

async function run(browser, loc, name, url) {
  const ctx = await browser.newContext({ locale: loc.locale, timezoneId: loc.timezoneId, viewport: { width: 1366, height: 900 },
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36' });
  await ctx.addInitScript(initScript);
  const page = await ctx.newPage();
  const requests = [], setCookies = [], ticks = [];
  ctx.on('request', r => requests.push({ method: r.method(), url: r.url(), type: r.resourceType() }));
  ctx.on('response', async resp => {
    const req = resp.request();
    let hs = [];
    try { hs = await resp.headersArray(); } catch (e) {}
    for (const h of hs) if (h.name.toLowerCase() === 'set-cookie') setCookies.push({ method: req.method(), url: req.url(), status: resp.status(), setCookie: h.value });
    if (/\/api\/v2\/tick/.test(req.url())) {
      let body = null; try { body = await resp.text(); } catch (e) { body = '<unavailable: ' + e.message + '>'; }
      ticks.push({ method: req.method(), url: req.url(), reqHeaders: await req.allHeaders().catch(() => ({})), postData: req.postData(), status: resp.status(), respHeaders: hs, body });
    }
  });
  const t0 = Date.now();
  let nav = null, navErr = null;
  try { nav = await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 }); } catch (e) { navErr = e.message; }
  const chain = [];
  if (nav) { let r = nav.request(); while (r) { chain.unshift(r.url()); r = r.redirectedFrom(); } }
  await page.waitForTimeout(10000);
  const finalUrl = page.url();
  const html = await page.content();
  await page.screenshot({ path: `${OUT}/${name}-${loc.tag}.png`, fullPage: false });
  const cookies = await ctx.cookies();
  const storage = await page.evaluate(() => ({
    local: Object.keys(localStorage), session: Object.keys(sessionStorage),
    cookieWrites: window.__cookieWrites || [],
    gdnMeta: (window.gdn && window.gdn.meta) ? { AnonymizeData: window.gdn.meta.AnonymizeData, vanillaAnalyticsDriver: window.gdn.meta.vanillaAnalyticsDriver } : null,
    hasOneTrustGlobal: typeof window.OneTrust !== 'undefined', hasOptanon: typeof window.Optanon !== 'undefined',
    dataLayer: (window.dataLayer || []).slice(0, 30).map(x => { try { return JSON.stringify(x).slice(0, 200) } catch (e) { return '?' } }),
    gtmKeys: window.google_tag_manager ? Object.keys(window.google_tag_manager) : [],
    bannerVisible: (() => { const b = document.querySelector('#onetrust-banner-sdk'); if (!b) return null; const s = getComputedStyle(b); return { display: s.display, visibility: s.visibility, h: b.offsetHeight }; })(),
    footerLinks: [...document.querySelectorAll('.optanon-show-settings, .ot-sdk-show-settings, #ot-sdk-btn')].map(a => ({ tag: a.tagName, cls: a.className, text: (a.textContent || '').trim().slice(0, 80), id: a.id, visible: a.offsetParent !== null })),
    cookieishLinks: [...document.querySelectorAll('a,button')].filter(a => /cookie/i.test(a.textContent || '') || /cookie/i.test(a.getAttribute('href') || '')).map(a => ({ text: (a.textContent || '').trim().slice(0, 80), href: a.getAttribute('href'), cls: a.className })).slice(0, 20),
  })).catch(e => ({ err: e.message }));
  const grab = (re) => { const out = []; let m; const g = new RegExp(re, 'g'); while ((m = g.exec(html)) && out.length < 5) out.push(html.slice(Math.max(0, m.index - 40), m.index + 120)); return out; };
  const htmlChecks = {
    cookielaw: /cdn\.cookielaw\.org/.test(html), otSDKStub: /otSDKStub/.test(html), domainScript: /50da44be-0564-43df-b139-329aedcf267b/.test(html),
    gtm: /GTM-5N5ZCHZT/.test(html), anonymizeCtx: grab('AnonymizeData'), analyticsDriverCtx: grab('vanillaAnalyticsDriver'),
  };
  const netChecks = {
    cookielawReqs: requests.filter(r => /cookielaw\.org|onetrust/.test(r.url)).map(r => r.url),
    gtmReqs: requests.filter(r => /googletagmanager|google-analytics|analytics\.google|doubleclick|hotjar|facebook|clarity/.test(r.url)).map(r => r.url),
    thirdPartyHosts: [...new Set(requests.map(r => { try { return new URL(r.url).host } catch (e) { return r.url } }))],
  };
  // Pref centre test: only if OneTrust loaded and footer link present
  let prefCentre = { attempted: false };
  if ((netChecks.cookielawReqs.length || storage.hasOneTrustGlobal) && storage.footerLinks && storage.footerLinks.length) {
    prefCentre.attempted = true;
    const cookiesBefore = cookies.map(c => c.name);
    try {
      const link = page.locator('.optanon-show-settings, .ot-sdk-show-settings, #ot-sdk-btn').first();
      await link.scrollIntoViewIfNeeded(); await link.click({ timeout: 5000 });
      await page.waitForTimeout(3000);
      prefCentre.pcVisible = await page.evaluate(() => { const p = document.querySelector('#onetrust-pc-sdk'); if (!p) return null; const s = getComputedStyle(p); return { display: s.display, visibility: s.visibility, h: p.offsetHeight }; });
      await page.screenshot({ path: `${OUT}/${name}-${loc.tag}-prefcentre.png` });
      const after = await ctx.cookies();
      prefCentre.newCookiesAfterClick = after.map(c => c.name).filter(n => !cookiesBefore.includes(n));
    } catch (e) { prefCentre.err = e.message; }
  }
  const result = { name, url, locale: loc, navErr, status: nav && nav.status(), redirectChain: chain, finalUrl, elapsedMs: Date.now() - t0,
    cookies: cookies.map(c => ({ name: c.name, domain: c.domain, path: c.path, expires: c.expires === -1 ? 'session' : new Date(c.expires * 1000).toISOString(), httpOnly: c.httpOnly, secure: c.secure, sameSite: c.sameSite, allowed: isAllowed(c.name) })),
    setCookies, ticks, storage, htmlChecks, netChecks, prefCentre, requestCount: requests.length };
  fs.writeFileSync(`${OUT}/${name}-${loc.tag}.json`, JSON.stringify(result, null, 2));
  fs.writeFileSync(`${OUT}/${name}-${loc.tag}.html`, html);
  fs.writeFileSync(`${OUT}/${name}-${loc.tag}-requests.json`, JSON.stringify(requests, null, 2));
  await ctx.close();
  return { result, html };
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const which = process.argv[2] || 'all';
  let discussion = process.argv[3] || null;
  for (const loc of locales) {
    const f = await run(browser, loc, 'forum', 'https://community-prod.spotify.com/forum/');
    if (!discussion) {
      const m = f.html.match(/href="(https:\/\/community-prod\.spotify\.com\/forum\/discussion\/\d+[^"]*)"/) || f.html.match(/href="(\/forum\/discussion\/\d+[^"]*)"/);
      discussion = m ? (m[1].startsWith('http') ? m[1] : 'https://community-prod.spotify.com' + m[1]) : null;
      console.log('discussion:', discussion);
    }
    if (discussion) await run(browser, loc, 'discussion', discussion);
    await run(browser, loc, 'openmic', 'https://community-prod.spotify.com/openmic/');
  }
  await run(browser, locales[1], 'khoros', 'https://community.spotify.com/');
  await browser.close();
  console.log('done');
})();
