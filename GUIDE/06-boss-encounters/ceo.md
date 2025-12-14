# The CEO

The CEO is The Pond's final MVP boss. He's the mastermind behind the pollution conspiracy - ruthless, dramatic, and convinced he IS the market. His attacks are apocalyptic: bullet walls, homing missiles, and screen-filling chaos.

---

## Character Profile

**Name**: The CEO
**Title**: Chief Executive Officer, [REDACTED] Industries
**HP**: 150
**Evidence**: `ceo_evidence`

**Personality**: Megalomaniacal, views the frog as a minor shareholder problem. Speaks in market metaphors and has a god complex.

---

## Dialogue

```gdscript
var dialogue_data: Dictionary = {
    "intro": "You think you can stop PROGRESS? I AM the pond. I AM the pollution. I AM... THE MARKET!",
    "phase2": "Your little investigation ends HERE!",
    "phase3": "ENOUGH! I'll bury you like I buried the evidence!",
    "defeat": "No... the board will hear about this..."
}
```

Each line escalates the drama. The CEO takes himself very seriously.

---

## Implementation

**File**: `combat/scripts/boss_ceo.gd`

```gdscript
class_name BossCEO
extends BossBase

# Base stats (higher than Lobbyist)
@export var ceo_total_hp: int = 150

# Phase 1: Bullet walls
@export var ceo_p1_wall_speed: float = 120.0
@export var ceo_p1_wall_count: int = 5
@export var ceo_p1_wall_spacing: float = 100.0

# Phase 2: Homing bullets
@export var ceo_p2_homing_strength: float = 2.0
@export var ceo_p2_homing_duration: float = 3.0
@export var ceo_p2_cooldown: float = 2.5

# Phase 3: Market Crash chaos
@export var ceo_p3_spawn_interval: float = 0.5
@export var ceo_p3_chaos_count: int = 8
@export var ceo_p3_cooldown: float = 1.2
```

---

## Phase 1: Board Meeting

**Pattern**: Horizontal bullet walls

```gdscript
func _phase1_attack() -> void:
    # "Board Meeting" - Bullet walls
    for i in range(ceo_p1_wall_count):
        var offset = (i - ceo_p1_wall_count / 2.0) * ceo_p1_wall_spacing
        var bullet_pos = global_position + Vector2(offset, 0)
        _spawn_bullet_at(Vector2.DOWN, ceo_p1_wall_speed, bullet_pos)
```

**Behavior**:
- 5 bullets in horizontal line
- Travel downward
- 100px spacing between bullets
- 120 px/s speed

**Strategy**: Find gaps in the wall. Move horizontally to avoid getting trapped.

---

## Phase 2: Leveraged Buyout

**Pattern**: Homing bullets that track player

```gdscript
func _phase2_attack() -> void:
    # "Leveraged Buyout" - Homing bullets
    var player = get_tree().get_first_node_in_group("player")
    if player:
        _spawn_homing_bullet(player)

func _spawn_homing_bullet(target: Node2D) -> void:
    if bullet_spawner:
        var direction = (target.global_position - global_position).normalized()
        bullet_spawner.fire_bullet(direction, 180.0)
```

**Behavior**:
- Single homing bullet
- Tracks player for 3 seconds
- 2.5 second cooldown
- Requires BulletUpHell homing support

**Strategy**: Keep moving. Homing bullets can't turn sharply. Lead them into walls or out-maneuver.

**Note**: Full homing implementation may require custom bullet behavior.

---

## Phase 3: Market Crash

**Pattern**: Random chaos bullets everywhere

```gdscript
func _phase3_attack() -> void:
    # "Market Crash" - Screen-filling chaos
    for i in range(ceo_p3_chaos_count):
        var angle = randf() * 2 * PI
        var speed = randf_range(100, 300)
        _spawn_bullet(Vector2.RIGHT.rotated(angle), speed)
```

**Behavior**:
- 8 bullets per attack
- Random directions
- Random speeds (100-300 px/s)
- 1.2 second cooldown (relentless)

**Strategy**: Stay calm. Despite the chaos, there are always gaps. Keep moving and look for patterns in the randomness.

---

## Tunable Parameters

### Base Stats

| Parameter | Default | Effect |
|-----------|---------|--------|
| `ceo_total_hp` | 150 | 50% more HP than Lobbyist |

### Phase 1

| Parameter | Default | Effect |
|-----------|---------|--------|
| `ceo_p1_wall_speed` | 120.0 | Wall descent speed |
| `ceo_p1_wall_count` | 5 | Bullets per wall |
| `ceo_p1_wall_spacing` | 100.0 | Gap between bullets |

### Phase 2

| Parameter | Default | Effect |
|-----------|---------|--------|
| `ceo_p2_homing_strength` | 2.0 | Turn rate multiplier |
| `ceo_p2_homing_duration` | 3.0 | How long bullets home |
| `ceo_p2_cooldown` | 2.5 | Time between homing shots |

### Phase 3

| Parameter | Default | Effect |
|-----------|---------|--------|
| `ceo_p3_chaos_count` | 8 | Bullets per burst |
| `ceo_p3_cooldown` | 1.2 | Attack frequency |
| Speed range | 100-300 | Random bullet speeds |

---

## Helper Functions

### Positional Bullet Spawn

```gdscript
func _spawn_bullet_at(direction: Vector2, speed: float, spawn_position: Vector2) -> void:
    if bullet_spawner:
        var original_pos = bullet_spawner.global_position
        bullet_spawner.global_position = spawn_position
        bullet_spawner.fire_bullet(direction, speed)
        bullet_spawner.global_position = original_pos
```

This allows spawning bullets from positions other than the boss center (needed for walls).

---

## Difficulty Scaling

```gdscript
func apply_difficulty_scaling(mutation_count: int, hard_mode: bool = false) -> void:
    super.apply_difficulty_scaling(mutation_count, hard_mode)

    var speed_scale = 1.0 + min(mutation_count * speed_scale_per_mutation, max_scaling - 1.0)
    if hard_mode:
        speed_scale *= hard_mode_multiplier

    ceo_p1_wall_speed *= speed_scale
    ceo_p2_homing_strength *= speed_scale
```

### Scaling Example

| Mutations | HP | Wall Speed | Homing Strength |
|-----------|-----|-----------|-----------------|
| 0 | 150 | 120 | 2.0 |
| 5 | 188 | 132 | 2.2 |
| 10 | 225 | 144 | 2.4 |

With 10 mutations, the CEO is significantly harder - rewarding skilled players with a real challenge.

---

## Phase Transitions

The CEO's transitions are dramatic:

```gdscript
func _on_phase_changed(new_phase: int) -> void:
    match new_phase:
        1: dialogue_triggered.emit(dialogue_data["intro"])
        2: dialogue_triggered.emit(dialogue_data["phase2"])
        3: dialogue_triggered.emit(dialogue_data["phase3"])
```

**Phase 1 → 2**: "Your little investigation ends HERE!"
- Screen shakes
- Boss visual change (more aggressive stance)
- Music intensifies

**Phase 2 → 3**: "ENOUGH! I'll bury you like I buried the evidence!"
- Major screen effect
- Boss transforms/glows
- Final boss music

---

## Evidence

The CEO drops `ceo_evidence`:

```
CLASSIFIED - EXECUTIVE EYES ONLY

Project "Clean Slate" is proceeding as planned.
The pond site will be sold to developers once
contamination levels become "irreversible."

Insurance claim: $47M
Development rights: $120M
Settlement reserves: $15M

Net profit: $152M

Delete this memo after reading.

- R.C.
```

This is the smoking gun that completes the conspiracy board's main thread.

---

## Visual Design (Assets Needed)

### Sprite Requirements

- **Idle**: Imposing frog in expensive suit, power pose
- **Phase 1**: Standing, arms wide (commanding the market)
- **Phase 2**: Pointing, aggressive
- **Phase 3**: Unhinged, tie loose, eyes glowing
- **Defeat**: Collapse, suit dissolving

### Bullet Design

- **Board Meeting (P1)**: Gold coins or stock ticker symbols
- **Leveraged Buyout (P2)**: Red arrow/missile
- **Market Crash (P3)**: Mixed financial symbols, chaotic

---

## Audio (Assets Needed)

| Sound | When |
|-------|------|
| `boss_ceo_intro` | "I AM THE MARKET!" |
| `boss_ceo_phase2` | Phase 2 transition |
| `boss_ceo_phase3` | Phase 3 transition (dramatic) |
| `boss_ceo_defeat` | Defeat collapse |
| `bullet_wall_spawn` | Wall bullets appear |
| `bullet_homing_launch` | Homing bullet fires |
| `bullet_chaos_spawn` | Chaos burst |

---

## Strategy Guide

### Recommended Build

- **Speed**: Essential for Phase 3 dodging
- **Damage**: Cut the fight shorter
- **HP**: Survive mistakes in Phase 3

### Phase-by-Phase Tips

**Phase 1 (100-66% HP)**:
- Learn the wall timing
- Position at wall gaps
- Attack between walls
- Easiest phase despite intimidating visuals

**Phase 2 (66-33% HP)**:
- Keep moving constantly
- Lead homing bullets away
- Attack while dodging
- Watch cooldown timing for safe windows

**Phase 3 (33-0% HP)**:
- Don't panic
- Random ≠ unavoidable
- Constant movement in one direction
- Play aggressive - end it fast
- This is the skill check

---

## Common Issues

**Wall bullets don't align:**
- Check `ceo_p1_wall_spacing` value
- Verify spawn position calculation
- Test bullet_spawner position reset

**Homing bullets don't track:**
- Implement custom homing behavior
- Or simplify to fast aimed shots
- Check `target` reference validity

**Phase 3 too hard/easy:**
- Adjust `ceo_p3_chaos_count` (fewer = easier)
- Modify `ceo_p3_cooldown` (longer = easier)
- Narrow speed range (less variance)

---

## Comparison: Lobbyist vs CEO

| Aspect | Lobbyist | CEO |
|--------|----------|-----|
| HP | 100 | 150 |
| Phase 1 | Aimed shots | Bullet walls |
| Phase 2 | Radial burst | Homing bullets |
| Phase 3 | Spiral + aimed | Random chaos |
| Difficulty | Tutorial | Final exam |
| Theme | Negotiation | Total war |

The CEO is the culmination of skills learned from the Lobbyist. If players can beat Phase 3, they've mastered The Pond's bullet hell systems.

---

## Summary

| Phase | Pattern | Cooldown | Difficulty |
|-------|---------|----------|------------|
| 1 | 5-bullet walls | 3.0s | Medium |
| 2 | Homing bullets | 2.5s | Medium-Hard |
| 3 | 8-bullet chaos | 1.2s | Hard |

The CEO is the villain players came to defeat. His patterns are overwhelming but fair. His defeat is cathartic. And his evidence exposes the full conspiracy.

---

[← Back to The Lobbyist](lobbyist.md) | [Next: The Researcher →](researcher.md)
