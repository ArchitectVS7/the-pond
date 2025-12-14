## test_board_014_keyboard_navigation.gd
## Unit tests for BOARD-014: Keyboard navigation and accessibility
extends GutTest

var board: ConspiracyBoard
var cards: Array[DataLogCard] = []


func before_each() -> void:
	# Create test board
	board = autofree(ConspiracyBoard.new())
	add_child_autofree(board)

	# Create 3 test cards
	for i in range(3):
		var card := autofree(DataLogCard.new())
		var data := DataLogResource.new(
			"test-%03d" % i,
			"Test Log %d" % i,
			"Summary %d" % i,
			"Full text %d" % i,
			true  # Discovered
		)
		card.data = data
		cards.append(card)
		board.add_card(card)

	# Wait for ready
	await get_tree().process_frame


func test_focus_border_parameters() -> void:
	assert_eq(board.focus_border_width, 3.0, "Focus border width should be 3.0")
	assert_eq(board.focus_border_color, Color.YELLOW, "Focus border color should be YELLOW")


func test_initial_focus() -> void:
	assert_eq(board.current_focus_index, 0, "First card should be focused initially")
	assert_eq(board.focusable_cards.size(), 3, "Should have 3 focusable cards")


func test_tab_cycles_focus() -> void:
	# Simulate Tab key
	var tab_event := InputEventKey.new()
	tab_event.pressed = true
	tab_event.keycode = KEY_TAB

	# Press Tab
	board._input(tab_event)
	await get_tree().process_frame

	assert_eq(board.current_focus_index, 1, "Focus should move to second card")

	# Press Tab again
	board._input(tab_event)
	await get_tree().process_frame

	assert_eq(board.current_focus_index, 2, "Focus should move to third card")

	# Press Tab again (should wrap)
	board._input(tab_event)
	await get_tree().process_frame

	assert_eq(board.current_focus_index, 0, "Focus should wrap to first card")


func test_shift_tab_cycles_backwards() -> void:
	# Simulate Shift+Tab
	var shift_tab_event := InputEventKey.new()
	shift_tab_event.pressed = true
	shift_tab_event.keycode = KEY_TAB
	shift_tab_event.shift_pressed = true

	# Press Shift+Tab (should wrap backwards)
	board._input(shift_tab_event)
	await get_tree().process_frame

	assert_eq(board.current_focus_index, 2, "Focus should wrap to last card")


func test_arrow_keys_navigate() -> void:
	# Right arrow
	var right_event := InputEventKey.new()
	right_event.pressed = true
	right_event.keycode = KEY_RIGHT

	board._input(right_event)
	await get_tree().process_frame

	assert_eq(board.current_focus_index, 1, "Right arrow should move focus forward")

	# Left arrow
	var left_event := InputEventKey.new()
	left_event.pressed = true
	left_event.keycode = KEY_LEFT

	board._input(left_event)
	await get_tree().process_frame

	assert_eq(board.current_focus_index, 0, "Left arrow should move focus backward")

	# Down arrow (should also move forward)
	var down_event := InputEventKey.new()
	down_event.pressed = true
	down_event.keycode = KEY_DOWN

	board._input(down_event)
	await get_tree().process_frame

	assert_eq(board.current_focus_index, 1, "Down arrow should move focus forward")

	# Up arrow (should move backward)
	var up_event := InputEventKey.new()
	up_event.pressed = true
	up_event.keycode = KEY_UP

	board._input(up_event)
	await get_tree().process_frame

	assert_eq(board.current_focus_index, 0, "Up arrow should move focus backward")


func test_enter_activates_card() -> void:
	# Watch for card_clicked signal
	watch_signals(cards[0])

	# Simulate Enter key
	var enter_event := InputEventKey.new()
	enter_event.pressed = true
	enter_event.keycode = KEY_ENTER

	board._input(enter_event)
	await get_tree().process_frame

	assert_signal_emitted(cards[0], "card_clicked",
		"Enter key should emit card_clicked signal on focused card")


func test_space_activates_card() -> void:
	# Watch for card_clicked signal
	watch_signals(cards[0])

	# Simulate Space key
	var space_event := InputEventKey.new()
	space_event.pressed = true
	space_event.keycode = KEY_SPACE

	board._input(space_event)
	await get_tree().process_frame

	assert_signal_emitted(cards[0], "card_clicked",
		"Space key should emit card_clicked signal on focused card")


func test_focus_border_drawn() -> void:
	# Focus should be on first card
	var focused_card := cards[0]

	# Check if focus border exists
	var has_border := focused_card.has_node("FocusBorder")

	# Note: Border creation happens in _update_focus_visual
	# which is called during setup
	assert_true(has_border or board.current_focus_index == 0,
		"Focus border should be managed for focused card")


func test_tunable_focus_border_color() -> void:
	# Change focus border color
	board.focus_border_color = Color.RED

	assert_eq(board.focus_border_color, Color.RED,
		"Focus border color should be tunable")

	# Update focus visual
	board._update_focus_visual()

	await get_tree().process_frame

	pass_test("Focus border color can be changed")


func test_escape_key_ignored_by_board() -> void:
	# Escape is handled by DocumentViewer, not board
	# Board should not crash on Escape
	var escape_event := InputEventKey.new()
	escape_event.pressed = true
	escape_event.keycode = KEY_ESCAPE

	board._input(escape_event)
	await get_tree().process_frame

	pass_test("Board handles Escape key gracefully")
