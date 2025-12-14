## Unit Tests for Spatial Hash Collision Optimization (COMBAT-007)
##
## Tests spatial hash grid for efficient collision detection.
## Reduces O(n^2) to O(n*k) where k = avg entities per cell.
extends GutTest

const SpatialHashClass := preload("res://combat/scripts/spatial_hash.gd")

const CELL_SIZE := 64.0  # Standard cell size for testing

var spatial_hash: RefCounted


func before_each() -> void:
	spatial_hash = SpatialHashClass.new(CELL_SIZE)


# =============================================================================
# BASIC FUNCTIONALITY TESTS
# =============================================================================


## Test 1: Can insert and query entities
func test_insert_and_query() -> void:
	var entity := _create_mock_entity(Vector2(100, 100))
	spatial_hash.insert(entity)

	var nearby := spatial_hash.query_nearby(Vector2(100, 100))

	assert_true(entity in nearby, "Inserted entity should be queryable at its position")


## Test 2: Query returns only nearby entities
func test_returns_only_nearby_entities() -> void:
	var close_entity := _create_mock_entity(Vector2(100, 100))
	var far_entity := _create_mock_entity(Vector2(500, 500))

	spatial_hash.insert(close_entity)
	spatial_hash.insert(far_entity)

	var nearby := spatial_hash.query_nearby(Vector2(100, 100))

	assert_true(close_entity in nearby, "Close entity should be in nearby results")
	assert_false(far_entity in nearby, "Far entity should NOT be in nearby results")


## Test 3: Query returns entities in adjacent cells
func test_returns_entities_in_adjacent_cells() -> void:
	# Entity in center cell
	var center_entity := _create_mock_entity(Vector2(100, 100))
	# Entity in adjacent cell (within 1 cell)
	var adjacent_entity := _create_mock_entity(Vector2(150, 100))

	spatial_hash.insert(center_entity)
	spatial_hash.insert(adjacent_entity)

	var nearby := spatial_hash.query_nearby(Vector2(100, 100))

	assert_true(center_entity in nearby, "Center entity should be in results")
	assert_true(adjacent_entity in nearby, "Adjacent cell entity should be in results")


## Test 4: Empty area returns empty results
func test_empty_area_returns_empty() -> void:
	var entity := _create_mock_entity(Vector2(100, 100))
	spatial_hash.insert(entity)

	var nearby := spatial_hash.query_nearby(Vector2(1000, 1000))

	assert_eq(nearby.size(), 0, "Query in empty area should return empty array")


## Test 5: Can remove entities
func test_remove_entity() -> void:
	var entity := _create_mock_entity(Vector2(100, 100))
	spatial_hash.insert(entity)
	spatial_hash.remove(entity)

	var nearby := spatial_hash.query_nearby(Vector2(100, 100))

	assert_false(entity in nearby, "Removed entity should not be in results")


## Test 6: Update entity position
func test_update_entity_position() -> void:
	var entity := _create_mock_entity(Vector2(100, 100))
	spatial_hash.insert(entity)

	# Move entity to new position
	entity.global_position = Vector2(500, 500)
	spatial_hash.update(entity)

	# Should not be at old position
	var old_nearby := spatial_hash.query_nearby(Vector2(100, 100))
	assert_false(entity in old_nearby, "Entity should not be at old position after update")

	# Should be at new position
	var new_nearby := spatial_hash.query_nearby(Vector2(500, 500))
	assert_true(entity in new_nearby, "Entity should be at new position after update")


# =============================================================================
# CELL CALCULATION TESTS
# =============================================================================


## Test 7: Correct cell calculation
func test_cell_calculation() -> void:
	# With cell size 64:
	# Position (100, 100) -> cell (1, 1)
	# Position (0, 0) -> cell (0, 0)
	# Position (-100, -100) -> cell (-2, -2)

	var cell1 := spatial_hash.get_cell_key(Vector2(100, 100))
	var cell2 := spatial_hash.get_cell_key(Vector2(0, 0))
	var cell3 := spatial_hash.get_cell_key(Vector2(64, 64))

	assert_eq(cell1, Vector2i(1, 1), "Position (100, 100) should be in cell (1, 1)")
	assert_eq(cell2, Vector2i(0, 0), "Position (0, 0) should be in cell (0, 0)")
	assert_eq(cell3, Vector2i(1, 1), "Position (64, 64) should be in cell (1, 1)")


## Test 8: Handles negative positions
func test_handles_negative_positions() -> void:
	var entity := _create_mock_entity(Vector2(-100, -100))
	spatial_hash.insert(entity)

	var nearby := spatial_hash.query_nearby(Vector2(-100, -100))

	assert_true(entity in nearby, "Entity at negative position should be queryable")


# =============================================================================
# RADIUS QUERY TESTS
# =============================================================================


## Test 9: Query with custom radius
func test_query_with_radius() -> void:
	var entity := _create_mock_entity(Vector2(100, 100))
	spatial_hash.insert(entity)

	# Large radius should find entity
	var large_radius := spatial_hash.query_radius(Vector2(100, 100), 50.0)
	assert_true(entity in large_radius, "Entity within radius should be found")

	# Small radius centered elsewhere should not find entity
	var small_radius := spatial_hash.query_radius(Vector2(200, 200), 10.0)
	assert_false(entity in small_radius, "Entity outside radius should not be found")


## Test 10: Radius respects exact distance
func test_radius_respects_exact_distance() -> void:
	var center := Vector2(0, 0)
	var entity := _create_mock_entity(Vector2(30, 0))  # 30 units away
	spatial_hash.insert(entity)

	# Radius 25 should NOT find it
	var too_small := spatial_hash.query_radius(center, 25.0)
	assert_false(entity in too_small, "Entity beyond radius should not be found")

	# Radius 35 should find it
	var large_enough := spatial_hash.query_radius(center, 35.0)
	assert_true(entity in large_enough, "Entity within radius should be found")


# =============================================================================
# MULTIPLE ENTITIES TESTS
# =============================================================================


## Test 11: Multiple entities in same cell
func test_multiple_entities_same_cell() -> void:
	var entity1 := _create_mock_entity(Vector2(10, 10))
	var entity2 := _create_mock_entity(Vector2(20, 20))
	var entity3 := _create_mock_entity(Vector2(30, 30))

	spatial_hash.insert(entity1)
	spatial_hash.insert(entity2)
	spatial_hash.insert(entity3)

	var nearby := spatial_hash.query_nearby(Vector2(15, 15))

	assert_true(entity1 in nearby, "Entity 1 should be in results")
	assert_true(entity2 in nearby, "Entity 2 should be in results")
	assert_true(entity3 in nearby, "Entity 3 should be in results")


## Test 12: Clear removes all entities
func test_clear() -> void:
	for i in range(10):
		var entity := _create_mock_entity(Vector2(i * 10, i * 10))
		spatial_hash.insert(entity)

	spatial_hash.clear()

	var nearby := spatial_hash.query_nearby(Vector2(50, 50))
	assert_eq(nearby.size(), 0, "Clear should remove all entities")


# =============================================================================
# PERFORMANCE TESTS
# =============================================================================


## Test 13: Performance with 500 entities
func test_performance_500_entities() -> void:
	# Insert 500 entities
	var entities: Array = []
	for i in range(500):
		var pos := Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
		var entity := _create_mock_entity(pos)
		entities.append(entity)
		spatial_hash.insert(entity)

	# Time 1000 queries
	var start_time := Time.get_ticks_usec()
	for i in range(1000):
		var query_pos := Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
		spatial_hash.query_nearby(query_pos)
	var elapsed := Time.get_ticks_usec() - start_time

	# Should complete in under 100ms (100,000 microseconds)
	assert_lt(
		elapsed,
		100000,
		"1000 queries with 500 entities should complete in <100ms (took %d us)" % elapsed
	)

	gut.p("Performance: 1000 queries in %d microseconds (%.2f ms)" % [elapsed, elapsed / 1000.0])


## Test 14: Query excludes self
func test_query_excludes_self() -> void:
	var entity := _create_mock_entity(Vector2(100, 100))
	spatial_hash.insert(entity)

	var nearby := spatial_hash.query_nearby(Vector2(100, 100), entity)

	assert_false(entity in nearby, "Query should exclude self when provided")


# =============================================================================
# EDGE CASE TESTS
# =============================================================================


## Test 15: Handles zero cell size gracefully
func test_zero_cell_size_fallback() -> void:
	var zero_hash := SpatialHashClass.new(0.0)

	# Should use minimum cell size instead of crashing
	assert_gt(zero_hash.cell_size, 0.0, "Cell size should fallback to minimum when zero provided")


## Test 16: Query returns array (not null)
func test_query_never_returns_null() -> void:
	var result := spatial_hash.query_nearby(Vector2(9999, 9999))

	assert_not_null(result, "Query should never return null")
	assert_true(result is Array, "Query should return Array type")


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


## Create a mock entity with position
func _create_mock_entity(pos: Vector2) -> RefCounted:
	var entity := MockEntity.new()
	entity.global_position = pos
	return entity


## Mock entity class for testing
class MockEntity:
	extends RefCounted
	var global_position: Vector2 = Vector2.ZERO
