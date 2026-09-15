---
name: hlv-docs-review
description: Systematically review all Higher Logic Vanilla (HLV) documentation from the Success Community KB. Use when researching HLV features, permissions, configuration, migration settings, or verifying platform capabilities.
---

# HLV Documentation Review

## When to use
- Researching HLV platform features and capabilities
- Verifying permission and role configuration options
- Checking category, moderation, or content settings
- Understanding HLV addons and enterprise features
- Migration planning and launch checklist review
- Answering "can HLV do X?" or "how does HLV handle Y?" questions

## Documentation Source

All documentation is on the Higher Logic Vanilla Success Community:
**Base URL:** `https://success.vanillaforums.com/kb/`

## KB Category Index

Fetch category listing pages to discover articles. Each category page lists its articles with titles and URLs.

| # | Category | URL | Covers |
|---|----------|-----|--------|
| 1 | Getting Started | `/kb/categories/45-getting-started-with-vanilla` | Onboarding, first steps, terminology |
| 2 | Installation & Setup | `/kb/categories/29-installation-setup` | Initial config, SSO, authentication |
| 3 | Categories & Organization | `/kb/categories/87-categories-organization` | Category types, hierarchy, settings |
| 4 | Posting & Content | `/kb/categories/79-posting-content` | Post types (Discussion, Question, Idea, Poll), rich editor, formatting |
| 5 | Knowledge Base | `/kb/categories/16-knowledge-base` | KB articles, permissions, migrations, universal content |
| 6 | Enterprise Features | `/kb/categories/13-enterprise-features` | Groups, multi-community, advanced features |
| 7 | Addons | `/kb/categories/4-addons` | All available plugins and extensions |
| 8 | Moderation Addons | `/kb/categories/85-moderation-add-ons` | Spam, keyword blocking, reporting, moderation tools |
| 9 | Developer Documentation | `/kb/categories/27-developer-documentation` | API v2, webhooks, custom development |
| 10 | Theme Development | `/kb/categories/132-theme-development` | Theming, layouts, CSS, widgets |
| 11 | Your Vanilla Account | `/kb/categories/56-your-vanilla-account` | User profiles, settings, notifications |

## Critical Articles (fetch these first)

These are the highest-priority articles for migration and configuration work:

| Article | URL | Why Critical |
|---------|-----|-------------|
| Roles & Permissions | `/kb/articles/39-roles-permissions` | Complete permission model, role types, global vs category perms |
| Category Configuration | `/kb/articles/8-category-configuration-management` | All category settings, visibility, post types |
| Category Types | `/kb/articles/293-category-types` | Discussion, Heading, Redirect, Nested category types |
| KB Permissions | `/kb/articles/185-knowledge-base-permissions` | Who can create/manage KB content |
| KB Overview | `/kb/articles/344-knowledge-base-training` | Full KB feature guide |
| KB Guide | `/kb/articles/81-a-guide-to-vanilla-knowledge` | Detailed KB setup instructions |
| Universal KB Content | `/kb/articles/186-universal-knowledge-base-content` | Shared content across KBs |
| Manage Roles with SSO | `/kb/articles/179-managing-roles-with-sso` | SSO role mapping (critical for Spotify OAuth) |
| Addon Master List | `/kb/articles/115-addon-master-list` | All available addons and their functions |
| Migration Launch Checklist | `/kb/articles/346-migration-launch-checklist` | Official checklist for platform migrations |
| KB Migrations | `/kb/articles/198-knowledge-base-migrations-to-vanilla` | Migrating KB content into HLV |
| Create User Accounts | `/kb/articles/129-create-user-accounts` | User creation and role assignment |
| Keyword Blocker | `/kb/articles/269-keyword-blocker` | Content moderation keyword filtering |
| Language Translation | `/kb/articles/377-language-translation-overview` | Multi-language support |
| Rich Editor Tables | `/kb/articles/617-rich-editor-table-formatting` | Content formatting capabilities |
| Discussion List Widget | `/kb/articles/412-discussion-list-widget` | Homepage/layout widget configuration |
| Featured Categories Widget | `/kb/articles/399-featured-categories-widget` | Category display widgets |

## Review Workflow

### Step 1: Full Sweep (fetch all category pages)

For each category in the index above, use WebFetch to load the category page and extract the full list of article titles and URLs within it.

```
For each category URL:
  1. WebFetch the category page
  2. Extract all article titles and URLs
  3. Log them to a master list
  4. Note any articles relevant to the current task
```

Run categories in parallel where possible (batch 3-4 at a time).

### Step 2: Deep Read (fetch critical articles)

Fetch and read each Critical Article listed above. For each article, extract:
- **Feature name and description**
- **Configuration options** (settings, toggles, dropdowns)
- **Permission requirements** (who can do what)
- **Limitations or gotchas**
- **API endpoints** (if mentioned)

### Step 3: Targeted Research

Based on the specific question or task, fetch additional articles discovered in Step 1. Prioritise articles that:
- Mention permissions, roles, or access control
- Describe category or board configuration
- Cover moderation or content management
- Relate to SSO, authentication, or user management
- Discuss migration, import, or data handling

### Step 4: Compile Findings

Structure output as:

```
## HLV Documentation Review: [Topic]

### Key Findings
- [Finding 1 with source article link]
- [Finding 2 with source article link]

### Configuration Options
| Setting | Values | Default | Article |
|---------|--------|---------|---------|

### Permissions Required
| Action | Permission | Roles | Article |
|--------|-----------|-------|---------|

### Limitations / Gotchas
- [Limitation with source]

### Open Questions
- [Things not covered in docs that need HLV team confirmation]
```

## API Documentation

HLV has a full REST API (v2). Key endpoints for configuration research:

- **API Overview:** `/kb/articles/40-api-v2-overview`
- **Base URL pattern:** `https://{community-url}/api/v2/`
- **Auth:** Bearer token or API key
- **Key endpoints:**
  - `GET /api/v2/roles` - list all roles
  - `GET /api/v2/categories` - list all categories with settings
  - `GET /api/v2/discussions` - list discussions
  - `GET /api/v2/knowledge-bases` - list KBs
  - `GET /api/v2/addons` - list installed addons

## Vanilla MCP Server

If the Vanilla MCP server is connected (check with `mcp__vanilla-mcp__*` tools), use it to query the actual staging/prod instance directly for:
- Current role configuration
- Installed addons and their settings
- Category structure and permissions
- User counts per role

This gives ground truth vs what the docs say is possible.

## Cross-Reference Sources

When reviewing docs, also check these for Spotify-specific context:
- **Slack:** `#community-ingelby` for HLV implementation decisions
- **Slack:** `#community-team` for broader migration discussions
- **Google Sheet:** Role & Permission matrix (spreadsheet ID: `1TEFk-MEOXlJr5OZD82eXwAV5_HWkMcwWlaUhQNfmv9I`)
- **GitHub:** `vanillaforums/spotify` repo for Spotify-specific customisations
- **GitHub:** `vanillaforums/vanilla-local` for platform source code reference

## Notes

- HLV docs can be long; WebFetch may truncate. If truncated, note what's missing and try fetching specific sections.
- Article numbers in URLs (e.g., `39-roles-permissions`) are stable IDs.
- The Success Community itself runs on HLV, so its structure demonstrates the platform's capabilities.
- "Vanilla" and "Higher Logic Vanilla" (HLV) are the same product. "Vanilla Forums" was the old company name before Higher Logic acquired it.
