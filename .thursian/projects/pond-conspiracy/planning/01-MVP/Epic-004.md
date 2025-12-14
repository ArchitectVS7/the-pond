# EPIC-004: Environmental Data Content - Development Plan

## Overview

**Epic**: EPIC-004 (Environmental Data Content)
**Release Phase**: MVP
**Priority**: P0 (Conspiracy board dependency)
**Dependencies**: EPIC-003 (Conspiracy Board UI)
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-002, CI-2.2

**Description**: Write 7-10 data logs with peer-reviewed citations, get NGO approval.

---

## Automated Workflow Protocol

### Before Each Story
1. **READ THIS PLAN** for re-alignment before starting
2. Verify dependencies from previous stories are complete
3. Check DEVELOPERS_MANUAL.md for any tunable parameters from prior work

### Story Completion Criteria
- ✅ All tests pass (adversarial workflow complete)
- ✅ Content deliverables created
- ✅ No human sign-off required - proceed immediately to next story

### Blocker Handling
- If a story cannot be completed due to blockers or human-required actions:
  - **SKIP** the blocked steps
  - **NOTE** in DEVELOPERS_MANUAL.md under "Blocked Steps" section
  - **PROCEED** to next story

---

## Important Note

This epic contains primarily content creation tasks that may require human expertise for:
- Scientific accuracy validation
- NGO outreach and partnerships
- Peer-reviewed citation verification

Stories that cannot be automated should be documented as blockers.

---

## Stories

### DATA-001: research-wetland-pollution-sources
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Research document on wetland pollution created
- [ ] 5+ pollution types identified
- [ ] Sources for each type documented
- [ ] Game-relevant framing applied

**Implementation Steps**:
1. Read plan for re-alignment
2. Research common wetland pollutants
3. Document sources (agricultural runoff, industrial, urban)
4. Create `conspiracy_board/content/research_notes.md`

**Deliverables**:
- Research notes document
- List of pollution topics for data logs

**Potential Blockers**:
- [ ] Requires external research → Note sources consulted in DEVELOPERS_MANUAL.md

---

### DATA-002: write-7-data-logs-draft
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] 7 data log documents written
- [ ] Each 200-400 words
- [ ] Mix of corporate memos, lab reports, whistleblower notes
- [ ] Narrative ties to game conspiracy

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `conspiracy_board/content/data_logs/` folder
3. Write each data log as markdown
4. Include TL;DR summary and full text for each

**Data Log Themes**:
1. Corporate memo about cost savings → pollution
2. Lab report showing contamination levels
3. Whistleblower email about cover-up
4. Government inspection (redacted)
5. Internal safety report (ignored)
6. PR strategy memo (spin the story)
7. Financial analysis (profit vs. cleanup)

**File Structure**:
```
conspiracy_board/content/data_logs/
├── 01_corporate_memo.md
├── 02_lab_report.md
├── 03_whistleblower.md
├── 04_inspection.md
├── 05_safety_report.md
├── 06_pr_strategy.md
└── 07_financial.md
```

**Test Cases**:
- `test_all_logs_exist` - 7 files present
- `test_logs_have_tldr` - Each has summary section
- `test_logs_have_full_text` - Each has full text section

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `min_word_count` | int | 200 | Minimum words per log |
| `max_word_count` | int | 400 | Maximum words per log |
| `tldr_max_words` | int | 50 | Summary word limit |

---

### DATA-003: cite-peer-reviewed-studies-inline
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Each data log references real studies
- [ ] Inline citations in text
- [ ] Citations are verifiable
- [ ] Mix of scientific and journalistic sources

**Implementation Steps**:
1. Read plan for re-alignment
2. Research peer-reviewed studies on wetland pollution
3. Add inline citations to data logs
4. Format as [Author, Year] or footnotes

**Deliverables**:
- Updated data logs with citations
- Source tracking document

**Potential Blockers**:
- [ ] Requires access to academic databases → Note alternative sources in DEVELOPERS_MANUAL.md

---

### DATA-004: create-bibliography-appendix
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Bibliography document created
- [ ] All cited sources listed
- [ ] Proper academic formatting (APA/MLA)
- [ ] Accessible from game menu

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `conspiracy_board/content/bibliography.md`
3. List all sources in consistent format
4. Group by data log reference

**Test Cases**:
- `test_bibliography_exists` - File present
- `test_all_citations_listed` - Count matches inline citations

---

### DATA-005: ngo-partnership-outreach
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] List of potential NGO partners created
- [ ] Outreach emails drafted
- [ ] Contact attempts documented
- [ ] Partnership benefits outlined

**Implementation Steps**:
1. Read plan for re-alignment
2. Research environmental NGOs focused on wetlands
3. Draft outreach template
4. Create tracking document

**Potential Blockers**:
- [ ] Human outreach required → SKIP actual contact, document template in DEVELOPERS_MANUAL.md

---

### DATA-006: ngo-content-review-approval
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Content sent to NGO partner for review
- [ ] Feedback incorporated
- [ ] Formal approval documented
- [ ] Partnership acknowledgment planned

**Implementation Steps**:
1. Read plan for re-alignment
2. Package content for review
3. Await and incorporate feedback
4. Document approval

**Potential Blockers**:
- [ ] Dependent on human interaction → SKIP, note in DEVELOPERS_MANUAL.md as future task

---

### DATA-007: integrate-data-logs-game
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Data logs converted to DataLogResource
- [ ] All 7 logs loadable in conspiracy board
- [ ] Discovery progression works
- [ ] Citations accessible in-game

**Implementation Steps**:
1. Read plan for re-alignment
2. Create DataLogResource for each log
3. Add to conspiracy board scene
4. Test discovery and viewing

**Test Cases**:
- `test_all_logs_load` - Resources instantiate
- `test_logs_display_correctly` - Content renders
- `test_discovery_tracks_all` - 7/7 achievable

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `discovery_order` | Array | [1,2,3,4,5,6,7] | Order logs can be discovered |
| `initial_unlocked` | int | 0 | Logs available at start |

---

## Files to Create

| File | Purpose |
|------|---------|
| `conspiracy_board/content/research_notes.md` | Research documentation |
| `conspiracy_board/content/data_logs/*.md` | 7 data log documents |
| `conspiracy_board/content/bibliography.md` | Source citations |
| `conspiracy_board/content/outreach_template.md` | NGO contact template |
| `conspiracy_board/resources/data_logs/*.tres` | DataLogResource files |
| `test/unit/test_data_content.gd` | Content tests |

---

## Dependencies Graph

```
DATA-001 (research)
    ↓
DATA-002 (write logs) → DATA-003 (citations) → DATA-004 (bibliography)
                                    ↓
                            DATA-007 (integrate)

DATA-005 (outreach) → DATA-006 (approval)
        ↓                    ↓
[LIKELY BLOCKED]      [LIKELY BLOCKED]
```

---

## Expected Blockers

This epic has significant human-dependent tasks:

| Story | Likely Status | Mitigation |
|-------|---------------|------------|
| DATA-001 | Completable | Use web research |
| DATA-002 | Completable | Draft content |
| DATA-003 | Partial | Use accessible sources |
| DATA-004 | Completable | After DATA-003 |
| DATA-005 | BLOCKED | Template only |
| DATA-006 | BLOCKED | Skip entirely |
| DATA-007 | Completable | With available content |

---

## Success Metrics

- 5 of 7 stories completed (accounting for blockers)
- 7 data logs written and integrated
- Citations documented
- Blockers clearly noted in DEVELOPERS_MANUAL.md

---

## Epic Completion Protocol

### On Epic Completion
1. Update `.thursian/projects/pond-conspiracy/planning/epics-and-stories.md`:
   - Mark Epic header with ✅ COMPLETE
   - Add **Status**: ✅ **COMPLETE** (date) line
   - Mark all stories with ✅ prefix
   - Update Story Index table with ✅ status
   - Update Progress Summary counts
2. Commit changes with message: "Complete EPIC-004: Environmental Data Content"
3. Proceed to next Epic in dependency order

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
