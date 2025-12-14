## bullet_collision_config.gd
## BULLET-007: Collision optimization configuration for BulletUpHell
## Optimizes bullet collisions using proper layer/mask setup and deferred operations
extends Node

# =============================================================================
# COLLISION LAYER CONSTANTS (from project.godot)
# =============================================================================

const LAYER_PLAYER: int = 1         # Layer 1: Player body
const LAYER_ENVIRONMENT: int = 2    # Layer 2: Walls, obstacles
const LAYER_ENEMIES: int = 3        # Layer 3: Enemy bodies
const LAYER_PLAYER_ATTACK: int = 4  # Layer 4: Tongue hit area
const LAYER_BULLETS: int = 5        # Layer 5: Enemy bullets

# Bit masks for efficient collision checks
const MASK_PLAYER: int = 1 << 0         # 0b00001 - Layer 1
const MASK_ENVIRONMENT: int = 1 << 1    # 0b00010 - Layer 2
const MASK_ENEMIES: int = 1 << 2        # 0b00100 - Layer 3
const MASK_PLAYER_ATTACK: int = 1 << 3  # 0b01000 - Layer 4
const MASK_BULLETS: int = 1 << 4        # 0b10000 - Layer 5

# =============================================================================
# TUNABLE PARAMETERS
# =============================================================================

## Default bullet collision hitbox size (radius in pixels)
const DEFAULT_BULLET_HITBOX_SIZE: float = 4.0

## Whether to use deferred collision shape operations (performance optimization)
const USE_DEFERRED_COLLISION: bool = true

# =============================================================================
# COLLISION CONFIGURATION
# =============================================================================

## Configure bullet collision layers for BulletUpHell spawner
## Bullets on Layer 5, mask only Layer 1 (Player)
static func configure_bullet_spawner(spawner: Node) -> void:
	"""
	Configure BulletUpHell spawner with optimized collision layers.

	Args:
		spawner: BuHSpawner node to configure
	"""
	if not spawner:
		push_error("BulletCollisionConfig: Cannot configure null spawner")
		return

	# BulletUpHell uses shared_area for collision template
	if not spawner.has_node("shared_area"):
		push_warning("BulletCollisionConfig: Spawner missing shared_area node")
		return

	var shared_area = spawner.get_node("shared_area")

	# Bullets are on Layer 5
	shared_area.collision_layer = MASK_BULLETS

	# Bullets only collide with Player (Layer 1)
	# This prevents enemy bullets from hitting enemies
	shared_area.collision_mask = MASK_PLAYER

	print("BulletCollisionConfig: Configured spawner '%s'" % spawner.name)
	print("  - Bullet Layer: 5 (Bullets)")
	print("  - Bullet Mask: 1 (Player only)")


## Configure individual bullet Area2D node
static func configure_bullet_area(bullet_area: Area2D) -> void:
	"""
	Configure individual bullet collision.

	Args:
		bullet_area: Bullet Area2D node
	"""
	if not bullet_area:
		return

	bullet_area.collision_layer = MASK_BULLETS
	bullet_area.collision_mask = MASK_PLAYER


## Enable collision shape with deferred operation (thread-safe)
static func enable_collision_shape(shape: CollisionShape2D) -> void:
	"""
	Enable collision shape using set_deferred for thread safety.

	Args:
		shape: CollisionShape2D to enable
	"""
	if not shape:
		return

	if USE_DEFERRED_COLLISION:
		shape.set_deferred("disabled", false)
	else:
		shape.disabled = false


## Disable collision shape with deferred operation (thread-safe)
static func disable_collision_shape(shape: CollisionShape2D) -> void:
	"""
	Disable collision shape using set_deferred for thread safety.

	Args:
		shape: CollisionShape2D to disable
	"""
	if not shape:
		return

	if USE_DEFERRED_COLLISION:
		shape.set_deferred("disabled", true)
	else:
		shape.disabled = true


## Create optimized bullet hitbox CircleShape2D
static func create_bullet_hitbox(radius: float = DEFAULT_BULLET_HITBOX_SIZE) -> CircleShape2D:
	"""
	Create optimized circular hitbox for bullet.

	Args:
		radius: Circle radius in pixels

	Returns:
		Configured CircleShape2D
	"""
	var shape = CircleShape2D.new()
	shape.radius = radius
	return shape


# =============================================================================
# VALIDATION
# =============================================================================

## Validate spawner collision configuration
static func validate_spawner_config(spawner: Node) -> Dictionary:
	"""
	Validate that spawner has correct collision configuration.

	Args:
		spawner: BuHSpawner to validate

	Returns:
		Dictionary with validation results
	"""
	var result = {
		"valid": false,
		"errors": [],
		"warnings": []
	}

	if not spawner:
		result.errors.append("Spawner is null")
		return result

	if not spawner.has_node("shared_area"):
		result.errors.append("Missing shared_area node")
		return result

	var shared_area = spawner.get_node("shared_area")

	# Check collision layer
	if shared_area.collision_layer != MASK_BULLETS:
		result.warnings.append(
			"Collision layer is %d, expected %d (Layer 5)" %
			[shared_area.collision_layer, MASK_BULLETS]
		)

	# Check collision mask
	if shared_area.collision_mask != MASK_PLAYER:
		result.warnings.append(
			"Collision mask is %d, expected %d (Player only)" %
			[shared_area.collision_mask, MASK_PLAYER]
		)

	result.valid = result.errors.size() == 0
	return result


# =============================================================================
# PERFORMANCE HELPERS
# =============================================================================

## Get collision layer name for debugging
static func get_layer_name(layer_bit: int) -> String:
	"""
	Get human-readable layer name from layer bit.

	Args:
		layer_bit: Layer number (1-5)

	Returns:
		Layer name string
	"""
	match layer_bit:
		1: return "Player"
		2: return "Environment"
		3: return "Enemies"
		4: return "PlayerAttack"
		5: return "Bullets"
		_: return "Unknown"


## Check if collision layers are optimized
static func is_collision_optimized(area: Area2D) -> bool:
	"""
	Check if area has optimized collision configuration.

	Args:
		area: Area2D to check

	Returns:
		True if collision layers are properly configured
	"""
	if not area:
		return false

	# Check if using minimal collision mask (fewer checks = better performance)
	var mask_bit_count = 0
	var mask = area.collision_mask

	for i in range(32):
		if mask & (1 << i):
			mask_bit_count += 1

	# Optimal: only 1 collision mask bit set (bullets only hit player)
	return mask_bit_count <= 1
