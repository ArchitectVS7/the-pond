## bullet_pool_manager.gd
## Wrapper for BulletUpHell pooling system with pre-warming and monitoring
## Provides convenient interface for pool management and health checks
extends Node

# ============================================================================
# Tunable Parameters (Export to Scene)
# ============================================================================

@export_group("Pool Configuration")
@export var enable_prewarm: bool = true  ## Pre-warm pools on _ready()
@export var shared_area_name: String = "0"  ## Default SharedArea node

@export_subgroup("Pool Sizes")
@export var basic_bullet_pool_size: int = 200  ## Basic bullet pool
@export var fast_bullet_pool_size: int = 150  ## Fast bullet pool
@export var spiral_bullet_pool_size: int = 150  ## Spiral bullet pool
@export var boss_bullet_pool_size: int = 500  ## Boss pattern pool

@export_group("Monitoring")
@export var enable_monitoring: bool = true  ## Enable pool health monitoring
@export var monitor_interval: float = 1.0  ## Health check interval (seconds)
@export var warn_on_auto_growth: bool = true  ## Warn if pool auto-grows

@export_group("Debug")
@export var debug_logging: bool = false  ## Enable verbose logging


# ============================================================================
# Pool Registry
# ============================================================================

## Pool configurations: {bullet_type: size}
var pool_registry: Dictionary = {}

## Monitoring data: {bullet_type: {acquisitions, releases, auto_grows}}
var pool_stats: Dictionary = {}

## Monitoring timer
var monitor_timer: Timer


# ============================================================================
# Signals
# ============================================================================

signal pool_prewarmed(bullet_type: String, size: int)
signal pool_auto_grew(bullet_type: String, old_size: int, new_size: int)
signal pool_depleted(bullet_type: String)
signal pool_health_warning(bullet_type: String, message: String)


# ============================================================================
# Initialization
# ============================================================================

func _ready() -> void:
	"""Initialize pool manager and pre-warm pools."""
	_setup_monitoring()

	if enable_prewarm:
		_register_default_pools()
		_prewarm_all_pools()


func _setup_monitoring() -> void:
	"""Setup health monitoring timer."""
	if not enable_monitoring:
		return

	monitor_timer = Timer.new()
	monitor_timer.wait_time = monitor_interval
	monitor_timer.autostart = true
	monitor_timer.timeout.connect(_on_monitor_timeout)
	add_child(monitor_timer)


func _register_default_pools() -> void:
	"""Register default pool configurations from exports."""
	register_pool("basic_bullet", basic_bullet_pool_size)
	register_pool("fast_bullet", fast_bullet_pool_size)
	register_pool("spiral_bullet", spiral_bullet_pool_size)
	register_pool("boss_bullet", boss_bullet_pool_size)


func _prewarm_all_pools() -> void:
	"""Pre-warm all registered pools."""
	for bullet_type in pool_registry.keys():
		var size = pool_registry[bullet_type]
		prewarm_pool(bullet_type, size)


# ============================================================================
# Public API
# ============================================================================

func register_pool(bullet_type: String, size: int) -> void:
	"""
	Register a bullet type for pooling.

	Args:
		bullet_type: Bullet type ID matching BulletUpHell pattern
		size: Initial pool size
	"""
	pool_registry[bullet_type] = size
	pool_stats[bullet_type] = {
		"acquisitions": 0,
		"releases": 0,
		"auto_grows": 0,
		"last_size": 0
	}

	if debug_logging:
		print("[PoolManager] Registered pool: %s (size: %d)" % [bullet_type, size])


func prewarm_pool(bullet_type: String, size: int = 0) -> void:
	"""
	Pre-warm a specific pool.

	Args:
		bullet_type: Bullet type ID
		size: Pool size (uses registered size if 0)
	"""
	if size == 0:
		size = pool_registry.get(bullet_type, 200)

	# Create pool via BulletUpHell
	Spawning.create_pool(bullet_type, shared_area_name, size)

	# Update stats
	pool_stats[bullet_type]["last_size"] = size

	pool_prewarmed.emit(bullet_type, size)

	if debug_logging:
		print("[PoolManager] Pre-warmed pool: %s with %d bullets" % [bullet_type, size])


func get_pool_size(bullet_type: String) -> int:
	"""
	Get current inactive pool size.

	Args:
		bullet_type: Bullet type ID

	Returns:
		Number of bullets available in pool
	"""
	if not Spawning.inactive_pool.has(bullet_type):
		return 0

	return Spawning.inactive_pool[bullet_type].size()


func get_pool_capacity(bullet_type: String) -> int:
	"""
	Get total pool capacity (active + inactive).

	Args:
		bullet_type: Bullet type ID

	Returns:
		Total pool capacity
	"""
	return Spawning.inactive_pool.get("__SIZE__" + bullet_type, 0)


func get_active_count(bullet_type: String) -> int:
	"""
	Get number of active bullets of type.

	Args:
		bullet_type: Bullet type ID

	Returns:
		Number of active bullets
	"""
	var capacity = get_pool_capacity(bullet_type)
	var inactive = get_pool_size(bullet_type)
	return capacity - inactive


func get_pool_health(bullet_type: String) -> Dictionary:
	"""
	Get comprehensive pool health metrics.

	Args:
		bullet_type: Bullet type ID

	Returns:
		Dictionary with health metrics
	"""
	var capacity = get_pool_capacity(bullet_type)
	var inactive = get_pool_size(bullet_type)
	var active = capacity - inactive
	var utilization = float(active) / capacity if capacity > 0 else 0.0

	return {
		"bullet_type": bullet_type,
		"capacity": capacity,
		"active": active,
		"inactive": inactive,
		"utilization": utilization,
		"stats": pool_stats.get(bullet_type, {})
	}


func get_all_pool_health() -> Array[Dictionary]:
	"""
	Get health metrics for all pools.

	Returns:
		Array of health dictionaries
	"""
	var health = []
	for bullet_type in pool_registry.keys():
		health.append(get_pool_health(bullet_type))
	return health


func print_pool_status() -> void:
	"""Print formatted pool status to console."""
	print("\n=== BULLET POOL STATUS ===")
	for health in get_all_pool_health():
		print("%s: %d/%d active (%.1f%% util) | Stats: %d acq, %d rel, %d grows" % [
			health.bullet_type,
			health.active,
			health.capacity,
			health.utilization * 100,
			health.stats.get("acquisitions", 0),
			health.stats.get("releases", 0),
			health.stats.get("auto_grows", 0)
		])
	print("=========================\n")


func clear_all_pools() -> void:
	"""Clear all bullets from all pools."""
	Spawning.clear_all_bullets()

	if debug_logging:
		print("[PoolManager] Cleared all pools")


func reset_stats() -> void:
	"""Reset pool statistics."""
	for bullet_type in pool_stats.keys():
		pool_stats[bullet_type] = {
			"acquisitions": 0,
			"releases": 0,
			"auto_grows": 0,
			"last_size": pool_stats[bullet_type].get("last_size", 0)
		}

	if debug_logging:
		print("[PoolManager] Reset all statistics")


# ============================================================================
# Monitoring
# ============================================================================

func _on_monitor_timeout() -> void:
	"""Periodic health check."""
	for bullet_type in pool_registry.keys():
		_check_pool_health(bullet_type)


func _check_pool_health(bullet_type: String) -> void:
	"""
	Check health of a specific pool.

	Args:
		bullet_type: Bullet type ID
	"""
	var health = get_pool_health(bullet_type)

	# Detect auto-growth
	var current_capacity = health.capacity
	var last_size = pool_stats[bullet_type].get("last_size", 0)

	if current_capacity > last_size and warn_on_auto_growth:
		pool_stats[bullet_type]["auto_grows"] += 1
		pool_stats[bullet_type]["last_size"] = current_capacity

		pool_auto_grew.emit(bullet_type, last_size, current_capacity)

		push_warning(
			"[PoolManager] Pool auto-grew: %s (%d -> %d bullets)" % [
				bullet_type,
				last_size,
				current_capacity
			]
		)

	# Check depletion
	if health.inactive == 0 and health.active > 0:
		pool_depleted.emit(bullet_type)

		pool_health_warning.emit(
			bullet_type,
			"Pool depleted - consider increasing size"
		)

		if debug_logging:
			print("[PoolManager] WARNING: Pool depleted: %s" % bullet_type)

	# Check high utilization (>80%)
	if health.utilization > 0.8:
		pool_health_warning.emit(
			bullet_type,
			"High utilization: %.1f%%" % (health.utilization * 100)
		)

		if debug_logging:
			print(
				"[PoolManager] WARNING: High utilization for %s: %.1f%%" % [
					bullet_type,
					health.utilization * 100
				]
			)


# ============================================================================
# Convenience Methods
# ============================================================================

func grow_pool(bullet_type: String, additional: int) -> void:
	"""
	Manually grow a pool.

	Args:
		bullet_type: Bullet type ID
		additional: Number of bullets to add
	"""
	Spawning.create_pool(bullet_type, shared_area_name, additional)

	var new_capacity = get_pool_capacity(bullet_type)
	pool_stats[bullet_type]["last_size"] = new_capacity

	if debug_logging:
		print("[PoolManager] Grew pool: %s by %d bullets (new capacity: %d)" % [
			bullet_type,
			additional,
			new_capacity
		])


func shrink_pool(bullet_type: String, target_size: int) -> void:
	"""
	Attempt to shrink pool (only affects inactive bullets).

	Args:
		bullet_type: Bullet type ID
		target_size: Target pool size
	"""
	if not Spawning.inactive_pool.has(bullet_type):
		return

	var current_inactive = get_pool_size(bullet_type)
	if current_inactive <= target_size:
		return

	# Remove excess inactive bullets
	var to_remove = current_inactive - target_size
	for i in range(to_remove):
		if Spawning.inactive_pool[bullet_type].size() > 0:
			Spawning.inactive_pool[bullet_type].pop_back()

	# Update size tracking
	var new_capacity = get_pool_capacity(bullet_type) - to_remove
	Spawning.inactive_pool["__SIZE__" + bullet_type] = new_capacity
	pool_stats[bullet_type]["last_size"] = new_capacity

	if debug_logging:
		print("[PoolManager] Shrunk pool: %s by %d bullets (new capacity: %d)" % [
			bullet_type,
			to_remove,
			new_capacity
		])


# ============================================================================
# Debug Utilities
# ============================================================================

func get_debug_info() -> String:
	"""
	Get formatted debug information.

	Returns:
		Multi-line debug string
	"""
	var info = "=== BULLET POOL DEBUG INFO ===\n"
	info += "Pre-warm enabled: %s\n" % enable_prewarm
	info += "Monitoring enabled: %s\n" % enable_monitoring
	info += "Shared area: %s\n\n" % shared_area_name

	info += "Registered pools: %d\n" % pool_registry.size()
	for bullet_type in pool_registry.keys():
		var health = get_pool_health(bullet_type)
		info += "  - %s: %d capacity, %d active, %.1f%% util\n" % [
			bullet_type,
			health.capacity,
			health.active,
			health.utilization * 100
		]

	info += "\nTotal active bullets: %d\n" % Spawning.poolBullets.size()
	info += "=============================="

	return info
