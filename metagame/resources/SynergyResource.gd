class_name SynergyResource
extends Resource

## Synergy combination resource for mutation interactions
## Checks if required mutations are active and provides bonus effects

@export var id: String
@export var synergy_name: String
@export var description: String
@export var required_mutations: Array[String] = []
@export var bonus_effects: Dictionary = {}

## Check if this synergy is currently active based on player's mutations
func check_active(player_mutations: Array[String]) -> bool:
	for req in required_mutations:
		if req not in player_mutations:
			return false
	return true

## Get the bonus effects for applying to player stats
func get_bonus_effects() -> Dictionary:
	return bonus_effects.duplicate()
