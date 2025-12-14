# The Lobbyist

The Lobbyist is The Pond's first boss. He's a corporate shill who'll say anything to protect the company. His attacks are themed around business jargon - "business cards," "marketing blitz," and "hostile takeover."

---

## Character Profile

**Name**: The Lobbyist
**Title**: VP of Stakeholder Engagement
**HP**: 100
**Evidence**: `lobbyist_evidence`

**Personality**: Smarmy, condescending, speaks in corporate buzzwords. Treats the player like a nuisance shareholder.

---

## Dialogue

```gdscript
var dialogue_data: Dictionary = {
    "intro": "Ah, a concerned citizen! Let me show you our... stakeholder engagement process.",
    "phase2": "Time for aggressive negotiations!",
    "phase3": "This is YOUR fault for not synergizing!",
    "defeat": "My... quarterly reports... ruined..."
}
```

Each phase transition and defeat triggers dialogue.

---

## Implementation

**File**: `combat/scripts/boss_lobbyist.gd`

```gdscript
class_name BossLobbyist
extends BossBase

# Phase 1: Aimed shots
@export var p1_bullet_speed: float = 150.0
@export var p1_cooldown: float = 2.0

# Phase 2: Radial burst
@export var p2_bullet_speed: float = 200.0
@export var p2_cooldown: float = 1.5
@export var p2_radial_count: int = 8

# Phase 3: Spiral + aimed
@export var p3_bullet_speed: float = 250.0
@export var p3_cooldown: float = 1.0
@export var p3_spiral_speed: float = 90.0
```

---

## Phase 1: Business Cards

**Pattern**: Single aimed shot at player

```gdscript
func _phase1_attack() -> void:
    # Aimed single shot - "Business Cards"
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var direction = (player.global_position - global_position).normalized()
        _spawn_bullet(direction, p1_bullet_speed)
```

**Behavior**:
- Fires toward player position
- 2 second cooldown
- 150 px/s bullet speed
- Easy to dodge with lateral movement

**Strategy**: Keep moving horizontally. The aimed shots are predictable.

---

## Phase 2: Marketing Blitz

**Pattern**: 8-direction radial burst

```gdscript
func _phase2_attack() -> void:
    # Radial burst - "Marketing Blitz"
    for i in range(p2_radial_count):
        var angle = (2 * PI / p2_radial_count) * i
        var direction = Vector2.RIGHT.rotated(angle)
        _spawn_bullet(direction, p2_bullet_speed)
```

**Behavior**:
- 8 bullets in even circle
- 1.5 second cooldown
- 200 px/s bullet speed
- Gaps between bullets

**Strategy**: Stay in gaps between bullets. Diagonal positioning works well.

---

## Phase 3: Hostile Takeover

**Pattern**: Continuous spiral + aimed shots

```gdscript
func _phase3_attack() -> void:
    # Spiral + aimed - "Hostile Takeover"
    var time = Time.get_ticks_msec() / 1000.0
    var spiral_angle = deg_to_rad(time * p3_spiral_speed)
    var spiral_dir = Vector2.RIGHT.rotated(spiral_angle)
    _spawn_bullet(spiral_dir, p3_bullet_speed)

    # Also aim at player
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var direction = (player.global_position - global_position).normalized()
        _spawn_bullet(direction, p3_bullet_speed * 0.8)
```

**Behavior**:
- Rotating spiral pattern
- Plus aimed shot toward player
- 1 second cooldown (fast)
- 250 px/s spiral, 200 px/s aimed

**Strategy**: Circle around the boss. The spiral rotates predictably. Watch for aimed shots.

---

## Tunable Parameters

### Phase 1

| Parameter | Default | Effect |
|-----------|---------|--------|
| `p1_bullet_speed` | 150.0 | Business card speed |
| `p1_cooldown` | 2.0 | Time between shots |

### Phase 2

| Parameter | Default | Effect |
|-----------|---------|--------|
| `p2_bullet_speed` | 200.0 | Radial burst speed |
| `p2_cooldown` | 1.5 | Time between bursts |
| `p2_radial_count` | 8 | Bullets per burst |

### Phase 3

| Parameter | Default | Effect |
|-----------|---------|--------|
| `p3_bullet_speed` | 250.0 | Spiral bullet speed |
| `p3_cooldown` | 1.0 | Attack frequency |
| `p3_spiral_speed` | 90.0 | Spiral rotation (deg/s) |

---

## Attack Timer System

```gdscript
var attack_timer: float = 0.0

func _physics_process(delta: float) -> void:
    if current_state in [BossState.PHASE_1, BossState.PHASE_2, BossState.PHASE_3]:
        attack_timer += delta
        _process_attack(delta)

func _process_attack(delta: float) -> void:
    var cooldown = _get_current_cooldown()
    if attack_timer >= cooldown:
        attack_timer = 0.0
        match current_phase:
            1: _phase1_attack()
            2: _phase2_attack()
            3: _phase3_attack()

func _get_current_cooldown() -> float:
    match current_phase:
        1: return p1_cooldown
        2: return p2_cooldown
        3: return p3_cooldown
    return 1.0
```

---

## Difficulty Scaling

The Lobbyist scales with player mutations:

```gdscript
func apply_difficulty_scaling(mutation_count: int, hard_mode: bool = false) -> void:
    super.apply_difficulty_scaling(mutation_count, hard_mode)

    # Apply speed scaling to bullet speeds
    var speed_scale = 1.0 + min(mutation_count * speed_scale_per_mutation, max_scaling - 1.0)
    if hard_mode:
        speed_scale *= hard_mode_multiplier

    p1_bullet_speed *= speed_scale
    p2_bullet_speed *= speed_scale
    p3_bullet_speed *= speed_scale
```

### Scaling Example

| Mutations | HP | Bullet Speed Scale |
|-----------|-----|-------------------|
| 0 | 100 | 1.0x |
| 5 | 125 | 1.1x |
| 10 | 150 | 1.2x |

---

## Phase Transitions

```gdscript
func _on_phase_changed(new_phase: int) -> void:
    match new_phase:
        1: dialogue_triggered.emit(dialogue_data["intro"])
        2: dialogue_triggered.emit(dialogue_data["phase2"])
        3: dialogue_triggered.emit(dialogue_data["phase3"])
```

Each transition:
1. Boss becomes invulnerable
2. Dialogue displays
3. 2 second transition animation
4. New phase begins

---

## Defeat Sequence

```gdscript
func _defeat() -> void:
    dialogue_triggered.emit(dialogue_data["defeat"])
    super._defeat()
```

1. "My... quarterly reports... ruined..." displays
2. Boss enters DEFEATED state
3. Evidence spawns after 1 second
4. Player collects evidence

---

## Evidence

The Lobbyist drops `lobbyist_evidence`, which unlocks a data log on the conspiracy board:

```
INTERCEPTED COMMUNICATION
From: Lobbying Firm LLP
To: [REDACTED] Industries

RE: EPA Meeting Strategy

Recommend we "donate" to the senator's
re-election campaign before the vote.
Our friends in the agency will handle
the inspection timeline.

Remember: there is no memo.
```

---

## Visual Design (Assets Needed)

### Sprite Requirements

- **Idle**: Smug businessman frog in suit
- **Attack**: Brief arm gesture
- **Hit**: Recoil/grimace
- **Transition**: Papers flying, adjusting tie
- **Defeat**: Suit disheveled, briefcase explodes

### Bullet Design

- **Business Cards**: Small white rectangles
- **Marketing Blitz**: Larger cards
- **Spiral**: Same cards with rotation

---

## Audio (Assets Needed)

| Sound | When |
|-------|------|
| `boss_lobbyist_intro` | Intro sequence |
| `boss_lobbyist_phase2` | Phase 2 transition |
| `boss_lobbyist_phase3` | Phase 3 transition |
| `boss_lobbyist_defeat` | Death sequence |
| `bullet_fire_card` | Business card launch |

---

## Strategy Guide

### Recommended Build

- **Speed mutations**: Dodge easier
- **Long Reach**: Hit from safer distance
- **Regeneration**: Heal between phases

### Phase-by-Phase Tips

**Phase 1 (100-66% HP)**:
- Move horizontally
- Attack during his cooldown
- Safe phase to learn patterns

**Phase 2 (66-33% HP)**:
- Find the gaps in radial bursts
- Diagonal positions safest
- Don't panic at bullet count

**Phase 3 (33-0% HP)**:
- Circle strafe around boss
- Spiral is predictable
- Watch for aimed shots
- Play aggressive - end it fast

---

## Common Issues

**Boss doesn't spawn bullets:**
- Check BuHSpawner node exists
- Verify `fire_bullet()` method
- Check bullet pattern pool

**Dialogue doesn't show:**
- Verify signal connection
- Check DialogueBox path
- Test with print statements

**Phase transitions broken:**
- Verify HP thresholds
- Check `_check_phase_transition()` called
- Ensure `take_damage()` reduces HP

---

## Summary

| Phase | Pattern | Cooldown | Speed | Difficulty |
|-------|---------|----------|-------|------------|
| 1 | Aimed single | 2.0s | 150 | Easy |
| 2 | 8-way radial | 1.5s | 200 | Medium |
| 3 | Spiral + aimed | 1.0s | 250 | Hard |

The Lobbyist teaches core bullet hell skills: dodging aimed shots, finding gaps in patterns, and managing multiple attack types. He's the tutorial boss - challenging but fair.

---

[← Back to Overview](overview.md) | [Next: The CEO →](ceo.md)
