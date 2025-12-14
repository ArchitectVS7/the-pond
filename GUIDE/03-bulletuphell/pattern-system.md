# Pattern System

Patterns define how bullets spawn. BulletUpHell provides several pattern types out of the box. This chapter covers how they work and how to create new ones.

---

## Pattern Types

### PatternOne

Spawns a single bullet.

```gdscript
var pattern := PatternOne.new()
pattern.bullet = "basic_bullet"
pattern.forced_angle = 0.0  # Radians, 0 = right
```

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `bullet` | String | Bullet ID to spawn |
| `forced_angle` | float | Direction in radians |
| `forced_lookat_mouse` | bool | Auto-aim at mouse |
| `forced_target` | NodePath | Auto-aim at node |

**Use cases**: Sniper shots, aimed projectiles

### PatternCircle

Spawns bullets in a circular arrangement.

```gdscript
var pattern := PatternCircle.new()
pattern.bullet = "basic_bullet"
pattern.nbr = 8              # Number of bullets
pattern.angle_total = TAU    # Full circle (2π)
pattern.radius = 0           # Spawn from center
```

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `nbr` | int | Number of bullets |
| `angle_total` | float | Arc coverage (TAU = 360°) |
| `angle_offset` | float | Starting angle offset |
| `radius` | float | Spawn distance from center |
| `layer_angle_offset` | float | Rotation per iteration |
| `iterations` | int | Number of spawn waves (-1 = infinite) |
| `cooldown_spawn` | float | Time between iterations |

**Use cases**: Radial bursts, spirals, waves

### PatternLine

Spawns bullets in a line.

```gdscript
var pattern := PatternLine.new()
pattern.bullet = "basic_bullet"
pattern.nbr = 5
pattern.spacing = 20.0
```

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `nbr` | int | Number of bullets |
| `spacing` | float | Distance between bullets |
| `perpendicular` | bool | Line perpendicular to direction |

**Use cases**: Laser beams, walls of bullets

---

## Creating Patterns

### Method 1: Resource Files (.tres)

Create pattern resources in the editor:

1. Right-click in FileSystem
2. New Resource → PatternCircle (or other type)
3. Configure in Inspector
4. Save as `.tres`

**File**: `combat/resources/bullet_patterns/radial_8way.tres`

### Method 2: Code

```gdscript
func _ready() -> void:
    var pattern := PatternCircle.new()
    pattern.bullet = "basic_bullet"
    pattern.nbr = 8
    pattern.angle_total = TAU
    Spawning.new_pattern("my_pattern", pattern)
```

### Registering and Spawning

```gdscript
# Register (once, typically in _ready)
Spawning.new_bullet("bullet_id", bullet_resource)
Spawning.new_pattern("pattern_id", pattern_resource)

# Spawn (whenever needed)
Spawning.spawn(spawner_node, "pattern_id", "shared_area_name")
```

---

## The Three MVP Patterns

### Radial 8-Way

**File**: `combat/resources/bullet_patterns/radial_8way.tres`

```gdscript
# Configuration
bullet = "basic_bullet"
nbr = 8
radius = 0
angle_total = TAU  # Full 360°
iterations = 1      # Single burst
```

**Visual**:
```
    ↑
  ↖   ↗
←   ●   →
  ↙   ↘
    ↓
```

**Tuning**:
- `nbr = 12-16`: More bullets, denser pattern
- `nbr = 4-6`: Fewer bullets, easier to dodge
- `angle_total = PI`: Half-circle (180°)

### Spiral Clockwise

**File**: `combat/resources/bullet_patterns/spiral_clockwise.tres`

```gdscript
# Configuration
bullet = "basic_bullet"
nbr = 12
iterations = -1                # Infinite loop
cooldown_spawn = 0.1           # 100ms between waves
layer_angle_offset = 0.5236    # 30° per wave
```

**Visual** (over time):
```
Wave 1: →→→→→→
Wave 2:  ↘↘↘↘↘↘
Wave 3:   ↓↓↓↓↓↓
Wave 4:    ↙↙↙↙↙↙
...
```

**Tuning**:
- `layer_angle_offset`: Rotation per spawn
  - `deg_to_rad(30)`: Smooth spiral
  - `deg_to_rad(45)`: Wider gaps
  - `deg_to_rad(90)`: Quarter-turn jumps
- `cooldown_spawn`: Time between waves
  - `0.05`: Dense spiral
  - `0.2`: Sparse spiral

### Aimed Single

**File**: `combat/resources/bullet_patterns/aimed_single.tres`

```gdscript
# Configuration
bullet = "basic_bullet"
iterations = 1
forced_lookat_mouse = true
```

**Visual**:
```
[Spawner] ───────→ [Mouse/Player]
```

**Tuning**:
- `forced_lookat_mouse = true`: Tracks mouse cursor
- `forced_target = NodePath("../Player")`: Tracks player node
- `forced_angle = PI/2`: Fixed direction (down)

---

## Advanced Patterns

### Expanding Ring

Bullets spawn in a circle and move outward:

```gdscript
var pattern := PatternCircle.new()
pattern.bullet = "basic_bullet"
pattern.nbr = 16
pattern.radius = 0
pattern.angle_total = TAU
```

The bullets naturally move outward because their velocity is set to their spawn direction.

### Contracting Ring

Create a bullet type that moves toward center:

```gdscript
var bullet := BuHBullet.new()
bullet.speed = -100.0  # Negative = toward spawner
# or use homing toward player
```

### Double Spiral

Two interleaved spirals:

```gdscript
# Spiral 1
var spiral1 := PatternCircle.new()
spiral1.nbr = 8
spiral1.layer_angle_offset = deg_to_rad(30)
spiral1.angle_offset = 0

# Spiral 2 (offset by half)
var spiral2 := PatternCircle.new()
spiral2.nbr = 8
spiral2.layer_angle_offset = deg_to_rad(30)
spiral2.angle_offset = deg_to_rad(15)  # Half of 30°

# Spawn both
Spawning.spawn(self, "spiral1", "0")
Spawning.spawn(self, "spiral2", "0")
```

### Burst + Aimed

Combine patterns for complex attacks:

```gdscript
func boss_attack() -> void:
    # Radial burst
    Spawning.spawn(self, "radial_16way", "0")

    # Then aimed shot
    await get_tree().create_timer(0.3).timeout
    Spawning.spawn(self, "aimed_triple", "0")
```

---

## Bullet Properties

When creating bullets, you can configure:

| Property | Type | Description |
|----------|------|-------------|
| `sprite` | Texture2D | Bullet appearance |
| `speed` | float | Movement speed (px/s) |
| `damage` | int | Damage on hit |
| `death_after_time` | float | Lifetime in seconds |
| `collision_shape` | Shape2D | Hitbox shape |
| `rotation_speed` | float | Spin rate |

**Example**:
```gdscript
var bullet := BuHBullet.new()
bullet.sprite = preload("res://assets/sprites/bullet.png")
bullet.speed = 200.0
bullet.damage = 1
bullet.death_after_time = 5.0
Spawning.new_bullet("basic_bullet", bullet)
```

---

## Testing Patterns

**Scene**: `combat/scenes/BulletPatternTest.tscn`

**Controls**:
- `SPACE`: Cycle between test modes
- `ENTER`: Manual spawn current pattern
- `ESC`: Return to arena

**Console output**:
```
BulletPatternTest: Initializing pattern tests...
✓ Spawning autoload detected
✓ Basic bullet registered
✓ Radial pattern registered (8 bullets)
```

---

## Common Issues

**"Spawning autoload not found"**
- Enable BulletUpHell plugin in Project Settings
- Check autoload is named "Spawning"

**Bullets don't spawn**
- Verify bullet ID matches pattern's `bullet` property
- Check SharedArea exists in scene

**Spiral doesn't rotate**
- `layer_angle_offset` must be in radians, not degrees
- Use `deg_to_rad()` for conversion

**Bullets go wrong direction**
- Check `forced_lookat_mouse` or `forced_target`
- Verify `forced_angle` is in radians

---

## Summary

| Pattern Type | Use Case | Key Parameter |
|--------------|----------|---------------|
| PatternOne | Single shots | `forced_angle` |
| PatternCircle | Radials, spirals | `nbr`, `layer_angle_offset` |
| PatternLine | Walls, beams | `spacing` |

Patterns are building blocks. Combine them with timing and positioning for complex boss attacks.

---

[← Back to Overview](overview.md) | [Next: Frog Patterns →](frog-patterns.md)
