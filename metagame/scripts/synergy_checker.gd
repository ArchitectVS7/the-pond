extends Node
class_name SynergyChecker

## Utility class for synergy detection and management
## Used by MutationManager to check synergy activation

## Check if synergy requirements are met
static func check_synergy(synergy: SynergyResource, player_mutations: Array[String]) -> bool:
	return synergy.check_active(player_mutations)

## Get all active synergies from a list
static func get_active_synergies(
	all_synergies: Array[SynergyResource],
	player_mutations: Array[String]
) -> Array[SynergyResource]:
	var active: Array[SynergyResource] = []
	for synergy in all_synergies:
		if check_synergy(synergy, player_mutations):
			active.append(synergy)
	return active

## Calculate combined synergy bonuses
static func calculate_synergy_bonuses(active_synergies: Array[SynergyResource]) -> Dictionary:
	var combined_bonus: Dictionary = {}

	for synergy in active_synergies:
		var bonus = synergy.get_bonus_effects()
		for key in bonus:
			if key in combined_bonus:
				combined_bonus[key] += bonus[key]
			else:
				combined_bonus[key] = bonus[key]

	return combined_bonus
