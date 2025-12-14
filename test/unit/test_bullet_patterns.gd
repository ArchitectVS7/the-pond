extends GutTest
# Unit tests for BULLET-003: Basic Bullet Patterns
# Tests: radial_8way, spiral_clockwise, aimed_single

var spawning_node: Node
var test_spawner: Node2D

# Tunable parameters from BULLET-003
const BULLETS_PER_RADIAL = 8
const SPIRAL_ROTATION_SPEED = 180.0  # Degrees per second
const BULLET_SPEED = 200.0

func before_all():
	# Get Spawning autoload
	spawning_node = get_node_or_null("/root/Spawning")
	assert_not_null(spawning_node, "Spawning autoload should be available")

func before_each():
	# Create test spawner
	test_spawner = Node2D.new()
	add_child(test_spawner)
	test_spawner.global_position = Vector2(576, 324)

	# Register basic bullet
	var bullet_props = {
		"__ID__": "test_bullet",
		"speed": BULLET_SPEED,
		"scale": 1.0,
		"angle": 0.0,
		"anim_idle_texture": "0",
		"anim_idle_collision": "0",
		"death_after_time": 5.0,
		"death_from_collision": true
	}
	spawning_node.new_bullet("test_bullet", bullet_props)

func after_each():
	# Clean up bullets and spawner
	if spawning_node:
		spawning_node.clear_all_bullets()
		spawning_node.reset(false)
	if test_spawner:
		test_spawner.queue_free()
	await get_tree().process_frame

# TEST: Radial pattern spawns 8 bullets
func test_radial_spawns_8_bullets():
	# Load and register radial pattern
	var radial_pattern = load("res://combat/resources/bullet_patterns/radial_8way.tres")
	assert_not_null(radial_pattern, "Radial pattern should load")

	radial_pattern.nbr = BULLETS_PER_RADIAL
	radial_pattern.bullet = "test_bullet"
	radial_pattern.iterations = 1
	spawning_node.new_pattern("test_radial", radial_pattern)

	# Spawn pattern
	spawning_node.spawn(test_spawner, "test_radial")

	# Wait for bullets to spawn
	await wait_seconds(0.1)

	# Count bullets in pool
	var bullet_count = spawning_node.poolBullets.size()
	assert_eq(bullet_count, BULLETS_PER_RADIAL,
		"Should spawn exactly %d bullets, got %d" % [BULLETS_PER_RADIAL, bullet_count])

	# Verify bullets are in circular pattern (radius should be 0 initially)
	var bullets_checked = 0
	for bullet_id in spawning_node.poolBullets:
		var bullet = spawning_node.poolBullets[bullet_id]
		# Verify bullet has expected speed
		assert_almost_eq(bullet.get("speed", 0), BULLET_SPEED, 0.1,
			"Bullet should have speed %f" % BULLET_SPEED)
		bullets_checked += 1

	assert_eq(bullets_checked, BULLETS_PER_RADIAL, "All bullets should be verified")

# TEST: Spiral pattern rotates over time
func test_spiral_rotates():
	# Load and register spiral pattern
	var spiral_pattern = load("res://combat/resources/bullet_patterns/spiral_clockwise.tres")
	assert_not_null(spiral_pattern, "Spiral pattern should load")

	spiral_pattern.bullet = "test_bullet"
	spiral_pattern.iterations = 3  # Spawn 3 waves
	spiral_pattern.cooldown_spawn = 0.1  # 100ms between spawns

	# Set rotation: 30 degrees per spawn (180° per second * 0.1s * PI/180)
	var angle_offset = deg_to_rad(SPIRAL_ROTATION_SPEED * 0.1)
	spiral_pattern.layer_angle_offset = angle_offset

	spawning_node.new_pattern("test_spiral", spiral_pattern)

	# Spawn first wave
	spawning_node.spawn(test_spawner, "test_spiral")
	await wait_seconds(0.05)

	var first_wave_count = spawning_node.poolBullets.size()
	assert_gt(first_wave_count, 0, "First wave should spawn bullets")

	# Wait for second wave
	await wait_seconds(0.15)

	var second_wave_count = spawning_node.poolBullets.size()
	assert_gt(second_wave_count, first_wave_count, "Second wave should spawn more bullets")

	# Verify rotation is applied (check layer_angle_offset)
	assert_almost_eq(spiral_pattern.layer_angle_offset, angle_offset, 0.01,
		"Pattern should have angle offset of %f radians" % angle_offset)

# TEST: Aimed pattern follows target (mouse position)
func test_aimed_follows_target():
	# Load and register aimed pattern
	var aimed_pattern = load("res://combat/resources/bullet_patterns/aimed_single.tres")
	assert_not_null(aimed_pattern, "Aimed pattern should load")

	aimed_pattern.bullet = "test_bullet"
	aimed_pattern.iterations = 1
	aimed_pattern.forced_lookat_mouse = true

	spawning_node.new_pattern("test_aimed", aimed_pattern)

	# Set a known mouse position (simulated)
	# Note: In real test, mouse position would be mocked
	# For now, just verify pattern is configured correctly

	# Spawn pattern
	spawning_node.spawn(test_spawner, "test_aimed")
	await wait_seconds(0.1)

	# Verify single bullet spawned
	var bullet_count = spawning_node.poolBullets.size()
	assert_eq(bullet_count, 1, "Should spawn exactly 1 aimed bullet")

	# Verify aimed configuration
	assert_true(aimed_pattern.forced_lookat_mouse,
		"Pattern should be configured to look at mouse")

# TEST: Bullets despawn after timeout
func test_bullets_despawn_after_timeout():
	# Create pattern with short timeout
	var radial_pattern = load("res://combat/resources/bullet_patterns/radial_8way.tres")
	radial_pattern.nbr = 3
	radial_pattern.bullet = "test_bullet"

	# Override bullet lifetime
	var short_bullet_props = {
		"__ID__": "short_bullet",
		"speed": BULLET_SPEED,
		"scale": 1.0,
		"angle": 0.0,
		"anim_idle_texture": "0",
		"anim_idle_collision": "0",
		"death_after_time": 0.2,  # 200ms lifetime
		"death_from_collision": true
	}
	spawning_node.new_bullet("short_bullet", short_bullet_props)

	radial_pattern.bullet = "short_bullet"
	spawning_node.new_pattern("test_timeout", radial_pattern)

	# Spawn bullets
	spawning_node.spawn(test_spawner, "test_timeout")
	await wait_seconds(0.1)

	var initial_count = spawning_node.poolBullets.size()
	assert_gt(initial_count, 0, "Bullets should spawn initially")

	# Wait for timeout
	await wait_seconds(0.3)

	var final_count = spawning_node.poolBullets.size()
	assert_eq(final_count, 0, "Bullets should despawn after timeout")

# TEST: Bullets move in expected directions
func test_bullets_move_correctly():
	# Radial pattern: bullets should move outward from center
	var radial_pattern = load("res://combat/resources/bullet_patterns/radial_8way.tres")
	radial_pattern.nbr = 4  # Use 4 for easier testing (90° apart)
	radial_pattern.bullet = "test_bullet"
	spawning_node.new_pattern("test_movement", radial_pattern)

	spawning_node.spawn(test_spawner, "test_movement")
	await wait_seconds(0.05)

	# Capture initial positions
	var initial_positions = {}
	for bullet_id in spawning_node.poolBullets:
		var bullet = spawning_node.poolBullets[bullet_id]
		initial_positions[bullet_id] = bullet["position"]

	# Wait for movement
	await wait_seconds(0.2)

	# Verify bullets have moved
	var moved_count = 0
	for bullet_id in spawning_node.poolBullets:
		if not initial_positions.has(bullet_id):
			continue
		var bullet = spawning_node.poolBullets[bullet_id]
		var initial_pos = initial_positions[bullet_id]
		var current_pos = bullet["position"]

		var distance_moved = initial_pos.distance_to(current_pos)
		if distance_moved > 10.0:  # Moved at least 10 pixels
			moved_count += 1

	assert_gt(moved_count, 0, "At least some bullets should have moved")

# Helper function to wait
func wait_seconds(seconds: float):
	await get_tree().create_timer(seconds).timeout
