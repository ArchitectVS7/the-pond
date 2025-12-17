# EPIC-010: Platform Support & Steam Integration - Development Plan

## Overview

**Epic**: EPIC-010 (Platform Support & Steam Integration)
**Release Phase**: MVP
**Priority**: P0 (Required for launch)
**Dependencies**: EPIC-009 (Save System)
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-007, ADR-001

**Description**: Windows, Linux, Steam Deck support, Steam achievements, overlay.

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

### PLATFORM-001: godotsteam-plugin-integration
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] GodotSteam plugin installed
- [ ] Compiles without errors
- [ ] Steam API initialized on launch
- [ ] Graceful fallback if Steam unavailable

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `steam_app_id` | int | 480 | Steam App ID (480 = Spacewar test) |
| `require_steam` | bool | false | Fail if Steam unavailable |

**Potential Blockers**:
- [ ] GodotSteam compatibility issues → Note version in DEVELOPERS_MANUAL.md

---

### PLATFORM-002: steam-authentication-automatic
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Automatic Steam login on launch
- [ ] No manual login required
- [ ] Steam username accessible

---

### PLATFORM-003: steam-achievements-framework
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Achievement definitions created
- [ ] Unlock API integrated
- [ ] Progress tracking for incremental achievements

**Achievement List (MVP)**:
| ID | Name | Description |
|----|------|-------------|
| FIRST_KILL | First Blood | Defeat your first enemy |
| BOSS_LOBBYIST | The Art of the Deal | Defeat The Lobbyist |
| BOSS_CEO | Hostile Takeover | Defeat The CEO |
| TRUE_ENDING | Truth Seeker | Uncover the full conspiracy |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `achievements_enabled` | bool | true | Enable achievement system |
| `achievement_popup_duration` | float | 5.0 | Popup display time |

**Potential Blockers**:
- [ ] Steam dashboard access required → Use test app, note in DEVELOPERS_MANUAL.md

---

### PLATFORM-004: steam-overlay-support
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Steam overlay works in-game
- [ ] Shift+Tab opens overlay
- [ ] Game pauses when overlay active

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `pause_on_overlay` | bool | true | Pause when overlay opens |
| `overlay_notification_pos` | int | 3 | 0-3 corner position |

---

### PLATFORM-005: windows-build-configuration
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Windows export template configured
- [ ] Builds produce .exe
- [ ] Icons and metadata set

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `windows_icon` | String | "res://icon.ico" | Windows icon path |
| `product_name` | String | "Pond Conspiracy" | Product name |
| `file_version` | String | "1.0.0.0" | File version |

---

### PLATFORM-006: linux-build-configuration
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Linux export template configured
- [ ] Builds produce x86_64 binary
- [ ] Steam runtime compatible

**Potential Blockers**:
- [ ] Linux testing environment unavailable → Note in DEVELOPERS_MANUAL.md

---

### PLATFORM-007: steam-deck-validation-800p-55fps
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Runs at 800p (1280x800)
- [ ] Maintains 55fps minimum
- [ ] Battery life acceptable (2+ hours)

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `deck_resolution` | Vector2i | Vector2i(1280, 800) | Steam Deck resolution |
| `deck_target_fps` | int | 55 | Target framerate on Deck |
| `deck_power_profile` | String | "balanced" | Power management |

**Potential Blockers**:
- [ ] Steam Deck hardware unavailable → Note in DEVELOPERS_MANUAL.md

---

### PLATFORM-008: steam-deck-control-mapping
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] All controls mapped to Deck inputs
- [ ] Left stick for movement
- [ ] Right stick for aim

**Control Mapping**:
| Deck Input | Action |
|------------|--------|
| Left Stick | Move (8-dir) |
| Right Stick | Aim direction |
| R2 (Trigger) | Attack |
| A | Confirm |
| B | Cancel/Back |
| Start | Pause |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `stick_deadzone` | float | 0.15 | Stick deadzone |
| `aim_sensitivity` | float | 1.0 | Aim stick sensitivity |

---

### PLATFORM-009: controller-support-xinput
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] XInput controllers work
- [ ] Automatic detection
- [ ] Button prompts match controller

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `vibration_enabled` | bool | true | Controller rumble |
| `vibration_intensity` | float | 1.0 | Rumble strength |

---

### PLATFORM-010: rebindable-controls-ui
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Controls rebindable in settings
- [ ] Both keyboard and controller
- [ ] Reset to defaults option
- [ ] Bindings saved

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `rebind_timeout` | float | 5.0 | Cancel rebind after seconds |
| `show_conflicts` | bool | true | Warn on binding conflicts |

---

## Files to Create

| File | Purpose |
|------|---------|
| `addons/godotsteam/` | Steam plugin (external) |
| `core/scripts/steam_manager.gd` | Steam integration |
| `core/scripts/achievement_manager.gd` | Achievements |
| `core/scripts/input_manager.gd` | Input handling |
| `metagame/scenes/ControlRebindUI.tscn` | Rebind interface |
| `export_presets.cfg` | Export configurations |
| `test/unit/test_input.gd` | Input tests |

---

## Success Metrics

- 10 stories completed
- Steam integration functional
- Windows and Linux builds working
- Controller support complete

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
