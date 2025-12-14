## Unit Tests for Tongue Attack System (COMBAT-003)
##
## Tests tongue whip attack mechanic.
## Acceptance Criteria (PRD FR-001):
## - Tongue attack with whip mechanic
## - Attack direction follows mouse aim
## - Hit detection on enemies
## - Cooldown between attacks
extends GutTest

const PlayerScene := preload("res://combat/scenes/Player.tscn")
const FRAME_DELTA := 0.016  # ~60fps

var player: CharacterBody2D
var tongue_attack: Node2D


func before_each() -> void:
	player = PlayerScene.instantiate()
	add_child_autofree(player)
	# Position player at known location
	player.global_position = Vector2(500, 500)
	await get_tree().process_frame

	# Get tongue attack reference
	tongue_attack = player.get_node("TongueAttack")


func after_each() -> void:
	# Release attack input
	Input.action_release("attack")


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


## Simulate attack input and process frames
func _simulate_attack(frames: int = 1) -> void:
	Input.action_press("attack")
	for i in range(frames):
		player._physics_process(FRAME_DELTA)
		tongue_attack._physics_process(FRAME_DELTA)
	Input.action_release("attack")


## Process physics frames without input
func _process_frames(frames: int) -> void:
	for i in range(frames):
		player._physics_process(FRAME_DELTA)
		tongue_attack._physics_process(FRAME_DELTA)


## Simulate mouse position and update aim
func _aim_at(pos: Vector2) -> void:
	Input.warp_mouse(pos)
	player._update_aim()


## Create a mock enemy at position
func _create_enemy_at(pos: Vector2) -> CharacterBody2D:
	var enemy := CharacterBody2D.new()
	enemy.add_to_group("enemies")
	# Set collision layer 3 (enemies) so HitArea (mask 3) can detect
	enemy.collision_layer = 3
	enemy.collision_mask = 0  # Enemies don't need to detect anything for this test
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16.0
	collision.shape = shape
	enemy.add_child(collision)
	add_child_autofree(enemy)
	enemy.global_position = pos
	return enemy


# =============================================================================
# CORE ATTACK TESTS
# =============================================================================


## Test 1: Attack input triggers attack
func test_attack_input_triggers_attack() -> void:
	assert_eq(tongue_attack.current_state, tongue_attack.State.IDLE, "Should start in IDLE state")

	_simulate_attack(1)

	assert_eq(
		tongue_attack.current_state,
		tongue_attack.State.EXTENDING,
		"Attack input should trigger EXTENDING state"
	)


## Test 2: Attack uses aim direction
func test_attack_uses_aim_direction() -> void:
	# Aim to the right
	_aim_at(Vector2(600, 500))
	_simulate_attack(5)  # Process through extend

	var tongue_line: Line2D = tongue_attack.get_node("TongueLine")
	var end_point: Vector2 = tongue_line.get_point_position(1)

	# Tongue should extend in positive X direction
	assert_gt(end_point.x, 0.0, "Tongue should extend toward aim direction (right)")
	assert_almost_eq(end_point.y, 0.0, 5.0, "Tongue Y should be ~0 when aiming right")


## Test 3: Attack has cooldown
func test_attack_has_cooldown() -> void:
	# Complete one attack
	_simulate_attack(1)
	_process_frames(20)  # Process through full attack cycle

	# Should be back in IDLE but with cooldown active
	assert_eq(
		tongue_attack.current_state, tongue_attack.State.IDLE, "Should return to IDLE after attack"
	)
	assert_gt(tongue_attack.cooldown_timer, 0.0, "Cooldown timer should be active after attack")


## Test 4: Cooldown blocks input
func test_attack_cooldown_blocks_input() -> void:
	# Complete one attack
	_simulate_attack(1)
	_process_frames(20)  # Process through full attack

	# Immediately try another attack (during cooldown)
	var cooldown_remaining := tongue_attack.cooldown_timer
	assert_gt(cooldown_remaining, 0.0, "Cooldown should be active")

	_simulate_attack(1)

	# Should still be in IDLE (attack blocked by cooldown)
	assert_eq(
		tongue_attack.current_state,
		tongue_attack.State.IDLE,
		"Attack should be blocked during cooldown"
	)


# =============================================================================
# STATE MACHINE TESTS
# =============================================================================


## Test 5: Attack starts in idle state
func test_attack_starts_in_idle_state() -> void:
	assert_eq(
		tongue_attack.current_state,
		tongue_attack.State.IDLE,
		"TongueAttack should initialize in IDLE state"
	)


## Test 6: Attack transitions to extending
func test_attack_transitions_to_extending() -> void:
	_simulate_attack(1)

	assert_eq(
		tongue_attack.current_state,
		tongue_attack.State.EXTENDING,
		"Attack should transition to EXTENDING on input"
	)


## Test 7: Attack transitions to retracting
func test_attack_transitions_to_retracting() -> void:
	_simulate_attack(1)

	# Process enough frames for extend to complete (0.15s / 0.016 = ~10 frames)
	_process_frames(12)

	assert_eq(
		tongue_attack.current_state,
		tongue_attack.State.RETRACTING,
		"Attack should transition to RETRACTING after extend completes"
	)


## Test 8: Attack returns to idle
func test_attack_returns_to_idle() -> void:
	_simulate_attack(1)

	# Process enough frames for full attack (extend + retract = 0.25s = ~16 frames)
	_process_frames(20)

	assert_eq(
		tongue_attack.current_state,
		tongue_attack.State.IDLE,
		"Attack should return to IDLE after retract completes"
	)


# =============================================================================
# HIT DETECTION TESTS
# =============================================================================


## Test 9: Attack damages enemy on hit
func test_attack_damages_enemy_on_hit() -> void:
	# Create enemy in attack range (within 144 pixels)
	var enemy := _create_enemy_at(Vector2(600, 500))  # 100 pixels to the right

	# Aim at enemy
	_aim_at(Vector2(600, 500))

	# Track if hit signal is emitted
	var hit_received := false
	var hit_enemy: Node2D = null
	var hit_damage: int = 0

	tongue_attack.tongue_hit.connect(
		func(e, d):
			hit_received = true
			hit_enemy = e
			hit_damage = d
	)

	# Perform attack
	_simulate_attack(1)
	_process_frames(10)  # Process through extend

	assert_true(hit_received, "Should emit tongue_hit signal when hitting enemy")
	assert_eq(hit_enemy, enemy, "Hit enemy should match the target")
	assert_eq(hit_damage, tongue_attack.base_damage, "Damage should match base_damage")


## Test 10: Attack misses enemy out of range
func test_attack_misses_enemy_out_of_range() -> void:
	# Create enemy beyond attack range (>144 pixels)
	var enemy := _create_enemy_at(Vector2(700, 500))  # 200 pixels to the right

	# Aim at enemy
	_aim_at(Vector2(700, 500))

	# Track if hit signal is emitted
	var hit_received := false
	tongue_attack.tongue_hit.connect(func(_e, _d): hit_received = true)

	# Perform full attack
	_simulate_attack(1)
	_process_frames(20)

	assert_false(hit_received, "Should NOT hit enemy outside max_range")


## Test 11: Attack emits signal on hit
func test_attack_emits_signal_on_hit() -> void:
	var enemy := _create_enemy_at(Vector2(600, 500))
	_aim_at(Vector2(600, 500))

	# Use watch_signals to verify emission
	watch_signals(tongue_attack)

	_simulate_attack(1)
	_process_frames(10)

	assert_signal_emitted(
		tongue_attack, "tongue_hit", "tongue_hit signal should be emitted on enemy hit"
	)


# =============================================================================
# EDGE CASE TESTS
# =============================================================================


## Test 12: Attack handles no enemies gracefully
func test_attack_handles_no_enemies() -> void:
	# No enemies in scene, just attack
	_aim_at(Vector2(600, 500))

	# Should not crash
	_simulate_attack(1)
	_process_frames(20)

	# Should complete attack cycle normally
	assert_eq(
		tongue_attack.current_state,
		tongue_attack.State.IDLE,
		"Attack should complete normally with no enemies"
	)


## Test 13: Attack started signal emits
func test_attack_started_signal_emits() -> void:
	watch_signals(tongue_attack)

	_simulate_attack(1)

	assert_signal_emitted(
		tongue_attack, "attack_started", "attack_started signal should emit when attack begins"
	)


## Test 14: Attack finished signal emits
func test_attack_finished_signal_emits() -> void:
	watch_signals(tongue_attack)

	_simulate_attack(1)
	_process_frames(20)

	assert_signal_emitted(
		tongue_attack, "attack_finished", "attack_finished signal should emit when attack completes"
	)


## Test 15: Multiple attacks work after cooldown expires
func test_multiple_attacks_work_after_cooldown() -> void:
	# First attack
	_simulate_attack(1)
	_process_frames(20)  # Complete attack

	# Wait for cooldown to expire (0.3s = ~19 frames)
	_process_frames(20)

	# Second attack should work
	_simulate_attack(1)

	assert_eq(
		tongue_attack.current_state,
		tongue_attack.State.EXTENDING,
		"Should be able to attack again after cooldown expires"
	)


## Test 16: Same enemy not hit twice in one attack
func test_same_enemy_not_hit_twice() -> void:
	var enemy := _create_enemy_at(Vector2(580, 500))  # 80 pixels right (hit mid-extend)
	_aim_at(Vector2(600, 500))

	var hit_count := 0
	tongue_attack.tongue_hit.connect(func(_e, _d): hit_count += 1)

	# Full attack cycle
	_simulate_attack(1)
	_process_frames(20)

	assert_eq(hit_count, 1, "Enemy should only be hit once per attack")


## Test 17: Tongue visual resets after attack
func test_tongue_visual_resets_after_attack() -> void:
	_aim_at(Vector2(600, 500))
	_simulate_attack(1)
	_process_frames(20)  # Complete full attack

	var tongue_line: Line2D = tongue_attack.get_node("TongueLine")
	var end_point: Vector2 = tongue_line.get_point_position(1)

	assert_almost_eq(
		end_point.length(), 0.0, 1.0, "Tongue visual should reset to zero length after attack"
	)
