# EPIC-005: Pollution Index UI - Development Plan

## Overview

**Epic**: EPIC-005 (Pollution Index UI)
**Release Phase**: MVP
**Priority**: P0 (1-day feature, critical for message)
**Dependencies**: EPIC-006 (Mutation System)
**Estimated Effort**: S (1 day)
**PRD Requirements**: FR-003, NEW-1

**Description**: Visual pollution meter on HUD, tracks pollution mutations, color-coded.

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

### POLLUTION-001: pollution-meter-progressbar
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] ProgressBar UI element created
- [ ] Displays current pollution level
- [ ] Range 0-100 (percentage)
- [ ] Positioned in HUD (top-right or bottom)

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `metagame/scenes/PollutionMeter.tscn`
3. Add ProgressBar with StyleBox customization
4. Create `metagame/scripts/pollution_meter.gd`
5. Expose `pollution_value` property

**Test Cases**:
- `test_meter_displays_value` - Value reflects internal state
- `test_meter_clamped_0_100` - Values outside range clamped
- `test_meter_updates_visually` - Bar fills correctly

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `meter_width` | int | 150 | Meter width in pixels |
| `meter_height` | int | 20 | Meter height in pixels |
| `meter_position` | Vector2 | Vector2(20, 20) | Screen position |
| `fill_direction` | int | 0 | 0=left-to-right, 1=bottom-to-top |

---

### POLLUTION-002: color-coding-green-yellow-red
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Meter is green at 0-33%
- [ ] Meter is yellow at 34-66%
- [ ] Meter is red at 67-100%
- [ ] Smooth color transitions

**Implementation Steps**:
1. Read plan for re-alignment
2. Define color thresholds
3. Lerp between colors for smooth transition
4. Update StyleBoxFlat fill color

**Test Cases**:
- `test_color_green_low` - Color correct at 0-33%
- `test_color_yellow_mid` - Color correct at 34-66%
- `test_color_red_high` - Color correct at 67-100%
- `test_color_transitions` - Gradient between zones

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `color_low` | Color | Color.GREEN | 0-33% color |
| `color_mid` | Color | Color.YELLOW | 34-66% color |
| `color_high` | Color | Color.RED | 67-100% color |
| `threshold_low` | float | 0.33 | Green/yellow boundary |
| `threshold_high` | float | 0.67 | Yellow/red boundary |
| `color_lerp_enabled` | bool | true | Smooth transitions |

---

### POLLUTION-003: tooltip-ecosystem-message
**Size**: XS | **Priority**: P0

**Acceptance Criteria**:
- [ ] Tooltip appears on hover
- [ ] Message explains pollution impact
- [ ] Message changes with severity level
- [ ] Tooltip styled consistently with UI

**Implementation Steps**:
1. Read plan for re-alignment
2. Add TooltipText or custom tooltip popup
3. Define messages for each severity level
4. Update message when pollution changes

**Test Cases**:
- `test_tooltip_appears_on_hover` - Tooltip triggers
- `test_tooltip_message_low` - Correct low message
- `test_tooltip_message_mid` - Correct mid message
- `test_tooltip_message_high` - Correct high message

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `message_low` | String | "The pond is healthy" | Low pollution message |
| `message_mid` | String | "Pollution is building up..." | Mid pollution message |
| `message_high` | String | "CRITICAL: Ecosystem in danger!" | High pollution message |
| `tooltip_delay` | float | 0.5 | Seconds before tooltip shows |

---

### POLLUTION-004: bind-pollution-mutation-count
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Pollution tracks number of pollution-type mutations
- [ ] Each pollution mutation adds to index
- [ ] Formula: pollution = pollution_mutations * weight
- [ ] Weight configurable per mutation type

**Implementation Steps**:
1. Read plan for re-alignment
2. Listen to mutation system signals
3. Filter for pollution-type mutations
4. Calculate cumulative pollution value

**Test Cases**:
- `test_zero_mutations_zero_pollution` - Clean start
- `test_pollution_mutation_increases` - Mutation adds pollution
- `test_multiple_mutations_cumulative` - Multiple mutations stack

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `pollution_per_mutation` | float | 15.0 | Base pollution per mutation |
| `oil_mutation_weight` | float | 1.5 | Oil mutation multiplier |
| `toxic_mutation_weight` | float | 1.2 | Toxic mutation multiplier |
| `mercury_mutation_weight` | float | 2.0 | Mercury mutation multiplier |
| `max_pollution` | float | 100.0 | Maximum pollution value |

---

### POLLUTION-005: update-on-mutation-selection-event
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Meter updates when player selects mutation
- [ ] Update is immediate (no delay)
- [ ] Animation shows increase (optional pulse)
- [ ] Event-driven architecture

**Implementation Steps**:
1. Read plan for re-alignment
2. Connect to EventBus `mutation_selected` signal
3. Recalculate pollution on signal
4. Trigger update animation

**Test Cases**:
- `test_update_on_mutation_signal` - Signal triggers update
- `test_update_immediate` - No visible delay
- `test_animation_plays` - Visual feedback works

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `update_animation` | bool | true | Enable pulse animation |
| `pulse_duration` | float | 0.3 | Animation duration |
| `pulse_scale` | float | 1.1 | Scale increase on pulse |

---

## Files to Create

| File | Purpose |
|------|---------|
| `metagame/scenes/PollutionMeter.tscn` | Meter UI scene |
| `metagame/scripts/pollution_meter.gd` | Meter logic |
| `metagame/scenes/HUD.tscn` | HUD container (if not exists) |
| `test/unit/test_pollution_meter.gd` | Unit tests |

---

## Dependencies Graph

```
POLLUTION-001 (progressbar)
        ↓
POLLUTION-002 (colors)
        ↓
POLLUTION-003 (tooltip)

POLLUTION-004 (mutation binding) → POLLUTION-005 (event update)
        ↓
[Requires EPIC-006 Mutation System]
```

---

## Integration Notes

This epic depends on EPIC-006 (Mutation System) for:
- Mutation type definitions (pollution vs. frog mutations)
- Mutation selection events
- Mutation weight values

If EPIC-006 is not complete:
- Implement POLLUTION-001 through POLLUTION-003 with mock data
- POLLUTION-004 and POLLUTION-005 should be marked as partially blocked
- Add stubs for mutation system integration

---

## Success Metrics

- All 5 stories completed (or blocked steps documented)
- Pollution meter displays correctly
- Color coding functional
- Event integration ready for mutation system
- DEVELOPERS_MANUAL.md updated with all tunable parameters

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
