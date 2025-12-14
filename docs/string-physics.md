# String Physics System - BOARD-009

## Overview

The String Physics System provides elastic, spring-based physics simulation for conspiracy board connection strings. Implemented in `StringRenderer`, it creates natural-looking wobble and bounce effects with a 300ms settle time.

## Features

- **Elastic Spring Physics**: Hooke's law-based spring simulation with damping
- **300ms Settle Time**: Tuned for smooth, natural-looking animations
- **Wobble Effects**: Bounce on connection with configurable intensity
- **Stretch Detection**: Automatic wobble trigger when strings stretch beyond limits
- **Performance Optimized**: < 0.5ms per string, tested with 10+ concurrent strings
- **Tunable Parameters**: Full control over physics behavior via exports

## Physics Model

### Spring Dynamics

The system uses a damped spring model:

```
F = -k * x - c * v

Where:
- F = spring force
- k = spring constant (string_stiffness)
- x = displacement from target
- c = damping coefficient (string_damping)
- v = velocity
```

### Settle Criteria

A string is considered "settled" when:
- Velocity < 1.0 pixels/second
- Position within 1.0 pixel of target

With default parameters (stiffness=150, damping=8), this occurs in ~300ms.

## Tunable Parameters

### Physics Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `string_stiffness` | float | 150.0 | Spring constant - higher = stiffer string |
| `string_damping` | float | 8.0 | Damping coefficient - higher = faster settle |
| `settle_time` | float | 0.3 | Target settle duration (reference only) |
| `max_stretch` | float | 1.5 | Max stretch ratio before triggering wobble |
| `physics_enabled` | bool | true | Enable/disable physics simulation |

### Visual Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `string_width` | float | 2.0 | Line thickness in pixels |
| `string_color` | Color | RED | Connection string color |
| `string_segments` | int | 20 | Bezier curve subdivision count |
| `bezier_curve_amount` | float | 50.0 | Base curve height offset |

## Usage Examples

### Basic Setup

```gdscript
# Create string renderer
var string = StringRenderer.new()
add_child(string)

# Set endpoints
string.set_endpoints(Vector2(0, 0), Vector2(200, 100))

# Trigger wobble on connection
string.trigger_wobble(30.0)
```

### Custom Physics Tuning

```gdscript
# Stiff, fast-settling string
string.string_stiffness = 300.0
string.string_damping = 15.0

# Loose, slow-bouncing string
string.string_stiffness = 75.0
string.string_damping = 4.0
```

### Performance Mode

```gdscript
# Disable physics for static strings
string.physics_enabled = false

# Force immediate settle (skip animation)
string.force_settle()
```

### Signal Handling

```gdscript
# React to physics events
string.string_settled.connect(func():
    print("String has settled")
)

string.string_wobbled.connect(func(intensity):
    print("String wobbled with intensity: ", intensity)
)
```

## API Reference

### Methods

#### `trigger_wobble(intensity: float = 30.0)`
Triggers a wobble/bounce effect by adding velocity to the spring system.

**Parameters:**
- `intensity`: Wobble intensity in pixels per second (default: 30.0)

**Example:**
```gdscript
string.trigger_wobble(50.0)  # Strong wobble
```

#### `is_physics_settled() -> bool`
Checks if physics have settled within thresholds.

**Returns:** `true` if settled, `false` if still animating

**Example:**
```gdscript
if string.is_physics_settled():
    print("Animation complete")
```

#### `force_settle()`
Forces physics to settle immediately, skipping animation.

**Example:**
```gdscript
string.force_settle()  # Instant settle
```

#### `get_average_performance() -> float`
Gets average processing time in milliseconds.

**Returns:** Average physics process time over last 60 samples

**Example:**
```gdscript
var avg_ms = string.get_average_performance()
print("Average: ", avg_ms, "ms")
```

#### `get_physics_state() -> Dictionary`
Gets current physics state for debugging.

**Returns:** Dictionary with keys:
- `current_offset`: Current curve offset
- `target_offset`: Target curve offset
- `velocity`: Current velocity
- `is_settled`: Settlement state
- `string_length`: Distance between endpoints
- `avg_performance_ms`: Average performance
- `physics_enabled`: Physics enable state

**Example:**
```gdscript
var state = string.get_physics_state()
print("Velocity: ", state.velocity)
```

### Signals

#### `string_settled()`
Emitted when physics settle within threshold.

```gdscript
string.string_settled.connect(func():
    print("String settled")
)
```

#### `string_wobbled(intensity: float)`
Emitted when wobble is triggered.

**Parameters:**
- `intensity`: The wobble intensity used

```gdscript
string.string_wobbled.connect(func(intensity):
    print("Wobbled: ", intensity)
)
```

## Performance Characteristics

### Benchmarks (60 FPS)

- **Single String**: ~0.05ms average
- **10 Strings**: ~0.5ms average (< 2ms total frame time)
- **Memory**: ~1KB per string instance

### Optimization Tips

1. **Disable for Static Strings**: Set `physics_enabled = false` for non-animated strings
2. **Reduce Segments**: Lower `string_segments` for distant/small strings
3. **Force Settle**: Use `force_settle()` when instant positioning is acceptable
4. **Batch Updates**: Update multiple strings in same frame

## Physics Tuning Guide

### Settle Time Tuning

To achieve different settle times:

| Target Time | Stiffness | Damping |
|-------------|-----------|---------|
| 150ms (fast) | 300.0 | 15.0 |
| 300ms (default) | 150.0 | 8.0 |
| 500ms (slow) | 75.0 | 4.0 |
| 1000ms (very slow) | 40.0 | 2.0 |

### Bounce Behavior

Control bounce/oscillation amount:

| Behavior | Stiffness | Damping |
|----------|-----------|---------|
| No bounce (critical damping) | 150.0 | 15.0+ |
| Light bounce | 150.0 | 8.0 |
| Medium bounce | 150.0 | 5.0 |
| Heavy bounce | 150.0 | 2.0 |

## Testing

Run the test suite to verify physics behavior:

```bash
# Run all string physics tests
godot --headless -s addons/gut/gut_cmdln.gd -gtest=test_string_physics.gd

# Run specific test
godot --headless -s addons/gut/gut_cmdln.gd -gtest=test_string_physics.gd -gunit_test_name=test_string_settles_300ms
```

### Key Test Cases

- `test_string_stretches`: Validates length changes
- `test_string_settles_300ms`: Validates settle time ±150ms
- `test_string_bounces`: Validates wobble effects
- `test_performance_with_10_strings`: Validates performance requirements

## Implementation Details

### Physics Loop

The `_physics_process(delta)` method:

1. Calculates displacement from target
2. Applies spring force: `F = k * displacement`
3. Adds force to velocity: `v += F * delta`
4. Applies damping: `v *= (1 - c * delta)`
5. Updates position: `offset += v * delta`
6. Checks settle condition
7. Updates visual curve

### Stretch Detection

Automatic wobble triggering on excessive stretch:

```gdscript
var distance = start_point.distance_to(end_point)
if _last_distance > 0:
    var stretch_ratio = distance / _last_distance
    if stretch_ratio > max_stretch:
        trigger_wobble(30.0)
```

## Dependencies

- **BOARD-008**: Base bezier curve rendering system
- Godot 4.x: `Line2D`, `Vector2`, physics timing
- GUT: Test framework for validation

## Future Enhancements

- [ ] Cable sag physics (gravity)
- [ ] Wind/environmental forces
- [ ] Collision detection
- [ ] Multi-segment chains
- [ ] Texture animation along curve

## Troubleshooting

### String doesn't settle
- Increase `string_damping` for faster settle
- Check that `physics_enabled = true`
- Verify no continuous position updates

### Performance issues
- Reduce `string_segments` count
- Disable physics on off-screen strings
- Use `force_settle()` for instant updates

### Too stiff/too loose
- Adjust `string_stiffness` (higher = stiffer)
- Tune `string_damping` (higher = less bounce)

## References

- [Hooke's Law](https://en.wikipedia.org/wiki/Hooke%27s_law)
- [Damped Harmonic Oscillator](https://en.wikipedia.org/wiki/Harmonic_oscillator#Damped_harmonic_oscillator)
- [Godot Line2D Documentation](https://docs.godotengine.org/en/stable/classes/class_line2d.html)
