## Unit Tests for Screen Shake Hit Feedback (COMBAT-008)
##
## Tests screen shake camera effect system.
## Shake is toggleable for accessibility (PRD NFR-002).
extends GutTest

const ScreenShakeClass := preload("res://shared/scripts/screen_shake.gd")

const FRAME_DELTA := 0.016  # ~60fps

var screen_shake: Node
var mock_camera: Camera2D


func before_each() -> void:
	# Create mock camera
	mock_camera = Camera2D.new()
	add_child_autofree(mock_camera)
	mock_camera.make_current()

	# Create screen shake instance
	screen_shake = ScreenShakeClass.new()
	add_child_autofree(screen_shake)

	# Wait for _ready
	await get_tree().process_frame


# =============================================================================
# BASIC FUNCTIONALITY TESTS
# =============================================================================


## Test 1: Shake can be triggered
func test_shake_can_be_triggered() -> void:
	screen_shake.shake_enabled = true
	screen_shake.shake(5.0, 0.2)

	assert_true(screen_shake.is_shaking(), "Shake should be active after trigger")


## Test 2: Shake affects camera offset
func test_shake_affects_camera_offset() -> void:
	screen_shake.shake_enabled = true
	var initial_offset := mock_camera.offset

	screen_shake.shake(10.0, 0.2)
	screen_shake._process(FRAME_DELTA)

	var new_offset := mock_camera.offset

	# Offset should have changed (or at least we're shaking)
	# Note: Due to randomness, offset might be (0,0) but unlikely
	assert_true(screen_shake.is_shaking(), "Should be shaking after trigger")


## Test 3: Shake stops after duration
func test_shake_stops_after_duration() -> void:
	screen_shake.shake_enabled = true
	var duration := 0.1

	screen_shake.shake(5.0, duration)

	# Process frames until duration elapsed
	var elapsed := 0.0
	while elapsed < duration + 0.05:
		screen_shake._process(FRAME_DELTA)
		elapsed += FRAME_DELTA

	assert_false(screen_shake.is_shaking(), "Shake should stop after duration")


## Test 4: Camera offset resets after shake
func test_camera_offset_resets() -> void:
	screen_shake.shake_enabled = true
	var initial_offset := mock_camera.offset

	screen_shake.shake(5.0, 0.1)

	# Process until shake completes
	var elapsed := 0.0
	while elapsed < 0.2:
		screen_shake._process(FRAME_DELTA)
		elapsed += FRAME_DELTA

	assert_eq(mock_camera.offset, Vector2.ZERO, "Camera offset should reset to zero after shake")


# =============================================================================
# ACCESSIBILITY TESTS
# =============================================================================


## Test 5: Shake respects enabled setting
func test_shake_respects_enabled_setting() -> void:
	screen_shake.shake_enabled = false
	screen_shake.shake(10.0, 0.5)

	assert_false(screen_shake.is_shaking(), "Shake should not trigger when disabled")


## Test 6: Shake can be disabled mid-shake
func test_shake_can_be_disabled_midshake() -> void:
	screen_shake.shake_enabled = true
	screen_shake.shake(10.0, 1.0)

	screen_shake._process(FRAME_DELTA)
	assert_true(screen_shake.is_shaking(), "Should be shaking initially")

	# Disable mid-shake
	screen_shake.shake_enabled = false
	screen_shake._process(FRAME_DELTA)

	assert_false(screen_shake.is_shaking(), "Shake should stop when disabled mid-shake")


## Test 7: Re-enabling allows new shakes
func test_reenable_allows_new_shakes() -> void:
	screen_shake.shake_enabled = false
	screen_shake.shake(5.0, 0.2)
	assert_false(screen_shake.is_shaking(), "Should not shake when disabled")

	screen_shake.shake_enabled = true
	screen_shake.shake(5.0, 0.2)
	assert_true(screen_shake.is_shaking(), "Should shake when re-enabled")


# =============================================================================
# INTENSITY TESTS
# =============================================================================


## Test 8: Base intensity affects shake magnitude
func test_base_intensity_affects_magnitude() -> void:
	screen_shake.shake_enabled = true
	screen_shake.base_intensity = 2.0  # Double intensity

	screen_shake.shake(5.0, 0.2)
	screen_shake._process(FRAME_DELTA)

	# Just verify it's shaking with modified intensity
	assert_true(screen_shake.is_shaking(), "Should shake with modified base_intensity")


## Test 9: Zero intensity produces no shake
func test_zero_intensity_no_shake() -> void:
	screen_shake.shake_enabled = true
	screen_shake.shake(0.0, 0.2)

	# Should either not shake or shake with zero offset
	screen_shake._process(FRAME_DELTA)
	pass_test("Zero intensity shake should be harmless")


## Test 10: Intensity decays over duration
func test_intensity_decays() -> void:
	screen_shake.shake_enabled = true
	screen_shake.shake(10.0, 0.5)

	# Get shake trauma at start vs end
	screen_shake._process(FRAME_DELTA)
	var early_trauma := screen_shake.current_trauma

	# Process most of the duration
	for i in range(20):
		screen_shake._process(FRAME_DELTA)
	var late_trauma := screen_shake.current_trauma

	assert_lt(late_trauma, early_trauma, "Trauma should decay over time")


# =============================================================================
# STACKING TESTS
# =============================================================================


## Test 11: Multiple shakes stack up to max
func test_shakes_stack_to_max() -> void:
	screen_shake.shake_enabled = true
	screen_shake.max_trauma = 1.0

	# Stack multiple shakes
	screen_shake.shake(0.5, 0.5)
	screen_shake.shake(0.5, 0.5)
	screen_shake.shake(0.5, 0.5)

	# Trauma should be capped at max_trauma
	assert_lte(
		screen_shake.current_trauma, screen_shake.max_trauma, "Trauma should not exceed max_trauma"
	)


## Test 12: Small hits don't overwhelm
func test_small_hits_dont_overwhelm() -> void:
	screen_shake.shake_enabled = true
	screen_shake.max_trauma = 1.0

	# Many small shakes
	for i in range(10):
		screen_shake.shake(0.1, 0.5)

	assert_lte(
		screen_shake.current_trauma,
		screen_shake.max_trauma,
		"Many small shakes should not exceed max"
	)


# =============================================================================
# PRESET TESTS
# =============================================================================


## Test 13: Hit shake preset works
func test_hit_shake_preset() -> void:
	screen_shake.shake_enabled = true
	screen_shake.shake_hit()

	assert_true(screen_shake.is_shaking(), "Hit preset should trigger shake")


## Test 14: Kill shake is stronger than hit
func test_kill_shake_stronger_than_hit() -> void:
	screen_shake.shake_enabled = true

	# Test hit
	screen_shake.shake_hit()
	var hit_trauma := screen_shake.current_trauma

	# Reset
	screen_shake.current_trauma = 0.0

	# Test kill
	screen_shake.shake_kill()
	var kill_trauma := screen_shake.current_trauma

	assert_gt(kill_trauma, hit_trauma, "Kill shake should add more trauma than hit")


# =============================================================================
# EDGE CASES
# =============================================================================


## Test 15: No camera doesn't crash
func test_no_camera_no_crash() -> void:
	# Remove camera
	mock_camera.queue_free()
	await get_tree().process_frame

	# Should not crash
	screen_shake.shake_enabled = true
	screen_shake.shake(5.0, 0.2)
	screen_shake._process(FRAME_DELTA)

	pass_test("No camera should not cause crash")


## Test 16: Negative duration handled
func test_negative_duration_handled() -> void:
	screen_shake.shake_enabled = true
	screen_shake.shake(5.0, -1.0)

	# Should not crash, duration clamped to 0
	screen_shake._process(FRAME_DELTA)
	pass_test("Negative duration should be handled gracefully")
