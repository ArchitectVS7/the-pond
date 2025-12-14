# Synergies

When certain mutations combine, synergies activate. These provide bonus effects beyond the individual mutations. This chapter covers the synergy system.

---

## The Concept

Synergies reward build planning. A player who collects three specific mutations gets a powerful bonus. This creates:

- **Discoverability**: Players experiment to find combos
- **Strategy**: Targeting synergies vs. taking immediate power
- **Replayability**: Different synergies encourage different builds

---

## SynergyResource Structure

**File**: `metagame/resources/SynergyResource.gd`

```gdscript
class_name SynergyResource
extends Resource

@export var id: String
@export var synergy_name: String
@export var description: String
@export var required_mutations: Array[String] = []
@export var bonus_effects: Dictionary = {}

## Check if synergy is active based on player mutations
func check_active(player_mutations: Array[String]) -> bool:
    for req in required_mutations:
        if req not in player_mutations:
            return false
    return true

## Get bonus effects dictionary
func get_bonus_effects() -> Dictionary:
    return bonus_effects.duplicate()
```

---

## Field Reference

| Field | Type | Purpose |
|-------|------|---------|
| `id` | String | Unique identifier |
| `synergy_name` | String | Display name |
| `description` | String | Effect description |
| `required_mutations` | Array[String] | Mutation IDs needed |
| `bonus_effects` | Dictionary | Stat bonuses when active |

---

## MVP Synergies

### Apex Predator

**File**: `metagame/resources/synergies/apex_predator.tres`

```tres
id = "apex_predator"
synergy_name = "Apex Predator"
description = "Perfect hunting machine - attack speed massively increased"
required_mutations = ["quick_tongue", "long_reach", "strong_legs"]
bonus_effects = {
    "attack_cooldown": -0.25
}
```

**Requirements**: Quick Tongue + Long Reach + Strong Legs

**Bonus**: -25% attack cooldown (stacks with mutation effects)

**Theme**: Offense-focused frog that strikes fast and hard

---

### Pollution Immune

**File**: `metagame/resources/synergies/pollution_immune.tres`

```tres
id = "pollution_immune"
synergy_name = "Pollution Immune"
description = "Your body has adapted to toxins - immune to your own pollution effects"
required_mutations = ["oil_slick", "toxic_aura", "tough_skin"]
bonus_effects = {
    "hp": 1
}
```

**Requirements**: Oil Slick + Toxic Aura + Tough Skin

**Bonus**: +1 HP

**Theme**: Embrace pollution mutations safely. The HP bonus offsets risky builds.

---

### Swamp King

**File**: `metagame/resources/synergies/swamp_king.tres`

```tres
id = "swamp_king"
synergy_name = "Swamp King"
description = "Master of the wetlands - greatly enhanced mobility on water surfaces"
required_mutations = ["lily_pad", "slippery", "speed_boost"]
bonus_effects = {
    "speed": 0.5
}
```

**Requirements**: Lily Pad + Slippery + Speed Boost

**Bonus**: +50% speed

**Theme**: Mobility-focused build. Combined with individual bonuses, creates extreme speed.

---

## Synergy Detection

The `MutationManager` checks synergies whenever mutations change:

```gdscript
func _check_synergies() -> void:
    var player_mutation_ids = get_active_mutation_ids()
    var newly_active: Array[SynergyResource] = []
    var newly_inactive: Array[SynergyResource] = []

    # Check each synergy
    for synergy in available_synergies:
        var is_active = synergy.check_active(player_mutation_ids)
        var was_active = synergy in active_synergies

        if is_active and not was_active:
            newly_active.append(synergy)
        elif not is_active and was_active:
            newly_inactive.append(synergy)

    # Update state and emit signals
    for synergy in newly_active:
        active_synergies.append(synergy)
        synergy_activated.emit(synergy)
        EventBus.synergy_activated.emit({
            "id": synergy.id,
            "name": synergy.synergy_name,
            "description": synergy.description
        })

    for synergy in newly_inactive:
        active_synergies.erase(synergy)
        synergy_deactivated.emit(synergy)

    # Reapply modifiers if synergies changed
    if newly_active.size() > 0 or newly_inactive.size() > 0:
        _apply_modifiers()
```

---

## Bonus Application

Synergy bonuses apply after mutation modifiers:

```gdscript
func _apply_modifiers() -> void:
    current_stats = base_stats.duplicate()

    # First: Apply mutation modifiers
    for mutation in active_mutations:
        # ... apply mutation effects

    # Second: Apply synergy bonuses
    for synergy in active_synergies:
        var bonus = synergy.get_bonus_effects()
        for key in bonus:
            if key in current_stats:
                if typeof(current_stats[key]) == TYPE_FLOAT:
                    current_stats[key] = current_stats[key] * (1.0 + bonus[key])
                else:
                    current_stats[key] = current_stats[key] + bonus[key]

    stats_changed.emit(current_stats)
```

### Stacking Example: Swamp King

```
Base speed: 200 px/s
+ Speed Boost (+20%): 200 * 1.2 = 240 px/s
+ Slippery (indirect speed): no direct effect
+ Lily Pad: no direct effect
+ Swamp King synergy (+50%): 240 * 1.5 = 360 px/s
```

The synergy bonus multiplies the already-modified stat.

---

## Creating a Synergy

### Step 1: Design the Synergy

Choose:
- 3 required mutations (thematically linked)
- Bonus effect (significant but not game-breaking)
- Name and description

### Step 2: Create the .tres File

```tres
# metagame/resources/synergies/my_synergy.tres
[gd_resource type="Resource" script_class="SynergyResource" load_steps=2 format=3]

[ext_resource type="Script" path="res://metagame/resources/SynergyResource.gd" id="1"]

[resource]
script = ExtResource("1")
id = "my_synergy"
synergy_name = "My Synergy"
description = "Description of the bonus effect"
required_mutations = ["mutation_a", "mutation_b", "mutation_c"]
bonus_effects = {
    "speed": 0.3
}
```

### Step 3: Place in Synergies Folder

The file must be in `metagame/resources/synergies/` for auto-loading.

---

## Synergy Loading

Synergies are loaded at runtime from the synergies directory:

```gdscript
func _load_synergies() -> void:
    var synergy_dir = "res://metagame/resources/synergies/"
    if DirAccess.dir_exists_absolute(synergy_dir):
        var dir = DirAccess.open(synergy_dir)
        if dir:
            dir.list_dir_begin()
            var file_name = dir.get_next()
            while file_name != "":
                if file_name.ends_with(".tres"):
                    var synergy = load(synergy_dir + file_name) as SynergyResource
                    if synergy:
                        available_synergies.append(synergy)
                file_name = dir.get_next()
            dir.list_dir_end()
```

No manual registration needed - drop `.tres` files in the folder.

---

## UI Integration

### Synergy Hints

Each mutation includes a `synergy_hint` field:

```tres
synergy_hint = "Part of Swamp King combo"
```

Displayed on mutation cards to guide players toward synergies.

### Synergy Activation Notification

When a synergy activates, show feedback:

```gdscript
EventBus.synergy_activated.connect(_on_synergy_activated)

func _on_synergy_activated(data: Dictionary) -> void:
    # Show notification
    $SynergyPopup.show_synergy(data.name, data.description)

    # Play fanfare
    AudioManager.play_sfx("synergy_unlock")
```

---

## Design Guidelines

### Mutation Selection

Choose mutations that:
- Share a theme (speed, damage, defense)
- Aren't all "must-picks" (create interesting choices)
- Come from different categories when possible

### Bonus Magnitude

| Bonus Type | Recommended |
|------------|-------------|
| Speed | +30-50% |
| Damage | +25-40% |
| HP | +1-2 |
| Cooldown | -20-30% |

Synergy bonuses should feel impactful but not trivialize the game.

### Thematic Coherence

- **Apex Predator**: Attack mutations → more attack power
- **Pollution Immune**: Pollution mutations → survivability
- **Swamp King**: Mobility mutations → extreme speed

The bonus should amplify the build's identity.

---

## Potential Future Synergies

### Alpha Phase

| Synergy | Mutations | Bonus |
|---------|-----------|-------|
| Glass Cannon | Mercury Blood + Strong Legs + Quick Tongue | +100% damage when at 1 HP |
| Tank | Tough Skin + Regeneration + Sticky Feet | -25% damage taken |

### Beta Phase

| Synergy | Mutations | Bonus |
|---------|-----------|-------|
| Venomous | Toxic Aura + War Croak + Split Tongue | Attacks poison enemies |
| Ninja Frog | Big Eyes + Double Jump + Slippery | Brief invisibility on dodge |

---

## Common Issues

**Synergy doesn't activate:**
- Verify all required mutation IDs match exactly
- Check mutations are in `active_mutations` array
- Ensure synergy .tres is in correct folder

**Synergy activates incorrectly:**
- Check for duplicate mutation IDs
- Verify `check_active()` logic
- Test with exact mutation combination

**Bonus doesn't apply:**
- Confirm `_apply_modifiers()` runs after synergy detection
- Check `bonus_effects` dictionary keys match stat names
- Verify type compatibility (float vs int)

---

## Summary

| Synergy | Mutations | Bonus |
|---------|-----------|-------|
| Apex Predator | quick_tongue + long_reach + strong_legs | -25% cooldown |
| Pollution Immune | oil_slick + toxic_aura + tough_skin | +1 HP |
| Swamp King | lily_pad + slippery + speed_boost | +50% speed |

Synergies add depth without complexity. Three mutations, one bonus, clear feedback.

---

[← Back to Mutation Data](mutation-data.md) | [Next: Pollution Index →](pollution-index.md)
