## test_input.gd
## Unit tests for InputManager (PLATFORM-008, PLATFORM-009, PLATFORM-010)

extends GutTest

var input_manager: InputManager

func before_each():
	input_manager = InputManager.new()
	add_child_autofree(input_manager)
	# Wait for ready
	await get_tree().process_frame

func after_each():
	if input_manager:
		input_manager.queue_free()

## PLATFORM-009: Test XInput controller detection
func test_device_type_detection():
	assert_not_null(input_manager, "InputManager should be instantiated")

	# Default should be keyboard/mouse
	assert_eq(input_manager.get_current_device(), InputManager.DeviceType.KEYBOARD_MOUSE,
		"Default device should be keyboard/mouse")

func test_steam_deck_detection():
	# Test Steam Deck detection logic
	var is_deck = input_manager.is_running_on_steam_deck()
	assert_typeof(is_deck, TYPE_BOOL, "Steam Deck detection should return bool")

func test_device_name_retrieval():
	var device_name = input_manager.get_device_name()
	assert_not_null(device_name, "Device name should not be null")
	assert_ne(device_name, "", "Device name should not be empty")
	assert_typeof(device_name, TYPE_STRING, "Device name should be string")

## PLATFORM-008: Test Steam Deck control mapping
func test_default_bindings_exist():
	# Test that all required bindings exist
	var required_actions = [
		"move_forward", "move_backward", "move_left", "move_right",
		"jump", "crouch", "sprint", "interact",
		"fire", "aim", "reload", "bullet_time",
		"pause", "inventory",
		"board_zoom_in", "board_zoom_out", "board_pan"
	]

	for action in required_actions:
		var binding = input_manager.get_binding(action)
		assert_not_null(binding, "Binding for '%s' should exist" % action)

func test_movement_bindings():
	# Test WASD movement bindings
	assert_eq(input_manager.get_binding("move_forward").keyboard_key, KEY_W,
		"Forward should be W")
	assert_eq(input_manager.get_binding("move_backward").keyboard_key, KEY_S,
		"Backward should be S")
	assert_eq(input_manager.get_binding("move_left").keyboard_key, KEY_A,
		"Left should be A")
	assert_eq(input_manager.get_binding("move_right").keyboard_key, KEY_D,
		"Right should be D")

func test_gamepad_analog_bindings():
	# Test gamepad analog stick bindings
	assert_eq(input_manager.get_binding("move_forward").gamepad_axis, JOY_AXIS_LEFT_Y,
		"Forward should use left stick Y")
	assert_eq(input_manager.get_binding("move_left").gamepad_axis, JOY_AXIS_LEFT_X,
		"Left should use left stick X")

func test_combat_bindings():
	# Test combat action bindings
	assert_eq(input_manager.get_binding("fire").mouse_button, MOUSE_BUTTON_LEFT,
		"Fire should be left mouse")
	assert_eq(input_manager.get_binding("aim").mouse_button, MOUSE_BUTTON_RIGHT,
		"Aim should be right mouse")
	assert_eq(input_manager.get_binding("fire").gamepad_button, JOY_BUTTON_RIGHT_SHOULDER,
		"Fire should be right shoulder on gamepad")

## PLATFORM-010: Test rebindable controls
func test_rebind_keyboard_action():
	# Create a key event
	var event = InputEventKey.new()
	event.keycode = KEY_F

	# Rebind forward to F
	var result = input_manager.rebind_action("move_forward", event)
	assert_true(result, "Rebinding should succeed")
	assert_eq(input_manager.get_binding("move_forward").keyboard_key, KEY_F,
		"Forward should now be F")

func test_rebind_mouse_action():
	# Create a mouse button event
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_MIDDLE

	# Rebind fire to middle mouse
	var result = input_manager.rebind_action("fire", event)
	assert_true(result, "Rebinding should succeed")
	assert_eq(input_manager.get_binding("fire").mouse_button, MOUSE_BUTTON_MIDDLE,
		"Fire should now be middle mouse")

func test_rebind_gamepad_button():
	# Create a gamepad button event
	var event = InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_X

	# Rebind jump to X button
	var result = input_manager.rebind_action("jump", event)
	assert_true(result, "Rebinding should succeed")
	assert_eq(input_manager.get_binding("jump").gamepad_button, JOY_BUTTON_X,
		"Jump should now be X button")

func test_rebind_gamepad_axis():
	# Create a gamepad axis event
	var event = InputEventJoypadMotion.new()
	event.axis = JOY_AXIS_TRIGGER_RIGHT
	event.axis_value = 1.0

	# Rebind fire to right trigger
	var result = input_manager.rebind_action("fire", event)
	assert_true(result, "Rebinding should succeed")
	assert_eq(input_manager.get_binding("fire").gamepad_axis, JOY_AXIS_TRIGGER_RIGHT,
		"Fire should now be right trigger")

func test_reset_single_binding():
	# First rebind
	var event = InputEventKey.new()
	event.keycode = KEY_F
	input_manager.rebind_action("move_forward", event)

	# Then reset
	input_manager.reset_binding("move_forward")

	# Should be back to default (W)
	assert_eq(input_manager.get_binding("move_forward").keyboard_key, KEY_W,
		"Forward should be reset to W")

func test_reset_all_bindings():
	# Rebind multiple actions
	var event1 = InputEventKey.new()
	event1.keycode = KEY_F
	input_manager.rebind_action("move_forward", event1)

	var event2 = InputEventKey.new()
	event2.keycode = KEY_G
	input_manager.rebind_action("move_backward", event2)

	# Reset all
	input_manager.reset_all_bindings()

	# Check defaults are restored
	assert_eq(input_manager.get_binding("move_forward").keyboard_key, KEY_W,
		"Forward should be reset to W")
	assert_eq(input_manager.get_binding("move_backward").keyboard_key, KEY_S,
		"Backward should be reset to S")

func test_rebind_invalid_action():
	var event = InputEventKey.new()
	event.keycode = KEY_F

	var result = input_manager.rebind_action("invalid_action", event)
	assert_false(result, "Rebinding invalid action should fail")

func test_binding_persistence():
	# Note: This test verifies the save/load mechanism exists
	# Actual file I/O testing would require more complex setup

	# Rebind an action
	var event = InputEventKey.new()
	event.keycode = KEY_F
	input_manager.rebind_action("move_forward", event)

	# Verify it was saved (check that binding persists)
	assert_eq(input_manager.get_binding("move_forward").keyboard_key, KEY_F,
		"Binding should persist")

## Test signal emissions
func test_rebind_signal_emission():
	watch_signals(input_manager)

	var event = InputEventKey.new()
	event.keycode = KEY_F
	input_manager.rebind_action("move_forward", event)

	assert_signal_emitted(input_manager, "control_rebinded",
		"control_rebinded signal should be emitted")

func test_device_changed_signal():
	# Note: This would require simulating device connection
	# For now, just verify the signal exists
	assert_has_signal(input_manager, "input_device_changed",
		"input_device_changed signal should exist")

## Integration tests
func test_conspiracy_board_bindings():
	# Verify conspiracy board controls exist (CONSPIRACY-001 integration)
	assert_not_null(input_manager.get_binding("board_zoom_in"),
		"Board zoom in binding should exist")
	assert_not_null(input_manager.get_binding("board_zoom_out"),
		"Board zoom out binding should exist")
	assert_not_null(input_manager.get_binding("board_pan"),
		"Board pan binding should exist")

func test_bullet_time_bindings():
	# Verify bullet time controls exist (BULLET-001, BULLET-002 integration)
	assert_not_null(input_manager.get_binding("bullet_time"),
		"Bullet time binding should exist")
	assert_eq(input_manager.get_binding("bullet_time").keyboard_key, KEY_Q,
		"Bullet time should be Q on keyboard")
	assert_eq(input_manager.get_binding("bullet_time").gamepad_button, JOY_BUTTON_LEFT_STICK,
		"Bullet time should be left stick click on gamepad")

## Performance tests
func test_binding_lookup_performance():
	# Test that binding lookups are fast
	var start_time = Time.get_ticks_usec()

	for i in range(1000):
		var _binding = input_manager.get_binding("move_forward")

	var elapsed = Time.get_ticks_usec() - start_time

	# Should complete 1000 lookups in less than 10ms
	assert_lt(elapsed, 10000, "Binding lookups should be fast (< 10ms for 1000 iterations)")

## Edge cases
func test_binding_with_no_device():
	# Test behavior when no input device is connected
	var binding = input_manager.get_binding("move_forward")
	assert_not_null(binding, "Binding should exist even without device")

func test_multiple_bindings_same_key():
	# Test that rebinding to same key as another action works
	var event = InputEventKey.new()
	event.keycode = KEY_W  # Same as move_forward

	var result = input_manager.rebind_action("jump", event)
	assert_true(result, "Should allow rebinding to same key")
	# Note: Conflict resolution is handled by InputMap layer
