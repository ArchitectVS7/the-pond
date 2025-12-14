# EPIC-018: Third Ending Path (Nihilist) - Development Plan

## Overview

**Epic**: EPIC-018 (Third Ending Path - Nihilist)
**Release Phase**: Beta
**Priority**: P2 (Narrative depth)
**Dependencies**: EPIC-013 (Second Ending Path)
**Estimated Effort**: M (1 week)
**PRD Requirements**: Beta FR

**Description**: Nihilist ending where player gives up.

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

### ENDING3-001: nihilist-evidence-branch
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Third interpretation of evidence
- [ ] Player chooses to give up
- [ ] Triggered by specific action
- [ ] Anti-climactic by design

**Unlock Condition**:
- Collect at least 4 evidence pieces
- Deliberately destroy evidence on conspiracy board
- Confirm "Give Up" dialog
- OR: Fail 10+ runs without progress

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `min_evidence_for_nihilist` | int | 4 | Evidence before option appears |
| `auto_nihilist_fail_count` | int | 10 | Fails before auto-trigger |
| `destruction_confirm_required` | bool | true | Require confirmation |

---

### ENDING3-002: ending3-cutscene-pixel-art
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Somber, quiet cutscene
- [ ] Frog walking away from board
- [ ] Conspiracy continues unsolved
- [ ] Rain/melancholy atmosphere

**Potential Blockers**:
- [ ] Art assets unavailable → Use text-based ending, note in DEVELOPERS_MANUAL.md

---

### ENDING3-003: ending3-narrative-writing
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Full narrative script
- [ ] Contemplative tone
- [ ] Acknowledges player's choice
- [ ] Commentary on apathy

**Narrative Beats**:
1. Frog looks at incomplete board
2. Internal monologue about futility
3. Decision to walk away
4. World continues, pollution worsens
5. Brief epilogue: "Sometimes... we just can't."

**Dialogue Excerpt**:
> "I've seen enough. Enough lies, enough cover-ups, enough... everything. Maybe they win. Maybe they always win. But I'm tired. So tired of fighting something so much bigger than me."

---

### ENDING3-004: ending3-unlock-condition
**Size**: S | **Priority**: P2

**Acceptance Criteria**:
- [ ] Multiple ways to trigger
- [ ] Intentional destruction path
- [ ] Repeated failure path
- [ ] Warning before triggering

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `show_warning_dialog` | bool | true | Warn before nihilist ending |
| `warning_text` | String | "Are you sure you want to give up?" | Warning message |
| `allow_undo` | bool | false | Can reverse after triggering |

---

### ENDING3-005: ending3-achievement
**Size**: S | **Priority**: P2

**Acceptance Criteria**:
- [ ] Achievement for nihilist ending
- [ ] Bittersweet achievement name
- [ ] Tracks completion

**Achievement**:
| ID | Name | Description |
|----|------|-------------|
| ENDING_NIHILIST | "Sometimes You Lose" | Choose to walk away from the conspiracy |

---

## Files to Create

| File | Purpose |
|------|---------|
| `metagame/scripts/nihilist_ending.gd` | Ending logic |
| `metagame/scenes/Ending3Cutscene.tscn` | Cutscene scene |
| `metagame/resources/endings/ending3.tres` | Ending data |
| `metagame/content/ending3_script.json` | Narrative content |
| `test/unit/test_nihilist_ending.gd` | Tests |

---

## Design Notes

**Purpose of Nihilist Ending**:
- Acknowledges player agency
- Comments on real-world apathy
- Provides closure for frustrated players
- Adds replayability (completionists want all endings)

**Tone**:
- Not punishing the player
- Melancholy, not depressing
- Valid choice, not "bad" ending
- Thought-provoking

---

## Success Metrics

- 5 stories completed
- Third ending fully playable
- Emotionally resonant
- Distinct from other endings

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
