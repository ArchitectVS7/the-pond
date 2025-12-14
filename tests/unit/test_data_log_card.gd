## test_data_log_card.gd
## Unit tests for DataLogCard component
## Tests BOARD-005 (data-log-card-component) and BOARD-006 (drag-drop-interaction-system)

extends GutTest

var card: DataLogCard
var data_resource: DataLogResource


func before_each() -> void:
	# Create a test card instance
	card = DataLogCard.new()
	add_child_autofree(card)

	# Create test data
	data_resource = DataLogResource.new(
		"test_001",
		"Test Document",
		"This is a test summary for preview",
		"Full text content goes here with more details",
		true  # discovered
	)


func after_each() -> void:
	card = null
	data_resource = null


## BOARD-005 Tests: Card Display

func test_card_displays_title() -> void:
	card.set_data(data_resource)
	await wait_frames(2)  # Wait for _ready and display update

	assert_not_null(card.title_label, "Title label should exist")
	assert_eq(card.title_label.text, "Test Document", "Title should match data")


func test_card_shows_preview() -> void:
	card.set_data(data_resource)
	await wait_frames(2)

	assert_not_null(card.preview_label, "Preview label should exist")
	var preview_text = card.preview_label.text
	assert_true(preview_text.length() <= card.preview_max_chars,
		"Preview should be truncated to max chars")


func test_card_discovered_state() -> void:
	# Test discovered state
	data_resource.discovered = true
	card.set_data(data_resource)
	await wait_frames(2)

	assert_eq(card.modulate.a, 1.0, "Discovered card should be fully opaque")

	# Test undiscovered state
	data_resource.discovered = false
	card.set_data(data_resource)
	await wait_frames(2)

	assert_eq(card.modulate.a, card.undiscovered_alpha,
		"Undiscovered card should have reduced alpha")


func test_card_dimensions() -> void:
	await wait_frames(2)

	assert_eq(card.size.x, card.card_width, "Card width should match setting")
	assert_eq(card.size.y, card.card_height, "Card height should match setting")


## BOARD-006 Tests: Drag-Drop Interaction

func test_card_drag_starts() -> void:
	card.set_data(data_resource)
	card.position = Vector2(100, 100)
	await wait_frames(2)

	# Track if drag_started signal was emitted
	var signal_watcher = watch_signals(card)

	# Simulate mouse press
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	press_event.global_position = Vector2(150, 150)
	card._on_gui_input(press_event)

	# Simulate movement beyond threshold
	var motion_event = InputEventMouseMotion.new()
	motion_event.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion_event.global_position = Vector2(160, 160)  # 14.14px distance > threshold
	card._on_gui_input(motion_event)

	assert_true(card._is_dragging, "Card should be in dragging state")
	assert_signal_emitted(card, "drag_started", "drag_started signal should emit")


func test_card_follows_mouse() -> void:
	card.set_data(data_resource)
	card.position = Vector2(100, 100)
	await wait_frames(2)

	# Start drag
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	press_event.global_position = Vector2(110, 110)
	card._on_gui_input(press_event)

	# Move past threshold to activate drag
	var motion_event1 = InputEventMouseMotion.new()
	motion_event1.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion_event1.global_position = Vector2(120, 120)
	card._on_gui_input(motion_event1)

	# Continue dragging
	var motion_event2 = InputEventMouseMotion.new()
	motion_event2.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion_event2.global_position = Vector2(200, 200)
	card._on_gui_input(motion_event2)

	# Position should track the mouse (accounting for drag offset)
	assert_true(card._is_dragging, "Card should be dragging")
	# The exact position depends on drag_offset, but it should have moved
	assert_ne(card.position, Vector2(100, 100), "Card position should have changed")


func test_card_drops() -> void:
	card.set_data(data_resource)
	card.position = Vector2(100, 100)
	await wait_frames(2)

	# Track signals
	var signal_watcher = watch_signals(card)

	# Start drag
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	press_event.global_position = Vector2(110, 110)
	card._on_gui_input(press_event)

	# Move to trigger drag
	var motion_event = InputEventMouseMotion.new()
	motion_event.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion_event.global_position = Vector2(120, 120)
	card._on_gui_input(motion_event)

	# Release mouse
	var release_event = InputEventMouseButton.new()
	release_event.button_index = MOUSE_BUTTON_LEFT
	release_event.pressed = false
	release_event.global_position = Vector2(120, 120)
	card._on_gui_input(release_event)

	assert_false(card._is_dragging, "Card should not be dragging after release")
	assert_signal_emitted(card, "drag_ended", "drag_ended signal should emit")


func test_card_z_order() -> void:
	card.set_data(data_resource)
	await wait_frames(2)

	var original_z = card.z_index

	# Start drag
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	press_event.global_position = Vector2(110, 110)
	card._on_gui_input(press_event)

	# Move to activate drag
	var motion_event = InputEventMouseMotion.new()
	motion_event.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion_event.global_position = Vector2(120, 120)
	card._on_gui_input(motion_event)

	assert_eq(card.z_index, 100, "Dragged card should be at z-index 100 (on top)")

	# End drag
	var release_event = InputEventMouseButton.new()
	release_event.button_index = MOUSE_BUTTON_LEFT
	release_event.pressed = false
	card._on_gui_input(release_event)

	assert_eq(card.z_index, original_z, "Z-index should restore after drag")


func test_drag_threshold() -> void:
	card.set_data(data_resource)
	card.drag_threshold = 10.0
	await wait_frames(2)

	# Start potential drag
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	press_event.global_position = Vector2(100, 100)
	card._on_gui_input(press_event)

	# Move slightly (under threshold)
	var motion_event1 = InputEventMouseMotion.new()
	motion_event1.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion_event1.global_position = Vector2(105, 105)  # 7.07px distance < 10.0
	card._on_gui_input(motion_event1)

	assert_false(card._is_dragging, "Should not drag when under threshold")

	# Move beyond threshold
	var motion_event2 = InputEventMouseMotion.new()
	motion_event2.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion_event2.global_position = Vector2(112, 112)  # 16.97px > 10.0
	card._on_gui_input(motion_event2)

	assert_true(card._is_dragging, "Should drag when beyond threshold")


func test_drag_opacity_change() -> void:
	card.set_data(data_resource)
	card.drag_opacity = 0.5
	data_resource.discovered = true
	await wait_frames(2)

	assert_eq(card.modulate.a, 1.0, "Initial opacity should be 1.0")

	# Start drag
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	press_event.global_position = Vector2(110, 110)
	card._on_gui_input(press_event)

	# Move to activate drag
	var motion_event = InputEventMouseMotion.new()
	motion_event.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion_event.global_position = Vector2(120, 120)
	card._on_gui_input(motion_event)

	assert_eq(card.modulate.a, 0.5, "Opacity should change to drag_opacity during drag")

	# End drag
	var release_event = InputEventMouseButton.new()
	release_event.button_index = MOUSE_BUTTON_LEFT
	release_event.pressed = false
	card._on_gui_input(release_event)

	assert_eq(card.modulate.a, 1.0, "Opacity should restore after drag")


func test_click_vs_drag_distinction() -> void:
	card.set_data(data_resource)
	await wait_frames(2)

	var signal_watcher = watch_signals(card)

	# Simulate a click (press and release without moving)
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	press_event.global_position = Vector2(110, 110)
	card._on_gui_input(press_event)

	var release_event = InputEventMouseButton.new()
	release_event.button_index = MOUSE_BUTTON_LEFT
	release_event.pressed = false
	release_event.global_position = Vector2(110, 110)
	card._on_gui_input(release_event)

	assert_signal_emitted(card, "card_clicked", "Should emit card_clicked on click")
	assert_signal_not_emitted(card, "drag_started", "Should not emit drag_started on click")
	assert_signal_not_emitted(card, "drag_ended", "Should not emit drag_ended on click")


## BOARD-005 Additional Tests

func test_preview_truncation() -> void:
	var long_text = "A".repeat(200)
	data_resource.summary = long_text
	card.preview_max_chars = 50
	card.set_data(data_resource)
	await wait_frames(2)

	var preview = data_resource.get_preview(card.preview_max_chars)
	assert_true(preview.length() <= card.preview_max_chars,
		"Preview should be truncated")
	assert_true(preview.ends_with("..."), "Truncated preview should end with ...")


func test_discovery_signal() -> void:
	data_resource.discovered = false
	card.set_data(data_resource)
	await wait_frames(2)

	var signal_watcher = watch_signals(card)

	card.set_discovered(true)

	assert_signal_emitted(card, "discovery_changed",
		"discovery_changed signal should emit when state changes")


func test_card_id_retrieval() -> void:
	card.set_data(data_resource)
	await wait_frames(2)

	assert_eq(card.get_data_id(), "test_001", "Should return correct data ID")
