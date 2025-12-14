## bullet_stress_test.gd
## Stress test controller for bullet performance validation
## Tests 500+ bullets at 60fps with memory tracking
extends Node

# Tunable parameters
@export var max_bullets: int = 500
@export var bullet_lifetime: float = 5.0
@export var spawn_rate: float = 100.0  # Bullets per second
@export var spawn_burst_size: int = 50
@export var enable_monitoring: bool = true

# References
@onready var bullet_container: Node2D = $BulletContainer
@onready var performance_monitor: Node = $PerformanceMonitor
@onready var spawn_timer: Timer = $SpawnTimer

# Bullet tracking
var active_bullets: Array[Node2D] = []
var total_spawned: int = 0
var total_despawned: int = 0

# Performance metrics
var frame_times: Array[float] = []
var max_frame_time: float = 0.0
var min_frame_time: float = 999.0
var avg_frame_time: float = 0.0
var frames_dropped: int = 0

# Memory tracking
var initial_memory: int = 0
var peak_memory: int = 0
var current_memory: int = 0

# Test state
var test_running: bool = false
var test_start_time: float = 0.0
var test_duration: float = 0.0

# Bullet pattern data (from BULLET-001)
const BULLET_PATTERN = {
	"pattern_name": "test_bullet",
	"bullet_type": "basic",
	"speed": 300.0,
	"lifetime": 5.0,
	"damage": 10
}

# Signals
signal test_started()
signal test_completed(results: Dictionary)
signal performance_warning(message: String)
signal memory_warning(message: String)


func _ready() -> void:
	"""Initialize stress test system."""
	setup_monitoring()
	setup_spawn_timer()
	initial_memory = _get_memory_usage()

	if enable_monitoring:
		performance_monitor.start_monitoring()


func setup_monitoring() -> void:
	"""Configure performance monitoring."""
	if performance_monitor:
		performance_monitor.fps_target = 60
		performance_monitor.warning_threshold = 16.7  # 60fps = 16.67ms per frame
		performance_monitor.connect("fps_warning", _on_fps_warning)


func setup_spawn_timer() -> void:
	"""Configure bullet spawn timer."""
	spawn_timer.wait_time = 1.0 / spawn_rate
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func start_test(duration: float = 10.0) -> void:
	"""
	Start stress test.

	Args:
		duration: Test duration in seconds
	"""
	if test_running:
		push_warning("Test already running")
		return

	print("=== BULLET STRESS TEST STARTED ===")
	print("Target: %d bullets at 60fps" % max_bullets)
	print("Duration: %.1fs" % duration)

	test_running = true
	test_start_time = Time.get_ticks_msec() / 1000.0
	test_duration = duration

	# Reset metrics
	_reset_metrics()

	# Start spawning
	spawn_timer.start()

	test_started.emit()


func stop_test() -> void:
	"""Stop stress test and generate results."""
	if not test_running:
		return

	test_running = false
	spawn_timer.stop()

	# Calculate final metrics
	var results = _generate_results()

	print("\n=== BULLET STRESS TEST COMPLETED ===")
	_print_results(results)

	test_completed.emit(results)


func _process(delta: float) -> void:
	"""Track frame timing and memory."""
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

	# Track memory
	current_memory = _get_memory_usage()
	if current_memory > peak_memory:
		peak_memory = current_memory

	# Check for memory leaks (> 20% growth)
	if initial_memory > 0:
		var memory_growth = float(current_memory - initial_memory) / initial_memory
		if memory_growth > 0.2:
			memory_warning.emit("Memory growth: %.1f%%" % (memory_growth * 100))

	# Update active bullet tracking
	_update_bullet_tracking()

	# Check test duration
	var elapsed = Time.get_ticks_msec() / 1000.0 - test_start_time
	if elapsed >= test_duration:
		stop_test()


func _on_spawn_timer_timeout() -> void:
	"""Spawn bullets on timer."""
	if not test_running:
		return

	# Spawn burst of bullets
	var spawn_count = min(spawn_burst_size, max_bullets - active_bullets.size())

	for i in spawn_count:
		_spawn_test_bullet()


func _spawn_test_bullet() -> void:
	"""Spawn a single test bullet."""
	if active_bullets.size() >= max_bullets:
		return

	# Create bullet using BulletUpHell plugin
	var bullet = _create_bullet_from_pattern(BULLET_PATTERN)

	if bullet:
		# Random position around center
		var angle = randf() * TAU
		var distance = randf_range(50, 150)
		bullet.position = Vector2(
			cos(angle) * distance,
			sin(angle) * distance
		)

		# Random direction
		var direction = Vector2(cos(angle), sin(angle)).rotated(randf_range(-PI/4, PI/4))
		bullet.set_direction(direction)

		# Add to container
		bullet_container.add_child(bullet)
		active_bullets.append(bullet)
		total_spawned += 1

		# Auto-despawn after lifetime
		get_tree().create_timer(bullet_lifetime).timeout.connect(
			func(): _despawn_bullet(bullet)
		)


func _create_bullet_from_pattern(pattern: Dictionary) -> Node2D:
	"""
	Create bullet from pattern data.

	Args:
		pattern: Bullet pattern configuration

	Returns:
		Created bullet node
	"""
	# Use BulletUpHell plugin to create bullet
	# This assumes the plugin is properly configured
	var bullet = preload("res://addons/BulletUpHell/Bullet.tscn").instantiate()

	if bullet:
		bullet.speed = pattern.get("speed", 300.0)
		bullet.damage = pattern.get("damage", 10)
		# Additional configuration as needed

	return bullet


func _despawn_bullet(bullet: Node2D) -> void:
	"""
	Despawn a bullet.

	Args:
		bullet: Bullet to remove
	"""
	if not is_instance_valid(bullet):
		return

	active_bullets.erase(bullet)
	total_despawned += 1
	bullet.queue_free()


func _update_bullet_tracking() -> void:
	"""Update active bullet list (remove freed bullets)."""
	active_bullets = active_bullets.filter(func(b): return is_instance_valid(b))


func _reset_metrics() -> void:
	"""Reset all performance metrics."""
	frame_times.clear()
	max_frame_time = 0.0
	min_frame_time = 999.0
	avg_frame_time = 0.0
	frames_dropped = 0
	total_spawned = 0
	total_despawned = 0
	initial_memory = _get_memory_usage()
	peak_memory = initial_memory
	current_memory = initial_memory


func _generate_results() -> Dictionary:
	"""
	Generate test results.

	Returns:
		Dictionary with performance metrics
	"""
	# Calculate average frame time
	if frame_times.size() > 0:
		var sum = 0.0
		for ft in frame_times:
			sum += ft
		avg_frame_time = sum / frame_times.size()

	var avg_fps = 1000.0 / avg_frame_time if avg_frame_time > 0 else 0.0

	return {
		"success": frames_dropped == 0 and avg_fps >= 60,
		"duration": test_duration,
		"bullets": {
			"max_active": active_bullets.size(),
			"total_spawned": total_spawned,
			"total_despawned": total_despawned,
			"target": max_bullets
		},
		"performance": {
			"avg_fps": avg_fps,
			"avg_frame_time_ms": avg_frame_time,
			"min_frame_time_ms": min_frame_time,
			"max_frame_time_ms": max_frame_time,
			"frames_dropped": frames_dropped,
			"total_frames": frame_times.size()
		},
		"memory": {
			"initial_mb": initial_memory / 1024.0 / 1024.0,
			"peak_mb": peak_memory / 1024.0 / 1024.0,
			"current_mb": current_memory / 1024.0 / 1024.0,
			"growth_mb": (peak_memory - initial_memory) / 1024.0 / 1024.0,
			"growth_percent": (float(peak_memory - initial_memory) / initial_memory * 100) if initial_memory > 0 else 0
		}
	}


func _print_results(results: Dictionary) -> void:
	"""
	Print formatted results.

	Args:
		results: Test results dictionary
	"""
	print("\nBullet Stats:")
	print("  Max Active: %d / %d" % [results.bullets.max_active, results.bullets.target])
	print("  Total Spawned: %d" % results.bullets.total_spawned)
	print("  Total Despawned: %d" % results.bullets.total_despawned)

	print("\nPerformance:")
	print("  Avg FPS: %.1f" % results.performance.avg_fps)
	print("  Avg Frame Time: %.2fms" % results.performance.avg_frame_time_ms)
	print("  Min Frame Time: %.2fms" % results.performance.min_frame_time_ms)
	print("  Max Frame Time: %.2fms" % results.performance.max_frame_time_ms)
	print("  Frames Dropped: %d / %d (%.1f%%)" % [
		results.performance.frames_dropped,
		results.performance.total_frames,
		(float(results.performance.frames_dropped) / results.performance.total_frames * 100) if results.performance.total_frames > 0 else 0
	])

	print("\nMemory:")
	print("  Initial: %.2f MB" % results.memory.initial_mb)
	print("  Peak: %.2f MB" % results.memory.peak_mb)
	print("  Current: %.2f MB" % results.memory.current_mb)
	print("  Growth: %.2f MB (%.1f%%)" % [results.memory.growth_mb, results.memory.growth_percent])

	print("\nResult: %s" % ("PASS" if results.success else "FAIL"))


func _get_memory_usage() -> int:
	"""
	Get current memory usage.

	Returns:
		Memory usage in bytes
	"""
	return OS.get_static_memory_usage()


func _on_fps_warning(fps: float, frame_time: float) -> void:
	"""
	Handle FPS warning from performance monitor.

	Args:
		fps: Current FPS
		frame_time: Current frame time in ms
	"""
	performance_warning.emit("FPS drop: %.1f fps (%.2fms)" % [fps, frame_time])


# Public API for external control
func get_current_bullet_count() -> int:
	"""Get number of active bullets."""
	return active_bullets.size()


func get_performance_stats() -> Dictionary:
	"""Get current performance statistics."""
	return {
		"active_bullets": active_bullets.size(),
		"total_spawned": total_spawned,
		"avg_fps": 1000.0 / avg_frame_time if avg_frame_time > 0 else 0.0,
		"frames_dropped": frames_dropped
	}


func is_test_running() -> bool:
	"""Check if test is currently running."""
	return test_running
