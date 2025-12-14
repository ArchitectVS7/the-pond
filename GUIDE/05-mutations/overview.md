# Mutations Overview

The mutation system is The Pond's roguelike progression core. Each run, players collect mutations that stack, synergize, and transform their frog. This chapter covers the implementation.

---

## The Core Concept

Mutations represent evolutionary adaptations - some natural frog abilities, others pollutant-induced changes. The tension between power (pollution mutations) and safety (frog mutations) creates meaningful choices.

16 mutations ship in MVP. More planned for Alpha/Beta.

---

## What's Here

| File | What It Covers |
|------|----------------|
| [Mutation Data](mutation-data.md) | Resource structure, creating new mutations |
| [Synergies](synergies.md) | Combination bonuses, synergy detection |
| [Pollution Index](pollution-index.md) | Pollution meter, environmental feedback |
| [Balancing](balancing.md) | Parameter tuning, design philosophy |

---

## System Architecture

```
metagame/
├── resources/
│   ├── MutationResource.gd      # Mutation data structure
│   ├── SynergyResource.gd       # Synergy combination logic
│   ├── mutations/               # 16 mutation .tres files
│   │   ├── speed_boost.tres
│   │   ├── toxic_aura.tres
│   │   └── ...
│   └── synergies/               # 3 synergy .tres files
│       ├── apex_predator.tres
│       ├── pollution_immune.tres
│       └── swamp_king.tres
├── scripts/
│   ├── mutation_manager.gd      # Central mutation logic
│   ├── level_up_ui.gd           # Selection interface
│   ├── mutation_card.gd         # Card component
│   └── pollution_meter.gd       # HUD pollution display
└── scenes/
    ├── LevelUpUI.tscn           # Level-up screen
    └── MutationCard.tscn        # Card visual
```

---

## Key Files

| File | Purpose |
|------|---------|
| `metagame/resources/MutationResource.gd` | Mutation data definition |
| `metagame/resources/SynergyResource.gd` | Synergy logic |
| `metagame/scripts/mutation_manager.gd` | Mutation state, stat calculation |
| `metagame/scripts/level_up_ui.gd` | Selection UI, game pause |
| `metagame/scripts/pollution_meter.gd` | Visual pollution feedback |

---

## Mutation Types

Three mutation categories exist:

```gdscript
enum MutationType { FROG, POLLUTION, HYBRID }
```

| Type | Theme | Pollution Cost |
|------|-------|----------------|
| FROG | Natural adaptations | 0 |
| POLLUTION | Chemical mutations | 10-20 |
| HYBRID | Mixed origin | 0-10 |

### Frog Mutations (Safe)

Natural abilities with no pollution cost:

| Mutation | Effect |
|----------|--------|
| Swift Legs | +20% movement speed |
| Quick Tongue | -20% attack cooldown |
| Long Reach | +20% tongue range |
| Double Jump | Jump again mid-air |
| Sticky Feet | Cling to walls |
| Big Eyes | +10% dodge chance |
| Strong Legs | +15% damage |
| Slippery | -10% attack cooldown |
| Regeneration | Heal 1 HP between waves |
| Lily Pad | Summon temporary platform |
| War Croak | Stun nearby enemies |
| Split Tongue | Hit 2 targets per attack |

### Pollution Mutations (Risky)

Powerful but add pollution:

| Mutation | Effect | Pollution |
|----------|--------|-----------|
| Oil Slick | Leave damaging trail | +15 |
| Toxic Aura | AoE damage | +12 |
| Mercury Blood | +50% damage, -1 HP | +20 |

---

## Interaction Flow

### Level-Up Event

1. Player defeats enough enemies (XP threshold)
2. Game pauses, `LevelUpUI.show_level_up()` called
3. Three random mutations presented
4. Player selects one
5. `MutationManager.add_mutation()` applies effects
6. Synergies checked automatically
7. Game resumes

### Stat Calculation

```gdscript
# In mutation_manager.gd
func _apply_modifiers() -> void:
    current_stats = base_stats.duplicate()

    # Apply mutation modifiers
    for mutation in active_mutations:
        var mods = mutation.get_stat_modifiers()
        current_stats.speed = current_stats.speed * (1.0 + mods.speed)
        current_stats.damage = current_stats.damage * (1.0 + mods.damage)
        # ... other stats

    # Apply synergy bonuses
    for synergy in active_synergies:
        var bonus = synergy.get_bonus_effects()
        # ... apply bonuses

    stats_changed.emit(current_stats)
```

---

## Signals

| Signal | When Emitted |
|--------|--------------|
| `mutation_added` | New mutation acquired |
| `mutation_removed` | Mutation lost |
| `stats_changed` | Stats recalculated |
| `synergy_activated` | Synergy combo achieved |
| `synergy_deactivated` | Synergy broken |

---

## Integration Points

### With Combat

```gdscript
# Player receives stat changes
MutationManager.stats_changed.connect(_on_stats_changed)

func _on_stats_changed(new_stats: Dictionary) -> void:
    move_speed = new_stats.speed
    attack_damage = new_stats.damage
    max_hp = new_stats.max_hp
```

### With Save System

```gdscript
# Serialize mutation state
save_data.mutations = {
    "active_ids": mutation_manager.get_active_mutation_ids(),
    "synergies": mutation_manager.active_synergies.map(func(s): return s.id)
}
```

### With Pollution Meter

```gdscript
# Update pollution display
EventBus.pollution_changed.connect(pollution_meter.set_pollution)
```

---

## Tunable Parameters Quick Reference

### System Limits

| Parameter | Default | Effect |
|-----------|---------|--------|
| `max_mutations` | 10 | Maximum mutations per run |
| `allow_duplicates` | false | Prevent duplicate selections |

### Level-Up UI

| Parameter | Default | Effect |
|-----------|---------|--------|
| `options_count` | 3 | Choices presented |
| `card_width` | 200 | Card width (px) |
| `card_height` | 280 | Card height (px) |
| `animation_duration` | 0.3 | Fade in/out time |

### Pollution Meter

| Parameter | Default | Effect |
|-----------|---------|--------|
| `pollution_per_mutation` | 15.0 | Base pollution weight |
| `threshold_low` | 0.33 | Green-yellow boundary |
| `threshold_high` | 0.67 | Yellow-red boundary |

---

## Story Traceability

| Story | Description | Status |
|-------|-------------|--------|
| MUT-001 | MutationResource definition | Complete |
| MUT-002 | MutationManager implementation | Complete |
| MUT-003 | Level-up UI | Complete |
| MUT-004 | 16 mutations created | Complete |
| MUT-005 | Synergy system | Complete |
| MUT-006 | Pollution meter UI | Complete |

---

## Next Steps

If you're implementing mutations:

1. Start with [Mutation Data](mutation-data.md) - understand the structure
2. Learn about [Synergies](synergies.md) - combo system
3. Review [Pollution Index](pollution-index.md) - risk/reward feedback
4. Tune with [Balancing](balancing.md) - parameter guide

---

[Back to Index](../index.md) | [Next: Mutation Data](mutation-data.md)
