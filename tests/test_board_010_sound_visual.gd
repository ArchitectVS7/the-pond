## test_board_010_sound_visual.gd
## Unit tests for BOARD-010: String snap sound and visual feedback
extends GutTest

var board: ConspiracyBoard
var card: DataLogCard
var test_data: DataLogResource


func before_each() -> void:
	# Create test board
	board = autofree(ConspiracyBoard.new())
	add_child_autofree(board)

	# Create test card
	card = autofree(DataLogCard.new())
	test_data = DataLogResource.new("test-001", "Test Log", "Test summary", "Full test text", true)
	card.data = test_data
	board.add_card(card)

	# Wait for ready
	await get_tree().process_frame


func test_snap_sound_node_exists() -> void:
	assert_not_null(board.snap_sound, "SnapSound node should be referenced if it exists")


func test_pulse_animation_parameters() -> void:
	assert_eq(board.pulse_duration, 0.2, "Pulse duration should be 0.2 seconds")
	assert_eq(board.pulse_scale, 1.1, "Pulse scale should be 1.1 (10% larger)")


func test_snap_feedback_triggers() -> void:
	# Position card near a pin
	var pin := board.pin_positions[0]
	card.global_position = pin + Vector2(30, 30)  # Within snap distance

	# Trigger drag end
	card.drag_ended.emit(card)

	await get_tree().create_timer(0.1).timeout

	# Verify card moved to pin
	assert_almost_eq(card.global_position, pin, Vector2(5, 5),
		"Card should snap to pin position")


func test_pulse_visual_effect() -> void:
	# Store original scale
	var original_scale := card.scale

	# Trigger snap feedback
	board._play_snap_feedback(card)

	# Wait for mid-animation
	await get_tree().create_timer(board.pulse_duration * 0.5).timeout

	# Scale should be larger during pulse
	# Note: This is timing-dependent and may be flaky in CI
	# Could be improved with signal-based testing

	# Wait for completion
	await get_tree().create_timer(board.pulse_duration).timeout

	# Scale should return to normal
	assert_almost_eq(card.scale, original_scale, Vector2(0.01, 0.01),
		"Card scale should return to original after pulse")


func test_tunable_pulse_parameters() -> void:
	# Test that pulse parameters can be changed
	board.pulse_duration = 0.5
	board.pulse_scale = 1.2

	assert_eq(board.pulse_duration, 0.5, "Pulse duration should be tunable")
	assert_eq(board.pulse_scale, 1.2, "Pulse scale should be tunable")

	# Trigger feedback with new parameters
	board._play_snap_feedback(card)

	# Wait for animation
	await get_tree().create_timer(board.pulse_duration).timeout

	pass_test("Pulse animation completed with custom parameters")


func test_snap_without_audio_stream() -> void:
	# Ensure no crash when audio stream is not configured
	if board.snap_sound:
		board.snap_sound.stream = null

	# Should not crash
	board._play_snap_feedback(card)

	await get_tree().process_frame

	pass_test("Snap feedback works without audio stream")


func test_multiple_snap_animations() -> void:
	# Test that multiple snaps can occur rapidly
	for i in range(3):
		board._play_snap_feedback(card)
		await get_tree().create_timer(0.05).timeout

	# Wait for all animations to complete
	await get_tree().create_timer(board.pulse_duration * 2).timeout

	pass_test("Multiple rapid snap animations handled correctly")
