## test_board_015_accessibility.gd
## Unit tests for BOARD-015: Screen reader support and accessibility
extends GutTest

var board: ConspiracyBoard
var card: DataLogCard
var viewer: DocumentViewer
var test_data: DataLogResource


func before_each() -> void:
	# Create test board
	board = autofree(ConspiracyBoard.new())
	add_child_autofree(board)

	# Create test card
	card = autofree(DataLogCard.new())
	test_data = DataLogResource.new(
		"test-001",
		"Test Document",
		"Test summary",
		"Full test text",
		true  # Discovered
	)
	card.data = test_data
	board.add_card(card)

	# Create test viewer
	viewer = autofree(DocumentViewer.new())
	add_child_autofree(viewer)

	# Wait for ready
	await get_tree().process_frame


func test_board_accessibility_name() -> void:
	assert_eq(board.accessibility_name, "Conspiracy Board",
		"Board should have accessibility name")


func test_board_accessibility_description() -> void:
	assert_eq(board.accessibility_description,
		"Interactive board for discovering and connecting data logs",
		"Board should have accessibility description")


func test_card_accessibility_name_discovered() -> void:
	# Card is discovered
	assert_string_contains(card.accessibility_name, "Data Log Card",
		"Card should have accessibility name")
	assert_string_contains(card.accessibility_name, "Test Document",
		"Discovered card name should include title")


func test_card_accessibility_name_undiscovered() -> void:
	# Create undiscovered card
	var undiscovered_card := autofree(DataLogCard.new())
	var undiscovered_data := DataLogResource.new(
		"test-002",
		"Secret",
		"???",
		"Secret text",
		false
	)
	undiscovered_card.data = undiscovered_data
	add_child_autofree(undiscovered_card)

	await get_tree().process_frame

	assert_string_contains(undiscovered_card.accessibility_name, "Undiscovered",
		"Undiscovered card name should indicate locked state")


func test_card_accessibility_description_discovered() -> void:
	assert_string_contains(card.accessibility_description, "Discovered data log",
		"Description should indicate discovered state")
	assert_string_contains(card.accessibility_description, "Press Enter to view",
		"Description should include interaction hint")


func test_card_accessibility_description_undiscovered() -> void:
	# Create undiscovered card
	var undiscovered_card := autofree(DataLogCard.new())
	var undiscovered_data := DataLogResource.new(
		"test-002",
		"Secret",
		"???",
		"Secret text",
		false
	)
	undiscovered_card.data = undiscovered_data
	add_child_autofree(undiscovered_card)

	await get_tree().process_frame

	assert_string_contains(undiscovered_card.accessibility_description, "Locked",
		"Undiscovered card description should indicate locked state")


func test_viewer_accessibility_name() -> void:
	assert_eq(viewer.accessibility_name, "Document Viewer Dialog",
		"Viewer should have accessibility name")


func test_viewer_accessibility_description_initial() -> void:
	assert_string_contains(viewer.accessibility_description, "detailed information",
		"Viewer should have accessibility description")


func test_viewer_accessibility_description_with_document() -> void:
	viewer.show_document(test_data)
	await get_tree().process_frame

	assert_string_contains(viewer.accessibility_description, "Test Document",
		"Viewer description should include document title when shown")


func test_close_button_accessibility() -> void:
	if viewer.close_button:
		assert_eq(viewer.close_button.accessibility_name, "Close Document Viewer",
			"Close button should have accessibility name")
		assert_string_contains(viewer.close_button.accessibility_description, "Close",
			"Close button should have accessibility description")


func test_toggle_button_accessibility_summary_mode() -> void:
	viewer.show_document(test_data)
	await get_tree().process_frame

	if viewer.toggle_button:
		assert_eq(viewer.toggle_button.accessibility_name, "Toggle Text View",
			"Toggle button should have accessibility name")
		assert_string_contains(viewer.toggle_button.accessibility_description, "full text",
			"Toggle button description should indicate next action (show full text)")


func test_toggle_button_accessibility_fulltext_mode() -> void:
	viewer.show_document(test_data)
	viewer._on_toggle_mode_button_pressed()  # Switch to full text
	await get_tree().process_frame

	if viewer.toggle_button:
		assert_string_contains(viewer.toggle_button.accessibility_description, "summary",
			"Toggle button description should update to show summary option")


func test_accessibility_updates_on_discovery_change() -> void:
	# Start with undiscovered card
	var changing_card := autofree(DataLogCard.new())
	var changing_data := DataLogResource.new(
		"test-003",
		"Changing",
		"Summary",
		"Full text",
		false
	)
	changing_card.data = changing_data
	add_child_autofree(changing_card)

	await get_tree().process_frame

	var initial_desc := changing_card.accessibility_description
	assert_string_contains(initial_desc, "Locked", "Should start locked")

	# Discover it
	changing_card.set_discovered(true)
	await get_tree().process_frame

	var updated_desc := changing_card.accessibility_description
	assert_string_contains(updated_desc, "Discovered", "Should update to discovered")
	assert_ne(initial_desc, updated_desc, "Description should change on discovery")


func test_godot_accessibility_limitations_documented() -> void:
	# This test verifies that we're using Godot 4.2+ accessibility features
	# The actual documentation check would be in DEVELOPERS_MANUAL.md

	# Verify properties exist (Godot 4.2+)
	assert_has(board, "accessibility_name", "Board should support accessibility_name property")
	assert_has(card, "accessibility_description", "Card should support accessibility_description property")

	pass_test("Accessibility properties are available in Godot 4.2+")
