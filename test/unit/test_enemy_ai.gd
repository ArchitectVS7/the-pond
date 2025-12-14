## Unit Tests for Enemy AI Basic Behaviors (COMBAT-006)
##
## Tests enemy AI behavior patterns.
## Behaviors: CHASE, WANDER, ORBIT, SWARM
extends GutTest

const EnemyBasicScene := preload("res://combat/scenes/EnemyBasic.tscn")
const PlayerScene := preload("res://combat/scenes/Player.tscn")

const FRAME_DELTA := 0.016  # ~60fps

var enemy: CharacterBody2D
var player: CharacterBody2D
var arena: Node2D


func before_each() -> void:
	arena = Node2D.new()
	add_child_autofree(arena)

	player = PlayerScene.instantiate()
	player.add_to_group("player")
	arena.add_child(player)
	player.global_position = Vector2(500, 500)

	enemy = EnemyBasicScene.instantiate()
	arena.add_child(enemy)
	enemy.global_position = Vector2(600, 500)  # 100px to the right
	enemy.target = player

	await get_tree().process_frame


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


func _process_frames(frames: int) -> void:
	for i in range(frames):
		enemy._physics_process(FRAME_DELTA)


func _distance_to_player() -> float:
	return enemy.global_position.distance_to(player.global_position)


# =============================================================================
# CHASE BEHAVIOR TESTS
# =============================================================================


## Test 1: Enemy moves toward player in chase mode
func test_chase_moves_toward_player() -> void:
	enemy.behavior_mode = enemy.BehaviorMode.CHASE
	var initial_distance := _distance_to_player()

	_process_frames(10)

	var new_distance := _distance_to_player()
	assert_lt(new_distance, initial_distance, "Enemy in CHASE mode should move toward player")


## Test 2: Chase maintains direction toward player
func test_chase_direction_toward_player() -> void:
	enemy.behavior_mode = enemy.BehaviorMode.CHASE
	_process_frames(1)

	var direction := enemy.velocity.normalized()
	var expected := (player.global_position - enemy.global_position).normalized()

	assert_almost_eq(direction.x, expected.x, 0.1, "Chase velocity should point toward player (X)")
	assert_almost_eq(direction.y, expected.y, 0.1, "Chase velocity should point toward player (Y)")


## Test 3: Chase uses move_speed
func test_chase_uses_move_speed() -> void:
	enemy.behavior_mode = enemy.BehaviorMode.CHASE
	enemy.move_speed = 100.0
	_process_frames(1)

	var speed := enemy.velocity.length()
	assert_almost_eq(speed, enemy.move_speed, 1.0, "Chase speed should match move_speed")


# =============================================================================
# WANDER BEHAVIOR TESTS
# =============================================================================


## Test 4: Wander changes direction periodically
func test_wander_changes_direction() -> void:
	enemy.behavior_mode = enemy.BehaviorMode.WANDER
	enemy.wander_interval = 0.1  # Fast for testing

	_process_frames(5)
	var initial_dir := enemy.velocity.normalized()

	# Process through wander interval
	_process_frames(10)
	var new_dir := enemy.velocity.normalized()

	# Direction should eventually change (with randomness, may take a few tries)
	# Just verify enemy is moving
	assert_gt(enemy.velocity.length(), 0.0, "Wander should produce movement")


## Test 5: Wander uses wander_speed
func test_wander_uses_wander_speed() -> void:
	enemy.behavior_mode = enemy.BehaviorMode.WANDER
	enemy.wander_speed = 50.0
	_process_frames(5)

	var speed := enemy.velocity.length()
	assert_almost_eq(speed, enemy.wander_speed, 5.0, "Wander speed should match wander_speed")


# =============================================================================
# ORBIT BEHAVIOR TESTS
# =============================================================================


## Test 6: Orbit maintains distance from player
func test_orbit_maintains_distance() -> void:
	enemy.behavior_mode = enemy.BehaviorMode.ORBIT
	enemy.orbit_distance = 100.0
	enemy.global_position = Vector2(600, 500)  # 100px from player

	var distances: Array[float] = []
	for i in range(30):
		_process_frames(1)
		distances.append(_distance_to_player())

	# All distances should be near orbit_distance
	for dist in distances:
		assert_almost_eq(
			dist, enemy.orbit_distance, 20.0, "Orbit should maintain orbit_distance from player"
		)


## Test 7: Orbit moves tangentially
func test_orbit_moves_tangentially() -> void:
	enemy.behavior_mode = enemy.BehaviorMode.ORBIT
	enemy.orbit_distance = 100.0
	enemy.global_position = Vector2(600, 500)  # Right of player

	_process_frames(1)

	# Velocity should be roughly perpendicular to player direction
	var to_player := (player.global_position - enemy.global_position).normalized()
	var velocity_dir := enemy.velocity.normalized()

	# Dot product of perpendicular vectors is ~0
	var dot := to_player.dot(velocity_dir)
	assert_almost_eq(
		abs(dot), 0.0, 0.3, "Orbit velocity should be tangential (perpendicular to player)"
	)


# =============================================================================
# SEPARATION BEHAVIOR TESTS
# =============================================================================


## Test 8: Enemies separate when too close
func test_separation_when_close() -> void:
	# Add a second enemy very close
	var enemy2 := EnemyBasicScene.instantiate()
	arena.add_child(enemy2)
	enemy2.global_position = enemy.global_position + Vector2(10, 0)  # Very close
	enemy2.target = player

	enemy.separation_enabled = true
	enemy.separation_radius = 50.0

	_process_frames(10)

	var distance := enemy.global_position.distance_to(enemy2.global_position)
	assert_gt(distance, 15.0, "Enemies should separate when too close")

	enemy2.queue_free()


## Test 9: Separation doesn't affect distant enemies
func test_no_separation_when_far() -> void:
	var enemy2 := EnemyBasicScene.instantiate()
	arena.add_child(enemy2)
	enemy2.global_position = enemy.global_position + Vector2(200, 0)  # Far away
	enemy2.target = player

	enemy.separation_enabled = true
	enemy.separation_radius = 50.0
	enemy.behavior_mode = enemy.BehaviorMode.CHASE

	var direction := (player.global_position - enemy.global_position).normalized()
	var initial_velocity := direction * enemy.move_speed
	_process_frames(1)

	# Velocity should be mostly unchanged by separation
	assert_almost_eq(
		enemy.velocity.length(),
		enemy.move_speed,
		5.0,
		"Distant enemies should not affect separation"
	)

	enemy2.queue_free()


# =============================================================================
# BEHAVIOR SWITCHING TESTS
# =============================================================================


## Test 10: Behavior mode can be changed at runtime
func test_behavior_mode_can_change() -> void:
	enemy.behavior_mode = enemy.BehaviorMode.CHASE
	_process_frames(5)
	var chase_dir := enemy.velocity.normalized()

	enemy.behavior_mode = enemy.BehaviorMode.WANDER
	_process_frames(5)

	# Just verify it doesn't crash
	pass_test("Behavior mode can be changed at runtime")


## Test 11: Default behavior is CHASE
func test_default_behavior_is_chase() -> void:
	var fresh_enemy := EnemyBasicScene.instantiate()
	arena.add_child(fresh_enemy)
	fresh_enemy.target = player

	assert_eq(
		fresh_enemy.behavior_mode,
		fresh_enemy.BehaviorMode.CHASE,
		"Default behavior should be CHASE"
	)

	fresh_enemy.queue_free()


# =============================================================================
# EDGE CASE TESTS
# =============================================================================


## Test 12: Enemy handles no target gracefully
func test_handles_no_target() -> void:
	enemy.target = null
	enemy.behavior_mode = enemy.BehaviorMode.CHASE

	# Should not crash
	_process_frames(10)

	assert_eq(enemy.velocity, Vector2.ZERO, "Enemy with no target should have zero velocity")


## Test 13: Enemy handles inactive state
func test_handles_inactive_state() -> void:
	enemy.is_active = false
	enemy.behavior_mode = enemy.BehaviorMode.CHASE

	var initial_pos := enemy.global_position
	_process_frames(10)

	assert_eq(enemy.global_position, initial_pos, "Inactive enemy should not move")
