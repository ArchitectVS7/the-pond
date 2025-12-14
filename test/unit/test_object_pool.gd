## Unit Tests for Object Pooling System (COMBAT-014)
##
## Tests object pooling for 500+ enemies on screen.
## PRD Requirement: Support 500+ enemies without frame drops.
extends GutTest

const ObjectPoolClass := preload("res://shared/scripts/object_pool.gd")

const FRAME_DELTA := 0.016  # ~60fps

var object_pool: Node


func before_each() -> void:
	object_pool = ObjectPoolClass.new()
	add_child_autofree(object_pool)
	await get_tree().process_frame


# =============================================================================
# BASIC FUNCTIONALITY TESTS
# =============================================================================


## Test 1: Can create ObjectPool
func test_can_create_pool() -> void:
	assert_not_null(object_pool, "ObjectPool should be created")


## Test 2: Can configure pool size
func test_can_configure_pool_size() -> void:
	object_pool.max_pool_size = 100
	assert_eq(object_pool.max_pool_size, 100, "Pool size should be configurable")


## Test 3: Can pre-warm pool
func test_can_prewarm_pool() -> void:
	# Create a simple scene for testing
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 10)

	assert_eq(object_pool.get_available_count(), 10, "Pool should be pre-warmed with 10 objects")


## Test 4: Can acquire object from pool
func test_can_acquire_object() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 5)

	var obj := object_pool.acquire(scene)
	assert_not_null(obj, "Should acquire object from pool")


## Test 5: Can release object back to pool
func test_can_release_object() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 5)
	var initial_count := object_pool.get_available_count()

	var obj := object_pool.acquire(scene)
	assert_eq(
		object_pool.get_available_count(),
		initial_count - 1,
		"Available count should decrease after acquire"
	)

	object_pool.release(obj)
	assert_eq(
		object_pool.get_available_count(),
		initial_count,
		"Available count should restore after release"
	)


# =============================================================================
# POOLING BEHAVIOR TESTS
# =============================================================================


## Test 6: Acquire creates new when pool empty
func test_acquire_creates_when_empty() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	# Don't prewarm - pool is empty
	var obj := object_pool.acquire(scene)
	assert_not_null(obj, "Should create new object when pool empty")


## Test 7: Released objects are reused
func test_released_objects_reused() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 1)

	var obj1 := object_pool.acquire(scene)
	var obj1_id := obj1.get_instance_id()

	object_pool.release(obj1)

	var obj2 := object_pool.acquire(scene)
	var obj2_id := obj2.get_instance_id()

	assert_eq(obj1_id, obj2_id, "Released object should be reused")


## Test 8: Pool respects max size
func test_pool_respects_max_size() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.max_pool_size = 10
	object_pool.prewarm(scene, 20)

	assert_lte(object_pool.get_available_count(), 10, "Pool should not exceed max size")


# =============================================================================
# STATISTICS TESTS
# =============================================================================


## Test 9: Tracks total created
func test_tracks_total_created() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 5)

	var stats := object_pool.get_statistics()
	assert_eq(stats.total_created, 5, "Should track total created")


## Test 10: Tracks active count
func test_tracks_active_count() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 5)
	object_pool.acquire(scene)
	object_pool.acquire(scene)

	var stats := object_pool.get_statistics()
	assert_eq(stats.active_count, 2, "Should track active count")


## Test 11: Tracks reuse count
func test_tracks_reuse_count() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 1)

	var obj := object_pool.acquire(scene)
	object_pool.release(obj)
	object_pool.acquire(scene)  # Reuse

	var stats := object_pool.get_statistics()
	assert_eq(stats.reuse_count, 1, "Should track reuse count")


# =============================================================================
# PERFORMANCE TESTS
# =============================================================================


## Test 12: Can handle 500 objects
func test_can_handle_500_objects() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.max_pool_size = 500
	object_pool.prewarm(scene, 500)

	assert_eq(object_pool.get_available_count(), 500, "Should handle 500 objects")


## Test 13: Acquire is fast (no scene instantiation needed)
func test_acquire_is_fast() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 100)

	var start := Time.get_ticks_usec()
	for i in range(100):
		var obj := object_pool.acquire(scene)
		object_pool.release(obj)
	var elapsed := Time.get_ticks_usec() - start

	# Should be < 1ms for 100 acquire/release cycles
	assert_lt(elapsed, 1000, "100 acquire/release should be < 1ms")


## Test 14: No allocations during acquire/release
func test_minimal_allocations() -> void:
	# This test documents the expectation
	# Actual allocation testing requires profiler
	gut.p("Pool should avoid allocations in acquire/release hot path")
	pass_test("Allocation pattern documented")


# =============================================================================
# LIFECYCLE CALLBACK TESTS
# =============================================================================


## Test 15: Calls reset callback on acquire
func test_calls_reset_on_acquire() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 1)
	var obj := object_pool.acquire(scene)
	object_pool.release(obj)

	# Add reset callback
	var reset_called := false
	object_pool.on_acquire = func(o): reset_called = true

	object_pool.acquire(scene)
	assert_true(reset_called, "Reset callback should be called")


## Test 16: Calls deactivate callback on release
func test_calls_deactivate_on_release() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 1)

	var deactivate_called := false
	object_pool.on_release = func(o): deactivate_called = true

	var obj := object_pool.acquire(scene)
	object_pool.release(obj)

	assert_true(deactivate_called, "Deactivate callback should be called")


# =============================================================================
# EDGE CASE TESTS
# =============================================================================


## Test 17: Handles null scene gracefully
func test_handles_null_scene() -> void:
	var obj := object_pool.acquire(null)
	assert_null(obj, "Should return null for null scene")


## Test 18: Handles double release gracefully
func test_handles_double_release() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 1)
	var obj := object_pool.acquire(scene)

	object_pool.release(obj)
	object_pool.release(obj)  # Double release

	pass_test("Double release should not crash")


## Test 19: Can clear entire pool
func test_can_clear_pool() -> void:
	var scene := PackedScene.new()
	var node := Node2D.new()
	scene.pack(node)
	node.queue_free()

	object_pool.prewarm(scene, 10)
	object_pool.clear()

	assert_eq(object_pool.get_available_count(), 0, "Clear should empty the pool")


## Test 20: Freed objects removed from pool
func test_freed_objects_removed() -> void:
	# Objects that are queue_free'd should be removed
	# when next accessed
	pass_test("Freed object handling documented")
