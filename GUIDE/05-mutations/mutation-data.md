# Mutation Data

Each mutation is a Resource file (`.tres`) with defined stats. This chapter covers the MutationResource structure and how to create new mutations.

---

## MutationResource Structure

**File**: `metagame/resources/MutationResource.gd`

```gdscript
class_name MutationResource
extends Resource

enum MutationType { FROG, POLLUTION, HYBRID }

@export var id: String
@export var mutation_name: String
@export var description: String
@export var icon: Texture2D
@export var type: MutationType = MutationType.FROG
@export var pollution_cost: int = 0

# Stat modifiers (multiplicative)
@export var speed_modifier: float = 0.0
@export var damage_modifier: float = 0.0
@export var hp_modifier: int = 0
@export var attack_cooldown_modifier: float = 0.0
@export var range_modifier: float = 0.0
@export var crit_chance_modifier: float = 0.0
@export var dodge_chance_modifier: float = 0.0

# Special abilities
@export var has_special_ability: bool = false
@export var ability_id: String = ""
@export var ability_cooldown: float = 0.0

# UI hints
@export var synergy_hint: String = ""
```

---

## Field Reference

### Identity Fields

| Field | Type | Purpose |
|-------|------|---------|
| `id` | String | Unique identifier ("speed_boost") |
| `mutation_name` | String | Display name ("Swift Legs") |
| `description` | String | Full description with effects |
| `icon` | Texture2D | Card icon (32x32 recommended) |
| `type` | MutationType | Category for filtering |

### Stat Modifiers

All modifiers are multiplicative percentages. +0.2 means +20%.

| Field | Type | Example |
|-------|------|---------|
| `speed_modifier` | float | 0.2 = +20% speed |
| `damage_modifier` | float | 0.5 = +50% damage |
| `hp_modifier` | int | 1 = +1 HP, -1 = -1 HP |
| `attack_cooldown_modifier` | float | -0.2 = 20% faster attacks |
| `range_modifier` | float | 0.2 = +20% tongue range |
| `crit_chance_modifier` | float | 0.1 = +10% crit chance |
| `dodge_chance_modifier` | float | 0.1 = +10% dodge chance |

### Special Abilities

| Field | Type | Purpose |
|-------|------|---------|
| `has_special_ability` | bool | Enables ability system |
| `ability_id` | String | Links to ability script |
| `ability_cooldown` | float | Ability cooldown (seconds) |

---

## Creating a Mutation

### Step 1: Create the .tres File

```tres
# metagame/resources/mutations/my_mutation.tres
[gd_resource type="Resource" script_class="MutationResource" load_steps=2 format=3]

[ext_resource type="Script" path="res://metagame/resources/MutationResource.gd" id="1"]

[resource]
script = ExtResource("1")
id = "my_mutation"
mutation_name = "Awesome Ability"
description = "Does something cool.\n+30% Speed"
type = 0
pollution_cost = 0
speed_modifier = 0.3
```

### Step 2: Set Properties

In the Godot inspector:

1. **id**: Use snake_case, unique
2. **mutation_name**: Player-facing name
3. **description**: Include effect values, use `\n` for line breaks
4. **type**: 0=FROG, 1=POLLUTION, 2=HYBRID
5. **pollution_cost**: 0 for safe, 10-20 for risky
6. **modifiers**: Set stat changes

### Step 3: Add Icon (Optional)

```gdscript
icon = preload("res://assets/icons/mutations/my_mutation.png")
```

---

## Existing Mutations Reference

### Frog Type (Safe)

**speed_boost.tres**
```tres
id = "speed_boost"
mutation_name = "Swift Legs"
description = "Your powerful frog legs propel you 20% faster.\n+20% Move Speed"
type = 0
pollution_cost = 0
speed_modifier = 0.2
synergy_hint = "Combine with water mutations"
```

**quick_tongue.tres**
```tres
id = "quick_tongue"
mutation_name = "Quick Tongue"
description = "Lightning-fast strikes.\n-20% Attack Cooldown"
type = 0
attack_cooldown_modifier = -0.2
```

**long_reach.tres**
```tres
id = "long_reach"
mutation_name = "Long Reach"
description = "Extended tongue range.\n+20% Tongue Range"
type = 0
range_modifier = 0.2
```

**lily_pad.tres** (Ability)
```tres
id = "lily_pad"
mutation_name = "Lily Pad"
description = "Summon a temporary platform beneath you.\n5 second duration, 8 second cooldown"
type = 0
has_special_ability = true
ability_id = "lily_pad"
ability_cooldown = 8.0
synergy_hint = "Part of Swamp King combo"
```

### Pollution Type (Risky)

**toxic_aura.tres**
```tres
id = "toxic_aura"
mutation_name = "Toxic Aura"
description = "Emit poisonous fumes that damage nearby enemies.\n1 damage per second in 80 unit radius\n[WARNING] +12 Pollution"
type = 1
pollution_cost = 12
has_special_ability = true
ability_id = "toxic_aura"
synergy_hint = "Part of Pollution Immune combo"
```

**mercury_blood.tres**
```tres
id = "mercury_blood"
mutation_name = "Mercury Blood"
description = "Toxic mercury infusion grants immense power at a cost.\n+50% Damage\n-1 Max HP\n[WARNING] +20 Pollution"
type = 1
pollution_cost = 20
damage_modifier = 0.5
hp_modifier = -1
synergy_hint = "High risk, high reward"
```

---

## Stat Application

Modifiers apply multiplicatively in `MutationManager`:

```gdscript
func _apply_modifiers() -> void:
    current_stats = base_stats.duplicate()

    for mutation in active_mutations:
        var mods = mutation.get_stat_modifiers()

        # Multiplicative application
        current_stats.speed = current_stats.speed * (1.0 + mods.speed)
        current_stats.damage = current_stats.damage * (1.0 + mods.damage)
        current_stats.max_hp = current_stats.max_hp + mods.hp
        current_stats.attack_cooldown = current_stats.attack_cooldown * (1.0 + mods.attack_cooldown)
        current_stats.range = current_stats.range * (1.0 + mods.range)

        # Additive with clamping
        current_stats.crit_chance = clampf(current_stats.crit_chance + mods.crit_chance, 0.0, 1.0)
        current_stats.dodge_chance = clampf(current_stats.dodge_chance + mods.dodge_chance, 0.0, 1.0)
```

### Stacking Behavior

Multiple speed mutations stack:

```
Base speed: 200 px/s
+20% (Swift Legs): 200 * 1.2 = 240 px/s
+15% (Slippery): 240 * 1.15 = 276 px/s
```

This multiplicative stacking allows powerful builds without linear addition.

---

## Special Abilities

For mutations with active abilities:

### 1. Set Ability Fields

```tres
has_special_ability = true
ability_id = "lily_pad"
ability_cooldown = 8.0
```

### 2. Create Ability Script

```gdscript
# metagame/scripts/abilities/lily_pad_ability.gd
class_name LilyPadAbility
extends AbilityBase

func activate() -> void:
    var platform = preload("res://combat/scenes/LilyPad.tscn").instantiate()
    platform.position = get_player_position()
    platform.duration = 5.0
    get_tree().current_scene.add_child(platform)
```

### 3. Register in Ability Manager

```gdscript
# The ability system looks up abilities by ability_id
ability_registry["lily_pad"] = LilyPadAbility.new()
```

---

## Mutation Serialization

For save/load and events:

```gdscript
func to_dict() -> Dictionary:
    return {
        "id": id,
        "name": mutation_name,
        "type": MutationType.keys()[type],
        "pollution_cost": pollution_cost,
        "modifiers": get_stat_modifiers(),
        "has_ability": has_special_ability,
        "ability_id": ability_id
    }
```

---

## Design Guidelines

### Naming Conventions

- **IDs**: snake_case, descriptive (`speed_boost`, `toxic_aura`)
- **Names**: Thematic, frog-related (`Swift Legs`, `War Croak`)
- **Descriptions**: Effect first, numbers explicit

### Description Format

```
[Short flavor text]
[Effect line 1]
[Effect line 2]
[WARNING] +X Pollution (if applicable)
```

### Balance Guidelines

| Modifier | Safe Range | Risky Range |
|----------|------------|-------------|
| speed | 10-25% | 30-50% |
| damage | 10-25% | 40-60% |
| cooldown | -10% to -25% | -30% to -50% |
| hp | +1 to +2 | -1 (with other benefits) |
| pollution | 0 | 10-20 |

---

## All 16 MVP Mutations

| ID | Name | Type | Key Effect |
|----|------|------|------------|
| speed_boost | Swift Legs | FROG | +20% speed |
| tough_skin | Tough Skin | FROG | +1 HP |
| quick_tongue | Quick Tongue | FROG | -20% cooldown |
| long_reach | Long Reach | FROG | +20% range |
| double_jump | Double Jump | FROG | Mid-air jump |
| sticky_feet | Sticky Feet | FROG | Wall cling |
| big_eyes | Big Eyes | FROG | +10% dodge |
| strong_legs | Strong Legs | FROG | +15% damage |
| slippery | Slippery | FROG | -10% cooldown |
| regeneration | Regeneration | FROG | Wave healing |
| lily_pad | Lily Pad | FROG | Platform ability |
| war_croak | War Croak | FROG | Stun ability |
| split_tongue | Split Tongue | FROG | Multi-target |
| oil_slick | Oil Slick | POLLUTION | Damage trail |
| toxic_aura | Toxic Aura | POLLUTION | AoE damage |
| mercury_blood | Mercury Blood | POLLUTION | +50% dmg, -1 HP |

---

## Common Issues

**Mutation doesn't appear in selection:**
- Verify `.tres` file is in `metagame/resources/mutations/`
- Check file uses correct script class
- Ensure `id` is unique

**Stats don't apply:**
- Confirm mutation is in `active_mutations` array
- Check `_apply_modifiers()` is being called
- Verify modifier values are percentages (0.2, not 20)

**Icon doesn't show:**
- Check icon path is correct
- Verify texture is 32x32 PNG
- Ensure icon field is set in .tres

---

[← Back to Overview](overview.md) | [Next: Synergies →](synergies.md)
