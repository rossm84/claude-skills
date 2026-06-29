---
name: khoros-user-roles
description: Use when pulling user lists by role from Khoros community.spotify.com, classifying users (staff/agent/advisor), or preparing user data for the HLV migration import.
---

# Khoros User Role Export

## When to use
- Someone asks for a list of users with a specific Khoros role (e.g. CS_001 / Open Mic)
- Classifying community users as Spotify staff vs outsourced agents vs community advisors
- Preparing user role data for the HLV (Higher Logic Vanilla) migration import
- Cross-referencing community users with Spotify accounts

## Custom Plugin Endpoint

The standard Khoros LiQL API and REST v1 `/roles/{id}/users/list` do NOT return role members (permission issue). Use the custom plugin endpoint instead:

```
POST https://community.spotify.com/spotify/plugins/custom/spotify/spotify/list_users_by_role_rolling?p={API_KEY}&r={ROLE}&limit=100&page={PAGE}
```

The API key and staging credentials are in the existing Google Apps Script (see "Existing Apps Script" section below). Do not hardcode credentials in this file.

Parameters:
- `p` -- API key (from the Apps Script)
- `r` -- role name (e.g. `CS_001`)
- `limit` -- results per page (max 100)
- `page` -- page number (1-indexed)

Response:
```json
{
  "data": {
    "size": 100,
    "items": [
      {"id": "12345", "login": "username", "email": "user@example.com"}
    ]
  }
}
```

Paginate until `data.size < limit`.

For staging: use `https://community-stage.spotify.com` with Basic Auth (credentials in the Apps Script).

## Known Roles

| Role | What it gates |
|------|---------------|
| `CS_001` | Open Mic (hidden boards: open-mic, cs_ideas_01, cs_ato, cs_offtopic, cs_internal_faqs, cs_training_feedback) |
| `CS_001_Moderator` | Moderator access to CS_001 boards |

To discover all roles: `SELECT id, name FROM roles LIMIT 200` via authenticated LiQL session.

## User Classification

Classify by email domain:

| Domain | Classification |
|--------|---------------|
| `@spotify.com` | Spotify Staff |
| `@sutherlandglobal.com` | Outsourced Agent (Sutherland) |
| `@concentrix.com` | Outsourced Agent (Concentrix) |
| `@modsquad.network`, `@modsquad.com` | Community Advisor (ModSquad) |
| `@24-7intouch.com`, `@client.24-7intouch.com` | Community Advisor (24-7 InTouch) |
| `@taskus.com` | Community Advisor (TaskUs) |
| Other | Review manually |

Also cross-reference with `S4D_STAFF_USERS` and `S4D_STAFF_ROLES` in `community-export-api/main.py` (lines 2182-2194).

## HLV Migration Role Mapping

Higher Logic Vanilla does not auto-map Khoros roles. Manual steps:

1. **Spotify Staff**: Gate the Open Mic category behind SSO in Vanilla. No separate role needed.
2. **Outsourced Agents**: Create a Vanilla role (e.g. "CS Agent") via dashboard or `POST /api/v2/roles`. Grant access to Open Mic category.
3. **Community Advisors**: Create a Vanilla role (e.g. "Community Advisor"). Confirm with Jamie Johnston whether they keep Open Mic access on HLV.
4. **Migration import**: In the HLV bulk import CSV, include a `roleID` column per user. Matthew Crouse (HLV) handles field mapping.
5. **Vanilla API**: `GET /api/v2/roles` to list roles, `POST /api/v2/roles` to create, `PATCH /api/v2/users/{id}` to assign.

## CS_001 Snapshot (2026-06-29)

Total: 7,107 users
- Spotify Staff: 226
- Outsourced Agents: 5,166 (Sutherland 3,438 / Concentrix 1,728)
- Community Advisors: 1,715 (ModSquad 1,563 / 24-7 InTouch 142 / TaskUs 6 / other 4)

Sheet: https://docs.google.com/spreadsheets/d/1Pvmis2K1RGdw-XSuQ4pq4fGCZEqW_RQcbtnHkDZ7GtU/edit
Melody's original sheet: https://docs.google.com/spreadsheets/d/16xOQL8siVZgFrfW0EkvGqzmEF7b_y8emZiqCnptxI6w/edit

## Existing Apps Script

There is an existing Google Apps Script (owned by Melody/Jamie) that runs this same endpoint and populates a "Users" sheet. It paginates 100 per run, tracks progress in cells L1/J1/N1/O1, and deduplicates by user ID. The API key and staging credentials are stored in that script.

## Related

- SAR pipeline does NOT include community data. See the SAR assessment doc.
- User ID mapping (Khoros to Spotify): `cs-analytics-dev.khoros_data.khoros_conversation_userid_mapping_snapshot_YYYYMMDD`
- SAR doc: https://docs.google.com/document/d/1K_r2OLtIvzyqb_6jJ1TExXU5hKJ8jWMNwj-IuiI0WtE/edit
