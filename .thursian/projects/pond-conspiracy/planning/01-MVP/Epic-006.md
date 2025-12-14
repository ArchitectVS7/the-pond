# EPIC-006: Mutation System - Development Plan

## Overview

**Epic**: EPIC-006 (Mutation System)
**Release Phase**: MVP
**Priority**: P0 (Core roguelike mechanic)
**Dependencies**: EPIC-001 (Combat System Foundation)
**Estimated Effort**: L (1.5 weeks)
**PRD Requirements**: FR-004

**Description**: 10-12 mutations with 3 synergies, level-up choice UI, pollution tracking.

---

## Automated Workflow Protocol

### Before Each Story
1. **READ THIS PLAN** for re-alignment before starting
2. Verify dependencies from previous stories are complete
3. Check DEVELOPERS_MANUAL.md for any tunable parameters from prior work

### Story Completion Criteria
- ✅ All tests pass (adversarial workflow complete)
- ✅ Tunable parameters documented in DEVELOPERS_MANUAL.md
- ✅ No human sign-off required - proceed immediately to next story

### Blocker Handling
- If a story cannot be completed due to blockers or human-required actions:
  - **SKIP** the blocked steps
  - **NOTE** in DEVELOPERS_MANUAL.md under "Blocked Steps" section
  - **PROCEED** to next story

---

## Stories

### MUTATION-001: mutation-data-structure
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] MutationResource class created
- [ ] Supports name, description, icon, type
- [ ] Type enum: POLLUTION, FROG, HYBRID
- [ ] Stat modifiers stored in dictionary
- [ ] Can be serialized for save system

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `metagame/resources/MutationResource.gd`
3. Define all properties with exports
4. Create enum for mutation types
5. Implement modifier application method

**Test Cases**:
- `test_mutation_resource_creates` - Resource instantiates
- `test_mutation_has_all_properties` - All fields accessible
- `test_mutation_type_enum` - Enum values correct
- `test_mutation_serializable` - Can save/load

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| (see individual mutations) | - | - | Each mutation has unique stats |

---

### MUTATION-002: level-up-choice-ui-3options
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Level-up screen pauses game
- [ ] Shows 3 random mutation options
- [ ] Each option displays name, description, icon
- [ ] Selection applies mutation and resumes

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `metagame/scenes/LevelUpUI.tscn`
3. Create 3 MutationCard child scenes
4. Implement random selection from pool
5. Handle input and selection events

**Test Cases**:
- `test_levelup_pauses_game` - Time scale = 0
- `test_levelup_shows_3_options` - 3 cards visible
- `test_selection_applies_mutation` - Mutation added to player
- `test_selection_resumes_game` - Time scale = 1

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `options_count` | int | 3 | Mutations offered per level |
| `card_width` | int | 200 | Mutation card width |
| `card_height` | int | 280 | Mutation card height |
| `card_spacing` | int | 40 | Space between cards |
| `animation_duration` | float | 0.3 | UI appear animation |

---

### MUTATION-003: mutation-application-system
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Player has mutation list/array
- [ ] Mutations modify player stats
- [ ] Some mutations trigger abilities
- [ ] Mutations stack (can have multiple)

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `metagame/scripts/mutation_manager.gd`
3. Add to player as child node
4. Implement `add_mutation()`, `remove_mutation()`
5. Apply modifiers to player controller

**Test Cases**:
- `test_add_mutation_adds_to_list` - List grows
- `test_mutation_modifies_stats` - Speed/damage changed
- `test_multiple_mutations_stack` - Effects cumulative
- `test_remove_mutation_reverts` - Stats restored

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `max_mutations` | int | 10 | Maximum mutations allowed |
| `allow_duplicates` | bool | false | Can stack same mutation |

---

### MUTATION-004: implement-10-base-mutations
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] 10 mutations fully implemented
- [ ] Mix of stat boosts and abilities
- [ ] Each has unique visual distinction
- [ ] Balanced for early game

**Base Mutations**:

| # | Name | Type | Effect |
|---|------|------|--------|
| 1 | Speed Boost | FROG | +20% move speed |
| 2 | Tough Skin | FROG | +1 max HP |
| 3 | Quick Tongue | FROG | -15% attack cooldown |
| 4 | Long Reach | FROG | +30% tongue range |
| 5 | Double Jump | FROG | Can dash (new ability) |
| 6 | Sticky Feet | FROG | No knockback taken |
| 7 | Big Eyes | FROG | +10% crit chance |
| 8 | Strong Legs | FROG | +10% damage |
| 9 | Slippery | FROG | +15% dodge chance |
| 10 | Regeneration | FROG | Heal 1 HP every 30s |

**Implementation Steps**:
1. Read plan for re-alignment
2. Create resource file for each mutation
3. Implement stat modifications in mutation_manager
4. Test each mutation individually

**Test Cases**:
- `test_speed_boost_increases_speed` - 20% increase
- `test_tough_skin_adds_hp` - +1 max HP
- `test_quick_tongue_reduces_cooldown` - 15% reduction
- (etc. for each mutation)

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `speed_boost_percent` | float | 0.2 | Speed increase |
| `tough_skin_hp` | int | 1 | HP increase |
| `quick_tongue_reduction` | float | 0.15 | Cooldown reduction |
| `long_reach_percent` | float | 0.3 | Range increase |
| `big_eyes_crit` | float | 0.1 | Crit chance |
| `strong_legs_damage` | float | 0.1 | Damage increase |
| `slippery_dodge` | float | 0.15 | Dodge chance |
| `regeneration_interval` | float | 30.0 | Seconds between heals |
| `regeneration_amount` | int | 1 | HP healed |

---

### MUTATION-005: pollution-mutations-oil-toxic-mercury
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] 3 pollution-themed mutations
- [ ] Each increases pollution index
- [ ] Powerful effects to offset downside
- [ ] Distinct visual effects

**Pollution Mutations**:

| # | Name | Type | Effect | Pollution |
|---|------|------|--------|-----------|
| 1 | Oil Slick | POLLUTION | Leave damaging trail | +15 |
| 2 | Toxic Aura | POLLUTION | Damage nearby enemies | +12 |
| 3 | Mercury Blood | POLLUTION | +50% damage, -1 max HP | +20 |

**Implementation Steps**:
1. Read plan for re-alignment
2. Create pollution mutation resources
3. Implement trail/aura mechanics
4. Connect to pollution index system

**Test Cases**:
- `test_oil_slick_creates_trail` - Trail spawns behind player
- `test_toxic_aura_damages_nearby` - Damage tick in radius
- `test_mercury_blood_tradeoff` - Damage up, HP down
- `test_pollution_increases` - Index rises on selection

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `oil_trail_damage` | int | 1 | Damage per tick |
| `oil_trail_duration` | float | 2.0 | Trail lifetime |
| `oil_trail_width` | float | 20.0 | Trail width |
| `toxic_aura_radius` | float | 50.0 | Damage radius |
| `toxic_aura_damage` | int | 1 | Damage per tick |
| `toxic_aura_interval` | float | 1.0 | Seconds between ticks |
| `mercury_damage_boost` | float | 0.5 | Damage increase |
| `mercury_hp_penalty` | int | 1 | Max HP reduction |
| `oil_pollution_cost` | int | 15 | Pollution added |
| `toxic_pollution_cost` | int | 12 | Pollution added |
| `mercury_pollution_cost` | int | 20 | Pollution added |

---

### MUTATION-006: frog-mutations-tongue-lily-croak
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] 3 frog-themed special mutations
- [ ] Unique abilities (not just stat boosts)
- [ ] Thematically fitting
- [ ] No pollution cost

**Frog Mutations**:

| # | Name | Type | Effect |
|---|------|------|--------|
| 1 | Split Tongue | FROG | Attack hits in 30° cone |
| 2 | Lily Pad | FROG | Temporary platform on water |
| 3 | War Croak | FROG | Stun enemies in radius (cooldown) |

**Implementation Steps**:
1. Read plan for re-alignment
2. Create frog mutation resources
3. Implement special ability mechanics
4. Add cooldowns where needed

**Test Cases**:
- `test_split_tongue_cone` - Multiple hit detection
- `test_lily_pad_spawns` - Platform created
- `test_war_croak_stuns` - Enemies freeze temporarily

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `split_tongue_angle` | float | 30.0 | Cone angle in degrees |
| `split_tongue_projectiles` | int | 3 | Tongue count |
| `lily_pad_duration` | float | 3.0 | Platform lifetime |
| `lily_pad_cooldown` | float | 10.0 | Spawn cooldown |
| `war_croak_radius` | float | 100.0 | Stun radius |
| `war_croak_duration` | float | 1.5 | Stun duration |
| `war_croak_cooldown` | float | 15.0 | Ability cooldown |

---

### MUTATION-007: synergy-system-3combos
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] Synergy detection system
- [ ] 3 synergy combinations defined
- [ ] Bonus effect when synergy active
- [ ] Visual indicator for active synergies

**Synergies**:

| # | Name | Required Mutations | Bonus |
|---|------|-------------------|-------|
| 1 | Apex Predator | Quick Tongue + Long Reach + Strong Legs | +25% attack speed |
| 2 | Pollution Immune | Oil Slick + Toxic Aura + Tough Skin | Immune to own pollution damage |
| 3 | Swamp King | Lily Pad + Slippery + Speed Boost | +50% speed on water/trails |

**Implementation Steps**:
1. Read plan for re-alignment
2. Create SynergyResource class
3. Define synergy combinations
4. Check for synergies on mutation add
5. Apply bonus effects

**Test Cases**:
- `test_synergy_detects_combo` - Synergy activates with right mutations
- `test_synergy_bonus_applies` - Bonus effect active
- `test_synergy_deactivates` - Removing mutation breaks synergy
- `test_multiple_synergies` - Can have multiple active

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `apex_speed_bonus` | float | 0.25 | Attack speed increase |
| `swamp_king_speed_bonus` | float | 0.5 | Movement speed on water |

---

### MUTATION-008: mutation-balance-tuning
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] All mutations tested in gameplay
- [ ] No obviously broken combinations
- [ ] Pollution mutations feel worth the cost
- [ ] Synergies are powerful but not mandatory

**Implementation Steps**:
1. Read plan for re-alignment
2. Create balance testing scenario
3. Run through with different builds
4. Adjust values based on testing
5. Document final values

**Deliverables**:
- Balance notes document
- Updated tunable parameters
- Known strong/weak combinations

**Potential Blockers**:
- [ ] Requires playtest data → Use theoretical balance, note in DEVELOPERS_MANUAL.md

---

### MUTATION-009: mutation-description-tooltips
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Each mutation has clear description
- [ ] Stats shown in tooltip (actual numbers)
- [ ] Pollution cost shown for pollution mutations
- [ ] Synergy hints shown

**Implementation Steps**:
1. Read plan for re-alignment
2. Write descriptions for all mutations
3. Format stats with actual values
4. Add synergy hints to relevant mutations

**Test Cases**:
- `test_all_mutations_have_descriptions` - No empty strings
- `test_descriptions_show_stats` - Numbers visible
- `test_pollution_shows_cost` - Pollution mutations show cost

**Tunable Parameters**: None (content task)

---

### MUTATION-010: pollution-index-increment-logic
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Pollution index increases on pollution mutation selection
- [ ] Each mutation type has weight
- [ ] Signal emitted for UI update
- [ ] Pollution persists for run duration

**Implementation Steps**:
1. Read plan for re-alignment
2. Add pollution tracking to mutation_manager
3. Emit signal on pollution change
4. Connect to pollution meter (EPIC-005)

**Test Cases**:
- `test_pollution_starts_zero` - Clean at run start
- `test_pollution_increases_on_selection` - Value increases
- `test_pollution_signal_emitted` - Event fires
- `test_pollution_cumulative` - Multiple mutations stack

**Tunable Parameters**:
(See MUTATION-005 for pollution costs per mutation)

---

## Files to Create

| File | Purpose |
|------|---------|
| `metagame/resources/MutationResource.gd` | Mutation data class |
| `metagame/resources/SynergyResource.gd` | Synergy data class |
| `metagame/resources/mutations/*.tres` | Individual mutation files |
| `metagame/resources/synergies/*.tres` | Synergy definition files |
| `metagame/scripts/mutation_manager.gd` | Player mutation handling |
| `metagame/scripts/synergy_checker.gd` | Synergy detection |
| `metagame/scenes/LevelUpUI.tscn` | Level-up screen |
| `metagame/scenes/MutationCard.tscn` | Card component |
| `metagame/scripts/level_up_ui.gd` | Level-up logic |
| `test/unit/test_mutations.gd` | Mutation tests |
| `test/unit/test_synergies.gd` | Synergy tests |

---

## Dependencies Graph

```
MUTATION-001 (data structure)
        ↓
MUTATION-002 (level-up UI) → MUTATION-003 (application system)
                                    ↓
        ┌───────────────────────────┼───────────────────────────┐
        ↓                           ↓                           ↓
MUTATION-004 (10 base)     MUTATION-005 (pollution)     MUTATION-006 (frog)
        │                           │                           │
        └───────────────────────────┼───────────────────────────┘
                                    ↓
                            MUTATION-007 (synergies)
                                    ↓
                            MUTATION-008 (balance)
                                    ↓
                            MUTATION-009 (tooltips)
                                    ↓
                            MUTATION-010 (pollution index)
```

---

## Success Metrics

- 10 stories completed
- 16 mutations implemented (10 base + 3 pollution + 3 frog)
- 3 synergies working
- Level-up UI functional
- All parameters documented in DEVELOPERS_MANUAL.md

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
