# EPIC-016: Dynamic Music System - Development Plan

## Overview

**Epic**: EPIC-016 (Dynamic Music System)
**Release Phase**: Alpha
**Priority**: P2 (Polish, not critical)
**Dependencies**: EPIC-001 (Combat System Foundation)
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: Music crossfades based on combat intensity.

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

### MUSIC-001: combat-intensity-calculation
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Intensity score 0.0 to 1.0
- [ ] Based on enemy count, player HP, boss presence
- [ ] Smooth transitions (not jerky)
- [ ] Debounced to prevent rapid switching

**Intensity Formula**:
```gdscript
var intensity = 0.0
intensity += clamp(enemy_count / 20.0, 0.0, 0.4)  # Up to 0.4 from enemies
intensity += clamp((1.0 - player_hp_percent) * 0.3, 0.0, 0.3)  # Up to 0.3 from low HP
intensity += 0.3 if boss_active else 0.0  # +0.3 during boss
return clamp(intensity, 0.0, 1.0)
```

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `intensity_enemy_weight` | float | 0.4 | Max intensity from enemies |
| `intensity_hp_weight` | float | 0.3 | Max intensity from low HP |
| `intensity_boss_weight` | float | 0.3 | Intensity added for boss |
| `intensity_smoothing` | float | 2.0 | Seconds to transition |
| `enemy_count_max` | int | 20 | Enemies for max contribution |

---

### MUSIC-002: music-layer-system-ambient-combat-boss
**Size**: L | **Priority**: P2

**Acceptance Criteria**:
- [ ] 3 music layers: Ambient, Combat, Boss
- [ ] Layers can play simultaneously
- [ ] Volume controlled by intensity
- [ ] Seamless looping

**Layer System**:
| Layer | Intensity Range | Description |
|-------|-----------------|-------------|
| Ambient | 0.0 - 0.3 | Calm exploration |
| Combat | 0.3 - 0.7 | Action music |
| Boss | 0.7 - 1.0 | Intense boss theme |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `layer_ambient_max_intensity` | float | 0.3 | Ambient fades above this |
| `layer_combat_min_intensity` | float | 0.2 | Combat fades in at this |
| `layer_combat_max_intensity` | float | 0.8 | Combat fades above this |
| `layer_boss_min_intensity` | float | 0.6 | Boss fades in at this |

---

### MUSIC-003: crossfade-implementation-smooth
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Smooth volume crossfades
- [ ] No audio pops or clicks
- [ ] Configurable fade duration
- [ ] Works with all layers

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `crossfade_duration` | float | 1.5 | Seconds to crossfade |
| `crossfade_curve` | int | 2 | 0=linear, 1=ease-in, 2=ease-out |
| `min_layer_volume` | float | -40.0 | dB when layer is "off" |
| `max_layer_volume` | float | 0.0 | dB when layer is full |

---

### MUSIC-004: boss-music-triggers
**Size**: S | **Priority**: P2

**Acceptance Criteria**:
- [ ] Boss music starts on arena enter
- [ ] Intensity jumps to boss level
- [ ] Each boss can have unique track
- [ ] Returns to normal after boss defeat

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `boss_music_fade_in` | float | 0.5 | Seconds to fade in boss music |
| `boss_music_intensity` | float | 0.9 | Forced intensity during boss |
| `post_boss_cooldown` | float | 5.0 | Seconds before intensity normalizes |

---

### MUSIC-005: victory-defeat-stingers
**Size**: S | **Priority**: P2

**Acceptance Criteria**:
- [ ] Victory stinger on boss defeat
- [ ] Defeat stinger on player death
- [ ] Stingers interrupt music briefly
- [ ] Music resumes/transitions after

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `stinger_duck_volume` | float | -20.0 | dB to duck main music |
| `stinger_duck_duration` | float | 2.0 | Seconds music stays ducked |
| `victory_stinger_length` | float | 3.0 | Victory stinger duration |
| `defeat_stinger_length` | float | 2.5 | Defeat stinger duration |

---

### MUSIC-006: audio-mixing-balance
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Music doesn't overpower SFX
- [ ] SFX priority for important sounds
- [ ] Master volume controls
- [ ] Bus routing correct

**Audio Bus Structure**:
```
Master
├── Music
│   ├── Ambient
│   ├── Combat
│   └── Boss
├── SFX
│   ├── Player
│   ├── Enemies
│   └── UI
└── Voice
```

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `music_bus_volume` | float | -6.0 | Default music bus dB |
| `sfx_bus_volume` | float | 0.0 | Default SFX bus dB |
| `sfx_priority_duck` | float | -3.0 | dB to duck music for priority SFX |

---

## Files to Create

| File | Purpose |
|------|---------|
| `shared/scripts/music_manager.gd` | Music system |
| `shared/scripts/intensity_tracker.gd` | Intensity calculation |
| `assets/audio/music/ambient_loop.ogg` | Ambient layer |
| `assets/audio/music/combat_loop.ogg` | Combat layer |
| `assets/audio/music/boss_loop.ogg` | Boss layer |
| `assets/audio/music/victory_stinger.ogg` | Victory sound |
| `assets/audio/music/defeat_stinger.ogg` | Defeat sound |
| `test/unit/test_music_system.gd` | Tests |

---

## Audio Notes

**File Requirements**:
- Format: OGG Vorbis (Godot preferred)
- Sample Rate: 44100 Hz
- Bit Rate: 128-192 kbps
- Loop Points: Must be seamless

**Potential Blockers**:
- [ ] Music assets unavailable → Use placeholder/silence, note in DEVELOPERS_MANUAL.md

---

## Success Metrics

- 6 stories completed
- Dynamic music system working
- Smooth transitions
- Proper audio mixing

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
