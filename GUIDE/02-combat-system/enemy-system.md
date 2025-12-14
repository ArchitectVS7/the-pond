# Enemy System

Enemies swarm. That's the core fantasy - you're surrounded by polluted creatures trying to kill you. The system needs to handle 500+ enemies at 60fps while making each feel like a threat.

---

## Spawn System (COMBAT-005)

**File**: `combat/scripts/enemy_spawner.gd`

### How Spawning Works

Enemies spawn in waves. Each wave increases the spawn rate and introduces new enemy types.

```gdscript
func _physics_process(_delta: float) -> void:
    spawn_timer += _delta

    if spawn_timer >= current_spawn_interval:
        spawn_timer = 0.0
        _spawn_enemy()

    escalation_timer += _delta
    if escalation_timer >= escalation_interval:
        _escalate_difficulty()
```

### Wave Progression

| Wave | Spawn Interval | Enemy Mix |
|------|---------------|-----------|
| 1 | 2.0s | 100% Basic |
| 2 | 1.85s | 70% Basic, 30% Fast |
| 3 | 1.70s | 70% Basic, 30% Fast |
| N | max(0.3s, 2.0 - 0.15×(N-1)) | 70% Basic, 30% Fast |

The spawn interval decreases by 0.15s each wave, bottoming out at 0.3s. This creates a smooth difficulty curve that peaks around wave 12.

### Tunable Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `base_spawn_interval` | 2.0 | 0.5-5.0 | Initial spawn rate |
| `min_spawn_interval` | 0.3 | 0.1-1.0 | Fastest spawn rate |
| `spawn_interval_reduction` | 0.15 | 0.05-0.3 | Reduction per wave |
| `escalation_interval` | 60.0 | 30-120 | Seconds per wave |
| `spawn_radius` | 600.0 | 400-1000 | Spawn distance from center |
| `max_enemies` | 100 | 50-500 | Cap on active enemies |

### Spawn Positioning

Enemies spawn in a ring around the arena center:

```gdscript
func _get_spawn_position() -> Vector2:
    var angle := randf() * TAU  # Random angle 0-2π
    var offset := Vector2.RIGHT.rotated(angle) * spawn_radius
    return arena_center + offset
```

**Why spawn in a ring?**
- Gives the player time to react (enemies must travel to reach them)
- Creates visual variety (enemies come from all directions)
- Prevents "spawn camping" at fixed points

---

## Enemy Types

### Basic Enemy: Polluted Tadpole

**Scene**: `combat/scenes/EnemyBasic.tscn`

| Stat | Value | Notes |
|------|-------|-------|
| `move_speed` | 80 | Slow, steady approach |
| `max_hp` | 1 | One-hit kill |
| `score_value` | 10 | Points on death |
| `contact_damage` | 1 | Damage to player |

The tadpole is the bread-and-butter enemy. It moves directly toward the player with no special behaviors. In large numbers, they create pressure through volume.

### Fast Enemy: Toxic Minnow

**Scene**: `combat/scenes/EnemyFast.tscn`

| Stat | Value | Notes |
|------|-------|-------|
| `move_speed` | 150 | Nearly double basic speed |
| `max_hp` | 1 | Still one-hit kill |
| `score_value` | 15 | Slightly more points |
| `contact_damage` | 1 | Same damage |

The minnow adds tension. It appears in wave 2+ and forces the player to prioritize threats. A swarm of basics is manageable; a fast minnow weaving through them is dangerous.

### Future Enemy Types

| Enemy | Behavior | When Introduced |
|-------|----------|----------------|
| Orbiter | Circles player, shoots | Alpha |
| Splitter | Spawns smaller enemies on death | Alpha |
| Tank | High HP, slow | Beta |
| Bomber | Explodes on death | Beta |

---

## AI Behaviors (COMBAT-006)

**File**: `combat/scripts/enemy_base.gd`

### Behavior Modes

```gdscript
enum BehaviorMode { CHASE, WANDER, ORBIT }
@export var behavior_mode: BehaviorMode = BehaviorMode.CHASE
```

#### CHASE (Default)

```gdscript
func _chase_behavior() -> void:
    var direction := global_position.direction_to(player.global_position)
    velocity = direction * move_speed
```

Simple, direct approach. Used by all MVP enemies.

#### WANDER

```gdscript
func _wander_behavior(delta: float) -> void:
    wander_timer += delta
    if wander_timer >= wander_interval:
        wander_timer = 0.0
        wander_direction = Vector2.RIGHT.rotated(randf() * TAU)

    velocity = wander_direction * wander_speed
```

Random movement, changes direction periodically. Useful for patrol enemies or passive creatures.

#### ORBIT

```gdscript
func _orbit_behavior(delta: float) -> void:
    orbit_angle += angular_speed * delta
    var ideal_pos := player.global_position + Vector2.RIGHT.rotated(orbit_angle) * orbit_distance
    velocity = global_position.direction_to(ideal_pos) * orbit_speed
```

Circles the player at a fixed distance. Used for ranged enemies that shoot while moving.

### Behavior Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `wander_speed` | 40.0 | 20-100 | Speed when wandering |
| `wander_interval` | 1.5 | 0.5-3.0 | Direction change frequency |
| `orbit_distance` | 100.0 | 50-200 | Orbit radius from player |
| `orbit_speed` | 60.0 | 30-120 | Speed when orbiting |

---

## Separation System

Without separation, 500 enemies would stack on top of each other. The separation system pushes them apart.

### How Separation Works

```gdscript
func _apply_separation() -> void:
    if not separation_enabled:
        return

    var push := Vector2.ZERO
    var nearby := spatial_hash.query_radius(global_position, separation_radius)

    for other in nearby:
        if other == self:
            continue
        var distance := global_position.distance_to(other.global_position)
        if distance < separation_radius:
            var away := global_position.direction_to(other.global_position) * -1
            var strength := (separation_radius - distance) / separation_radius
            push += away * strength

    velocity += push * separation_strength
```

### Separation Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `separation_enabled` | true | - | Toggle separation |
| `separation_radius` | 30.0 | 15-50 | Check distance |
| `separation_strength` | 50.0 | 20-100 | Push force |

### Tuning Separation

| Radius | Effect | Use Case |
|--------|--------|----------|
| 15px | Tight swarms | Vampire Survivors style |
| 30px | Readable groups | Default |
| 50px+ | Spread out | When individual enemies matter |

**Lower separation** creates denser swarms. Enemies overlap more, creating visual intensity.

**Higher separation** makes each enemy distinct. Better for games where positioning matters.

---

## Object Pooling (COMBAT-014)

Creating and destroying 500 enemies causes frame drops. Object pooling reuses enemy instances instead.

### Pool Lifecycle

```
Game Start:
1. Create 50 enemies per type (pre-warm)
2. Hide and disable all enemies
3. Store in available pool

Spawn Enemy:
1. Get enemy from pool (or create if empty)
2. Call enemy.reset()
3. Position and enable

Enemy Death:
1. Call enemy.deactivate()
2. Return to available pool
3. Don't queue_free()
```

### Pool Integration

```gdscript
# In EnemySpawner
func _spawn_enemy() -> void:
    var enemy := enemy_pool.acquire(enemy_scene)
    enemy.global_position = _get_spawn_position()
    enemy.reset()

func _on_enemy_died(enemy: Node2D) -> void:
    enemy_pool.release(enemy)
```

### Pool Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `pooling_enabled` | true | - | Toggle pooling |
| `pool_prewarm_count` | 50 | 0-100 | Pre-created enemies |
| `pool_max_size` | 500 | 100-1000 | Maximum pool size |

See [Performance](performance.md) for detailed pooling documentation.

---

## Damage System

### Taking Damage

```gdscript
func take_damage(amount: int) -> void:
    current_hp -= amount
    _flash_white()  # Visual feedback

    if current_hp <= 0:
        die()
```

### Death

```gdscript
func die() -> void:
    emit_signal("died", self)

    if use_pooling:
        # Pool handles deactivation
        return
    else:
        queue_free()
```

### Signals

| Signal | When Emitted | Use |
|--------|--------------|-----|
| `died(enemy)` | HP reaches 0 | Score, feedback, pool return |
| `damaged(enemy, amount)` | Any damage taken | UI feedback |

---

## Collision Setup

### Layer Configuration

```
Enemy (CharacterBody2D)
├── Layer: 3 (Enemies)
├── Mask: 1, 2 (Player, Environment)
└── Collision Shape: Circle
```

Enemies collide with:
- **Player** (layer 1): To deal contact damage
- **Environment** (layer 2): To avoid walking through walls

Enemies don't collide with:
- **Other enemies** (layer 3): Separation handles this more smoothly
- **Player attack** (layer 4): Tongue uses `get_overlapping_bodies()`

---

## Performance Considerations

### Spatial Hash Requirement

Separation requires checking nearby enemies. Without optimization:
```
500 enemies × 500 enemies = 250,000 checks per frame
```

With spatial hash:
```
500 enemies × ~5 neighbors = 2,500 checks per frame
```

See [Spatial Hashing](performance.md#spatial-hashing) for implementation details.

### Process Mode

Enemies use `_physics_process` for movement:

```gdscript
func _physics_process(_delta: float) -> void:
    if not is_active:
        return  # Skip if pooled/inactive

    _update_behavior()
    _apply_separation()
    move_and_slide()
```

The `is_active` check is crucial - pooled enemies shouldn't process.

---

## Debugging

### Visualize Separation

```gdscript
func _draw() -> void:
    draw_circle(Vector2.ZERO, separation_radius, Color(1, 0, 0, 0.2))
```

### Count Enemies

```gdscript
# In EnemySpawner
func get_enemy_count() -> int:
    return get_tree().get_nodes_in_group("enemies").size()
```

### Log Spawns

```gdscript
func _spawn_enemy() -> void:
    print("Spawning enemy. Total: %d" % get_enemy_count())
```

---

## Common Issues

**Enemies stack on each other:**
- Check `separation_enabled` is true
- Verify spatial hash is working
- Increase `separation_strength`

**Frame drops during spawns:**
- Enable object pooling
- Increase `pool_prewarm_count`
- Check for expensive operations in `reset()`

**Enemies move through walls:**
- Check collision mask includes environment layer
- Verify wall collision shapes exist

**Too easy / too hard:**
- Adjust `escalation_interval` for pace
- Adjust `base_spawn_interval` for initial difficulty
- Tweak enemy speeds

---

## Summary

| System | Implementation |
|--------|----------------|
| Spawning | Ring spawn, escalating waves |
| Movement | Chase/Wander/Orbit behaviors |
| Separation | Spatial hash, 30px radius |
| Pooling | Pre-warm 50, max 500 |
| HP | 1 HP (one-hit kills) |

The enemy system is designed for volume. Individual enemies are simple; the challenge comes from managing 500 of them at once.

---

[← Back to Tongue Attack](tongue-attack.md) | [Next: Performance →](performance.md)
