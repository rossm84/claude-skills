---
name: technical-writer
description: Use when writing or improving technical documentation, API references, user guides, TechDocs, or runbooks. Structured workflow for audience analysis, content audit, writing, and accuracy verification.
---

# Technical Writer

Structured documentation workflow. Use for TechDocs, API references, user guides, runbooks, or any technical content that needs to be clear and accurate.

## Workflow

### 1. Scope
Before writing, answer:
- **Audience:** Who reads this? (engineer, PM, end user, oncall)
- **Goal:** What should the reader be able to DO after reading?
- **Existing docs:** What already exists? Is it outdated, incomplete, or scattered?

### 2. Structure
Pick the right shape:
- **Reference** (API docs, config options): alphabetical/grouped, every field documented, no narrative
- **Guide** (how-to, tutorial): numbered steps, prerequisites up front, expected output at each step
- **Runbook** (oncall, incident): decision tree, copy-pasteable commands, escalation paths
- **Overview** (architecture, design): top-down, diagrams first, link to details

### 3. Write
- Lead with what the reader needs most. Don't build up to it.
- One idea per paragraph. Short paragraphs.
- Code examples must be copy-pasteable and tested. Include expected output.
- Use tables for structured comparisons. Use lists for sequences.
- Link to source code with `file:line` format where useful.
- No filler ("In this document we will..."), no hedging ("It should work...").

### 4. Verify
- Every command in the doc: run it. Does it work?
- Every URL: fetch it. Does it resolve?
- Every claim about behaviour: check the code. Is it true?
- Read it cold. Does it make sense without the conversation that prompted it?

## Backstage TechDocs specifics (Spotify)

When writing for Backstage TechDocs (`mkdocs.yml` + `docs/` folder):
- Use the `spotify-backstage-techdocs` skill for repo setup, CI, and catalog registration
- `mkdocs.yml` must list all pages in `nav:` section
- Supported markdown extensions: `admonition`, `codehilite`, `pymdownx.details`, `pymdownx.superfences`
- Diagrams via Mermaid fenced blocks (```mermaid)
- Keep filenames lowercase-kebab-case
- Index page must exist as `docs/index.md`

## Google Docs specifics

When writing to Google Docs:
- Use `gsuite-cli docs insert` for formatted content (tables, headings, lists)
- Use `gsuite-cli docs table` for cell-level edits
- For new docs: `create_new_drive_file` then `update_drive_file` with HTML, then use gsuite-cli for tables
- Generous whitespace: `<br>` between sections, padding in cells
