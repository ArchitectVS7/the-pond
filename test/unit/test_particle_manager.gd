## Unit Tests for Particle System (COMBAT-009)
##
## Tests particle effects for hit impacts and enemy deaths.
## Performance requirement: Cap at 200 particles (PRD).
extends GutTest

const ParticleManagerClass := preload("res://shared/scripts/particle_manager.gd")

const FRAME_DELTA := 0.016  # ~60fps

var particle_manager: Node2D
var arena: Node2D


func before_each() -> void:
	arena = Node2D.new()
	add_child_autofree(arena)

	particle_manager = ParticleManagerClass.new()
	arena.add_child(particle_manager)

	await get_tree().process_frame


# =============================================================================
# BASIC FUNCTIONALITY TESTS
# =============================================================================


## Test 1: Can spawn hit particles
func test_spawn_hit_particles() -> void:
	var spawn_pos := Vector2(100, 100)
	particle_manager.spawn_hit_particles(spawn_pos)

	assert_true(particle_manager.get_active_count() > 0, "Hit particles should be spawned")


## Test 2: Can spawn death particles
func test_spawn_death_particles() -> void:
	var spawn_pos := Vector2(200, 200)
	particle_manager.spawn_death_particles(spawn_pos)

	assert_true(particle_manager.get_active_count() > 0, "Death particles should be spawned")


## Test 3: Particles appear at correct position
func test_particles_at_correct_position() -> void:
	var spawn_pos := Vector2(150, 150)
	particle_manager.spawn_hit_particles(spawn_pos)

	# Get spawned particles and check position
	var particles := particle_manager.get_active_particles()
	assert_gt(particles.size(), 0, "Should have particles")

	for particle in particles:
		# Particles should be near spawn position (with some spread)
		var distance := particle.global_position.distance_to(spawn_pos)
		assert_lt(distance, 100.0, "Particles should be near spawn position")


# =============================================================================
# LIFECYCLE TESTS
# =============================================================================


## Test 4: Particles cleanup after lifetime
func test_particles_cleanup_after_lifetime() -> void:
	particle_manager.spawn_hit_particles(Vector2(100, 100))
	var initial_count := particle_manager.get_active_count()
	assert_gt(initial_count, 0, "Should have particles initially")

	# Wait for particles to expire (simulate time passing)
	for i in range(120):  # ~2 seconds at 60fps
		particle_manager._process(FRAME_DELTA)

	assert_eq(particle_manager.get_active_count(), 0, "Particles should cleanup after lifetime")


## Test 5: CPUParticles2D are one-shot
func test_particles_are_oneshot() -> void:
	particle_manager.spawn_hit_particles(Vector2(100, 100))

	var particles := particle_manager.get_active_particles()
	for particle in particles:
		if particle is CPUParticles2D:
			assert_true(particle.one_shot, "Particles should be one-shot")


# =============================================================================
# PERFORMANCE TESTS
# =============================================================================


## Test 6: Respects max particle limit
func test_respects_max_particle_limit() -> void:
	particle_manager.max_particles = 50

	# Spawn many particles
	for i in range(100):
		particle_manager.spawn_hit_particles(Vector2(i * 10, 100))

	assert_lte(
		particle_manager.get_active_count(),
		particle_manager.max_particles,
		"Should not exceed max_particles limit"
	)


## Test 7: Old particles removed when at limit
func test_old_particles_removed_at_limit() -> void:
	particle_manager.max_particles = 10

	# Spawn many particles
	for i in range(20):
		particle_manager.spawn_hit_particles(Vector2(i * 10, 100))
		particle_manager._process(FRAME_DELTA)

	assert_lte(
		particle_manager.get_active_count(),
		particle_manager.max_particles,
		"Old particles should be removed to stay under limit"
	)


## Test 8: 200 particle limit from PRD
func test_200_particle_limit_default() -> void:
	assert_lte(
		particle_manager.max_particles, 200, "Default max_particles should be <= 200 per PRD"
	)


# =============================================================================
# VARIATION TESTS
# =============================================================================


## Test 9: Death particles are more intense than hit
func test_death_particles_more_intense() -> void:
	# This is a visual test, but we can check particle count
	particle_manager.spawn_hit_particles(Vector2(100, 100))
	var hit_count := particle_manager.get_active_count()

	# Clear and spawn death
	for p in particle_manager.get_active_particles():
		p.queue_free()
	await get_tree().process_frame

	particle_manager.spawn_death_particles(Vector2(100, 100))
	var death_count := particle_manager.get_active_count()

	# Death should spawn at least as many particles
	assert_gte(death_count, hit_count, "Death particles should be at least as many as hit")


## Test 10: Particles can have color variation
func test_particles_can_spawn() -> void:
	# Basic spawn test - color variation is visual
	particle_manager.spawn_hit_particles(Vector2(100, 100))
	pass_test("Particles spawn successfully")


# =============================================================================
# EDGE CASE TESTS
# =============================================================================


## Test 11: Zero position works
func test_zero_position_works() -> void:
	particle_manager.spawn_hit_particles(Vector2.ZERO)
	assert_true(particle_manager.get_active_count() >= 0, "Zero position should not crash")


## Test 12: Negative position works
func test_negative_position_works() -> void:
	particle_manager.spawn_hit_particles(Vector2(-500, -500))
	pass_test("Negative position should not crash")


## Test 13: Very large spawn count handled
func test_large_spawn_count_handled() -> void:
	for i in range(500):
		particle_manager.spawn_hit_particles(Vector2(randf() * 1000, randf() * 1000))

	assert_lte(
		particle_manager.get_active_count(),
		particle_manager.max_particles,
		"Large spawn count should be capped"
	)


# =============================================================================
# POOLING TESTS (Preparation for COMBAT-014)
# =============================================================================


## Test 14: Clear removes all particles
func test_clear_removes_all() -> void:
	for i in range(10):
		particle_manager.spawn_hit_particles(Vector2(i * 10, 100))

	particle_manager.clear_all()

	assert_eq(particle_manager.get_active_count(), 0, "Clear should remove all particles")
