extends GutTest

## Unit tests for synergy system
## Tests synergy detection, activation, and bonus application

var mutation_manager: MutationManager
var test_player: Node

func before_each():
	# Create test player node
	test_player = Node.new()
	test_player.set("move_speed", 200.0)
	test_player.set("base_damage", 10)
	test_player.set("max_hp", 5)
	add_child(test_player)

	# Create mutation manager
	mutation_manager = MutationManager.new()
	test_player.add_child(mutation_manager)

	# Wait for ready
	await wait_frames(1)

func after_each():
	test_player.queue_free()

## Test synergy resource creation
func test_synergy_creation():
	var synergy = _create_test_synergy(
		"test_synergy",
		["mut1", "mut2"],
		{"speed": 0.5}
	)

	assert_eq(synergy.id, "test_synergy", "Synergy should have correct ID")
	assert_eq(synergy.required_mutations.size(), 2, "Should have 2 required mutations")
	assert_has(synergy.bonus_effects, "speed", "Should have speed bonus")

## Test synergy check_active with all requirements met
func test_synergy_check_active_true():
	var synergy = _create_test_synergy(
		"test_synergy",
		["mut1", "mut2"],
		{"speed": 0.5}
	)

	var player_mutations = ["mut1", "mut2", "mut3"]
	var is_active = synergy.check_active(player_mutations)

	assert_true(is_active, "Synergy should be active when all requirements met")

## Test synergy check_active with missing requirements
func test_synergy_check_active_false():
	var synergy = _create_test_synergy(
		"test_synergy",
		["mut1", "mut2"],
		{"speed": 0.5}
	)

	var player_mutations = ["mut1", "mut3"]
	var is_active = synergy.check_active(player_mutations)

	assert_false(is_active, "Synergy should not be active when requirements missing")

## Test synergy activation
func test_synergy_activation():
	# Setup synergy
	var synergy = _create_test_synergy(
		"test_synergy",
		["speed_boost", "slippery"],
		{"speed": 0.3}
	)
	mutation_manager.available_synergies.append(synergy)

	# Add required mutations
	var mut1 = _create_test_mutation("speed_boost", 0.2, 0.0, 0)
	var mut2 = _create_test_mutation("slippery", 0.0, 0.0, 0)

	mutation_manager.add_mutation(mut1)
	mutation_manager.add_mutation(mut2)

	# Check synergy activated
	assert_eq(mutation_manager.active_synergies.size(), 1, "Should have 1 active synergy")
	assert_true(synergy in mutation_manager.active_synergies, "Test synergy should be active")

## Test synergy deactivation on mutation removal
func test_synergy_deactivation():
	# Setup synergy
	var synergy = _create_test_synergy(
		"test_synergy",
		["speed_boost", "slippery"],
		{"speed": 0.3}
	)
	mutation_manager.available_synergies.append(synergy)

	# Add and then remove mutations
	var mut1 = _create_test_mutation("speed_boost", 0.2, 0.0, 0)
	var mut2 = _create_test_mutation("slippery", 0.0, 0.0, 0)

	mutation_manager.add_mutation(mut1)
	mutation_manager.add_mutation(mut2)
	mutation_manager.remove_mutation("slippery")

	# Check synergy deactivated
	assert_eq(mutation_manager.active_synergies.size(), 0, "Should have 0 active synergies")

## Test synergy bonus application
func test_synergy_bonus_stats():
	# Setup synergy with speed bonus
	var synergy = _create_test_synergy(
		"speed_synergy",
		["speed_boost", "slippery"],
		{"speed": 0.5}  # +50% bonus
	)
	mutation_manager.available_synergies.append(synergy)

	# Add mutations
	var mut1 = _create_test_mutation("speed_boost", 0.2, 0.0, 0)  # +20%
	var mut2 = _create_test_mutation("slippery", 0.0, 0.0, 0)

	mutation_manager.add_mutation(mut1)
	mutation_manager.add_mutation(mut2)

	var stats = mutation_manager.current_stats
	# Base: 200, +20% = 240, then synergy +50% = 360
	assert_almost_eq(stats.speed, 360.0, 0.01, "Synergy bonus should be applied")

## Test Apex Predator synergy
func test_apex_predator_synergy():
	# Create Apex Predator synergy
	var synergy = _create_test_synergy(
		"apex_predator",
		["quick_tongue", "long_reach", "strong_legs"],
		{"attack_cooldown": -0.25}
	)
	mutation_manager.available_synergies.append(synergy)

	# Add required mutations
	var mut1 = _create_test_mutation_advanced("quick_tongue", 0.0, 0.0, 0, 0, 0.0, -0.15)
	var mut2 = _create_test_mutation_advanced("long_reach", 0.0, 0.0, 0, 0, 0.0, 0.0, 0.3)
	var mut3 = _create_test_mutation("strong_legs", 0.0, 0.1, 0)

	mutation_manager.add_mutation(mut1)
	mutation_manager.add_mutation(mut2)
	mutation_manager.add_mutation(mut3)

	# Check synergy active
	assert_eq(mutation_manager.active_synergies.size(), 1, "Apex Predator should be active")

	# Check attack cooldown reduction
	var stats = mutation_manager.current_stats
	# Base: 0.5, -15% = 0.425, then synergy -25% = 0.31875
	assert_true(stats.attack_cooldown < 0.35, "Attack cooldown should be significantly reduced")

## Test Pollution Immune synergy
func test_pollution_immune_synergy():
	var synergy = _create_test_synergy(
		"pollution_immune",
		["oil_slick", "toxic_aura", "tough_skin"],
		{"hp": 1}
	)
	mutation_manager.available_synergies.append(synergy)

	# Add required mutations
	var mut1 = _create_test_mutation("oil_slick", 0.0, 0.0, 0, 15)
	var mut2 = _create_test_mutation("toxic_aura", 0.0, 0.0, 0, 12)
	var mut3 = _create_test_mutation("tough_skin", 0.0, 0.0, 1)

	mutation_manager.add_mutation(mut1)
	mutation_manager.add_mutation(mut2)
	mutation_manager.add_mutation(mut3)

	# Check synergy active
	assert_eq(mutation_manager.active_synergies.size(), 1, "Pollution Immune should be active")

	# Check HP bonus
	var stats = mutation_manager.current_stats
	# Base: 5, +1 from tough_skin, +1 from synergy = 7
	assert_eq(stats.max_hp, 7, "Should have bonus HP from synergy")

	# Check pollution tracked correctly
	assert_eq(mutation_manager.get_total_pollution(), 27, "Should track pollution from all mutations")

## Test Swamp King synergy
func test_swamp_king_synergy():
	var synergy = _create_test_synergy(
		"swamp_king",
		["lily_pad", "slippery", "speed_boost"],
		{"speed": 0.5}
	)
	mutation_manager.available_synergies.append(synergy)

	# Add required mutations
	var mut1 = _create_test_mutation("lily_pad", 0.0, 0.0, 0)
	var mut2 = _create_test_mutation("slippery", 0.0, 0.0, 0)
	var mut3 = _create_test_mutation("speed_boost", 0.2, 0.0, 0)

	mutation_manager.add_mutation(mut1)
	mutation_manager.add_mutation(mut2)
	mutation_manager.add_mutation(mut3)

	# Check synergy active
	assert_eq(mutation_manager.active_synergies.size(), 1, "Swamp King should be active")

	# Check speed bonus
	var stats = mutation_manager.current_stats
	# Base: 200, +20% = 240, then synergy +50% = 360
	assert_almost_eq(stats.speed, 360.0, 0.01, "Should have massive speed boost")

## Test multiple synergies active
func test_multiple_synergies():
	# Create two compatible synergies
	var synergy1 = _create_test_synergy(
		"synergy1",
		["mut1", "mut2"],
		{"speed": 0.3}
	)
	var synergy2 = _create_test_synergy(
		"synergy2",
		["mut3", "mut4"],
		{"damage": 0.2}
	)
	mutation_manager.available_synergies.append(synergy1)
	mutation_manager.available_synergies.append(synergy2)

	# Add mutations for both synergies
	mutation_manager.add_mutation(_create_test_mutation("mut1", 0.0, 0.0, 0))
	mutation_manager.add_mutation(_create_test_mutation("mut2", 0.0, 0.0, 0))
	mutation_manager.add_mutation(_create_test_mutation("mut3", 0.0, 0.0, 0))
	mutation_manager.add_mutation(_create_test_mutation("mut4", 0.0, 0.0, 0))

	# Check both active
	assert_eq(mutation_manager.active_synergies.size(), 2, "Should have 2 active synergies")

## Test synergy activated signal
func test_synergy_activated_signal():
	var signal_emitted = false
	var received_synergy = null

	mutation_manager.synergy_activated.connect(func(s):
		signal_emitted = true
		received_synergy = s
	)

	var synergy = _create_test_synergy(
		"test_synergy",
		["mut1", "mut2"],
		{"speed": 0.3}
	)
	mutation_manager.available_synergies.append(synergy)

	mutation_manager.add_mutation(_create_test_mutation("mut1", 0.0, 0.0, 0))
	mutation_manager.add_mutation(_create_test_mutation("mut2", 0.0, 0.0, 0))

	await wait_frames(1)
	assert_true(signal_emitted, "Should emit synergy_activated signal")
	assert_not_null(received_synergy, "Should receive synergy in signal")

## Test synergy deactivated signal
func test_synergy_deactivated_signal():
	var signal_emitted = false

	mutation_manager.synergy_deactivated.connect(func(_s):
		signal_emitted = true
	)

	var synergy = _create_test_synergy(
		"test_synergy",
		["mut1", "mut2"],
		{"speed": 0.3}
	)
	mutation_manager.available_synergies.append(synergy)

	mutation_manager.add_mutation(_create_test_mutation("mut1", 0.0, 0.0, 0))
	mutation_manager.add_mutation(_create_test_mutation("mut2", 0.0, 0.0, 0))
	mutation_manager.remove_mutation("mut2")

	await wait_frames(1)
	assert_true(signal_emitted, "Should emit synergy_deactivated signal")

## Helper: Create test synergy
func _create_test_synergy(id: String, required: Array, bonuses: Dictionary) -> SynergyResource:
	var synergy = SynergyResource.new()
	synergy.id = id
	synergy.synergy_name = id
	synergy.description = "Test synergy"
	synergy.required_mutations = required
	synergy.bonus_effects = bonuses
	return synergy

## Helper: Create test mutation
func _create_test_mutation(id: String, speed_mod: float, damage_mod: float, hp_mod: int, pollution: int = 0) -> MutationResource:
	var mutation = MutationResource.new()
	mutation.id = id
	mutation.mutation_name = id
	mutation.description = "Test mutation"
	mutation.speed_modifier = speed_mod
	mutation.damage_modifier = damage_mod
	mutation.hp_modifier = hp_mod
	mutation.pollution_cost = pollution
	return mutation

## Helper: Create advanced test mutation
func _create_test_mutation_advanced(
	id: String,
	speed_mod: float = 0.0,
	damage_mod: float = 0.0,
	hp_mod: int = 0,
	pollution: int = 0,
	crit_mod: float = 0.0,
	attack_cd_mod: float = 0.0,
	range_mod: float = 0.0
) -> MutationResource:
	var mutation = _create_test_mutation(id, speed_mod, damage_mod, hp_mod, pollution)
	mutation.crit_chance_modifier = crit_mod
	mutation.attack_cooldown_modifier = attack_cd_mod
	mutation.range_modifier = range_mod
	return mutation
