extends Node2D

# BulletPatternTest - Tests basic bullet patterns for BULLET-003
# This script validates radial, spiral, and aimed patterns

@onready var spawner = $TestSpawner
var spawning_node: Node

# Tunable parameters (BULLET-003)
@export var bullets_per_radial: int = 8
@export var spiral_rotation_speed: float = 180.0  # Degrees per second (30° per spawn)
@export var bullet_speed: float = 200.0

var test_mode: int = 0
var spawn_timer: float = 0.0
const SPAWN_INTERVAL = 2.0

func _ready():
	print("BulletPatternTest: Initializing pattern tests...")

	# Verify Spawning autoload is available
	if has_node("/root/Spawning"):
		spawning_node = get_node("/root/Spawning")
		print("✓ Spawning autoload detected")

		# Register basic bullet properties
		var bullet_props = {
			"__ID__": "basic_bullet",
			"speed": bullet_speed,
			"scale": 1.0,
			"angle": 0.0,
			"anim_idle_texture": "0",
			"anim_idle_collision": "0",
			"death_after_time": 5.0,
			"death_from_collision": true
		}
		spawning_node.new_bullet("basic_bullet", bullet_props)
		print("✓ Basic bullet registered")

		# Register patterns
		_register_patterns()

		print("BulletPatternTest: Ready to test patterns")
		print("  Mode 0: Radial 8-way")
		print("  Mode 1: Spiral clockwise")
		print("  Mode 2: Aimed single")
		print("  Press SPACE to cycle modes, ENTER to spawn")
	else:
		push_error("✗ Spawning autoload not found - plugin may not be enabled")

func _register_patterns():
	# Load pattern resources
	var radial_pattern = load("res://combat/resources/bullet_patterns/radial_8way.tres")
	var spiral_pattern = load("res://combat/resources/bullet_patterns/spiral_clockwise.tres")
	var aimed_pattern = load("res://combat/resources/bullet_patterns/aimed_single.tres")

	if radial_pattern:
		radial_pattern.nbr = bullets_per_radial
		radial_pattern.bullet = "basic_bullet"
		spawning_node.new_pattern("radial_8way", radial_pattern)
		print("✓ Radial pattern registered (", bullets_per_radial, " bullets)")

	if spiral_pattern:
		# Convert degrees per second to radians per spawn
		var angle_offset_radians = deg_to_rad(spiral_rotation_speed * SPAWN_INTERVAL)
		spiral_pattern.layer_angle_offset = angle_offset_radians
		spiral_pattern.bullet = "basic_bullet"
		spawning_node.new_pattern("spiral_clockwise", spiral_pattern)
		print("✓ Spiral pattern registered (", spiral_rotation_speed, "°/sec)")

	if aimed_pattern:
		aimed_pattern.bullet = "basic_bullet"
		spawning_node.new_pattern("aimed_single", aimed_pattern)
		print("✓ Aimed pattern registered")

func _process(delta):
	# Auto-spawn for demonstration
	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		_spawn_current_pattern()

func _spawn_current_pattern():
	if spawning_node == null:
		return

	match test_mode:
		0:
			spawning_node.spawn(spawner, "radial_8way")
			print("Spawned radial_8way pattern")
		1:
			spawning_node.spawn(spawner, "spiral_clockwise")
			print("Spawned spiral_clockwise pattern")
		2:
			spawning_node.spawn(spawner, "aimed_single")
			print("Spawned aimed_single pattern")

func _input(event):
	if event.is_action_pressed("ui_accept"):  # ENTER
		_spawn_current_pattern()

	if event.is_action_pressed("ui_select"):  # SPACE
		test_mode = (test_mode + 1) % 3
		print("Switched to mode ", test_mode)
		match test_mode:
			0: print("  Testing: Radial 8-way")
			1: print("  Testing: Spiral clockwise")
			2: print("  Testing: Aimed single")

	if event.is_action_pressed("ui_cancel"):  # ESC
		get_tree().change_scene_to_file("res://combat/scenes/TestArena.tscn")
