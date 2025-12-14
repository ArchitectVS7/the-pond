# Game Feel

Combat works mechanically - enemies die when you hit them. But does it *feel* satisfying? This chapter covers the feedback systems that make each kill feel impactful: screen shake, particles, hit-stop, and audio.

---

## The Feedback Stack

When the tongue hits an enemy:
1. **Screen shake** - Camera jitters (0.2 trauma)
2. **Particles** - Burst at hit position
3. **Audio** - "Thwap" sound effect

When an enemy dies:
1. **Screen shake** - Stronger shake (0.4 trauma)
2. **Particles** - Death burst (more particles)
3. **Hit-stop** - 2-frame freeze
4. **Audio** - "Glorp" sound effect

Each system is optional and toggleable for accessibility. Together, they create "juice."

---

## Screen Shake (COMBAT-008)

**File**: `shared/scripts/screen_shake.gd`

### Trauma System

Instead of directly setting shake amount, we use trauma that decays over time:

```gdscript
# Add trauma from events
func add_trauma(amount: float) -> void:
    trauma = min(trauma + amount, max_trauma)

# In _process
func _process(delta: float) -> void:
    trauma = max(trauma - trauma_decay_rate * delta, 0.0)

    var shake_amount := pow(trauma, shake_power)
    var offset := Vector2(
        randf_range(-1, 1) * max_offset * shake_amount,
        randf_range(-1, 1) * max_offset * shake_amount
    )
    camera.offset = offset * base_intensity
```

### Why Trauma?

Direct shake: "Shake for 0.3 seconds"
- Abrupt start and stop
- Multiple shakes don't stack naturally

Trauma shake: "Add 0.4 trauma"
- Natural decay (starts strong, fades out)
- Multiple events stack and decay together
- Quadratic response (small hits subtle, big hits intense)

### Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `shake_enabled` | true | - | Master toggle (accessibility) |
| `base_intensity` | 1.0 | 0.0-2.0 | Global multiplier |
| `max_offset` | 16.0 | 8-32 | Maximum pixel offset |
| `trauma_decay_rate` | 1.5 | 0.5-3.0 | Decay speed |
| `max_trauma` | 1.0 | 0.5-1.5 | Trauma cap |
| `shake_power` | 2.0 | 1.0-3.0 | Response curve |

### Presets

| Preset | Trauma | Duration | Use |
|--------|--------|----------|-----|
| `shake_hit()` | 0.2 | 0.15s | Tongue hit |
| `shake_kill()` | 0.4 | 0.25s | Enemy death |

### Tuning Guide

**More intense shake:**
- Increase `base_intensity`
- Increase trauma values
- Decrease `trauma_decay_rate`
- Decrease `shake_power`

**Subtler shake:**
- Decrease `base_intensity`
- Decrease trauma values
- Increase `trauma_decay_rate`
- Increase `shake_power`

### Usage

```gdscript
# Use presets
ScreenShake.shake_hit()
ScreenShake.shake_kill()

# Custom shake
ScreenShake.shake(0.6, 0.3)  # 0.6 trauma, 0.3s

# Check state
if ScreenShake.is_shaking():
    # ...
```

---

## Particles (COMBAT-009)

**File**: `shared/scripts/particle_manager.gd`

### System Overview

CPUParticles2D for compatibility. Pooled for performance. Capped at 200 systems per PRD.

### Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `max_particles` | 200 | 100-500 | System cap |
| `hit_particle_lifetime` | 0.5 | 0.2-1.0 | Hit duration |
| `death_particle_lifetime` | 0.8 | 0.5-1.5 | Death duration |
| `hit_particle_amount` | 8 | 4-16 | Particles per hit |
| `death_particle_amount` | 16 | 8-32 | Particles per death |
| `hit_particle_speed` | 100.0 | 50-200 | Hit velocity |
| `death_particle_speed` | 150.0 | 100-300 | Death velocity |

### Colors

| Parameter | Default | Description |
|-----------|---------|-------------|
| `hit_color` | (1, 1, 0.8, 1) | Warm white |
| `death_color` | (0.2, 0.8, 0.2, 1) | Green slime |

### Usage

```gdscript
# Spawn effects
ParticleManager.spawn_hit_particles(position)
ParticleManager.spawn_death_particles(position)

# Check count
var count := ParticleManager.get_active_count()

# Clear all
ParticleManager.clear_all()
```

### Tuning Guide

**More satisfying hits:**
- Increase `hit_particle_amount`
- Increase `hit_particle_speed`
- Brighter `hit_color`

**Dramatic deaths:**
- Increase `death_particle_amount`
- Longer `death_particle_lifetime`
- Contrasting `death_color`

**Performance:**
- Decrease all amounts
- Shorter lifetimes
- Lower `max_particles` cap

---

## Hit-Stop (COMBAT-010)

**File**: `shared/scripts/hit_stop.gd`

### What is Hit-Stop?

A brief pause (2 frames = ~33ms) when killing enemies. The game freezes, then resumes. Creates a sense of impact.

### How It Works

```gdscript
func trigger_hit_stop(duration: float = default_duration) -> void:
    if not hit_stop_enabled:
        return

    freeze_timer = duration
    Engine.time_scale = freeze_time_scale  # 0.0 = full stop
    emit_signal("freeze_started", duration)

func _process(delta: float) -> void:
    if freeze_timer > 0:
        freeze_timer -= delta  # Uses real delta, not scaled
        if freeze_timer <= 0:
            Engine.time_scale = 1.0
            emit_signal("freeze_ended")
```

### Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `hit_stop_enabled` | true | - | Master toggle |
| `default_duration` | 0.033 | 0.016-0.1 | Freeze length |
| `freeze_time_scale` | 0.0 | 0.0-0.1 | 0.0 = full stop |
| `kill_duration_multiplier` | 1.0 | 0.5-3.0 | Scale for kills |

### Duration Guide

| Value | Frames | Feel |
|-------|--------|------|
| 0.016 | 1 | Subtle |
| 0.033 | 2 | PRD default |
| 0.05 | 3 | Pronounced |
| 0.1 | 6 | Dramatic (boss kills) |

### time_scale Variations

| Value | Effect | Use |
|-------|--------|-----|
| 0.0 | Full stop | Maximum impact |
| 0.05 | Extreme slow-mo | "Matrix" effect |
| 0.1 | Slow-mo | Subtle pause |

### Usage

```gdscript
# Use preset
HitStop.hit_stop_kill()

# Custom duration
HitStop.trigger_hit_stop(0.1)  # 100ms

# Check state
if HitStop.is_frozen():
    # ...

# Stop early
HitStop.stop_hit_stop()
```

### Process Mode

HitStop uses `PROCESS_MODE_ALWAYS` so it can:
- Keep counting down during freeze
- Restore time_scale when done
- Work when `Engine.time_scale = 0`

### Interaction with Screen Shake

Hit-stop and shake work together:
1. Enemy dies
2. Hit-stop freezes (33ms)
3. Screen shake adds offset
4. Player *sees* the shake during freeze
5. Game resumes

The freeze makes shake more noticeable.

---

## Audio (COMBAT-011)

**File**: `shared/scripts/audio_manager.gd`

### System Overview

AudioStreamPlayer pooling. Pitch variation for organic feel. PRD requirement: "wet thwap on hit, glorp on death."

### Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `sfx_enabled` | true | - | Master toggle |
| `master_volume` | 1.0 | 0.0-1.0 | Volume level |
| `pitch_variation` | 0.1 | 0.0-0.3 | Random pitch range |
| `max_simultaneous_sounds` | 16 | 8-32 | Player pool size |

### Pitch Variation

Every sound plays at a slightly different pitch:
```gdscript
player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
```

| Value | Effect |
|-------|--------|
| 0.0 | Same pitch every time (robotic) |
| 0.05 | Subtle variation |
| 0.1 | Natural variation (default) |
| 0.2+ | Noticeable variation |

### Audio Files Required

| Sound | Path | Character |
|-------|------|-----------|
| Hit | `res://assets/audio/sfx/hit_thwap.wav` | Wet, fleshy impact |
| Death | `res://assets/audio/sfx/death_glorp.wav` | Squishy pop |

**Specs:**
- Format: WAV or OGG
- Sample rate: 44100 Hz
- Channels: Mono
- Duration: 0.1-0.5s

### Usage

```gdscript
# Play sounds
AudioManager.play_hit()
AudioManager.play_death()

# Generic
AudioManager.play_sfx("hit")

# Check state
var playing := AudioManager.get_playing_count()

# Stop all
AudioManager.stop_all()
```

### Audio Bus Setup

Create an "SFX" bus in Godot:
```
Master
├── Music
└── SFX ← Sound effects here
```

This lets players adjust music and SFX independently.

---

## Combining Feedback

The full feedback stack for a kill:

```gdscript
func _on_enemy_killed(enemy: Node2D) -> void:
    # Order matters for feel

    # 1. Hit-stop first (freezes the moment)
    HitStop.hit_stop_kill()

    # 2. Screen shake (visible during freeze)
    ScreenShake.shake_kill()

    # 3. Particles (spawn at death position)
    ParticleManager.spawn_death_particles(enemy.global_position)

    # 4. Audio (plays through freeze)
    AudioManager.play_death()
```

### Why This Order?

1. **Hit-stop first**: Creates the "moment" that other effects fill
2. **Screen shake**: Visible immediately during freeze
3. **Particles**: Spawn frozen, then animate when game resumes
4. **Audio**: Plays in real-time (not affected by time_scale)

---

## Accessibility

Every feedback system MUST be toggleable (PRD NFR-002):

| System | Setting | Default |
|--------|---------|---------|
| Screen shake | `shake_enabled` | true |
| Hit-stop | `hit_stop_enabled` | true |
| Particles | (always on, visual only) | - |
| Audio | `sfx_enabled` | true |

These should be exposed in the Settings menu under Accessibility.

---

## Tuning for Feel

### "Impactful" (More Feedback)

```gdscript
ScreenShake.base_intensity = 1.5
ScreenShake.trauma_decay_rate = 1.0
HitStop.default_duration = 0.05
ParticleManager.death_particle_amount = 24
```

### "Subtle" (Less Feedback)

```gdscript
ScreenShake.base_intensity = 0.5
ScreenShake.trauma_decay_rate = 2.5
HitStop.default_duration = 0.016
ParticleManager.death_particle_amount = 8
```

### "Fast-Paced" (Quick Recovery)

```gdscript
ScreenShake.trauma_decay_rate = 3.0
HitStop.default_duration = 0.016
ParticleManager.hit_particle_lifetime = 0.3
```

---

## Setup (Autoloads)

Add to `project.godot`:

```
[autoload]
ScreenShake="*res://shared/scripts/screen_shake.gd"
ParticleManager="*res://shared/scripts/particle_manager.gd"
HitStop="*res://shared/scripts/hit_stop.gd"
AudioManager="*res://shared/scripts/audio_manager.gd"
```

All systems are global singletons accessible from anywhere.

---

## Summary

| System | Purpose | Key Parameter |
|--------|---------|---------------|
| Screen Shake | Camera movement | `base_intensity` |
| Particles | Visual burst | `death_particle_amount` |
| Hit-Stop | Time freeze | `default_duration` |
| Audio | Sound effect | `pitch_variation` |

Game feel is subjective. Start with defaults, then tune based on playtesting. The goal: every kill should feel satisfying.

---

[← Back to Performance](performance.md) | [Next: Tunable Parameters →](tunable-parameters.md)
