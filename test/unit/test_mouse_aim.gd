## Unit Tests for Mouse Aim System (COMBAT-002)
##
## Tests mouse aiming functionality for tongue attack direction.
## Acceptance Criteria (PRD FR-001):
## - Mouse aim tracks cursor position
## - Aim direction is always normalized
## - Aim updates every physics frame
## - Aim angle available for sprite rotation
extends GutTest

const PlayerScene := preload("res://combat/scenes/Player.tscn")
const FRAME_DELTA := 0.016  # ~60fps

var player: CharacterBody2D


func before_each() -> void:
	player = PlayerScene.instantiate()
	add_child_autofree(player)
	# Position player at known location for predictable testing
	player.global_position = Vector2(500, 500)
	await get_tree().process_frame


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


## Simulate mouse at a specific position and update aim
func _simulate_mouse_at(pos: Vector2) -> void:
	# Warp mouse to position (works in tests)
	Input.warp_mouse(pos)
	# Force aim update
	player._update_aim()


# =============================================================================
# TEST CASES
# =============================================================================


## Test 1: Aim direction points toward mouse (right)
func test_aim_direction_points_toward_mouse_right() -> void:
	# Mouse directly to the right of player
	_simulate_mouse_at(Vector2(600, 500))

	# Aim should point right (positive X, zero Y)
	assert_gt(player.aim_direction.x, 0.9, "Aim X should be ~1.0 when mouse is right")
	assert_almost_eq(player.aim_direction.y, 0.0, 0.1, "Aim Y should be ~0 when mouse is right")


## Test 2: Aim direction points toward mouse (left)
func test_aim_direction_points_toward_mouse_left() -> void:
	# Mouse directly to the left of player
	_simulate_mouse_at(Vector2(400, 500))

	# Aim should point left (negative X, zero Y)
	assert_lt(player.aim_direction.x, -0.9, "Aim X should be ~-1.0 when mouse is left")
	assert_almost_eq(player.aim_direction.y, 0.0, 0.1, "Aim Y should be ~0 when mouse is left")


## Test 3: Aim direction points toward mouse (up)
func test_aim_direction_points_toward_mouse_up() -> void:
	# Mouse directly above player (negative Y in Godot)
	_simulate_mouse_at(Vector2(500, 400))

	# Aim should point up (zero X, negative Y)
	assert_almost_eq(player.aim_direction.x, 0.0, 0.1, "Aim X should be ~0 when mouse is above")
	assert_lt(player.aim_direction.y, -0.9, "Aim Y should be ~-1.0 when mouse is above")


## Test 4: Aim direction points toward mouse (down)
func test_aim_direction_points_toward_mouse_down() -> void:
	# Mouse directly below player (positive Y in Godot)
	_simulate_mouse_at(Vector2(500, 600))

	# Aim should point down (zero X, positive Y)
	assert_almost_eq(player.aim_direction.x, 0.0, 0.1, "Aim X should be ~0 when mouse is below")
	assert_gt(player.aim_direction.y, 0.9, "Aim Y should be ~1.0 when mouse is below")


## Test 5: Aim direction is always normalized
func test_aim_direction_is_normalized() -> void:
	# Test at various positions
	var test_positions := [
		Vector2(600, 500),  # Right
		Vector2(400, 600),  # Down-left
		Vector2(550, 450),  # Up-right (close)
		Vector2(1000, 1000),  # Far diagonal
	]

	for pos in test_positions:
		_simulate_mouse_at(pos)
		var length := player.aim_direction.length()
		assert_almost_eq(
			length, 1.0, 0.01, "Aim direction should be normalized at mouse pos %s" % pos
		)


## Test 6: Aim angle matches direction
func test_aim_angle_matches_direction() -> void:
	# Mouse to the right (angle should be 0)
	_simulate_mouse_at(Vector2(600, 500))
	assert_almost_eq(player.aim_angle, 0.0, 0.1, "Right aim should have angle ~0")

	# Mouse below (angle should be PI/2 = 1.57)
	_simulate_mouse_at(Vector2(500, 600))
	assert_almost_eq(player.aim_angle, PI / 2, 0.1, "Down aim should have angle ~PI/2")

	# Mouse to the left (angle should be PI or -PI)
	_simulate_mouse_at(Vector2(400, 500))
	assert_almost_eq(abs(player.aim_angle), PI, 0.1, "Left aim should have angle ~PI")

	# Mouse above (angle should be -PI/2 = -1.57)
	_simulate_mouse_at(Vector2(500, 400))
	assert_almost_eq(player.aim_angle, -PI / 2, 0.1, "Up aim should have angle ~-PI/2")


## Test 7: Aim updates in physics process
func test_aim_updates_in_physics_process() -> void:
	# Set initial mouse position
	_simulate_mouse_at(Vector2(600, 500))
	var initial_direction := player.aim_direction

	# Move mouse to new position
	Input.warp_mouse(Vector2(400, 500))

	# Simulate physics frame
	player._physics_process(FRAME_DELTA)

	# Aim should have updated
	assert_ne(
		player.aim_direction, initial_direction, "Aim direction should update after physics process"
	)


## Test 8: Aim handles mouse at player position (edge case)
func test_aim_handles_mouse_at_player_position() -> void:
	# Mouse exactly at player position
	_simulate_mouse_at(player.global_position)

	# Aim should remain valid (not NaN, not crash)
	assert_false(is_nan(player.aim_direction.x), "Aim X should not be NaN")
	assert_false(is_nan(player.aim_direction.y), "Aim Y should not be NaN")

	# Direction should have valid length (0 or 1, not NaN)
	var length := player.aim_direction.length()
	assert_true(
		length >= 0.0 and length <= 1.0, "Aim length should be valid when mouse at player position"
	)


## Test 9: Aim gracefully handles missing AimPivot node
## This tests the defensive code path when AimPivot is null
func test_aim_gracefully_handles_missing_aim_pivot() -> void:
	# Simulate missing AimPivot by setting to null
	player.aim_pivot = null

	# Should not crash when updating aim
	_simulate_mouse_at(Vector2(600, 500))

	# aim_direction should still update correctly
	assert_gt(player.aim_direction.x, 0.9, "aim_direction should update even when AimPivot is null")

	# aim_angle should still update correctly
	assert_almost_eq(
		player.aim_angle, 0.0, 0.1, "aim_angle should update even when AimPivot is null"
	)


## Test 10: Aim pivot rotates when present
func test_aim_pivot_rotates_when_present() -> void:
	# Ensure aim_pivot is present (it should be by default)
	assert_not_null(player.aim_pivot, "AimPivot should exist in Player scene")

	# Initial rotation should be 0 (pointing right)
	var initial_rotation := player.aim_pivot.rotation

	# Aim down (90 degrees = PI/2)
	_simulate_mouse_at(Vector2(500, 600))

	# AimPivot should have rotated
	assert_almost_eq(
		player.aim_pivot.rotation, PI / 2, 0.1, "AimPivot should rotate to face mouse (down = PI/2)"
	)
