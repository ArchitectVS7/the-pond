# BULLET-007: Collision Optimization Documentation

## Overview
Optimized bullet collision system using Godot's collision layers and masks to eliminate redundant collision checks and achieve 60fps with 500 bullets + 100 enemies.

## Collision Layer Architecture

### Layer Map (project.godot)
| Layer | Name | Used By | Purpose |
|-------|------|---------|---------|
| 1 | Player | Player body | Player character collision |
| 2 | Environment | Walls, obstacles | Static world geometry |
| 3 | Enemies | Enemy bodies | Enemy character collision |
| 4 | PlayerAttack | Tongue hit area | Player attack detection |
| 5 | **Bullets** | Enemy bullets | **Enemy projectiles (NEW)** |

### Collision Matrix
| Entity | Layer | Mask | Collides With |
|--------|-------|------|---------------|
| Player | 1 | 2, 5 | Environment, Bullets |
| Enemy | 3 | 2 | Environment only |
| Bullet | 5 | 1 | Player only |
| PlayerAttack | 4 | 3 | Enemies only |

## Key Optimizations

### 1. Minimal Collision Masks
```gdscript
# Bullets only check Player layer (1 bit set)
bullet.collision_layer = 0b10000  # Layer 5
bullet.collision_mask = 0b00001   # Layer 1 only

# This prevents bullets from checking:
# - Other bullets (no bullet-bullet collision)
# - Enemies (bullets pass through enemies)
# - Environment (bullets ignore walls for bullet-hell gameplay)
```

### 2. Deferred Collision Operations
```gdscript
# Thread-safe collision shape enable/disable
collision_config.enable_collision_shape(shape)  # Uses set_deferred()
collision_config.disable_collision_shape(shape) # Uses set_deferred()
```

### 3. Area2D for Bullets
- BulletUpHell uses `Area2D` (not `CharacterBody2D`)
- No physics simulation needed for bullets
- Cheaper overlap detection
- Perfect for bullet-hell patterns

## Performance Metrics

### Target Performance
- **500 bullets** active simultaneously
- **100 enemies** moving on screen
- **60 FPS** average
- **0 dropped frames** (all frames < 16.67ms)

### Collision Check Reduction
Without layer optimization:
- Each bullet checks: Bullets (500) + Enemies (100) + Player (1) = **601 checks**
- Total per frame: 500 bullets × 601 = **300,500 checks**

With layer optimization:
- Each bullet checks: Player (1) only = **1 check**
- Total per frame: 500 bullets × 1 = **500 checks**

**Performance gain: 600x fewer collision checks!**

## Implementation Guide

### 1. Configure Project Settings
Already done in `project.godot`:
```ini
[layer_names]
2d_physics/layer_1="Player"
2d_physics/layer_2="Environment"
2d_physics/layer_3="Enemies"
2d_physics/layer_4="PlayerAttack"
2d_physics/layer_5="Bullets"
```

### 2. Configure BulletUpHell Spawner
```gdscript
var collision_config = preload("res://combat/scripts/bullet_collision_config.gd")

# Configure spawner's shared_area template
collision_config.configure_bullet_spawner($BulletSpawner)
```

### 3. Configure Individual Bullets (if needed)
```gdscript
# For manually created bullets
var bullet_area = Area2D.new()
collision_config.configure_bullet_area(bullet_area)

# Add collision shape
var shape = CollisionShape2D.new()
shape.shape = collision_config.create_bullet_hitbox(4.0)
bullet_area.add_child(shape)
```

### 4. Validate Configuration
```gdscript
# Check spawner setup
var validation = collision_config.validate_spawner_config($BulletSpawner)

if not validation.valid:
    for error in validation.errors:
        print("ERROR: ", error)

for warning in validation.warnings:
    print("WARNING: ", warning)
```

## API Reference

### BulletCollisionConfig (Static Class)

#### Constants
```gdscript
const LAYER_PLAYER: int = 1
const LAYER_ENVIRONMENT: int = 2
const LAYER_ENEMIES: int = 3
const LAYER_PLAYER_ATTACK: int = 4
const LAYER_BULLETS: int = 5

const MASK_PLAYER: int = 0b00001
const MASK_ENVIRONMENT: int = 0b00010
const MASK_ENEMIES: int = 0b00100
const MASK_PLAYER_ATTACK: int = 0b01000
const MASK_BULLETS: int = 0b10000

const DEFAULT_BULLET_HITBOX_SIZE: float = 4.0
const USE_DEFERRED_COLLISION: bool = true
```

#### Functions
```gdscript
# Configure BulletUpHell spawner
configure_bullet_spawner(spawner: Node) -> void

# Configure individual bullet Area2D
configure_bullet_area(bullet_area: Area2D) -> void

# Thread-safe collision shape operations
enable_collision_shape(shape: CollisionShape2D) -> void
disable_collision_shape(shape: CollisionShape2D) -> void

# Create optimized bullet hitbox
create_bullet_hitbox(radius: float = 4.0) -> CircleShape2D

# Validation
validate_spawner_config(spawner: Node) -> Dictionary

# Helpers
get_layer_name(layer_bit: int) -> String
is_collision_optimized(area: Area2D) -> bool
```

## Testing

### Unit Tests
Location: `tests/unit/test_bullet_collision.gd`

Run tests:
```bash
# Run all collision tests
godot --headless -s addons/gut/gut_cmdln.gd -gtest=test_bullet_collision

# Run specific test
godot --headless -s addons/gut/gut_cmdln.gd -gtest=test_bullet_collision -gunit_test_name=test_bullet_collides_player
```

Key test cases:
- `test_bullet_collides_player` - Bullets hit player ✓
- `test_bullet_ignores_enemies` - Bullets ignore enemies ✓
- `test_collision_layer_masks` - Layer bit flags correct ✓
- `test_enable_collision_shape_deferred` - Deferred operations work ✓

### Performance Tests
Location: `tests/integration/test_bullet_collision_performance.gd`

Run performance test:
```bash
godot --headless -s addons/gut/gut_cmdln.gd -gtest=test_bullet_collision_performance
```

Validates:
- 500 bullets + 100 enemies
- Average FPS >= 60
- Zero dropped frames
- Collision layer optimization

### Stress Test
Location: `combat/scripts/bullet_collision_stress_test.gd`

Manual stress test (in-game):
```gdscript
var stress_test = load("res://combat/scripts/bullet_collision_stress_test.gd").new()
add_child(stress_test)
stress_test.start_test()
```

## Tunable Parameters

### In bullet_collision_config.gd
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `DEFAULT_BULLET_HITBOX_SIZE` | float | 4.0 | Default bullet collision radius |
| `USE_DEFERRED_COLLISION` | bool | true | Use set_deferred() for safety |

### In bullet_collision_stress_test.gd
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max_bullets` | int | 500 | Maximum bullets to spawn |
| `max_enemies` | int | 100 | Maximum enemies to spawn |
| `bullet_spawn_rate` | float | 100.0 | Bullets spawned per second |
| `enemy_spawn_rate` | float | 20.0 | Enemies spawned per second |
| `test_duration` | float | 10.0 | Test duration in seconds |
| `enable_collision_validation` | bool | true | Validate layer config |

## Troubleshooting

### Bullets Not Hitting Player
**Check:**
1. Bullet collision_layer = 16 (0b10000 = Layer 5)
2. Bullet collision_mask = 1 (0b00001 = Layer 1)
3. Player collision_layer = 1 (Layer 1)
4. Player collision_mask includes 16 (Layer 5)

**Fix:**
```gdscript
collision_config.configure_bullet_spawner($BulletSpawner)
```

### Bullets Hitting Enemies (Wrong!)
**Check:**
1. Bullet collision_mask should be 1 (Player only)
2. Enemy collision_mask should NOT include 16 (Bullets)

**Validate:**
```gdscript
var validation = collision_config.validate_spawner_config($BulletSpawner)
print(validation)
```

### Performance Issues
**Check:**
1. Run performance test to measure baseline
2. Verify collision layers are optimized:
```gdscript
var is_optimized = collision_config.is_collision_optimized($BulletArea)
print("Optimized: ", is_optimized)
```
3. Use deferred collision operations
4. Reduce max_bullets in spawner

## Integration with BulletUpHell

### BulletUpHell Spawner Setup
BulletUpHell uses a `shared_area` template node that gets cloned for each bullet:

```
BuHSpawner
├── shared_area (Area2D)  <- Configure this!
│   └── CollisionShape2D
├── Patterns
└── ...
```

When you configure the spawner:
```gdscript
collision_config.configure_bullet_spawner($BulletSpawner)
```

It sets:
- `shared_area.collision_layer = 16` (Layer 5: Bullets)
- `shared_area.collision_mask = 1` (Layer 1: Player only)

All spawned bullets inherit these settings automatically!

## Future Enhancements

### Potential Optimizations
1. **Quadtree/SpatialHash for bullets** - Already implemented for enemies
2. **Bullet pooling** - Reuse bullet instances (COMBAT-014 pattern)
3. **SIMD collision checks** - Batch collision detection
4. **GPU-based collision** - For extreme bullet counts (1000+)

### Additional Features
1. **Collision layer presets** - Named configurations for different bullet types
2. **Dynamic layer switching** - Bullets that change targets mid-flight
3. **Collision callbacks** - Hook into bullet-player collision events
4. **Visual debugging** - Show collision layers in debug overlay

## References

- **Epic-002**: BulletUpHell Integration
- **COMBAT-007**: Spatial Hash Collision Optimization (enemies)
- **Godot Docs**: [Physics Layers and Masks](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html#collision-layers-and-masks)
- **BulletUpHell**: [Plugin Documentation](https://github.com/Dark-Peace/BulletUpHell)

## Acceptance Criteria Status

- [x] Bullet collision uses Area2D efficiently
- [x] Collision layers properly configured (Layer 5: Bullets)
- [x] No redundant collision checks (bullets only mask Player)
- [x] Performance validated with 500 bullets + 100 enemies at 60fps
- [x] Tests created and passing
- [x] Documentation complete
