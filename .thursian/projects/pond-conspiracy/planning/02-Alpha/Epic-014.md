# EPIC-014: Additional Mutations (15 Total) - Development Plan

## Overview

**Epic**: EPIC-014 (Additional Mutations)
**Release Phase**: Alpha
**Priority**: P1 (Build variety)
**Dependencies**: EPIC-006 (Mutation System)
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: +5 mutations, +3 synergies for 15 total mutations, 6 synergies.

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

### MUTATION-011: design-5-new-mutations
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] 5 new mutation concepts designed
- [ ] Mix of frog and pollution types
- [ ] Unique mechanics (not just stat boosts)
- [ ] Balanced with existing mutations

**New Mutations**:

| # | Name | Type | Effect |
|---|------|------|--------|
| 11 | Camouflage | FROG | Brief invulnerability after standing still |
| 12 | Webbed Feet | FROG | Move faster on water/slime |
| 13 | Acidic Spit | POLLUTION | Attacks leave damaging puddles |
| 14 | Radioactive Glow | POLLUTION | Damage nearby enemies, but visible to all |
| 15 | Parasite Host | HYBRID | On death, spawn ally tadpoles |

---

### MUTATION-012: implement-new-mutations-code
**Size**: L | **Priority**: P1

**Acceptance Criteria**:
- [ ] All 5 new mutations implemented
- [ ] Each has working mechanic
- [ ] Integrates with existing system
- [ ] Tests written

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `camouflage_delay` | float | 1.5 | Seconds still before camo |
| `camouflage_duration` | float | 2.0 | Invulnerability time |
| `webbed_speed_bonus` | float | 0.5 | +50% speed on water |
| `acidic_puddle_duration` | float | 3.0 | Puddle lifetime |
| `acidic_puddle_damage` | int | 1 | Damage per tick |
| `radioactive_radius` | float | 40.0 | Damage radius |
| `radioactive_damage` | int | 1 | Damage per second |
| `parasite_tadpole_count` | int | 3 | Allies spawned on death |
| `parasite_tadpole_duration` | float | 10.0 | Ally lifetime |

---

### MUTATION-013: balance-new-mutations
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] New mutations tested in gameplay
- [ ] Not overpowered or underpowered
- [ ] Pollution costs appropriate
- [ ] Synergies considered

**Pollution Costs**:
| Mutation | Pollution Cost |
|----------|----------------|
| Acidic Spit | +12 |
| Radioactive Glow | +18 |
| Parasite Host | +10 |

---

### MUTATION-014: design-3-new-synergies
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] 3 new synergy combinations
- [ ] Use mix of old and new mutations
- [ ] Meaningful bonus effects

**New Synergies**:

| # | Name | Required | Bonus |
|---|------|----------|-------|
| 4 | Invisible Predator | Camouflage + Quick Tongue + Big Eyes | Camo attacks deal 2x damage |
| 5 | Toxic Wasteland | Acidic Spit + Oil Slick + Toxic Aura | Puddles and trails last 2x longer |
| 6 | Immortal Frog | Tough Skin + Regeneration + Parasite Host | Tadpoles also heal player |

---

### MUTATION-015: implement-synergy-combos
**Size**: M | **Priority**: P1

**Acceptance Criteria**:
- [ ] All 3 new synergies implemented
- [ ] Bonus effects work correctly
- [ ] UI shows synergy status

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `invisible_pred_damage_mult` | float | 2.0 | Camo attack multiplier |
| `toxic_wasteland_duration_mult` | float | 2.0 | Trail/puddle extension |
| `immortal_frog_heal_amount` | int | 1 | HP healed per tadpole |

---

### MUTATION-016: mutation-description-update
**Size**: S | **Priority**: P1

**Acceptance Criteria**:
- [ ] All new mutations have descriptions
- [ ] Stats clearly shown
- [ ] Pollution costs visible
- [ ] Synergy hints included

---

### MUTATION-017: synergy-tooltip-ui
**Size**: S | **Priority**: P1

**Acceptance Criteria**:
- [ ] Synergies show in mutation UI
- [ ] Active synergies highlighted
- [ ] Tooltip explains bonus
- [ ] Shows required mutations

---

## Files to Create

| File | Purpose |
|------|---------|
| `metagame/resources/mutations/camouflage.tres` | New mutation |
| `metagame/resources/mutations/webbed_feet.tres` | New mutation |
| `metagame/resources/mutations/acidic_spit.tres` | New mutation |
| `metagame/resources/mutations/radioactive_glow.tres` | New mutation |
| `metagame/resources/mutations/parasite_host.tres` | New mutation |
| `metagame/resources/synergies/invisible_predator.tres` | New synergy |
| `metagame/resources/synergies/toxic_wasteland.tres` | New synergy |
| `metagame/resources/synergies/immortal_frog.tres` | New synergy |
| `test/unit/test_new_mutations.gd` | Tests |

---

## Success Metrics

- 7 stories completed
- 15 total mutations working
- 6 total synergies working
- All balanced and documented

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
