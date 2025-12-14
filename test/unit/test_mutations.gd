extends GutTest

## Unit tests for mutation system
## Tests mutation application, stat calculation, and special abilities

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

## Test basic mutation addition
func test_add_mutation():
	var mutation = _create_test_mutation("test_speed", 0.2, 0.0, 0)
	var result = mutation_manager.add_mutation(mutation)

	assert_true(result, "Should successfully add mutation")
	assert_eq(mutation_manager.active_mutations.size(), 1, "Should have 1 active mutation")
	assert_true(mutation_manager.has_mutation("test_speed"), "Should have test_speed mutation")

## Test stat modification
func test_speed_modifier():
	var mutation = _create_test_mutation("speed_boost", 0.2, 0.0, 0)
	mutation_manager.add_mutation(mutation)

	var stats = mutation_manager.current_stats
	assert_eq(stats.speed, 240.0, "Speed should be increased by 20%")

## Test damage modifier
func test_damage_modifier():
	var mutation = _create_test_mutation("damage_boost", 0.0, 0.1, 0)
	mutation_manager.add_mutation(mutation)

	var stats = mutation_manager.current_stats
	assert_eq(stats.damage, 11, "Damage should be increased by 10%")

## Test HP modifier
func test_hp_modifier():
	var mutation = _create_test_mutation("tough_skin", 0.0, 0.0, 1)
	mutation_manager.add_mutation(mutation)

	var stats = mutation_manager.current_stats
	assert_eq(stats.max_hp, 6, "Max HP should be increased by 1")

## Test multiple mutations
func test_multiple_mutations():
	var mutation1 = _create_test_mutation("speed1", 0.2, 0.0, 0)
	var mutation2 = _create_test_mutation("speed2", 0.1, 0.0, 0)

	mutation_manager.add_mutation(mutation1)
	mutation_manager.add_mutation(mutation2)

	var stats = mutation_manager.current_stats
	# 200 * 1.2 * 1.1 = 264
	assert_almost_eq(stats.speed, 264.0, 0.01, "Speed modifiers should stack multiplicatively")

## Test mutation removal
func test_remove_mutation():
	var mutation = _create_test_mutation("test_speed", 0.2, 0.0, 0)
	mutation_manager.add_mutation(mutation)

	var result = mutation_manager.remove_mutation("test_speed")

	assert_true(result, "Should successfully remove mutation")
	assert_eq(mutation_manager.active_mutations.size(), 0, "Should have 0 active mutations")
	assert_false(mutation_manager.has_mutation("test_speed"), "Should not have test_speed mutation")

## Test max mutations limit
func test_max_mutations_limit():
	mutation_manager.max_mutations = 3

	for i in range(4):
		var mutation = _create_test_mutation("mutation_" + str(i), 0.1, 0.0, 0)
		var result = mutation_manager.add_mutation(mutation)

		if i < 3:
			assert_true(result, "Should add mutation " + str(i))
		else:
			assert_false(result, "Should reject mutation when at max")

## Test duplicate prevention
func test_duplicate_prevention():
	mutation_manager.allow_duplicates = false
	var mutation = _create_test_mutation("test_mut", 0.1, 0.0, 0)

	var result1 = mutation_manager.add_mutation(mutation)
	var result2 = mutation_manager.add_mutation(mutation)

	assert_true(result1, "Should add first mutation")
	assert_false(result2, "Should reject duplicate")
	assert_eq(mutation_manager.active_mutations.size(), 1, "Should only have 1 mutation")

## Test pollution tracking
func test_pollution_tracking():
	var mutation1 = _create_test_mutation("oil", 0.0, 0.0, 0, 15)
	var mutation2 = _create_test_mutation("toxic", 0.0, 0.0, 0, 12)

	mutation_manager.add_mutation(mutation1)
	mutation_manager.add_mutation(mutation2)

	assert_eq(mutation_manager.get_total_pollution(), 27, "Should track total pollution")

## Test stat change signal
func test_stats_changed_signal():
	var signal_emitted = false
	mutation_manager.stats_changed.connect(func(_stats): signal_emitted = true)

	var mutation = _create_test_mutation("test", 0.1, 0.0, 0)
	mutation_manager.add_mutation(mutation)

	await wait_frames(1)
	assert_true(signal_emitted, "Should emit stats_changed signal")

## Test mutation added signal
func test_mutation_added_signal():
	var received_mutation = null
	mutation_manager.mutation_added.connect(func(m): received_mutation = m)

	var mutation = _create_test_mutation("test", 0.1, 0.0, 0)
	mutation_manager.add_mutation(mutation)

	await wait_frames(1)
	assert_not_null(received_mutation, "Should emit mutation_added signal")
	assert_eq(received_mutation.id, "test", "Should receive correct mutation")

## Test crit chance clamping
func test_crit_chance_clamping():
	var mutation = _create_test_mutation_advanced("crit_boost", 0.0, 0.0, 0, 0, 1.0)
	mutation_manager.add_mutation(mutation)

	var stats = mutation_manager.current_stats
	assert_eq(stats.crit_chance, 1.0, "Crit chance should be clamped to 1.0")

## Test dodge chance clamping
func test_dodge_chance_clamping():
	var mutation = _create_test_mutation_advanced("dodge_boost", 0.0, 0.0, 0, 0, 0.0, 0.0, 0.0, 1.5)
	mutation_manager.add_mutation(mutation)

	var stats = mutation_manager.current_stats
	assert_eq(stats.dodge_chance, 1.0, "Dodge chance should be clamped to 1.0")

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
	range_mod: float = 0.0,
	dodge_mod: float = 0.0
) -> MutationResource:
	var mutation = _create_test_mutation(id, speed_mod, damage_mod, hp_mod, pollution)
	mutation.crit_chance_modifier = crit_mod
	mutation.attack_cooldown_modifier = attack_cd_mod
	mutation.range_modifier = range_mod
	mutation.dodge_chance_modifier = dodge_mod
	return mutation
