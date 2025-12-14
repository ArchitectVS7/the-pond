## SpatialHash - Grid-based spatial partitioning for collision optimization
##
## COMBAT-007: Collision detection spatial hash
##
## Reduces O(n^2) collision checks to O(n*k) where k = average entities per cell.
## Essential for supporting 500+ enemies at 60fps (PRD requirement).
##
## How It Works:
## - Divides world into grid of cells (default 64x64 pixels)
## - Entities are placed in cells based on their position
## - Queries only check nearby cells (3x3 grid = 9 cells max)
##
## Architecture Notes:
## - Uses RefCounted for memory safety
## - No allocations in query hot path (pre-allocated arrays)
## - Entity tracking via Dictionary for O(1) lookup/removal
## - Thread-safe for single-threaded Godot physics
class_name SpatialHash
extends RefCounted

# =============================================================================
# CONSTANTS
# =============================================================================

## Minimum allowed cell size (prevents division issues)
const MIN_CELL_SIZE := 16.0

## Number of adjacent cells to check (1 = 3x3 grid)
const ADJACENT_RANGE := 1

# =============================================================================
# EXPORTS/SETTINGS
# =============================================================================

## Size of each cell in pixels
## Larger cells = fewer cells to check, more entities per cell
## Smaller cells = more cells to check, fewer entities per cell
## Optimal: slightly larger than largest entity collision radius
var cell_size: float = 64.0

# =============================================================================
# INTERNAL STATE
# =============================================================================

## Grid storage: Dictionary[Vector2i, Array[entity]]
## Key is cell coordinates, value is array of entities in that cell
var _grid: Dictionary = {}

## Entity tracking: Dictionary[entity, Vector2i]
## Maps entity to its current cell for fast removal/updates
var _entity_cells: Dictionary = {}

## Pre-allocated array for query results (reduces allocations)
var _query_result: Array = []

## Pre-allocated array for cells to check
var _cells_to_check: Array[Vector2i] = []

# =============================================================================
# INITIALIZATION
# =============================================================================


func _init(p_cell_size: float = 64.0) -> void:
	cell_size = maxf(p_cell_size, MIN_CELL_SIZE)

	# Pre-allocate cells_to_check for 3x3 grid (9 cells)
	_cells_to_check.resize(9)


# =============================================================================
# PUBLIC API
# =============================================================================


## Insert entity into spatial hash
## Entity must have global_position: Vector2
func insert(entity: Variant) -> void:
	if entity == null:
		return

	var cell_key := get_cell_key(entity.global_position)
	_add_to_cell(cell_key, entity)
	_entity_cells[entity] = cell_key


## Remove entity from spatial hash
func remove(entity: Variant) -> void:
	if entity == null or not _entity_cells.has(entity):
		return

	var old_cell := _entity_cells[entity] as Vector2i
	_remove_from_cell(old_cell, entity)
	_entity_cells.erase(entity)


## Update entity position (call after entity moves)
func update(entity: Variant) -> void:
	if entity == null:
		return

	var new_cell := get_cell_key(entity.global_position)

	# Only update if cell changed
	if _entity_cells.has(entity):
		var old_cell := _entity_cells[entity] as Vector2i
		if old_cell == new_cell:
			return  # Same cell, no update needed

		_remove_from_cell(old_cell, entity)

	_add_to_cell(new_cell, entity)
	_entity_cells[entity] = new_cell


## Query entities near a position (checks 3x3 cell grid)
## Optional: exclude_entity to exclude self from results
func query_nearby(position: Vector2, exclude_entity: Variant = null) -> Array:
	_query_result.clear()

	var center_cell := get_cell_key(position)

	# Check 3x3 grid of cells centered on position
	for dx in range(-ADJACENT_RANGE, ADJACENT_RANGE + 1):
		for dy in range(-ADJACENT_RANGE, ADJACENT_RANGE + 1):
			var cell_key := Vector2i(center_cell.x + dx, center_cell.y + dy)
			_add_cell_entities_to_result(cell_key, exclude_entity)

	return _query_result.duplicate()  # Return copy to prevent modification


## Query entities within exact radius
## More precise than query_nearby, but slightly slower
func query_radius(center: Vector2, radius: float, exclude_entity: Variant = null) -> Array:
	_query_result.clear()

	var radius_squared := radius * radius

	# Calculate cell range to check based on radius
	var cells_to_span := ceili(radius / cell_size) + 1
	var center_cell := get_cell_key(center)

	for dx in range(-cells_to_span, cells_to_span + 1):
		for dy in range(-cells_to_span, cells_to_span + 1):
			var cell_key := Vector2i(center_cell.x + dx, center_cell.y + dy)

			if not _grid.has(cell_key):
				continue

			var cell_entities: Array = _grid[cell_key]
			for entity in cell_entities:
				if entity == exclude_entity:
					continue

				var distance_squared := center.distance_squared_to(entity.global_position)
				if distance_squared <= radius_squared:
					_query_result.append(entity)

	return _query_result.duplicate()


## Clear all entities from spatial hash
func clear() -> void:
	_grid.clear()
	_entity_cells.clear()
	_query_result.clear()


## Get cell key for a world position
func get_cell_key(position: Vector2) -> Vector2i:
	return Vector2i(floori(position.x / cell_size), floori(position.y / cell_size))


## Get number of entities tracked
func get_entity_count() -> int:
	return _entity_cells.size()


## Get number of non-empty cells
func get_cell_count() -> int:
	return _grid.size()


# =============================================================================
# INTERNAL HELPERS
# =============================================================================


## Add entity to a specific cell
func _add_to_cell(cell_key: Vector2i, entity: Variant) -> void:
	if not _grid.has(cell_key):
		_grid[cell_key] = []

	var cell_array: Array = _grid[cell_key]
	if entity not in cell_array:
		cell_array.append(entity)


## Remove entity from a specific cell
func _remove_from_cell(cell_key: Vector2i, entity: Variant) -> void:
	if not _grid.has(cell_key):
		return

	var cell_array: Array = _grid[cell_key]
	cell_array.erase(entity)

	# Clean up empty cells to save memory
	if cell_array.is_empty():
		_grid.erase(cell_key)


## Add all entities from a cell to query result (excluding optional entity)
func _add_cell_entities_to_result(cell_key: Vector2i, exclude_entity: Variant) -> void:
	if not _grid.has(cell_key):
		return

	var cell_entities: Array = _grid[cell_key]
	for entity in cell_entities:
		if entity != exclude_entity:
			_query_result.append(entity)


# =============================================================================
# DEBUG HELPERS
# =============================================================================


## Get statistics for debugging
func get_stats() -> Dictionary:
	var total_entities := 0
	var max_per_cell := 0
	var min_per_cell := 999999

	for cell_key in _grid:
		var count: int = (_grid[cell_key] as Array).size()
		total_entities += count
		max_per_cell = maxi(max_per_cell, count)
		if count > 0:
			min_per_cell = mini(min_per_cell, count)

	return {
		"cell_size": cell_size,
		"total_entities": total_entities,
		"cell_count": _grid.size(),
		"max_per_cell": max_per_cell,
		"min_per_cell": min_per_cell if _grid.size() > 0 else 0,
		"avg_per_cell": float(total_entities) / maxf(_grid.size(), 1.0)
	}
