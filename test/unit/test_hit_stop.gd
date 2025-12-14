## Unit Tests for Hit-Stop System (COMBAT-010)
##
## Tests 2-frame pause feedback on enemy kills.
## PRD Requirement: "Hit-stop: 2-frame pause on enemy kills"
extends GutTest

const HitStopClass := preload("res://shared/scripts/hit_stop.gd")

const FRAME_DELTA := 0.016  # ~60fps (1/60 = 0.01666...)
const TWO_FRAMES := 0.033  # 2/60 = 0.0333...

var hit_stop: Node


func before_each() -> void:
	hit_stop = HitStopClass.new()
	add_child_autofree(hit_stop)
	await get_tree().process_frame


# =============================================================================
# BASIC FUNCTIONALITY TESTS
# =============================================================================


## Test 1: Can trigger hit-stop
func test_can_trigger_hit_stop() -> void:
	hit_stop.trigger_hit_stop()

	assert_true(hit_stop.is_frozen(), "Hit-stop should freeze the game")


## Test 2: Hit-stop has correct default duration (2 frames)
func test_default_duration_is_2_frames() -> void:
	# At 60fps, 2 frames = 2/60 = ~0.033 seconds
	assert_almost_eq(
		hit_stop.default_duration, TWO_FRAMES, 0.01, "Default duration should be ~2 frames at 60fps"
	)


## Test 3: Hit-stop unfreezes after duration
func test_unfreezes_after_duration() -> void:
	hit_stop.trigger_hit_stop()
	assert_true(hit_stop.is_frozen(), "Should be frozen initially")

	# Simulate time passing (3 frames to ensure we're past duration)
	for i in range(4):
		hit_stop._process(FRAME_DELTA)

	assert_false(hit_stop.is_frozen(), "Should unfreeze after duration")


## Test 4: Time scale changes during freeze
func test_time_scale_changes_during_freeze() -> void:
	var original_scale := Engine.time_scale

	hit_stop.trigger_hit_stop()

	# Time scale should be reduced (frozen)
	assert_lt(Engine.time_scale, original_scale, "Time scale should decrease during hit-stop")

	# Cleanup - wait for unfreeze
	for i in range(4):
		hit_stop._process(FRAME_DELTA)


## Test 5: Time scale restores after freeze
func test_time_scale_restores_after_freeze() -> void:
	var original_scale := Engine.time_scale

	hit_stop.trigger_hit_stop()

	# Wait for duration to pass
	for i in range(4):
		hit_stop._process(FRAME_DELTA)

	assert_almost_eq(
		Engine.time_scale, original_scale, 0.01, "Time scale should restore after hit-stop"
	)


# =============================================================================
# DURATION TESTS
# =============================================================================


## Test 6: Custom duration works
func test_custom_duration_works() -> void:
	var custom_duration := 0.1  # 100ms
	hit_stop.trigger_hit_stop(custom_duration)

	# Should still be frozen after 50ms
	for i in range(3):  # ~48ms
		hit_stop._process(FRAME_DELTA)

	assert_true(hit_stop.is_frozen(), "Should still be frozen before custom duration")

	# Should be unfrozen after 100ms
	for i in range(5):  # +80ms = ~128ms total
		hit_stop._process(FRAME_DELTA)

	assert_false(hit_stop.is_frozen(), "Should unfreeze after custom duration")


## Test 7: Zero duration does not freeze
func test_zero_duration_does_not_freeze() -> void:
	hit_stop.trigger_hit_stop(0.0)

	assert_false(hit_stop.is_frozen(), "Zero duration should not freeze")


## Test 8: Negative duration treated as zero
func test_negative_duration_treated_as_zero() -> void:
	hit_stop.trigger_hit_stop(-1.0)

	assert_false(hit_stop.is_frozen(), "Negative duration should not freeze")


# =============================================================================
# ACCESSIBILITY TESTS
# =============================================================================


## Test 9: Can disable hit-stop globally
func test_can_disable_hit_stop() -> void:
	hit_stop.hit_stop_enabled = false
	hit_stop.trigger_hit_stop()

	assert_false(hit_stop.is_frozen(), "Hit-stop should not freeze when disabled")


## Test 10: Re-enabling allows hit-stop again
func test_reenable_allows_hit_stop() -> void:
	hit_stop.hit_stop_enabled = false
	hit_stop.trigger_hit_stop()
	assert_false(hit_stop.is_frozen(), "Should not freeze when disabled")

	hit_stop.hit_stop_enabled = true
	hit_stop.trigger_hit_stop()
	assert_true(hit_stop.is_frozen(), "Should freeze when re-enabled")


# =============================================================================
# STACKING TESTS
# =============================================================================


## Test 11: Multiple triggers extend duration (stacking)
func test_multiple_triggers_stack() -> void:
	hit_stop.trigger_hit_stop()  # 33ms

	# Wait 1 frame
	hit_stop._process(FRAME_DELTA)

	# Trigger again
	hit_stop.trigger_hit_stop()  # Reset to 33ms

	assert_true(hit_stop.is_frozen(), "Should still be frozen after second trigger")


## Test 12: Get remaining freeze time
func test_get_remaining_time() -> void:
	hit_stop.trigger_hit_stop()
	var initial_remaining := hit_stop.get_remaining_time()

	hit_stop._process(FRAME_DELTA)
	var after_one_frame := hit_stop.get_remaining_time()

	assert_gt(initial_remaining, after_one_frame, "Remaining time should decrease")


# =============================================================================
# CONVENIENCE METHODS
# =============================================================================


## Test 13: Kill hit-stop helper (2 frames)
func test_kill_hit_stop_is_2_frames() -> void:
	hit_stop.hit_stop_kill()

	assert_true(hit_stop.is_frozen(), "Kill should trigger freeze")

	# Verify it's approximately 2 frames
	# After 1 frame, still frozen
	hit_stop._process(FRAME_DELTA)
	assert_true(hit_stop.is_frozen(), "Should be frozen after 1 frame")

	# After 3 frames, unfrozen
	hit_stop._process(FRAME_DELTA)
	hit_stop._process(FRAME_DELTA)
	assert_false(hit_stop.is_frozen(), "Should unfreeze after 2+ frames")


## Test 14: Force stop clears freeze
func test_force_stop_clears_freeze() -> void:
	hit_stop.trigger_hit_stop()
	assert_true(hit_stop.is_frozen(), "Should be frozen")

	hit_stop.stop_hit_stop()

	assert_false(hit_stop.is_frozen(), "Force stop should clear freeze")


# =============================================================================
# SIGNAL TESTS
# =============================================================================


## Test 15: Emits freeze_started signal
func test_emits_freeze_started_signal() -> void:
	watch_signals(hit_stop)

	hit_stop.trigger_hit_stop()

	assert_signal_emitted(hit_stop, "freeze_started", "Should emit freeze_started signal")


## Test 16: Emits freeze_ended signal
func test_emits_freeze_ended_signal() -> void:
	watch_signals(hit_stop)

	hit_stop.trigger_hit_stop()

	# Wait for freeze to end
	for i in range(4):
		hit_stop._process(FRAME_DELTA)

	assert_signal_emitted(hit_stop, "freeze_ended", "Should emit freeze_ended signal")


# =============================================================================
# EDGE CASE TESTS
# =============================================================================


## Test 17: Handles very small delta
func test_handles_small_delta() -> void:
	hit_stop.trigger_hit_stop()

	# Very small delta (shouldn't cause issues)
	hit_stop._process(0.001)

	assert_true(hit_stop.is_frozen(), "Should handle small delta without issues")


## Test 18: Handles large delta (frame skip)
func test_handles_large_delta() -> void:
	hit_stop.trigger_hit_stop()

	# Large delta simulating frame skip
	hit_stop._process(0.5)

	assert_false(hit_stop.is_frozen(), "Should unfreeze even with large delta")


## Test 19: Works with custom freeze scale
func test_custom_freeze_scale() -> void:
	hit_stop.freeze_time_scale = 0.1  # Slow-mo instead of full freeze
	hit_stop.trigger_hit_stop()

	assert_almost_eq(Engine.time_scale, 0.1, 0.01, "Should use custom freeze scale")

	# Cleanup
	for i in range(4):
		hit_stop._process(FRAME_DELTA)
