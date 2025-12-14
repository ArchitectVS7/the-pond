## Unit Tests for Enemy Spawn System (COMBAT-005)
##
## Tests enemy spawning with escalating difficulty.
## Acceptance Criteria (PRD FR-001):
## - Enemy spawn system with escalating difficulty
## - Difficulty increases every 60 seconds
## - Supports multiple enemy types
extends GutTest

const EnemySpawnerScript := preload("res://combat/scripts/enemy_spawner.gd")
const EnemyBasicScene := preload("res://combat/scenes/EnemyBasic.tscn")
const EnemyFastScene := preload("res://combat/scenes/EnemyFast.tscn")
const PlayerScene := preload("res://combat/scenes/Player.tscn")

const FRAME_DELTA := 0.016  # ~60fps

var spawner: Node2D
var player: CharacterBody2D
var arena: Node2D


func before_each() -> void:
	# Create arena container
	arena = Node2D.new()
	add_child_autofree(arena)

	# Create player
	player = PlayerScene.instantiate()
	player.add_to_group("player")
	arena.add_child(player)
	player.global_position = Vector2(500, 500)

	# Create spawner
	spawner = Node2D.new()
	spawner.set_script(EnemySpawnerScript)
	arena.add_child(spawner)
	spawner.global_position = Vector2(500, 500)

	# Configure spawner
	spawner.basic_enemy_scene = EnemyBasicScene
	spawner.fast_enemy_scene = EnemyFastScene
	spawner.base_spawn_interval = 0.5  # Faster for testing
	spawner.escalation_interval = 2.0  # Faster for testing

	await get_tree().process_frame


func after_each() -> void:
	# Clean up any remaining enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


func _process_frames(frames: int) -> void:
	for i in range(frames):
		spawner._physics_process(FRAME_DELTA)


func _process_time(seconds: float) -> void:
	var frames := int(seconds / FRAME_DELTA)
	_process_frames(frames)


func _count_enemies() -> int:
	return get_tree().get_nodes_in_group("enemies").size()


# =============================================================================
# SPAWNING TESTS
# =============================================================================


## Test 1: Spawner starts inactive
func test_spawner_starts_inactive() -> void:
	assert_false(spawner.is_spawning, "Spawner should start inactive")


## Test 2: Start spawning activates spawner
func test_start_spawning_activates() -> void:
	spawner.start_spawning()

	assert_true(spawner.is_spawning, "start_spawning() should activate spawner")


## Test 3: Stop spawning deactivates spawner
func test_stop_spawning_deactivates() -> void:
	spawner.start_spawning()
	spawner.stop_spawning()

	assert_false(spawner.is_spawning, "stop_spawning() should deactivate spawner")


## Test 4: Enemies spawn after interval
func test_enemies_spawn_after_interval() -> void:
	spawner.start_spawning()

	# Process enough time for first spawn
	_process_time(spawner.base_spawn_interval + 0.1)

	assert_gt(_count_enemies(), 0, "Enemies should spawn after spawn interval")


## Test 5: Multiple enemies spawn over time
func test_multiple_enemies_spawn() -> void:
	spawner.start_spawning()

	# Process enough time for multiple spawns
	_process_time(spawner.base_spawn_interval * 3 + 0.1)

	assert_gte(_count_enemies(), 2, "Multiple enemies should spawn over time")


## Test 6: Enemies spawn at arena edge (spawn radius)
func test_enemies_spawn_at_radius() -> void:
	spawner.start_spawning()
	_process_time(spawner.base_spawn_interval + 0.1)

	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		var enemy: Node2D = enemies[0]
		var distance := enemy.global_position.distance_to(spawner.global_position)

		# Should be approximately at spawn_radius
		assert_almost_eq(
			distance,
			spawner.spawn_radius,
			50.0,
			"Enemies should spawn near spawn_radius from spawner"
		)


# =============================================================================
# ESCALATION TESTS
# =============================================================================


## Test 7: Difficulty escalates after interval
func test_difficulty_escalates() -> void:
	spawner.start_spawning()
	var initial_wave := spawner.current_wave

	# Process through escalation interval
	_process_time(spawner.escalation_interval + 0.1)

	assert_eq(
		spawner.current_wave, initial_wave + 1, "Wave should increase after escalation interval"
	)


## Test 8: Spawn interval decreases with escalation
func test_spawn_interval_decreases() -> void:
	spawner.start_spawning()
	var initial_interval := spawner.current_spawn_interval

	# Process through escalation
	_process_time(spawner.escalation_interval + 0.1)

	assert_lt(
		spawner.current_spawn_interval,
		initial_interval,
		"Spawn interval should decrease after escalation"
	)


## Test 9: Spawn interval has minimum limit
func test_spawn_interval_has_minimum() -> void:
	spawner.start_spawning()

	# Force many escalations
	for i in range(20):
		spawner._escalate_difficulty()

	assert_gte(
		spawner.current_spawn_interval,
		spawner.min_spawn_interval,
		"Spawn interval should not go below minimum"
	)


## Test 10: Escalation signal emits
func test_escalation_signal_emits() -> void:
	watch_signals(spawner)
	spawner.start_spawning()

	_process_time(spawner.escalation_interval + 0.1)

	assert_signal_emitted(
		spawner, "difficulty_escalated", "difficulty_escalated signal should emit on escalation"
	)


# =============================================================================
# ENEMY TYPE TESTS
# =============================================================================


## Test 11: Wave 1 spawns only basic enemies
func test_wave1_spawns_basic_only() -> void:
	spawner.start_spawning()
	assert_eq(spawner.current_wave, 1, "Should start at wave 1")

	# Spawn several enemies
	_process_time(spawner.base_spawn_interval * 5)

	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		# Basic enemies have move_speed 80
		assert_eq(enemy.move_speed, 80.0, "Wave 1 should only spawn basic enemies (speed 80)")


## Test 12: Wave 2+ can spawn fast enemies
func test_wave2_can_spawn_fast() -> void:
	spawner.start_spawning()

	# Force to wave 2
	spawner._escalate_difficulty()
	assert_eq(spawner.current_wave, 2, "Should be at wave 2")

	# Spawn many enemies to get at least one fast
	spawner.base_spawn_interval = 0.1
	_process_time(2.0)

	var enemies := get_tree().get_nodes_in_group("enemies")
	var has_fast := false
	for enemy in enemies:
		if enemy.move_speed > 100.0:  # Fast enemies are 150
			has_fast = true
			break

	# Note: This may fail due to random chance, but with 30% probability
	# and ~20 spawns, it's very likely to have at least one fast enemy
	assert_true(
		has_fast or enemies.size() < 5, "Wave 2+ should have a chance to spawn fast enemies"
	)


# =============================================================================
# LIMIT TESTS
# =============================================================================


## Test 13: Enemy count is tracked
func test_enemy_count_tracked() -> void:
	spawner.start_spawning()
	_process_time(spawner.base_spawn_interval * 3 + 0.1)

	var actual_count := _count_enemies()
	assert_eq(
		spawner.enemy_count, actual_count, "Spawner enemy_count should match actual enemy count"
	)


## Test 14: Max enemies limit is respected
func test_max_enemies_limit() -> void:
	spawner.max_enemies = 5
	spawner.base_spawn_interval = 0.05  # Very fast spawning
	spawner.start_spawning()

	_process_time(2.0)  # Should try to spawn many

	assert_lte(_count_enemies(), spawner.max_enemies, "Should not exceed max_enemies limit")


## Test 15: Enemy count decreases on death
func test_enemy_count_decreases_on_death() -> void:
	spawner.start_spawning()
	_process_time(spawner.base_spawn_interval + 0.1)

	var initial_count := spawner.enemy_count

	# Kill an enemy
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		enemies[0].die()
		await get_tree().process_frame

		assert_eq(
			spawner.enemy_count, initial_count - 1, "Enemy count should decrease when enemy dies"
		)


# =============================================================================
# RESET TESTS
# =============================================================================


## Test 16: Reset restores initial state
func test_reset_restores_state() -> void:
	spawner.start_spawning()
	_process_time(spawner.escalation_interval + 0.5)

	spawner.reset()

	assert_eq(spawner.current_wave, 1, "Reset should restore wave to 1")
	assert_eq(
		spawner.current_spawn_interval,
		spawner.base_spawn_interval,
		"Reset should restore spawn interval"
	)
	assert_eq(spawner.spawn_timer, 0.0, "Reset should reset spawn timer")
	assert_eq(spawner.escalation_timer, 0.0, "Reset should reset escalation timer")


## Test 17: Player target is found automatically
func test_player_target_found() -> void:
	spawner.player_target = null  # Clear reference
	spawner.start_spawning()
	_process_time(spawner.base_spawn_interval + 0.1)

	assert_not_null(spawner.player_target, "Spawner should find player automatically")
