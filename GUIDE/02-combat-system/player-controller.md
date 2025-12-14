# Player Controller

The player is a frog. The frog moves with WASD, aims with the mouse. That's it. Simplicity is intentional - in a bullet hell, you need instant, predictable control.

---

## Movement System (COMBAT-001)

**File**: `combat/scripts/player_controller.gd`

### How It Works

```gdscript
func _physics_process(_delta: float) -> void:
    var input := Vector2.ZERO
    input.x = Input.get_axis("move_left", "move_right")
    input.y = Input.get_axis("move_up", "move_down")

    velocity = input.normalized() * move_speed
    move_and_slide()
```

That's the core. No acceleration, no friction, no momentum. You press a direction, you move that direction at full speed. You release, you stop.

### Why No Momentum?

Bullet hells require precision. Consider:
- A bullet is 3 pixels away
- You need to move 4 pixels to dodge
- With momentum, you'd overshoot into another bullet
- Without momentum, you stop exactly where you intended

Some games (Celeste, Hollow Knight) use momentum for platforming feel. The Pond doesn't - it's a survival game where dodging matters more than movement feel.

### Tunable Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `move_speed` | 200.0 | 100-400 | Pixels per second |

**200 px/s feels right because:**
- Fast enough to dodge between bullets
- Slow enough to make tight gaps challenging
- Matches the 48px tile grid (4.16 tiles/second)

### Changing Movement Speed

Want faster gameplay?
```gdscript
@export var move_speed: float = 300.0  # 50% faster
```

This changes the entire game balance. Faster movement means:
- Easier dodging
- Larger arena feels needed
- Enemies need to be faster or spawn faster
- Consider this a "difficulty setting" change

---

## Aim System (COMBAT-002)

**File**: `combat/scripts/player_controller.gd`

### How It Works

```gdscript
func _physics_process(_delta: float) -> void:
    var mouse_pos := get_global_mouse_position()
    aim_direction = (mouse_pos - global_position).normalized()
    aim_angle = aim_direction.angle()

    $AimPivot.rotation = aim_angle
```

The aim pivot is a Node2D that parents the tongue. Rotating it points the tongue at the mouse.

### Instant vs Smoothed Aim

The current implementation is instant - the tongue points exactly at the mouse every frame. Some games smooth this:

```gdscript
# Smoothed aim (NOT currently used)
var target_angle := aim_direction.angle()
$AimPivot.rotation = lerp_angle($AimPivot.rotation, target_angle, 0.3)
```

**Why instant?**
- Feels more responsive
- No "lag" between mouse and tongue
- Better for precision attacks

**Why you might add smoothing:**
- Visual polish (tongue doesn't jitter)
- Different game feel (more deliberate aiming)
- If mouse input feels too twitchy

### Variables Available

These are calculated every frame and available for other systems:

| Variable | Type | Description |
|----------|------|-------------|
| `aim_direction` | Vector2 | Normalized direction to mouse |
| `aim_angle` | float | Angle in radians (0=right, PI/2=down) |

Use `aim_direction` when you need a vector (spawning projectiles, applying knockback).
Use `aim_angle` when you need rotation (visuals, cone attacks).

---

## Input Handling

### Input Actions

Defined in `project.godot`:

| Action | Default Key | Description |
|--------|-------------|-------------|
| `move_up` | W | Move up |
| `move_down` | S | Move down |
| `move_left` | A | Move left |
| `move_right` | D | Move right |
| `attack` | Left Mouse | Tongue attack |
| `quit` | Escape | Exit game |

### Why _physics_process?

Input is handled in `_physics_process`, not `_process`:

```gdscript
# GOOD - consistent 60fps timing
func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        _perform_attack()

# BAD - variable timing
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        _perform_attack()
```

`_physics_process` runs at a fixed 60fps regardless of rendering framerate. This means:
- Input timing is consistent
- Physics and input are synchronized
- No frame-dependent bugs

See [Input Lag Validation](performance.md#input-lag-validation) for more on timing.

---

## Collision Setup

### Layer Configuration

| Layer | Name | Used By |
|-------|------|---------|
| 1 | Player | Player body |
| 2 | Environment | Walls, obstacles |
| 3 | Enemies | Enemy bodies |
| 4 | PlayerAttack | Tongue hit area |

### Player Collision

```
Player (CharacterBody2D)
├── Layer: 1 (Player)
├── Mask: 2 (Environment)
└── Collision Shape: Circle, 16px radius
```

The player collides with environment but not enemies directly. Enemy collision is handled by their AI (they push toward player) and the tongue hitbox.

### Why Not Collide With Enemies?

In some games, touching enemies damages you. In The Pond, enemies deal damage through their own collision detection. This separation allows:
- Enemies to overlap slightly (swarm feel)
- Smoother movement when surrounded
- Contact damage controlled by enemy, not player

---

## State Machine (Future)

The current player is stateless - you can move and attack simultaneously. For future features, consider a state machine:

```gdscript
enum State { IDLE, MOVING, ATTACKING, HURT, DEAD }
var current_state := State.IDLE

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            _handle_idle(delta)
        State.MOVING:
            _handle_moving(delta)
        State.ATTACKING:
            _handle_attacking(delta)
        # etc.
```

**When you'd need states:**
- Dash ability (can't attack while dashing)
- Hurt state (brief invincibility)
- Death animation
- Dialogue/cutscene locks

For MVP, the stateless approach is simpler and works fine.

---

## Integration Points

### With Tongue Attack

The tongue attack reads `aim_direction` from the player:
```gdscript
# In tongue_attack.gd
var direction := get_parent().get_parent().aim_direction
```

### With Mutations

Mutations modify player stats at runtime:
```gdscript
# Speed mutation
player.move_speed *= 1.5  # +50% speed

# After mutation expires
player.move_speed = base_speed
```

### With Save System

Player position is saved:
```gdscript
# In save_data.gd
save_data.player_data["position"] = player.global_position
```

---

## Debugging

### Visualize Aim Direction

Add this to see the aim line:
```gdscript
func _draw() -> void:
    draw_line(Vector2.ZERO, aim_direction * 100, Color.RED, 2.0)
```

Don't forget to call `queue_redraw()` in `_physics_process`.

### Log Input Timing

```gdscript
func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        print("Attack at frame: ", Engine.get_physics_frames())
```

### Check Movement Speed

```gdscript
func _physics_process(_delta: float) -> void:
    print("Velocity: ", velocity.length(), " px/s")
```

---

## Common Issues

**Player moves diagonally faster:**
Fixed by `.normalized()` - diagonal input is normalized to unit length.

**Aim feels jittery:**
Check if you're running the game at very high FPS (200+). Consider adding aim smoothing.

**Player gets stuck on walls:**
Check collision shapes. The player uses a circle which slides along walls naturally.

**Input feels delayed:**
Ensure you're using `_physics_process`, not `_process`. Check for V-Sync settings.

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Movement | 8-directional, 200 px/s, no momentum |
| Aim | Instant, follows mouse, updates every frame |
| Input | `_physics_process` for consistent 60fps timing |
| Collision | Layer 1, masks environment only |

The player controller is intentionally simple. Complexity comes from the environment (bullets, enemies), not from the movement itself.

---

[← Back to Overview](overview.md) | [Next: Tongue Attack →](tongue-attack.md)
