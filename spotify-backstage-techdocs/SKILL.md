---
name: spotify-backstage-techdocs
description: Use when creating, deploying, or debugging a Backstage TechDoc at Spotify (ghe.spotify.net + Tingle CI + Backstage catalog). Covers repo creation, required YAML files, catalog registration, visibility settings, and the specific failure modes that block builds (private visibility, main vs master, pymdownx extensions, stuck catalog locations, filename conflicts).
---

# Spotify Backstage TechDocs Setup

## When to use

User wants to publish internal documentation as a Backstage TechDoc via Tingle CI. Also use when an existing TechDoc is failing to build or not appearing in Backstage.

## The minimum viable TechDoc

Five files at repo root plus a `docs/` directory. Every working TechDoc in `community-platform` follows this pattern verbatim. Deviating from it breaks things in non-obvious ways.

```
<repo-root>/
├── build-info.yaml          Tingle build config
├── catalog-info.yaml        Backstage catalog entity
├── mkdocs.yml               MkDocs config
├── service-info.yaml        Tingle publish target
├── docs/
│   └── index.md             Entry page (required)
```

## Required file contents

### `mkdocs.yml`
Keep minimal. Do not add pymdownx extensions or material-specific syntax — techdocs-core does not ship with them and the build fails.

```yaml
site_name: "<component-id>"
plugins:
  - techdocs-core
nav:
  - Overview: index.md
  - <additional pages>...
```

### `catalog-info.yaml`

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: <component-id>
  title: <Human readable title>
  description: <one line>
  annotations:
    github.com/project-slug: <org>/<repo-name>
    backstage.io/techdocs-ref: dir:.
  tags: [customer-service, insights, techdocs]
spec:
  type: documentation
  lifecycle: production
  owner: community@spotify.com
```

### `service-info.yaml`
Tingle uses this to route the published docs. The `id` field must match `catalog-info.yaml` `metadata.name` and the repo name.

```yaml
id: <component-id>
description: <one line>
system: community
owner: community
visibility: private
dependencies: []
facts:
  component_type: documentation
  lifecycle: production
  website_url: https://backstage.spotify.net/docs/<component-id>
  website_hosting: internal
```

### `build-info.yaml`

```yaml
version: 2
useBuildIdentity: true

template:
  type: systemDocs
  systemDocs:
    gcpProject: spotidocplatform-previews
    reviewDeployments:
      enabled: true
```

## The naming invariant

The **repo name, `service-info.yaml` id, and `catalog-info.yaml` metadata.name must all be the same lowercase-kebab-case string.** Deviation causes silent catalog validation failures.

Examples from working repos in `community-platform`:

| Repo | id | catalog name |
|------|----|--------------|
| `s4d-community-insights` | `s4d-community-insights` | `s4d-community-insights` |
| `community-export-api-docs` | `community-export-api-docs` | `community-export-api-docs` |
| `khoros-community-reference` | `khoros-community-reference` | `khoros-community-reference` |
| `cs-insights-techdoc` | `cs-insights-techdoc` | `cs-insights-techdoc` |

## Deployment procedure (first-time)

1. **Create the repo under `community-platform`** (the org that has Tingle installed org-wide).
   ```bash
   GH_HOST=ghe.spotify.net gh repo create community-platform/<name> --internal \
     --description "<desc>"
   ```
   **Critical:** use `--internal`, not `--private`. Tingle's service account cannot clone private repos in this org. This is the single most common failure mode and produces a "Repository not found" error with no further context.

2. **Default branch must be `master`.** Tingle in this org does not listen to `main`. Either create the repo with master as default or rename after push:
   ```bash
   git init -b master
   ```
   Every working TechDoc in `community-platform` uses `master`.

3. **Push the five required files** on master.

4. **Register in Backstage catalog.** Browser only, requires SSO:
   - Go to `https://backstage.spotify.net/catalog-import`
   - Paste `https://ghe.spotify.net/community-platform/<name>/blob/master/catalog-info.yaml`
   - Analyze → Import

5. **Verify build** via `/commits/<sha>/statuses`. Working build contexts are `Spotify-CI` and `tingle`, both transitioning to `success`. A working build's status URL has `/components/<id>/tingle/<uuid>`. A broken build's URL has the fallback pattern `/tingle/<org>/<repo>/<uuid>`, which indicates the component is not registered.

6. **Verify published docs** at `https://backstage.spotify.net/docs/default/component/<component-id>`.

## Verifying setup without browser access

```bash
# File structure (should match the five-file pattern)
gh api repos/community-platform/<repo>/contents --hostname ghe.spotify.net --jq '.[].name'

# Visibility must be internal or public, never private
gh api repos/community-platform/<repo> --hostname ghe.spotify.net --jq '.visibility'

# Default branch must be master
gh api repos/community-platform/<repo> --hostname ghe.spotify.net --jq '.default_branch'

# Build status on latest commit
SHA=$(gh api repos/community-platform/<repo>/branches/master --hostname ghe.spotify.net --jq '.commit.sha')
gh api "repos/community-platform/<repo>/commits/$SHA/statuses" --hostname ghe.spotify.net \
  --jq '[.[] | {ctx: .context, state: .state, url: .target_url}] | unique_by(.ctx)'
```

## Known failure modes and their signatures

### Build fails instantly with "Repository not found"
```
ERROR: Repository not found.
fatal: Could not read from remote repository.
```
**Cause:** repo visibility is `private`. Tingle's service account only has `internal` access.
**Fix:** `gh api -X PATCH repos/community-platform/<repo> --hostname ghe.spotify.net -f visibility=internal`.

### Build fails with empty description, URL pattern `/tingle/<org>/<repo>/<uuid>`
**Cause:** component not registered in Backstage catalog.
**Fix:** complete step 4 above. Check the `/components/<id>/tingle/` URL pattern appears after registration to confirm.

### Zero builds trigger, zero commit statuses
**Cause:** pushed to `main` branch instead of `master`. Tingle in `community-platform` does not listen to `main`.
**Fix:** rename the branch:
```bash
git branch -m main master
git push -u origin master
gh api -X PATCH repos/community-platform/<repo> --hostname ghe.spotify.net -f default_branch=master
gh api -X DELETE repos/community-platform/<repo>/git/refs/heads/main --hostname ghe.spotify.net
```

### Catalog import fails with "already registered but failing processing"
**Cause:** Backstage has a stuck location record for that exact URL. Usually triggered by a repo rename that invalidates a prior registration, or by a failed initial registration that Backstage never retries cleanly.
**Fix:** the URL is permanently blocked. Workarounds in order of preference:
1. Use a different filename (e.g. rename `catalog.yaml` ↔ `catalog-info.yaml`) so the URL is novel
2. Rename the repo to a name Backstage has never seen before
3. Ask a Backstage admin in `#backstage` or `#tingle-users` to clear the stuck location

### Build fails with mkdocs module errors
**Cause:** `mkdocs.yml` has `pymdownx` extensions, material theme shortcodes (`:material-*:`, `grid cards`), or other extras not in techdocs-core.
**Fix:** strip mkdocs.yml back to the minimal form shown above. Mermaid code fences still render without extra config.

### Silent catalog validation failure (registers but component never appears)
**Cause:** `owner` or `system` field references a Backstage entity that does not exist.
**Fix:** use `owner: community@spotify.com` and `system: community` — proven values from working repos. Do not invent new owner/system values without first verifying they exist in the catalog.

### Tingle hooks endpoint returns `[]`
**Not a failure.** Tingle uses GitHub App events, not classic webhooks. This is true of all working repos too. Check `commits/<sha>/statuses` instead.

## After first successful build

- Push commits trigger rebuilds automatically via the Tingle GitHub App event on the `community-platform` org.
- Published docs update within ~2 minutes of commit.
- New pages: add a markdown file in `docs/`, add it to the `nav` block in `mkdocs.yml`, commit, push. No catalog re-registration needed.

## Sync to claude-skills repo

After creating or editing this skill, sync to the tracked repo per CLAUDE.md:

```bash
cp -r ~/.claude/skills/spotify-backstage-techdocs ~/claude-skills/
cd ~/claude-skills && git add -A && git commit -m "sync: add spotify-backstage-techdocs skill" && git push
```
