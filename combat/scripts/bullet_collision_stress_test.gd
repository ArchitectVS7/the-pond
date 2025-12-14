## bullet_collision_stress_test.gd
## BULLET-007: Collision performance stress test
## Tests 500 bullets + 100 enemies at 60fps with optimized collision layers
extends Node2D

# =============================================================================
# TUNABLE PARAMETERS
# =============================================================================

@export var max_bullets: int = 500
@export var max_enemies: int = 100
@export var bullet_spawn_rate: float = 100.0  # Bullets per second
@export var enemy_spawn_rate: float = 20.0    # Enemies per second
@export var test_duration: float = 10.0        # Seconds
@export var enable_collision_validation: bool = true

# =============================================================================
# REFERENCES
# =============================================================================

@onready var bullet_spawner: Node = $BulletSpawner
@onready var enemy_container: Node2D = $EnemyContainer
@onready var player: CharacterBody2D = $Player
@onready var collision_config = preload("res://combat/scripts/bullet_collision_config.gd")

# =============================================================================
# STATE
# =============================================================================

var active_bullets: Array[Node] = []
var active_enemies: Array[Node2D] = []
var test_running: bool = false
var test_start_time: float = 0.0

# Performance tracking
var frame_times: Array[float] = []
var max_frame_time: float = 0.0
var min_frame_time: float = 999.0
var avg_frame_time: float = 0.0
var frames_dropped: int = 0
var collision_checks_performed: int = 0

# Collision tracking
var bullet_player_collisions: int = 0
var bullet_enemy_collisions: int = 0  # Should be 0 with proper layers!

# Signals
signal test_started()
signal test_completed(results: Dictionary)
signal collision_layer_error(message: String)

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	"""Initialize stress test."""
	_setup_collision_layers()
	_validate_collision_config()


func _setup_collision_layers() -> void:
	"""Configure collision layers for all test entities."""
	# Configure player (Layer 1)
	if player:
		player.collision_layer = collision_config.MASK_PLAYER
		player.collision_mask = collision_config.MASK_ENVIRONMENT | collision_config.MASK_BULLETS

	# Configure bullet spawner (Layer 5, masks Layer 1)
	if bullet_spawner:
		collision_config.configure_bullet_spawner(bullet_spawner)


func _validate_collision_config() -> void:
	"""Validate collision configuration before test."""
	if not enable_collision_validation:
		return

	if bullet_spawner:
		var validation = collision_config.validate_spawner_config(bullet_spawner)

		if not validation.valid:
			for error in validation.errors:
				push_error("Collision config error: %s" % error)
				collision_layer_error.emit(error)

		for warning in validation.warnings:
			push_warning("Collision config warning: %s" % warning)


# =============================================================================
# TEST CONTROL
# =============================================================================

func start_test() -> void:
	"""Start collision stress test."""
	if test_running:
		push_warning("Test already running")
		return

	print("\n=== BULLET COLLISION STRESS TEST ===")
	print("Target: %d bullets + %d enemies at 60fps" % [max_bullets, max_enemies])
	print("Duration: %.1fs" % test_duration)
	print("\nCollision Layer Configuration:")
	print("  - Bullets: Layer 5, Mask Layer 1 (Player only)")
	print("  - Player: Layer 1, Mask Layers 2,5 (Environment, Bullets)")
	print("  - Enemies: Layer 3, Mask Layer 2 (Environment)")

	test_running = true
	test_start_time = Time.get_ticks_msec() / 1000.0
	_reset_metrics()

	# Start spawning
	_start_spawning()

	test_started.emit()


func stop_test() -> void:
	"""Stop test and generate results."""
	if not test_running:
		return

	test_running = false
	_stop_spawning()

	var results = _generate_results()

	print("\n=== TEST COMPLETED ===")
	_print_results(results)

	test_completed.emit(results)


# =============================================================================
# SPAWNING
# =============================================================================

func _start_spawning() -> void:
	"""Start spawning bullets and enemies."""
	# Bullet spawning handled by BulletUpHell spawner
	if bullet_spawner and bullet_spawner.has_method("start_spawning"):
		bullet_spawner.start_spawning()

	# Enemy spawning
	_spawn_enemies_batch(max_enemies)


func _stop_spawning() -> void:
	"""Stop spawning."""
	if bullet_spawner and bullet_spawner.has_method("stop_spawning"):
		bullet_spawner.stop_spawning()


func _spawn_enemies_batch(count: int) -> void:
	"""
	Spawn batch of test enemies.

	Args:
		count: Number of enemies to spawn
	"""
	if not enemy_container:
		return

	# Load enemy scene
	var enemy_scene = preload("res://combat/scenes/EnemyBasic.tscn")

	for i in count:
		var enemy = enemy_scene.instantiate()

		# Random position around player
		var angle = randf() * TAU
		var distance = randf_range(100, 300)
		enemy.position = player.position + Vector2(
			cos(angle) * distance,
			sin(angle) * distance
		)

		# Configure collision (Layer 3, masks Layer 2)
		enemy.collision_layer = collision_config.MASK_ENEMIES
		enemy.collision_mask = collision_config.MASK_ENVIRONMENT

		# Set player target
		enemy.target = player

		enemy_container.add_child(enemy)
		active_enemies.append(enemy)


# =============================================================================
# PERFORMANCE TRACKING
# =============================================================================

func _process(delta: float) -> void:
	"""Track frame timing and collision stats."""
	if not test_running:
		return

	# Track frame time
	var frame_time_ms = delta * 1000.0
	frame_times.append(frame_time_ms)

	if frame_time_ms > max_frame_time:
		max_frame_time = frame_time_ms
	if frame_time_ms < min_frame_time:
		min_frame_time = frame_time_ms

	# Check for dropped frames (> 16.67ms at 60fps)
	if frame_time_ms > 16.67:
		frames_dropped += 1

	# Update bullet count
	_update_bullet_tracking()

	# Check test duration
	var elapsed = Time.get_ticks_msec() / 1000.0 - test_start_time
	if elapsed >= test_duration:
		stop_test()


func _update_bullet_tracking() -> void:
	"""Update active bullet count from spawner."""
	if bullet_spawner and bullet_spawner.has_method("get_active_bullet_count"):
		var bullet_count = bullet_spawner.get_active_bullet_count()
		# Store for results
		if bullet_count > active_bullets.size():
			active_bullets.resize(bullet_count)


# =============================================================================
# COLLISION CALLBACKS
# =============================================================================

func _on_bullet_hit_player(bullet: Node, player_node: Node) -> void:
	"""Track bullet-player collision."""
	bullet_player_collisions += 1
	collision_checks_performed += 1


func _on_bullet_hit_enemy(bullet: Node, enemy: Node) -> void:
	"""Track bullet-enemy collision (should NOT happen!)."""
	bullet_enemy_collisions += 1
	collision_checks_performed += 1

	push_error("COLLISION LAYER ERROR: Bullet hit enemy! Layers misconfigured.")
	collision_layer_error.emit("Bullet hit enemy - collision layers not working!")


# =============================================================================
# METRICS AND RESULTS
# =============================================================================

func _reset_metrics() -> void:
	"""Reset all performance metrics."""
	frame_times.clear()
	max_frame_time = 0.0
	min_frame_time = 999.0
	avg_frame_time = 0.0
	frames_dropped = 0
	collision_checks_performed = 0
	bullet_player_collisions = 0
	bullet_enemy_collisions = 0
	active_bullets.clear()
	active_enemies.clear()


func _generate_results() -> Dictionary:
	"""
	Generate test results.

	Returns:
		Dictionary with performance and collision metrics
	"""
	# Calculate average frame time
	if frame_times.size() > 0:
		var sum = 0.0
		for ft in frame_times:
			sum += ft
		avg_frame_time = sum / frame_times.size()

	var avg_fps = 1000.0 / avg_frame_time if avg_frame_time > 0 else 0.0

	# Success criteria:
	# 1. 60fps average
	# 2. No dropped frames
	# 3. No bullet-enemy collisions (layer validation)
	var success = (
		avg_fps >= 60.0 and
		frames_dropped == 0 and
		bullet_enemy_collisions == 0
	)

	return {
		"success": success,
		"duration": test_duration,
		"entities": {
			"bullets": active_bullets.size(),
			"enemies": active_enemies.size(),
			"target_bullets": max_bullets,
			"target_enemies": max_enemies
		},
		"performance": {
			"avg_fps": avg_fps,
			"avg_frame_time_ms": avg_frame_time,
			"min_frame_time_ms": min_frame_time,
			"max_frame_time_ms": max_frame_time,
			"frames_dropped": frames_dropped,
			"total_frames": frame_times.size()
		},
		"collisions": {
			"bullet_player": bullet_player_collisions,
			"bullet_enemy": bullet_enemy_collisions,
			"total_checks": collision_checks_performed,
			"layer_validation": bullet_enemy_collisions == 0
		}
	}


func _print_results(results: Dictionary) -> void:
	"""
	Print formatted test results.

	Args:
		results: Test results dictionary
	"""
	print("\nEntity Stats:")
	print("  Bullets: %d / %d" % [results.entities.bullets, results.entities.target_bullets])
	print("  Enemies: %d / %d" % [results.entities.enemies, results.entities.target_enemies])

	print("\nPerformance:")
	print("  Avg FPS: %.1f" % results.performance.avg_fps)
	print("  Avg Frame Time: %.2fms" % results.performance.avg_frame_time_ms)
	print("  Min Frame Time: %.2fms" % results.performance.min_frame_time_ms)
	print("  Max Frame Time: %.2fms" % results.performance.max_frame_time_ms)
	print("  Frames Dropped: %d / %d" % [
		results.performance.frames_dropped,
		results.performance.total_frames
	])

	print("\nCollision Stats:")
	print("  Bullet-Player: %d" % results.collisions.bullet_player)
	print("  Bullet-Enemy: %d (should be 0!)" % results.collisions.bullet_enemy)
	print("  Total Checks: %d" % results.collisions.total_checks)
	print("  Layer Validation: %s" % ("PASS" if results.collisions.layer_validation else "FAIL"))

	var result_text = "PASS" if results.success else "FAIL"
	print("\n=== RESULT: %s ===" % result_text)

	if not results.collisions.layer_validation:
		print("ERROR: Collision layers are NOT properly configured!")
		print("Bullets are hitting enemies when they should only hit player.")
