## test_board_012_toggle_text.gd
## Unit tests for BOARD-012: TL;DR/Full text toggle
extends GutTest

var viewer: DocumentViewer
var test_data: DataLogResource


func before_each() -> void:
	# Create test viewer
	viewer = autofree(DocumentViewer.new())
	add_child_autofree(viewer)

	# Create test data with distinct summary and full text
	test_data = DataLogResource.new(
		"test-001",
		"Test Document",
		"Short summary here",
		"This is much longer full text content that contains more details and information than the summary.",
		true
	)

	# Show viewer
	viewer.show_document(test_data)

	# Wait for ready
	await get_tree().process_frame


func test_starts_with_summary() -> void:
	assert_eq(viewer.content_label.text, "Short summary here",
		"Viewer should start showing summary")
	assert_false(viewer.showing_full_text, "showing_full_text state should be false")
	assert_eq(viewer.toggle_button.text, "Show Full Text",
		"Toggle button should say 'Show Full Text'")


func test_toggle_to_full_text() -> void:
	# Press toggle button
	viewer._on_toggle_mode_button_pressed()

	await get_tree().process_frame

	assert_true(viewer.showing_full_text, "showing_full_text state should be true")
	assert_eq(viewer.content_label.text, test_data.full_text,
		"Content should show full text")
	assert_eq(viewer.toggle_button.text, "Show Summary",
		"Toggle button should say 'Show Summary'")


func test_toggle_back_to_summary() -> void:
	# Toggle to full text
	viewer._on_toggle_mode_button_pressed()
	await get_tree().process_frame

	# Toggle back
	viewer._on_toggle_mode_button_pressed()
	await get_tree().process_frame

	assert_false(viewer.showing_full_text, "showing_full_text state should be false")
	assert_eq(viewer.content_label.text, "Short summary here",
		"Content should show summary again")
	assert_eq(viewer.toggle_button.text, "Show Full Text",
		"Toggle button should say 'Show Full Text' again")


func test_toggle_state_persists_during_session() -> void:
	# Toggle to full text
	viewer._on_toggle_mode_button_pressed()
	await get_tree().process_frame

	assert_true(viewer.showing_full_text, "State should persist")

	# State remains until viewer is closed or different document shown
	# (Session persistence is within the viewer lifetime)


func test_toggle_resets_on_new_document() -> void:
	# Toggle to full text
	viewer._on_toggle_mode_button_pressed()
	await get_tree().process_frame

	assert_true(viewer.showing_full_text, "Should be showing full text")

	# Show different document
	var other_data := DataLogResource.new(
		"test-002",
		"Other Doc",
		"Other summary",
		"Other full text",
		true
	)

	viewer.show_document(other_data)
	await get_tree().process_frame

	assert_false(viewer.showing_full_text, "State should reset to summary for new document")
	assert_eq(viewer.content_label.text, "Other summary",
		"Should show summary of new document")


func test_multiple_toggles() -> void:
	# Rapidly toggle multiple times
	for i in range(5):
		viewer._on_toggle_mode_button_pressed()
		await get_tree().process_frame

	# Should end on full text (odd number of toggles)
	assert_true(viewer.showing_full_text, "Should end on full text after 5 toggles")

	# One more toggle
	viewer._on_toggle_mode_button_pressed()
	await get_tree().process_frame

	assert_false(viewer.showing_full_text, "Should be back to summary after 6 toggles")
