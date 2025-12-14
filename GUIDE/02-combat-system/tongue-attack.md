# Tongue Attack

The tongue is your only weapon. It extends, hits enemies, retracts. Three tiles of range, ~1.8 attacks per second. The elastic physics make it feel alive.

---

## Core Mechanics (COMBAT-003)

**File**: `combat/scripts/tongue_attack.gd`

### The Attack Cycle

```
IDLE → EXTENDING → RETRACTING → IDLE
         ↓            ↓
    hits enemies   cooldown starts
```

1. Player presses attack
2. Tongue extends over `extend_duration` (0.15s)
3. Tongue retracts over `retract_duration` (0.1s)
4. Cooldown prevents next attack for `attack_cooldown` (0.3s)

**Total attack time**: 0.15 + 0.1 = 0.25 seconds
**Attacks per second**: 1 / (0.25 + 0.3) ≈ 1.8

### Tunable Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `base_damage` | 1 | 1-10 | Damage per hit |
| `attack_cooldown` | 0.3 | 0.1-1.0 | Seconds between attacks |
| `extend_duration` | 0.15 | 0.05-0.5 | Seconds to extend |
| `retract_duration` | 0.1 | 0.05-0.3 | Seconds to retract |
| `max_range` | 144.0 | 48-288 | Maximum length in pixels |

### Range Explained

```
max_range = 144 pixels
tile_size = 48 pixels
range_in_tiles = 144 / 48 = 3 tiles
```

The PRD specifies 3-tile range. At 48 pixels per tile, that's 144 pixels. This is a balance point:
- **Shorter** (2 tiles): More risk, need to get closer to enemies
- **Longer** (4 tiles): Safer, but less tension

---

## Elastic Physics (COMBAT-004)

The tongue doesn't extend linearly - it overshoots then snaps back. This is purely visual feel, not gameplay-affecting.

### How Overshoot Works

```gdscript
# During extension
var progress := time_elapsed / extend_duration
var effective_range := max_range * (1.0 + extend_overshoot)
var current_length := lerp(0.0, effective_range, ease_out_elastic(progress))
```

At default settings:
- `max_range` = 144 pixels
- `extend_overshoot` = 0.15 (15%)
- Effective range = 144 × 1.15 = 165.6 pixels

The tongue extends to 165.6 pixels, then settles to 144 pixels.

### Tunable Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `extend_overshoot` | 0.15 | 0.0-0.5 | Extra extension before settle |
| `elastic_strength` | 2.0 | 1.0-5.0 | Bounce intensity |
| `retract_snap` | 2.5 | 1.0-4.0 | How fast retract starts |

### What Each Parameter Does

#### `extend_overshoot`

Controls how far past `max_range` the tongue goes before settling:

| Value | Effect | Feel |
|-------|--------|------|
| 0.0 | No overshoot | Linear, mechanical |
| 0.1 | Subtle | Slight whip |
| 0.15 | Default | Noticeable whip |
| 0.3+ | Exaggerated | Cartoon physics |

**When to change**: Increase for more dramatic "whip crack". Decrease if mutations need exact range control.

#### `elastic_strength`

Controls the springiness of the settle:

| Value | Effect | Feel |
|-------|--------|------|
| 1.0 | Minimal bounce | Almost linear |
| 2.0 | Default | Natural elastic |
| 3.0-5.0 | Exaggerated | Wobbly |

**When to change**: Increase for cartoony feel. Decrease for snappier attacks.

#### `retract_snap`

Controls retraction curve - how much of the retract happens early:

| Value | Effect | Feel |
|-------|--------|------|
| 1.0 | Linear | Constant speed |
| 2.0 | Moderate | Starts fast, slows |
| 2.5 | Default | 80% in first half |
| 4.0 | Extreme | Near-instant start |

**When to change**: Increase for punchier feel. Pairs well with screen shake.

### Disabling Elastic Physics

Set all elastic parameters to their "off" values:
```gdscript
extend_overshoot = 0.0
elastic_strength = 1.0
retract_snap = 1.0
```

This gives linear extend/retract behavior.

---

## Hit Detection

### Area2D Setup

```
TongueAttack (Node2D)
└── HitArea (Area2D)
    ├── Layer: 4 (PlayerAttack)
    ├── Mask: 3 (Enemies)
    └── CollisionShape2D: Rectangle
```

The hit area scales with the tongue's current length:
```gdscript
func _update_hitbox() -> void:
    var shape := $HitArea/CollisionShape2D.shape as RectangleShape2D
    shape.size = Vector2(current_length, 8.0)  # 8px wide
    $HitArea.position = Vector2(current_length / 2.0, 0.0)
```

### Processing Hits

```gdscript
func _physics_process(_delta: float) -> void:
    if state == State.EXTENDING:
        var enemies := $HitArea.get_overlapping_bodies()
        for enemy in enemies:
            if enemy not in hit_enemies:
                _hit_enemy(enemy)
                hit_enemies.append(enemy)
```

Key points:
- Only checks during EXTENDING state
- Tracks already-hit enemies to avoid double damage
- Clears hit list when attack ends

### Damage Application

```gdscript
func _hit_enemy(enemy: Node2D) -> void:
    if enemy.has_method("take_damage"):
        enemy.take_damage(base_damage)
        _trigger_hit_feedback()
```

---

## Feedback Integration

When the tongue hits an enemy, multiple feedback systems trigger:

```gdscript
func _trigger_hit_feedback() -> void:
    # Screen shake
    ScreenShake.shake_hit()

    # Particles at enemy position
    ParticleManager.spawn_hit_particles(enemy.global_position)

    # Audio
    AudioManager.play_hit()
```

When an enemy dies from the hit:
```gdscript
func _trigger_kill_feedback() -> void:
    ScreenShake.shake_kill()
    ParticleManager.spawn_death_particles(enemy.global_position)
    AudioManager.play_death()
    HitStop.hit_stop_kill()
```

See [Game Feel](game-feel.md) for details on each system.

---

## Mutation Interactions

Mutations can modify tongue behavior:

| Mutation | Effect | Implementation |
|----------|--------|----------------|
| Longer Tongue | +50% range | `max_range *= 1.5` |
| Faster Tongue | +50% attack speed | `attack_cooldown *= 0.5` |
| Venomous Tongue | DoT effect | Apply status in `_hit_enemy()` |
| Multi-Tongue | 3-way attack | Spawn 2 additional tongues at angles |

### Example: Longer Tongue

```gdscript
# When mutation is acquired
func apply_longer_tongue() -> void:
    tongue.max_range *= 1.5  # 144 → 216 pixels (4.5 tiles)
    tongue.extend_overshoot *= 1.5  # Scale overshoot proportionally
```

### Example: Multi-Tongue

```gdscript
# Spawn additional tongues at ±30° angles
func _attack_multi() -> void:
    _spawn_tongue(aim_direction)
    _spawn_tongue(aim_direction.rotated(deg_to_rad(30)))
    _spawn_tongue(aim_direction.rotated(deg_to_rad(-30)))
```

---

## Visual Representation

The tongue uses a Line2D for rendering:

```gdscript
func _update_visual() -> void:
    $TongueLine.clear_points()
    $TongueLine.add_point(Vector2.ZERO)  # Base (mouth)
    $TongueLine.add_point(Vector2(current_length, 0))  # Tip
```

For a more complex visual:
- Add intermediate points for curves
- Use a Sprite2D at the tip
- Apply shader for color gradient

---

## State Machine

```gdscript
enum State { IDLE, EXTENDING, RETRACTING }
var state := State.IDLE
var time_in_state := 0.0

func _physics_process(delta: float) -> void:
    time_in_state += delta

    match state:
        State.IDLE:
            if Input.is_action_just_pressed("attack") and can_attack:
                _enter_state(State.EXTENDING)

        State.EXTENDING:
            _update_extend()
            if time_in_state >= extend_duration:
                _enter_state(State.RETRACTING)

        State.RETRACTING:
            _update_retract()
            if time_in_state >= retract_duration:
                _enter_state(State.IDLE)
                _start_cooldown()
```

---

## Debugging

### Visualize Hitbox

```gdscript
func _draw() -> void:
    if state != State.IDLE:
        var rect := Rect2(0, -4, current_length, 8)
        draw_rect(rect, Color.RED, false, 2.0)
```

### Log Attack Timing

```gdscript
func _enter_state(new_state: State) -> void:
    print("Tongue: %s → %s at frame %d" % [
        State.keys()[state],
        State.keys()[new_state],
        Engine.get_physics_frames()
    ])
    state = new_state
    time_in_state = 0.0
```

### Test Range

```gdscript
# Spawn marker at max range to verify
func _ready() -> void:
    var marker := Sprite2D.new()
    marker.position = Vector2(max_range, 0)
    $AimPivot.add_child(marker)
```

---

## Common Issues

**Tongue doesn't hit enemies:**
- Check collision layers (tongue layer 4, enemies layer 3)
- Check `monitorable` and `monitoring` flags on Area2D
- Verify enemies have collision shapes

**Double damage on single hit:**
- Ensure `hit_enemies` array is being tracked
- Clear array on state transition to IDLE

**Elastic feels wrong:**
- Verify `ease_out_elastic()` function is correct
- Check `extend_overshoot` is in 0-0.5 range
- Try disabling elastic temporarily to isolate issue

**Attack feels unresponsive:**
- Check `attack_cooldown` isn't too long
- Verify `can_attack` flag is being set correctly
- Check input is in `_physics_process`, not `_process`

---

## Summary

| Feature | Value |
|---------|-------|
| Range | 3 tiles (144px) |
| Attack speed | ~1.8 attacks/sec |
| Damage | 1 per hit |
| Elastic overshoot | 15% |

The tongue attack is simple in concept but has tunable parameters for game feel. The elastic physics add visual satisfaction without affecting gameplay balance.

---

[← Back to Player Controller](player-controller.md) | [Next: Enemy System →](enemy-system.md)
