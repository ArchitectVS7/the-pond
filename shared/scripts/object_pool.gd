## ObjectPool - Generic object pooling for performance
##
## COMBAT-014: Object pooling for 500+ enemies
## PRD Requirement: Support 500+ enemies without frame drops
##
## Features:
## - Pre-warm pool with objects at startup
## - Acquire/release pattern for reuse
## - Lifecycle callbacks for reset/deactivate
## - Statistics tracking
## - Multiple scene type support
##
## Architecture Notes:
## - Generic pool - works with any PackedScene
## - Objects stay in scene tree when pooled (just hidden)
## - Zero allocations in acquire/release hot path
## - Thread-safe for single-threaded Godot use
class_name ObjectPool
extends Node

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when pool creates a new object
signal object_created(object: Node)

## Emitted when object is acquired from pool
signal object_acquired(object: Node)

## Emitted when object is released back to pool
signal object_released(object: Node)

## Emitted when pool is exhausted (creating new object)
signal pool_exhausted(scene: PackedScene)

# =============================================================================
# EXPORTS
# =============================================================================

## Maximum pool size per scene type (0 = unlimited)
@export var max_pool_size: int = 500

## Whether to auto-grow pool when exhausted
@export var auto_grow: bool = true

## Container node for pooled objects (defaults to self)
@export var pool_container: Node = null

# =============================================================================
# CALLBACKS
# =============================================================================

## Called when object is acquired (for reset)
## Signature: func(object: Node) -> void
var on_acquire: Callable = Callable()

## Called when object is released (for deactivate)
## Signature: func(object: Node) -> void
var on_release: Callable = Callable()

# =============================================================================
# STATE
# =============================================================================

## Available objects by scene path (scene_path -> Array[Node])
var _available: Dictionary = {}

## Active objects by scene path (scene_path -> Array[Node])
var _active: Dictionary = {}

## Scene reference cache (scene_path -> PackedScene)
var _scene_cache: Dictionary = {}

## Statistics
var _stats := {
	"total_created": 0,
	"reuse_count": 0,
}

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	if pool_container == null:
		pool_container = self


# =============================================================================
# PUBLIC API - POOLING
# =============================================================================


## Pre-warm pool with instances of a scene
func prewarm(scene: PackedScene, count: int) -> void:
	if scene == null:
		return

	var scene_path := _get_scene_key(scene)
	_ensure_scene_cached(scene_path, scene)

	# Create up to max_pool_size objects
	var to_create := mini(count, max_pool_size) if max_pool_size > 0 else count

	for i in range(to_create):
		var current_available := _get_available_count_for_scene(scene_path)
		if max_pool_size > 0 and current_available >= max_pool_size:
			break

		var obj := _create_object(scene)
		_deactivate_object(obj)
		_add_to_available(scene_path, obj)


## Acquire an object from pool (or create new if empty)
func acquire(scene: PackedScene) -> Node:
	if scene == null:
		return null

	var scene_path := _get_scene_key(scene)
	_ensure_scene_cached(scene_path, scene)

	var obj: Node = null

	# Try to get from available pool
	if _has_available(scene_path):
		obj = _pop_available(scene_path)

		# Validate object is still valid
		if not is_instance_valid(obj):
			# Object was freed externally, try again
			return acquire(scene)

		_stats.reuse_count += 1
	else:
		# Pool exhausted, create new
		pool_exhausted.emit(scene)

		if auto_grow:
			obj = _create_object(scene)
		else:
			return null

	# Track as active
	_add_to_active(scene_path, obj)

	# Activate object
	_activate_object(obj)

	# Call acquire callback
	if on_acquire.is_valid():
		on_acquire.call(obj)

	object_acquired.emit(obj)
	return obj


## Release object back to pool
func release(object: Node) -> void:
	if object == null or not is_instance_valid(object):
		return

	# Find scene path for this object
	var scene_path := _find_scene_path_for_object(object)
	if scene_path.is_empty():
		# Object not from this pool, just deactivate
		_deactivate_object(object)
		return

	# Check if already in available pool (double release)
	if _is_in_available(scene_path, object):
		return

	# Remove from active
	_remove_from_active(scene_path, object)

	# Call release callback
	if on_release.is_valid():
		on_release.call(object)

	# Deactivate
	_deactivate_object(object)

	# Add back to available (if not at max)
	var current_available := _get_available_count_for_scene(scene_path)
	if max_pool_size == 0 or current_available < max_pool_size:
		_add_to_available(scene_path, object)
	else:
		# At max, just free
		object.queue_free()

	object_released.emit(object)


## Clear all pooled objects
func clear() -> void:
	# Free all available objects
	for scene_path in _available.keys():
		var objects: Array = _available[scene_path]
		for obj in objects:
			if is_instance_valid(obj):
				obj.queue_free()
		objects.clear()

	_available.clear()
	_active.clear()
	_scene_cache.clear()
	_stats.total_created = 0
	_stats.reuse_count = 0


# =============================================================================
# PUBLIC API - STATISTICS
# =============================================================================


## Get count of available objects (all scene types)
func get_available_count() -> int:
	var count := 0
	for scene_path in _available.keys():
		count += _available[scene_path].size()
	return count


## Get count of active objects (all scene types)
func get_active_count() -> int:
	var count := 0
	for scene_path in _active.keys():
		count += _active[scene_path].size()
	return count


## Get pool statistics
func get_statistics() -> Dictionary:
	return {
		"total_created": _stats.total_created,
		"available_count": get_available_count(),
		"active_count": get_active_count(),
		"reuse_count": _stats.reuse_count,
		"scene_types": _available.keys().size(),
	}


# =============================================================================
# INTERNAL - OBJECT MANAGEMENT
# =============================================================================


## Create a new object instance
func _create_object(scene: PackedScene) -> Node:
	var obj := scene.instantiate()
	pool_container.add_child(obj)
	_stats.total_created += 1
	object_created.emit(obj)
	return obj


## Activate an object (make visible, enable processing)
func _activate_object(obj: Node) -> void:
	if obj is Node2D:
		obj.visible = true
	elif obj is Control:
		obj.visible = true

	obj.set_process(true)
	obj.set_physics_process(true)


## Deactivate an object (hide, disable processing)
func _deactivate_object(obj: Node) -> void:
	if obj is Node2D:
		obj.visible = false
	elif obj is Control:
		obj.visible = false

	obj.set_process(false)
	obj.set_physics_process(false)


# =============================================================================
# INTERNAL - POOL TRACKING
# =============================================================================


## Get scene key for dictionary lookup
func _get_scene_key(scene: PackedScene) -> String:
	return scene.resource_path if scene.resource_path else str(scene.get_instance_id())


## Ensure scene is cached
func _ensure_scene_cached(scene_path: String, scene: PackedScene) -> void:
	if not _scene_cache.has(scene_path):
		_scene_cache[scene_path] = scene
	if not _available.has(scene_path):
		_available[scene_path] = []
	if not _active.has(scene_path):
		_active[scene_path] = []


## Check if available pool has objects
func _has_available(scene_path: String) -> bool:
	return _available.has(scene_path) and _available[scene_path].size() > 0


## Pop object from available pool
func _pop_available(scene_path: String) -> Node:
	var objects: Array = _available[scene_path]
	return objects.pop_back()


## Add object to available pool
func _add_to_available(scene_path: String, obj: Node) -> void:
	if not _available.has(scene_path):
		_available[scene_path] = []
	_available[scene_path].append(obj)


## Add object to active tracking
func _add_to_active(scene_path: String, obj: Node) -> void:
	if not _active.has(scene_path):
		_active[scene_path] = []
	_active[scene_path].append(obj)


## Remove object from active tracking
func _remove_from_active(scene_path: String, obj: Node) -> void:
	if _active.has(scene_path):
		_active[scene_path].erase(obj)


## Check if object is in available pool
func _is_in_available(scene_path: String, obj: Node) -> bool:
	return _available.has(scene_path) and obj in _available[scene_path]


## Get available count for specific scene
func _get_available_count_for_scene(scene_path: String) -> int:
	if _available.has(scene_path):
		return _available[scene_path].size()
	return 0


## Find scene path for an object
func _find_scene_path_for_object(obj: Node) -> String:
	for scene_path in _active.keys():
		if obj in _active[scene_path]:
			return scene_path
	return ""
