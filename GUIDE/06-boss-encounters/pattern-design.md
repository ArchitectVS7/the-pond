# Boss Pattern Design

Creating satisfying boss patterns requires balancing spectacle with fairness. This chapter covers the philosophy and practical techniques for designing bullet patterns.

---

## Design Philosophy

### Core Principles

1. **Telegraph Everything**: Players should never feel cheated
2. **Escalate Gradually**: Each phase harder than the last
3. **Create Rhythm**: Patterns have beats players can learn
4. **Reward Mastery**: Skilled play makes patterns trivial
5. **Theme Patterns**: Attacks reflect boss personality

### The "Fair Death" Test

After every death, players should think:
- "I should have dodged left" ✓
- "I needed to move earlier" ✓
- "That attack came from nowhere" ✗

If players blame themselves, the pattern is fair. If they blame the game, redesign.

---

## Pattern Types

### Aimed Patterns

Bullets target player position:

```gdscript
func _aimed_shot() -> void:
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var direction = (player.global_position - global_position).normalized()
        _spawn_bullet(direction, bullet_speed)
```

**Characteristics**:
- Predictable (always toward player)
- Easy to dodge with lateral movement
- Foundation of Phase 1 patterns

**When to Use**: Tutorial phases, rhythm breaks, combined with other patterns.

### Radial Patterns

Bullets spread in all directions:

```gdscript
func _radial_burst(count: int) -> void:
    for i in range(count):
        var angle = (2 * PI / count) * i
        var direction = Vector2.RIGHT.rotated(angle)
        _spawn_bullet(direction, bullet_speed)
```

**Characteristics**:
- Even coverage
- Gaps are predictable
- More bullets = smaller gaps

**When to Use**: Pressure phases, forcing movement, spectacle.

### Spiral Patterns

Rotating emitter creates spirals:

```gdscript
func _spiral_shot() -> void:
    var time = Time.get_ticks_msec() / 1000.0
    var angle = deg_to_rad(time * rotation_speed)
    var direction = Vector2.RIGHT.rotated(angle)
    _spawn_bullet(direction, bullet_speed)
```

**Characteristics**:
- Hypnotic visual
- Safe zone rotates with spiral
- Fast rotation = harder

**When to Use**: Intense phases, visual wow factor, skill checks.

### Wall Patterns

Lines of bullets:

```gdscript
func _bullet_wall(count: int, spacing: float, direction: Vector2) -> void:
    for i in range(count):
        var offset = (i - count / 2.0) * spacing
        var perpendicular = direction.orthogonal()
        var pos = global_position + perpendicular * offset
        _spawn_bullet_at(direction, bullet_speed, pos)
```

**Characteristics**:
- Forces horizontal/vertical movement
- Gaps require positioning
- Can trap players against walls

**When to Use**: Zone denial, forcing specific movement, Phase 1 patterns.

### Homing Patterns

Bullets track player:

```gdscript
# In bullet script
func _physics_process(delta: float) -> void:
    if homing and homing_timer > 0:
        var to_player = (player.global_position - global_position).normalized()
        velocity = velocity.lerp(to_player * speed, homing_strength * delta)
        homing_timer -= delta
```

**Characteristics**:
- High threat
- Requires constant movement
- Can be out-maneuvered

**When to Use**: Phase 2+, boss signature attacks, limited use (powerful).

---

## Pattern Combinations

### Aimed + Radial

```gdscript
func _combo_attack() -> void:
    # Radial burst
    _radial_burst(8)

    # Delayed aimed shot
    await get_tree().create_timer(0.5).timeout
    _aimed_shot()
```

Player dodges radial, then must react to aimed. Tests adaptability.

### Spiral + Wall

```gdscript
func _spiral_wall_combo() -> void:
    _spiral_shot()  # Continuous

    if attack_timer > wall_interval:
        _bullet_wall(5, 80, Vector2.DOWN)
        attack_timer = 0
```

Spiral controls center, walls deny edges. Tests positioning.

### Homing + Chaos

```gdscript
func _pressure_attack() -> void:
    _spawn_homing_bullet()

    # Random bullets while homing active
    for i in range(5):
        var angle = randf() * 2 * PI
        _spawn_bullet(Vector2.RIGHT.rotated(angle), randf_range(100, 200))
```

Homing forces movement, chaos punishes panic. Tests composure.

---

## Difficulty Tuning

### Speed

| Difficulty | Speed Range | Player Reaction |
|------------|-------------|-----------------|
| Easy | 100-150 px/s | Comfortable |
| Medium | 150-250 px/s | Requires attention |
| Hard | 250-350 px/s | Demanding |
| Extreme | 350+ px/s | Expert only |

### Density

| Bullets/Second | Feel |
|----------------|------|
| 1-2 | Calm, rhythmic |
| 3-5 | Active |
| 6-10 | Intense |
| 10+ | Overwhelming |

### Cooldowns

| Cooldown | Player Feel |
|----------|-------------|
| 3+ seconds | Recovery time |
| 2 seconds | Steady pressure |
| 1 second | Relentless |
| < 1 second | Panic mode |

---

## Telegraphing

### Visual Telegraphs

```gdscript
func _telegraphed_attack() -> void:
    # Warning indicator
    $Telegraph.visible = true
    $Telegraph.position = attack_position

    await get_tree().create_timer(telegraph_duration).timeout

    $Telegraph.visible = false
    _execute_attack()
```

| Telegraph Type | Duration | Use Case |
|----------------|----------|----------|
| Ground marker | 0.5-1.0s | Area attacks |
| Boss animation | 0.3-0.5s | Standard attacks |
| Audio cue | 0.2-0.3s | Fast attacks |
| Color change | Variable | Phase shifts |

### Audio Telegraphs

```gdscript
func _audio_telegraph_attack() -> void:
    AudioManager.play_sfx("attack_charge")
    await get_tree().create_timer(0.5).timeout
    _execute_attack()
```

Sound cues help players who aren't looking at the boss.

---

## Phase Design

### Phase 1: Introduction

- Simple patterns
- Long cooldowns
- Teaches core mechanics
- ~30% of fight duration

### Phase 2: Escalation

- Combined patterns
- Shorter cooldowns
- New mechanics introduced
- ~40% of fight duration

### Phase 3: Climax

- All mechanics combined
- Fast cooldowns
- Highest intensity
- ~30% of fight duration

### Transitions

```gdscript
func _transition_to_phase(new_phase: int) -> void:
    # Invulnerability during transition
    is_invulnerable = true

    # Clear bullets (mercy)
    _clear_all_bullets()

    # Dramatic pause
    await get_tree().create_timer(2.0).timeout

    # Begin new phase
    is_invulnerable = false
    _start_phase_pattern(new_phase)
```

Transitions give players breathing room. They also build anticipation.

---

## Testing Patterns

### Hitbox Visualization

```gdscript
func _draw() -> void:
    if debug_hitboxes:
        for bullet in active_bullets:
            draw_circle(bullet.position - global_position, bullet.radius, Color(1, 0, 0, 0.5))
```

Seeing actual hitboxes reveals unfair patterns.

### Slow Motion Testing

```gdscript
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("debug_slow_mo"):
        Engine.time_scale = 0.25
    if event.is_action_released("debug_slow_mo"):
        Engine.time_scale = 1.0
```

Slow motion helps analyze pattern readability.

### Invincibility Testing

```gdscript
# In player
var debug_invincible: bool = false

func take_damage(amount: int) -> void:
    if debug_invincible:
        return
    # ...
```

Test patterns without death interruption.

---

## Common Mistakes

### Too Dense

**Problem**: Walls with no gaps

**Solution**:
```gdscript
# Bad: Bullets overlap
var spacing = 20  # Too tight

# Good: Clear gaps
var spacing = player_hitbox_width * 2  # At least 2x player width
```

### No Telegraph

**Problem**: Instant attacks

**Solution**: Always have windup:
```gdscript
# Bad: Immediate
_spawn_bullet(direction, speed)

# Good: Telegraphed
$ChargeEffect.play()
await get_tree().create_timer(0.3).timeout
_spawn_bullet(direction, speed)
```

### Inconsistent Rhythm

**Problem**: Random cooldowns feel unfair

**Solution**: Consistent timing:
```gdscript
# Bad: Random
var cooldown = randf_range(0.5, 3.0)

# Good: Consistent with variation
var cooldown = base_cooldown + randf_range(-0.2, 0.2)
```

### Screen-Filling Chaos

**Problem**: No safe zones

**Solution**: Always leave escape routes:
```gdscript
func _chaos_attack() -> void:
    for i in range(bullet_count):
        var angle = randf() * 2 * PI

        # Leave safe cone toward player's escape route
        if _is_angle_in_safe_zone(angle):
            continue

        _spawn_bullet(Vector2.RIGHT.rotated(angle), speed)
```

---

## Reference: BulletUpHell Integration

The Pond uses BulletUpHell for bullet management:

```gdscript
# Get spawner reference
@onready var bullet_spawner = $BuHSpawner

# Fire single bullet
func _spawn_bullet(direction: Vector2, speed: float) -> void:
    bullet_spawner.fire_bullet(direction, speed)

# Fire with position override
func _spawn_bullet_at(direction: Vector2, speed: float, pos: Vector2) -> void:
    var original = bullet_spawner.global_position
    bullet_spawner.global_position = pos
    bullet_spawner.fire_bullet(direction, speed)
    bullet_spawner.global_position = original
```

See [BulletUpHell Chapter](../03-bulletuphell/overview.md) for pool configuration.

---

## Summary

| Aspect | Guideline |
|--------|-----------|
| Telegraph | 0.3-1.0s warning |
| Speed | 100-350 px/s |
| Gaps | 2x player width minimum |
| Cooldowns | Consistent with ±0.2s variance |
| Phases | Introduce → Escalate → Climax |
| Testing | Slow-mo, hitbox viz, invincibility |

Good patterns are:
- **Readable**: Player understands the threat
- **Dodgeable**: Skill allows evasion
- **Satisfying**: Mastery feels earned
- **Thematic**: Reflects boss personality

The goal isn't to kill players. It's to challenge them fairly and make victory meaningful.

---

[← Back to Sentient Pond](sentient-pond.md) | [Back to Overview](overview.md)
