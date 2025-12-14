## test_bullet_pooling_performance.gd
## Performance benchmarks for BulletUpHell pooling system
## Compares pooled vs non-pooled bullet spawning and validates 500 bullet requirement
extends GutTest

# Test configuration
const BENCHMARK_BULLET_TYPE = "bench_bullet"
const STRESS_TEST_BULLETS = 500
const TEST_DURATION = 5.0
const TARGET_FPS = 60
const MAX_FRAME_TIME_MS = 16.67  # 60fps = 16.67ms per frame

# Test state
var test_scene: Node2D
var frame_times: Array[float] = []
var spawn_times: Array[float] = []


func before_all() -> void:
	"""Setup before all tests."""
	# Create test scene
	test_scene = Node2D.new()
	add_child_autofree(test_scene)

	# Create minimal bullet props
	var props = {
		"__ID__": BENCHMARK_BULLET_TYPE,
		"anim_idle_collision": "Circle",
		"anim_idle_texture": "default",
		"speed": 200.0,
		"scale": 1.0,
		"angle": 0.0,
		"death_from_collision": false
	}

	if not Spawning.arrayProps.has(BENCHMARK_BULLET_TYPE):
		Spawning.new_bullet(BENCHMARK_BULLET_TYPE, props)


func before_each() -> void:
	"""Setup before each test."""
	frame_times.clear()
	spawn_times.clear()
	Spawning.clear_all_bullets()
	await wait_frames(2)


func after_each() -> void:
	"""Cleanup after each test."""
	Spawning.clear_all_bullets()
	await wait_frames(2)


# ============================================================================
# Spawn Performance Benchmarks
# ============================================================================

func test_pooled_spawn_performance() -> void:
	"""Benchmark pooled bullet spawning performance."""
	# Pre-warm large pool
	Spawning.create_pool(BENCHMARK_BULLET_TYPE, "0", 1000)

	var queued_instance = {
		"shared_area": Spawning.get_shared_area("0"),
		"props": Spawning.arrayProps[BENCHMARK_BULLET_TYPE],
		"state": Spawning.BState.Unactive
	}

	# Measure spawn time for 100 bullets
	var iterations = 100
	var total_time_us = 0

	for i in range(iterations):
		var start = Time.get_ticks_usec()

		Spawning.wake_from_pool(
			BENCHMARK_BULLET_TYPE,
			queued_instance,
			"0",
			false
		)

		var end = Time.get_ticks_usec()
		spawn_times.append(end - start)
		total_time_us += (end - start)

	var avg_time_us = total_time_us / float(iterations)
	var max_time_us = spawn_times.max()
	var min_time_us = spawn_times.min()

	print("\n=== POOLED SPAWN PERFORMANCE ===")
	print("Iterations: %d" % iterations)
	print("Avg spawn time: %.2f µs" % avg_time_us)
	print("Min spawn time: %.2f µs" % min_time_us)
	print("Max spawn time: %.2f µs" % max_time_us)
	print("================================\n")

	# Pooled spawn should be very fast (< 50 µs)
	assert_lt(
		avg_time_us,
		50.0,
		"Average pooled spawn time should be < 50 µs (got %.2f µs)" % avg_time_us
	)


func test_spawn_consistency() -> void:
	"""Test that spawn times are consistent with pooling."""
	Spawning.create_pool(BENCHMARK_BULLET_TYPE, "0", 500)

	var queued_instance = {
		"shared_area": Spawning.get_shared_area("0"),
		"props": Spawning.arrayProps[BENCHMARK_BULLET_TYPE],
		"state": Spawning.BState.Unactive
	}

	# Measure spawn time variance
	for i in range(100):
		var start = Time.get_ticks_usec()
		Spawning.wake_from_pool(BENCHMARK_BULLET_TYPE, queued_instance, "0", false)
		var end = Time.get_ticks_usec()
		spawn_times.append(end - start)

	# Calculate standard deviation
	var avg = spawn_times.reduce(func(a, b): return a + b) / spawn_times.size()
	var variance = 0.0
	for time in spawn_times:
		variance += pow(time - avg, 2)
	variance /= spawn_times.size()
	var std_dev = sqrt(variance)

	print("\n=== SPAWN CONSISTENCY ===")
	print("Average: %.2f µs" % avg)
	print("Std Dev: %.2f µs" % std_dev)
	print("Coefficient of Variation: %.2f%%" % ((std_dev / avg) * 100))
	print("========================\n")

	# Coefficient of variation should be low (< 50%)
	var cv = (std_dev / avg) * 100
	assert_lt(
		cv,
		50.0,
		"Spawn time variance should be low (CV < 50%, got %.2f%%)" % cv
	)


# ============================================================================
# Stress Test - 500 Bullets @ 60fps (BULLET-004 Requirement)
# ============================================================================

func test_500_bullets_60fps() -> void:
	"""
	Stress test: 500 bullets at 60fps.
	Matches BULLET-004 acceptance criteria.
	"""
	# Pre-warm pool with headroom
	Spawning.create_pool(BENCHMARK_BULLET_TYPE, "0", 600)

	var bullet_rids = []
	var queued_instance = {
		"shared_area": Spawning.get_shared_area("0"),
		"props": Spawning.arrayProps[BENCHMARK_BULLET_TYPE],
		"state": Spawning.BState.Moving,
		"position": Vector2.ZERO,
		"rotation": 0.0,
		"speed": 200.0,
		"vel": Vector2(200, 0),
		"scale": Vector2.ONE
	}

	# Spawn 500 bullets
	print("\n=== SPAWNING 500 BULLETS ===")
	var spawn_start = Time.get_ticks_msec()

	for i in range(STRESS_TEST_BULLETS):
		var bullet_rid = Spawning.wake_from_pool(
			BENCHMARK_BULLET_TYPE,
			queued_instance.duplicate(),
			"0",
			false
		)

		# Set position in circle pattern
		var angle = (TAU / STRESS_TEST_BULLETS) * i
		var instance = queued_instance.duplicate()
		instance["position"] = Vector2(cos(angle), sin(angle)) * 100
		instance["rotation"] = angle

		Spawning.poolBullets[bullet_rid] = instance
		bullet_rids.append(bullet_rid)

	var spawn_end = Time.get_ticks_msec()
	print("Spawned %d bullets in %d ms" % [STRESS_TEST_BULLETS, spawn_end - spawn_start])

	# Run for test duration and measure frame times
	print("Running stress test for %.1f seconds..." % TEST_DURATION)
	var test_start = Time.get_ticks_msec()
	var frames = 0
	var dropped_frames = 0

	while (Time.get_ticks_msec() - test_start) < (TEST_DURATION * 1000):
		var frame_start = Time.get_ticks_usec()

		# Simulate bullet movement (BulletUpHell handles this in _physics_process)
		await get_tree().process_frame

		var frame_end = Time.get_ticks_usec()
		var frame_time_ms = (frame_end - frame_start) / 1000.0
		frame_times.append(frame_time_ms)

		if frame_time_ms > MAX_FRAME_TIME_MS:
			dropped_frames += 1

		frames += 1

	# Calculate metrics
	var total_time = frame_times.reduce(func(a, b): return a + b)
	var avg_frame_time = total_time / frames
	var max_frame_time = frame_times.max()
	var min_frame_time = frame_times.min()
	var avg_fps = 1000.0 / avg_frame_time

	print("\n=== STRESS TEST RESULTS ===")
	print("Bullets: %d" % STRESS_TEST_BULLETS)
	print("Duration: %.1f seconds" % TEST_DURATION)
	print("Frames: %d" % frames)
	print("Avg FPS: %.1f" % avg_fps)
	print("Avg Frame Time: %.2f ms" % avg_frame_time)
	print("Min Frame Time: %.2f ms" % min_frame_time)
	print("Max Frame Time: %.2f ms" % max_frame_time)
	print("Dropped Frames: %d (%.1f%%)" % [
		dropped_frames,
		(float(dropped_frames) / frames * 100)
	])
	print("==========================\n")

	# Assertions
	assert_gte(
		avg_fps,
		TARGET_FPS,
		"Should maintain average 60 FPS (got %.1f)" % avg_fps
	)

	var drop_rate = float(dropped_frames) / frames
	assert_lt(
		drop_rate,
		0.05,
		"Dropped frame rate should be < 5%% (got %.1f%%)" % (drop_rate * 100)
	)

	# Cleanup
	for bullet_rid in bullet_rids:
		if Spawning.poolBullets.has(bullet_rid):
			Spawning.back_to_grave(BENCHMARK_BULLET_TYPE, bullet_rid)

	await wait_frames(2)


# ============================================================================
# Memory Stability Tests
# ============================================================================

func test_memory_stable_with_pooling() -> void:
	"""Test that pooling prevents memory growth."""
	# Pre-warm pool
	Spawning.create_pool(BENCHMARK_BULLET_TYPE, "0", 400)

	var initial_mem = OS.get_static_memory_usage()
	var memory_samples = []

	var queued_instance = {
		"shared_area": Spawning.get_shared_area("0"),
		"props": Spawning.arrayProps[BENCHMARK_BULLET_TYPE],
		"state": Spawning.BState.Moving,
		"position": Vector2.ZERO,
		"rotation": 0.0,
		"speed": 200.0,
		"vel": Vector2(200, 0)
	}

	print("\n=== MEMORY STABILITY TEST ===")
	print("Initial memory: %.2f MB" % (initial_mem / 1024.0 / 1024.0))

	# Spawn and despawn 1000 bullets in batches
	for batch in range(10):
		var bullets = []

		# Spawn 100 bullets
		for i in range(100):
			var bullet_rid = Spawning.wake_from_pool(
				BENCHMARK_BULLET_TYPE,
				queued_instance.duplicate(),
				"0",
				false
			)
			Spawning.poolBullets[bullet_rid] = queued_instance.duplicate()
			bullets.append(bullet_rid)

		await wait_frames(5)

		# Despawn all bullets
		for bullet_rid in bullets:
			Spawning.back_to_grave(BENCHMARK_BULLET_TYPE, bullet_rid)

		await wait_frames(5)

		# Sample memory
		var current_mem = OS.get_static_memory_usage()
		memory_samples.append(current_mem)

		print("Batch %d: %.2f MB" % [batch + 1, current_mem / 1024.0 / 1024.0])

	var final_mem = OS.get_static_memory_usage()
	var growth = float(final_mem - initial_mem) / initial_mem

	print("\nFinal memory: %.2f MB" % (final_mem / 1024.0 / 1024.0))
	print("Memory growth: %.2f%%" % (growth * 100))
	print("============================\n")

	# Memory growth should be minimal (< 10%)
	assert_lt(
		growth,
		0.10,
		"Memory growth should be < 10%% (got %.2f%%)" % (growth * 100)
	)


# ============================================================================
# Pool Scaling Tests
# ============================================================================

func test_pool_scales_efficiently() -> void:
	"""Test that pool performance scales with size."""
	var pool_sizes = [100, 300, 500, 1000]
	var results = {}

	for pool_size in pool_sizes:
		# Clear previous pool
		if Spawning.inactive_pool.has(BENCHMARK_BULLET_TYPE):
			Spawning.inactive_pool.erase(BENCHMARK_BULLET_TYPE)
			Spawning.inactive_pool.erase("__SIZE__" + BENCHMARK_BULLET_TYPE)

		# Create pool
		Spawning.create_pool(BENCHMARK_BULLET_TYPE, "0", pool_size)

		var queued_instance = {
			"shared_area": Spawning.get_shared_area("0"),
			"props": Spawning.arrayProps[BENCHMARK_BULLET_TYPE],
			"state": Spawning.BState.Unactive
		}

		# Measure acquire time for 50 bullets
		var total_time = 0
		for i in range(50):
			var start = Time.get_ticks_usec()
			Spawning.wake_from_pool(BENCHMARK_BULLET_TYPE, queued_instance, "0", false)
			var end = Time.get_ticks_usec()
			total_time += (end - start)

		var avg_time = total_time / 50.0
		results[pool_size] = avg_time

		Spawning.clear_all_bullets()
		await wait_frames(2)

	print("\n=== POOL SCALING TEST ===")
	for pool_size in pool_sizes:
		print("Pool size %d: %.2f µs avg acquire" % [pool_size, results[pool_size]])
	print("========================\n")

	# All sizes should have similar performance (within 2x)
	var times = results.values()
	var min_time = times.min()
	var max_time = times.max()
	var ratio = max_time / min_time

	assert_lt(
		ratio,
		2.0,
		"Pool performance should scale well (ratio < 2.0, got %.2f)" % ratio
	)


# ============================================================================
# Comparison Tests (Pooled vs Non-Pooled)
# ============================================================================

func test_pooling_performance_improvement() -> void:
	"""
	Compare pooled vs non-pooled performance.
	Note: BulletUpHell always uses pooling, so this tests pre-warmed vs auto-created pools.
	"""
	# Test 1: Pre-warmed pool
	Spawning.create_pool(BENCHMARK_BULLET_TYPE, "0", 200)

	var queued_instance = {
		"shared_area": Spawning.get_shared_area("0"),
		"props": Spawning.arrayProps[BENCHMARK_BULLET_TYPE],
		"state": Spawning.BState.Unactive
	}

	var prewarm_times = []
	for i in range(50):
		var start = Time.get_ticks_usec()
		Spawning.wake_from_pool(BENCHMARK_BULLET_TYPE, queued_instance, "0", false)
		var end = Time.get_ticks_usec()
		prewarm_times.append(end - start)

	Spawning.clear_all_bullets()
	await wait_frames(5)

	# Test 2: Auto-created pool (cold start)
	# Clear pool
	Spawning.inactive_pool.erase(BENCHMARK_BULLET_TYPE)
	Spawning.inactive_pool.erase("__SIZE__" + BENCHMARK_BULLET_TYPE)

	var cold_times = []
	for i in range(50):
		var start = Time.get_ticks_usec()
		Spawning.wake_from_pool(BENCHMARK_BULLET_TYPE, queued_instance, "0", false)
		var end = Time.get_ticks_usec()
		cold_times.append(end - start)

	var prewarm_avg = prewarm_times.reduce(func(a, b): return a + b) / prewarm_times.size()
	var cold_avg = cold_times.reduce(func(a, b): return a + b) / cold_times.size()

	print("\n=== POOLING IMPROVEMENT ===")
	print("Pre-warmed avg: %.2f µs" % prewarm_avg)
	print("Cold start avg: %.2f µs" % cold_avg)
	print("Improvement: %.1fx faster" % (cold_avg / prewarm_avg))
	print("==========================\n")

	# Pre-warmed should be at least 2x faster
	assert_gt(
		cold_avg / prewarm_avg,
		2.0,
		"Pre-warmed pool should be at least 2x faster"
	)
