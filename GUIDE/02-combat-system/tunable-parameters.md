# Tunable Parameters - Combat System

Every `@export` variable in the combat system, organized by file. Change these in the Godot editor or via code to adjust gameplay feel.

---

## Player Controller

**File**: `combat/scripts/player_controller.gd`

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `move_speed` | float | 200.0 | 100-400 | Movement speed (px/sec) |

**Notes**:
- 200 px/s ≈ 4 tiles/second at 48px tiles
- No momentum/acceleration (instant response)
- Diagonal movement normalized (same speed in all directions)

---

## Tongue Attack

**File**: `combat/scripts/tongue_attack.gd`

### Core Settings

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `base_damage` | int | 1 | 1-10 | Damage per hit |
| `attack_cooldown` | float | 0.3 | 0.1-1.0 | Seconds between attacks |
| `extend_duration` | float | 0.15 | 0.05-0.5 | Extension time |
| `retract_duration` | float | 0.1 | 0.05-0.3 | Retraction time |
| `max_range` | float | 144.0 | 48-288 | Maximum length (px) |

### Elastic Physics

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `extend_overshoot` | float | 0.15 | 0.0-0.5 | Overshoot percentage |
| `elastic_strength` | float | 2.0 | 1.0-5.0 | Bounce intensity |
| `retract_snap` | float | 2.5 | 1.0-4.0 | Snap-back speed |

**Calculations**:
- Total attack time = `extend_duration` + `retract_duration` = 0.25s
- Attacks per second = 1 / (0.25 + `attack_cooldown`) ≈ 1.8
- Effective range = `max_range` × (1 + `extend_overshoot`) = 165.6px

---

## Enemy Spawner

**File**: `combat/scripts/enemy_spawner.gd`

### Spawn Settings

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `base_spawn_interval` | float | 2.0 | 0.5-5.0 | Initial spawn rate |
| `min_spawn_interval` | float | 0.3 | 0.1-1.0 | Fastest spawn rate |
| `spawn_interval_reduction` | float | 0.15 | 0.05-0.3 | Reduction per wave |
| `escalation_interval` | float | 60.0 | 30-120 | Seconds per wave |
| `spawn_radius` | float | 600.0 | 400-1000 | Spawn distance |
| `max_enemies` | int | 100 | 50-500 | Active enemy cap |

### Pool Settings

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `pooling_enabled` | bool | true | - | Toggle pooling |
| `pool_prewarm_count` | int | 50 | 0-100 | Pre-created enemies |
| `pool_max_size` | int | 500 | 100-1000 | Maximum pool |

### Spatial Hash

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `spatial_hash_cell_size` | float | 64.0 | 32-128 | Grid cell size |

---

## Enemy Base

**File**: `combat/scripts/enemy_base.gd`

### Stats

| Parameter | Type | Default (Basic) | Default (Fast) | Effect |
|-----------|------|-----------------|----------------|--------|
| `move_speed` | float | 80.0 | 150.0 | Movement speed |
| `max_hp` | int | 1 | 1 | Health points |
| `score_value` | int | 10 | 15 | Points on death |
| `contact_damage` | int | 1 | 1 | Damage to player |

### Behavior

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `behavior_mode` | enum | CHASE | CHASE/WANDER/ORBIT | AI behavior |
| `wander_speed` | float | 40.0 | 20-100 | Wander speed |
| `wander_interval` | float | 1.5 | 0.5-3.0 | Direction change |
| `orbit_distance` | float | 100.0 | 50-200 | Orbit radius |
| `orbit_speed` | float | 60.0 | 30-120 | Orbit speed |

### Separation

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `separation_enabled` | bool | true | - | Toggle separation |
| `separation_radius` | float | 30.0 | 15-50 | Check distance |
| `separation_strength` | float | 50.0 | 20-100 | Push force |

---

## Screen Shake

**File**: `shared/scripts/screen_shake.gd`

### Main Settings

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `shake_enabled` | bool | true | - | Master toggle |
| `base_intensity` | float | 1.0 | 0.0-2.0 | Global multiplier |
| `max_offset` | float | 16.0 | 8-32 | Max camera offset |
| `trauma_decay_rate` | float | 1.5 | 0.5-3.0 | Decay speed |
| `max_trauma` | float | 1.0 | 0.5-1.5 | Trauma cap |
| `shake_power` | float | 2.0 | 1.0-3.0 | Response curve |

### Presets

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `hit_trauma` | float | 0.2 | 0.1-0.5 | Hit shake trauma |
| `kill_trauma` | float | 0.4 | 0.2-0.8 | Kill shake trauma |
| `hit_duration` | float | 0.15 | 0.1-0.3 | Hit shake duration |
| `kill_duration` | float | 0.25 | 0.15-0.5 | Kill shake duration |

---

## Particle Manager

**File**: `shared/scripts/particle_manager.gd`

### System Settings

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `max_particles` | int | 200 | 100-500 | System cap |

### Hit Particles

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `hit_particle_lifetime` | float | 0.5 | 0.2-1.0 | Duration |
| `hit_particle_amount` | int | 8 | 4-16 | Count |
| `hit_particle_speed` | float | 100.0 | 50-200 | Velocity |
| `hit_color` | Color | (1,1,0.8,1) | - | Color |

### Death Particles

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `death_particle_lifetime` | float | 0.8 | 0.5-1.5 | Duration |
| `death_particle_amount` | int | 16 | 8-32 | Count |
| `death_particle_speed` | float | 150.0 | 100-300 | Velocity |
| `death_color` | Color | (0.2,0.8,0.2,1) | - | Color |

---

## Hit-Stop

**File**: `shared/scripts/hit_stop.gd`

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `hit_stop_enabled` | bool | true | - | Master toggle |
| `default_duration` | float | 0.033 | 0.016-0.1 | Freeze length |
| `freeze_time_scale` | float | 0.0 | 0.0-0.1 | During freeze |
| `kill_duration_multiplier` | float | 1.0 | 0.5-3.0 | Kill scale |

**Frame Reference**:
- 0.016s = 1 frame
- 0.033s = 2 frames (PRD)
- 0.05s = 3 frames
- 0.066s = 4 frames

---

## Audio Manager

**File**: `shared/scripts/audio_manager.gd`

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `sfx_enabled` | bool | true | - | Master toggle |
| `master_volume` | float | 1.0 | 0.0-1.0 | Volume level |
| `pitch_variation` | float | 0.1 | 0.0-0.3 | Random pitch |
| `max_simultaneous_sounds` | int | 16 | 8-32 | Player pool |

---

## Performance Monitor

**File**: `shared/scripts/performance_monitor.gd`

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `target_fps` | float | 60.0 | 30-144 | Target FPS |
| `warning_threshold_fps` | float | 55.0 | 30-60 | Warning level |
| `tracking_enabled` | bool | false | - | Auto-start |
| `smoothing_frames` | int | 30 | 10-60 | FPS average window |

---

## Input Latency Monitor

**File**: `shared/scripts/input_latency_monitor.gd`

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `target_latency_ms` | float | 16.67 | 8-33 | Target latency |
| `warn_on_exceed` | bool | true | - | Console warnings |

---

## Quick Tuning Recipes

### Faster Combat

```gdscript
# Player
move_speed = 300.0

# Tongue
attack_cooldown = 0.15
extend_duration = 0.1

# Enemies
base_spawn_interval = 1.0
min_spawn_interval = 0.2
```

### More Impact

```gdscript
# Screen shake
base_intensity = 1.5
trauma_decay_rate = 1.0

# Hit-stop
default_duration = 0.05

# Particles
death_particle_amount = 24
```

### Easier Mode

```gdscript
# Tongue
max_range = 216.0  # 4.5 tiles
base_damage = 2

# Spawner
base_spawn_interval = 3.0
escalation_interval = 90.0
max_enemies = 50
```

### Harder Mode

```gdscript
# Enemies
move_speed = 120.0  # Basic
move_speed = 200.0  # Fast

# Spawner
base_spawn_interval = 1.0
min_spawn_interval = 0.2
max_enemies = 200
```

---

## Collision Layers

| Layer | Name | Used By |
|-------|------|---------|
| 1 | Player | Player body |
| 2 | Environment | Walls, obstacles |
| 3 | Enemies | Enemy bodies |
| 4 | PlayerAttack | Tongue hitbox |

---

## Input Actions

| Action | Default | Description |
|--------|---------|-------------|
| `move_up` | W | Move up |
| `move_down` | S | Move down |
| `move_left` | A | Move left |
| `move_right` | D | Move right |
| `attack` | LMB | Tongue attack |
| `quit` | Escape | Exit game |

---

[← Back to Game Feel](game-feel.md) | [Back to Overview](overview.md)
