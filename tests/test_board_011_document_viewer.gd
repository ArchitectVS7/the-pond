## test_board_011_document_viewer.gd
## Unit tests for BOARD-011: Document viewer popup
extends GutTest

var viewer: DocumentViewer
var test_data: DataLogResource


func before_each() -> void:
	# Create test viewer
	viewer = autofree(DocumentViewer.new())
	add_child_autofree(viewer)

	# Create test data
	test_data = DataLogResource.new(
		"test-001",
		"Test Document",
		"This is a test summary",
		"This is the full text content of the test document.",
		true
	)

	# Wait for ready
	await get_tree().process_frame


func test_viewer_dimensions() -> void:
	assert_eq(viewer.viewer_width, 600, "Default viewer width should be 600")
	assert_eq(viewer.viewer_height, 400, "Default viewer height should be 400")

	# Check panel size
	assert_eq(viewer.panel.custom_minimum_size, Vector2(600, 400),
		"Panel should match viewer dimensions")


func test_viewer_starts_hidden() -> void:
	assert_false(viewer.visible, "Viewer should start hidden")
	assert_eq(viewer.modulate.a, 0.0, "Viewer should start transparent")


func test_show_document() -> void:
	# Show document
	viewer.show_document(test_data)

	# Wait for animation to start
	await get_tree().process_frame

	assert_true(viewer.visible, "Viewer should be visible")
	assert_eq(viewer.title_label.text, "Test Document", "Title should match data")
	assert_eq(viewer.content_label.text, "This is a test summary",
		"Content should show summary by default")


func test_show_undiscovered_document() -> void:
	# Create undiscovered data
	var undiscovered := DataLogResource.new("test-002", "Secret", "???", "Secret text", false)

	# Try to show - should not display
	viewer.show_document(undiscovered)

	await get_tree().process_frame

	assert_false(viewer.visible, "Viewer should not show undiscovered documents")


func test_close_button() -> void:
	# Show viewer
	viewer.show_document(test_data)
	await get_tree().process_frame

	# Click close button
	viewer._on_close_button_pressed()

	# Wait for close animation
	await get_tree().create_timer(viewer.animation_duration + 0.1).timeout

	assert_false(viewer.visible, "Viewer should be hidden after close")


func test_click_outside_closes() -> void:
	# Show viewer
	viewer.show_document(test_data)
	await get_tree().process_frame

	# Simulate click on overlay
	var click_event := InputEventMouseButton.new()
	click_event.pressed = true
	click_event.button_index = MOUSE_BUTTON_LEFT
	viewer._on_overlay_gui_input(click_event)

	# Wait for close animation
	await get_tree().create_timer(viewer.animation_duration + 0.1).timeout

	assert_false(viewer.visible, "Clicking outside should close viewer")


func test_open_animation() -> void:
	# Show document
	viewer.show_document(test_data)

	await get_tree().process_frame

	# Should be visible and animating
	assert_true(viewer.visible, "Viewer should be visible during animation")

	# Wait for animation to complete
	await get_tree().create_timer(viewer.animation_duration + 0.1).timeout

	# Should be fully visible
	assert_almost_eq(viewer.modulate.a, 1.0, 0.1, "Viewer should be fully opaque after animation")
	assert_almost_eq(viewer.panel.scale, Vector2.ONE, Vector2(0.01, 0.01),
		"Panel should be at normal scale after animation")


func test_tunable_animation_duration() -> void:
	# Change animation duration
	viewer.animation_duration = 0.5

	assert_eq(viewer.animation_duration, 0.5, "Animation duration should be tunable")


func test_viewer_closed_signal() -> void:
	# Watch for signal
	watch_signals(viewer)

	# Show and close
	viewer.show_document(test_data)
	await get_tree().process_frame

	viewer.close_viewer()

	assert_signal_emitted(viewer, "viewer_closed", "viewer_closed signal should be emitted")
