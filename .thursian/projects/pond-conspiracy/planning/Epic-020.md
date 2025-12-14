# EPIC-020: Endless Mode - Development Plan

## Overview

**Epic**: EPIC-020 (Endless Mode)
**Release Phase**: Beta
**Priority**: P3 (Optional mode)
**Dependencies**: EPIC-001, EPIC-006 (Combat, Mutation System)
**Estimated Effort**: M (1 week)
**PRD Requirements**: Beta FR

**Description**: Survive as long as possible mode.

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

### ENDLESS-001: endless-mode-spawning-infinite
**Size**: M | **Priority**: P3

**Acceptance Criteria**:
- [ ] No end to enemy spawning
- [ ] All enemy types appear
- [ ] No bosses in endless mode
- [ ] Spawning intensifies over time

**Spawn Algorithm**:
```gdscript
func get_spawn_rate(time_survived: float) -> float:
    # Start at 2.0s, approach 0.3s asymptotically
    var base = 2.0
    var min_rate = 0.3
    var decay = 0.01
    return max(min_rate, base * exp(-decay * time_survived))
```

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `endless_base_spawn_rate` | float | 2.0 | Initial spawn interval |
| `endless_min_spawn_rate` | float | 0.3 | Fastest spawn interval |
| `endless_spawn_decay` | float | 0.01 | Rate of difficulty increase |
| `endless_max_enemies` | int | 200 | Enemy cap |

---

### ENDLESS-002: difficulty-scaling-exponential
**Size**: M | **Priority**: P3

**Acceptance Criteria**:
- [ ] Difficulty increases over time
- [ ] Enemy HP scales
- [ ] Enemy speed scales
- [ ] New enemy types introduced gradually

**Scaling Formula**:
```gdscript
func get_difficulty_multiplier(time_survived: float) -> float:
    # 1.0 at start, doubles every 5 minutes
    return pow(2.0, time_survived / 300.0)
```

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `difficulty_double_time` | float | 300.0 | Seconds to double difficulty |
| `hp_scale_enabled` | bool | true | Scale enemy HP |
| `speed_scale_enabled` | bool | true | Scale enemy speed |
| `max_difficulty_mult` | float | 10.0 | Cap difficulty multiplier |
| `new_enemy_interval` | float | 120.0 | Seconds between enemy type unlocks |

---

### ENDLESS-003: endless-mode-ui-timer-score
**Size**: M | **Priority**: P3

**Acceptance Criteria**:
- [ ] Timer shows time survived
- [ ] Score counter visible
- [ ] Kill counter visible
- [ ] Current difficulty indicator

**HUD Elements**:
| Element | Position | Content |
|---------|----------|---------|
| Timer | Top center | MM:SS.ms |
| Score | Top right | Running total |
| Kills | Below score | Enemy count |
| Difficulty | Top left | Skull icons or meter |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `show_timer` | bool | true | Display timer |
| `show_kills` | bool | true | Display kill count |
| `difficulty_display_mode` | int | 1 | 0=none, 1=icons, 2=meter |

---

### ENDLESS-004: endless-mode-leaderboard
**Size**: M | **Priority**: P3

**Acceptance Criteria**:
- [ ] Separate leaderboard from daily
- [ ] Tracks time survived
- [ ] Tracks score
- [ ] Local and online boards

**Leaderboard Entries**:
| ID | Name | Sort |
|----|------|------|
| endless_time | Endless Survival | Descending (time) |
| endless_score | Endless Score | Descending (score) |
| endless_kills | Endless Kills | Descending (kills) |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `endless_leaderboard_enabled` | bool | true | Use online boards |
| `local_high_score_count` | int | 10 | Local scores to keep |

**Potential Blockers**:
- [ ] Steam leaderboards → Fall back to local only, note in DEVELOPERS_MANUAL.md

---

### ENDLESS-005: endless-mode-achievement
**Size**: S | **Priority**: P3

**Acceptance Criteria**:
- [ ] Survival time achievements
- [ ] Kill count achievements
- [ ] Score achievements

**Achievements**:
| ID | Name | Requirement |
|----|------|-------------|
| ENDLESS_5MIN | "5 Minutes of Fame" | Survive 5 minutes |
| ENDLESS_10MIN | "The Long Haul" | Survive 10 minutes |
| ENDLESS_20MIN | "Endless Dedication" | Survive 20 minutes |
| ENDLESS_1000_KILLS | "Frog of War" | Kill 1000 enemies |
| ENDLESS_100K_SCORE | "High Scorer" | Reach 100,000 score |

---

### ENDLESS-006: endless-mode-balance-tuning
**Size**: M | **Priority**: P3

**Acceptance Criteria**:
- [ ] Tested for fairness
- [ ] Skill-based progression
- [ ] Mutations matter
- [ ] No impossible scaling

**Balance Goals**:
- Average player: 3-5 minutes
- Good player: 8-12 minutes
- Expert player: 15-20+ minutes
- Theoretical max: ~30 minutes (scaling becomes overwhelming)

**Testing Checklist**:
- [ ] No build is mandatory
- [ ] Multiple viable strategies
- [ ] Luck doesn't dominate skill
- [ ] Deaths feel fair

---

## Files to Create

| File | Purpose |
|------|---------|
| `combat/scripts/endless_mode.gd` | Mode logic |
| `combat/scripts/endless_spawner.gd` | Spawn management |
| `combat/scripts/endless_scaler.gd` | Difficulty scaling |
| `combat/scenes/EndlessArena.tscn` | Endless arena |
| `metagame/scenes/EndlessModeMenu.tscn` | Mode select UI |
| `metagame/scenes/EndlessResultsScreen.tscn` | Results display |
| `test/unit/test_endless_mode.gd` | Tests |

---

## Endless Mode Design Philosophy

**Core Loop**:
1. Start with basic mutations
2. Survive waves of increasing difficulty
3. Collect XP, level up, gain mutations
4. Push personal best time/score
5. Die, compare to leaderboard
6. Try again with new strategy

**What Makes It Fun**:
- Pure skill expression
- No narrative interruption
- High score chasing
- Mutation experimentation
- "One more run" feeling

---

## Success Metrics

- 6 stories completed
- Endless mode playable
- Balanced difficulty curve
- Leaderboards working (or local fallback)
- Achievements functional

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
