## ControlRebindUI.gd
## PLATFORM-010: Rebindable Controls UI
##
## User interface for rebinding controls

extends Control

## References
@onready var device_label: Label = $Panel/VBoxContainer/DeviceLabel
@onready var bindings_list: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/BindingsList
@onready var rebind_dialog: AcceptDialog = $RebindDialog
@onready var reset_button: Button = $Panel/VBoxContainer/ButtonsContainer/ResetButton
@onready var close_button: Button = $Panel/VBoxContainer/ButtonsContainer/CloseButton

## Input manager reference
var input_manager: InputManager = null

## Currently rebinding action
var rebinding_action: String = ""
var is_waiting_for_input: bool = false

func _ready() -> void:
	# Get InputManager
	if has_node("/root/InputManager"):
		input_manager = get_node("/root/InputManager")
		input_manager.input_device_changed.connect(_on_device_changed)
		input_manager.control_rebinded.connect(_on_control_rebinded)

	# Populate bindings list
	_populate_bindings()
	_update_device_label()

	# Hide by default
	hide()

func _populate_bindings() -> void:
	if input_manager == null:
		return

	# Clear existing entries
	for child in bindings_list.get_children():
		child.queue_free()

	# Group actions by category
	var categories = {
		"Movement": ["move_forward", "move_backward", "move_left", "move_right", "jump", "crouch", "sprint"],
		"Camera": ["look_up", "look_down", "look_left", "look_right"],
		"Combat": ["fire", "aim", "reload", "bullet_time"],
		"Interaction": ["interact"],
		"UI": ["pause", "inventory"],
		"Conspiracy Board": ["board_zoom_in", "board_zoom_out", "board_pan"]
	}

	for category in categories.keys():
		# Add category header
		var header = Label.new()
		header.text = category
		header.add_theme_font_size_override("font_size", 18)
		bindings_list.add_child(header)

		# Add separator
		var separator = HSeparator.new()
		bindings_list.add_child(separator)

		# Add bindings for this category
		for action_name in categories[category]:
			_add_binding_entry(action_name)

		# Add spacing
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 10)
		bindings_list.add_child(spacer)

func _add_binding_entry(action_name: String) -> void:
	if input_manager == null:
		return

	var binding = input_manager.get_binding(action_name)
	if binding == null:
		return

	# Create container
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Action name label
	var name_label = Label.new()
	name_label.text = _format_action_name(action_name)
	name_label.custom_minimum_size = Vector2(200, 0)
	container.add_child(name_label)

	# Binding display label
	var binding_label = Label.new()
	binding_label.text = _get_binding_text(binding)
	binding_label.custom_minimum_size = Vector2(300, 0)
	binding_label.name = "BindingLabel_" + action_name
	container.add_child(binding_label)

	# Rebind button
	var rebind_button = Button.new()
	rebind_button.text = "Rebind"
	rebind_button.pressed.connect(_on_rebind_button_pressed.bind(action_name))
	container.add_child(rebind_button)

	# Reset button
	var reset_btn = Button.new()
	reset_btn.text = "Reset"
	reset_btn.pressed.connect(_on_reset_action_button_pressed.bind(action_name))
	container.add_child(reset_btn)

	bindings_list.add_child(container)

func _format_action_name(action_name: String) -> String:
	# Convert snake_case to Title Case
	return action_name.replace("_", " ").capitalize()

func _get_binding_text(binding: InputManager.ActionBinding) -> String:
	var device = input_manager.get_current_device()

	match device:
		InputManager.DeviceType.KEYBOARD_MOUSE:
			if binding.keyboard_key != -1:
				return OS.get_keycode_string(binding.keyboard_key)
			elif binding.mouse_button != -1:
				return _get_mouse_button_name(binding.mouse_button)
		_:
			# Gamepad
			if binding.gamepad_button != -1:
				return _get_gamepad_button_name(binding.gamepad_button)
			elif binding.gamepad_axis != -1:
				return _get_gamepad_axis_name(binding.gamepad_axis, binding.gamepad_axis_value)

	return "Not bound"

func _get_mouse_button_name(button: int) -> String:
	match button:
		MOUSE_BUTTON_LEFT:
			return "Left Mouse"
		MOUSE_BUTTON_RIGHT:
			return "Right Mouse"
		MOUSE_BUTTON_MIDDLE:
			return "Middle Mouse"
		MOUSE_BUTTON_WHEEL_UP:
			return "Mouse Wheel Up"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "Mouse Wheel Down"
		_:
			return "Mouse Button %d" % button

func _get_gamepad_button_name(button: int) -> String:
	match button:
		JOY_BUTTON_A:
			return "A Button"
		JOY_BUTTON_B:
			return "B Button"
		JOY_BUTTON_X:
			return "X Button"
		JOY_BUTTON_Y:
			return "Y Button"
		JOY_BUTTON_LEFT_SHOULDER:
			return "Left Shoulder"
		JOY_BUTTON_RIGHT_SHOULDER:
			return "Right Shoulder"
		JOY_BUTTON_BACK:
			return "Back"
		JOY_BUTTON_START:
			return "Start"
		JOY_BUTTON_LEFT_STICK:
			return "Left Stick"
		JOY_BUTTON_RIGHT_STICK:
			return "Right Stick"
		JOY_BUTTON_DPAD_UP:
			return "D-Pad Up"
		JOY_BUTTON_DPAD_DOWN:
			return "D-Pad Down"
		JOY_BUTTON_DPAD_LEFT:
			return "D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT:
			return "D-Pad Right"
		_:
			return "Button %d" % button

func _get_gamepad_axis_name(axis: int, value: float) -> String:
	var direction = "+" if value > 0 else "-"
	match axis:
		JOY_AXIS_LEFT_X:
			return "Left Stick X %s" % direction
		JOY_AXIS_LEFT_Y:
			return "Left Stick Y %s" % direction
		JOY_AXIS_RIGHT_X:
			return "Right Stick X %s" % direction
		JOY_AXIS_RIGHT_Y:
			return "Right Stick Y %s" % direction
		JOY_AXIS_TRIGGER_LEFT:
			return "Left Trigger"
		JOY_AXIS_TRIGGER_RIGHT:
			return "Right Trigger"
		_:
			return "Axis %d %s" % [axis, direction]

func _update_device_label() -> void:
	if input_manager == null:
		return

	device_label.text = "Current Device: " + input_manager.get_device_name()

func _on_device_changed(_device_type: InputManager.DeviceType) -> void:
	_update_device_label()
	_populate_bindings()

func _on_control_rebinded(action_name: String) -> void:
	# Update the binding label
	var label = bindings_list.get_node_or_null("BindingLabel_" + action_name)
	if label:
		var binding = input_manager.get_binding(action_name)
		label.text = _get_binding_text(binding)

func _on_rebind_button_pressed(action_name: String) -> void:
	rebinding_action = action_name
	is_waiting_for_input = true
	rebind_dialog.popup_centered()

func _on_reset_action_button_pressed(action_name: String) -> void:
	if input_manager:
		input_manager.reset_binding(action_name)

func _on_reset_button_pressed() -> void:
	if input_manager:
		input_manager.reset_all_bindings()
		_populate_bindings()

func _on_close_button_pressed() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if not is_waiting_for_input:
		return

	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if input_manager.rebind_action(rebinding_action, event):
			is_waiting_for_input = false
			rebind_dialog.hide()
			_populate_bindings()

func show_ui() -> void:
	show()
	_populate_bindings()
