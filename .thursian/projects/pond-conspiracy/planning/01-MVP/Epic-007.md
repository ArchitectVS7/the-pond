# EPIC-007: Boss Encounters - Development Plan

## Overview

**Epic**: EPIC-007 (Boss Encounters)
**Release Phase**: MVP
**Priority**: P0 (Must-have for ending)
**Dependencies**: EPIC-001, EPIC-002 (Combat, BulletUpHell)
**Estimated Effort**: L (1.5 weeks)
**PRD Requirements**: FR-005

**Description**: 2 boss fights (The Lobbyist, The CEO) with unique patterns and phases.

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
- If a story cannot be completed due to blockers or human-required actions:
  - **SKIP** the blocked steps
  - **NOTE** in DEVELOPERS_MANUAL.md under "Blocked Steps" section
  - **PROCEED** to next story

---

## Stories

### BOSS-001: boss-framework-phases-hp
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] BossBase class with phase system
- [ ] HP pool with phase thresholds
- [ ] State machine for boss states
- [ ] Attack pattern switching per phase
- [ ] Death/defeat handling

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `combat/scripts/boss_base.gd`
3. Implement phase state machine
4. Define phase transition thresholds
5. Create attack pattern interface

**Boss States**:
- `IDLE` - Waiting/intro
- `PHASE_1` - First attack pattern
- `PHASE_2` - Second attack pattern
- `PHASE_3` - Final attack pattern
- `TRANSITIONING` - Between phases
- `DEFEATED` - Death sequence

**Test Cases**:
- `test_boss_starts_idle` - Initial state correct
- `test_boss_transitions_phases` - HP triggers phase change
- `test_boss_defeated_at_zero_hp` - Death triggers
- `test_phase_changes_attack_pattern` - Different attacks per phase

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `total_hp` | int | 100 | Boss total health |
| `phase_2_threshold` | float | 0.66 | HP% for phase 2 |
| `phase_3_threshold` | float | 0.33 | HP% for phase 3 |
| `phase_transition_duration` | float | 2.0 | Invulnerability during transition |
| `intro_duration` | float | 3.0 | Time before boss becomes active |

---

### BOSS-002: boss-arena-spawning-trigger
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Boss arena defined as zone
- [ ] Boss spawns when player enters
- [ ] Arena locks during fight
- [ ] Normal enemies cleared on boss spawn

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `combat/scenes/BossArena.tscn`
3. Add Area2D trigger zone
4. Implement arena lock (invisible walls)
5. Connect to enemy spawner for clearing

**Test Cases**:
- `test_boss_spawns_on_enter` - Trigger works
- `test_arena_locks` - Player can't leave
- `test_enemies_cleared` - No regular enemies during boss
- `test_arena_unlocks_on_defeat` - Exit opens

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `arena_width` | int | 800 | Arena width in pixels |
| `arena_height` | int | 600 | Arena height in pixels |
| `spawn_delay` | float | 1.0 | Delay after entering before boss appears |
| `lock_fade_duration` | float | 0.5 | Wall appear animation time |

---

### BOSS-003: lobbyist-boss-design-pixel-art
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Lobbyist boss sprite created
- [ ] Suit-wearing frog design
- [ ] 3 phase visual variations
- [ ] Attack animations
- [ ] Idle and hurt animations

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `assets/sprites/bosses/lobbyist/` folder
3. Design base sprite (32x32 or 48x48)
4. Create animation frames
5. Set up AnimationPlayer

**Potential Blockers**:
- [ ] Art assets unavailable → Use placeholder shapes, note in DEVELOPERS_MANUAL.md

---

### BOSS-004: lobbyist-bullet-patterns-3phases
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] Phase 1: "Business Cards" - Slow aimed shots
- [ ] Phase 2: "Marketing Blitz" - Radial spreads
- [ ] Phase 3: "Hostile Takeover" - Chaos patterns
- [ ] Uses BulletUpHell patterns from EPIC-002

**Phase Attack Patterns**:

| Phase | HP Range | Pattern | Speed | Cooldown |
|-------|----------|---------|-------|----------|
| 1 | 100%-66% | Single aimed | 150 | 2.0s |
| 2 | 66%-33% | 8-way radial | 200 | 1.5s |
| 3 | 33%-0% | Spiral + aimed | 250 | 1.0s |

**Test Cases**:
- `test_phase1_aims_at_player` - Bullets go toward player
- `test_phase2_radial_burst` - 8 bullets in circle
- `test_phase3_spiral` - Rotating pattern

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `p1_bullet_speed` | float | 150.0 | Phase 1 bullet speed |
| `p1_cooldown` | float | 2.0 | Phase 1 attack interval |
| `p2_bullet_speed` | float | 200.0 | Phase 2 bullet speed |
| `p2_cooldown` | float | 1.5 | Phase 2 attack interval |
| `p2_radial_count` | int | 8 | Bullets per radial burst |
| `p3_bullet_speed` | float | 250.0 | Phase 3 bullet speed |
| `p3_cooldown` | float | 1.0 | Phase 3 attack interval |
| `p3_spiral_speed` | float | 90.0 | Spiral rotation degrees/sec |

---

### BOSS-005: lobbyist-dialogue-corporate-speak
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Intro dialogue on boss spawn
- [ ] Phase transition quips
- [ ] Defeat dialogue
- [ ] Corporate buzzword humor

**Dialogue Lines**:
- **Intro**: "Ah, a concerned citizen! Let me show you our... stakeholder engagement process."
- **Phase 2**: "Time for aggressive negotiations!"
- **Phase 3**: "This is YOUR fault for not synergizing!"
- **Defeat**: "My... quarterly reports... ruined..."

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `dialogue_display_time` | float | 3.0 | How long dialogue shows |
| `dialogue_font_size` | int | 16 | Text size |

---

### BOSS-006: ceo-boss-design-pixel-art
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] CEO boss sprite created
- [ ] Larger than Lobbyist (final boss)
- [ ] Crown/throne motif
- [ ] 3 phase visual variations

**Potential Blockers**:
- [ ] Art assets unavailable → Use placeholder shapes, note in DEVELOPERS_MANUAL.md

---

### BOSS-007: ceo-bullet-patterns-3phases
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] Phase 1: "Board Meeting" - Geometric patterns
- [ ] Phase 2: "Leveraged Buyout" - Homing bullets
- [ ] Phase 3: "Market Crash" - Screen-filling mayhem

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `ceo_total_hp` | int | 150 | Higher HP than Lobbyist |
| `ceo_p1_wall_speed` | float | 120.0 | Bullet wall speed |
| `ceo_p2_homing_strength` | float | 2.0 | Homing turn rate |
| `ceo_p2_homing_duration` | float | 3.0 | How long bullets home |
| `ceo_p3_spawn_interval` | float | 0.5 | Bullet spawn rate |

---

### BOSS-008: ceo-dialogue-final-boss
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Dramatic intro dialogue
- [ ] Escalating threat level in phases
- [ ] Defeat dialogue reveals conspiracy

**Dialogue Lines**:
- **Intro**: "You think you can stop PROGRESS? I AM the pond. I AM the pollution. I AM... THE MARKET!"
- **Phase 2**: "Your little investigation ends HERE!"
- **Phase 3**: "ENOUGH! I'll bury you like I buried the evidence!"
- **Defeat**: "No... the board will hear about this..."

---

### BOSS-009: boss-defeat-rewards-evidence
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Boss drops evidence item on defeat
- [ ] Evidence unlocks conspiracy board content
- [ ] Victory fanfare/effect
- [ ] Persistent unlock saved

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `evidence_spawn_delay` | float | 1.0 | Delay after death animation |
| `victory_fanfare_volume` | float | -3.0 | Audio volume dB |

---

### BOSS-010: boss-difficulty-scaling
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Boss stats scale with run progress
- [ ] More mutations = slightly harder boss
- [ ] Optional hard mode modifier

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `hp_scale_per_mutation` | float | 0.05 | 5% HP per mutation |
| `speed_scale_per_mutation` | float | 0.02 | 2% speed per mutation |
| `max_scaling` | float | 1.5 | Cap at 150% base stats |
| `hard_mode_multiplier` | float | 1.5 | Hard mode base increase |

---

## Files to Create

| File | Purpose |
|------|---------|
| `combat/scripts/boss_base.gd` | Base boss class |
| `combat/scripts/boss_lobbyist.gd` | Lobbyist boss |
| `combat/scripts/boss_ceo.gd` | CEO boss |
| `combat/scenes/BossLobbyist.tscn` | Lobbyist scene |
| `combat/scenes/BossCEO.tscn` | CEO scene |
| `combat/scenes/BossArena.tscn` | Arena template |
| `combat/resources/boss_patterns/*.tres` | Bullet patterns |
| `test/unit/test_boss_framework.gd` | Boss tests |

---

## Success Metrics

- 10 stories completed
- 2 fully playable boss fights
- 3 phases each with unique patterns
- DEVELOPERS_MANUAL.md updated with all tunable parameters

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
