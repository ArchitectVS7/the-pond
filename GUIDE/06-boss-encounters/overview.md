# Boss Encounters Overview

Boss fights are The Pond's narrative climaxes. Each boss represents a different aspect of corporate malfeasance - the Lobbyist, the CEO, and eventually more. This chapter covers the boss framework and individual encounters.

---

## The Core Concept

Bosses are multi-phase bullet hell fights with personality. Each boss:

- **Has character**: Dialogue, attack names, visual identity
- **Escalates in phases**: Three phases with increasing intensity
- **Drops evidence**: Advances the conspiracy board narrative
- **Scales with mutations**: Harder if player is stronger

The bosses turn The Pond from "a game about frogs" into "a game about exposing corporate greed."

---

## What's Here

| File | What It Covers |
|------|----------------|
| [The Lobbyist](lobbyist.md) | MVP boss, business card patterns |
| [The CEO](ceo.md) | MVP final boss, market crash chaos |
| [The Researcher](researcher.md) | Alpha boss (planned) |
| [Sentient Pond](sentient-pond.md) | Beta boss (planned) |
| [Pattern Design](pattern-design.md) | Boss pattern philosophy |

---

## Boss Framework

### BossBase Architecture

**File**: `combat/scripts/boss_base.gd`

```gdscript
class_name BossBase
extends CharacterBody2D

signal phase_changed(new_phase: int)
signal boss_defeated
signal dialogue_triggered(text: String)

enum BossState { IDLE, PHASE_1, PHASE_2, PHASE_3, TRANSITIONING, DEFEATED }

# Health and thresholds
@export var total_hp: int = 100
@export var phase_2_threshold: float = 0.66
@export var phase_3_threshold: float = 0.33
@export var phase_transition_duration: float = 2.0

# Intro and defeat
@export var intro_duration: float = 3.0
@export var evidence_spawn_delay: float = 1.0
@export var evidence_id: String = ""

# Difficulty scaling
@export var hp_scale_per_mutation: float = 0.05
@export var speed_scale_per_mutation: float = 0.02
@export var max_scaling: float = 1.5
@export var hard_mode_multiplier: float = 1.5

var current_hp: int
var current_state: BossState = BossState.IDLE
var current_phase: int = 0
var is_invulnerable: bool = true
```

### Scene Structure

```
BossBase (CharacterBody2D)
├── Sprite2D                    # Boss visual
├── CollisionShape2D            # Hitbox
├── BuHSpawner                  # Bullet spawner
├── AnimationPlayer             # State animations
└── HealthBar (UI)              # Boss health display
```

---

## Key Files

| File | Purpose |
|------|---------|
| `combat/scripts/boss_base.gd` | Shared boss logic |
| `combat/scripts/boss_lobbyist.gd` | Lobbyist implementation |
| `combat/scripts/boss_ceo.gd` | CEO implementation |
| `combat/scenes/BossLobbyist.tscn` | Lobbyist scene |
| `combat/scenes/BossCEO.tscn` | CEO scene |

---

## Boss Lifecycle

### 1. Intro Phase

```gdscript
func _start_intro() -> void:
    current_state = BossState.IDLE
    # Play intro animation, show dialogue
    await get_tree().create_timer(intro_duration).timeout
    _transition_to_phase(1)
```

- Boss appears
- Intro dialogue plays
- Player cannot attack (invulnerable)
- Duration: 3 seconds (tunable)

### 2. Phase Transitions

```gdscript
func _check_phase_transition() -> void:
    var hp_percent = float(current_hp) / float(total_hp)

    if current_phase == 1 and hp_percent <= phase_2_threshold:
        _transition_to_phase(2)
    elif current_phase == 2 and hp_percent <= phase_3_threshold:
        _transition_to_phase(3)

func _transition_to_phase(new_phase: int) -> void:
    current_state = BossState.TRANSITIONING
    is_invulnerable = true
    current_phase = new_phase
    phase_changed.emit(new_phase)

    # Transition animation
    await get_tree().create_timer(phase_transition_duration).timeout

    current_state = BossState["PHASE_%d" % new_phase]
    is_invulnerable = false
    _start_phase_pattern(new_phase)
```

**Thresholds**:
- Phase 1: 100% - 66% HP
- Phase 2: 66% - 33% HP
- Phase 3: 33% - 0% HP

### 3. Defeat

```gdscript
func _defeat() -> void:
    current_state = BossState.DEFEATED
    is_invulnerable = true
    boss_defeated.emit()

    await get_tree().create_timer(evidence_spawn_delay).timeout
    _spawn_evidence()

func _spawn_evidence() -> void:
    if evidence_id != "":
        var evidence = preload("res://metagame/scenes/Evidence.tscn").instantiate()
        evidence.evidence_id = evidence_id
        evidence.position = global_position
        get_parent().add_child(evidence)
        EventBus.evidence_dropped.emit(evidence_id)
```

- Boss explodes/fades
- Defeat dialogue plays
- Evidence item spawns
- Player collects evidence for conspiracy board

---

## Difficulty Scaling

Bosses scale based on player mutations:

```gdscript
func apply_difficulty_scaling(mutation_count: int, hard_mode: bool = false) -> void:
    # HP scaling: +5% per mutation, max 1.5x
    var hp_scale = 1.0 + min(mutation_count * hp_scale_per_mutation, max_scaling - 1.0)

    # Speed scaling: +2% per mutation, max 1.5x
    var speed_scale = 1.0 + min(mutation_count * speed_scale_per_mutation, max_scaling - 1.0)

    if hard_mode:
        hp_scale *= hard_mode_multiplier
        speed_scale *= hard_mode_multiplier

    total_hp = int(total_hp * hp_scale)
    current_hp = total_hp
```

### Scaling Examples

| Mutations | HP Scale | Effective HP |
|-----------|----------|--------------|
| 0 | 1.0x | 100 |
| 5 | 1.25x | 125 |
| 10 | 1.5x | 150 |
| 10 + Hard Mode | 2.25x | 225 |

---

## Signals

| Signal | When Emitted |
|--------|--------------|
| `phase_changed` | Boss enters new phase |
| `boss_defeated` | Boss HP reaches 0 |
| `dialogue_triggered` | Dialogue line should display |

### Usage

```gdscript
# In combat scene
boss.phase_changed.connect(_on_boss_phase_changed)
boss.boss_defeated.connect(_on_boss_defeated)
boss.dialogue_triggered.connect(_on_boss_dialogue)

func _on_boss_phase_changed(phase: int) -> void:
    # Update music intensity
    AudioManager.set_boss_phase(phase)

func _on_boss_defeated() -> void:
    # Victory screen, XP reward
    $VictoryUI.show()

func _on_boss_dialogue(text: String) -> void:
    $DialogueBox.show_text(text)
```

---

## Tunable Parameters

### Base Parameters

| Parameter | Type | Default | Effect |
|-----------|------|---------|--------|
| `total_hp` | int | 100 | Base health |
| `phase_2_threshold` | float | 0.66 | HP% for Phase 2 |
| `phase_3_threshold` | float | 0.33 | HP% for Phase 3 |
| `phase_transition_duration` | float | 2.0 | Transition time |
| `intro_duration` | float | 3.0 | Intro sequence time |
| `evidence_spawn_delay` | float | 1.0 | Post-defeat wait |

### Scaling Parameters

| Parameter | Type | Default | Effect |
|-----------|------|---------|--------|
| `hp_scale_per_mutation` | float | 0.05 | +5% HP per mutation |
| `speed_scale_per_mutation` | float | 0.02 | +2% speed per mutation |
| `max_scaling` | float | 1.5 | Maximum 1.5x scaling |
| `hard_mode_multiplier` | float | 1.5 | Hard mode extra scaling |

---

## Integration Points

### With Combat System

```gdscript
# Player tongue hits boss
func _on_tongue_hit_boss(boss: BossBase) -> void:
    var damage = player.attack_damage
    boss.take_damage(damage)
```

### With EventBus

```gdscript
# Boss signals events
EventBus.boss_phase_changed.emit(boss_name, phase)
EventBus.boss_defeated.emit(boss_name)
EventBus.evidence_dropped.emit(evidence_id)
```

### With Save System

```gdscript
# Track defeated bosses
save_data.defeated_bosses.append(boss_name)
save_data.collected_evidence.append(evidence_id)
```

---

## MVP Bosses

| Boss | HP | Evidence | Phases |
|------|-----|----------|--------|
| The Lobbyist | 100 | lobbyist_evidence | Aimed → Radial → Spiral |
| The CEO | 150 | ceo_evidence | Walls → Homing → Chaos |

### Alpha Planned

| Boss | HP | Evidence | Theme |
|------|-----|----------|-------|
| The Researcher | 125 | researcher_evidence | Lab experiments gone wrong |

### Beta Planned

| Boss | HP | Evidence | Theme |
|------|-----|----------|-------|
| Sentient Pond | 200 | final_evidence | The pond fights back |

---

## Story Traceability

| Story | Description | Status |
|-------|-------------|--------|
| BOSS-001 | BossBase framework | Complete |
| BOSS-002 | Lobbyist implementation | Complete |
| BOSS-003 | CEO implementation | Complete |
| BOSS-004 | Phase transition system | Complete |
| BOSS-005 | Evidence drop system | Complete |
| BOSS-006 | Difficulty scaling | Complete |

---

## Next Steps

If you're implementing bosses:

1. Read [The Lobbyist](lobbyist.md) - first boss example
2. Read [The CEO](ceo.md) - final boss complexity
3. Understand [Pattern Design](pattern-design.md) - bullet pattern philosophy
4. Plan future bosses with Alpha/Beta docs

---

[Back to Index](../index.md) | [Next: The Lobbyist](lobbyist.md)
