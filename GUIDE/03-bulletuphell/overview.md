# BulletUpHell Overview

The Pond uses the BulletUpHell plugin for bullet patterns. This isn't custom code - it's an established Godot plugin optimized for danmaku (bullet hell) games. This chapter covers how we use it.

---

## Why BulletUpHell?

Building a bullet system from scratch requires:
- Object pooling for 500+ bullets
- Efficient collision detection
- Pattern definition system
- Performance optimization

BulletUpHell provides all of this. The plugin uses RID-based pooling through PhysicsServer2D, achieving better performance than Node2D-based alternatives.

---

## What's Here

| File | What It Covers |
|------|----------------|
| [Pattern System](pattern-system.md) | How patterns work, creating new ones |
| [Frog Patterns](frog-patterns.md) | Thematic patterns for The Pond |
| [Performance Tuning](performance-tuning.md) | Pooling, optimization, 500 bullet target |

---

## Plugin Structure

BulletUpHell adds these to your project:

```
addons/BulletUpHell/
├── BuHSpawner.gd          # Main spawning system (autoload)
├── BuHSharedArea.gd       # Collision grouping
├── resources/
│   ├── BuHBullet.gd       # Bullet definition
│   └── BuHPattern.gd      # Pattern definition
└── ExampleScenes/          # Reference implementations
```

---

## Core Concepts

### Spawning (Autoload)

The `Spawning` autoload manages all bullets. You don't create bullets directly - you tell Spawning to spawn patterns.

```gdscript
# Spawn a pattern
Spawning.spawn(self, "radial_8way", "0")
#              ↑      ↑             ↑
#           spawner  pattern ID   shared area
```

### Bullets

Bullets are defined as resources, not scenes. This is why they're fast.

```gdscript
# Register a bullet type
var bullet := BuHBullet.new()
bullet.sprite = preload("res://assets/sprites/bullet.png")
bullet.speed = 200.0
bullet.damage = 1
Spawning.new_bullet("my_bullet", bullet)
```

### Patterns

Patterns define how bullets spawn: direction, count, timing, rotation.

```gdscript
# Register a pattern
var pattern := PatternCircle.new()
pattern.bullet = "my_bullet"
pattern.nbr = 8  # 8 bullets in circle
Spawning.new_pattern("radial_8way", pattern)

# Spawn it
Spawning.spawn(self, "radial_8way", "0")
```

### Shared Areas

SharedArea nodes group bullets for collision detection. All bullets in the same SharedArea share a single Area2D, improving performance.

```gdscript
# Create SharedArea in scene tree
SharedArea (name: "0")
├── Enemies use this for their bullets
└── All bullets collide with player

SharedArea (name: "1")
├── Different collision behavior
└── Boss-specific bullets
```

---

## The Three Patterns (BULLET-003)

MVP implements three foundational patterns:

### 1. Radial 8-Way

Bullets spawn in a circle, spreading outward.

```
    ↑
  ↖ ↑ ↗
← ● ● ● →
  ↙ ↓ ↘
    ↓
```

**Use**: Death explosions, area denial, boss transitions

### 2. Spiral Clockwise

Rotating continuous fire. Each wave is offset from the last.

```
Wave 1: →
Wave 2:  ↘
Wave 3:   ↓
Wave 4:    ↙
...
```

**Use**: Turrets, rotating hazards, boss continuous fire

### 3. Aimed Single

Single bullet targeting the player (or mouse).

```
[Enemy] ───────→ [Player]
```

**Use**: Sniper enemies, telegraphed attacks

---

## Quick Start

### Spawning a Pattern

```gdscript
func _ready() -> void:
    # Patterns are already registered by the test scene
    pass

func attack() -> void:
    Spawning.spawn(self, "radial_8way", "0")
```

### Creating a Custom Pattern

```gdscript
func _ready() -> void:
    # 1. Create bullet
    var bullet := BuHBullet.new()
    bullet.sprite = preload("res://assets/sprites/bullet.png")
    bullet.speed = 150.0
    Spawning.new_bullet("slow_bullet", bullet)

    # 2. Create pattern
    var pattern := PatternCircle.new()
    pattern.bullet = "slow_bullet"
    pattern.nbr = 12
    pattern.angle_total = TAU  # Full circle
    Spawning.new_pattern("slow_radial", pattern)

func attack() -> void:
    Spawning.spawn(self, "slow_radial", "0")
```

### Pre-Warming the Pool

```gdscript
func _ready() -> void:
    # Pre-create 200 bullets to avoid allocation during gameplay
    Spawning.create_pool("basic_bullet", "0", 200)
```

---

## Performance at a Glance

| Metric | Target | Method |
|--------|--------|--------|
| Bullets on screen | 500+ | RID-based pooling |
| Spawn time | <0.01ms | Pre-warmed pools |
| Frame drops | 0 | Zero allocations |

BulletUpHell achieves this through:
- **RID pooling**: Uses PhysicsServer2D directly, not Node2D
- **Batch rendering**: All bullets of same type in one draw call
- **Culling**: Off-screen bullets automatically removed

---

## Story Traceability

| Story | Description | Files |
|-------|-------------|-------|
| BULLET-001 | BulletUpHell integration | Plugin setup |
| BULLET-002 | SharedArea configuration | Scene setup |
| BULLET-003 | Basic patterns | Pattern resources |
| BULLET-004 | 500 bullet validation | Performance tests |
| BULLET-005 | Frog-themed patterns | `frog_patterns/` |
| BULLET-006 | Bullet pooling | Pool configuration |

---

## Resources

- **Plugin Source**: `addons/BulletUpHell/`
- **Example Scenes**: `addons/BulletUpHell/ExampleScenes/`
- **Pattern Resources**: `combat/resources/bullet_patterns/`
- **Test Scene**: `combat/scenes/BulletPatternTest.tscn`

---

[Back to Index](../index.md) | [Next: Pattern System →](pattern-system.md)
