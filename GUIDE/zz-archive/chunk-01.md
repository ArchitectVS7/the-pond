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
