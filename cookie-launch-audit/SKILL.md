---
name: cookie-launch-audit
description: Use when checking cookie consent / ODPO readiness for the community.spotify.com Higher Logic Vanilla launch. Runs a live anonymous cookie test of community-prod (Playwright) plus a read-only audit of the doc, sheets, tracker, Gmail, Slack, Jira and Coda, and writes a go/no-go report. Triggers - "cookie audit", "cookie launch check", "ODPO check", "is cookie consent ready".
---

# Cookie launch audit (community.spotify.com → HLV)

**This skill is READ-ONLY.** Never post, send, edit, react, comment, transition or draft anything. The only file it writes is the report.

## Context
- Go-live is Tue 6 Oct 2026 at 14:00 BST. Before cutover the prod host is community-prod.spotify.com; after cutover it's community.spotify.com.
- **Legal launch condition** (Marjorie Wilson, 2 Oct 2026): only Strictly Necessary cookies before consent, and Vanilla Analytics fully OFF before consent (anonymising isn't enough).
- **Allowed before consent:**
  - Cloudflare: __cf_bm, _cfuvid, cf_clearance
  - Vanilla login/session/security: vf_*_ENDTX, -tk, -sid, ssostatetoken, vfo_s, -Volatile, -AnonymizeData
  - OneTrust: OptanonConsent, OptanonAlertBoxClosed
  - Spotify: sp_t, sp_landing, sp_new
- **Not allowed before consent:**
  - -vA (Vanilla Analytics)
  - -Vv (visit counter; signed-in members only; HLV ticket #475354)
  - __vnOz0 / __vnOz1 (Who's Online)
  - __vnf (Shadow Banning)
  - _ga*, Hotjar _hj*, or any other analytics/ads
- **Background:** the "Research & Launch Decision (2 Oct)" tab in doc 1HK2lAURbVz-lyQHzhhnpNjnPBW1gM9DDAM0xFm8SrSg.

## Step 1: Live cookie test
```bash
cd ~/.claude/skills/cookie-launch-audit/livetest
[ -d node_modules ] || npm i --silent
PLAYWRIGHT_BROWSERS_PATH=~/.cache/ms-playwright node run.js
```
- Output goes to `/tmp/cookie-livetest-YYYY-MM-DD/`. That's one JSON, HTML, requests and screenshot set for each page/locale: forum, discussion and openmic in de and gb, plus khoros.
- Read the JSON files and report:
  - every cookie, whether it's allowed, and which request set it (look especially at POST /forum/api/v2/tick)
  - whether `-vA` is set
  - the inline `vanillaAnalyticsDriver` and `AnonymizeData` values
  - whether OneTrust loads (cdn.cookielaw.org, script 50da44be-0564-43df-b139-329aedcf267b) and whether a banner shows
  - whether GTM-5N5ZCHZT loads
  - whether the footer Cookie Settings button (optanon-show-settings) is present
- **After cutover:** if community.spotify.com resolves to HLV (the cert notAfter is Dec 21/22, not Nov 19), the "khoros" run is now HLV, so treat it as the primary result.
- If Playwright fails, fall back to curl Set-Cookie headers and the HTML. Say that you did.

## Step 2: Read-only audit
**If a source's tools aren't available** (scheduled headless runs have no Google Workspace, Jira or Coda connectors):
- Don't guess. List it under "Not checked (no access)" in the report.
- Slack is still usually available through `mcp__plugin_enterprise-search_slack__*`, and GitHub through `~/bin/gh`.
- The live test (Step 1) always runs.

Read these and check them against each other. Don't trust summaries.

**Google Workspace MCP** (search_tools, then execute_tool with `name`/`args`):
- doc 1HK2lAURbVz-lyQHzhhnpNjnPBW1gM9DDAM0xFm8SrSg, all tabs
- sheet 1q0Y9XDlBB9ElYxfH3i_ARE6Xws71usT5IC12W9mKOog, tabs "Cookies" and "For Legal Review"
- HLV tracker 18Jt5Sa5LTbRby_huSpXvThkyHQFKqeTmZ1_vDRRc4MI, tab "OPEN QUESTIONS FOR HLV", the cookie rows
- Gmail threads:
  - 1a0fddd3e853bdcd "Which cookies can be turned off before consent?"
  - 1a0f7f506bab89d7 "Cookies: open questions for HLV"
  - 1a0f65890d92953e "New Business Request DUE: Mon, Oct 5"
  - anything new from higherlogic.com, ingelby.com, marjories@, corinapopa@ or vivianb@ in the last 2 days

**Slack:**
- C0C66GZJ8MC: Marjorie group DM
- C0C5K66K9U5: CMP team DM
- C0C67VCSAH0: Jamie/Mark group DM
- C01AWP8H3C3: #community-ingelby, for replies to Ross's 2 Oct 22:01 -Vv question
- C8T0Z7VJ5: #office-of-the-dpo

**Jira** (cloudId spotify.atlassian.net): CPM-315, 316, 352, 452, 517, 525, 526, 207. Read the latest comments and statuses.

**Coda** vt7s4PjgkI: CMP-0287 (script ID still blank?), CMP-0288, and whether any HLV/Cloudflare-current cookies are on the Cookies Master Table yet.

**HLV repo:** `gh api repos/vanillaforums/spotify/commits?per_page=10`. Look for recent changes to plugins/spotify-consent or any -Vv plugin.

**Answer these:**
1. Has Marjorie or the ODPO replied? What is the current ruling on -Vv: option 1 (Ingelby expires it), a time-limited exception, or blocked?
2. Has HLV switched off Vanilla Analytics? Is that confirmed in writing, and does the live test agree? Any update on ticket #475354, its ETA, or the DateLastActive side-effect question?
3. Has Ingelby replied or tested the -Vv plugin? Is spotify-consent (OneTrust + GTM) enabled on prod?
4. Has Jamie signed off on losing HLV analytics, the -Vv route, and go/no-go?
5. Do any records contradict each other or the facts? Known traps:
   - "-Vv updates last-visit date" (false)
   - "-Vv anonymous" (false)
   - LithiumVisitor as a Strictly Necessary precedent (rejected)
   - "-vA won't be set" (unverified until tested)
   - mixed cookie counts. The rule is 20 = 19 cookies + 1 storage item.

## Step 3: Report
Write to `~/notes/cookie-audit-YYYY-MM-DD-HHMM.md`, and print the TL;DR at the end of your response. Structure:
1. **TL;DR:** GO / NO-GO / GO-WITH-EXCEPTION for cookies, in 3 lines, plain English.
2. **Live test:** a table of cookie | allowed? | set by | expiry, with PASS/FAIL against the launch condition.
3. **What changed since the last audit:** compare against the most recent `~/notes/cookie-audit-*.md` if one exists.
4. **Outstanding actions:** owner | status | next step.
5. **Discrepancies:** each with a source link or ID and a suggested fix.
6. **Ranked risks for go-live,** each with the decision needed.

Mark every claim as [V] verified or [I] inferred.
