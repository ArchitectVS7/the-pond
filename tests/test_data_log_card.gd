## test_data_log_card.gd
## Unit tests for DataLogCard component
## Tests card display, discovery states, and visual updates

extends GutTest

var card_scene = preload("res://conspiracy_board/scenes/DataLogCard.tscn")
var card: DataLogCard
var test_data: DataLogResource


func before_each() -> void:
	# Create test data log resource
	test_data = DataLogResource.new()
	test_data.id = "test_log_001"
	test_data.title = "Test Data Log"
	test_data.summary = "This is a test summary that should be displayed in the preview area of the card."
	test_data.full_text = "This is the full text content of the test data log. It contains detailed information."
	test_data.discovered = false

	# Instantiate card
	card = card_scene.instantiate()
	add_child_autofree(card)


func after_each() -> void:
	if is_instance_valid(card) and card.get_parent():
		card.queue_free()


## Test: Card displays title correctly when discovered
func test_card_displays_title() -> void:
	card.data = test_data
	card.set_discovered(true)
	await wait_frames(1)

	assert_eq(card.title_label.text, "Test Data Log", "Card should display correct title")


## Test: Undiscovered card hides title
func test_card_hides_title_when_undiscovered() -> void:
	card.data = test_data
	card.set_discovered(false)
	await wait_frames(1)

	assert_eq(card.title_label.text, "???", "Undiscovered card should show '???'")


## Test: Card shows preview text when discovered
func test_card_shows_preview() -> void:
	card.data = test_data
	card.set_discovered(true)
	await wait_frames(1)

	var preview = card.preview_label.text
	assert_true(preview.length() > 0, "Preview should not be empty")
	assert_true(preview.begins_with("This is a test summary"), "Preview should contain summary text")


## Test: Preview text is truncated based on max chars
func test_card_truncates_preview() -> void:
	# Create long summary
	var long_summary = "A".repeat(200)
	test_data.summary = long_summary

	card.preview_max_chars = 50
	card.data = test_data
	card.set_discovered(true)
	await wait_frames(1)

	var preview = card.preview_label.text
	assert_true(preview.length() <= 53, "Preview should be truncated (50 + '...')") # 50 chars + "..."


## Test: Undiscovered card shows locked preview
func test_card_shows_locked_when_undiscovered() -> void:
	card.data = test_data
	card.set_discovered(false)
	await wait_frames(1)

	assert_eq(card.preview_label.text, "[LOCKED]", "Undiscovered card should show [LOCKED]")


## Test: Card visual changes on discovery
func test_card_discovered_state() -> void:
	card.data = test_data
	card.set_discovered(false)
	await wait_frames(1)

	var undiscovered_alpha = card.modulate.a

	card.set_discovered(true)
	await wait_frames(1)

	var discovered_alpha = card.modulate.a

	assert_gt(discovered_alpha, undiscovered_alpha, "Discovered card should be more opaque")


## Test: Discovery changed signal is emitted
func test_card_emits_discovery_signal() -> void:
	watch_signals(card)

	card.data = test_data
	card.set_discovered(true)
	await wait_frames(1)

	assert_signal_emitted(card, "discovery_changed", "Should emit discovery_changed signal")


## Test: Card size matches tunable parameters
func test_card_size_parameters() -> void:
	card.card_width = 300
	card.card_height = 200
	await wait_frames(1)

	assert_eq(card.custom_minimum_size.x, 300, "Card width should match parameter")
	assert_eq(card.custom_minimum_size.y, 200, "Card height should match parameter")


## Test: Card returns correct data ID
func test_card_returns_data_id() -> void:
	card.data = test_data

	assert_eq(card.get_data_id(), "test_log_001", "Card should return correct data ID")


## Test: Card returns full text only when discovered
func test_card_returns_full_text_when_discovered() -> void:
	card.data = test_data
	card.set_discovered(false)

	assert_eq(card.get_full_text(), "", "Undiscovered card should return empty string")

	card.set_discovered(true)
	assert_true(card.get_full_text().length() > 0, "Discovered card should return full text")


## Test: Card handles null data gracefully
func test_card_handles_null_data() -> void:
	card.data = null
	await wait_frames(1)

	# Should not crash
	assert_true(true, "Card should handle null data without crashing")


## Test: Card click signal is emitted
func test_card_emits_click_signal() -> void:
	watch_signals(card)

	card.data = test_data
	await wait_frames(1)

	# Simulate mouse click
	var mouse_event = InputEventMouseButton.new()
	mouse_event.button_index = MOUSE_BUTTON_LEFT
	mouse_event.pressed = true
	mouse_event.position = Vector2(10, 10)

	card._on_gui_input(mouse_event)

	assert_signal_emitted(card, "card_clicked", "Should emit card_clicked signal on click")


## Test: Undiscovered alpha affects card opacity
func test_undiscovered_alpha_parameter() -> void:
	card.undiscovered_alpha = 0.5
	card.data = test_data
	card.set_discovered(false)
	await wait_frames(1)

	assert_almost_eq(card.modulate.a, 0.5, 0.01, "Card alpha should match undiscovered_alpha parameter")


## Test: DataLogResource preview truncation
func test_resource_get_preview() -> void:
	var preview = test_data.get_preview(20)

	assert_eq(preview.length(), 20, "Preview should be truncated to max chars")
	assert_true(preview.ends_with("..."), "Truncated preview should end with '...'")


## Test: DataLogResource discover method
func test_resource_discover() -> void:
	assert_false(test_data.discovered, "Should start undiscovered")

	test_data.discover()

	assert_true(test_data.discovered, "Should be discovered after calling discover()")


## Test: DataLogResource connections
func test_resource_connections() -> void:
	test_data.add_connection("entity_001")
	test_data.add_connection("entity_002")

	assert_true(test_data.is_connected_to("entity_001"), "Should be connected to entity_001")
	assert_eq(test_data.connections.size(), 2, "Should have 2 connections")

	test_data.remove_connection("entity_001")

	assert_false(test_data.is_connected_to("entity_001"), "Should not be connected after removal")
	assert_eq(test_data.connections.size(), 1, "Should have 1 connection after removal")
