extends GutTest

# Test suite for BULLET-005: Custom Frog-Themed Bullet Patterns
# Tests fly swarm, lily pad spiral, and ripple wave patterns

# Pattern resource paths
const FLY_SWARM_PATTERN = "res://combat/resources/bullet_patterns/fly_swarm.tres"
const LILY_PAD_PATTERN = "res://combat/resources/bullet_patterns/lily_pad_spiral.tres"
const RIPPLE_WAVE_PATTERN = "res://combat/resources/bullet_patterns/ripple_wave.tres"

# Bullet resource paths
const FLY_BULLET = "res://combat/resources/bullets/fly_bullet.tres"
const LILY_PAD_BULLET = "res://combat/resources/bullets/lily_pad_bullet.tres"
const RIPPLE_BULLET = "res://combat/resources/bullets/ripple_bullet.tres"

# Test spawner and pattern nodes
var spawner: Node2D
var test_pattern: Node

func before_each():
	# Create a spawner for testing
	spawner = Node2D.new()
	var spawner_script = load("res://addons/BulletUpHell/BuHSpawner.gd")
	if spawner_script:
		spawner.set_script(spawner_script)
	add_child(spawner)

func after_each():
	# Clean up
	if spawner:
		spawner.queue_free()
	if test_pattern:
		test_pattern.queue_free()

# ============================================================================
# FLY SWARM PATTERN TESTS
# ============================================================================

func test_fly_swarm_pattern_loads():
	# Test that fly swarm pattern resource loads correctly
	var pattern = load(FLY_SWARM_PATTERN)
	assert_not_null(pattern, "Fly swarm pattern should load")
	assert_eq(pattern.resource_name, "FlySwarm", "Pattern should be named FlySwarm")

func test_fly_bullet_properties_loads():
	# Test that fly bullet properties load correctly
	var bullet = load(FLY_BULLET)
	assert_not_null(bullet, "Fly bullet should load")
	assert_eq(bullet.__ID__, "fly_bullet", "Bullet ID should be fly_bullet")

func test_fly_swarm_random_offset():
	# ACCEPTANCE CRITERIA: Bullets have position variance
	var pattern = load(FLY_SWARM_PATTERN)
	assert_not_null(pattern, "Pattern should load")

	# Verify random position variation is configured
	assert_eq(pattern.r_randomisation_chances, 1.0,
		"Should have 100% randomization chance")
	assert_eq(pattern.r_radius_choice, "gaussian",
		"Should use gaussian distribution for radius")

	# Verify radius variation parameters (0, max, stddev)
	var radius_var = pattern.r_radius_variation
	assert_almost_eq(radius_var.y, 15.0, 0.1,
		"Max radius offset should be 15.0 (fly_random_offset)")

	# Verify angle decal randomization
	assert_eq(pattern.r_angle_decal_choice, "gaussian",
		"Should randomize angle decal")

func test_fly_swarm_small_fast_bullets():
	# Test that fly bullets are small and fast
	var bullet = load(FLY_BULLET)
	assert_not_null(bullet, "Bullet should load")

	# Small scale (0.5x)
	assert_almost_eq(bullet.scale, 0.5, 0.01,
		"Fly bullets should be small (0.5 scale)")

	# Fast speed (250.0)
	assert_almost_eq(bullet.speed, 250.0, 1.0,
		"Fly bullets should be fast (250 speed)")

func test_fly_swarm_erratic_movement():
	# Test that fly bullets have erratic movement pattern
	var bullet = load(FLY_BULLET)
	assert_not_null(bullet, "Bullet should load")

	# Verify angular equation for erratic movement
	assert_eq(bullet.a_angular_equation, "sin(t*8)*0.3",
		"Should have sinusoidal angular movement for erratic flight")

	# Verify rotating speed
	assert_almost_eq(bullet.spec_rotating_speed, 5.0, 0.1,
		"Should have rotation for visual variety")

func test_fly_swarm_burst_count():
	# Test that fly swarm spawns multiple bullets
	var pattern = load(FLY_SWARM_PATTERN)
	assert_not_null(pattern, "Pattern should load")

	# Should spawn 16 bullets per burst
	assert_eq(pattern.nbr, 16,
		"Should spawn 16 bullets per burst (swarm effect)")

# ============================================================================
# LILY PAD SPIRAL PATTERN TESTS
# ============================================================================

func test_lily_pad_pattern_loads():
	# Test that lily pad spiral pattern resource loads correctly
	var pattern = load(LILY_PAD_PATTERN)
	assert_not_null(pattern, "Lily pad pattern should load")
	assert_eq(pattern.resource_name, "LilyPadSpiral",
		"Pattern should be named LilyPadSpiral")

func test_lily_pad_bullet_properties_loads():
	# Test that lily pad bullet properties load correctly
	var bullet = load(LILY_PAD_BULLET)
	assert_not_null(bullet, "Lily pad bullet should load")
	assert_eq(bullet.__ID__, "lily_pad_bullet",
		"Bullet ID should be lily_pad_bullet")

func test_lily_pad_expands():
	# ACCEPTANCE CRITERIA: Pattern grows from center
	var pattern = load(LILY_PAD_PATTERN)
	assert_not_null(pattern, "Pattern should load")

	# Verify multi-layer expansion
	assert_eq(pattern.layer_nbr, 3,
		"Should have 3 layers for expansion effect")

	# Verify position offset increases per layer (30.0 pixels)
	assert_almost_eq(pattern.layer_pos_offset, 30.0, 0.1,
		"Each layer should offset by 30 pixels (expansion)")

	# Verify speed decreases per layer for outward expansion
	assert_almost_eq(pattern.layer_speed_offset, -15.0, 0.1,
		"Speed should decrease per layer for expansion effect")

func test_lily_pad_slow_expansion():
	# Test that lily pad bullets expand slowly
	var bullet = load(LILY_PAD_BULLET)
	assert_not_null(bullet, "Bullet should load")

	# Slow speed (50.0)
	assert_almost_eq(bullet.speed, 50.0, 1.0,
		"Lily pad bullets should expand slowly (lily_expand_rate=50)")

	# Verify speed multiplier for gradual expansion
	assert_eq(bullet.a_speed_multi_iterations, 1,
		"Should use speed multiplier for expansion")

func test_lily_pad_nature_theme():
	# Test that lily pad has nature-themed visual properties
	var bullet = load(LILY_PAD_BULLET)
	assert_not_null(bullet, "Bullet should load")

	# Green trail color for nature theme
	var trail_color = bullet.spec_trail_modulate
	assert_true(trail_color.g > trail_color.r,
		"Should have green-dominant color for nature theme")
	assert_almost_eq(trail_color.g, 0.8, 0.1,
		"Green channel should be prominent")

	# Larger scale for lily pad feel
	assert_almost_eq(bullet.scale, 1.2, 0.1,
		"Should be larger (1.2x) for lily pad aesthetic")

func test_lily_pad_continuous_spiral():
	# Test that lily pad pattern spirals continuously
	var pattern = load(LILY_PAD_PATTERN)
	assert_not_null(pattern, "Pattern should load")

	# Infinite iterations for continuous spiral
	assert_eq(pattern.iterations, -1,
		"Should have infinite iterations for continuous effect")

	# Verify angle offset per layer for spiral
	assert_almost_eq(pattern.layer_angle_offset, 0.3927, 0.01,
		"Should have angular offset for spiral pattern")

func test_lily_pad_symmetry():
	# Test that lily pad pattern is symmetric
	var pattern = load(LILY_PAD_PATTERN)
	assert_not_null(pattern, "Pattern should load")

	assert_true(pattern.symmetric,
		"Lily pad pattern should be symmetric for natural feel")

# ============================================================================
# RIPPLE WAVE PATTERN TESTS
# ============================================================================

func test_ripple_wave_pattern_loads():
	# Test that ripple wave pattern resource loads correctly
	var pattern = load(RIPPLE_WAVE_PATTERN)
	assert_not_null(pattern, "Ripple wave pattern should load")
	assert_eq(pattern.resource_name, "RippleWave",
		"Pattern should be named RippleWave")

func test_ripple_bullet_properties_loads():
	# Test that ripple bullet properties load correctly
	var bullet = load(RIPPLE_BULLET)
	assert_not_null(bullet, "Ripple bullet should load")
	assert_eq(bullet.__ID__, "ripple_bullet",
		"Bullet ID should be ripple_bullet")

func test_ripple_creates_rings():
	# ACCEPTANCE CRITERIA: Multiple ring waves spawn
	var pattern = load(RIPPLE_WAVE_PATTERN)
	assert_not_null(pattern, "Pattern should load")

	# Verify number of rings (iterations = 3)
	assert_eq(pattern.iterations, 3,
		"Should create 3 ripple rings (ripple_ring_count)")

	# Verify ring spawn delay (0.5 seconds)
	assert_almost_eq(pattern.cooldown_spawn, 0.5, 0.01,
		"Rings should spawn 0.5s apart (ripple_ring_delay)")

	# High bullet count per ring for complete circle
	assert_eq(pattern.nbr, 24,
		"Should have 24 bullets per ring for smooth circle")

func test_ripple_concentric_circles():
	# Test that ripple creates concentric circular patterns
	var pattern = load(RIPPLE_WAVE_PATTERN)
	assert_not_null(pattern, "Pattern should load")

	# Full 360-degree circle
	assert_almost_eq(pattern.angle_total, 6.28319, 0.001,
		"Should cover full circle (2*PI radians)")

	# Symmetric for perfect circles
	assert_true(pattern.symmetric,
		"Should be symmetric for perfect concentric circles")

	# Pattern looks at center for radial expansion
	assert_true(pattern.forced_pattern_lookat,
		"Should look at pattern center for radial effect")

func test_ripple_wave_visual_trail():
	# Test that ripple bullets have water-like visual trails
	var bullet = load(RIPPLE_BULLET)
	assert_not_null(bullet, "Bullet should load")

	# Should have trail effect
	assert_almost_eq(bullet.spec_trail_length, 10.0, 0.1,
		"Should have trail for water ripple effect")
	assert_almost_eq(bullet.spec_trail_width, 2.0, 0.1,
		"Trail should be visible width")

	# Blue trail color for water theme
	var trail_color = bullet.spec_trail_modulate
	assert_true(trail_color.b > trail_color.r,
		"Should have blue-dominant color for water theme")
	assert_almost_eq(trail_color.b, 0.9, 0.1,
		"Blue channel should be prominent")

func test_ripple_medium_speed():
	# Test that ripple bullets have medium expansion speed
	var bullet = load(RIPPLE_BULLET)
	assert_not_null(bullet, "Bullet should load")

	# Medium speed (120.0)
	assert_almost_eq(bullet.speed, 120.0, 1.0,
		"Ripple bullets should have medium speed (120)")

# ============================================================================
# PATTERN DIFFERENTIATION TESTS
# ============================================================================

func test_patterns_visually_distinct():
	# Test that all three patterns have distinct characteristics
	var fly = load(FLY_BULLET)
	var lily = load(LILY_PAD_BULLET)
	var ripple = load(RIPPLE_BULLET)

	# Different speeds
	assert_true(fly.speed != lily.speed,
		"Fly and lily should have different speeds")
	assert_true(lily.speed != ripple.speed,
		"Lily and ripple should have different speeds")

	# Different scales
	assert_true(fly.scale != lily.scale,
		"Fly and lily should have different scales")
	assert_true(lily.scale != ripple.scale,
		"Lily and ripple should have different scales")

	# Different trail effects
	assert_true(fly.spec_trail_length != ripple.spec_trail_length,
		"Fly and ripple should have different trail effects")

func test_pattern_spawn_rates_distinct():
	# Test that patterns have different spawn behaviors
	var fly_pattern = load(FLY_SWARM_PATTERN)
	var lily_pattern = load(LILY_PAD_PATTERN)
	var ripple_pattern = load(RIPPLE_WAVE_PATTERN)

	# Different cooldowns
	assert_true(fly_pattern.cooldown_spawn != lily_pattern.cooldown_spawn,
		"Fly and lily should have different spawn rates")
	assert_true(lily_pattern.cooldown_spawn != ripple_pattern.cooldown_spawn,
		"Lily and ripple should have different spawn rates")

	# Different bullet counts
	assert_true(fly_pattern.nbr != lily_pattern.nbr,
		"Fly and lily should spawn different bullet counts")

# ============================================================================
# TUNABLE PARAMETER VALIDATION
# ============================================================================

func test_fly_random_offset_parameter():
	# Test fly_random_offset parameter (default: 15.0)
	var pattern = load(FLY_SWARM_PATTERN)
	var radius_var = pattern.r_radius_variation
	assert_almost_eq(radius_var.y, 15.0, 0.1,
		"fly_random_offset should default to 15.0")

func test_lily_expand_rate_parameter():
	# Test lily_expand_rate parameter (default: 50.0)
	var bullet = load(LILY_PAD_BULLET)
	assert_almost_eq(bullet.speed, 50.0, 1.0,
		"lily_expand_rate should default to 50.0")

func test_ripple_ring_count_parameter():
	# Test ripple_ring_count parameter (default: 3)
	var pattern = load(RIPPLE_WAVE_PATTERN)
	assert_eq(pattern.iterations, 3,
		"ripple_ring_count should default to 3")

func test_ripple_ring_delay_parameter():
	# Test ripple_ring_delay parameter (default: 0.5)
	var pattern = load(RIPPLE_WAVE_PATTERN)
	assert_almost_eq(pattern.cooldown_spawn, 0.5, 0.01,
		"ripple_ring_delay should default to 0.5")

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

func test_all_patterns_compatible_with_spawner():
	# Test that all patterns can be used with BulletUpHell spawner
	var patterns = [FLY_SWARM_PATTERN, LILY_PAD_PATTERN, RIPPLE_WAVE_PATTERN]

	for pattern_path in patterns:
		var pattern = load(pattern_path)
		assert_not_null(pattern, "Pattern should load: " + pattern_path)
		assert_not_null(pattern.script,
			"Pattern should have PatternCircle script: " + pattern_path)

func test_all_bullets_have_valid_properties():
	# Test that all bullet resources have required properties
	var bullets = [FLY_BULLET, LILY_PAD_BULLET, RIPPLE_BULLET]

	for bullet_path in bullets:
		var bullet = load(bullet_path)
		assert_not_null(bullet, "Bullet should load: " + bullet_path)
		assert_true(bullet.speed > 0,
			"Bullet should have positive speed: " + bullet_path)
		assert_true(bullet.scale > 0,
			"Bullet should have positive scale: " + bullet_path)
		assert_true(bullet.death_after_time > 0,
			"Bullet should have lifetime: " + bullet_path)
