## input_manager.gd
## PLATFORM-008: Steam Deck Control Mapping
## PLATFORM-009: XInput Controller Support
## PLATFORM-010: Rebindable Controls
##
## Comprehensive input management for multiple platforms

extends Node
class_name InputManager

## Input device types
enum DeviceType {
	KEYBOARD_MOUSE,
	GAMEPAD_XBOX,
	GAMEPAD_PS,
	GAMEPAD_NINTENDO,
	STEAM_DECK,
	GENERIC_CONTROLLER
}

## Input action mappings
class ActionBinding:
	var action_name: String
	var keyboard_key: int = -1
	var mouse_button: int = -1
	var gamepad_button: int = -1
	var gamepad_axis: int = -1
	var gamepad_axis_value: float = 0.0

	func _init(p_action_name: String):
		action_name = p_action_name

## Signals
signal input_device_changed(device_type: DeviceType)
signal control_rebinded(action_name: String)
signal gamepad_connected(device_id: int)
signal gamepad_disconnected(device_id: int)

## Current input device
var current_device: DeviceType = DeviceType.KEYBOARD_MOUSE
var last_gamepad_id: int = -1

## Action bindings
var action_bindings: Dictionary = {}
var save_file_path: String = "user://input_bindings.save"

## Steam Deck detection
var is_steam_deck: bool = false

## Default bindings
var default_bindings: Dictionary = {}

func _ready() -> void:
	_detect_platform()
	_setup_default_bindings()
	_load_bindings()
	_setup_input_detection()

## PLATFORM-007: Steam Deck Detection
func _detect_platform() -> void:
	# Check for Steam Deck
	if OS.has_environment("STEAM_DECK"):
		is_steam_deck = true
		current_device = DeviceType.STEAM_DECK
		push_warning("InputManager: Running on Steam Deck")

	# Check for connected gamepads
	var joypads = Input.get_connected_joypads()
	if joypads.size() > 0:
		_detect_gamepad_type(joypads[0])

## PLATFORM-009: Detect XInput controller type
func _detect_gamepad_type(device_id: int) -> void:
	var device_name = Input.get_joy_name(device_id).to_lower()

	if "xbox" in device_name or "xinput" in device_name:
		current_device = DeviceType.GAMEPAD_XBOX
	elif "playstation" in device_name or "dualshock" in device_name or "dualsense" in device_name:
		current_device = DeviceType.GAMEPAD_PS
	elif "nintendo" in device_name or "switch" in device_name:
		current_device = DeviceType.GAMEPAD_NINTENDO
	elif is_steam_deck:
		current_device = DeviceType.STEAM_DECK
	else:
		current_device = DeviceType.GENERIC_CONTROLLER

	last_gamepad_id = device_id
	input_device_changed.emit(current_device)

## Setup input device detection
func _setup_input_detection() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

## Handle gamepad connection changes
func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		_detect_gamepad_type(device_id)
		gamepad_connected.emit(device_id)
	else:
		if device_id == last_gamepad_id:
			current_device = DeviceType.KEYBOARD_MOUSE
			input_device_changed.emit(current_device)
		gamepad_disconnected.emit(device_id)

## PLATFORM-008: Setup default Steam Deck bindings
func _setup_default_bindings() -> void:
	# Movement
	default_bindings["move_forward"] = _create_binding("move_forward", KEY_W, -1, JOY_BUTTON_INVALID, JOY_AXIS_LEFT_Y, -1.0)
	default_bindings["move_backward"] = _create_binding("move_backward", KEY_S, -1, JOY_BUTTON_INVALID, JOY_AXIS_LEFT_Y, 1.0)
	default_bindings["move_left"] = _create_binding("move_left", KEY_A, -1, JOY_BUTTON_INVALID, JOY_AXIS_LEFT_X, -1.0)
	default_bindings["move_right"] = _create_binding("move_right", KEY_D, -1, JOY_BUTTON_INVALID, JOY_AXIS_LEFT_X, 1.0)

	# Camera
	default_bindings["look_up"] = _create_binding("look_up", KEY_UP, -1, JOY_BUTTON_INVALID, JOY_AXIS_RIGHT_Y, -1.0)
	default_bindings["look_down"] = _create_binding("look_down", KEY_DOWN, -1, JOY_BUTTON_INVALID, JOY_AXIS_RIGHT_Y, 1.0)
	default_bindings["look_left"] = _create_binding("look_left", KEY_LEFT, -1, JOY_BUTTON_INVALID, JOY_AXIS_RIGHT_X, -1.0)
	default_bindings["look_right"] = _create_binding("look_right", KEY_RIGHT, -1, JOY_BUTTON_INVALID, JOY_AXIS_RIGHT_X, 1.0)

	# Actions
	default_bindings["jump"] = _create_binding("jump", KEY_SPACE, -1, JOY_BUTTON_A, -1, 0.0)
	default_bindings["crouch"] = _create_binding("crouch", KEY_CTRL, -1, JOY_BUTTON_B, -1, 0.0)
	default_bindings["interact"] = _create_binding("interact", KEY_E, -1, JOY_BUTTON_X, -1, 0.0)
	default_bindings["sprint"] = _create_binding("sprint", KEY_SHIFT, -1, JOY_BUTTON_LEFT_STICK, -1, 0.0)

	# Combat (BULLET-001, BULLET-002 integration)
	default_bindings["fire"] = _create_binding("fire", KEY_NONE, MOUSE_BUTTON_LEFT, JOY_BUTTON_RIGHT_SHOULDER, -1, 0.0)
	default_bindings["aim"] = _create_binding("aim", KEY_NONE, MOUSE_BUTTON_RIGHT, JOY_BUTTON_LEFT_SHOULDER, -1, 0.0)
	default_bindings["reload"] = _create_binding("reload", KEY_R, -1, JOY_BUTTON_Y, -1, 0.0)
	default_bindings["bullet_time"] = _create_binding("bullet_time", KEY_Q, -1, JOY_BUTTON_LEFT_STICK, -1, 0.0)

	# UI
	default_bindings["pause"] = _create_binding("pause", KEY_ESCAPE, -1, JOY_BUTTON_START, -1, 0.0)
	default_bindings["inventory"] = _create_binding("inventory", KEY_TAB, -1, JOY_BUTTON_BACK, -1, 0.0)

	# Conspiracy Board (CONSPIRACY-001 integration)
	default_bindings["board_zoom_in"] = _create_binding("board_zoom_in", KEY_EQUAL, -1, JOY_BUTTON_DPAD_UP, -1, 0.0)
	default_bindings["board_zoom_out"] = _create_binding("board_zoom_out", KEY_MINUS, -1, JOY_BUTTON_DPAD_DOWN, -1, 0.0)
	default_bindings["board_pan"] = _create_binding("board_pan", KEY_NONE, MOUSE_BUTTON_MIDDLE, JOY_BUTTON_RIGHT_STICK, -1, 0.0)

	# Copy defaults to current bindings
	action_bindings = default_bindings.duplicate(true)

## Helper to create binding
func _create_binding(action_name: String, kb_key: int, mouse_btn: int, gp_button: int, gp_axis: int, axis_value: float) -> ActionBinding:
	var binding = ActionBinding.new(action_name)
	binding.keyboard_key = kb_key
	binding.mouse_button = mouse_btn
	binding.gamepad_button = gp_button
	binding.gamepad_axis = gp_axis
	binding.gamepad_axis_value = axis_value
	return binding

## PLATFORM-010: Load custom bindings
func _load_bindings() -> void:
	if not FileAccess.file_exists(save_file_path):
		return

	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		push_error("InputManager: Failed to load bindings")
		return

	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	file.close()

	if parse_result != OK:
		push_error("InputManager: Failed to parse binding data")
		return

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return

	# Restore custom bindings
	for action_name in data.keys():
		if action_bindings.has(action_name):
			var saved_data = data[action_name]
			var binding: ActionBinding = action_bindings[action_name]

			binding.keyboard_key = saved_data.get("keyboard_key", -1)
			binding.mouse_button = saved_data.get("mouse_button", -1)
			binding.gamepad_button = saved_data.get("gamepad_button", -1)
			binding.gamepad_axis = saved_data.get("gamepad_axis", -1)
			binding.gamepad_axis_value = saved_data.get("gamepad_axis_value", 0.0)

## Save custom bindings
func _save_bindings() -> void:
	var data = {}

	for action_name in action_bindings.keys():
		var binding: ActionBinding = action_bindings[action_name]
		data[action_name] = {
			"keyboard_key": binding.keyboard_key,
			"mouse_button": binding.mouse_button,
			"gamepad_button": binding.gamepad_button,
			"gamepad_axis": binding.gamepad_axis,
			"gamepad_axis_value": binding.gamepad_axis_value
		}

	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file == null:
		push_error("InputManager: Failed to save bindings")
		return

	# Godot 4.4+: store_string returns bool indicating success
	if not file.store_string(JSON.stringify(data, "\t")):
		push_error("InputManager: Failed to write input bindings")
		file.close()
		return
	file.close()

## Rebind action
func rebind_action(action_name: String, event: InputEvent) -> bool:
	if not action_bindings.has(action_name):
		push_error("InputManager: Unknown action: %s" % action_name)
		return false

	var binding: ActionBinding = action_bindings[action_name]

	if event is InputEventKey:
		binding.keyboard_key = event.keycode
	elif event is InputEventMouseButton:
		binding.mouse_button = event.button_index
	elif event is InputEventJoypadButton:
		binding.gamepad_button = event.button_index
	elif event is InputEventJoypadMotion:
		binding.gamepad_axis = event.axis
		binding.gamepad_axis_value = sign(event.axis_value)
	else:
		return false

	_save_bindings()
	control_rebinded.emit(action_name)
	return true

## Get binding for action
func get_binding(action_name: String) -> ActionBinding:
	return action_bindings.get(action_name)

## Reset binding to default
func reset_binding(action_name: String) -> void:
	if not default_bindings.has(action_name):
		return

	action_bindings[action_name] = default_bindings[action_name].duplicate()
	_save_bindings()
	control_rebinded.emit(action_name)

## Reset all bindings to defaults
func reset_all_bindings() -> void:
	action_bindings = default_bindings.duplicate(true)
	_save_bindings()

## Get current device type
func get_current_device() -> DeviceType:
	return current_device

## Check if running on Steam Deck
func is_running_on_steam_deck() -> bool:
	return is_steam_deck

## Get device name string
func get_device_name() -> String:
	match current_device:
		DeviceType.KEYBOARD_MOUSE:
			return "Keyboard & Mouse"
		DeviceType.GAMEPAD_XBOX:
			return "Xbox Controller"
		DeviceType.GAMEPAD_PS:
			return "PlayStation Controller"
		DeviceType.GAMEPAD_NINTENDO:
			return "Nintendo Controller"
		DeviceType.STEAM_DECK:
			return "Steam Deck"
		DeviceType.GENERIC_CONTROLLER:
			return "Generic Controller"
		_:
			return "Unknown"
