# EPIC-019: Daily Challenges & Leaderboards - Development Plan

## Overview

**Epic**: EPIC-019 (Daily Challenges & Leaderboards)
**Release Phase**: Beta
**Priority**: P2 (Replayability)
**Dependencies**: EPIC-009, EPIC-010 (Save System, Platform Support)
**Estimated Effort**: L (1.5 weeks)
**PRD Requirements**: Beta FR

**Description**: Daily seeded runs with leaderboards.

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

### DAILY-001: seeded-run-generation
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Seed determines all RNG
- [ ] Same seed = same run
- [ ] Seed affects enemies, mutations, spawns
- [ ] Seed can be shared

**Seed Coverage**:
- Enemy spawn patterns
- Enemy types per wave
- Mutation offerings
- Boss attack timings
- Item drops

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `seed_string_max_length` | int | 16 | Max characters in seed |
| `daily_seed_format` | String | "YYYYMMDD" | Date-based seed format |

---

### DAILY-002: daily-challenge-framework
**Size**: L | **Priority**: P2

**Acceptance Criteria**:
- [ ] New challenge every 24 hours
- [ ] Same challenge globally
- [ ] One attempt per day
- [ ] Results tracked

**Challenge Generation**:
```gdscript
func generate_daily_seed() -> String:
    var date = Time.get_date_dict_from_system()
    return "DAILY_%04d%02d%02d" % [date.year, date.month, date.day]
```

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `challenge_reset_utc_hour` | int | 0 | UTC hour for new challenge |
| `attempts_per_day` | int | 1 | Runs allowed per challenge |
| `practice_mode_enabled` | bool | true | Allow non-scoring practice |

---

### DAILY-003: steam-leaderboard-integration
**Size**: L | **Priority**: P2

**Acceptance Criteria**:
- [ ] Steam leaderboard API integrated
- [ ] Scores upload on run end
- [ ] Scores download for display
- [ ] Handles offline gracefully

**Leaderboard Types**:
| ID | Name | Sort | Score Type |
|----|------|------|------------|
| daily_score | Daily Challenge | Descending | Total score |
| daily_time | Daily Speedrun | Ascending | Time in seconds |
| alltime_score | All-Time Best | Descending | Total score |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `leaderboard_upload_retry` | int | 3 | Upload retry attempts |
| `leaderboard_cache_duration` | float | 300.0 | Seconds to cache scores |

**Potential Blockers**:
- [ ] Steam API access required → SKIP, note in DEVELOPERS_MANUAL.md

---

### DAILY-004: daily-challenge-ui
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Challenge menu accessible from main menu
- [ ] Shows today's seed
- [ ] Shows remaining attempts
- [ ] Shows timer until next challenge

**UI Elements**:
- Challenge title/theme
- Seed display (optional reveal)
- Start Challenge button
- "Already attempted" state
- Countdown timer

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `show_seed_to_player` | bool | false | Display seed string |
| `countdown_refresh_rate` | float | 1.0 | Timer update frequency |

---

### DAILY-005: leaderboard-display-top100
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Shows top 100 players
- [ ] Highlights player's rank
- [ ] Shows friend scores if available
- [ ] Pagination for scrolling

**Display Columns**:
| Column | Description |
|--------|-------------|
| Rank | 1-100 position |
| Player | Steam name |
| Score | Total score |
| Time | Run duration |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `leaderboard_page_size` | int | 20 | Entries per page |
| `show_friends_first` | bool | true | Prioritize friend scores |
| `highlight_player_rank` | bool | true | Highlight user's position |

---

### DAILY-006: daily-challenge-rewards
**Size**: S | **Priority**: P2

**Acceptance Criteria**:
- [ ] Participation rewards
- [ ] Rank-based rewards
- [ ] Streak rewards for consecutive days
- [ ] Cosmetic unlocks

**Reward Tiers**:
| Tier | Requirement | Reward |
|------|-------------|--------|
| Participant | Complete challenge | +10 currency |
| Top 50% | Beat median score | +25 currency |
| Top 10% | Top 10% score | +50 currency |
| Champion | #1 daily | Special cosmetic |
| Streak 7 | 7 days in a row | Streak badge |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `participation_reward` | int | 10 | Base currency |
| `top_50_reward` | int | 25 | Top half bonus |
| `top_10_reward` | int | 50 | Top 10% bonus |
| `streak_bonus_per_day` | int | 5 | Extra per streak day |

---

### DAILY-007: challenge-expiration-logic
**Size**: S | **Priority**: P2

**Acceptance Criteria**:
- [ ] Challenge locks after 24 hours
- [ ] In-progress runs complete
- [ ] No late submissions
- [ ] Grace period for active runs

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `challenge_duration_hours` | int | 24 | Challenge window |
| `grace_period_minutes` | int | 30 | Extra time for active runs |
| `allow_late_start` | bool | false | Start after window |

---

## Files to Create

| File | Purpose |
|------|---------|
| `metagame/scripts/daily_challenge.gd` | Challenge system |
| `metagame/scripts/seeded_rng.gd` | Seeded RNG wrapper |
| `metagame/scripts/leaderboard_manager.gd` | Steam leaderboards |
| `metagame/scenes/DailyChallengeMenu.tscn` | Challenge UI |
| `metagame/scenes/LeaderboardDisplay.tscn` | Leaderboard UI |
| `test/unit/test_daily_challenge.gd` | Tests |
| `test/unit/test_seeded_rng.gd` | RNG tests |

---

## Success Metrics

- 7 stories completed
- Daily challenges working
- Leaderboards functional (or blocked with docs)
- Rewards engaging

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
