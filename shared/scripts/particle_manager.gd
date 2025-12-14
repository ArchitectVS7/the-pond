## ParticleManager - Manages particle effects for combat feedback
##
## COMBAT-009: Particle system for hits and deaths
## PRD Requirement: Cap max particles to 200 for performance
##
## Features:
## - Hit impact particles (small burst)
## - Death particles (larger burst)
## - Automatic cleanup after lifetime
## - Particle pooling (preparation for COMBAT-014)
## - Performance capping
##
## Architecture Notes:
## - Designed as autoload singleton
## - Uses CPUParticles2D for compatibility
## - Old particles removed when at limit (FIFO)
## - No allocations in spawn hot path (uses pool)
class_name ParticleManager
extends Node2D

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when particles are spawned
signal particles_spawned(type: String, position: Vector2)

# =============================================================================
# EXPORTS (Tunable in Editor - see DEVELOPERS_MANUAL.md)
# =============================================================================

## Maximum particles allowed (PRD: 200)
@export var max_particles: int = 200

## Lifetime of hit particles (seconds)
@export var hit_particle_lifetime: float = 0.5

## Lifetime of death particles (seconds)
@export var death_particle_lifetime: float = 0.8

## Number of particles per hit
@export var hit_particle_amount: int = 8

## Number of particles per death
@export var death_particle_amount: int = 16

## Speed of hit particles (pixels/second)
@export var hit_particle_speed: float = 100.0

## Speed of death particles (pixels/second)
@export var death_particle_speed: float = 150.0

# =============================================================================
# COLORS
# =============================================================================

## Hit particle color (impact flash)
@export var hit_color: Color = Color(1.0, 1.0, 0.8, 1.0)  # Warm white

## Death particle color (enemy goop)
@export var death_color: Color = Color(0.2, 0.8, 0.2, 1.0)  # Green slime

# =============================================================================
# STATE
# =============================================================================

## Active particle systems (tracked for cleanup and counting)
var _active_particles: Array[CPUParticles2D] = []

## Pool of inactive particle systems for reuse
var _particle_pool: Array[CPUParticles2D] = []

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	# Pre-warm pool with a few particle systems
	for i in range(10):
		_particle_pool.append(_create_particle_system())


func _process(_delta: float) -> void:
	# Cleanup finished particles
	_cleanup_finished_particles()


# =============================================================================
# PUBLIC API
# =============================================================================


## Spawn hit impact particles at position
func spawn_hit_particles(pos: Vector2) -> void:
	var particles := _get_or_create_particles()
	_configure_hit_particles(particles)
	particles.global_position = pos
	particles.emitting = true

	_register_particle(particles)
	particles_spawned.emit("hit", pos)


## Spawn death burst particles at position
func spawn_death_particles(pos: Vector2) -> void:
	var particles := _get_or_create_particles()
	_configure_death_particles(particles)
	particles.global_position = pos
	particles.emitting = true

	_register_particle(particles)
	particles_spawned.emit("death", pos)


## Get current active particle count
func get_active_count() -> int:
	return _active_particles.size()


## Get all active particle systems
func get_active_particles() -> Array[CPUParticles2D]:
	return _active_particles


## Clear all particles immediately
func clear_all() -> void:
	for particles in _active_particles:
		particles.emitting = false
		_return_to_pool(particles)
	_active_particles.clear()


# =============================================================================
# PARTICLE CONFIGURATION
# =============================================================================


## Configure particle system for hit effect
func _configure_hit_particles(particles: CPUParticles2D) -> void:
	particles.amount = hit_particle_amount
	particles.lifetime = hit_particle_lifetime
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.initial_velocity_min = hit_particle_speed * 0.5
	particles.initial_velocity_max = hit_particle_speed
	particles.gravity = Vector2(0, 200)
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = hit_color


## Configure particle system for death effect
func _configure_death_particles(particles: CPUParticles2D) -> void:
	particles.amount = death_particle_amount
	particles.lifetime = death_particle_lifetime
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.initial_velocity_min = death_particle_speed * 0.5
	particles.initial_velocity_max = death_particle_speed
	particles.gravity = Vector2(0, 300)
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = death_color


# =============================================================================
# POOLING AND LIFECYCLE
# =============================================================================


## Get particle system from pool or create new one
func _get_or_create_particles() -> CPUParticles2D:
	if _particle_pool.size() > 0:
		var particles := _particle_pool.pop_back()
		particles.visible = true
		return particles

	var particles := _create_particle_system()
	add_child(particles)
	return particles


## Create a new particle system
func _create_particle_system() -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	add_child(particles)
	return particles


## Register particle as active
func _register_particle(particles: CPUParticles2D) -> void:
	_active_particles.append(particles)

	# Enforce max limit (remove oldest first)
	while _active_particles.size() > max_particles:
		var oldest := _active_particles.pop_front()
		oldest.emitting = false
		_return_to_pool(oldest)


## Return particle to pool for reuse
func _return_to_pool(particles: CPUParticles2D) -> void:
	particles.emitting = false
	particles.visible = false
	_particle_pool.append(particles)


## Cleanup finished particle systems
func _cleanup_finished_particles() -> void:
	var to_remove: Array[CPUParticles2D] = []

	for particles in _active_particles:
		if not particles.emitting:
			to_remove.append(particles)

	for particles in to_remove:
		_active_particles.erase(particles)
		_return_to_pool(particles)
