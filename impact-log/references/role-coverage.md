# Role Coverage Map

> **Last updated:** 2026-06-09
>
> This document maps the impact-log skill's coverage across all engineering career steps at Spotify. It identifies which roles have full support, partial support, or no support — and what sources exist to close the gaps.

## Coverage Summary

| Support level | Meaning |
|--------------|---------|
| **Full (sourced)** | Dedicated level template captured from a published source (e.g., PZN leadership templates). Content reflects the source author's intent. |
| **Full (derived)** | Dedicated level template synthesized from Steps framework docs, self-assessment templates, or archetype descriptions. No published template exists for this role — the content is a best-effort interpretation of available source material. Marked with a derivation notice in the template header. |
| **Partial** | Generic framework applies; no level-specific template, deepening prompts, or evidence signals |
| **Planned** | Source material identified; template can be derived but has not been written yet |
| **None** | No support and no identified source material |

**Why this distinction matters:** A user running `prep --level senior` gets content captured from a document that PZN engineering leadership published and reviewed. A user running `prep --level sem` (once implemented) gets content derived from the Steps framework — a reasonable interpretation, but not reviewed by a specific leader for that role. The derivation notice ensures transparency about the content's provenance.

## IC Track

| Step | `--level` flag | Support | Content provenance | Source material | Notes |
|------|---------------|---------|-------------------|-----------------|-------|
| Associate Eng | — | None | — | [IC Career Steps](https://docs.google.com/document/d/1z-4rJBfNwoZKNCUJtOk0YptN0Y-tuCRSGzkFwCs-ZAI/) | Rare in practice; teams can create local Steps per XTL guidance |
| **Eng I** | `eng1` | **Full (sourced)** | Captured from published PZN template | [PZN template](https://docs.google.com/document/d/1Mo1liBAXeyeS-5eo-olnwH1lV4pjY1JRDj4ZN39iQkE/) | Shipped in PR #69 |
| **Eng II** | `eng2` | **Full (sourced)** | Captured from published PZN template | [PZN template](https://docs.google.com/document/d/1Du-GJ-uW468bHZjn3Wk7zL_UhefSkfpc_AQgLl4iqxA/) | Shipped in PR #69 |
| **Senior Eng** | `senior` | **Full (sourced)** | Captured from published PZN template | [PZN template](https://docs.google.com/document/d/1X-Gboti_aceCoBOrdXt3qs502NpyFgQlPu_KKYlz8c8/) | Shipped in PR #69. Includes "Looking ahead → Staff" |
| **Staff Eng** | `staff` | **Full (sourced)** | Captured from published PZN template | [PZN template](https://docs.google.com/document/d/11HTPFEOWmN7kZEiN_Xbt_nz3D4euJnY84vUu5VxmU9U/) | Shipped in PR #69. Includes evidence signals (PR #70) |
| Senior Staff Eng | — | Planned | To be derived (no published template) | [Expert Archetypes](https://docs.google.com/document/d/1PTGHrESTT7otB8IU4FM2c4hEprghnmYipoDvKgFeTKg/) | Cross-org technical leadership; archetype-based rather than template-based |
| Principal Eng | — | Planned | To be derived (no published template) | [Expert Archetypes](https://docs.google.com/document/d/1PTGHrESTT7otB8IU4FM2c4hEprghnmYipoDvKgFeTKg/) | Company-wide technical influence; rare role |

## EM Track

| Step | `--level` flag | Support | Content provenance | Source material | Notes |
|------|---------------|---------|-------------------|-----------------|-------|
| **EM (I/II)** | `em` | **Full (sourced)** | Captured from published PZN template | [PZN template](https://docs.google.com/document/d/1SMAdq4E5xCIyPNQbNXQEhlffjTLq7SlogpyRIqq6TLY/) | Template shipped in PR #69. EM-specific pull modes, discovery sources, and deepening prompts shipped in this PR |
| **Senior EM** | `sem` | **Full (sourced)** | Captured from published PZN template | [SEM template](https://docs.google.com/document/d/16yUETQ_qKTbytdKM0Y539T7XHUFwRtilkTZegpok_ts/) | Upgraded from derived to sourced in PR #73. Multi-squad scope; developing other EMs; organizational strategy |
| **Director** | `director` | **Full (derived)** | Derived from deprecated EM Career Steps | [EM Career Steps](https://docs.google.com/document/d/1zVMboZel1a3l9yKjm860SfDn2LGGAbs-4HwqCzX8za4/) (deprecated April 2026) | Shipped in this PR. Studio/mission-level scope; growing leaders and defining strategy |
| Senior Director | — | Planned | To be derived (no published template) | [EM Career Steps](https://docs.google.com/document/d/1zVMboZel1a3l9yKjm860SfDn2LGGAbs-4HwqCzX8za4/) (deprecated April 2026) | Long-term vision and strategy; setting up leaders for success |
| VP of Engineering | — | Planned | To be derived (no published template) | [EM Career Steps](https://docs.google.com/document/d/1zVMboZel1a3l9yKjm860SfDn2LGGAbs-4HwqCzX8za4/) (deprecated April 2026) | Company-level tech and business vision; rare in the skill's audience |

## Non-Engineering Roles

The Performance@Spotify framework (WHAT × HOW) applies to all employees, not just engineering. The impact-log skill's generic framework (`prep` without `--level`) works for any role, and the `--level custom` option supports any role-specific template.

Career frameworks exist for multiple non-engineering role families — all accessible via the [HR Career Frameworks Confluence page](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/). These could serve as source material for derived templates.

| Role family | `--level` flag | Support | Content provenance | Source material | Notes |
|-------------|---------------|---------|-------------------|-----------------|-------|
| Product Manager | — | Planned | To be derived | [PM Career Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/) (Confluence) | Strategy, stakeholder management, metrics-driven decisions |
| Data Scientist | — | Planned | To be derived | [Insights Career Framework](https://sites.google.com/spotify.com/insights-toolkit/talent-growth/career-development/cab-framework/the-career-framework-achievement), [DS Career Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/) (Confluence) | Experiment-heavy; evidence signals could prioritize Oliver + BigQuery |
| User Researcher | — | Planned | To be derived | [UR Career Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/) (Confluence) | Research outcomes, insights-to-action, cross-functional influence |
| Designer | — | Planned | To be derived | Career framework not yet identified | User research and design outcomes; different evidence surface |
| Data Curation | — | Planned | To be derived | [Data Curation Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/) (Confluence) | Content quality, editorial judgment, curation impact |
| Market Researcher | — | Planned | To be derived | [Market Research Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/) (Confluence, interim) | Market insights, competitive intelligence |
| Project/Program Manager | — | Planned | To be derived | [PPM Career Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/) (Confluence) | Delivery management, cross-team coordination, risk management |

All non-engineering roles can use `--level custom` with a team-provided template today. Dedicated templates would require reading the respective career frameworks and structuring them around the Performance@Spotify WHAT × HOW framework — the same approach used for the derived Senior EM and Director templates.

## Gap Analysis

### Closed in this PR

| Gap | Resolution |
|-----|-----------|
| **EM tooling parity** | EM-specific pull modes, discovery sources, deepening prompts, backfill nudge, calibrate anti-patterns |
| **Senior EM** | Full (derived) template with 3 dimensions, reflection questions, evidence signals, Expectations Sync agenda |
| **Director** | Full (derived) template with 3 dimensions, reflection questions, evidence signals, Expectations Sync agenda |

### Remaining gaps — Engineering roles

| Priority | Gap | Impact | Path to close |
|----------|-----|--------|---------------|
| Medium | **Senior Staff Eng** | Cross-org scope beyond Staff; rare but high-impact users | Derive from [Expert Archetypes](https://docs.google.com/document/d/1PTGHrESTT7otB8IU4FM2c4hEprghnmYipoDvKgFeTKg/). Add as `--level senior-staff` |
| Medium | **Senior Director** | Long-term vision, setting up leaders for success | Derive from deprecated [EM Career Steps](https://docs.google.com/document/d/1zVMboZel1a3l9yKjm860SfDn2LGGAbs-4HwqCzX8za4/). Add as `--level senior-director` |
| Lower | **Principal Eng** | Company-wide technical influence; extremely rare | Derive from [Expert Archetypes](https://docs.google.com/document/d/1PTGHrESTT7otB8IU4FM2c4hEprghnmYipoDvKgFeTKg/). Add as `--level principal` |
| Lower | **VP of Engineering** | Company-level tech and business vision; very rare | Derive from deprecated [EM Career Steps](https://docs.google.com/document/d/1zVMboZel1a3l9yKjm860SfDn2LGGAbs-4HwqCzX8za4/). Add as `--level vp` |
| Lower | **Associate Eng** | Entry-level; teams can create local Steps per XTL guidance | Derive from [Engineering Expectations](https://docs.google.com/document/d/12o2AVnHKmALOqMPaFIZmO2LuNSwatbYBJ8lrKfoZ5xI/). Add as `--level associate` |

### Remaining gaps — Non-engineering roles

Career frameworks exist for these roles via the [HR Career Frameworks Confluence page](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/). Templates can be derived using the same approach as the engineering derived templates.

| Priority | Gap | Impact | Path to close |
|----------|-----|--------|---------------|
| Medium | **Product Manager** | Strategy, stakeholder management, metrics-driven decisions | Derive from [PM Career Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/). Add as `--level pm` |
| Medium | **Data Scientist** | Experiment outcomes, statistical analysis, business insights | Derive from [Insights Career Framework](https://sites.google.com/spotify.com/insights-toolkit/talent-growth/career-development/cab-framework/the-career-framework-achievement). Add as `--level ds` |
| Lower | **User Researcher** | Research outcomes, insights-to-action, cross-functional influence | Derive from [UR Career Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/). Add as `--level ur` |
| Lower | **Designer** | Design outcomes, user experience impact | Career framework not yet identified; may require team-published guides |
| Lower | **Project/Program Manager** | Delivery management, cross-team coordination | Derive from [PPM Career Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/). Add as `--level ppm` |
| Lower | **Data Curation** | Content quality, editorial judgment | Derive from [Data Curation Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/) |
| Lower | **Market Researcher** | Market insights, competitive intelligence | Derive from [Market Research Framework](https://spotify.atlassian.net/wiki/spaces/HR/pages/260380181/) (interim) |

## How `--level custom` bridges the gaps

Any role without a dedicated template can use `--level custom` with a Google Doc URL or local file path:

```json
{
  "career_level": "custom",
  "custom_template": "https://docs.google.com/document/d/..."
}
```

The agent reads the custom template at inference time and adapts `prep` reflection questions to its structure. This covers:
- Roles not yet in the level templates (Senior Staff, Principal, Senior Director, VP)
- Non-engineering roles (PM, DS, Designer)
- Team-specific templates that differ from the org-level defaults
- Squad rubrics (layered on top via the squad rubric discovery feature)

## Source Documents

The skill draws from two authoritative sources plus team-specific templates:

### Engineering Expectations in an AI Era (XTL) — the current framework

Announced April 22, 2026 by the XTL. **Replaces the previous Engineering Steps Career framework.** Defines what each level looks like in an agentic world, aligned with Performance@Spotify. The XTL confirmed this document is intended to be a "standalone / complete reference" — not layered on top of the deprecated Steps framework.

> "All previous Engineering Steps Career material is now deprecated." — XTL, [#engineering](https://spotify.slack.com/archives/C05G4BXRYM6/p1776870003997119), April 22, 2026

An EM expectations model was announced as coming in May 2026 with potential small refinements to the IC model.

| Document | What it covers | Status | URL |
|----------|---------------|--------|-----|
| Engineering Expectations in an AI Era | IC expectations per level, aligned with Performance@Spotify | **Current** | [Google Doc](https://docs.google.com/document/d/12o2AVnHKmALOqMPaFIZmO2LuNSwatbYBJ8lrKfoZ5xI/) |
| EM Expectations model | EM expectations per level | **Announced May 2026** — verify availability | TBD |
| Staff+ and SEM Promotion Process | Promotion requirements and formal process (unchanged) | **Current** | [Google Doc](https://docs.google.com/document/d/1DeaVNncDALRTbgqbRr2MbXvVfS0rI92f4ZXDM9FByBQ/) |

### Deprecated Steps Framework documents (historical reference only)

These documents were the previous source of truth. They are referenced here for provenance — some derived content may have been synthesized from them before the deprecation. New templates should not reference these as authoritative sources.

| Document | What it covered | Status | URL |
|----------|----------------|--------|-----|
| Career Steps for ICs | Eng I through Principal behavioral expectations | **Deprecated** April 2026 | [Google Doc](https://docs.google.com/document/d/1z-4rJBfNwoZKNCUJtOk0YptN0Y-tuCRSGzkFwCs-ZAI/) |
| IC Self-Assessment Template | Behavioral examples and self-assessment per level | **Deprecated** April 2026 | [Google Sheet](https://docs.google.com/spreadsheets/d/12Ug5W8Tt8ydxYCdbsdv9QzsDU_VctL1rbVF6zvkfkX0/) |
| Career Steps for EMs | EM through Director behavioral expectations | **Deprecated** April 2026 (pending EM Expectations replacement) | [Google Doc](https://docs.google.com/document/d/1zVMboZel1a3l9yKjm860SfDn2LGGAbs-4HwqCzX8za4/) |
| EM Self-Assessment Template | Behavioral examples and self-assessment per level | **Deprecated** April 2026 | [Google Sheet](https://docs.google.com/spreadsheets/d/1-NMneeDWXHdVpT1Y8dnWs7pg0LrgnJD0sYUQusXMvSs/) |
| Expert Archetypes | Senior, Staff, Senior Staff, Principal archetype descriptions | **Status unclear** — not explicitly deprecated; may still be valid for Staff+ roles | [Google Doc](https://docs.google.com/document/d/1PTGHrESTT7otB8IU4FM2c4hEprghnmYipoDvKgFeTKg/) |
| Steps in Everyday Work | Eng II, Senior, Staff behavioral examples | **Deprecated** April 2026 | [Google Doc](https://docs.google.com/document/d/13hkIEbTAuhjfYnnVk2Oa-Bb6NC9nS3BlWaLZOsztNgo/) |

### Performance@Spotify (HR + XTL) — defines how impact is measured

WHAT × HOW framework, Impact Scale, Values in Action, Impact & Development Talk process. Introduced in 2026; the Engineering Expectations model aligns with this.

| Document | What it covers | URL |
|----------|---------------|-----|
| Performance@Spotify Playbook | WHAT × HOW framework, Impact Scale, Values in Action, I&DT structure | [Google Slides](https://docs.google.com/presentation/d/1i0p_sQRPPq1SrHqXrs0Wfs3BAbH2tK8K8GyQ7c5fKB4/) |
| Workday & Claude Companion Guide | Step-by-step Workday walkthrough and Claude skill usage | [Google Slides](https://docs.google.com/presentation/d/1j1_54HSyzX-bX8oCNSeMLmVr8GgdEVfcqdDHXrbsXBU/) |

### PZN Level Templates — team-specific

Team-specific impact dimensions, reflection questions, and Expectations Sync agendas published by Personalization engineering leadership. Built on the Engineering Expectations model and Performance@Spotify framework.

| Document | What it covers | URL |
|----------|---------------|-----|
| PZN Level Templates (Eng I–EM) | 5 level-specific templates with 3 dimensions, reflection questions, Expectations Sync agendas | See [`idt-level-templates.md`](idt-level-templates.md) freshness notice for all 5 URLs |
| Impact Info Session — PZN | June 2026 I&DT cycle context and level-specific guidance | [Google Slides](https://docs.google.com/presentation/d/1ZLCUp3iX_wxjtGWE6-57wliKzxq0DghuUdaNHoMOVkg/) |

### How the frameworks relate

- **Engineering Expectations** answers: "What does each level look like? What behaviors are expected in an agentic world?" (Replaces Steps)
- **Performance@Spotify** answers: "How is my impact measured? What does the I&DT process look like?"
- **PZN templates** combine both: "Here are the reflection questions for your level, structured around the WHAT × HOW framework, with an Expectations Sync agenda."

When deriving templates for roles without PZN-published content, the skill synthesizes from the Engineering Expectations doc (for level-specific scope and behavioral expectations) and Performance@Spotify (for the WHAT × HOW structure and I&DT alignment). For EM roles above EM I/II, the deprecated EM Career Steps doc may serve as a reference until the EM Expectations model is published — any content derived from the deprecated doc will carry a provenance notice and should be updated when the replacement is available.
