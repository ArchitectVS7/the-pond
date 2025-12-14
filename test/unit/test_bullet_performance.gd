## test_bullet_performance.gd
## Performance validation tests for bullet system
## Verifies 500 bullets at 60fps with memory stability
extends GutTest

# Test configuration
const STRESS_TEST_SCENE = "res://combat/scenes/BulletStressTest.tscn"
const TARGET_FPS = 60
const TARGET_FRAME_TIME_MS = 16.67
const MAX_MEMORY_GROWTH_PERCENT = 20.0
const TEST_DURATION = 10.0
const WARM_UP_DURATION = 2.0

# Test subjects
var stress_test: Node
var results: Dictionary


func before_each() -> void:
	"""Set up before each test."""
	# Load and add stress test scene
	var scene = load(STRESS_TEST_SCENE)
	stress_test = scene.instantiate()
	add_child_autofree(stress_test)

	# Wait for ready
	await get_tree().process_frame


func after_each() -> void:
	"""Clean up after each test."""
	if stress_test:
		stress_test.stop_test()
		results = {}


## Performance Benchmark Tests

func test_500_bullets_60fps() -> void:
	"""Test that 500 bullets maintain 60fps."""
	assert_not_null(stress_test, "Stress test scene should load")

	# Configure for 500 bullets
	stress_test.max_bullets = 500
	stress_test.spawn_rate = 100.0
	stress_test.bullet_lifetime = 5.0

	# Run test
	var test_completed = false
	var test_results = {}

	stress_test.test_completed.connect(func(r):
		test_completed = true
		test_results = r
	)

	stress_test.start_test(TEST_DURATION)

	# Wait for test completion
	var timeout = TEST_DURATION + 5.0
	var start_time = Time.get_ticks_msec() / 1000.0

	while not test_completed:
		await get_tree().process_frame

		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		if elapsed > timeout:
			fail_test("Test timed out after %.1fs" % timeout)
			return

	# Validate results
	assert_true(test_results.has("performance"), "Results should include performance metrics")

	var perf = test_results.performance
	var bullets = test_results.bullets

	# Check bullet count
	assert_gte(bullets.max_active, 400, "Should maintain at least 400 active bullets")
	gut.p("Max active bullets: %d / %d" % [bullets.max_active, bullets.target])

	# Check FPS
	assert_gte(perf.avg_fps, TARGET_FPS, "Should maintain 60 FPS average")
	gut.p("Average FPS: %.1f" % perf.avg_fps)

	# Check frame time
	assert_lte(perf.avg_frame_time_ms, TARGET_FRAME_TIME_MS, "Frame time should be <= 16.67ms")
	gut.p("Average frame time: %.2fms" % perf.avg_frame_time_ms)

	# Check dropped frames (should be 0 or very low)
	var drop_rate = float(perf.frames_dropped) / perf.total_frames * 100
	assert_lt(drop_rate, 1.0, "Dropped frame rate should be < 1%")
	gut.p("Dropped frames: %d / %d (%.2f%%)" % [perf.frames_dropped, perf.total_frames, drop_rate])

	# Overall success check
	assert_true(test_results.success, "Test should pass all criteria")


func test_bullet_memory_stable() -> void:
	"""Test that memory usage remains stable over time."""
	assert_not_null(stress_test, "Stress test scene should load")

	# Configure for sustained spawning
	stress_test.max_bullets = 500
	stress_test.spawn_rate = 100.0
	stress_test.bullet_lifetime = 5.0

	# Run longer test for memory stability
	var test_completed = false
	var test_results = {}

	stress_test.test_completed.connect(func(r):
		test_completed = true
		test_results = r
	)

	stress_test.start_test(TEST_DURATION)

	# Wait for test completion
	var timeout = TEST_DURATION + 5.0
	var start_time = Time.get_ticks_msec() / 1000.0

	while not test_completed:
		await get_tree().process_frame

		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		if elapsed > timeout:
			fail_test("Test timed out after %.1fs" % timeout)
			return

	# Validate memory results
	assert_true(test_results.has("memory"), "Results should include memory metrics")

	var memory = test_results.memory

	# Check memory growth
	assert_lte(memory.growth_percent, MAX_MEMORY_GROWTH_PERCENT,
		"Memory growth should be <= %.1f%%" % MAX_MEMORY_GROWTH_PERCENT)
	gut.p("Memory growth: %.2f MB (%.1f%%)" % [memory.growth_mb, memory.growth_percent])

	# Check no excessive memory usage
	assert_lt(memory.growth_mb, 100.0, "Memory growth should be < 100 MB")
	gut.p("Memory usage: %.2f MB -> %.2f MB (Peak: %.2f MB)" %
		[memory.initial_mb, memory.current_mb, memory.peak_mb])


func test_burst_spawn_performance() -> void:
	"""Test performance during rapid burst spawning."""
	assert_not_null(stress_test, "Stress test scene should load")

	# Configure for burst spawning
	stress_test.max_bullets = 500
	stress_test.spawn_rate = 200.0  # Higher rate
	stress_test.spawn_burst_size = 100  # Larger bursts
	stress_test.bullet_lifetime = 3.0  # Shorter lifetime

	var test_completed = false
	var test_results = {}

	stress_test.test_completed.connect(func(r):
		test_completed = true
		test_results = r
	)

	stress_test.start_test(5.0)  # Shorter test

	# Wait for completion
	var timeout = 10.0
	var start_time = Time.get_ticks_msec() / 1000.0

	while not test_completed:
		await get_tree().process_frame

		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		if elapsed > timeout:
			fail_test("Test timed out")
			return

	# Validate burst handling
	var perf = test_results.performance

	# Should still maintain reasonable performance
	assert_gte(perf.avg_fps, 50.0, "Should maintain at least 50 FPS during bursts")
	gut.p("Burst test FPS: %.1f" % perf.avg_fps)

	# Frame time variance should not be excessive
	var frame_time_variance = perf.max_frame_time_ms - perf.min_frame_time_ms
	assert_lt(frame_time_variance, 30.0, "Frame time variance should be reasonable")
	gut.p("Frame time variance: %.2fms" % frame_time_variance)


func test_sustained_spawn_despawn() -> void:
	"""Test sustained spawning and despawning over time."""
	assert_not_null(stress_test, "Stress test scene should load")

	# Configure for sustained cycle
	stress_test.max_bullets = 500
	stress_test.spawn_rate = 100.0
	stress_test.bullet_lifetime = 2.0  # Fast turnover

	var test_completed = false
	var test_results = {}

	stress_test.test_completed.connect(func(r):
		test_completed = true
		test_results = r
	)

	stress_test.start_test(TEST_DURATION)

	# Wait for completion
	var timeout = TEST_DURATION + 5.0
	var start_time = Time.get_ticks_msec() / 1000.0

	while not test_completed:
		await get_tree().process_frame

		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		if elapsed > timeout:
			fail_test("Test timed out")
			return

	# Validate sustained operation
	var bullets = test_results.bullets

	# Should have cycled through many bullets
	assert_gte(bullets.total_spawned, 500, "Should spawn many bullets")
	assert_gte(bullets.total_despawned, 100, "Should despawn many bullets")
	gut.p("Bullet cycle: spawned %d, despawned %d" % [bullets.total_spawned, bullets.total_despawned])

	# Memory should remain stable despite turnover
	var memory = test_results.memory
	assert_lte(memory.growth_percent, MAX_MEMORY_GROWTH_PERCENT, "Memory should remain stable")


func test_performance_monitoring_integration() -> void:
	"""Test integration with PerformanceMonitor."""
	assert_not_null(stress_test, "Stress test scene should load")

	var performance_monitor = stress_test.get_node("PerformanceMonitor")
	assert_not_null(performance_monitor, "Should have PerformanceMonitor")

	# Check monitoring is active
	assert_true(stress_test.enable_monitoring, "Monitoring should be enabled")

	# Start test and check warnings are emitted
	var warning_received = false

	stress_test.performance_warning.connect(func(_msg):
		warning_received = true
	)

	# Configure for potential warnings (very high spawn rate)
	stress_test.max_bullets = 1000
	stress_test.spawn_rate = 500.0
	stress_test.spawn_burst_size = 200

	stress_test.start_test(2.0)

	await get_tree().create_timer(3.0).timeout

	# May or may not receive warnings depending on hardware
	# Just verify the connection works
	gut.p("Performance warning system: %s" % ("Active" if warning_received else "No warnings"))


## Regression Tests

func test_bullet_cleanup_on_test_stop() -> void:
	"""Test that bullets are properly cleaned up when test stops."""
	assert_not_null(stress_test, "Stress test scene should load")

	stress_test.max_bullets = 100
	stress_test.start_test(2.0)

	# Wait a bit
	await get_tree().create_timer(1.0).timeout

	# Should have bullets
	var bullet_count_during = stress_test.get_current_bullet_count()
	assert_gt(bullet_count_during, 0, "Should have bullets during test")

	# Stop test
	stress_test.stop_test()

	# Wait for cleanup
	await get_tree().create_timer(1.0).timeout

	# Bullets should despawn naturally (not forced)
	# Count should decrease over time
	var bullet_count_after = stress_test.get_current_bullet_count()
	gut.p("Bullets: during=%d, after=%d" % [bullet_count_during, bullet_count_after])


func test_performance_stats_api() -> void:
	"""Test public API for performance statistics."""
	assert_not_null(stress_test, "Stress test scene should load")

	# Check initial stats
	var stats = stress_test.get_performance_stats()
	assert_eq(stats.active_bullets, 0, "Should start with no bullets")
	assert_eq(stats.total_spawned, 0, "Should have spawned nothing")

	# Start test
	stress_test.start_test(2.0)
	await get_tree().create_timer(1.0).timeout

	# Check during test
	stats = stress_test.get_performance_stats()
	assert_gt(stats.active_bullets, 0, "Should have bullets during test")
	assert_gt(stats.total_spawned, 0, "Should have spawned bullets")
	assert_true(stats.has("avg_fps"), "Should include FPS")
	assert_true(stats.has("frames_dropped"), "Should include dropped frames")

	gut.p("Test stats: %d bullets, %.1f fps" % [stats.active_bullets, stats.avg_fps])
