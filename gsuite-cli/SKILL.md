---
name: gsuite-cli
description: Use when working with Google Docs (tables, formatting, insert content), Gmail (send, search, read), Calendar (events, free/busy), Sheets (read, write, append), Slides, Tasks, or Drive via the CLI. Covers all interactive Google Workspace operations from the terminal.
---

# Google Workspace CLI (`gsuite-cli`)

Binary: `~/bin/gsuite-cli`
Config: `~/.gsuite-cli/config.json`
Auth: `gsuite-cli auth status` (currently authenticated as rossmiller@spotify.com)

## Command pattern

```bash
~/bin/gsuite-cli <service> <command> [options]
```

Always use `--json` for parseable output when processing results programmatically.

## Google Docs

```bash
# Get document content (returns structure including tables)
gsuite-cli docs get <docId>

# Create a new doc
gsuite-cli docs create --title "My Doc"

# Insert markdown-formatted content with native Google Docs formatting
gsuite-cli docs insert <docId> --position end --markdown "## Section\nSome **bold** text"
gsuite-cli docs insert <docId> --after "Open Action Items" --markdown "- [ ] New task"
gsuite-cli docs insert <docId> --before "Template" --markdown-file ./section.md

# Tables: list, read cells, write cells
gsuite-cli docs table <docId> --list
gsuite-cli docs table <docId> --get 0 --row 1 --col 0
gsuite-cli docs table <docId> --set 0 --row 1 --col 0 --content "**Bold** cell content"

# Find and replace
gsuite-cli docs replace <docId> --find "old text" --replace "new text"

# Hyperlink text
gsuite-cli docs link <docId> --text "click here" --url "https://example.com"

# Export to file
gsuite-cli docs export <docId> ~/Desktop/doc.pdf
```

### Docs tips
- `--markdown` supports headings, bold, italic, lists, checkboxes, links, code
- Table indices are 0-based (first table = 0)
- `--after` / `--before` match paragraph text, not exact string
- For large content, use `--markdown-file` to avoid shell quoting issues

## Gmail

```bash
# List recent emails
gsuite-cli gmail list
gsuite-cli gmail list --max 20 --unread

# Search (uses Gmail query syntax)
gsuite-cli gmail search "from:someone@example.com subject:review"
gsuite-cli gmail search "is:unread newer_than:1d"

# Read a specific email
gsuite-cli gmail get <messageId>

# Send email
gsuite-cli gmail send --to "user@example.com" --subject "Subject" --body "Body text"
gsuite-cli gmail send --to "user@example.com" --subject "Report" --html "<h1>HTML body</h1>"
gsuite-cli gmail send --to "a@x.com" --cc "b@x.com" --subject "FYI" --body "See attached" --attach ./file.pdf

# Drafts
gsuite-cli gmail drafts
gsuite-cli gmail drafts --max 5

# Labels
gsuite-cli gmail labels

# Attachments
gsuite-cli gmail attachments <messageId>
gsuite-cli gmail download <messageId> <attachmentId> ~/Desktop/

# Archive
gsuite-cli gmail archive <messageId1> <messageId2>
```

### Gmail tips
- Search uses standard Gmail query operators: `from:`, `to:`, `subject:`, `is:unread`, `newer_than:`, `has:attachment`, `label:`
- IMPORTANT: never send an email without Ross's explicit approval. Draft first, confirm, then send.

## Calendar

```bash
# List upcoming events
gsuite-cli calendar list
gsuite-cli calendar list --max 20 --from "2026-07-01" --to "2026-07-07"

# Search events
gsuite-cli calendar search "standup"

# Get event detail
gsuite-cli calendar get <eventId>

# Create event
gsuite-cli calendar create --title "Meeting" --start "2026-07-02T10:00:00" --end "2026-07-02T11:00:00"
gsuite-cli calendar create --title "Sync" --start "2026-07-02T14:00:00" --duration 30 --attendees "a@x.com,b@x.com"

# Update event
gsuite-cli calendar update <eventId> --title "New title"

# Delete event
gsuite-cli calendar delete <eventId>

# List calendars
gsuite-cli calendar calendars

# RSVP
gsuite-cli calendar respond <eventId> --status accepted

# Free/busy check
gsuite-cli calendar freebusy --calendars "rossmiller@spotify.com" --from "2026-07-02T09:00:00" --to "2026-07-02T17:00:00"
```

## Sheets

```bash
# Get spreadsheet info
gsuite-cli sheets get <spreadsheetId>

# Read range (use double quotes for ranges with ! in zsh)
gsuite-cli sheets read <spreadsheetId> "Sheet1!A1:D10"

# Write data (values as JSON array of arrays)
gsuite-cli sheets write <spreadsheetId> "Sheet1!A1" --values '[["Header1","Header2"],["val1","val2"]]'

# Append a row
gsuite-cli sheets append <spreadsheetId> "Sheet1!A:D" --values '[["new","row","data","here"]]'

# Clear a range
gsuite-cli sheets clear <spreadsheetId> "Sheet1!A1:D10"

# Create new spreadsheet
gsuite-cli sheets create --title "My Sheet"

# Export
gsuite-cli sheets export <spreadsheetId> ~/Desktop/sheet.xlsx
```

## Drive

```bash
gsuite-cli drive list
gsuite-cli drive search "name contains 'quarterly'"
gsuite-cli drive get <fileId>
gsuite-cli drive download <fileId> ~/Desktop/
gsuite-cli drive upload ~/Desktop/file.pdf --name "Report" --parent <folderId>
gsuite-cli drive mkdir "New Folder" --parent <folderId>
```

## Slides

```bash
gsuite-cli slides get <presentationId>
gsuite-cli slides create --title "New Deck"
```

## Tasks

```bash
gsuite-cli tasks lists
gsuite-cli tasks list --list <listId>
gsuite-cli tasks create --list <listId> --title "Do the thing"
gsuite-cli tasks complete --list <listId> <taskId>
```

## Extracting document IDs

Google Docs/Sheets/Slides URLs follow this pattern:
- `https://docs.google.com/document/d/<DOCUMENT_ID>/edit`
- `https://docs.google.com/spreadsheets/d/<SPREADSHEET_ID>/edit`
- `https://docs.google.com/presentation/d/<PRESENTATION_ID>/edit`

Extract the ID between `/d/` and the next `/`.

## When to use this vs MCP tools

| Task | Use gsuite-cli | Use MCP |
|------|---------------|---------|
| Insert formatted content / tables into Docs | Yes | No (MCP can't do tables) |
| Read Doc structure / sections | Either | GDrive MCP is fine |
| Send/read Gmail | Yes | No Gmail MCP available |
| Calendar events | Yes | No Calendar MCP available |
| Sheets cell-level read/write | Yes | Enterprise Context for create/update |
| Create Google Doc from scratch | Either | Enterprise Context works |
| Search Drive files | Either | GDrive MCP works |
