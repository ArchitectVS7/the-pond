# EPIC-005: Pollution Index UI - Implementation Documentation

## Overview

Visual pollution meter displayed on the HUD showing environmental damage caused by selecting pollution-inducing mutations. Provides real-time feedback on ecosystem health with color-coded visual indicators and contextual tooltips.

**Epic Status**: ✅ Complete (5/5 stories - 2 with mutation system stubs pending EPIC-006)

**Files**:
- `metagame/scenes/PollutionMeter.tscn` - Pollution meter UI scene
- `metagame/scripts/pollution_meter.gd` - Meter logic and updates
- `metagame/scenes/HUD.tscn` - Main HUD with pollution meter
- `core/event_bus.gd` - Event signals for pollution system
- `test/unit/test_pollution_meter.gd` - Comprehensive unit tests (30+ tests)

---

## POLLUTION-001: ProgressBar-Based Pollution Meter

**Component**: `PollutionMeter` (extends Control)

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `meter_width` | int | 150 | Meter width in pixels |
| `meter_height` | int | 20 | Meter height in pixels |
| `meter_position` | Vector2 | Vector2(20, 20) | Screen position (pixels from top-left) |
| `fill_direction` | int | 0 | Fill direction (0=left-to-right) |
| `pollution_value` | float | 0.0 | Current pollution (0.0-100.0) |

**Tuning Notes**:
- Default 150x20px provides compact HUD element without obscuring gameplay
- Position at (20, 20) places meter in top-left with comfortable margin
- Meter auto-clamps values to 0-100 range
- ProgressBar syncs automatically with `pollution_value` changes

---

## POLLUTION-002: Color Coding (Green/Yellow/Red)

**Color System**: Dynamic color interpolation based on pollution thresholds

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `color_low` | Color | Color.GREEN | 0-33% pollution color |
| `color_mid` | Color | Color.YELLOW | 34-66% pollution color |
| `color_high` | Color | Color.RED | 67-100% pollution color |
| `threshold_low` | float | 0.33 | Green/yellow boundary (0.0-1.0) |
| `threshold_high` | float | 0.67 | Yellow/red boundary (0.0-1.0) |
| `color_lerp_enabled` | bool | true | Enable smooth color transitions |

---

## POLLUTION-003: Tooltip with Ecosystem Messages

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `message_low` | String | "The pond is healthy. Keep it that way!" | 0-33% tooltip |
| `message_mid` | String | "Pollution is building up... The frogs are worried." | 34-66% tooltip |
| `message_high` | String | "CRITICAL: Ecosystem in danger! Corporate greed is killing the pond!" | 67-100% tooltip |

---

## POLLUTION-004: Mutation Binding (Stubs for EPIC-006)

**Status**: ⚠️ STUB IMPLEMENTATION - Full integration pending EPIC-006

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `pollution_per_mutation` | float | 15.0 | Base pollution per mutation |
| `oil_mutation_weight` | float | 1.5 | Oil spill pollution multiplier |
| `toxic_mutation_weight` | float | 1.2 | Toxic waste pollution multiplier |
| `mercury_mutation_weight` | float | 2.0 | Mercury contamination multiplier |
| `max_pollution` | float | 100.0 | Maximum pollution cap |

---

## POLLUTION-005: Event System (Stubs for EPIC-006)

**Status**: ⚠️ STUB IMPLEMENTATION - Event handling ready for EPIC-006

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `update_animation` | bool | true | Enable pulse animation on pollution change |
| `pulse_duration` | float | 0.3 | Animation duration (seconds) |
| `pulse_scale` | float | 1.1 | Scale multiplier during pulse |

---

## Story Implementation Summary

| Story | Status | Notes |
|-------|--------|-------|
| POLLUTION-001 | ✅ Complete | ProgressBar meter with position/size controls |
| POLLUTION-002 | ✅ Complete | Color lerp system with configurable thresholds |
| POLLUTION-003 | ✅ Complete | Contextual tooltips with custom messages |
| POLLUTION-004 | ⚠️ Stub | Mutation calculations ready, awaits EPIC-006 data |
| POLLUTION-005 | ⚠️ Stub | Event handling ready, awaits EPIC-006 signals |

**Overall Epic Progress**: 5/5 stories implemented (2 with stubs for EPIC-006 integration)
