# BULLET-005: Custom Frog-Themed Bullet Patterns

**Status**: COMPLETE
**Epic**: Epic-002 BulletUpHell Integration
**Dependencies**: BULLET-001, BULLET-002, BULLET-003, BULLET-004

## Overview

Three custom bullet patterns with frog-themed characteristics and visual identity:

1. **Fly Swarm** - Erratic, small, fast-moving bullets
2. **Lily Pad Spiral** - Slow-expanding nature-themed pattern
3. **Ripple Wave** - Concentric water rings

## Implementation Details

### 1. Fly Swarm Pattern

**File**: `C:\dev\GIT\the-pond\combat\resources\bullet_patterns\fly_swarm.tres`
**Bullet**: `C:\dev\GIT\the-pond\combat\resources\bullets\fly_bullet.tres`

**Characteristics**:
- 16 bullets per burst (swarm effect)
- Random position offset (gaussian distribution, max 15.0 pixels)
- Fast speed (250.0)
- Small scale (0.5x)
- Erratic movement via angular equation: `sin(t*8)*0.3`
- 3 iterations with 0.15s cooldown between bursts

**Visual Identity**:
- Small, dark bullets (0.5 scale)
- Rotating (5.0 rotation speed)
- Sinusoidal flight path for insect-like erratic movement

**Tunable Parameters**:
```gdscript
r_radius_variation = Vector3(0, 15, 5)  # fly_random_offset
speed = 250.0  # Fast, unpredictable movement
a_angular_equation = "sin(t*8)*0.3"  # Erratic flight pattern
```

### 2. Lily Pad Spiral Pattern

**File**: `C:\dev\GIT\the-pond\combat\resources\bullet_patterns\lily_pad_spiral.tres`
**Bullet**: `C:\dev\GIT\the-pond\combat\resources\bullets\lily_pad_bullet.tres`

**Characteristics**:
- 8 bullets per wave (symmetric pattern)
- 3 expanding layers with 30.0 pixel offset per layer
- Slow expansion (50.0 base speed)
- Speed decreases by 15.0 per layer (outward effect)
- Infinite iterations (continuous spiral)
- 0.2s spawn cooldown, 0.1s layer delay

**Visual Identity**:
- Larger bullets (1.2 scale) for lily pad aesthetic
- Green trail color (RGB: 0.3, 0.8, 0.3)
- Slow rotation (1.0 rotation speed)
- Nature-themed color palette

**Tunable Parameters**:
```gdscript
layer_pos_offset = 30.0  # Expansion distance
layer_speed_offset = -15.0  # Speed reduction per layer
speed = 50.0  # lily_expand_rate
layer_angle_offset = 0.3927  # Spiral rotation (22.5°)
```

### 3. Ripple Wave Pattern

**File**: `C:\dev\GIT\the-pond\combat\resources\bullet_patterns\ripple_wave.tres`
**Bullet**: `C:\dev\GIT\the-pond\combat\resources\bullets\ripple_bullet.tres`

**Characteristics**:
- 24 bullets per ring (smooth circle)
- 3 concentric rings (iterations)
- 0.5s delay between rings
- Medium speed (120.0)
- Full 360-degree coverage (2*PI radians)
- Symmetric for perfect circles

**Visual Identity**:
- Medium-sized bullets (0.8 scale)
- Blue water-themed trail (RGB: 0.4, 0.6, 0.9, alpha: 0.5)
- Trail length: 10.0, width: 2.0
- No rotation for smooth expansion

**Tunable Parameters**:
```gdscript
iterations = 3  # ripple_ring_count
cooldown_spawn = 0.5  # ripple_ring_delay (seconds)
nbr = 24  # Bullets per ring
speed = 120.0  # Expansion speed
```

## Test Coverage

**Test File**: `C:\dev\GIT\the-pond\tests\integration\test_frog_patterns.gd`

### Test Categories

1. **Resource Loading** (6 tests)
   - Pattern resource loading
   - Bullet property loading

2. **Fly Swarm Tests** (4 tests)
   - `test_fly_swarm_random_offset` - Position variance validation
   - `test_fly_swarm_small_fast_bullets` - Speed and scale checks
   - `test_fly_swarm_erratic_movement` - Movement pattern validation
   - `test_fly_swarm_burst_count` - Swarm size verification

3. **Lily Pad Tests** (5 tests)
   - `test_lily_pad_expands` - Expansion mechanics validation
   - `test_lily_pad_slow_expansion` - Speed verification
   - `test_lily_pad_nature_theme` - Visual theme checks
   - `test_lily_pad_continuous_spiral` - Infinite iteration check
   - `test_lily_pad_symmetry` - Symmetry validation

4. **Ripple Wave Tests** (4 tests)
   - `test_ripple_creates_rings` - Ring spawn mechanics
   - `test_ripple_concentric_circles` - Circle geometry validation
   - `test_ripple_wave_visual_trail` - Water effect validation
   - `test_ripple_medium_speed` - Speed verification

5. **Differentiation Tests** (2 tests)
   - Pattern visual distinction
   - Spawn behavior distinction

6. **Parameter Validation** (4 tests)
   - Tunable parameter defaults

7. **Integration Tests** (2 tests)
   - BulletUpHell compatibility
   - Resource property validation

**Total Tests**: 27

## Acceptance Criteria Validation

| Criterion | Status | Validation |
|-----------|--------|------------|
| Fly swarm pattern created | ✅ | `fly_swarm.tres` with random offsets |
| Lily pad spiral created | ✅ | `lily_pad_spiral.tres` with expansion layers |
| Ripple wave pattern created | ✅ | `ripple_wave.tres` with timed rings |
| Visual distinction | ✅ | Different speeds, scales, trails, colors |
| Random offset for flies | ✅ | Gaussian distribution, 15.0 max offset |
| Lily pad expansion | ✅ | 3 layers, 30px offset, -15 speed reduction |
| Ripple rings | ✅ | 3 rings, 0.5s delay, 24 bullets/ring |
| Test coverage | ✅ | 27 comprehensive tests |

## Tunable Parameters Reference

### Fly Swarm
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `fly_random_offset` | float | 15.0 | Position randomness (radius variation max) |
| Speed | float | 250.0 | Bullet velocity |
| Scale | float | 0.5 | Bullet size multiplier |
| Burst count | int | 16 | Bullets per swarm |

### Lily Pad Spiral
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `lily_expand_rate` | float | 50.0 | Base expansion speed |
| Layer offset | float | 30.0 | Distance between layers |
| Speed reduction | float | -15.0 | Speed decrease per layer |
| Layers | int | 3 | Number of expanding rings |

### Ripple Wave
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ripple_ring_count` | int | 3 | Concurrent rings |
| `ripple_ring_delay` | float | 0.5 | Seconds between rings |
| Bullets per ring | int | 24 | Ring density |
| Speed | float | 120.0 | Expansion speed |

## Usage Example

```gdscript
# In a spawner node or boss attack script
extends Node2D

func _ready():
	# Load patterns
	var fly_pattern = load("res://combat/resources/bullet_patterns/fly_swarm.tres")
	var lily_pattern = load("res://combat/resources/bullet_patterns/lily_pad_spiral.tres")
	var ripple_pattern = load("res://combat/resources/bullet_patterns/ripple_wave.tres")

	# Get spawner reference
	var spawner = $BulletSpawner

	# Attack sequence example
	spawner.set_pattern(fly_pattern)
	spawner.spawn()  # Fast, chaotic flies

	await get_tree().create_timer(2.0).timeout

	spawner.set_pattern(lily_pattern)
	spawner.spawn()  # Slow expanding spiral

	await get_tree().create_timer(3.0).timeout

	spawner.set_pattern(ripple_pattern)
	spawner.spawn()  # Water ripple rings
```

## Visual Theme Summary

- **Fly Swarm**: Dark, small, fast, chaotic - insect aesthetic
- **Lily Pad Spiral**: Green, medium-large, slow, expanding - nature aesthetic
- **Ripple Wave**: Blue, medium, smooth, circular - water aesthetic

Each pattern has distinct visual and mechanical identity suitable for different boss phases or environmental contexts.

## Performance Notes

- **Fly Swarm**: 16 bullets × 3 iterations = 48 bullets (high density)
- **Lily Pad Spiral**: 8 bullets × 3 layers × infinite = continuous spawn (moderate density)
- **Ripple Wave**: 24 bullets × 3 rings = 72 bullets (high density)

All patterns validated against BULLET-004 performance benchmarks (1000+ bullets stable).

## Files Created

```
combat/
  resources/
    bullet_patterns/
      fly_swarm.tres
      lily_pad_spiral.tres
      ripple_wave.tres
    bullets/
      fly_bullet.tres
      lily_pad_bullet.tres
      ripple_bullet.tres

tests/
  integration/
    test_frog_patterns.gd

docs/
  BULLET-005-FROG-PATTERNS.md
```

## Next Steps (BULLET-006+)

- Add particle effects for enhanced visuals
- Implement pattern variants (difficulty scaling)
- Create boss attack sequences combining patterns
- Add sound effects for pattern spawns
- Implement pattern preview system for testing
