# EPIC-017: Secret Boss (Sentient Pond) - Development Plan

## Overview

**Epic**: EPIC-017 (Secret Boss - Sentient Pond)
**Release Phase**: Beta
**Priority**: P2 (Discovery content)
**Dependencies**: EPIC-007, EPIC-012 (Boss Encounters, Third Boss)
**Estimated Effort**: L (1.5 weeks)
**PRD Requirements**: Beta FR

**Description**: True final boss with secret unlock condition.

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

### SECRET-001: sentient-pond-boss-design
**Size**: L | **Priority**: P2

**Acceptance Criteria**:
- [ ] Unique boss design - the pond itself
- [ ] Eldritch/cosmic horror aesthetic
- [ ] Eyes emerging from water
- [ ] Tentacle/wave attacks
- [ ] Larger arena than other bosses

**Design Notes**:
- The pond is alive - polluted into sentience
- Multi-phase fight against water itself
- Environmental hazards integrated

**Potential Blockers**:
- [ ] Complex art requirements → Use simpler design, note in DEVELOPERS_MANUAL.md

---

### SECRET-002: secret-unlock-condition-easter-egg
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Secret condition to access boss
- [ ] Not obvious on first playthrough
- [ ] Requires specific actions/discoveries
- [ ] Hints available for observant players

**Unlock Condition**:
1. Defeat all 3 main bosses
2. Collect all 7 evidence pieces
3. Find hidden "Pond Memory" in each arena (3 total)
4. Return to starting pond area
5. Stand in center during full moon phase

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `require_all_bosses` | bool | true | Must defeat all bosses |
| `require_all_evidence` | bool | true | Must have all evidence |
| `pond_memories_required` | int | 3 | Hidden collectibles needed |
| `moon_phase_required` | bool | true | Timing requirement |

---

### SECRET-003: pond-bullet-patterns-water-themed
**Size**: L | **Priority**: P2

**Acceptance Criteria**:
- [ ] Phase 1: "Rising Tide" - Waves from edges
- [ ] Phase 2: "Whirlpool" - Spiral pulling patterns
- [ ] Phase 3: "Tsunami" - Screen-filling chaos
- [ ] Phase 4: "Calm Before Storm" - Fake victory, then surprise

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `pond_hp` | int | 200 | Highest HP boss |
| `wave_speed` | float | 180.0 | Bullet wave speed |
| `whirlpool_pull_strength` | float | 50.0 | Player pull force |
| `tsunami_bullet_count` | int | 100 | Bullets in tsunami |
| `fake_death_hp` | float | 0.1 | HP% for fake death |

---

### SECRET-004: pond-4phase-mechanics
**Size**: L | **Priority**: P2

**Acceptance Criteria**:
- [ ] 4 phases (more than other bosses)
- [ ] Phase 4 is surprise after "defeat"
- [ ] Environmental hazards each phase
- [ ] Increasing water level mechanic

**Phase Breakdown**:
| Phase | HP Range | Mechanic |
|-------|----------|----------|
| 1 | 100%-66% | Rising water edges |
| 2 | 66%-33% | Whirlpool center pull |
| 3 | 33%-10% | Random geysers |
| 4 | Fake death → 10%-0% | All mechanics combined |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `water_rise_speed` | float | 5.0 | Pixels per second |
| `water_max_height` | float | 100.0 | Max water encroachment |
| `geyser_warning_time` | float | 1.0 | Seconds before geyser |
| `geyser_damage` | int | 2 | Damage from geyser |

---

### SECRET-005: pond-dialogue-eldritch-horror
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Creepy, otherworldly dialogue
- [ ] References pollution giving it consciousness
- [ ] Questions player's motivations
- [ ] Philosophical about existence

**Dialogue Lines**:
- **Intro**: "YOU... MADE ME. Your chemicals. Your waste. Your NEGLIGENCE. I am what you created."
- **Phase 2**: "Do you feel it? The pull of consequence?"
- **Phase 3**: "I AM EVERY DROP. EVERY MOLECULE. YOU CANNOT DEFEAT WATER."
- **Fake Death**: "Finally... peace..."
- **Phase 4**: "DID YOU THINK IT WOULD BE THAT EASY?!"
- **True Death**: "Perhaps... in time... another pond... will remember..."

---

### SECRET-006: pond-defeat-reward-true-ending
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Unlocks true ending
- [ ] Special cutscene
- [ ] Ultimate evidence piece
- [ ] Credits sequence

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `true_ending_cutscene_length` | float | 60.0 | Cutscene duration |
| `credits_scroll_speed` | float | 50.0 | Credits scroll speed |

---

### SECRET-007: secret-boss-achievement
**Size**: S | **Priority**: P2

**Acceptance Criteria**:
- [ ] Achievement for finding secret boss
- [ ] Achievement for defeating secret boss
- [ ] Rare/hidden achievement category

**Achievements**:
| ID | Name | Description |
|----|------|-------------|
| SECRET_FOUND | "Something's Watching" | Discover the secret boss |
| SECRET_DEFEATED | "Return to Pond" | Defeat the Sentient Pond |
| TRUE_ENDING | "The Whole Truth" | Achieve the true ending |

---

## Files to Create

| File | Purpose |
|------|---------|
| `combat/scripts/boss_pond.gd` | Secret boss logic |
| `combat/scenes/BossPond.tscn` | Boss scene |
| `combat/scenes/PondArena.tscn` | Special arena |
| `combat/scripts/water_hazard.gd` | Environmental hazards |
| `metagame/scripts/secret_tracker.gd` | Unlock condition tracking |
| `metagame/scenes/TrueEndingCutscene.tscn` | True ending |
| `assets/sprites/bosses/pond/*.png` | Boss art |
| `test/unit/test_secret_boss.gd` | Tests |

---

## Success Metrics

- 7 stories completed
- Secret boss fully playable
- True ending achievable
- Secret feels rewarding to discover

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
