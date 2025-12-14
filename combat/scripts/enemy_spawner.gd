## EnemySpawner - Handles enemy spawning with escalating difficulty
##
## COMBAT-005: Enemy spawn escalation system
## COMBAT-007: Spatial hash collision optimization
## COMBAT-014: Object pooling for 500+ enemies
## PRD FR-001: "Enemy spawn system: escalating difficulty every 60 seconds"
##
## Architecture Notes:
## - Attached to a Node2D in the arena
## - Spawns enemies at random positions around the arena edge
## - Difficulty escalates every escalation_interval seconds
## - Manages SpatialHash for O(n*k) collision detection (COMBAT-007)
## - Uses ObjectPool for zero-allocation enemy reuse (COMBAT-014)
class_name EnemySpawner
extends Node2D

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when difficulty escalates
signal difficulty_escalated(new_wave: int, spawn_rate: float)

## Emitted when an enemy is spawned
signal enemy_spawned(enemy: EnemyBase)

# =============================================================================
# ENEMY SCENES
# =============================================================================

## Basic enemy scene (slow, 1 HP)
@export var basic_enemy_scene: PackedScene

## Fast enemy scene (faster, 1 HP) - unlocks at wave 2
@export var fast_enemy_scene: PackedScene

# =============================================================================
# SPAWN SETTINGS
# =============================================================================

## Time between spawns at wave 1 (seconds)
@export var base_spawn_interval: float = 2.0

## Minimum spawn interval (prevents too fast spawning)
@export var min_spawn_interval: float = 0.3

## Spawn interval reduction per wave (seconds)
@export var spawn_interval_reduction: float = 0.15

## Time between difficulty escalations (seconds) - PRD: 60 seconds
@export var escalation_interval: float = 60.0

## Spawn distance from arena center (pixels)
@export var spawn_radius: float = 600.0

## Maximum enemies alive at once (performance limit)
@export var max_enemies: int = 100

# =============================================================================
# SPATIAL HASH SETTINGS (COMBAT-007)
# =============================================================================

## Cell size for spatial partitioning (pixels)
## Optimal: slightly larger than enemy separation_radius
## Larger = fewer cells, more entities per cell
## Smaller = more cells, fewer entities per cell
@export var spatial_hash_cell_size: float = 64.0

# =============================================================================
# POOLING SETTINGS (COMBAT-014)
# =============================================================================

## Whether to use object pooling for enemies
@export var pooling_enabled: bool = true

## Number of enemies to pre-warm in pool per type
@export var pool_prewarm_count: int = 50

## Maximum pool size per enemy type
@export var pool_max_size: int = 500

# =============================================================================
# STATE
# =============================================================================

## Current difficulty wave (starts at 1)
var current_wave: int = 1

## Current spawn interval (decreases each wave)
var current_spawn_interval: float = 2.0

## Timer for spawning
var spawn_timer: float = 0.0

## Timer for escalation
var escalation_timer: float = 0.0

## Whether spawning is active
var is_spawning: bool = false

## Reference to player target
var player_target: Node2D = null

## Count of currently alive enemies
var enemy_count: int = 0

## Spatial hash for optimized collision queries (COMBAT-007)
var spatial_hash: SpatialHash = null

## Object pool for enemy reuse (COMBAT-014)
var enemy_pool: ObjectPool = null

## List of all active enemies (for spatial hash updates)
var _active_enemies: Array[EnemyBase] = []

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	current_spawn_interval = base_spawn_interval

	# Initialize spatial hash for collision optimization (COMBAT-007)
	spatial_hash = SpatialHash.new(spatial_hash_cell_size)

	# Initialize object pool for enemy reuse (COMBAT-014)
	if pooling_enabled:
		_init_enemy_pool()

	# Find player automatically if not set
	if not player_target:
		player_target = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	# Always update spatial hash positions (enemies move even when not spawning)
	_update_spatial_hash()

	if not is_spawning:
		return

	# Update escalation timer
	escalation_timer += delta
	if escalation_timer >= escalation_interval:
		_escalate_difficulty()
		escalation_timer = 0.0

	# Update spawn timer
	spawn_timer += delta
	if spawn_timer >= current_spawn_interval:
		_try_spawn_enemy()
		spawn_timer = 0.0


# =============================================================================
# SPAWNING CONTROL
# =============================================================================


## Start spawning enemies
func start_spawning() -> void:
	is_spawning = true
	spawn_timer = 0.0
	escalation_timer = 0.0


## Stop spawning enemies
func stop_spawning() -> void:
	is_spawning = false


## Reset spawner to initial state
func reset() -> void:
	current_wave = 1
	current_spawn_interval = base_spawn_interval
	spawn_timer = 0.0
	escalation_timer = 0.0
	enemy_count = 0
	_active_enemies.clear()
	if spatial_hash:
		spatial_hash.clear()


# =============================================================================
# ENEMY SPAWNING
# =============================================================================


## Try to spawn an enemy (respects max limit)
func _try_spawn_enemy() -> void:
	if enemy_count >= max_enemies:
		return

	if not player_target:
		player_target = get_tree().get_first_node_in_group("player")
		if not player_target:
			return

	var enemy := _create_enemy()
	if enemy:
		var spawn_pos := _get_spawn_position()
		enemy.global_position = spawn_pos
		enemy.target = player_target
		enemy.spatial_hash = spatial_hash  # COMBAT-007: Share spatial hash reference

		# Connect died signal if not already connected (pooled enemies retain connections)
		if not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died)

		# Only add as child if not already in scene tree (non-pooled enemies)
		if not enemy.is_inside_tree():
			get_parent().add_child(enemy)

		# Register with spatial hash (COMBAT-007)
		_active_enemies.append(enemy)
		if spatial_hash:
			spatial_hash.insert(enemy)

		enemy_count += 1
		enemy_spawned.emit(enemy)


## Create an enemy instance based on current wave
func _create_enemy() -> EnemyBase:
	var scene_to_spawn: PackedScene

	# Wave 1: Only basic enemies
	# Wave 2+: Mix of basic and fast enemies
	if current_wave >= 2 and fast_enemy_scene and randf() < 0.3:
		scene_to_spawn = fast_enemy_scene
	elif basic_enemy_scene:
		scene_to_spawn = basic_enemy_scene
	else:
		push_error("EnemySpawner: No enemy scenes assigned!")
		return null

	# COMBAT-014: Use pooling if enabled
	if pooling_enabled and enemy_pool:
		var enemy := enemy_pool.acquire(scene_to_spawn) as EnemyBase
		if enemy:
			enemy.use_pooling = true  # Mark for pool release on death
			return enemy

	# Fallback: Direct instantiation
	return scene_to_spawn.instantiate() as EnemyBase


## Get a random spawn position around the arena edge
func _get_spawn_position() -> Vector2:
	var angle := randf() * TAU
	var offset := Vector2(cos(angle), sin(angle)) * spawn_radius

	# Spawn relative to arena center (spawner position)
	return global_position + offset


# =============================================================================
# DIFFICULTY ESCALATION
# =============================================================================


## Increase difficulty for next wave
func _escalate_difficulty() -> void:
	current_wave += 1

	# Reduce spawn interval (more enemies per second)
	current_spawn_interval = maxf(
		base_spawn_interval - (spawn_interval_reduction * (current_wave - 1)), min_spawn_interval
	)

	difficulty_escalated.emit(current_wave, current_spawn_interval)


# =============================================================================
# EVENT HANDLERS
# =============================================================================


## Handle enemy death
func _on_enemy_died(enemy: EnemyBase, _position: Vector2) -> void:
	enemy_count -= 1

	# Remove from spatial hash (COMBAT-007)
	_active_enemies.erase(enemy)
	if spatial_hash:
		spatial_hash.remove(enemy)

	# COMBAT-014: Release to pool if pooling enabled
	if pooling_enabled and enemy_pool and enemy.use_pooling:
		enemy_pool.release(enemy)


# =============================================================================
# SPATIAL HASH (COMBAT-007)
# =============================================================================


## Update all enemy positions in spatial hash
## Called every physics frame to keep spatial data current
func _update_spatial_hash() -> void:
	if not spatial_hash:
		return

	for enemy in _active_enemies:
		if is_instance_valid(enemy) and enemy.is_active:
			spatial_hash.update(enemy)


## Get spatial hash statistics for debugging
func get_spatial_hash_stats() -> Dictionary:
	if spatial_hash:
		return spatial_hash.get_stats()
	return {}


# =============================================================================
# OBJECT POOLING (COMBAT-014)
# =============================================================================


## Initialize the enemy object pool
func _init_enemy_pool() -> void:
	enemy_pool = ObjectPool.new()
	enemy_pool.max_pool_size = pool_max_size
	enemy_pool.auto_grow = true
	add_child(enemy_pool)

	# Set up lifecycle callbacks
	enemy_pool.on_acquire = _on_pool_acquire
	enemy_pool.on_release = _on_pool_release

	# Pre-warm pools with enemies
	if basic_enemy_scene:
		enemy_pool.prewarm(basic_enemy_scene, pool_prewarm_count)
	if fast_enemy_scene:
		enemy_pool.prewarm(fast_enemy_scene, pool_prewarm_count / 2)


## Callback when enemy is acquired from pool
func _on_pool_acquire(enemy: Node) -> void:
	if enemy is EnemyBase:
		enemy.reset()  # Reset enemy state for reuse


## Callback when enemy is released to pool
func _on_pool_release(enemy: Node) -> void:
	if enemy is EnemyBase:
		enemy.deactivate()  # Prepare for pooling


## Get pool statistics for debugging
func get_pool_stats() -> Dictionary:
	if enemy_pool:
		return enemy_pool.get_statistics()
	return {}
