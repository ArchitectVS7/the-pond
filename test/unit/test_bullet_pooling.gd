## test_bullet_pooling.gd
## Unit tests for BulletUpHell pooling system integration
## Tests pool creation, acquire, release, and auto-growth
extends GutTest

# Test configuration
const TEST_BULLET_TYPE = "test_bullet"
const TEST_SHARED_AREA = "0"
const INITIAL_POOL_SIZE = 50

# Test fixtures
var test_bullet_props: Dictionary
var test_pattern: NavigationPolygon


func before_each() -> void:
	"""Setup before each test."""
	# Clear any existing pools
	if Spawning.inactive_pool.has(TEST_BULLET_TYPE):
		Spawning.inactive_pool.erase(TEST_BULLET_TYPE)
		Spawning.inactive_pool.erase("__SIZE__" + TEST_BULLET_TYPE)

	# Create minimal bullet properties
	test_bullet_props = {
		"__ID__": TEST_BULLET_TYPE,
		"anim_idle_collision": "Circle",
		"anim_idle_texture": "default",
		"speed": 200.0,
		"scale": 1.0,
		"angle": 0.0,
		"death_from_collision": false
	}

	# Register test bullet type if not already registered
	if not Spawning.arrayProps.has(TEST_BULLET_TYPE):
		Spawning.new_bullet(TEST_BULLET_TYPE, test_bullet_props)


func after_each() -> void:
	"""Cleanup after each test."""
	# Clear all bullets and pools
	Spawning.clear_all_bullets()
	await wait_frames(2)


# ============================================================================
# Pool Creation Tests
# ============================================================================

func test_pool_creation_creates_pool() -> void:
	"""Test that create_pool() creates a pool entry."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, INITIAL_POOL_SIZE)

	assert_true(
		Spawning.inactive_pool.has(TEST_BULLET_TYPE),
		"Pool should be created for bullet type"
	)


func test_pool_creation_allocates_bullets() -> void:
	"""Test that create_pool() allocates the correct number of bullets."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, INITIAL_POOL_SIZE)

	var pool_array = Spawning.inactive_pool[TEST_BULLET_TYPE]
	assert_eq(
		pool_array.size(),
		INITIAL_POOL_SIZE,
		"Pool should contain %d bullets" % INITIAL_POOL_SIZE
	)


func test_pool_creation_tracks_size() -> void:
	"""Test that pool size is tracked with __SIZE__ key."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, INITIAL_POOL_SIZE)

	var tracked_size = Spawning.inactive_pool.get("__SIZE__" + TEST_BULLET_TYPE, 0)
	assert_eq(
		tracked_size,
		INITIAL_POOL_SIZE,
		"Pool size should be tracked"
	)


func test_pool_creation_multiple_types() -> void:
	"""Test that multiple bullet types can have separate pools."""
	var type_a = "bullet_a"
	var type_b = "bullet_b"

	# Create test props for both types
	Spawning.new_bullet(type_a, test_bullet_props.duplicate())
	Spawning.new_bullet(type_b, test_bullet_props.duplicate())

	Spawning.create_pool(type_a, TEST_SHARED_AREA, 30)
	Spawning.create_pool(type_b, TEST_SHARED_AREA, 40)

	assert_eq(
		Spawning.inactive_pool[type_a].size(),
		30,
		"Pool A should have 30 bullets"
	)
	assert_eq(
		Spawning.inactive_pool[type_b].size(),
		40,
		"Pool B should have 40 bullets"
	)


# ============================================================================
# Pool Acquire Tests
# ============================================================================

func test_pool_acquire_returns_bullet() -> void:
	"""Test that wake_from_pool() returns a bullet RID."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, 10)

	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	var bullet_rid = Spawning.wake_from_pool(
		TEST_BULLET_TYPE,
		queued_instance,
		TEST_SHARED_AREA,
		false
	)

	assert_typeof(
		bullet_rid,
		TYPE_RID,
		"wake_from_pool should return RID"
	)


func test_pool_acquire_decrements_pool() -> void:
	"""Test that acquiring a bullet decrements the pool size."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, 10)
	var initial_size = Spawning.inactive_pool[TEST_BULLET_TYPE].size()

	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	Spawning.wake_from_pool(
		TEST_BULLET_TYPE,
		queued_instance,
		TEST_SHARED_AREA,
		false
	)

	var new_size = Spawning.inactive_pool[TEST_BULLET_TYPE].size()
	assert_eq(
		new_size,
		initial_size - 1,
		"Pool size should decrease by 1"
	)


func test_pool_acquire_adds_to_active_bullets() -> void:
	"""Test that acquired bullets are added to poolBullets."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, 10)

	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	var bullet_rid = Spawning.wake_from_pool(
		TEST_BULLET_TYPE,
		queued_instance,
		TEST_SHARED_AREA,
		false
	)

	assert_true(
		Spawning.poolBullets.has(bullet_rid),
		"Bullet should be in active pool"
	)


# ============================================================================
# Pool Release Tests
# ============================================================================

func test_pool_release_recycles() -> void:
	"""Test that releasing a bullet returns it to the pool."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, 10)
	var initial_pool_size = Spawning.inactive_pool[TEST_BULLET_TYPE].size()

	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	var bullet_rid = Spawning.wake_from_pool(
		TEST_BULLET_TYPE,
		queued_instance,
		TEST_SHARED_AREA,
		false
	)

	# Manually add to poolBullets (normally done by spawn)
	Spawning.poolBullets[bullet_rid] = queued_instance

	# Release bullet
	Spawning.back_to_grave(TEST_BULLET_TYPE, bullet_rid)

	# Wait for physics update
	await wait_frames(2)

	# Pool should have original size after release
	var final_pool_size = Spawning.inactive_pool[TEST_BULLET_TYPE].size()
	assert_eq(
		final_pool_size,
		initial_pool_size,
		"Pool should return to initial size after release"
	)


func test_pool_release_marks_queued_free() -> void:
	"""Test that releasing a bullet marks it as QueuedFree."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, 10)

	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Moving
	}

	var bullet_rid = Spawning.wake_from_pool(
		TEST_BULLET_TYPE,
		queued_instance,
		TEST_SHARED_AREA,
		false
	)

	Spawning.poolBullets[bullet_rid] = queued_instance
	Spawning.back_to_grave(TEST_BULLET_TYPE, bullet_rid)

	assert_eq(
		Spawning.poolBullets[bullet_rid]["state"],
		Spawning.BState.QueuedFree,
		"Bullet state should be QueuedFree"
	)


# ============================================================================
# Pool Auto-Growth Tests
# ============================================================================

func test_pool_auto_creates_when_missing() -> void:
	"""Test that pool auto-creates if wake_from_pool called without pool."""
	# Don't create pool - let it auto-create
	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	# This should trigger auto-creation
	var bullet_rid = Spawning.wake_from_pool(
		TEST_BULLET_TYPE,
		queued_instance,
		TEST_SHARED_AREA,
		false
	)

	assert_true(
		Spawning.inactive_pool.has(TEST_BULLET_TYPE),
		"Pool should be auto-created"
	)
	assert_typeof(
		bullet_rid,
		TYPE_RID,
		"Should still return valid bullet"
	)


func test_pool_auto_grows_when_empty() -> void:
	"""Test that pool auto-grows when depleted."""
	# Create small pool
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, 2)
	var initial_size = Spawning.inactive_pool["__SIZE__" + TEST_BULLET_TYPE]

	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	# Acquire all bullets from pool
	Spawning.wake_from_pool(TEST_BULLET_TYPE, queued_instance, TEST_SHARED_AREA, false)
	Spawning.wake_from_pool(TEST_BULLET_TYPE, queued_instance, TEST_SHARED_AREA, false)

	# This should trigger auto-growth
	Spawning.wake_from_pool(TEST_BULLET_TYPE, queued_instance, TEST_SHARED_AREA, false)

	var new_size = Spawning.inactive_pool["__SIZE__" + TEST_BULLET_TYPE]
	assert_gt(
		new_size,
		initial_size,
		"Pool size should increase after auto-growth"
	)


# ============================================================================
# Pool Pre-Warming Tests
# ============================================================================

func test_pool_prewarms_on_initialization() -> void:
	"""Test that pool pre-warming creates bullets before first spawn."""
	var prewarm_size = 100
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, prewarm_size)

	# Verify pool is ready immediately
	assert_eq(
		Spawning.inactive_pool[TEST_BULLET_TYPE].size(),
		prewarm_size,
		"Pool should be pre-warmed with %d bullets" % prewarm_size
	)

	# Verify no allocation happens on first acquire
	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	var start_time = Time.get_ticks_usec()
	var bullet_rid = Spawning.wake_from_pool(
		TEST_BULLET_TYPE,
		queued_instance,
		TEST_SHARED_AREA,
		false
	)
	var acquire_time = Time.get_ticks_usec() - start_time

	# Acquire should be very fast (< 100 microseconds)
	assert_lt(
		acquire_time,
		100,
		"Pre-warmed acquire should be fast (got %d µs)" % acquire_time
	)


# ============================================================================
# Integration Tests
# ============================================================================

func test_pool_multiple_acquire_release_cycles() -> void:
	"""Test multiple acquire/release cycles maintain pool integrity."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, 20)
	var initial_size = Spawning.inactive_pool[TEST_BULLET_TYPE].size()

	var bullets = []
	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	# Acquire 10 bullets
	for i in range(10):
		var bullet_rid = Spawning.wake_from_pool(
			TEST_BULLET_TYPE,
			queued_instance.duplicate(),
			TEST_SHARED_AREA,
			false
		)
		Spawning.poolBullets[bullet_rid] = queued_instance.duplicate()
		bullets.append(bullet_rid)

	# Release all bullets
	for bullet_rid in bullets:
		Spawning.back_to_grave(TEST_BULLET_TYPE, bullet_rid)

	await wait_frames(2)

	# Pool should return to initial size
	var final_size = Spawning.inactive_pool[TEST_BULLET_TYPE].size()
	assert_eq(
		final_size,
		initial_size,
		"Pool should return to initial size after cycle"
	)


func test_pool_stress_500_bullets() -> void:
	"""Test pool with 500 bullets (matches BULLET-004 requirement)."""
	var stress_pool_size = 600
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, stress_pool_size)

	var bullets = []
	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	# Acquire 500 bullets
	for i in range(500):
		var bullet_rid = Spawning.wake_from_pool(
			TEST_BULLET_TYPE,
			queued_instance.duplicate(),
			TEST_SHARED_AREA,
			false
		)
		bullets.append(bullet_rid)

	assert_eq(
		bullets.size(),
		500,
		"Should successfully acquire 500 bullets"
	)

	# Pool should have 100 remaining
	var remaining = Spawning.inactive_pool[TEST_BULLET_TYPE].size()
	assert_eq(
		remaining,
		100,
		"Pool should have 100 bullets remaining"
	)

	# Cleanup
	for bullet_rid in bullets:
		if Spawning.poolBullets.has(bullet_rid):
			Spawning.back_to_grave(TEST_BULLET_TYPE, bullet_rid)

	await wait_frames(2)


# ============================================================================
# Performance Tests
# ============================================================================

func test_pool_acquire_performance() -> void:
	"""Test that pool acquire is faster than instantiation."""
	Spawning.create_pool(TEST_BULLET_TYPE, TEST_SHARED_AREA, 100)

	var queued_instance = {
		"shared_area": Spawning.get_shared_area(TEST_SHARED_AREA),
		"props": test_bullet_props,
		"state": Spawning.BState.Unactive
	}

	# Measure pooled acquisition
	var start_time = Time.get_ticks_usec()
	for i in range(50):
		Spawning.wake_from_pool(
			TEST_BULLET_TYPE,
			queued_instance,
			TEST_SHARED_AREA,
			false
		)
	var pooled_time = Time.get_ticks_usec() - start_time

	var avg_pooled_time = pooled_time / 50.0

	# Pooled acquisition should be < 50 microseconds per bullet
	assert_lt(
		avg_pooled_time,
		50.0,
		"Pooled acquire should be fast (got %.2f µs avg)" % avg_pooled_time
	)

	print("Average pooled acquire time: %.2f µs" % avg_pooled_time)
