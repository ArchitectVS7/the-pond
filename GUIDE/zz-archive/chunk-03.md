

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


# Pond Conspiracy - Developers Manual - Epic-006

## Epic-006: Mutation System - Tunable Parameters

This document contains all 50+ tunable parameters for the mutation system.

For complete details, see docs/mutation_balance.md

## Quick Reference

### System Parameters (2)
- max_mutations: 10
- allow_duplicates: false

### UI Parameters (7)
- options_count: 3
- card_width: 200
- card_height: 280
- card_spacing: 40
- animation_duration: 0.3
- hover_scale: 1.05
- hover_duration: 0.15

### Mutation Parameters (29)
See individual .tres files in metagame/resources/mutations/

### Ability Parameters (15)
See individual .gd files in metagame/scripts/abilities/

### Synergy Parameters (3)
See individual .tres files in metagame/resources/synergies/

**Total: 50+ tunable parameters**