---
name: concur-expenses
description: Use when Ross asks to do, prepare, fill in or tidy an SAP Concur expense claim — matching receipts (emailed photos, OneDrive links, e-receipts) to card transactions, writing Business Purpose/comments, fixing expense types, attaching receipts, attendees, hotel itemisation. Drives Ross's Claude Chrome. Never submits the claim.
---

# Concur expenses (Spotify, UK entity, Citi corporate card)

Never click **Submit Claim**. Ross submits. Saving lines is OK once he has approved the plan.

## 1. Gather
- **Claim**: Concur is open in the Claude Chrome (CDP 9223, see memory `chrome-debug-bridge`). Read the claim list: date, type, supplier, amount, alerts. `scripts/snap.js` screenshots the Concur tab and dumps its text.
- **Receipts**: Ross emails photos from ross.m84@hotmail.com to rossmiller@spotify.com (`gmail.list_messages from:ross.m84@hotmail.com`).
  - Outlook-for-Android "attachments" are usually **OneDrive 1drv.ms links**. Open each link in the browser, take the biggest `<img>` (a blob: URL) and read it in-page with fetch + FileReader. Direct curl to OneDrive is blocked by the sandbox.
  - Real Gmail attachments: open the `download_url` (switch `disp=safe` to `disp=inline`) in a new tab and screenshot the `<img>` at natural size. Don't fetch them with session cookies (blocked, and against Ross's rules).
  - E-receipts (SumUp, Uber, hotels) are in Gmail: screenshot the message body (`div.adn`).
  - Citi "Notification of transaction" emails confirm amounts. A big hotel charge on check-in day is a **pre-auth**.
- **Before screenshotting**: bring the tab to the front. Background tabs hang. Never `setViewportSize` on the shared context; it shrinks Ross's window. If you do, reset with `Emulation.clearDeviceMetricsOverride`.

## 2. Match and check, then show Ross a table before writing anything
Columns: line, date, amount, receipt file(s), problems. Flag:
- missing receipts (ask; e.g. the till printer failed: "No Receipt" status plus an explanation)
- wrong type from the card feed (WH Smith meal deals arrive as Newspapers/Magazines)
- city of purchase wrong (card feed defaults to the trip country)
- hotel needs itemisation; external guests need attendees

Questions to ask: trip purpose (one line), who was at each meal, destinations for taxis, titles.

## 3. Policy (Global Expense & Entertainment Policy, Confluence HR 260380506)
- **Meals on a business trip**: type **Travel Meals**, not "Overtime Meals (Non Travel)", which the card feed often pre-fills. Travel Meals can't have attendees.
- Meal with **Spotify colleagues** while travelling: **Entertainment (with Spotify employees)**. Needs names and titles.
- Meal with **external** people (suppliers/partners such as Sutherland Global): **Business Meals (with clients)** or Entertainment (with business guests). Needs each attendee's name, title and company, plus the business topic.
- **Hotel**: invoice (not proforma) in Spotify's name; room, tax, meals and incidentals must be **itemised**. No minibar alcohol.
- Alcohol is fine with food. Tips: about 10% outside the US. Ross's preference: **don't mention tips in comments**.
- Taxi: OK when no practical public transport (early or late). Put the client names in Comments if travelling with clients.
- Help: expenses@spotify.com.

## 4. Fields
- **Business Purpose**: max **64 chars**, e.g. `Sofia mod team visit - evening meal, launch day`.
- **Comment**: max **500 chars**; Concur refuses to save beyond that. Open with one trip sentence, then what the expense was, where and when, who was there, what's attached.
- **Receipt No**: fiscal sale number (УНП/UNP on Bulgarian receipts), invoice number, or card `Auth NNNNNN`.
- **Receipt Status**: Tax Receipt (default) / Receipt / No Receipt.
- Extra required fields by type: Public Transport needs From Location, To Location and Transport Type (Bus / Ferry / Subway/Tube only, no Tram). Taxi needs Destination. Business Meals needs attendees.
- Fill every field you can: city, Receipt No, Invoice in Company Name (hotel invoiced to Spotify).

## 5. Writing with scripts/fill.js
Ross's permission rule allows exactly: `node <skill>/scripts/fill.js <spec.json>` (it chdirs to its own folder; put specs and receipts next to it, or use absolute paths). Spec:
```json
{"idx":4,"expect":"£7.90","type":"Travel Meals","bp":"...<=64","city":{"search":"Edinburgh","pick":"Edinburgh"},
 "text":{"From Location":"...","Receipt No":"..."},"combos":{"Transport Type":{"search":"Sub","pick":"Subway/Tube"}},
 "receiptStatus":"No Receipt","comment":"...<=500","files":["r/a.jpg","r/b.jpg"]}
```
- `idx` is the "Viewing expense N of M" position. The order **changes** when dates or types change. `expect` (the amount string) makes it abort if it lands on the wrong line, so always set it.
- It handles: split view (clicks "Show full screen view"), the "add image to existing receipt?" confirm, and the hidden upload input (clicks Add).
- **Receipt images can't be removed once merged into a multi-page receipt**, and some lines show no Remove button at all. Get the files right first time. Run **one line per call** and check the result before the next. The auto-mode classifier blocks batch saves and edits to the script's capabilities.
- After a type change Concur may say "saved but missing information" (e.g. attendees). That's expected.

### Hotel itemisation (fill.js itemize mode)
From the hotel's Itemisations tab (Ross or the wizard creates N "Hotel Room Rate" rows first):
```json
{"mode":"itemize","expect":"1,335.96",
 "edit":[{"n":1,"date":"10/04/2026","amount":"186.77","comment":"Night of 4 Oct: room + VAT + supplement"}],
 "add":[{"type":"Room Tax","date":"10/09/2026","amount":"8.35","comment":"City tax 5 x 1.67"}]}
```
Use one Hotel Room Rate per night (room + VAT + per-night supplements) and put city tax under Room Tax. Types available: Hotel Room Rate, Room Tax, Travel Meals, Business Meals, Parking, Laundry, Miscellaneous. The script prints Itemised/Remaining after each save; aim for Remaining € 0.00.

### Speed lessons (Oct 2026 Bulgaria claim)
- Ask every question in one message up front: trip purpose, who was at each meal (name, title, company), taxi destinations, missing receipts, titles.
- **Merge multiple photos into one image or PDF before uploading.** Multiple uploads trigger an async confirm dialog and caused duplicate pages and a stray slip on the wrong line, which can't be removed.
- Keep Concur in full-screen view (not split) and ask Ross not to click while a script runs.
- Ross can send receipts as real attachments, or forward them to receipts@expensit.com so Concur attaches them itself.
- Run fill.js via the skill path: `node ~/.claude/skills/concur-expenses/scripts/fill.js /abs/spec.json` (scripts/package.json forces CommonJS).

## 6. Manual steps for Ross (the script can't do these)
- **Attendees**: Attendees button → Advanced Options → new attendee (Business Guest: name, title, company) → Save. Someone with a spotify.com contractor account can still be external.
- **Hotel itemisation** when nightly rates vary: give him a per-night table (room incl. VAT / supplements / city tax) that sums to the total.
- Removing a wrongly attached receipt.

## 7. Report
Finish with a table per line: what was set, receipts attached, alerts left, and anything Ross must do. Remind him to review, then submit himself.
