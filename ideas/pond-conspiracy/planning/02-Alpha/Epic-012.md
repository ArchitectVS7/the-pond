# EPIC-012: Third Boss Fight (The Researcher) - Development Plan

## Overview

**Epic**: EPIC-012 (Third Boss Fight - The Researcher)
**Release Phase**: Alpha
**Priority**: P1 (Content expansion)
**Dependencies**: EPIC-007 (Boss Encounters)
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: Lab coat frog boss with science-themed bullet patterns.

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

### BOSS3-001: researcher-boss-design-pixel-art
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] Researcher boss sprite created
- [ ] Lab coat and goggles design
- [ ] 3 phase visual variations
- [ ] Beaker/flask props

**Potential Blockers**:
- [ ] Art assets unavailable → Use placeholder, note in DEVELOPERS_MANUAL.md

---

### BOSS3-002: researcher-bullet-patterns-beaker-flask
**Size**: L | **Priority**: P1

**Acceptance Criteria**:
- [ ] Phase 1: "Controlled Experiment" - Predictable grid patterns
- [ ] Phase 2: "Chemical Reaction" - Expanding bubble bullets
- [ ] Phase 3: "Unstable Compound" - Random explosive bursts

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `researcher_hp` | int | 120 | Boss health |
| `p1_grid_size` | int | 5 | Grid pattern size |
| `p2_bubble_count` | int | 6 | Bubbles per burst |
| `p2_bubble_expand_rate` | float | 50.0 | Expansion speed |
| `p3_explosion_radius` | float | 80.0 | Burst damage radius |

---

### BOSS3-003: researcher-dialogue-corporate-science
**Size**: S | **Priority**: P1

**Acceptance Criteria**:
- [ ] Science-themed dialogue
- [ ] References to "data" and "results"
- [ ] Corporate funded research corruption theme

**Dialogue Lines**:
- **Intro**: "Another test subject! Let's see if you survive the... peer review process."
- **Phase 2**: "Fascinating! Your mutations are... most irregular."
- **Phase 3**: "THE DATA MUST BE PRESERVED!"
- **Defeat**: "This... this wasn't in the hypothesis..."

---

### BOSS3-004: researcher-3phase-mechanics
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] Inherits from boss_base.gd
- [ ] 3 distinct attack phases
- [ ] Summons "lab assistant" minions in Phase 3

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `phase_2_threshold` | float | 0.66 | HP% for phase 2 |
| `phase_3_threshold` | float | 0.33 | HP% for phase 3 |
| `minion_spawn_count` | int | 2 | Minions spawned in phase 3 |
| `minion_spawn_interval` | float | 10.0 | Seconds between minion waves |

---

### BOSS3-005: researcher-defeat-reward-evidence
**Size**: S | **Priority**: P1

**Acceptance Criteria**:
- [ ] Drops unique evidence item
- [ ] Unlocks additional data logs
- [ ] Contributes to second ending

---

### BOSS3-006: researcher-arena-lab-tileset
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] Laboratory-themed arena
- [ ] Beakers and equipment props
- [ ] Different visual from other arenas

**Potential Blockers**:
- [ ] Tileset art unavailable → Use recolored existing tiles, note in DEVELOPERS_MANUAL.md

---

## Files to Create

| File | Purpose |
|------|---------|
| `combat/scripts/boss_researcher.gd` | Boss logic |
| `combat/scenes/BossResearcher.tscn` | Boss scene |
| `combat/scenes/LabArena.tscn` | Arena scene |
| `assets/sprites/bosses/researcher/*.png` | Boss sprites |
| `test/unit/test_boss_researcher.gd` | Tests |

---

## Success Metrics

- 6 stories completed
- Third boss fully playable
- Unique patterns and dialogue
- Integrates with meta-progression

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
