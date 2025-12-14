## EnemyBase - Base class for all enemy types
##
## COMBAT-005: Enemy spawn escalation system
## COMBAT-006: Enemy AI basic behaviors
## COMBAT-007: Spatial hash collision optimization
##
## Behavior Modes:
## - CHASE: Move directly toward player
## - WANDER: Random movement, changes direction periodically
## - ORBIT: Circle around player at fixed distance
##
## Architecture Notes:
## - Base class for all enemies (inheritance pattern)
## - Uses CharacterBody2D for physics
## - Emits signals on death for feedback systems (COMBAT-008, COMBAT-009)
## - Uses SpatialHash for O(n*k) separation checks (COMBAT-007)
## - Designed for object pooling (COMBAT-014)
class_name EnemyBase
extends CharacterBody2D

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when enemy dies - connected by particle system, audio, scoring
signal died(enemy: EnemyBase, position: Vector2)

## Emitted when enemy takes damage - connected by hit feedback
signal damaged(enemy: EnemyBase, amount: int, remaining_hp: int)

# =============================================================================
# ENUMS
# =============================================================================

## Available behavior modes (COMBAT-006)
enum BehaviorMode { CHASE, WANDER, ORBIT }

# =============================================================================
# EXPORTS (Tunable per enemy type)
# =============================================================================

## Enemy display name (for UI, debugging)
@export var enemy_name: String = "Basic Enemy"

## Maximum health points
@export var max_hp: int = 1

## Movement speed in pixels per second
@export var move_speed: float = 80.0

## Points awarded when killed
@export var score_value: int = 10

## Collision damage dealt to player on contact
@export var contact_damage: int = 1

# =============================================================================
# BEHAVIOR SETTINGS (COMBAT-006)
# =============================================================================

## Current behavior mode
@export var behavior_mode: BehaviorMode = BehaviorMode.CHASE

## Speed when wandering (slower than chase)
@export var wander_speed: float = 40.0

## How often to change wander direction (seconds)
@export var wander_interval: float = 1.5

## Distance to maintain when orbiting player
@export var orbit_distance: float = 100.0

## Speed when orbiting
@export var orbit_speed: float = 60.0

## Whether separation from other enemies is enabled
@export var separation_enabled: bool = true

## Radius to check for other enemies (separation)
@export var separation_radius: float = 30.0

## Strength of separation force
@export var separation_strength: float = 50.0

# =============================================================================
# STATE
# =============================================================================

## Current health points
var current_hp: int = 1

## Whether enemy is active (for object pooling)
var is_active: bool = true

## Reference to player (set by spawner)
var target: Node2D = null

## Reference to spatial hash for optimized separation (set by spawner, COMBAT-007)
var spatial_hash: SpatialHash = null

## Whether this enemy uses pooling (set by spawner, COMBAT-014)
var use_pooling: bool = false

## Timer for wander direction changes
var _wander_timer: float = 0.0

## Current wander direction (normalized)
var _wander_direction: Vector2 = Vector2.RIGHT

## Orbit angle (radians)
var _orbit_angle: float = 0.0

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	# Randomize initial wander direction and orbit angle
	_wander_direction = Vector2.from_angle(randf() * TAU)
	_orbit_angle = randf() * TAU


func _physics_process(delta: float) -> void:
	if not is_active:
		velocity = Vector2.ZERO
		return

	if not target:
		velocity = Vector2.ZERO
		return

	# Update behavior based on current mode (COMBAT-006)
	match behavior_mode:
		BehaviorMode.CHASE:
			_update_chase()
		BehaviorMode.WANDER:
			_update_wander(delta)
		BehaviorMode.ORBIT:
			_update_orbit(delta)

	# Apply separation from other enemies
	if separation_enabled:
		_apply_separation()

	move_and_slide()


# =============================================================================
# BEHAVIOR IMPLEMENTATIONS (COMBAT-006)
# =============================================================================


## CHASE: Move directly toward player
func _update_chase() -> void:
	if not target:
		return
	var direction := (target.global_position - global_position).normalized()
	velocity = direction * move_speed


## WANDER: Random movement, changes direction periodically
func _update_wander(delta: float) -> void:
	_wander_timer += delta

	# Change direction when timer expires
	if _wander_timer >= wander_interval:
		_wander_timer = 0.0
		_wander_direction = Vector2.from_angle(randf() * TAU)

	velocity = _wander_direction * wander_speed


## ORBIT: Circle around player at fixed distance
func _update_orbit(delta: float) -> void:
	if not target:
		return

	# Update orbit angle
	var orbit_circumference := TAU * orbit_distance
	var angular_speed := orbit_speed / orbit_distance  # radians per second
	_orbit_angle += angular_speed * delta

	# Calculate tangent direction (perpendicular to radius)
	var radius_direction := Vector2.from_angle(_orbit_angle)
	var tangent_direction := radius_direction.rotated(PI / 2)  # 90 degrees

	# Move toward orbit position while moving tangentially
	var ideal_position := target.global_position + radius_direction * orbit_distance
	var to_ideal := ideal_position - global_position

	# Blend: move tangentially, but also correct toward ideal orbit distance
	var correction_strength := 0.3
	velocity = tangent_direction * orbit_speed + to_ideal * correction_strength


## Apply separation force to avoid clumping with other enemies
## Uses SpatialHash for O(n*k) lookups instead of O(n^2) (COMBAT-007)
func _apply_separation() -> void:
	var separation_force := Vector2.ZERO

	# Get nearby enemies from spatial hash (COMBAT-007) or fallback to group
	var nearby_enemies: Array
	if spatial_hash:
		nearby_enemies = spatial_hash.query_radius(global_position, separation_radius, self)
	else:
		# Fallback to old O(n) method if no spatial hash
		nearby_enemies = get_tree().get_nodes_in_group("enemies")

	for other in nearby_enemies:
		if other == self:
			continue

		var to_other := other.global_position - global_position
		var distance := to_other.length()

		if distance > 0.0 and distance < separation_radius:
			# Push away from nearby enemy (stronger when closer)
			var push_strength := (separation_radius - distance) / separation_radius
			separation_force -= to_other.normalized() * push_strength * separation_strength

	velocity += separation_force


# =============================================================================
# DAMAGE AND DEATH
# =============================================================================


## Take damage from player attack
func take_damage(amount: int) -> void:
	if not is_active:
		return

	current_hp -= amount
	damaged.emit(self, amount, current_hp)

	if current_hp <= 0:
		die()


## Handle death
func die() -> void:
	if not is_active:
		return

	is_active = false

	# Trigger feedback effects
	_trigger_kill_shake()  # COMBAT-008
	_trigger_death_particles()  # COMBAT-009
	_trigger_kill_hit_stop()  # COMBAT-010
	_trigger_death_sound()  # COMBAT-011

	died.emit(self, global_position)

	# COMBAT-014: If pooling enabled, spawner will release to pool
	# Otherwise, queue_free for garbage collection
	if not use_pooling:
		queue_free()


## Trigger screen shake for kill feedback (COMBAT-008)
func _trigger_kill_shake() -> void:
	# Get ScreenShake autoload if available
	var screen_shake := get_node_or_null("/root/ScreenShake")
	if screen_shake and screen_shake.has_method("shake_kill"):
		screen_shake.shake_kill()


## Trigger death particles at current position (COMBAT-009)
func _trigger_death_particles() -> void:
	var particle_manager := get_node_or_null("/root/ParticleManager")
	if particle_manager and particle_manager.has_method("spawn_death_particles"):
		particle_manager.spawn_death_particles(global_position)


## Trigger hit-stop for kill impact (COMBAT-010)
func _trigger_kill_hit_stop() -> void:
	var hit_stop := get_node_or_null("/root/HitStop")
	if hit_stop and hit_stop.has_method("hit_stop_kill"):
		hit_stop.hit_stop_kill()


## Trigger death sound (glorp) (COMBAT-011)
func _trigger_death_sound() -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("play_death"):
		audio_manager.play_death()


# =============================================================================
# OBJECT POOLING SUPPORT (COMBAT-014)
# =============================================================================


## Reset enemy for reuse from pool (called by pool on_acquire callback)
func reset() -> void:
	current_hp = max_hp
	is_active = true
	velocity = Vector2.ZERO
	visible = true
	set_physics_process(true)
	# Reset AI state
	_wander_timer = 0.0
	_wander_direction = Vector2.from_angle(randf() * TAU)
	_orbit_angle = randf() * TAU
	# Note: spatial_hash and target are set by spawner


## Deactivate for return to pool (called by pool on_release callback)
func deactivate() -> void:
	is_active = false
	velocity = Vector2.ZERO
	target = null
	# Don't queue_free - just hide and disable
	visible = false
	set_physics_process(false)
