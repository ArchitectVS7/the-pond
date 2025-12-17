# Frog Pattern Usage Guide

Quick reference for using the custom frog-themed bullet patterns in The Pond.

## Quick Start

```gdscript
extends Node2D

# Load patterns
const FLY_SWARM = preload("res://combat/resources/bullet_patterns/fly_swarm.tres")
const LILY_PAD = preload("res://combat/resources/bullet_patterns/lily_pad_spiral.tres")
const RIPPLE = preload("res://combat/resources/bullet_patterns/ripple_wave.tres")

func _ready():
    var spawner = $BulletSpawner
    spawner.set_pattern(FLY_SWARM)
    spawner.spawn()
```

## Pattern Comparison

| Pattern | Speed | Size | Bullets | Use Case |
|---------|-------|------|---------|----------|
| Fly Swarm | Fast (250) | Small (0.5x) | 48 | Chaotic pressure |
| Lily Pad | Slow (50) | Large (1.2x) | Continuous | Area denial |
| Ripple Wave | Medium (120) | Medium (0.8x) | 72 | Timed dodging |

## Boss Attack Examples

### Phase 1: Warm-up (Flies)
```gdscript
func phase_1_attack():
    spawner.set_pattern(FLY_SWARM)
    spawner.spawn()
    # Fast, easy to read, teaches movement
```

### Phase 2: Pressure (Lily Pads)
```gdscript
func phase_2_attack():
    spawner.set_pattern(LILY_PAD)
    spawner.spawn()
    # Slow but persistent, requires positioning
```

### Phase 3: Precision (Ripples)
```gdscript
func phase_3_attack():
    spawner.set_pattern(RIPPLE)
    spawner.spawn()
    # Timed waves, requires rhythm
```

### Phase 4: Combination (All Three)
```gdscript
func phase_4_attack():
    # Chaos: all patterns at once
    spawner1.set_pattern(FLY_SWARM)
    spawner2.set_pattern(LILY_PAD)
    spawner3.set_pattern(RIPPLE)

    spawner1.spawn()
    await get_tree().create_timer(0.5).timeout
    spawner2.spawn()
    await get_tree().create_timer(0.5).timeout
    spawner3.spawn()
```

## Tuning for Difficulty

### Easy Mode
```gdscript
# Modify pattern before spawning
var pattern = FLY_SWARM.duplicate()
pattern.nbr = 8  # Fewer bullets
pattern.cooldown_spawn = 0.3  # Slower spawn
spawner.set_pattern(pattern)
```

### Hard Mode
```gdscript
var pattern = RIPPLE.duplicate()
pattern.nbr = 32  # More bullets per ring
pattern.cooldown_spawn = 0.3  # Faster rings
spawner.set_pattern(pattern)
```

## Visual Customization

### Changing Colors
```gdscript
# Modify bullet properties
var bullet = load("res://combat/resources/bullets/fly_bullet.tres").duplicate()
bullet.spec_trail_modulate = Color(1, 0, 0, 1)  # Red flies
spawner.set_bullet(bullet)
```

### Changing Speed
```gdscript
var bullet = LILY_PAD_BULLET.duplicate()
bullet.speed = 100.0  # Faster expansion
spawner.set_bullet(bullet)
```

## Pattern Behavior Reference

### Fly Swarm
- **Spawns**: 3 bursts of 16 bullets
- **Timing**: 0.15s between bursts
- **Movement**: Erratic sinusoidal
- **Best for**: Overwhelming the player, testing reflexes

### Lily Pad Spiral
- **Spawns**: Continuous (infinite iterations)
- **Timing**: 0.2s base, 0.1s per layer
- **Movement**: Expanding spiral, slows per layer
- **Best for**: Area control, forcing movement

### Ripple Wave
- **Spawns**: 3 rings of 24 bullets
- **Timing**: 0.5s between rings
- **Movement**: Radial expansion
- **Best for**: Rhythm challenges, gap-finding

## Common Patterns

### Alternating Attack
```gdscript
func alternating_attack():
    var patterns = [FLY_SWARM, LILY_PAD, RIPPLE]
    var index = 0

    while attacking:
        spawner.set_pattern(patterns[index])
        spawner.spawn()
        index = (index + 1) % patterns.size()
        await get_tree().create_timer(2.0).timeout
```

### Directional Spray
```gdscript
func directional_spray():
    var pattern = FLY_SWARM.duplicate()
    pattern.pattern_angle = deg_to_rad(angle_to_player)
    pattern.forced_pattern_lookat = false
    spawner.set_pattern(pattern)
```

### Ring Defense
```gdscript
func create_ring_defense():
    # Multiple ripple spawners in circle
    for i in range(4):
        var spawner = spawners[i]
        var pattern = RIPPLE.duplicate()
        pattern.pattern_angle = deg_to_rad(90 * i)
        spawner.set_pattern(pattern)
        spawner.spawn()
```

## Performance Tips

1. **Reuse Patterns**: Preload once, use many times
2. **Limit Concurrent**: Max 3 active patterns for 60 FPS
3. **Cleanup**: Set `death_after_time` appropriately
4. **Pool Bullets**: BulletUpHell handles pooling automatically

## Debugging

### Visualize Spawn Points
```gdscript
func _draw():
    # Draw spawner positions
    for spawner in get_children():
        draw_circle(spawner.position, 10, Color.RED)
```

### Count Active Bullets
```gdscript
func _process(_delta):
    var count = get_tree().get_nodes_in_group("bullets").size()
    print("Active bullets: ", count)
```

### Test Pattern Timing
```gdscript
func test_timing():
    var start = Time.get_ticks_msec()
    spawner.set_pattern(RIPPLE)
    spawner.spawn()
    spawner.finished.connect(func():
        var duration = Time.get_ticks_msec() - start
        print("Pattern duration: ", duration, "ms")
    )
```

## Integration Checklist

- [ ] Load pattern resource
- [ ] Assign to spawner
- [ ] Set spawner position
- [ ] Call spawn()
- [ ] Handle bullet collision (if needed)
- [ ] Set cleanup timing
- [ ] Test performance

## Troubleshooting

**Bullets not spawning**:
- Check Spawning autoload is enabled
- Verify pattern resource path
- Ensure spawner is added to scene tree

**Performance issues**:
- Reduce bullet count (`pattern.nbr`)
- Increase spawn cooldown
- Limit concurrent patterns

**Unexpected behavior**:
- Verify `forced_pattern_lookat` setting
- Check angle_total (should be ~6.28 for circles)
- Review randomization parameters

## Advanced: Custom Variants

### Homing Flies
```gdscript
var bullet = FLY_BULLET.duplicate()
bullet.homing_type = 1  # Track player
bullet.homing_steer = 0.5
bullet.homing_duration = 2.0
```

### Bouncing Ripples
```gdscript
var bullet = RIPPLE_BULLET.duplicate()
bullet.spec_bounces = 2
```

### Giant Lily Pads
```gdscript
var bullet = LILY_PAD_BULLET.duplicate()
bullet.scale = 2.0
bullet.damage = 4.0
```

---

**See Also**:
- `BULLET-005-FROG-PATTERNS.md` - Technical documentation
- `test_frog_patterns.gd` - Test examples
- BulletUpHell documentation - Plugin reference
