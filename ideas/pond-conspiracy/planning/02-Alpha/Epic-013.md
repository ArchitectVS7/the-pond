# EPIC-013: Second Ending Path - Development Plan

## Overview

**Epic**: EPIC-013 (Second Ending Path)
**Release Phase**: Alpha
**Priority**: P1 (Narrative depth)
**Dependencies**: EPIC-008 (Meta-Progression System)
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: Government conspiracy variant ending.

---

## Automated Workflow Protocol

### Before Each Story
1. **READ THIS PLAN** for re-alignment before starting
2. Verify dependencies from previous stories are complete
3. Check DEVELOPERS_MANUAL.md for any tunable parameters from prior work

### Story Completion Criteria
- All tests pass (adversarial workflow complete)
- Tunable parameters documented in DEVELOPERS_MANUAL.md
- No human sign-off required - proceed immediately to next story

### Blocker Handling
- Skip blocked steps and note in DEVELOPERS_MANUAL.md
- Proceed to next story

---

## Stories

### ENDING2-001: government-conspiracy-evidence-branch
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] Alternative evidence interpretation
- [ ] Government involvement revealed
- [ ] Requires specific evidence combination
- [ ] Different from corporate ending

**Branch Logic**:
- Corporate Ending: Follow money trail → Corporate conspiracy
- Government Ending: Follow regulatory failures → Government coverup

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `gov_evidence_required` | Array | [2, 4, 6] | Evidence IDs for gov ending |
| `gov_connection_pattern` | String | "regulatory" | Connection theme |

---

### ENDING2-002: ending2-cutscene-pixel-art
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] Government-themed ending cutscene
- [ ] Different visual style from ending 1
- [ ] Reveals government complicity

**Potential Blockers**:
- [ ] Art assets unavailable → Use text-based ending, note in DEVELOPERS_MANUAL.md

---

### ENDING2-003: ending2-narrative-writing
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] Full narrative script
- [ ] Dialogue for ending sequence
- [ ] Ties up government plot threads
- [ ] Satisfying conclusion

**Narrative Beats**:
1. Evidence reveals regulatory capture
2. Government officials implicated
3. Choice: expose or stay silent
4. Consequences shown

---

### ENDING2-004: ending2-unlock-condition-logic
**Size**: S | **Priority**: P1

**Acceptance Criteria**:
- [ ] Correct evidence triggers ending 2
- [ ] Distinct from ending 1 requirements
- [ ] Can be discovered naturally
- [ ] Hint system supports discovery

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `ending2_hint_threshold` | int | 2 | Evidence count before hint |
| `ending2_explicit_hint` | bool | false | Show direct path hint |

---

### ENDING2-005: ending2-achievement-integration
**Size**: S | **Priority**: P1

**Acceptance Criteria**:
- [ ] Achievement for reaching ending 2
- [ ] Tracks ending 2 completion
- [ ] Distinct from ending 1 achievement

**Achievement**:
- **ID**: ENDING_GOVERNMENT
- **Name**: "Deep State"
- **Description**: "Uncover the government's role in the conspiracy"

---

## Files to Create

| File | Purpose |
|------|---------|
| `metagame/scripts/ending_manager.gd` | Ending logic |
| `metagame/scenes/Ending2Cutscene.tscn` | Cutscene scene |
| `metagame/resources/endings/ending2.tres` | Ending data |
| `metagame/content/ending2_script.json` | Narrative content |
| `test/unit/test_endings.gd` | Ending tests |

---

## Success Metrics

- 5 stories completed
- Second ending fully playable
- Distinct from first ending
- Achievement functional

---
---

## Epic Completion Protocol

### On Epic Completion
1. Update `.thursian/projects/pond-conspiracy/planning/epics-and-stories.md`:
   - Mark Epic header with ✅ COMPLETE
   - Add **Status**: ✅ **COMPLETE** (date) line
   - Mark all stories with ✅ prefix
   - Update Story Index table with ✅ status
   - Update Progress Summary counts
2. Commit changes with message: "Complete EPIC-XXX: [Epic Name]"
3. Proceed to next Epic in dependency order

---


**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
