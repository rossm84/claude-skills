---
name: review-gdoc
description: Fetches a Google Doc via the Enterprise Context Agent MCP and opens claudit for inline element-level review with rendered markdown. Use when the user shares a Google Docs URL and asks for review, or wants structured feedback on a Drive-hosted design doc, RFC, or spec.
---

# Review Google Doc

Fetches a Google Doc, converts it to a local markdown file, and opens claudit for inline element-level commenting. After review, optionally pushes content changes back to the source Doc.

## When to use

- User shares a Google Docs URL and asks for review.
- User asks to review a design doc, RFC, or spec stored in Google Drive.
- After authoring a Doc and wanting structured AI-assisted review before sharing it broadly.

## Usage

```
/review-gdoc <google-docs-url-or-id>
```

For a markdown file you already have cached locally, the user can run `claudit gdoc <path> [--source-url <url>]` directly in their terminal — no skill invocation needed.

## Procedure

When invoked with a Google Docs URL or ID:

1. Call `mcp__claude_ai_Spotify_s_Enterprise_Context_Agent__read_drive_file` with the URL or ID to fetch the doc content.
2. If the response is HTML or rich text, convert it to markdown. Preserve heading levels, lists, paragraph breaks, tables, code blocks, and inline emphasis. Strip Drive metadata that isn't part of the doc body.
3. Sanitize the doc title for a filename: lowercase, replace spaces and non-alphanumeric chars with `-`, collapse repeats. Example: "Q3 Spec — Foo Service" becomes `q3-spec-foo-service`.
4. Write the markdown to `.claude/gdoc-cache/<sanitized-title>.md`. Create the directory if missing.
5. Fetch existing Doc comments and persist them next to the markdown so the sidebar can render them:
   1. Call `mcp__claude_ai_GDrive_MCP__list_document_comments` with the file ID. The response includes `comments[]` with `author.display_name`, `content`, `created_time`, `id`, optional `quoted_content`, optional `resolved`, and optional nested `replies[]`. Some replies have `action: "resolve"` and no `content` — drop those, they're system markers, not user replies.
   2. Resolve each unique `display_name` to a Spotify avatar:
      - Read `~/.claude/gdoc-cache/authors.json` if it exists. Schema: `{ "<display_name>": { "email": "...", "avatarUrl": "..." } }`. If the name is already cached, skip the lookup (Bandmanager is ~10 s per author).
      - Otherwise call `mcp__claude_ai_Bandmanager_MCP__entitySearchTool` with the display name. Pick the first result whose `__typename` is `UserAccount` and whose `name` matches the display name exactly — the search is fuzzy and returns dozens of near-matches. Take the matched entity's `id` (an `@spotify.com` email) and set `avatarUrl = https://backstage.spotify.net/api/proxy/avatar/<email>`.
      - Update `~/.claude/gdoc-cache/authors.json` with any newly-resolved entries.
      - If no `UserAccount` matches exactly, store `{ "email": null, "avatarUrl": null }` so we don't retry on every run; the sidebar falls back to initials.
   3. For each comment and reply, replace `author` with `{ displayName, email, avatarUrl }` (camelCase for JS consumption). Drop replies whose `action === "resolve"`.
   4. Write to `.claude/gdoc-cache/<sanitized-title>.comments.json`:
      ```json
      {
        "fileId": "<google-doc-id>",
        "fetchedAt": "<iso-timestamp>",
        "comments": [
          {
            "id": "...",
            "author": { "displayName": "...", "email": "...", "avatarUrl": "..." },
            "content": "...",
            "createdTime": "...",
            "quotedContent": "...",
            "resolved": false,
            "replies": [{ "id": "...", "author": {...}, "content": "...", "createdTime": "..." }]
          }
        ]
      }
      ```
      `quotedContent` and `replies` are optional. Sort top-level comments by anchor in document order if you can derive it from `quoted_content`; otherwise leave the API order — the UI re-sorts by anchor line.
6. Tell the user which files you cached (markdown + comments JSON), then run `claudit gdoc <cached-path> --source-url <original-google-docs-url>` via the Bash tool. Always pass `--source-url` so the claudit header shows a "GDoc Review" badge with an "Open in Drive" link instead of the generic "Plan Review" treatment. The command launches the claudit web UI in their browser and blocks until the user submits or approves. The result is a `[USER REQUEST]` or `[USER APPROVED]` signal in stdout.

Remember the original Google Doc URL or ID — you'll need it later if the user wants content pushed back.

## Addressing feedback

When `[USER REQUEST]` is emitted, the user has comments to address.

1. Read `.claude/gdoc-comments.json`. If the file is missing or its `comments` array is empty, tell the user "no comments left to address" and skip to step 6.
2. For each comment, classify it:
   - **Doc-content change**: the user wants the Doc itself revised — a paragraph rewritten, a section expanded, a typo fixed.
   - **Repo / code change**: the user wants the codebase to reflect the doc — a new test, an API rename, etc.
   - **Question or note**: the user wants a response or follow-up clarification, not an edit.
3. For doc-content changes, edit the **cached markdown file** at `.claude/gdoc-cache/<...>.md`. That stays the local source of truth for the next round of review.
4. For repo / code changes, edit the relevant files with Edit/Write.
5. Ask the user explicitly: "Push these doc-content changes back to the source Google Doc at `<url>`?" Only push if confirmed — Doc edits are high-blast-radius and may surprise other readers. If confirmed, use `mcp__claude_ai_Spotify_s_Enterprise_Context_Agent__update_drive_file` with the original URL or ID and the updated markdown body.
6. Delete `.claude/gdoc-comments.json`.
7. Summarize: list what changed in the cached file, what changed in the repo, and whether the source Doc was updated.

## On approval

When `[USER APPROVED]` is emitted:

1. Delete `.claude/gdoc-comments.json` if it exists.
2. Confirm "no changes needed" to the user.
3. Leave the cached file in `.claude/gdoc-cache/` for reference.

## Not the same as /review-plan or /review-superpowers

- `/review-plan` is for Claude Code's native plan mode — files in `~/.claude/plans/`, gated by the ExitPlanMode hook.
- `/review-superpowers` is for committed repo artifacts under `docs/superpowers/`.
- `/review-gdoc` is for Google Drive-hosted documents fetched via the Enterprise Context Agent MCP. The doc is not in the repo and not in Claude's plan storage.

Pick the one that matches where the doc lives.
