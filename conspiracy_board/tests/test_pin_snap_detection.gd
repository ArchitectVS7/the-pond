## test_pin_snap_detection.gd
## Unit tests for BOARD-007 pin snap detection functionality
## Tests snap distance threshold, animation, and nearest pin selection

extends GutTest

const ConspiracyBoard = preload("res://conspiracy_board/scripts/conspiracy_board.gd")
const DataLogCard = preload("res://conspiracy_board/scripts/data_log_card.gd")

var board: ConspiracyBoard
var card: DataLogCard


func before_each() -> void:
	# Create board instance
	board = ConspiracyBoard.new()
	add_child_autofree(board)

	# Set up default pin positions
	board.pin_positions = [
		Vector2(200, 200),
		Vector2(500, 200),
		Vector2(800, 200)
	]
	board.snap_distance = 50.0
	board.snap_animation_duration = 0.1

	# Create test card
	card = DataLogCard.new()
	board.add_card(card)

	await get_tree().process_frame


func after_each() -> void:
	if card and is_instance_valid(card):
		card.queue_free()
	if board and is_instance_valid(board):
		board.queue_free()


## Test: Card snaps to pin when within 49px threshold (BOARD-007)
func test_snap_within_threshold() -> void:
	# Arrange - Place card 49px away from first pin (200, 200)
	var pin_position := Vector2(200, 200)
	var card_position := Vector2(249, 200)  # 49px to the right
	card.global_position = card_position

	# Act - Trigger drag end (simulates user dropping card)
	board._on_card_drag_ended(card)

	# Wait for snap animation to complete
	await get_tree().create_timer(board.snap_animation_duration + 0.05).timeout

	# Assert - Card should have snapped to pin position
	assert_almost_eq(
		card.global_position.x,
		pin_position.x,
		1.0,
		"Card should snap to pin X position within 1px"
	)
	assert_almost_eq(
		card.global_position.y,
		pin_position.y,
		1.0,
		"Card should snap to pin Y position within 1px"
	)


## Test: Card does NOT snap when beyond 51px threshold (BOARD-007)
func test_no_snap_beyond_threshold() -> void:
	# Arrange - Place card 51px away from first pin (200, 200)
	var original_position := Vector2(251, 200)  # 51px to the right
	card.global_position = original_position

	# Act - Trigger drag end
	board._on_card_drag_ended(card)

	# Wait a bit to ensure no animation is running
	await get_tree().create_timer(board.snap_animation_duration + 0.05).timeout

	# Assert - Card should stay at original position (no snap)
	assert_almost_eq(
		card.global_position.x,
		original_position.x,
		1.0,
		"Card should stay at original X position (no snap)"
	)
	assert_almost_eq(
		card.global_position.y,
		original_position.y,
		1.0,
		"Card should stay at original Y position (no snap)"
	)


## Test: Card snaps to NEAREST pin when multiple pins are in range (BOARD-007)
func test_snap_to_nearest() -> void:
	# Arrange - Place card between two pins, closer to the second pin
	# Pin 1: (200, 200)
	# Pin 2: (500, 200)
	# Card: (480, 200) - 280px from pin1, 20px from pin2
	var closest_pin := Vector2(500, 200)
	var card_position := Vector2(480, 200)
	card.global_position = card_position

	# Act - Trigger drag end
	board._on_card_drag_ended(card)

	# Wait for snap animation
	await get_tree().create_timer(board.snap_animation_duration + 0.05).timeout

	# Assert - Card should snap to the NEAREST pin (pin 2)
	assert_almost_eq(
		card.global_position.x,
		closest_pin.x,
		1.0,
		"Card should snap to nearest pin X position"
	)
	assert_almost_eq(
		card.global_position.y,
		closest_pin.y,
		1.0,
		"Card should snap to nearest pin Y position"
	)


## Test: get_nearest_pin returns correct pin (BOARD-007 utility function)
func test_get_nearest_pin_utility() -> void:
	# Test position near first pin
	var test_pos1 := Vector2(210, 210)  # Near (200, 200)
	var nearest1 := board.get_nearest_pin(test_pos1)
	assert_eq(nearest1, Vector2(200, 200), "Should return first pin")

	# Test position near second pin
	var test_pos2 := Vector2(495, 195)  # Near (500, 200)
	var nearest2 := board.get_nearest_pin(test_pos2)
	assert_eq(nearest2, Vector2(500, 200), "Should return second pin")

	# Test position near third pin
	var test_pos3 := Vector2(805, 205)  # Near (800, 200)
	var nearest3 := board.get_nearest_pin(test_pos3)
	assert_eq(nearest3, Vector2(800, 200), "Should return third pin")


## Test: is_within_snap_distance returns correct boolean (BOARD-007 utility)
func test_is_within_snap_distance_utility() -> void:
	# Within snap distance
	assert_true(
		board.is_within_snap_distance(Vector2(230, 200)),
		"Position 30px from pin should be within snap distance"
	)

	# Exactly at snap distance
	assert_true(
		board.is_within_snap_distance(Vector2(250, 200)),
		"Position exactly 50px from pin should be within snap distance"
	)

	# Beyond snap distance
	assert_false(
		board.is_within_snap_distance(Vector2(260, 200)),
		"Position 60px from pin should NOT be within snap distance"
	)

	# Far away from all pins
	assert_false(
		board.is_within_snap_distance(Vector2(1000, 1000)),
		"Position far from all pins should NOT be within snap distance"
	)


## Test: Snap animation has correct duration (BOARD-007)
func test_snap_animation_duration() -> void:
	# Arrange
	var pin_position := Vector2(200, 200)
	card.global_position = Vector2(230, 200)  # 30px away
	var start_time := Time.get_ticks_msec()

	# Act - Trigger snap
	board._on_card_drag_ended(card)

	# Wait for animation
	await get_tree().create_timer(board.snap_animation_duration + 0.05).timeout
	var end_time := Time.get_ticks_msec()
	var duration_ms := end_time - start_time

	# Assert - Animation should complete in approximately the configured duration
	# Allow 50ms tolerance for frame timing
	var expected_ms := board.snap_animation_duration * 1000.0
	assert_almost_eq(
		duration_ms,
		expected_ms,
		80.0,  # 80ms tolerance
		"Snap animation should complete in configured duration"
	)

	# Card should be at pin position after animation
	assert_almost_eq(
		card.global_position.distance_to(pin_position),
		0.0,
		1.0,
		"Card should be at pin position after animation"
	)


## Test: Configurable snap_distance parameter (BOARD-007 tunable parameter)
func test_configurable_snap_distance() -> void:
	# Test with 30px snap distance
	board.snap_distance = 30.0
	card.global_position = Vector2(225, 200)  # 25px from pin

	board._on_card_drag_ended(card)
	await get_tree().create_timer(board.snap_animation_duration + 0.05).timeout

	# Should snap at 25px with 30px threshold
	assert_almost_eq(
		card.global_position.x,
		200.0,
		1.0,
		"Card should snap with 30px threshold"
	)

	# Reset position and test beyond new threshold
	card.global_position = Vector2(235, 200)  # 35px from pin
	board._on_card_drag_ended(card)
	await get_tree().create_timer(board.snap_animation_duration + 0.05).timeout

	# Should NOT snap at 35px with 30px threshold
	assert_almost_eq(
		card.global_position.x,
		235.0,
		1.0,
		"Card should NOT snap beyond 30px threshold"
	)


## Test: add_card connects drag_ended signal properly (BOARD-007 integration)
func test_add_card_connects_signal() -> void:
	# Create new card
	var new_card := DataLogCard.new()

	# Add via add_card method (should auto-connect signal)
	board.add_card(new_card)

	# Verify signal is connected
	assert_true(
		new_card.drag_ended.is_connected(board._on_card_drag_ended),
		"add_card should connect drag_ended signal"
	)

	# Test snap works on new card
	new_card.global_position = Vector2(220, 200)
	board._on_card_drag_ended(new_card)
	await get_tree().create_timer(board.snap_animation_duration + 0.05).timeout

	assert_almost_eq(
		new_card.global_position.x,
		200.0,
		1.0,
		"Newly added card should snap correctly"
	)

	new_card.queue_free()
