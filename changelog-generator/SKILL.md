---
name: changelog-generator
description: Use when creating release notes, changelogs, or update summaries from git history. Transforms technical commits into user-friendly release notes grouped by category.
---

# Changelog Generator

Transform git commits into clean release notes.

## Usage

### From a date range
```bash
git log --oneline --after="2026-06-01" --before="2026-07-01" --no-merges
```

### Between tags/versions
```bash
git log --oneline v0.27..v0.28 --no-merges
```

### Between commits
```bash
git log --oneline abc123..HEAD --no-merges
```

## Process

1. **Gather commits** using the right range
2. **Filter out noise**: skip pure refactors, test-only changes, CI config, typo fixes unless they fixed user-visible bugs
3. **Categorize** into groups:
   - **New** -- wholly new features or capabilities
   - **Improved** -- enhancements to existing features
   - **Fixed** -- bug fixes
   - **Breaking** -- changes that require user action
   - **Security** -- vulnerability fixes
4. **Rewrite** each entry in user language (not developer language):
   - Bad: "fix: handle null in _km_calculate_issue_priority"
   - Good: "Fixed priority scoring crash when articles had no helpfulness data"
5. **Format** as markdown

## Output template

```markdown
# [Product Name] [Version] -- [Date]

## New
- **Feature Name**: One-sentence description of what users can now do

## Improved
- **Area**: What got better and why it matters

## Fixed
- Description of what was broken and that it's now fixed

## Breaking
- What changed and what users need to do
```

## Tips
- Lead with the user impact, not the technical change
- Group related commits into a single entry
- Skip internal-only changes entirely
- For this project: use KM versioning format (0.0XX) not semver
- Include the deploy date
- If the changelog is for a Slack post, use the `slack-message-formatting` skill for formatting
