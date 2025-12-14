class_name MutationResource
extends Resource

## Core mutation data structure for Pond Conspiracy roguelike system
## Defines stat modifiers, special abilities, and synergy hints

enum MutationType { FROG, POLLUTION, HYBRID }

@export var id: String
@export var mutation_name: String
@export var description: String
@export var icon: Texture2D
@export var type: MutationType = MutationType.FROG
@export var pollution_cost: int = 0

# Stat modifiers (additive/multiplicative based on context)
@export var speed_modifier: float = 0.0
@export var damage_modifier: float = 0.0
@export var hp_modifier: int = 0
@export var attack_cooldown_modifier: float = 0.0
@export var range_modifier: float = 0.0
@export var crit_chance_modifier: float = 0.0
@export var dodge_chance_modifier: float = 0.0

# Special ability system
@export var has_special_ability: bool = false
@export var ability_id: String = ""
@export var ability_cooldown: float = 0.0

# Synergy hints for UI tooltips
@export var synergy_hint: String = ""

## Returns all stat modifiers as a dictionary
func get_stat_modifiers() -> Dictionary:
	return {
		"speed": speed_modifier,
		"damage": damage_modifier,
		"hp": hp_modifier,
		"attack_cooldown": attack_cooldown_modifier,
		"range": range_modifier,
		"crit_chance": crit_chance_modifier,
		"dodge_chance": dodge_chance_modifier
	}

## Serialize mutation to dictionary for events/saving
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
