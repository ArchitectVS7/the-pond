# Combat System Overview

The Pond is a bullet hell roguelike. Combat is the core loop - you move, you attack, enemies swarm, you survive or you don't. This chapter covers everything that makes that loop feel good.

---

## The Core Loop

```
Move → Aim → Attack → Kill → Dodge → Repeat
```

Every system in this chapter serves that loop:
- **Player movement** needs to be responsive (200 px/s, 16ms input lag)
- **Tongue attack** needs to feel satisfying (elastic physics, 3-tile range)
- **Enemies** need to threaten without overwhelming (spatial hashing, escalating spawns)
- **Feedback** needs to communicate everything (screen shake, particles, hit-stop, audio)

---

## What's Here

| File | What It Covers |
|------|----------------|
| [Player Controller](player-controller.md) | Movement, aim system, input handling |
| [Tongue Attack](tongue-attack.md) | Whip mechanic, elastic physics, damage |
| [Enemy System](enemy-system.md) | Spawning, AI behaviors, enemy types |
| [Performance](performance.md) | Spatial hashing, object pooling, 60fps validation |
| [Game Feel](game-feel.md) | Screen shake, particles, hit-stop, audio |
| [Tunable Parameters](tunable-parameters.md) | Every `@export` variable in one place |

---

## PRD Requirements

The Product Requirements Document sets hard targets:

| Metric | Target | Implementation |
|--------|--------|----------------|
| Minimum FPS | 60 | GTX 1060 @ 1080p |
| Input lag | <16ms | 1 frame at 60fps |
| Enemies on screen | 500+ | Object pooling, spatial hash |
| Bullets on screen | 500+ | BulletUpHell plugin |
| Tongue range | 3 tiles | 144 pixels (48px/tile) |

Every implementation detail traces back to these requirements.

---

## File Structure

```
combat/
├── scenes/
│   ├── Arena.tscn           # Main combat scene
│   ├── Player.tscn          # Player character
│   ├── EnemyBasic.tscn      # Polluted Tadpole
│   └── EnemyFast.tscn       # Toxic Minnow
├── scripts/
│   ├── player_controller.gd  # Movement, aim
│   ├── tongue_attack.gd      # Attack mechanics
│   ├── enemy_base.gd         # Enemy behaviors
│   ├── enemy_spawner.gd      # Spawn system
│   └── spatial_hash.gd       # Collision optimization
└── resources/
    └── bullet_patterns/      # BulletUpHell patterns
```

---

## Key Systems

### Movement (COMBAT-001, 002)

The player is a CharacterBody2D with simple 4-direction movement. Aim follows the mouse cursor. No acceleration or momentum - instant response is the priority.

**Why instant response?** In bullet hells, the player needs frame-perfect control. Adding inertia feels "floaty" and makes dodging impossible. The 200 px/s speed is fast enough to dodge but slow enough to thread between bullets.

### Tongue Attack (COMBAT-003, 004)

The tongue is the player's only attack. It extends, hits enemies in range, and retracts. The "elastic physics" add game feel without affecting gameplay - the tongue overshoots slightly then bounces back.

**Why elastic?** A linear tongue extension feels mechanical. The overshoot and snap-back feel alive, like an actual frog tongue. It's purely visual feedback - the hitbox is still the same.

### Enemy System (COMBAT-005, 006)

Enemies spawn in escalating waves. Basic enemies (Polluted Tadpole) move slowly toward the player. Fast enemies (Toxic Minnow) appear in later waves. All enemies use simple chase behavior with separation to avoid stacking.

**Why separation?** Without it, 500 enemies would occupy the same pixel. The spatial hash makes separation efficient (O(n*k) instead of O(n²)).

### Feedback Systems (COMBAT-008 through 011)

Every kill triggers:
1. **Screen shake** - Camera offset based on trauma
2. **Particles** - Visual burst at death position
3. **Hit-stop** - 2-frame freeze for impact
4. **Audio** - "Glorp" sound effect

**Why all four?** Any one of these alone feels weak. Together, they create the "juice" that makes combat satisfying. Each can be toggled for accessibility.

---

## Sidebars

These short explanations help you understand the concepts:

| Sidebar | Topic |
|---------|-------|
| [What is Spatial Hashing?](sidebars/what-is-spatial-hashing.md) | Grid-based collision optimization |
| [Object Pooling Explained](sidebars/object-pooling.md) | Reusing objects to avoid allocations |
| [Trauma-Based Screen Shake](sidebars/trauma-screen-shake.md) | How the trauma system creates natural shake decay |
| [Hit-Stop and Game Feel](sidebars/hit-stop-game-feel.md) | Why 2-frame freezes make combat feel impactful |

---

## Story Traceability

| Story | Description | Files |
|-------|-------------|-------|
| COMBAT-001 | Player movement | `player_controller.gd` |
| COMBAT-002 | Mouse aim system | `player_controller.gd` |
| COMBAT-003 | Tongue attack | `tongue_attack.gd` |
| COMBAT-004 | Elastic physics | `tongue_attack.gd` |
| COMBAT-005 | Enemy spawning | `enemy_spawner.gd` |
| COMBAT-006 | Enemy AI | `enemy_base.gd` |
| COMBAT-007 | Spatial hash | `spatial_hash.gd` |
| COMBAT-008 | Screen shake | `screen_shake.gd` |
| COMBAT-009 | Particles | `particle_manager.gd` |
| COMBAT-010 | Hit-stop | `hit_stop.gd` |
| COMBAT-011 | Audio | `audio_manager.gd` |
| COMBAT-012 | Performance monitoring | `performance_monitor.gd` |
| COMBAT-013 | Input lag validation | `input_latency_monitor.gd` |
| COMBAT-014 | Object pooling | `object_pool.gd` |

---

## Quick Start

**Want to tweak movement speed?**
→ Open `player_controller.gd`, find `@export var move_speed: float = 200.0`

**Want to make the tongue longer?**
→ Open `tongue_attack.gd`, find `@export var max_range: float = 144.0`

**Want more enemies?**
→ Open `enemy_spawner.gd`, find `@export var max_enemies: int = 100`

**Want more intense screen shake?**
→ Open `screen_shake.gd`, find `@export var base_intensity: float = 1.0`

All tunable parameters are documented in [Tunable Parameters](tunable-parameters.md).

---

[Back to Index](../index.md) | [Next: Player Controller →](player-controller.md)
