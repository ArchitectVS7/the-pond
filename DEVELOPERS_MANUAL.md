# Pond Conspiracy - Developer's Manual

## Overview

This manual documents all tunable settings, configuration options, and developer notes for the Pond Conspiracy project. Settings are exposed via `@export` variables in GDScript for easy editor tuning.

---

## EPIC-003: Conspiracy Board UI

### Blocked Stories (Human-Dependent)

The following stories were skipped during automated development as they require human involvement:

- **BOARD-001**: Figma prototype creation → SKIP (design tool access required)
- **BOARD-002**: Recruit 10 testers → SKIP (human recruitment task)
- **BOARD-003**: Achieve 8/10 satisfaction → SKIP (depends on BOARD-001, BOARD-002)

**Note**: Wireframe implementation in-engine used instead of Figma. User testing to be conducted post-MVP.

---

### BOARD-005: Data Log Card Component

**Files**:
- `conspiracy_board/scenes/DataLogCard.tscn` - Card scene
- `conspiracy_board/scripts/data_log_card.gd` - Card logic
- `conspiracy_board/resources/DataLogResource.gd` - Card data resource

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `card_width` | int | 200 | Card width in pixels |
| `card_height` | int | 150 | Card height in pixels |
| `preview_max_chars` | int | 80 | Characters before truncation in preview |
| `undiscovered_alpha` | float | 0.3 | Opacity when undiscovered (0.0-1.0) |
| `discovered_color` | Color | Paper beige | Background color for discovered cards |
| `undiscovered_color` | Color | Dark gray | Background color for undiscovered cards |
| `title_color` | Color | Near black | Title text color |
| `preview_color` | Color | Dark gray | Preview text color |

**Tuning Notes**:
- `card_width` and `card_height` determine the visual size of cards on the conspiracy board
- Default 200x150 provides good readability while fitting multiple cards on screen
- `preview_max_chars` controls text truncation - increase for more detail, decrease for cleaner look
- `undiscovered_alpha = 0.3` creates clear visual distinction between discovered/undiscovered state
- Discovered cards use warm paper beige (0.92, 0.88, 0.78) for noir aesthetic
- Undiscovered cards are semi-transparent dark gray to indicate locked content

**Card States**:
- **Discovered**: Full opacity, paper texture, shows real title and preview
- **Undiscovered**: 30% opacity, faded appearance, shows "???" and "[LOCKED]"

**DataLogResource Structure**:
```gdscript
id: String              # Unique identifier
title: String           # Display title
summary: String         # Short preview (TL;DR)
full_text: String       # Complete document content
discovered: bool        # Discovery state
category: String        # For grouping/filtering
connections: Array[String]  # IDs of connected documents
```

---

### BOARD-006: Drag-Drop Interaction System

**File**: `conspiracy_board/scripts/data_log_card.gd`

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `drag_threshold` | float | 5.0 | Pixels of movement before drag activates |
| `drag_opacity` | float | 0.8 | Opacity while dragging (0.0-1.0) |

**Tuning Notes**:
- `drag_threshold = 5.0` prevents accidental drags on clicks
  - Lower (2-3px) for more sensitive drag detection
  - Higher (8-10px) for less accidental drags on touchscreens
- `drag_opacity = 0.8` provides clear visual feedback during drag
  - Higher (0.9-1.0) for subtle feedback
  - Lower (0.5-0.7) for dramatic "lifting" effect

**Drag-Drop Behavior**:
1. Mouse down on card stores position and offset
2. Movement beyond `drag_threshold` activates drag mode
3. While dragging:
   - Card z-index set to 100 (brings to top)
   - Opacity changes to `drag_opacity`
   - Position follows mouse cursor with offset
4. On mouse release:
   - Z-index restored to original
   - Opacity restored based on discovered state
   - `drag_ended` signal emitted for snap detection (BOARD-007)

**Signals Emitted**:
- `card_clicked(card)` - Single click without drag
- `drag_started(card)` - Drag initiated (past threshold)
- `drag_ended(card)` - Mouse released after drag
- `discovery_changed(card, is_discovered)` - Discovery state changed

**Click vs Drag Distinction**:
- Movement under threshold + release = Click (opens document viewer)
- Movement over threshold = Drag (position on board)
- This prevents frustrating "I tried to click but it dragged" scenarios

**Integration with BOARD-007**:
- Parent board listens to `drag_ended` signal
- Checks distance to all pin positions
- Snaps to nearest pin if within 50px threshold
- See BOARD-007 for snap detection logic

---

## COMBAT-001: Player Movement

**File**: `combat/scripts/player_controller.gd`

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `move_speed` | float | 200.0 | Movement speed in pixels/second |

**Tuning Notes**:
- 200 px/s feels responsive but controllable
- Increase for faster-paced gameplay
- Consider mutation "Speed Boost" at +50% (300 px/s)

---

## COMBAT-002: Mouse Aim System

**File**: `combat/scripts/player_controller.gd`

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| (no exports) | - | - | Aim is always normalized, no tuning needed |

**Variables Available**:
- `aim_direction: Vector2` - Normalized direction toward mouse
- `aim_angle: float` - Angle in radians (0=right, PI/2=down)

**Tuning Notes**:
- AimPivot rotation is instant (no smoothing)
- Add lerp if aim feels too twitchy

---

## COMBAT-003: Tongue Attack Whip Mechanic

**File**: `combat/scripts/tongue_attack.gd`

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `base_damage` | int | 1 | Damage dealt per hit |
| `attack_cooldown` | float | 0.3 | Seconds between attacks |
| `extend_duration` | float | 0.15 | Seconds to extend tongue |
| `retract_duration` | float | 0.1 | Seconds to retract tongue |
| `max_range` | float | 144.0 | Maximum tongue length (pixels) |

**Tuning Notes**:
- `max_range = 144` = 3 tiles at 48px/tile (PRD requirement)
- Total attack duration = extend + retract = 0.25s
- Attacks per second = 1 / (0.25 + 0.3) = ~1.8 attacks/sec
- Mutation "Faster Tongue" could reduce cooldown by 50% (0.15s)
- Mutation "Longer Tongue" could increase range by 50% (216px = 4.5 tiles)

**State Machine**:
```
IDLE → (attack input) → EXTENDING → (timer) → RETRACTING → (timer) → IDLE
                                                                ↓
                                                        cooldown starts
```

---

## COMBAT-004: Tongue Elastic Physics

**File**: `combat/scripts/tongue_attack.gd`

| Setting | Type | Default | Range | Description |
|---------|------|---------|-------|-------------|
| `extend_overshoot` | float | 0.15 | 0.0-0.5 | How much tongue overshoots max_range (15% = 21.6px extra) |
| `elastic_strength` | float | 2.0 | 1.0-5.0 | Bounce intensity at max extension |
| `retract_snap` | float | 2.5 | 1.0-4.0 | Snap-back speed (higher = faster initial retract) |

**What These Settings Do**:

### `extend_overshoot`
Controls how far the tongue extends past `max_range` before settling back.
- **0.0**: No overshoot - linear extension like COMBAT-003
- **0.1**: Subtle whip effect - extends 10% past max (158.4px), settles at 144px
- **0.15** (default): Noticeable whip - extends 15% past (165.6px)
- **0.3+**: Exaggerated cartoon whip - may feel too loose

**Why Change It**: Increase for more dramatic "whip crack" feel. Decrease for tighter, more precise attacks. Set to 0 if mutations need exact range control.

### `elastic_strength`
Controls the "springiness" of the overshoot bounce.
- **1.0**: Minimal bounce - almost linear
- **2.0** (default): Natural elastic feel
- **3.0-5.0**: Exaggerated spring - tongue visibly wobbles

**Why Change It**: Increase for cartoony feel. Decrease for snappier, more responsive attacks. Works best when combined with `extend_overshoot > 0`.

### `retract_snap`
Controls how quickly the tongue snaps back vs. eases in.
- **1.0**: Linear retract - constant speed
- **2.0**: Moderate snap - starts fast, slows at end
- **2.5** (default): Good snap feel - 80% retracted in first half of duration
- **4.0**: Extreme snap - almost instant start, very slow finish

**Why Change It**: Increase for punchier feel (tongue "snaps" back). Decrease if it feels too abrupt. Higher values pair well with screen shake (COMBAT-008).

**Effective Range Calculation**:
```
effective_range = max_range * (1 + extend_overshoot)
# Default: 144 * 1.15 = 165.6 pixels (3.45 tiles)
```

**Mutation Interactions**:
- "Longer Tongue" (+50% range): Affects `max_range`, overshoot scales proportionally
- "Elastic Tongue": Could increase `extend_overshoot` to 0.3
- "Snappy Tongue": Could increase `retract_snap` to 4.0

---

## COMBAT-005: Enemy Spawn Escalation System

**Files**:
- `combat/scripts/enemy_spawner.gd` - Spawner logic
- `combat/scripts/enemy_base.gd` - Base enemy class
- `combat/scenes/EnemyBasic.tscn` - Slow, 1 HP enemy
- `combat/scenes/EnemyFast.tscn` - Fast, 1 HP enemy

### Spawner Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `base_spawn_interval` | float | 2.0 | Seconds between spawns at wave 1 |
| `min_spawn_interval` | float | 0.3 | Minimum spawn interval (prevents overwhelming) |
| `spawn_interval_reduction` | float | 0.15 | Interval reduction per wave |
| `escalation_interval` | float | 60.0 | Seconds between difficulty escalations (PRD: 60s) |
| `spawn_radius` | float | 600.0 | Distance from center to spawn enemies |
| `max_enemies` | int | 100 | Maximum enemies alive at once |

**How Escalation Works**:
```
Wave 1: spawn_interval = 2.0s, basic enemies only
Wave 2: spawn_interval = 1.85s, 30% chance fast enemy
Wave 3: spawn_interval = 1.70s, 30% chance fast enemy
...
Wave N: spawn_interval = max(0.3, 2.0 - 0.15*(N-1))
```

**Why Change These**:

### `base_spawn_interval`
Controls initial difficulty. Lower = harder start.
- **1.0s**: Intense from start (hard mode)
- **2.0s** (default): Gradual ramp-up
- **3.0s+**: Very slow start (easy mode)

### `escalation_interval`
How long before difficulty increases. PRD specifies 60 seconds.
- **30s**: Fast escalation (shorter runs)
- **60s** (default): PRD standard
- **90s+**: Slower escalation (longer runs)

### `spawn_radius`
Where enemies spawn relative to arena center.
- **400px**: Enemies spawn closer (more pressure)
- **600px** (default): Standard distance
- **800px+**: More reaction time

### Enemy Settings

| Setting | Basic | Fast | Description |
|---------|-------|------|-------------|
| `move_speed` | 80 | 150 | Pixels per second |
| `max_hp` | 1 | 1 | Health points |
| `score_value` | 10 | 15 | Points on kill |
| `contact_damage` | 1 | 1 | Damage to player |

**Enemy Types**:
- **Polluted Tadpole** (Basic): Slow, steady approach. First enemy type.
- **Toxic Minnow** (Fast): Quick, smaller. Appears wave 2+.

---

## COMBAT-006: Enemy AI Basic Behaviors

**File**: `combat/scripts/enemy_base.gd`

### Behavior Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `CHASE` | Move directly toward player | Default, aggressive enemies |
| `WANDER` | Random movement, direction changes periodically | Patrol behavior, passive enemies |
| `ORBIT` | Circle around player at fixed distance | Ranged enemies, tactical positioning |

### Behavior Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `behavior_mode` | enum | CHASE | Current behavior (CHASE, WANDER, ORBIT) |
| `wander_speed` | float | 40.0 | Speed when wandering (slower than chase) |
| `wander_interval` | float | 1.5 | Seconds between wander direction changes |
| `orbit_distance` | float | 100.0 | Distance to maintain when orbiting |
| `orbit_speed` | float | 60.0 | Speed when orbiting |
| `separation_enabled` | bool | true | Whether enemies avoid clumping |
| `separation_radius` | float | 30.0 | Distance to check for other enemies |
| `separation_strength` | float | 50.0 | Force strength for pushing apart |

### How Behaviors Work

#### CHASE (Default)
```
velocity = direction_to_player * move_speed
```
Simple, direct approach. Best for basic melee enemies.

#### WANDER
```
Every wander_interval seconds:
  pick_random_direction()
velocity = random_direction * wander_speed
```
Useful for patrol enemies or passive creatures that only chase when provoked.

#### ORBIT
```
angle += angular_speed * delta
ideal_pos = player_pos + direction_from_angle * orbit_distance
velocity = tangent_direction * orbit_speed + correction_to_ideal
```
Creates circling behavior. Good for ranged enemies that shoot while moving.

### Separation System

Prevents enemies from stacking on top of each other:
```
for each nearby_enemy within separation_radius:
  push_away_force += (separation_radius - distance) / separation_radius
velocity += push_away_force * separation_strength
```

**Why Change These**:

### `separation_radius`
How close enemies can get before pushing apart.
- **15px**: Tight swarms (Vampire Survivors style)
- **30px** (default): Readable groups
- **50px+**: Very spread out

### `wander_interval`
How often wandering enemies change direction.
- **0.5s**: Erratic, unpredictable movement
- **1.5s** (default): Natural-feeling patrol
- **3.0s+**: Long, straight paths

### `orbit_distance`
How far orbiters stay from player.
- **60px**: Close orbit (threatening)
- **100px** (default): Comfortable distance
- **150px+**: Far orbit (ranged attackers)

**Enemy Type Suggestions**:
- **Basic Melee**: CHASE, separation_enabled=true
- **Patrol Guard**: WANDER, switches to CHASE when player detected
- **Ranged Shooter**: ORBIT, fires projectiles while circling
- **Swarm Bug**: CHASE, separation_radius=15 (tight pack)

---

## COMBAT-007: Spatial Hash Collision Optimization

**Files**:
- `combat/scripts/spatial_hash.gd` - SpatialHash class
- `combat/scripts/enemy_spawner.gd` - Manages spatial hash
- `combat/scripts/enemy_base.gd` - Uses spatial hash for separation

### What is Spatial Hashing?

Spatial hashing divides the game world into a grid of cells. Entities are placed into cells based on their position. When checking for nearby entities (like enemy separation), we only check the current cell and adjacent cells instead of ALL entities.

**Performance Impact**:
- **Without spatial hash**: O(n²) - 500 enemies = 250,000 checks per frame
- **With spatial hash**: O(n*k) - 500 enemies with k=5 per cell = 2,500 checks per frame
- **100x performance improvement** for large enemy counts

### Spawner Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `spatial_hash_cell_size` | float | 64.0 | Size of each cell in pixels |

### SpatialHash Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `cell_size` | float | 64.0 | Grid cell size (set in constructor) |
| `MIN_CELL_SIZE` | const | 16.0 | Minimum allowed cell size |
| `ADJACENT_RANGE` | const | 1 | Adjacent cells to check (1 = 3x3 grid) |

### Tuning `spatial_hash_cell_size`

**Optimal Value**: Slightly larger than the largest `separation_radius` you use.

| Cell Size | Effect | Use Case |
|-----------|--------|----------|
| 32px | More cells, fewer entities per cell | Dense swarm games |
| 64px (default) | Balanced | Most games |
| 128px | Fewer cells, more entities per cell | Spread-out enemies |

**Formula**: `cell_size ≈ separation_radius * 1.5 to 2.0`

**Why Change It**:
- **Too small** (< separation_radius): Entities span multiple cells, queries check many cells
- **Too large** (>> separation_radius): Many entities per cell, queries return too many results
- **Just right**: Each query returns only 5-20 nearby entities

### How It Works

```
Grid (64px cells):
+-----+-----+-----+
| 2,1 | 3,1 | 4,1 |
+-----+-----+-----+
| 2,2 | 3,2 | 4,2 |  ← Enemy at (200, 150) is in cell (3, 2)
+-----+-----+-----+
| 2,3 | 3,3 | 4,3 |
+-----+-----+-----+

Query for nearby enemies at (200, 150):
- Checks cells: (2,1), (3,1), (4,1), (2,2), (3,2), (4,2), (2,3), (3,3), (4,3)
- Returns only enemies in those 9 cells (not all 500 enemies)
```

### API Reference

```gdscript
# Create spatial hash
var spatial_hash := SpatialHash.new(64.0)

# Insert entity (must have global_position)
spatial_hash.insert(enemy)

# Query nearby entities (3x3 cell grid)
var nearby := spatial_hash.query_nearby(position)

# Query with exact radius check
var in_radius := spatial_hash.query_radius(position, 50.0)

# Update position (call after entity moves)
spatial_hash.update(enemy)

# Remove entity
spatial_hash.remove(enemy)

# Get statistics
var stats := spatial_hash.get_stats()
# Returns: { cell_size, total_entities, cell_count, max_per_cell, avg_per_cell }
```

### Debugging Performance

Enable spatial hash statistics in console:
```gdscript
# In EnemySpawner or debug script
func _physics_process(delta: float) -> void:
    if Engine.get_physics_frames() % 60 == 0:  # Every second
        var stats := get_spatial_hash_stats()
        print("Spatial Hash: %d entities in %d cells (avg: %.1f/cell)" % [
            stats.total_entities, stats.cell_count, stats.avg_per_cell
        ])
```

**Healthy stats**:
- `avg_per_cell`: 5-20 entities
- `max_per_cell`: < 50 entities
- If `avg_per_cell` > 30: Increase cell_size
- If `cell_count` > 1000: Increase cell_size

---

## COMBAT-008: Screen Shake Hit Feedback

**File**: `shared/scripts/screen_shake.gd`

### Overview

Screen shake provides visceral feedback for combat actions. Uses a trauma-based system where actions add "trauma" that decays over time. Must be toggleable for accessibility (PRD NFR-002).

### Main Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `shake_enabled` | bool | true | Master toggle for accessibility |
| `base_intensity` | float | 1.0 | Global intensity multiplier |
| `max_offset` | float | 16.0 | Maximum camera offset in pixels |
| `trauma_decay_rate` | float | 1.5 | How fast trauma decays (per second) |
| `max_trauma` | float | 1.0 | Maximum trauma accumulation |
| `shake_power` | float | 2.0 | Exponential curve (2.0 = quadratic) |

### Preset Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `hit_trauma` | float | 0.2 | Trauma added on tongue hit |
| `kill_trauma` | float | 0.4 | Trauma added on enemy kill |
| `hit_duration` | float | 0.15 | Duration for hit shake |
| `kill_duration` | float | 0.25 | Duration for kill shake |

### How Trauma Works

```
trauma = 0.5, shake_power = 2.0
shake_amount = trauma^shake_power = 0.5^2 = 0.25
offset = random(-1, 1) * max_offset * shake_amount * base_intensity
       = random(-1, 1) * 16 * 0.25 * 1.0
       = random(-4, 4) pixels
```

**Why shake_power matters**:
- **1.0**: Linear response (feels flat)
- **2.0** (default): Quadratic (small hits = subtle, big hits = intense)
- **3.0**: Cubic (even more contrast between small and large)

### Tuning Guide

**For more intense shake**:
- Increase `base_intensity` (global)
- Increase `hit_trauma` or `kill_trauma` (per action)
- Decrease `trauma_decay_rate` (lasts longer)
- Decrease `shake_power` (more responsive)

**For subtler shake**:
- Decrease `base_intensity`
- Decrease `hit_trauma` or `kill_trauma`
- Increase `trauma_decay_rate`
- Increase `shake_power`

**For snappier shake**:
- Increase `trauma_decay_rate` (decays faster)
- Decrease durations

### Usage from Code

```gdscript
# Get ScreenShake autoload
var screen_shake := get_node("/root/ScreenShake")

# Use presets
screen_shake.shake_hit()   # Tongue hit an enemy
screen_shake.shake_kill()  # Enemy died

# Custom shake
screen_shake.shake(0.6, 0.3)  # 0.6 trauma, 0.3 seconds

# Check state
if screen_shake.is_shaking():
    print("Currently shaking")

# Stop immediately
screen_shake.stop_shake()
```

### Setup (Autoload)

Add to `project.godot` autoloads:
```
[autoload]
ScreenShake="*res://shared/scripts/screen_shake.gd"
```

### Accessibility Notes

Screen shake MUST be toggleable per PRD NFR-002. The `shake_enabled` setting:
- Defaults to `true`
- Should be exposed in Settings menu (ACCESS-005)
- When `false`, no shake occurs (camera offset stays at zero)

---

## COMBAT-009: Particle System Hits and Deaths

**File**: `shared/scripts/particle_manager.gd`

### Overview

Particle effects provide visual feedback for combat actions. Uses CPUParticles2D for compatibility and predictable performance. Cap at 200 particles per PRD requirement.

### Main Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `max_particles` | int | 200 | Maximum particle systems (PRD limit) |
| `hit_particle_lifetime` | float | 0.5 | How long hit particles last |
| `death_particle_lifetime` | float | 0.8 | How long death particles last |
| `hit_particle_amount` | int | 8 | Particles per hit burst |
| `death_particle_amount` | int | 16 | Particles per death burst |
| `hit_particle_speed` | float | 100.0 | Hit particle velocity |
| `death_particle_speed` | float | 150.0 | Death particle velocity |

### Color Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `hit_color` | Color | (1, 1, 0.8, 1) | Warm white for hits |
| `death_color` | Color | (0.2, 0.8, 0.2, 1) | Green slime for deaths |

### Tuning Guide

**For more satisfying hits**:
- Increase `hit_particle_amount`
- Increase `hit_particle_speed`
- Adjust `hit_color` for visibility

**For dramatic deaths**:
- Increase `death_particle_amount`
- Increase `death_particle_lifetime`
- Use contrasting `death_color`

**For performance**:
- Decrease `max_particles` (PRD allows up to 200)
- Decrease particle amounts
- Decrease lifetimes (cleanup faster)

### Usage from Code

```gdscript
# Get ParticleManager autoload
var particles := get_node("/root/ParticleManager")

# Spawn effects
particles.spawn_hit_particles(enemy.global_position)
particles.spawn_death_particles(enemy.global_position)

# Check state
var count := particles.get_active_count()
print("Active particles: %d" % count)

# Clear all
particles.clear_all()
```

### Setup (Autoload)

Add to `project.godot` autoloads:
```
[autoload]
ParticleManager="*res://shared/scripts/particle_manager.gd"
```

### Pooling

ParticleManager uses object pooling internally:
- Inactive particle systems are reused
- Old particles removed when at max limit (FIFO)
- Pre-warms pool with 10 systems on startup

---

## COMBAT-010: Hit-Stop 2-Frame Pause

**File**: `shared/scripts/hit_stop.gd`

### Overview

Hit-stop (also called "freeze frames") creates a brief pause when enemies die, adding impact and weight to kills. At 60fps, 2 frames = ~33ms pause. Uses Engine.time_scale for the freeze effect.

### Main Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `hit_stop_enabled` | bool | true | Master toggle for accessibility |
| `default_duration` | float | 0.033 | Freeze duration (2 frames at 60fps) |
| `freeze_time_scale` | float | 0.0 | Time scale during freeze (0.0 = full stop) |
| `kill_duration_multiplier` | float | 1.0 | Multiplier for kill freeze duration |

### Understanding the Settings

#### `default_duration`
How long the game pauses in seconds.
- **0.016** (1 frame): Subtle impact, barely noticeable
- **0.033** (default, 2 frames): PRD requirement, good balance
- **0.05** (3 frames): More pronounced, dramatic
- **0.1+**: Very long, may feel sluggish

**Why Change It**: Increase for more dramatic kills. Decrease if game feels "stuttery". Set to 0 to effectively disable (use `hit_stop_enabled` instead for proper disable).

#### `freeze_time_scale`
What Engine.time_scale becomes during the freeze.
- **0.0** (default): Complete stop - game freezes entirely
- **0.01-0.05**: "Slow-mo" effect - game crawls but doesn't stop
- **0.1-0.3**: Noticeable slowdown without full freeze
- **0.5+**: Too fast to notice, not recommended

**Why Change It**: Use slow-mo (0.05-0.1) for a "matrix" feel. Use full stop (0.0) for maximum impact. Higher values are more subtle.

#### `kill_duration_multiplier`
Scales the duration specifically for kill effects.
- **0.5**: Kills pause half as long (0.016s = 1 frame)
- **1.0** (default): Standard duration
- **2.0**: Kills pause twice as long (0.066s = 4 frames)

**Why Change It**: Use different values for different effects. For example:
- Regular kills: 1.0x (2 frames)
- Boss kills: 3.0x (6 frames) for dramatic impact
- Multi-kills: Could stack or cap for satisfying combos

### Tuning Guide

**For more impactful kills**:
- Increase `default_duration` to 0.05+ (3 frames)
- Decrease `freeze_time_scale` to 0.0 (full stop)
- Increase `kill_duration_multiplier`

**For subtler effect**:
- Decrease `default_duration` to 0.016 (1 frame)
- Increase `freeze_time_scale` to 0.05 (slow-mo)
- Decrease `kill_duration_multiplier`

**For fast-paced action**:
- Keep duration short (0.016-0.033)
- Consider slow-mo instead of full stop
- Multiple rapid kills feel better with stacking disabled

### Usage from Code

```gdscript
# Get HitStop autoload
var hit_stop := get_node("/root/HitStop")

# Use preset (2 frames)
hit_stop.hit_stop_kill()

# Custom duration
hit_stop.trigger_hit_stop(0.1)  # 100ms freeze

# Check state
if hit_stop.is_frozen():
    print("Game is frozen")

# Get remaining time
var remaining := hit_stop.get_remaining_time()

# Force stop
hit_stop.stop_hit_stop()
```

### Signals

```gdscript
# Connect to freeze events
hit_stop.freeze_started.connect(_on_freeze_started)
hit_stop.freeze_ended.connect(_on_freeze_ended)

func _on_freeze_started(duration: float) -> void:
    # Pause animations, audio, etc.
    pass

func _on_freeze_ended() -> void:
    # Resume animations
    pass
```

### Setup (Autoload)

Add to `project.godot` autoloads:
```
[autoload]
HitStop="*res://shared/scripts/hit_stop.gd"
```

### Accessibility Notes

Hit-stop MUST be toggleable per PRD NFR-002. The `hit_stop_enabled` setting:
- Defaults to `true`
- Should be exposed in Settings menu (ACCESS-005)
- When `false`, trigger_hit_stop() returns immediately without effect
- No time_scale changes occur when disabled

### Interaction with Screen Shake

Hit-stop and screen shake work together for maximum impact:
1. Enemy dies
2. Hit-stop freezes game (0.033s)
3. Screen shake adds camera movement
4. Particles spawn at death position

The freeze makes the shake more noticeable since the player can "see" the shake before action resumes.

### Process Mode

HitStop uses `PROCESS_MODE_ALWAYS` so it can:
- Continue counting down the freeze timer
- Restore time_scale when freeze ends
- Work correctly even when Engine.time_scale = 0.0

---

## COMBAT-011: Audio Feedback Wet Thwap Glorp

**File**: `shared/scripts/audio_manager.gd`

### Overview

Sound effects provide auditory feedback for combat actions. Uses AudioStreamPlayer pooling for performance. PRD requirement: "wet thwap on hit, glorp on enemy death".

### Main Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `sfx_enabled` | bool | true | Master toggle for accessibility |
| `master_volume` | float | 1.0 | Volume level (0.0 to 1.0) |
| `pitch_variation` | float | 0.1 | Random pitch range (+/- 10%) |
| `max_simultaneous_sounds` | int | 16 | Audio player pool size |

### Sound Resources

| Setting | Type | Default Path | Description |
|---------|------|--------------|-------------|
| `hit_sound` | AudioStream | null | Direct resource for hit sound |
| `death_sound` | AudioStream | null | Direct resource for death sound |
| `hit_sound_path` | String | `res://assets/audio/sfx/hit_thwap.wav` | Fallback path |
| `death_sound_path` | String | `res://assets/audio/sfx/death_glorp.wav` | Fallback path |

### Understanding the Settings

#### `pitch_variation`
Adds random pitch variation to prevent repetitive sound.
- **0.0**: No variation - same pitch every time (robotic)
- **0.05**: Subtle variation - barely noticeable
- **0.1** (default): Natural variation - sounds organic
- **0.2+**: Noticeable variation - may feel inconsistent

**Why Change It**: Increase for more varied sounds (especially with many rapid kills). Decrease for more consistent audio.

#### `max_simultaneous_sounds`
Size of AudioStreamPlayer pool.
- **8**: Minimum - may cut off sounds in intense combat
- **16** (default): Good balance for most scenarios
- **32+**: High - for very rapid sound events

**Why Change It**: Increase if sounds are being cut off during intense combat. Decrease to save memory.

### Audio Asset Requirements

Create audio files at these paths:
```
res://assets/audio/sfx/hit_thwap.wav    # Tongue hit sound
res://assets/audio/sfx/death_glorp.wav  # Enemy death sound
```

**Recommended Audio Specs**:
- **Format**: WAV (uncompressed) or OGG (compressed)
- **Sample Rate**: 44100 Hz
- **Channels**: Mono (stereo unnecessary for SFX)
- **Bit Depth**: 16-bit
- **Duration**: 0.1s - 0.5s (short, punchy)

**Sound Character**:
- **Hit (thwap)**: Wet, fleshy impact. Think frog tongue slapping.
- **Death (glorp)**: Squishy, bubbly pop. Think toxic slime bursting.

### Usage from Code

```gdscript
# Get AudioManager autoload
var audio := get_node("/root/AudioManager")

# Play combat sounds
audio.play_hit()    # Wet thwap
audio.play_death()  # Glorp

# Generic method
audio.play_sfx("hit")
audio.play_sfx("death")

# Check state
var playing := audio.get_playing_count()

# Stop all sounds
audio.stop_all()
```

### Signals

```gdscript
# Connect to sound events
audio.sound_played.connect(_on_sound_played)

func _on_sound_played(sound_type: String) -> void:
    print("Played: %s" % sound_type)
```

### Setup (Autoload)

Add to `project.godot` autoloads:
```
[autoload]
AudioManager="*res://shared/scripts/audio_manager.gd"
```

### Audio Bus Configuration

For proper mixing, create an "SFX" bus in Godot:
1. Open Audio tab (bottom panel)
2. Add bus named "SFX"
3. Adjust volume relative to Master and Music

```
Master
├── Music (for background music)
└── SFX (for sound effects)
```

### Pooling System

AudioManager uses a pool of AudioStreamPlayer nodes:
- Pre-creates `max_simultaneous_sounds` players on startup
- Uses round-robin selection for next player
- Reuses players that finished or replays if still playing
- No runtime allocations during gameplay

### Accessibility Notes

SFX MUST be toggleable per PRD NFR-002. The `sfx_enabled` setting:
- Defaults to `true`
- Should be exposed in Settings menu
- When `false`, no sounds play
- Volume slider should also be available

### Missing Audio Handling

AudioManager gracefully handles missing audio files:
- No errors thrown if file not found
- Signal still emitted (for subtitles/captions)
- Game continues to function normally

This allows development without audio assets while maintaining the feedback system hooks.

---

## COMBAT-012: Performance 60fps GTX 1060 Validation

**File**: `shared/scripts/performance_monitor.gd`

### Overview

Performance monitoring and validation infrastructure to ensure 60fps minimum on target hardware (GTX 1060 @ 1080p). This story provides profiling tools and documents validation procedures.

### PRD Requirements

| Metric | Target | Context |
|--------|--------|---------|
| Minimum FPS | 60 | GTX 1060 / RX 580 @ 1080p |
| Average FPS | 90+ | Streaming headroom |
| Enemies on screen | 500+ | With spatial hash optimization |
| Steam Deck FPS | 55 | @ 800p medium settings |

### PerformanceMonitor Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `target_fps` | float | 60.0 | Target FPS for validation |
| `warning_threshold_fps` | float | 55.0 | Emit warning below this |
| `tracking_enabled` | bool | false | Auto-start tracking |
| `smoothing_frames` | int | 30 | Frames for FPS averaging |

### Usage from Code

```gdscript
# Get PerformanceMonitor (if autoload)
var perf := get_node("/root/PerformanceMonitor")

# Or create instance for specific profiling
var perf := PerformanceMonitor.new()
add_child(perf)

# Start tracking
perf.start_tracking()

# ... run game for a while ...

# Get statistics
var stats := perf.get_statistics()
print("Min FPS: ", stats.min_fps)
print("Avg FPS: ", stats.avg_fps)
print("Meeting target: ", stats.meeting_target)

# Generate full report
perf.print_report()

# Stop tracking
perf.stop_tracking()
```

### Statistics Available

```gdscript
var stats := perf.get_statistics()
# Returns:
# {
#   fps: 62.0,              # Current FPS
#   fps_smoothed: 61.5,     # Averaged FPS
#   frame_time_ms: 16.1,    # Current frame time
#   min_fps: 58.0,          # Minimum recorded
#   max_fps: 120.0,         # Maximum recorded
#   avg_fps: 75.0,          # Average over session
#   frame_count: 3600,      # Frames tracked
#   duration_seconds: 60.0, # Tracking duration
#   memory_mb: 128.5,       # Memory usage
#   object_count: 1500,     # Godot objects
#   target_fps: 60.0,       # Target
#   meeting_target: false   # Pass/fail
# }
```

### Manual Hardware Validation

Since automated tests cannot verify real hardware performance, manual testing is required:

#### Test Environment
- **GPU**: GTX 1060 6GB or RX 580 8GB
- **Resolution**: 1920x1080 (1080p)
- **Settings**: Maximum (no quality reduction)
- **Streaming**: Test with OBS running (Game Capture)

#### Test Scenarios

**Scenario 1: Enemy Stress Test**
1. Spawn 500 enemies
2. Enable PerformanceMonitor tracking
3. Play for 60 seconds
4. Check `min_fps >= 60`

**Scenario 2: Combat Intensity**
1. Start with 100 enemies
2. Attack continuously (all feedback systems active)
3. Verify no frame drops during:
   - Screen shake
   - Particle effects
   - Hit-stop freeze
   - Audio playback

**Scenario 3: Streaming Test**
1. Launch OBS (Game Capture mode)
2. Record at 1080p60
3. Play game at max intensity
4. Verify game maintains 60fps
5. Verify recording is smooth

#### Validation Checklist

```markdown
## Hardware Validation Checklist

### Environment
- [ ] GTX 1060 6GB or equivalent
- [ ] 1080p resolution
- [ ] Maximum quality settings
- [ ] V-Sync OFF (for true FPS measurement)

### Tests
- [ ] 500 enemies: min_fps >= 60
- [ ] Combat stress: no drops below 60
- [ ] Streaming (OBS): min_fps >= 60
- [ ] 10-minute session: avg_fps >= 90

### Results
- Min FPS: ___
- Avg FPS: ___
- Max enemies tested: ___
- Issues found: ___
```

### Optimization Techniques Used

The following optimizations ensure 60fps:

| System | Technique | Story |
|--------|-----------|-------|
| Enemy separation | Spatial hash O(n*k) | COMBAT-007 |
| Particles | Object pooling, 200 cap | COMBAT-009 |
| Audio | AudioStreamPlayer pool | COMBAT-011 |
| Hit-stop | Engine.time_scale (zero overhead) | COMBAT-010 |
| Screen shake | Trauma decay (simple math) | COMBAT-008 |

### Debugging Performance Issues

**If FPS drops below 60:**

1. **Check spatial hash stats**
```gdscript
var stats := spawner.get_spatial_hash_stats()
if stats.avg_per_cell > 30:
    print("Increase spatial_hash_cell_size")
```

2. **Check particle count**
```gdscript
var count := particle_manager.get_active_count()
if count >= 200:
    print("At particle limit - reduce particle amounts")
```

3. **Check audio pool**
```gdscript
var playing := audio_manager.get_playing_count()
if playing >= 16:
    print("Audio pool saturated - increase max_simultaneous_sounds")
```

4. **Use Godot profiler**
   - Run game with `--debug`
   - Open Debugger → Profiler tab
   - Identify functions > 1ms per frame

### Setup (Autoload - Optional)

For global access, add to `project.godot`:
```
[autoload]
PerformanceMonitor="*res://shared/scripts/performance_monitor.gd"
```

---

## COMBAT-013: Input Lag 16ms Validation

**File**: `shared/scripts/input_latency_monitor.gd`

### Overview

Input latency monitoring ensures responsive controls. PRD requires <16ms input lag (1 frame at 60fps). This story provides measurement tools and documents best practices.

### PRD Requirements

| Metric | Target | Calculation |
|--------|--------|-------------|
| Input Lag | <16ms | 1000ms / 60fps = 16.67ms |
| Frame Budget | 16.67ms | Time from input to response |

### InputLatencyMonitor Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `target_latency_ms` | float | 16.67 | Target latency (1 frame) |
| `warn_on_exceed` | bool | true | Push warning on exceed |

### Usage from Code

```gdscript
# Get InputLatencyMonitor (if autoload)
var latency := get_node("/root/InputLatencyMonitor")

# Record input event (in _physics_process or _input)
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        latency.record_input("attack")
        _start_attack()

# Record response (when action takes effect)
func _start_attack() -> void:
    latency.record_response("attack")
    # ... attack logic ...
```

### Measuring Latency

```gdscript
# Get last measurement
var last := latency.get_last_latency_ms("attack")

# Get statistics
var avg := latency.get_average_latency_ms("attack")
var max := latency.get_max_latency_ms("attack")
var min := latency.get_min_latency_ms("attack")

# Check if acceptable
if latency.is_action_acceptable("attack"):
    print("Attack latency OK")

# Generate full report
latency.print_report()
```

### Best Practices for Low Latency

#### 1. Use _physics_process for Input

```gdscript
# GOOD: Input handled in _physics_process
# Consistent 60fps timing, synchronized with physics
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        perform_attack()

# BAD: Input handled in _process
# Variable frame rate, unpredictable timing
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        perform_attack()
```

**Why**: `_physics_process` runs at a fixed 60fps, giving predictable 16.67ms frame timing. `_process` runs every frame which can vary.

#### 2. Avoid Input Accumulation for Critical Actions

```gdscript
# For lower latency (but more input checks):
Input.use_accumulated_input = false

# For default behavior (one check per frame):
Input.use_accumulated_input = true  # default
```

**Trade-off**: Disabling accumulation can reduce latency but increases input processing overhead.

#### 3. Respond Immediately in Same Frame

```gdscript
# GOOD: Immediate response
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        # Action happens same frame as input
        current_state = State.EXTENDING
        velocity = direction * speed

# BAD: Deferred response
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        # Action deferred to next frame
        call_deferred("_start_attack")
```

#### 4. Keep Input Processing Light

```gdscript
# GOOD: Light processing in input handler
func _physics_process(delta: float) -> void:
    handle_movement()  # Simple velocity calculation
    handle_attack()    # State machine update

# BAD: Heavy processing in input handler
func _physics_process(delta: float) -> void:
    recalculate_all_ai()  # Don't do heavy work here
    rebuild_spatial_hash()  # This blocks input response
```

### Latency Breakdown

At 60fps, the frame budget is 16.67ms:

```
Input Event → Input Processing → Game Logic → Render → Display
   0ms           ~1ms              ~5ms        ~10ms    ~16ms
```

**Where latency occurs**:
1. **Input polling**: ~0.5ms (hardware + driver)
2. **Godot input system**: ~0.5ms
3. **_physics_process call**: ~0ms (just function call)
4. **Game logic**: 1-5ms (depends on complexity)
5. **Rendering**: 5-10ms (GPU work)
6. **Display sync**: 0-16ms (V-Sync)

**We control**: Steps 3-4 (game logic)
**Hardware controls**: Steps 1-2, 5-6

### V-Sync Considerations

| V-Sync Setting | Latency Impact | Notes |
|----------------|----------------|-------|
| OFF | Lowest | Screen tearing, but responsive |
| ON | +16ms worst case | Smooth, but adds latency |
| Adaptive | Variable | Best of both |
| Triple Buffer | +16ms | Smooth, extra buffer |

**Recommendation**: Let player choose V-Sync in settings. Document impact.

### Manual Validation

#### Hardware Setup
For precise measurement, use:
- High-speed camera (240fps+)
- Light sensor on screen
- LED on input device trigger

#### Software Approximation
Use InputLatencyMonitor during gameplay:
```gdscript
# Enable tracking
latency.warn_on_exceed = true

# Play normally for 5 minutes
# Check for warnings in console

# Generate report
latency.print_report()
```

### Validation Checklist

```markdown
## Input Latency Validation

### Environment
- [ ] V-Sync OFF for testing
- [ ] 60fps stable (check PerformanceMonitor)
- [ ] No background processes

### Tests
- [ ] Movement: avg < 16ms
- [ ] Attack: avg < 16ms
- [ ] All actions: max < 32ms (2 frames acceptable spike)

### Results
- Movement avg: ___ ms
- Attack avg: ___ ms
- Max latency seen: ___ ms
- Unacceptable spikes: ___
```

### Setup (Autoload - Optional)

For global access, add to `project.godot`:
```
[autoload]
InputLatencyMonitor="*res://shared/scripts/input_latency_monitor.gd"
```

---

## COMBAT-014: Object Pooling 500+ Enemies

**Files**:
- `shared/scripts/object_pool.gd` - Generic ObjectPool class
- `combat/scripts/enemy_spawner.gd` - Integration with pooling
- `combat/scripts/enemy_base.gd` - Pooling support methods

### Overview

Object pooling eliminates runtime allocations during gameplay by reusing enemy instances. When an enemy dies, it's returned to the pool instead of being freed; when a new enemy is needed, one is acquired from the pool instead of being instantiated.

### PRD Requirements

| Metric | Target | Method |
|--------|--------|--------|
| Enemies on screen | 500+ | Object pooling |
| Frame drops | 0 | Zero allocations in hot path |
| Memory usage | Stable | Pre-warmed pool |

### EnemySpawner Pooling Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `pooling_enabled` | bool | true | Enable/disable pooling system |
| `pool_prewarm_count` | int | 50 | Enemies to pre-create per type at startup |
| `pool_max_size` | int | 500 | Maximum pool size per enemy type |

### ObjectPool Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `max_pool_size` | int | 500 | Maximum objects in pool (0 = unlimited) |
| `auto_grow` | bool | true | Create new objects when pool exhausted |
| `pool_container` | Node | self | Parent node for pooled objects |

### Understanding the Settings

#### `pooling_enabled`
Master toggle for the pooling system.
- **true** (default): Enemies acquired from pool, released on death
- **false**: Traditional instantiate/queue_free behavior

**Why Change It**: Disable for debugging, or if pooling causes unexpected behavior. Enable (default) for production performance.

#### `pool_prewarm_count`
How many enemies to create at game start.
- **0**: No pre-warming - first enemies cause allocation spike
- **25**: Light pre-warm - fewer startup cost, some allocations later
- **50** (default): Good balance - handles early waves without allocation
- **100+**: Full pre-warm - higher startup cost, no allocations during play

**Why Change It**: Increase if you see frame drops early in gameplay. Decrease if startup time is too long.

#### `pool_max_size`
Maximum enemies per scene type that can be pooled.
- **100**: Light pooling - saves memory, may allocate during intense combat
- **500** (default): PRD requirement - handles maximum enemy count
- **1000+**: Heavy pooling - uses more memory, handles extreme scenarios

**Why Change It**: Increase for higher enemy counts. Decrease to save memory if you never exceed 100 enemies.

### How Pooling Works

```
Game Start:
1. EnemySpawner._init_enemy_pool() creates ObjectPool
2. ObjectPool.prewarm(basic_enemy_scene, 50) pre-creates enemies
3. Pre-warmed enemies are hidden and disabled

During Gameplay (Spawn):
1. _create_enemy() calls enemy_pool.acquire(scene)
2. Pool returns existing hidden enemy (or creates new if empty)
3. Pool calls on_acquire callback → enemy.reset()
4. Enemy is visible, processing enabled, HP restored

During Gameplay (Death):
1. enemy.die() emits died signal, doesn't queue_free (if pooled)
2. Spawner._on_enemy_died() calls enemy_pool.release(enemy)
3. Pool calls on_release callback → enemy.deactivate()
4. Enemy is hidden, processing disabled, stays in scene tree
```

### Enemy Lifecycle Callbacks

The pool uses callbacks for state management:

```gdscript
# Called when enemy is acquired from pool
func reset() -> void:
    current_hp = max_hp
    is_active = true
    visible = true
    velocity = Vector2.ZERO
    set_physics_process(true)

# Called when enemy is released to pool
func deactivate() -> void:
    is_active = false
    visible = false
    velocity = Vector2.ZERO
    set_physics_process(false)
```

### Usage from Code

```gdscript
# Creating a custom pool
var pool := ObjectPool.new()
pool.max_pool_size = 100
pool.auto_grow = true
add_child(pool)

# Set up callbacks
pool.on_acquire = func(obj): obj.reset()
pool.on_release = func(obj): obj.hide()

# Pre-warm with objects
pool.prewarm(my_scene, 20)

# Acquire an object
var obj := pool.acquire(my_scene)
obj.global_position = spawn_pos

# Release back to pool
pool.release(obj)

# Get statistics
var stats := pool.get_statistics()
print("Active: %d, Available: %d, Reused: %d" % [
    stats.active_count, stats.available_count, stats.reuse_count
])
```

### Statistics Available

```gdscript
var stats := pool.get_statistics()
# Returns:
# {
#   total_created: 75,      # Objects ever created
#   available_count: 50,    # Objects waiting in pool
#   active_count: 25,       # Objects currently in use
#   reuse_count: 200,       # Times objects were reused
#   scene_types: 2          # Number of different scenes pooled
# }
```

### Debugging Pool Behavior

Enable pool statistics during gameplay:

```gdscript
# In EnemySpawner or debug script
func _physics_process(delta: float) -> void:
    if Engine.get_physics_frames() % 60 == 0:  # Every second
        var stats := get_pool_stats()
        print("Pool: %d active, %d available, %d reused" % [
            stats.active_count, stats.available_count, stats.reuse_count
        ])
```

**Healthy stats**:
- `reuse_count` should increase during gameplay
- `total_created` should stabilize after pre-warm
- `active_count` + `available_count` ≤ `max_pool_size`

**Warning signs**:
- `total_created` keeps increasing → pool exhausted, increase prewarm
- `reuse_count` is 0 → pooling not working, check `use_pooling` flag

### Performance Impact

| Metric | Without Pooling | With Pooling |
|--------|-----------------|--------------|
| Allocations/sec | ~10 per enemy spawn | 0 |
| Frame spikes | On spawn/death | None |
| Memory churn | High (GC pressure) | Low (stable) |
| Startup cost | None | Pre-warm time |

### Edge Cases Handled

1. **Pool Exhausted**: Creates new object if `auto_grow = true`
2. **Double Release**: Ignored (checks if already in available pool)
3. **Invalid Object**: Skipped if `is_instance_valid()` fails
4. **Scene Not Found**: Returns null, no crash
5. **Max Pool Reached**: Oldest objects freed, new ones added

### Disabling Pooling

For debugging or testing without pooling:

```gdscript
# In EnemySpawner
pooling_enabled = false

# Or in EnemyBase (already killed enemies)
use_pooling = false
```

### Integration with Other Systems

| System | Integration | Notes |
|--------|-------------|-------|
| Spatial Hash | Enemies removed on death, added on spawn | Via spawner callbacks |
| Particles | Spawn at death position before deactivate | Works normally |
| Audio | Play at death before deactivate | Works normally |
| Hit-Stop | Triggers before pool release | Works normally |
| Screen Shake | Triggers before pool release | Works normally |

---

## Input Actions

**File**: `project.godot`

| Action | Default Binding | Description |
|--------|-----------------|-------------|
| `move_up` | W | Move up |
| `move_down` | S | Move down |
| `move_left` | A | Move left |
| `move_right` | D | Move right |
| `attack` | Left Mouse Button | Tongue attack |
| `quit` | Escape | Exit game |

---

## Collision Layers

| Layer | Name | Used By |
|-------|------|---------|
| 1 | Player | Player body |
| 2 | Environment | Walls, obstacles |
| 3 | Enemies | Enemy bodies |
| 4 | PlayerAttack | Tongue hit area |

**Mask Configuration**:
- Player: Layer 1, Mask 2 (collides with environment)
- Tongue HitArea: Layer 4, Mask 3 (detects enemies via `get_overlapping_bodies()`)
- Enemies: Layer 3, Mask 1+2+4 (collides with player, environment, and player attacks)

**Important**: HitArea uses `monitorable = false` since it only monitors enemies, enemies don't need to detect it.

---

## Performance Targets

| Metric | Target | Validation |
|--------|--------|------------|
| FPS | 60 minimum | GTX 1060 @ 1080p |
| Input Lag | <16ms | 1 frame at 60fps |
| Enemies on screen | 500+ | Object pooling |
| Bullets on screen | 500+ | BulletUpHell plugin |

---

## Future Mutations (Reference)

These mutations will modify the settings above:

| Mutation | Effect | Setting Modified |
|----------|--------|------------------|
| Longer Tongue | +50% range | `max_range: 216` |
| Faster Tongue | +50% attack speed | `attack_cooldown: 0.15` |
| Multi-Tongue | Attack in 3 directions | New logic needed |
| Sticky Tongue | Enemies stick briefly | New mechanic |

---

## Changelog

| Date | Story | Changes |
|------|-------|---------|
| 2025-12-13 | COMBAT-001 | Added `move_speed` |
| 2025-12-13 | COMBAT-002 | Added aim system notes |
| 2025-12-13 | COMBAT-003 | Added tongue attack settings |
| 2025-12-13 | COMBAT-004 | Added elastic physics settings |
| 2025-12-13 | COMBAT-005 | Added enemy spawner settings |
| 2025-12-13 | COMBAT-006 | Added enemy AI behavior settings |
| 2025-12-13 | COMBAT-007 | Added spatial hash documentation |
| 2025-12-13 | COMBAT-008 | Added screen shake documentation |
| 2025-12-13 | COMBAT-009 | Added particle system documentation |
| 2025-12-13 | COMBAT-010 | Added hit-stop documentation |
| 2025-12-13 | COMBAT-011 | Added audio manager documentation |
| 2025-12-13 | COMBAT-012 | Added performance monitoring documentation |
| 2025-12-13 | COMBAT-013 | Added input latency documentation |
| 2025-12-13 | COMBAT-014 | Added object pooling documentation |
| 2025-12-13 | BULLET-003 | Added basic bullet patterns documentation |
| 2025-12-13 | BULLET-006 | Added bullet pooling optimization documentation |
| 2025-12-13 | EPIC-003 | Noted blocked stories for manual completion |

---

## BULLET-003: Basic Bullet Patterns

**Files**:
- `combat/resources/bullet_patterns/radial_8way.tres`
- `combat/resources/bullet_patterns/spiral_clockwise.tres`
- `combat/resources/bullet_patterns/aimed_single.tres`
- `combat/scenes/bullet_pattern_test.gd`

### Overview

Implements three foundational bullet patterns using BulletUpHell plugin:
1. **Radial 8-way**: Bullets spawn in circle pattern (configurable count)
2. **Spiral Clockwise**: Rotating pattern with angle offset per spawn
3. **Aimed Single**: Single bullet targeting mouse cursor

### Tunable Parameters

**File**: `combat/scenes/bullet_pattern_test.gd`

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `bullets_per_radial` | int | 8 | Bullets in radial burst |
| `spiral_rotation_speed` | float | 180.0 | Degrees per second rotation |
| `bullet_speed` | float | 200.0 | Bullet movement speed (px/sec) |

### Pattern Resources

#### Radial 8-Way (`radial_8way.tres`)

**Type**: PatternCircle
**Purpose**: Classic radial burst pattern

```gdscript
# Key properties:
bullet = "basic_bullet"
nbr = 8                  # Number of bullets
radius = 0               # Spawn from center
angle_total = 6.28319    # Full circle (2*PI)
iterations = 1           # Single burst
```

**Tuning Notes**:
- `nbr`: Controls bullet count (8 is balanced, 12-16 for danmaku feel)
- `radius = 0`: All bullets spawn at same point, diverge outward
- `angle_total = 2*PI`: Full 360° coverage
- For semi-circle patterns, set `angle_total = PI` (180°)

**Use Cases**:
- Enemy death explosion
- Boss attack phase transitions
- Area denial patterns

#### Spiral Clockwise (`spiral_clockwise.tres`)

**Type**: PatternCircle
**Purpose**: Rotating continuous fire

```gdscript
# Key properties:
bullet = "basic_bullet"
nbr = 12                         # Bullets per wave
iterations = -1                  # Infinite loop
cooldown_spawn = 0.1             # 100ms between waves
layer_angle_offset = 0.5236      # 30° rotation per wave (radians)
```

**Tuning Notes**:
- `layer_angle_offset`: Rotation per spawn (default: 30° = PI/6 radians)
- Calculate from rotation speed: `deg_to_rad(rotation_speed * cooldown_spawn)`
- 180°/sec * 0.1sec = 18° per spawn (smooth spiral)
- 360°/sec * 0.1sec = 36° per spawn (wider gaps)
- `cooldown_spawn`: Controls spiral density (lower = denser)

**Rotation Speed Examples**:
- 90°/sec: Very slow spiral (9° per 0.1s wave)
- 180°/sec: Moderate spiral (default)
- 360°/sec: Fast spiral (36° per wave)
- 720°/sec: Double spiral (72° per wave, creates gaps)

**Use Cases**:
- Turret enemy continuous fire
- Boss rotating laser patterns
- Environmental hazards (rotating spike traps)

#### Aimed Single (`aimed_single.tres`)

**Type**: PatternOne
**Purpose**: Targeted single projectile

```gdscript
# Key properties:
bullet = "basic_bullet"
iterations = 1
forced_lookat_mouse = true       # Aim at mouse cursor
forced_pattern_lookat = true     # Pattern rotation affects aim
```

**Tuning Notes**:
- `forced_lookat_mouse = true`: Auto-aims at player mouse
- For AI enemies, use `forced_target = NodePath("../Player")` instead
- `forced_angle`: Can override mouse targeting with fixed angle

**Use Cases**:
- Tracking projectiles
- Sniper enemies
- Boss telegraphed attacks

### Testing

**Scene**: `combat/scenes/BulletPatternTest.tscn`

**Controls**:
- SPACE: Cycle between test modes (0=Radial, 1=Spiral, 2=Aimed)
- ENTER: Manual spawn current pattern
- ESC: Return to arena

**Auto-spawn**: Patterns spawn every 2 seconds for visual testing

**Console Output**:
```
BulletPatternTest: Initializing pattern tests...
✓ Spawning autoload detected
✓ Basic bullet registered
✓ Radial pattern registered (8 bullets)
✓ Spiral pattern registered (180.0°/sec)
✓ Aimed pattern registered
```

### Unit Tests

**File**: `test/unit/test_bullet_patterns.gd`

Tests verify:
1. `test_radial_spawns_8_bullets` - Exact bullet count
2. `test_spiral_rotates` - Angle offset applied correctly
3. `test_aimed_follows_target` - Mouse targeting works
4. `test_bullets_despawn_after_timeout` - Lifetime respected
5. `test_bullets_move_correctly` - Bullets move in expected directions

**Run Tests**:
```bash
# In Godot editor:
# Scene → Run Scene (F6) on test scene with GUT plugin
```

### Performance Considerations

**Current Load** (per pattern):
- Radial: 8 bullets @ 200px/sec = negligible CPU
- Spiral: 12 bullets/wave * continuous = ~120 bullets/10s
- Aimed: 1 bullet = minimal

**Expected Limits** (from BULLET-004):
- Target: 500 bullets @ 60fps
- Current patterns well under limit

**Optimization Notes**:
- Bullets auto-despawn after 5 seconds (`death_after_time = 5.0`)
- Off-screen culling enabled by BulletUpHell
- Object pooling will be added in BULLET-006

### Integration with Game Systems

**Spawning from Code**:
```gdscript
# In enemy script:
func shoot_radial():
    var spawning = get_node("/root/Spawning")
    spawning.spawn(self, "radial_8way")

func shoot_spiral():
    var spawning = get_node("/root/Spawning")
    spawning.spawn(self, "spiral_clockwise")

func shoot_aimed():
    var spawning = get_node("/root/Spawning")
    spawning.spawn(self, "aimed_single")
```

**Creating Custom Patterns**:
1. Duplicate one of the `.tres` files in `combat/resources/bullet_patterns/`
2. Edit properties in Godot Inspector
3. Register in code: `spawning.new_pattern("my_pattern", pattern_resource)`
4. Spawn: `spawning.spawn(spawner_node, "my_pattern")`

### Future Patterns (BULLET-005)

Frog-themed patterns planned:
- **Fly Swarm**: Small bullets with random offsets
- **Lily Pad Spiral**: Slow expanding green bullets
- **Ripple Wave**: Concentric ring patterns

### Troubleshooting

**Problem**: "Spawning autoload not found"
**Solution**: Enable BulletUpHell plugin in Project Settings

**Problem**: Bullets don't spawn
**Solution**: Verify bullet ID matches pattern's `bullet` property

**Problem**: Spiral doesn't rotate
**Solution**: Check `layer_angle_offset` is non-zero (in radians, not degrees)

**Problem**: Aimed bullets go wrong direction
**Solution**: Ensure `forced_lookat_mouse = true` or set `forced_target`

### References

- BulletUpHell Documentation: `addons/BulletUpHell/README.md`
- Example Scenes: `addons/BulletUpHell/ExampleScenes/`
- Epic Plan: `.thursian/projects/pond-conspiracy/planning/01-MVP/Epic-002.md`

---

## BULLET-006: Bullet Pooling Optimization

**Files**:
- `combat/scripts/bullet_pool_manager.gd` - Pool management wrapper
- `test/unit/test_bullet_pooling.gd` - Unit tests
- `test/benchmarks/test_bullet_pooling_performance.gd` - Performance benchmarks
- `docs/BULLETUPHELL_POOLING_ANALYSIS.md` - Detailed analysis

### Overview

**IMPORTANT**: BulletUpHell plugin **already includes sophisticated object pooling**. No custom pooling implementation needed. This story documents how to use and optimize the built-in pooling system.

### Built-in Pooling System

BulletUpHell uses RID-based pooling via PhysicsServer2D:
- **Pre-warming Support**: Manual pool creation via `create_pool()`
- **Auto-Growth**: Automatically grows pool when depleted
- **RID Efficiency**: Uses physics server RIDs instead of Node2D instances
- **Zero Allocations**: No instantiate/free calls during gameplay after pre-warm

### Tunable Parameters

**File**: `combat/scripts/bullet_pool_manager.gd` (optional wrapper)

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `enable_prewarm` | bool | true | Pre-warm pools on _ready() |
| `shared_area_name` | String | "0" | Default SharedArea node name |
| `basic_bullet_pool_size` | int | 200 | Basic bullet pool size |
| `fast_bullet_pool_size` | int | 150 | Fast bullet pool size |
| `spiral_bullet_pool_size` | int | 150 | Spiral bullet pool size |
| `boss_bullet_pool_size` | int | 500 | Boss pattern pool size |
| `enable_monitoring` | bool | true | Enable pool health monitoring |
| `monitor_interval` | float | 1.0 | Health check interval (seconds) |
| `warn_on_auto_growth` | bool | true | Warn if pool auto-grows |

### BulletUpHell Native Settings

**File**: `addons/BulletUpHell/BuHSpawner.gd` (read-only, built into plugin)

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `poolBullets` | Dictionary | {} | Active bullets (RID -> bullet_data) |
| `inactive_pool` | Dictionary | {} | Inactive bullets by bullet_type |
| `cull_bullets` | bool | true | Delete bullets offscreen |
| `cull_margin` | float | 50.0 | Distance from viewport before culling |
| `cull_minimum_speed_required` | float | 200.0 | Don't cull slow bullets |

### How BulletUpHell Pooling Works

#### 1. Pool Structure

```gdscript
# From BuHSpawner.gd
var poolBullets: Dictionary = {}      # Active bullets
var inactive_pool: Dictionary = {}    # Inactive bullets by type
var shape_indexes: Dictionary = {}    # RID -> shape_index mapping
var shape_rids: Dictionary = {}       # Area -> {index -> RID}
```

#### 2. Pool Lifecycle

**Initialization** (`create_pool()`):
```gdscript
Spawning.create_pool(bullet_type, shared_area, amount)
# Creates 'amount' bullets of 'bullet_type'
# Stores in inactive_pool[bullet_type]
# For RID bullets: creates PhysicsServer2D shapes
```

**Acquiring** (`wake_from_pool()`):
```gdscript
# Returns RID from inactive pool
# Auto-creates pool if missing (with warning)
# Auto-grows pool if empty (with warning)
```

**Releasing** (`back_to_grave()`):
```gdscript
# Returns bullet RID to inactive_pool
# Sets state to BState.QueuedFree
```

### Setup: Pre-Warm Pools on Scene Load

**Method 1: Direct BulletUpHell API**

```gdscript
# In your combat scene's _ready()
func _ready() -> void:
    # Pre-warm pool for each bullet type
    Spawning.create_pool("basic_bullet", "0", 200)
    Spawning.create_pool("fast_bullet", "0", 100)
    Spawning.create_pool("spiral_bullet", "0", 150)
    print("Pre-warmed bullet pools")
```

**Method 2: Using BulletPoolManager Wrapper**

```gdscript
# Add BulletPoolManager as autoload or scene node
# Configure via exports:
@export var basic_bullet_pool_size: int = 200
@export var enable_prewarm: bool = true

# Automatic pre-warming on _ready()
# Monitoring and health checks included
```

### Recommended Pool Sizes

| Use Case | Pool Size | Rationale |
|----------|-----------|-----------|
| Normal Gameplay | 200 | ~4 seconds of bullets at 50/sec spawn rate |
| Boss Fight | 500 | Dense bullet patterns |
| Stress Test (BULLET-004) | 600+ | Performance validation (500+ bullets) |

### Pool Health Monitoring

**Using BulletPoolManager**:

```gdscript
var pool_mgr = $BulletPoolManager

# Get pool health
var health = pool_mgr.get_pool_health("basic_bullet")
print("Active: %d, Capacity: %d, Utilization: %.1f%%" % [
    health.active,
    health.capacity,
    health.utilization * 100
])

# Print all pools
pool_mgr.print_pool_status()

# Connect to signals
pool_mgr.pool_auto_grew.connect(_on_pool_grew)
pool_mgr.pool_depleted.connect(_on_pool_depleted)
```

### Performance Characteristics

| Metric | Without Pool | With Pool (Pre-warmed) |
|--------|--------------|------------------------|
| Spawn Time | ~0.5ms | ~0.01ms (50x faster) |
| Despawn Time | ~0.3ms | ~0.005ms (60x faster) |
| Memory Growth | Linear | Constant after warmup |
| GC Pressure | High | None |

### Integration with Game Systems

**Spawning Bullets** (automatic pooling):

```gdscript
# BulletUpHell automatically uses the pool
Spawning.spawn(self, "radial_8way", "0")
# No manual acquire/release needed
```

**Custom Bullet Types**:

```gdscript
# Register bullet type first
Spawning.new_bullet("custom_bullet", bullet_props)

# Pre-warm pool
Spawning.create_pool("custom_bullet", "0", 100)

# Spawn as normal
Spawning.spawn(self, "custom_pattern", "0")
```

### Tuning Guide

#### For More Responsive Gameplay

- **Increase pool sizes**: Prevents auto-growth warnings
- **Pre-warm generously**: 200% headroom over max expected
- **Monitor pool health**: Enable `enable_monitoring = true`

#### For Memory Optimization

- **Reduce pool sizes**: If you never use all bullets
- **Disable monitoring**: `enable_monitoring = false`
- **Use shared areas wisely**: Group bullets by collision behavior

#### For Best Performance

```gdscript
# Pre-warm with headroom
Spawning.create_pool("bullet_type", "0", 600)  # 200% headroom

# Monitor for warnings
# If you see "WARNING : bullet pool for bullet of ID X is empty"
# → Increase pool size for that type
```

### Debugging

**Check Pool Status**:

```gdscript
# Direct BulletUpHell access
print("Inactive bullets: ", Spawning.inactive_pool["basic_bullet"].size())
print("Active bullets: ", Spawning.poolBullets.size())

# Via BulletPoolManager
var stats = pool_mgr.get_pool_health("basic_bullet")
print("Pool stats: ", stats)
```

**Common Warnings**:

| Warning | Cause | Fix |
|---------|-------|-----|
| "WARNING : there's no bullet pool for bullet of ID X" | Pool not pre-warmed | Add `create_pool()` call |
| "WARNING : bullet pool for bullet of ID X is empty" | Pool too small | Increase pool size |
| Pool auto-grew | Pool exhausted mid-game | Increase pre-warm size |

### Unit Tests

**File**: `test/unit/test_bullet_pooling.gd`

Tests verify:
1. Pool creation allocates bullets
2. Pool acquire returns bullets and decrements pool
3. Pool release recycles bullets
4. Pool auto-grows when depleted
5. Pool pre-warming works correctly
6. Stress test with 500 bullets

**Run Tests**:
```bash
# In Godot editor with GUT plugin:
# Scene → Run Scene (F6) on test scene
```

### Performance Benchmarks

**File**: `test/benchmarks/test_bullet_pooling_performance.gd`

Benchmarks measure:
1. **Pooled spawn performance**: < 50µs per bullet
2. **500 bullets @ 60fps**: Maintains 60fps average
3. **Memory stability**: < 10% growth over 1000 spawn/despawn cycles
4. **Spawn consistency**: Low variance (< 50% CV)

**Expected Results** (on target hardware):
- Average spawn time: ~10-30µs
- 500 bullets: 60+ fps
- Memory growth: < 5%
- No frame drops during stress test

### Optimization Tips

#### 1. Pre-Warm Generously

```gdscript
# Better to over-allocate than trigger auto-growth mid-game
Spawning.create_pool("bullet", "0", 600)  # 200% headroom
```

#### 2. Use Shared Areas Wisely

```gdscript
# Group bullets by collision behavior
Spawning.create_pool("enemy_bullet", "0", 400)  # SharedArea "0"
Spawning.create_pool("boss_bullet", "1", 200)   # SharedArea "1"
```

#### 3. Clear Bullets Between Levels

```gdscript
func change_level() -> void:
    Spawning.clear_all_bullets()  # Returns all to pool
    await get_tree().process_frame
    # Pool is now ready for next level
```

### BULLET-004 Integration

Pool sizes are designed to meet BULLET-004 performance requirements:

| Requirement | Pool Configuration |
|-------------|-------------------|
| 500 bullets @ 60fps | Pre-warm 600 bullets (20% headroom) |
| No frame drops | Zero allocations during gameplay |
| Memory stable | Constant pool size after warmup |

### Accessibility Notes

- Pooling is transparent to gameplay
- No user-facing settings required
- No impact on accessibility features

### References

- Detailed Analysis: `docs/BULLETUPHELL_POOLING_ANALYSIS.md`
- BulletUpHell Source: `addons/BulletUpHell/BuHSpawner.gd` (lines 38-286)
- Epic Plan: `.thursian/projects/pond-conspiracy/planning/01-MVP/Epic-002.md`
