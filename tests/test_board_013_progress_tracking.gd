## test_board_013_progress_tracking.gd
## Unit tests for BOARD-013: Progress tracking UI (X of 7 discovered)
extends GutTest

var board: ConspiracyBoard
var cards: Array[DataLogCard] = []


func before_each() -> void:
	# Create test board
	board = autofree(ConspiracyBoard.new())
	add_child_autofree(board)

	# Create 7 test cards (matching progress_total)
	for i in range(7):
		var card := autofree(DataLogCard.new())
		var data := DataLogResource.new(
			"test-%03d" % i,
			"Test Log %d" % i,
			"Summary %d" % i,
			"Full text %d" % i,
			false  # Start undiscovered
		)
		card.data = data
		cards.append(card)
		board.add_card(card)

	# Wait for ready
	await get_tree().process_frame


func test_progress_total_default() -> void:
	assert_eq(board.progress_total, 7, "Default progress_total should be 7")


func test_initial_discovered_count() -> void:
	assert_eq(board.discovered_count, 0, "Initial discovered count should be 0")


func test_progress_label_initial_text() -> void:
	if board.progress_label:
		assert_eq(board.progress_label.text, "0 of 7 discovered",
			"Initial progress label should show 0 of 7")


func test_discover_one_card() -> void:
	# Discover first card
	cards[0].set_discovered(true)

	await get_tree().process_frame

	assert_eq(board.discovered_count, 1, "Discovered count should be 1")

	if board.progress_label:
		assert_eq(board.progress_label.text, "1 of 7 discovered",
			"Progress label should update to 1 of 7")


func test_discover_multiple_cards() -> void:
	# Discover 3 cards
	for i in range(3):
		cards[i].set_discovered(true)
		await get_tree().process_frame

	assert_eq(board.discovered_count, 3, "Discovered count should be 3")

	if board.progress_label:
		assert_eq(board.progress_label.text, "3 of 7 discovered",
			"Progress label should update to 3 of 7")


func test_discover_all_cards() -> void:
	# Discover all 7 cards
	for card in cards:
		card.set_discovered(true)
		await get_tree().process_frame

	assert_eq(board.discovered_count, 7, "Discovered count should be 7")

	if board.progress_label:
		assert_eq(board.progress_label.text, "7 of 7 discovered",
			"Progress label should show completion")


func test_undiscover_card() -> void:
	# Discover then undiscover
	cards[0].set_discovered(true)
	await get_tree().process_frame

	assert_eq(board.discovered_count, 1, "Count should be 1 after discovery")

	cards[0].set_discovered(false)
	await get_tree().process_frame

	assert_eq(board.discovered_count, 0, "Count should return to 0 after undiscovery")

	if board.progress_label:
		assert_eq(board.progress_label.text, "0 of 7 discovered",
			"Progress label should return to 0 of 7")


func test_discovery_changed_signal() -> void:
	# Watch for signal on card
	watch_signals(cards[0])

	# Discover card
	cards[0].set_discovered(true)

	await get_tree().process_frame

	assert_signal_emitted(cards[0], "discovery_changed",
		"discovery_changed signal should be emitted")

	assert_signal_emit_count(cards[0], "discovery_changed", 1,
		"Signal should be emitted exactly once")


func test_tunable_progress_total() -> void:
	# Change progress total
	board.progress_total = 10
	board._update_progress_display()

	await get_tree().process_frame

	if board.progress_label:
		assert_eq(board.progress_label.text, "0 of 10 discovered",
			"Progress label should respect tunable progress_total")
