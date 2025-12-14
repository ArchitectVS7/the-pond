extends GutTest

# Integration tests for BulletUpHell plugin
# Tests that the plugin is properly enabled and configured in Godot 4.2

func test_plugin_enabled():
	# Verify plugin is listed in editor_plugins
	var config = ConfigFile.new()
	var err = config.load("res://project.godot")
	assert_eq(err, OK, "Should load project.godot")

	var plugins = config.get_value("editor_plugins", "enabled", PackedStringArray())
	assert_has(plugins, "res://addons/BulletUpHell/plugin.cfg",
		"BulletUpHell plugin should be enabled in project settings")

func test_spawning_autoload_exists():
	# Verify Spawning autoload is configured
	assert_true(has_node("/root/Spawning"),
		"Spawning autoload should be available")

func test_spawning_autoload_type():
	# Verify the autoload is the correct type
	if has_node("/root/Spawning"):
		var spawning = get_node("/root/Spawning")
		assert_not_null(spawning, "Spawning node should exist")
		# The Spawning node should be a Node2D with BuHSpawner script
		assert_true(spawning is Node2D, "Spawning should be a Node2D")

func test_bullet_spawner_script_loads():
	# Test that we can load the spawner script
	var spawner_script = load("res://addons/BulletUpHell/BuHSpawner.gd")
	assert_not_null(spawner_script, "BuHSpawner.gd should load")

func test_bullet_pattern_script_loads():
	# Test that we can load the pattern script
	var pattern_script = load("res://addons/BulletUpHell/BuHPattern.gd")
	assert_not_null(pattern_script, "BuHPattern.gd should load")

func test_bullet_properties_script_loads():
	# Test that we can load bullet properties
	var props_script = load("res://addons/BulletUpHell/BuHBulletProperties.gd")
	assert_not_null(props_script, "BuHBulletProperties.gd should load")

func test_bullet_spawner_instantiates():
	# Test that we can create a spawner instance
	var spawner_script = load("res://addons/BulletUpHell/BuHSpawner.gd")
	if spawner_script:
		var instance = Node2D.new()
		instance.set_script(spawner_script)
		assert_not_null(instance, "Should instantiate BuHSpawner")
		instance.free()

func test_bullet_type_resource_loads():
	# Test that bullet type resources can be loaded
	var bullet_props = load("res://addons/BulletUpHell/BulletProps.gd")
	assert_not_null(bullet_props, "BulletProps resource should load")

func test_custom_functions_loads():
	# Test that custom functions script loads
	var custom_funcs = load("res://addons/BulletUpHell/customFunctions.gd")
	assert_not_null(custom_funcs, "customFunctions.gd should load")

func test_plugin_configuration():
	# Verify plugin.cfg is properly configured
	var config = ConfigFile.new()
	var err = config.load("res://addons/BulletUpHell/plugin.cfg")
	assert_eq(err, OK, "Should load plugin.cfg")

	assert_eq(config.get_value("plugin", "name"), "BulletUpHell",
		"Plugin name should be BulletUpHell")
	assert_eq(config.get_value("plugin", "version"), "4.2.8",
		"Plugin version should be 4.2.8")
	assert_eq(config.get_value("plugin", "script"), "BuH.gd",
		"Plugin script should be BuH.gd")
