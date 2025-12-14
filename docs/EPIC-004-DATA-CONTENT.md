# EPIC-004: Environmental Data Content - Developer Documentation

## Overview

7 data log documents forming the conspiracy board narrative. Based on peer-reviewed research on wetland pollution, corporate negligence, and regulatory capture. Players discover these documents during gameplay to piece together the environmental conspiracy.

**Files**:
- `conspiracy_board/content/data_logs/*.md` - 7 markdown source documents
- `conspiracy_board/resources/data_logs/data_log_*.tres` - 7 Godot resource files
- `conspiracy_board/content/research_notes.md` - Research compilation
- `conspiracy_board/content/bibliography.md` - APA citations (34 sources)
- `conspiracy_board/content/outreach_template.md` - NGO partnership template
- `test/unit/test_data_content.gd` - Comprehensive unit tests

---

## Tunable Parameters

**File**: `conspiracy_board/resources/data_logs/*.tres` (via DataLogResource exports)

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `min_word_count` | int | 200 | Minimum words per data log full_text |
| `max_word_count` | int | 400 | Maximum words per data log (guideline, not enforced) |
| `tldr_max_chars` | int | 300 | Summary character limit (~50 words) |
| `discovery_order` | Array | [1,2,3,4,5,6,7] | Order logs can be discovered |
| `initial_unlocked` | int | 0 | Logs available at game start |

**Note**: These are content guidelines used during development. Godot resources don't enforce word counts at runtime.

---

## Data Log Summaries

| ID | Title | Type | Words | Key Theme |
|----|-------|------|-------|-----------|
| 01 | Corporate Memo: Cost Reduction Initiative | Internal Memo | 350 | Cost-cutting leads to illegal dumping ($2.3M savings) |
| 02 | Lab Report: Mercury Contamination | Scientific Analysis | 320 | Mercury 340% above EPA limits, tadpoles contaminated |
| 03 | Whistleblower: Night Shift Illegal Dumping | Sworn Testimony | 380 | Employee exposes dumping, gets fired and threatened |
| 04 | EPA Inspection Report [REDACTED] | Government Report | 340 | Violations found but polluter identity hidden by redactions |
| 05 | Internal Safety Report: Ignored Warnings | Safety Audit | 370 | $850K urgent repairs ignored, auditor intimidated |
| 06 | PR Strategy: Greenwashing Campaign | PR Proposal | 390 | $1.2M budget to spin pollution, $0 for actual cleanup |
| 07 | Financial Analysis: Cheaper to Pollute | CFO Memo | 400 | Proves breaking law saves $9.7M vs. compliance |

---

## Content Guidelines

### TL;DR Summaries
Each data log has a `summary` field (TL;DR section):
- **Max Length**: 300 characters (~50 words)
- **Purpose**: Preview text for undiscovered/locked cards
- **Tone**: Punchy, reveal key scandal without spoiling full story
- **Example**: "AgriCorp VP memo reveals plan to dump untreated waste into wetlands to save $2.3M annually. Environmental impact dismissed as 'acceptable risk.'"

### Full Text Content
Each data log has a `full_text` field:
- **Min Length**: 200 words (500+ characters)
- **Target Length**: 200-400 words
- **Structure**: Formal document format (memo header, lab report, legal testimony, etc.)
- **Realism**: Based on real-world case studies and peer-reviewed research
- **Narrative Arc**: Each log reveals one piece of the conspiracy puzzle

### Narrative Connections
Data logs use the `connections` array to link related documents:
- **Log 01 (Corporate Memo)** → Sets up illegal dumping decision
- **Log 02 (Lab Report)** → Confirms environmental damage, connects to 01 and 07
- **Log 03 (Whistleblower)** → Exposes night-time dumping, connects to 01, 04, 05
- **Log 04 (EPA Report)** → Government found violations but redacted details, connects to 03, 05
- **Log 05 (Safety Audit)** → Internal warnings ignored, connects to 03, 04, 07
- **Log 06 (PR Strategy)** → Greenwashing instead of cleanup, connects to 07
- **Log 07 (Financial Analysis)** → Proves profit motive, connects to 01, 02, 05, 06

---

## Discovery System

**Default Behavior**:
- All logs start `discovered = false` (locked)
- Player must find logs during gameplay to unlock
- `discovery_order` can enforce sequence (e.g., must find 01 before 02)

**Tuning Discovery Order**:

```gdscript
# Option 1: Linear progression (must find in order)
discovery_order = [1, 2, 3, 4, 5, 6, 7]

# Option 2: Branching paths (player chooses which thread to follow)
# Corporate path: 01 → 07 → 06
# Whistleblower path: 03 → 04 → 05
# Scientific path: 02 → any

# Option 3: All unlocked from start (testing mode)
initial_unlocked = 7
```

**Implementation Example** (in ConspiracyBoard script):

```gdscript
func can_discover_log(log_id: String) -> bool:
    var log_num := int(log_id.substr(9, 2))  # Extract "01" from "data_log_01"

    # Check if previous logs in discovery_order are discovered
    for i in range(log_num - 1):
        var prev_id := "data_log_%02d" % (i + 1)
        var prev_log := get_log_resource(prev_id)
        if not prev_log.discovered:
            return false  # Must discover previous logs first

    return true
```

---

## Educational Integration

### Peer-Reviewed Citations
Data logs include inline citations in square brackets (primarily in Lab Report - Log 02):
- `[1]` Blum & Bergquist, 2007 - Mercury isotopic analysis
- `[2]` EPA, 2011 - Coal plant emissions
- `[3]` Bank et al., 2007 - Amphibian bioaccumulation
- `[4]` Bergeron et al., 2010 - Mercury toxicity in frogs

Full bibliography available in `conspiracy_board/content/bibliography.md` with 34 sources in APA format.

### NGO Partnership (Blocked - Human Required)
Stories **DATA-005** and **DATA-006** require manual human outreach:
- **Template**: `conspiracy_board/content/outreach_template.md`
- **Recommended Partners**: Wetlands International, Save The Frogs!, NRDC, Sierra Club
- **Purpose**: Scientific accuracy review, educational partnerships, media support
- **Timeline**: Beta phase (Q1 2025)

**Developer Action Required**: Review outreach template and contact NGOs during beta testing.

---

## Testing

**File**: `test/unit/test_data_content.gd`

**Test Coverage**:
1. ✅ All 7 markdown files exist
2. ✅ All 7 resource files load correctly
3. ✅ All logs have titles, summaries, full_text
4. ✅ Summaries ≤ 300 characters
5. ✅ Full text ≥ 500 characters (minimum)
6. ✅ Word counts ≥ 200 words
7. ✅ IDs match expected format (`data_log_01` through `data_log_07`)
8. ✅ Logs start `discovered = false`
9. ✅ Content-specific tests (Log 02 mentions mercury, Log 07 mentions "APPROVED", etc.)
10. ✅ Bibliography and research notes exist
11. ✅ Performance: All 7 resources load in < 100ms

**Run Tests**:
```bash
# In Godot editor with GUT plugin:
# Project → Project Settings → Autoload → Add GUT
# Scene → Run Scene (F6) on test scene
```

---

## Content Maintenance

### Updating Data Logs
To modify data log content:

1. **Edit Markdown Source**: Update `.md` file in `conspiracy_board/content/data_logs/`
2. **Update Resource**: Open `.tres` file in Godot Inspector
3. **Copy Text**: Paste updated `full_text` from markdown into resource
4. **Verify Tests**: Run `test_data_content.gd` to ensure compliance
5. **Check Word Count**: Summary ≤ 300 chars, Full text ≥ 200 words

### Adding New Data Logs
To add an 8th log (or more):

1. Create `08_new_log.md` in `conspiracy_board/content/data_logs/`
2. Create `data_log_08.tres` resource
3. Set `id = "data_log_08"`
4. Add to `discovery_order` array
5. Update `test_data_content.gd` to include log 08
6. Update this documentation

---

## Accessibility Notes

**Content Warnings**:
Data logs contain themes of:
- Corporate malfeasance and corruption
- Environmental destruction
- Whistleblower retaliation and workplace intimidation
- Regulatory capture (government favoring corporations over public)

**Recommended Age Rating**: Teen (13+) due to mature themes
**Optional Content Filter**: Could add toggle to simplify or remove graphic descriptions

---

## Localization Considerations

Data logs are text-heavy narrative content. For localization:

**High Priority for Translation**:
- `summary` field (TL;DR) - Player sees this first
- `title` field - Displayed on conspiracy board cards

**Medium Priority**:
- `full_text` field - Only visible when player clicks to read

**Low Priority**:
- `research_notes.md` - Developer reference
- `bibliography.md` - Academic citations (often kept in English)

**Translation Notes**:
- Maintain formal document tone (legal, scientific, corporate)
- Preserve document headers (TO:, FROM:, DATE:, etc.)
- Keep bracketed citations `[1]` as-is
- Translate handwritten margin notes for authenticity

---

## Performance Considerations

**Memory Usage**:
- 7 resources × ~2KB average = ~14KB total
- All text stored in `full_text` strings
- No runtime generation, all content pre-authored

**Load Time**:
- Target: < 100ms for all 7 resources (tested in `test_data_content.gd`)
- Resources are lightweight (no textures, just text data)

**Rendering**:
- Conspiracy board cards show `summary` only (low overhead)
- Full text rendered only when player opens document viewer
- Use RichTextLabel with BBCode for formatted display

---

## Future Expansions (Post-MVP)

**Additional Data Logs**:
- Employee emails (more casual, personal perspective)
- News articles (media coverage of scandal)
- Social media posts (public reaction)
- Court documents (lawsuit filings)

**Interactive Elements**:
- Redaction mini-game (player "uncovers" blacked-out text)
- Cross-reference tool (click citation to see bibliography entry)
- Timeline view (sort logs chronologically)
- Search function (find keywords across all logs)

**Player-Generated Content**:
- Note-taking system (player annotates documents)
- Connection mapping (player draws lines between related logs)
- Theory crafting (player writes summary of conspiracy)

---

## Blocked Stories (Human-Dependent)

### DATA-005: NGO Outreach
- **Status**: Template created, manual execution required
- **Timeline**: Beta phase (Q1 2025)
- **Action**: Developer must personalize and send emails to NGOs
- **Deliverable**: `outreach_template.md` (✅ Complete)

### DATA-006: NGO Review Integration
- **Status**: Blocked by DATA-005
- **Timeline**: After NGO responses received
- **Action**: Incorporate feedback into final data logs
- **Deliverable**: Depends on NGO feedback

**Contingency**: Game can launch without NGO partnership. Bibliography provides sufficient scientific credibility.

---

## Story Completion Status

| Story | Status | Deliverables |
|-------|--------|--------------|
| DATA-001 | ✅ COMPLETE | research_notes.md (5 pollution types) |
| DATA-002 | ✅ COMPLETE | 7 markdown data logs |
| DATA-003 | ✅ COMPLETE | Inline citations added to Lab Report |
| DATA-004 | ✅ COMPLETE | bibliography.md (34 sources, APA format) |
| DATA-005 | ⚠️ BLOCKED | outreach_template.md (human execution required) |
| DATA-006 | ⚠️ BLOCKED | Depends on DATA-005 NGO responses |
| DATA-007 | ✅ COMPLETE | 7 DataLogResource .tres files |

**Epic Status**: 5 of 7 stories complete. 2 blocked (human-dependent, non-critical).

---

## Changelog

| Date | Story | Changes |
|------|-------|---------|
| 2025-12-13 | DATA-001 | Research notes created (5 pollution types) |
| 2025-12-13 | DATA-002 | 7 data log markdown files written |
| 2025-12-13 | DATA-003 | Peer-reviewed citations added (Lab Report) |
| 2025-12-13 | DATA-004 | Bibliography created (34 sources in APA format) |
| 2025-12-13 | DATA-005 | NGO outreach template documented (blocked - human required) |
| 2025-12-13 | DATA-006 | NGO review process documented (blocked - depends on DATA-005) |
| 2025-12-13 | DATA-007 | 7 DataLogResource .tres files created |

---

**Last Updated**: December 13, 2024
