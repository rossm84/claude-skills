process.chdir(__dirname);
const connect = require('./lib'); const fs = require('fs');
const spec = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const esc = s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
(async () => {
  const b = await connect();
  const p = b.contexts()[0].pages().find(p => p.url().includes('concursolutions'));
  await p.bringToFront(); await p.keyboard.press('Escape');
  // Itemise mode: run from the expense's Itemisations tab or an open itemisation.
  // spec: {mode:"itemize", expect:"1,335.96", edit:[{n,date,amount,comment}], add:[{type,date,amount,comment}]}
  if (spec.mode === 'itemize') {
    const body = async () => p.innerText('body');
    if (!(await body()).includes(spec.expect)) { console.log('ABORT: parent amount not on page'); process.exit(1); }
    const fillItem = async (it) => {
      if (it.type) {
        const cb = p.locator('[role=combobox]').first();
        await cb.click(); await p.waitForTimeout(600); await cb.fill(it.type).catch(() => p.keyboard.type(it.type)); await p.waitForTimeout(1500);
        await p.getByRole('option', { name: new RegExp('^' + esc(it.type)) }).first().click(); await p.waitForTimeout(2000);
      }
      const di = p.locator('input[id^=transactionDate]'); await di.fill(it.date); await di.press('Tab');
      const am = p.getByRole('textbox', { name: 'Amount', exact: true }); await am.fill(it.amount); await am.press('Tab');
      if (it.comment) await p.locator('textarea#comment').fill(it.comment);
      await p.getByRole('button', { name: /^Save Itemi[sz]ation/ }).first().click(); await p.waitForTimeout(4000);
      const d = p.locator('[role=alertdialog]'); if (await d.count()) { console.log('DIALOG', (await d.innerText()).replace(/\s+/g, ' ')); await d.getByRole('button').last().click(); await p.waitForTimeout(1500); }
      const m = (await body()).match(/Itemised\s*€\s*[\d,.]+[\s\S]{0,40}Remaining\s*€\s*[\d,.]+/); console.log('  saved', it.date, it.amount, '|', m ? m[0].replace(/\s+/g, ' ') : '');
    };
    const openItem = async (n) => {
      if (!(await p.getByRole('button', { name: /^Save Itemi[sz]ation/ }).count()) || !(await body()).includes(`${n} of `)) {
        if (!(await body()).includes('Add Itemisation')) { await p.getByRole('button', { name: 'Itemisations' }).first().click().catch(() => p.getByText('Itemisations', { exact: true }).first().click()); await p.waitForTimeout(2500); }
        await p.getByText('Hotel Room Rate', { exact: true }).nth(n - 1).click(); await p.waitForTimeout(3000);
      }
    };
    for (const it of spec.edit || []) { await openItem(it.n); console.log('EDIT', it.n, (await body()).match(/\d+ of \d+/)?.[0]); await fillItem(it); }
    for (const it of spec.add || []) {
      if (!(await body()).includes('Add Itemisation')) { await p.getByText('Expense', { exact: true }).first().click().catch(() => {}); await p.waitForTimeout(2500); }
      await p.getByRole('button', { name: 'Add Itemisation' }).click(); await p.waitForTimeout(3000);
      console.log('ADD', it.type); await fillItem(it);
    }
    await p.screenshot({ path: 'itemize-result.png' }); process.exit(0);
  }
  if (!(await p.innerText('body')).includes('Viewing expense')) {
    const row = p.locator('[role=row]').filter({ hasText: 'Select expense' }).nth(spec.idx-1);
    await row.locator('[role=gridcell],[role=cell],td').nth(6).click(); await p.waitForTimeout(4000);
    const fs2 = p.getByRole('button', { name: 'Show full screen view' }); if (await fs2.count()) { await fs2.click(); await p.waitForTimeout(3000); }
  }
  const cur = async () => +((await p.innerText('body')).match(/Viewing expense (\d+) of/)||[])[1];
  for (let g=0; g<15 && (await cur()) !== spec.idx; g++) {
    const c = await cur();
    await p.locator(c < spec.idx ? 'button[aria-label*="Next" i]' : 'button[aria-label*="Previous" i]').first().click();
    await p.waitForTimeout(3000);
  }
  const head = (await p.innerText('body')).match(/Viewing expense[^\n]*\n[^\n]*/)[0].replace('\n',' ');
  console.log('ON', head);
  if (!head.includes(spec.expect)) { console.log('ABORT: amount mismatch'); process.exit(1); }
  const combo = async (i, text, pick) => {
    const cb = p.locator('[role=combobox]').nth(i);
    await cb.click(); await p.waitForTimeout(600);
    await cb.fill(text).catch(()=>p.keyboard.type(text)); await p.waitForTimeout(2000);
    const o = p.getByRole('option', { name: new RegExp(esc(pick || text)) }).first();
    await o.click(); await p.waitForTimeout(2500);
  };
  if (spec.type) await combo(0, spec.type);
  await p.getByRole('textbox', { name: 'Business Purpose' }).fill(spec.bp);
  if (spec.city) await combo(1, spec.city.search, spec.city.pick);
  for (const [lab, val] of Object.entries(spec.text || {})) await p.getByLabel(lab, { exact: true }).fill(val);
  for (const [lab, val] of Object.entries(spec.combos || {})) {
    const cb = p.getByRole('combobox', { name: lab });
    await cb.click(); await p.waitForTimeout(600); await cb.fill(val.search||val).catch(()=>p.keyboard.type(val.search||val)); await p.waitForTimeout(1500);
    await p.getByRole('option', { name: new RegExp(esc(val.pick||val)) }).first().click(); await p.waitForTimeout(1000);
  }
  if (spec.receiptStatus) {
    const cbs = p.locator('[role=combobox]'); const n = await cbs.count();
    for (let i=0;i<n;i++) { const v = (await cbs.nth(i).inputValue().catch(()=> cbs.nth(i).innerText())).trim(); if (/^(Tax Receipt|Receipt|No Receipt|None Selected)$/.test(v)) { await cbs.nth(i).click(); await p.waitForTimeout(600); await p.getByRole('option', { name: spec.receiptStatus, exact: true }).click(); break; } }
  }
  await p.locator('textarea#comment').fill(spec.comment);
  for (const f of spec.files || []) {
    if (await p.locator('input[type=file]').count()) await p.locator('input[type=file]').last().setInputFiles(f);
    else { await p.getByRole('button', { name: /^Add( Receipt)?$/ }).last().click(); await p.locator('input[type=file]').first().waitFor({ state: 'attached', timeout: 10000 }); await p.locator('input[type=file]').last().setInputFiles(f); }
    await p.waitForTimeout(3000);
    const dlg = p.locator('[role=alertdialog]'); if (await dlg.count()) { await dlg.getByRole('button', { name: 'Add Receipt' }).click(); }
    await p.waitForTimeout(6000);
  }
  await p.getByRole('button', { name: /^Save Expense/ }).first().click();
  await p.waitForTimeout(5000);
  await p.screenshot({ path: `saved-${spec.idx}.png` });
  const t = await p.innerText('body');
  console.log('AFTER', (t.match(/Viewing expense[^\n]*\n[^\n]*/)||['(back on list)'])[0].replace('\n',' '));
  const err = t.match(/(Error[^\n]{0,200})/g); console.log('ERRORS', err ? [...new Set(err)].slice(0,6) : 'none');
  process.exit(0);
})();
