## test_bullet_collision.gd
## BULLET-007: Unit tests for bullet collision optimization
## Tests collision layer configuration, bullet-player hits, and enemy ignore logic
extends GutTest

# =============================================================================
# TEST FIXTURES
# =============================================================================

var collision_config: Script
var test_player: CharacterBody2D
var test_enemy: CharacterBody2D
var test_bullet_area: Area2D
var test_spawner: Node

func before_each() -> void:
	"""Set up test fixtures before each test."""
	collision_config = load("res://combat/scripts/bullet_collision_config.gd")

	# Create test player
	test_player = CharacterBody2D.new()
	test_player.name = "TestPlayer"
	test_player.collision_layer = collision_config.MASK_PLAYER
	test_player.collision_mask = collision_config.MASK_ENVIRONMENT | collision_config.MASK_BULLETS
	add_child_autofree(test_player)

	# Create test enemy
	test_enemy = CharacterBody2D.new()
	test_enemy.name = "TestEnemy"
	test_enemy.collision_layer = collision_config.MASK_ENEMIES
	test_enemy.collision_mask = collision_config.MASK_ENVIRONMENT
	add_child_autofree(test_enemy)

	# Create test bullet area
	test_bullet_area = Area2D.new()
	test_bullet_area.name = "TestBullet"
	add_child_autofree(test_bullet_area)

	# Create mock spawner with shared_area
	test_spawner = Node.new()
	test_spawner.name = "TestSpawner"
	var shared_area = Area2D.new()
	shared_area.name = "shared_area"
	test_spawner.add_child(shared_area)
	add_child_autofree(test_spawner)


func after_each() -> void:
	"""Clean up after each test."""
	# GUT autofree handles cleanup
	pass


# =============================================================================
# COLLISION LAYER CONFIGURATION TESTS
# =============================================================================

func test_collision_layer_constants() -> void:
	"""Test that collision layer constants are correct."""
	assert_eq(collision_config.LAYER_PLAYER, 1, "Player layer should be 1")
	assert_eq(collision_config.LAYER_ENVIRONMENT, 2, "Environment layer should be 2")
	assert_eq(collision_config.LAYER_ENEMIES, 3, "Enemies layer should be 3")
	assert_eq(collision_config.LAYER_PLAYER_ATTACK, 4, "PlayerAttack layer should be 4")
	assert_eq(collision_config.LAYER_BULLETS, 5, "Bullets layer should be 5")


func test_collision_layer_masks() -> void:
	"""Test that collision mask bit flags are correct."""
	assert_eq(collision_config.MASK_PLAYER, 0b00001, "Player mask should be bit 0")
	assert_eq(collision_config.MASK_ENVIRONMENT, 0b00010, "Environment mask should be bit 1")
	assert_eq(collision_config.MASK_ENEMIES, 0b00100, "Enemies mask should be bit 2")
	assert_eq(collision_config.MASK_PLAYER_ATTACK, 0b01000, "PlayerAttack mask should be bit 3")
	assert_eq(collision_config.MASK_BULLETS, 0b10000, "Bullets mask should be bit 4")


func test_configure_bullet_spawner() -> void:
	"""Test bullet spawner collision configuration."""
	# Configure spawner
	collision_config.configure_bullet_spawner(test_spawner)

	var shared_area = test_spawner.get_node("shared_area")

	# Bullets should be on Layer 5
	assert_eq(
		shared_area.collision_layer,
		collision_config.MASK_BULLETS,
		"Bullets should be on Layer 5"
	)

	# Bullets should only mask Player (Layer 1)
	assert_eq(
		shared_area.collision_mask,
		collision_config.MASK_PLAYER,
		"Bullets should only collide with Player"
	)


func test_configure_bullet_area() -> void:
	"""Test individual bullet area configuration."""
	collision_config.configure_bullet_area(test_bullet_area)

	assert_eq(
		test_bullet_area.collision_layer,
		collision_config.MASK_BULLETS,
		"Bullet area should be on Layer 5"
	)

	assert_eq(
		test_bullet_area.collision_mask,
		collision_config.MASK_PLAYER,
		"Bullet area should only mask Player"
	)


# =============================================================================
# COLLISION DETECTION TESTS
# =============================================================================

func test_bullet_collides_player() -> void:
	"""
	ACCEPTANCE CRITERIA: Bullets hit player
	Bullets on Layer 5 with Mask 1 should collide with Player on Layer 1
	"""
	# Configure bullet
	collision_config.configure_bullet_area(test_bullet_area)

	# Add collision shape to bullet
	var bullet_shape = CollisionShape2D.new()
	bullet_shape.shape = collision_config.create_bullet_hitbox(4.0)
	test_bullet_area.add_child(bullet_shape)

	# Add collision shape to player
	var player_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 16.0
	player_shape.shape = circle
	test_player.add_child(player_shape)

	# Position bullet and player overlapping
	test_player.global_position = Vector2(100, 100)
	test_bullet_area.global_position = Vector2(100, 100)

	# Check that layers allow collision
	# Bullet layer (5) & Player mask (2,5) should have overlap
	var bullet_layer = test_bullet_area.collision_layer
	var player_mask = test_player.collision_mask

	var can_collide = (bullet_layer & player_mask) != 0

	assert_true(
		can_collide,
		"Bullet layer %d should overlap with Player mask %d" % [bullet_layer, player_mask]
	)


func test_bullet_ignores_enemies() -> void:
	"""
	ACCEPTANCE CRITERIA: Enemy bullets don't hit enemies
	Bullets on Layer 5 with Mask 1 should NOT collide with Enemies on Layer 3
	"""
	# Configure bullet
	collision_config.configure_bullet_area(test_bullet_area)

	# Check that bullet mask does NOT include enemy layer
	var bullet_mask = test_bullet_area.collision_mask
	var enemy_layer = test_enemy.collision_layer

	var can_collide = (bullet_mask & enemy_layer) != 0

	assert_false(
		can_collide,
		"Bullet mask %d should NOT overlap with Enemy layer %d" % [bullet_mask, enemy_layer]
	)


func test_player_detects_bullets() -> void:
	"""Test that player collision mask includes bullet layer."""
	# Player should have Bullets (Layer 5) in its mask
	var player_mask = test_player.collision_mask
	var bullet_layer = collision_config.MASK_BULLETS

	var can_detect = (player_mask & bullet_layer) != 0

	assert_true(
		can_detect,
		"Player mask %d should include Bullets layer %d" % [player_mask, bullet_layer]
	)


func test_enemy_ignores_bullets() -> void:
	"""Test that enemy collision mask does NOT include bullet layer."""
	# Enemy should NOT have Bullets (Layer 5) in its mask
	var enemy_mask = test_enemy.collision_mask
	var bullet_layer = collision_config.MASK_BULLETS

	var can_detect = (enemy_mask & bullet_layer) != 0

	assert_false(
		can_detect,
		"Enemy mask %d should NOT include Bullets layer %d" % [enemy_mask, bullet_layer]
	)


# =============================================================================
# DEFERRED COLLISION TESTS
# =============================================================================

func test_enable_collision_shape_deferred() -> void:
	"""Test collision shape enabling with set_deferred."""
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.disabled = true
	add_child_autofree(shape)

	# Enable using deferred
	collision_config.enable_collision_shape(shape)

	# Wait for deferred call
	await wait_frames(2)

	assert_false(shape.disabled, "Collision shape should be enabled after deferred call")


func test_disable_collision_shape_deferred() -> void:
	"""Test collision shape disabling with set_deferred."""
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.disabled = false
	add_child_autofree(shape)

	# Disable using deferred
	collision_config.disable_collision_shape(shape)

	# Wait for deferred call
	await wait_frames(2)

	assert_true(shape.disabled, "Collision shape should be disabled after deferred call")


# =============================================================================
# HITBOX CREATION TESTS
# =============================================================================

func test_create_bullet_hitbox_default() -> void:
	"""Test default bullet hitbox creation."""
	var hitbox = collision_config.create_bullet_hitbox()

	assert_not_null(hitbox, "Hitbox should be created")
	assert_true(hitbox is CircleShape2D, "Hitbox should be CircleShape2D")
	assert_eq(
		hitbox.radius,
		collision_config.DEFAULT_BULLET_HITBOX_SIZE,
		"Default hitbox should have correct radius"
	)


func test_create_bullet_hitbox_custom_size() -> void:
	"""Test custom bullet hitbox creation."""
	var custom_radius = 8.0
	var hitbox = collision_config.create_bullet_hitbox(custom_radius)

	assert_eq(
		hitbox.radius,
		custom_radius,
		"Custom hitbox should have specified radius"
	)


# =============================================================================
# VALIDATION TESTS
# =============================================================================

func test_validate_spawner_config_valid() -> void:
	"""Test spawner validation with correct configuration."""
	# Configure spawner correctly
	collision_config.configure_bullet_spawner(test_spawner)

	# Validate
	var result = collision_config.validate_spawner_config(test_spawner)

	assert_true(result.valid, "Correctly configured spawner should be valid")
	assert_eq(result.errors.size(), 0, "Should have no errors")


func test_validate_spawner_config_missing_shared_area() -> void:
	"""Test spawner validation with missing shared_area."""
	# Create spawner without shared_area
	var bad_spawner = Node.new()
	add_child_autofree(bad_spawner)

	var result = collision_config.validate_spawner_config(bad_spawner)

	assert_false(result.valid, "Spawner without shared_area should be invalid")
	assert_gt(result.errors.size(), 0, "Should have errors")


func test_validate_spawner_config_wrong_layers() -> void:
	"""Test spawner validation with incorrect layers."""
	var shared_area = test_spawner.get_node("shared_area")

	# Set wrong layers
	shared_area.collision_layer = 1  # Wrong layer
	shared_area.collision_mask = 2   # Wrong mask

	var result = collision_config.validate_spawner_config(test_spawner)

	# Should have warnings about wrong configuration
	assert_gt(result.warnings.size(), 0, "Should have warnings about wrong layers")


# =============================================================================
# PERFORMANCE HELPER TESTS
# =============================================================================

func test_get_layer_name() -> void:
	"""Test layer name retrieval."""
	assert_eq(collision_config.get_layer_name(1), "Player")
	assert_eq(collision_config.get_layer_name(2), "Environment")
	assert_eq(collision_config.get_layer_name(3), "Enemies")
	assert_eq(collision_config.get_layer_name(4), "PlayerAttack")
	assert_eq(collision_config.get_layer_name(5), "Bullets")
	assert_eq(collision_config.get_layer_name(99), "Unknown")


func test_is_collision_optimized() -> void:
	"""Test collision optimization check."""
	# Configure bullet area (optimized - only 1 mask bit)
	collision_config.configure_bullet_area(test_bullet_area)

	assert_true(
		collision_config.is_collision_optimized(test_bullet_area),
		"Bullet area with single mask bit should be optimized"
	)

	# Create unoptimized area (multiple mask bits)
	var unoptimized = Area2D.new()
	unoptimized.collision_mask = 0b11111  # All 5 layers
	add_child_autofree(unoptimized)

	assert_false(
		collision_config.is_collision_optimized(unoptimized),
		"Area with multiple mask bits should not be optimized"
	)


# =============================================================================
# INTEGRATION TESTS
# =============================================================================

func test_full_collision_setup() -> void:
	"""Test complete collision layer setup for game scenario."""
	# Configure all entities
	collision_config.configure_bullet_spawner(test_spawner)
	collision_config.configure_bullet_area(test_bullet_area)

	# Validate spawner
	var validation = collision_config.validate_spawner_config(test_spawner)
	assert_true(validation.valid, "Spawner should be valid after configuration")

	# Check optimization
	assert_true(
		collision_config.is_collision_optimized(test_bullet_area),
		"Bullet area should be optimized"
	)

	# Verify collision matrix
	# Bullet (Layer 5, Mask 1) vs Player (Layer 1, Mask 2|5)
	var bullet_layer = test_bullet_area.collision_layer
	var player_mask = test_player.collision_mask
	assert_true(
		(bullet_layer & player_mask) != 0,
		"Bullets should collide with Player"
	)

	# Bullet (Layer 5, Mask 1) vs Enemy (Layer 3, Mask 2)
	var enemy_layer = test_enemy.collision_layer
	var bullet_mask = test_bullet_area.collision_mask
	assert_false(
		(bullet_mask & enemy_layer) != 0,
		"Bullets should NOT collide with Enemies"
	)
