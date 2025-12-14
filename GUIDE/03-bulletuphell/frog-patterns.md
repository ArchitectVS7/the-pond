# Frog Patterns

The MVP patterns (radial, spiral, aimed) are generic. This chapter covers frog-themed patterns that fit The Pond's aesthetic. These are planned for Alpha development.

---

## Design Philosophy

The Pond is about a frog uncovering corporate pollution. Bullet patterns should reinforce this:

- **Organic shapes**: Ripples, bubbles, lily pads
- **Environmental themes**: Toxic splashes, pollution clouds
- **Frog abilities**: Tongue-like patterns, hop mechanics

Patterns shouldn't just be geometric - they should feel like they belong in a polluted pond.

---

## Planned Patterns

### Fly Swarm

Small bullets with random offsets, simulating a swarm of flies.

**Concept**:
```
    ·   ·
  ·   ·   ·
    ·   ·
```

**Implementation sketch**:
```gdscript
var pattern := PatternCircle.new()
pattern.bullet = "fly_bullet"
pattern.nbr = 12
pattern.radius = randf_range(10, 30)  # Random spawn radius
# Add velocity noise to each bullet post-spawn
```

**Characteristics**:
- Small sprites (8x8 pixels)
- Erratic movement (velocity noise)
- High count, low damage
- Buzzing visual feel

### Lily Pad Spiral

Slow-moving green bullets expanding outward like ripples from a lily pad.

**Concept**:
```
      ○
    ○   ○
  ○   ●   ○
    ○   ○
      ○
```

**Implementation sketch**:
```gdscript
var bullet := BuHBullet.new()
bullet.sprite = preload("res://assets/sprites/lilypad_bullet.png")
bullet.speed = 80.0  # Slow
bullet.scale_over_time = 1.2  # Grows slightly

var pattern := PatternCircle.new()
pattern.bullet = "lilypad_bullet"
pattern.nbr = 6
pattern.iterations = -1
pattern.cooldown_spawn = 0.5
pattern.layer_angle_offset = deg_to_rad(30)
```

**Characteristics**:
- Green color palette
- Slow, predictable movement
- Larger hitboxes
- Zen-like aesthetic

### Ripple Wave

Concentric rings expanding from a point, like ripples in water.

**Concept**:
```
         ○ ○ ○
       ○       ○
      ○         ○
       ○       ○
         ○ ○ ○
```

**Implementation sketch**:
```gdscript
func spawn_ripple() -> void:
    for i in range(5):  # 5 rings
        await get_tree().create_timer(0.2 * i).timeout
        var pattern := PatternCircle.new()
        pattern.bullet = "water_bullet"
        pattern.nbr = 12 + (i * 4)  # More bullets per ring
        pattern.radius = 0
        Spawning.spawn(self, "ripple_" + str(i), "0")
```

**Characteristics**:
- Multiple rings with increasing density
- Uniform expansion speed
- Blue/gray color (polluted water)
- Predictable timing for dodging

### Toxic Splash

Bullets that arc and fall, simulating toxic liquid being thrown.

**Concept**:
```
    \   |   /
     \  |  /
      \ | /
       \|/
        ●
```

**Implementation notes**:
- Requires gravity-affected bullets
- BulletUpHell supports acceleration
- Splatter pattern on "impact"

### Bubble Stream

Rising bullets that wobble side-to-side.

**Concept**:
```
  ○     ○
    ○     ○
  ○     ○
    ○     ○
```

**Implementation notes**:
- Sinusoidal X velocity
- Slow upward movement
- Pop particles on destruction

---

## Boss-Specific Patterns

### The Lobbyist

Corporate-themed attacks:

**Document Storm**: Papers flying in chaotic patterns
- Rectangle sprites
- Spinning rotation
- Random velocity angles

**Red Tape**: Horizontal lines of bullets
- PatternLine
- Sweep across arena
- Must jump through gaps

### The CEO

Money-themed attacks:

**Golden Rain**: Coins falling from above
- Gravity-affected
- High density
- Spawn from top of screen

**Stock Crash**: Downward diagonal lines
- Multiple PatternLines
- Varying angles
- Red color (losses)

### The Researcher

Science-themed attacks:

**Chemical Reaction**: Expanding colored rings
- Multi-colored bullets
- Ring + cross patterns
- Color-coded safe zones

**Lab Accident**: Random toxic splashes
- Unpredictable positions
- Warning indicators before spawn

### The Sentient Pond

Nature-corrupted attacks:

**Awakening**: Massive ripple waves
- Slow, huge rings
- Requires precise movement
- Environmental storytelling

---

## Creating Thematic Bullets

### Sprite Design

| Pattern | Size | Shape | Color |
|---------|------|-------|-------|
| Fly | 8x8 | Circle | Brown/black |
| Lily pad | 16x16 | Hexagon | Green |
| Water | 12x12 | Circle | Blue-gray |
| Toxic | 12x12 | Blob | Green/purple |
| Bubble | 10x10 | Circle | Transparent |

### Visual Effects

Add particles to bullets for atmosphere:
```gdscript
# Trailing particles
var bullet := BuHBullet.new()
bullet.trail_enabled = true
bullet.trail_color = Color(0.2, 0.8, 0.2, 0.5)  # Green trail
```

### Sound Design

Each pattern type should have distinct audio:
- Flies: Buzzing
- Water: Splash, drip
- Toxic: Sizzle
- Bubbles: Pop

---

## Pattern Difficulty Scaling

Patterns should scale with game progression:

### Wave 1-3 (Introduction)
- Slow patterns
- Wide gaps
- Single pattern type at a time

### Wave 4-7 (Escalation)
- Faster patterns
- Tighter gaps
- Combined patterns

### Wave 8+ (Challenge)
- Maximum speed
- Minimal gaps
- Multiple overlapping patterns

### Boss Encounters
- Unique patterns
- Phase-based complexity
- Learnable tells

---

## Implementation Priority

For Alpha development:

| Priority | Pattern | Difficulty |
|----------|---------|------------|
| 1 | Ripple Wave | Medium |
| 2 | Fly Swarm | Easy |
| 3 | Lily Pad Spiral | Easy |
| 4 | Toxic Splash | Hard (gravity) |
| 5 | Bubble Stream | Medium |

Start with Ripple Wave - it's visually impressive and uses existing PatternCircle capabilities.

---

## Testing New Patterns

1. Create bullet resource with placeholder sprite
2. Create pattern resource
3. Test in BulletPatternTest scene
4. Adjust timing, speed, count
5. Add final art and effects
6. Integrate with enemies/bosses

```gdscript
# Quick test setup
func _ready() -> void:
    # Placeholder bullet
    var bullet := BuHBullet.new()
    bullet.sprite = preload("res://icon.svg")  # Use any texture
    bullet.speed = 100.0
    Spawning.new_bullet("test_bullet", bullet)

    # Test pattern
    var pattern := PatternCircle.new()
    pattern.bullet = "test_bullet"
    pattern.nbr = 8
    Spawning.new_pattern("test_pattern", pattern)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        Spawning.spawn(self, "test_pattern", "0")
```

---

## Summary

| Theme | Patterns | Visual Style |
|-------|----------|--------------|
| Nature | Ripple, Lily Pad, Bubble | Organic, flowing |
| Pollution | Toxic Splash, Fly Swarm | Chaotic, threatening |
| Corporate | Document Storm, Red Tape | Geometric, oppressive |
| Science | Chemical, Lab Accident | Colorful, dangerous |

Frog patterns aren't just gameplay - they're storytelling. Each pattern reinforces the environmental narrative.

---

[← Back to Pattern System](pattern-system.md) | [Next: Performance Tuning →](performance-tuning.md)
