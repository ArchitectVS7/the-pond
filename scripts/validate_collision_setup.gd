#!/usr/bin/env -S godot --headless --script
## validate_collision_setup.gd
## BULLET-007: Validation script for collision layer configuration
## Run: godot --headless --script scripts/validate_collision_setup.gd
extends SceneTree

var collision_config = preload("res://combat/scripts/bullet_collision_config.gd")

func _init() -> void:
	"""Validate collision configuration across all scenes."""
	print("=== BULLET-007 Collision Configuration Validation ===\n")

	_validate_project_settings()
	_validate_collision_constants()
	_validate_layer_names()
	_print_collision_matrix()
	_print_optimization_tips()

	print("\n=== Validation Complete ===")
	quit()


func _validate_project_settings() -> void:
	"""Validate project.godot layer names."""
	print("1. Project Settings - Layer Names:")

	var layers = {
		"2d_physics/layer_1": "Player",
		"2d_physics/layer_2": "Environment",
		"2d_physics/layer_3": "Enemies",
		"2d_physics/layer_4": "PlayerAttack",
		"2d_physics/layer_5": "Bullets"
	}

	var all_valid = true

	for setting in layers.keys():
		var expected = layers[setting]
		var actual = ProjectSettings.get_setting(setting, "")

		if actual == expected:
			print("  ✓ %s = '%s'" % [setting, actual])
		else:
			print("  ✗ %s = '%s' (expected '%s')" % [setting, actual, expected])
			all_valid = false

	if all_valid:
		print("  Result: PASS\n")
	else:
		print("  Result: FAIL - Update project.godot [layer_names] section\n")


func _validate_collision_constants() -> void:
	"""Validate collision config constants."""
	print("2. Collision Config - Constants:")

	var tests = [
		{"name": "LAYER_PLAYER", "value": collision_config.LAYER_PLAYER, "expected": 1},
		{"name": "LAYER_ENVIRONMENT", "value": collision_config.LAYER_ENVIRONMENT, "expected": 2},
		{"name": "LAYER_ENEMIES", "value": collision_config.LAYER_ENEMIES, "expected": 3},
		{"name": "LAYER_PLAYER_ATTACK", "value": collision_config.LAYER_PLAYER_ATTACK, "expected": 4},
		{"name": "LAYER_BULLETS", "value": collision_config.LAYER_BULLETS, "expected": 5},
		{"name": "MASK_PLAYER", "value": collision_config.MASK_PLAYER, "expected": 0b00001},
		{"name": "MASK_ENVIRONMENT", "value": collision_config.MASK_ENVIRONMENT, "expected": 0b00010},
		{"name": "MASK_ENEMIES", "value": collision_config.MASK_ENEMIES, "expected": 0b00100},
		{"name": "MASK_PLAYER_ATTACK", "value": collision_config.MASK_PLAYER_ATTACK, "expected": 0b01000},
		{"name": "MASK_BULLETS", "value": collision_config.MASK_BULLETS, "expected": 0b10000},
	]

	var all_valid = true

	for test in tests:
		if test.value == test.expected:
			print("  ✓ %s = %d (0b%s)" % [
				test.name,
				test.value,
				_to_binary_string(test.value, 5)
			])
		else:
			print("  ✗ %s = %d (expected %d)" % [
				test.name,
				test.value,
				test.expected
			])
			all_valid = false

	if all_valid:
		print("  Result: PASS\n")
	else:
		print("  Result: FAIL - Check bullet_collision_config.gd constants\n")


func _validate_layer_names() -> void:
	"""Validate layer name helper function."""
	print("3. Layer Name Helper:")

	var tests = [
		{"layer": 1, "expected": "Player"},
		{"layer": 2, "expected": "Environment"},
		{"layer": 3, "expected": "Enemies"},
		{"layer": 4, "expected": "PlayerAttack"},
		{"layer": 5, "expected": "Bullets"},
		{"layer": 99, "expected": "Unknown"}
	]

	var all_valid = true

	for test in tests:
		var actual = collision_config.get_layer_name(test.layer)
		if actual == test.expected:
			print("  ✓ Layer %d = '%s'" % [test.layer, actual])
		else:
			print("  ✗ Layer %d = '%s' (expected '%s')" % [
				test.layer,
				actual,
				test.expected
			])
			all_valid = false

	if all_valid:
		print("  Result: PASS\n")
	else:
		print("  Result: FAIL\n")


func _print_collision_matrix() -> void:
	"""Print collision matrix for reference."""
	print("4. Collision Matrix:")
	print("")
	print("  Entity          | Layer | Mask    | Collides With")
	print("  ----------------|-------|---------|------------------")
	print("  Player          | 1     | 2,5     | Environment, Bullets")
	print("  Enemy           | 3     | 2       | Environment")
	print("  Bullet          | 5     | 1       | Player ONLY ⚡")
	print("  PlayerAttack    | 4     | 3       | Enemies")
	print("")
	print("  Key Optimization: Bullets only mask Layer 1 (Player)")
	print("  This prevents redundant bullet-enemy collision checks!")
	print("")


func _print_optimization_tips() -> void:
	"""Print optimization tips."""
	print("5. Performance Optimization:")
	print("")
	print("  Without layer optimization:")
	print("    Each bullet checks: 500 bullets + 100 enemies + 1 player = 601 entities")
	print("    Total per frame: 500 bullets × 601 = 300,500 checks")
	print("")
	print("  With layer optimization:")
	print("    Each bullet checks: 1 player only = 1 entity")
	print("    Total per frame: 500 bullets × 1 = 500 checks")
	print("")
	print("  Performance gain: 600x fewer collision checks! 🚀")
	print("")


func _to_binary_string(value: int, width: int) -> String:
	"""Convert integer to binary string with zero-padding."""
	var result = ""
	for i in range(width):
		var bit = (value >> (width - 1 - i)) & 1
		result += str(bit)
	return result
