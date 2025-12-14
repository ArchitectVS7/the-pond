extends Node
class_name MutationManager

## Central mutation management system for Pond Conspiracy
## Handles mutation application, stat calculation, and synergy detection

signal mutation_added(mutation: MutationResource)
signal mutation_removed(mutation: MutationResource)
signal stats_changed(new_stats: Dictionary)
signal synergy_activated(synergy: SynergyResource)
signal synergy_deactivated(synergy: SynergyResource)

@export var max_mutations: int = 10
@export var allow_duplicates: bool = false

var active_mutations: Array[MutationResource] = []
var active_synergies: Array[SynergyResource] = []
var base_stats: Dictionary = {}
var current_stats: Dictionary = {}

# Synergy database (loaded at runtime)
var available_synergies: Array[SynergyResource] = []

func _ready() -> void:
	# Store base stats from player
	_cache_base_stats()
	# Load available synergies
	_load_synergies()

## Add a mutation to the player
func add_mutation(mutation: MutationResource) -> bool:
	if active_mutations.size() >= max_mutations:
		push_warning("Cannot add mutation: max mutations reached")
		return false

	if not allow_duplicates and has_mutation(mutation.id):
		push_warning("Cannot add mutation: duplicate not allowed")
		return false

	active_mutations.append(mutation)
	_apply_modifiers()
	_check_synergies()
	mutation_added.emit(mutation)

	if mutation.pollution_cost > 0:
		EventBus.pollution_changed.emit(get_total_pollution())

	return true

## Remove a mutation by ID
func remove_mutation(mutation_id: String) -> bool:
	for i in range(active_mutations.size()):
		if active_mutations[i].id == mutation_id:
			var removed = active_mutations[i]
			active_mutations.remove_at(i)
			_apply_modifiers()
			_check_synergies()
			mutation_removed.emit(removed)
			EventBus.pollution_changed.emit(get_total_pollution())
			return true
	return false

## Check if player has a specific mutation
func has_mutation(mutation_id: String) -> bool:
	for m in active_mutations:
		if m.id == mutation_id:
			return true
	return false

## Get total pollution from all mutations
func get_total_pollution() -> int:
	var total = 0
	for m in active_mutations:
		total += m.pollution_cost
	return total

## Get list of active mutation IDs
func get_active_mutation_ids() -> Array[String]:
	var ids: Array[String] = []
	for m in active_mutations:
		ids.append(m.id)
	return ids

## Recalculate player stats based on active mutations and synergies
func _apply_modifiers() -> void:
	current_stats = base_stats.duplicate()

	# Apply mutation modifiers
	for mutation in active_mutations:
		var mods = mutation.get_stat_modifiers()
		current_stats.speed = current_stats.speed * (1.0 + mods.speed)
		current_stats.damage = current_stats.damage * (1.0 + mods.damage)
		current_stats.max_hp = current_stats.max_hp + mods.hp
		current_stats.attack_cooldown = current_stats.attack_cooldown * (1.0 + mods.attack_cooldown)
		current_stats.range = current_stats.range * (1.0 + mods.range)
		current_stats.crit_chance = clampf(current_stats.crit_chance + mods.crit_chance, 0.0, 1.0)
		current_stats.dodge_chance = clampf(current_stats.dodge_chance + mods.dodge_chance, 0.0, 1.0)

	# Apply synergy bonuses
	for synergy in active_synergies:
		var bonus = synergy.get_bonus_effects()
		for key in bonus:
			if key in current_stats:
				if typeof(current_stats[key]) == TYPE_FLOAT:
					current_stats[key] = current_stats[key] * (1.0 + bonus[key])
				else:
					current_stats[key] = current_stats[key] + bonus[key]

	stats_changed.emit(current_stats)

## Check for active synergies
func _check_synergies() -> void:
	var player_mutation_ids = get_active_mutation_ids()
	var newly_active: Array[SynergyResource] = []
	var newly_inactive: Array[SynergyResource] = []

	# Check which synergies are now active
	for synergy in available_synergies:
		var is_active = synergy.check_active(player_mutation_ids)
		var was_active = synergy in active_synergies

		if is_active and not was_active:
			newly_active.append(synergy)
		elif not is_active and was_active:
			newly_inactive.append(synergy)

	# Update active synergies
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

## Cache base stats from parent player node
func _cache_base_stats() -> void:
	var player = get_parent()
	if player:
		base_stats = {
			"speed": player.get("move_speed") if player.get("move_speed") else 200.0,
			"damage": player.get("base_damage") if player.get("base_damage") else 10,
			"max_hp": player.get("max_hp") if player.get("max_hp") else 5,
			"attack_cooldown": 0.5,
			"range": 100.0,
			"crit_chance": 0.05,
			"dodge_chance": 0.0
		}
		current_stats = base_stats.duplicate()

## Load synergy resources from disk
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
