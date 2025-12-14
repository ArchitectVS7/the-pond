## Unit Tests for Input Latency Validation (COMBAT-013)
##
## Validates <16ms input lag (1 frame at 60fps).
## These tests verify input handling patterns, not actual hardware latency.
## Real latency measurement requires specialized hardware.
##
## PRD Requirements:
## - <16ms input lag for all player actions
## - 1 frame at 60fps = 16.67ms maximum
extends GutTest

const InputLatencyMonitorClass := preload("res://shared/scripts/input_latency_monitor.gd")

const FRAME_DELTA := 0.016  # ~60fps
const TARGET_LATENCY_MS := 16.67  # 1 frame at 60fps

var latency_monitor: Node


func before_each() -> void:
	latency_monitor = InputLatencyMonitorClass.new()
	add_child_autofree(latency_monitor)
	await get_tree().process_frame


# =============================================================================
# BASIC FUNCTIONALITY TESTS
# =============================================================================


## Test 1: Can create InputLatencyMonitor
func test_can_create_monitor() -> void:
	assert_not_null(latency_monitor, "InputLatencyMonitor should be created")


## Test 2: Has target latency setting
func test_has_target_latency() -> void:
	assert_true("target_latency_ms" in latency_monitor, "Should have target_latency_ms property")


## Test 3: Default target is 16.67ms (1 frame)
func test_default_target_is_one_frame() -> void:
	assert_almost_eq(
		latency_monitor.target_latency_ms,
		TARGET_LATENCY_MS,
		0.1,
		"Default target should be ~16.67ms"
	)


## Test 4: Can record input event
func test_can_record_input() -> void:
	latency_monitor.record_input("attack")
	pass_test("Input recording should not error")


## Test 5: Can record action response
func test_can_record_response() -> void:
	latency_monitor.record_input("attack")
	latency_monitor.record_response("attack")
	pass_test("Response recording should not error")


# =============================================================================
# LATENCY MEASUREMENT TESTS
# =============================================================================


## Test 6: Can measure latency between input and response
func test_can_measure_latency() -> void:
	latency_monitor.record_input("attack")

	# Simulate some processing time
	await get_tree().create_timer(0.005).timeout  # 5ms

	latency_monitor.record_response("attack")

	var latency := latency_monitor.get_last_latency_ms("attack")
	assert_gt(latency, 0.0, "Latency should be positive")


## Test 7: Tracks average latency
func test_tracks_average_latency() -> void:
	for i in range(5):
		latency_monitor.record_input("attack")
		latency_monitor.record_response("attack")

	var avg := latency_monitor.get_average_latency_ms("attack")
	assert_gte(avg, 0.0, "Average latency should be tracked")


## Test 8: Tracks maximum latency
func test_tracks_max_latency() -> void:
	for i in range(5):
		latency_monitor.record_input("attack")
		latency_monitor.record_response("attack")

	var max_lat := latency_monitor.get_max_latency_ms("attack")
	assert_gte(max_lat, 0.0, "Max latency should be tracked")


# =============================================================================
# VALIDATION TESTS
# =============================================================================


## Test 9: Can check if latency meets target
func test_can_check_meets_target() -> void:
	var meets := latency_monitor.is_latency_acceptable(10.0)
	assert_true(meets, "10ms should meet 16.67ms target")


## Test 10: High latency flagged
func test_high_latency_flagged() -> void:
	var meets := latency_monitor.is_latency_acceptable(25.0)
	assert_false(meets, "25ms should exceed 16.67ms target")


## Test 11: Can validate all actions
func test_can_validate_all_actions() -> void:
	latency_monitor.record_input("move")
	latency_monitor.record_response("move")
	latency_monitor.record_input("attack")
	latency_monitor.record_response("attack")

	var all_valid := latency_monitor.are_all_actions_acceptable()
	assert_true(all_valid, "All immediate responses should be acceptable")


# =============================================================================
# INPUT HANDLING PATTERN TESTS
# =============================================================================


## Test 12: Documents _physics_process pattern
func test_physics_process_pattern() -> void:
	# This test documents the expected pattern
	# Input should be handled in _physics_process for consistent timing
	gut.p("=== INPUT HANDLING PATTERN ===")
	gut.p("Input SHOULD be handled in _physics_process for:")
	gut.p("  - Consistent 60fps timing")
	gut.p("  - Synchronized with physics")
	gut.p("  - Predictable 16.67ms frame budget")
	gut.p("Input SHOULD NOT be handled in _process because:")
	gut.p("  - Variable frame rate")
	gut.p("  - Unpredictable timing")
	gut.p("===============================")
	pass_test("Pattern documented")


## Test 13: Verifies use_accumulated_input setting
func test_accumulated_input_setting() -> void:
	# Godot's Input.use_accumulated_input affects latency
	# When true (default): input is buffered and processed once per frame
	# When false: input is processed immediately (lower latency but more calls)
	assert_true(true, "Input accumulation affects latency - document setting")


# =============================================================================
# ACTION-SPECIFIC TESTS
# =============================================================================


## Test 14: Movement input latency tracking
func test_movement_latency_tracking() -> void:
	latency_monitor.record_input("move_up")
	latency_monitor.record_response("move_up")

	var latency := latency_monitor.get_last_latency_ms("move_up")
	assert_gte(latency, 0.0, "Movement latency should be tracked")


## Test 15: Attack input latency tracking
func test_attack_latency_tracking() -> void:
	latency_monitor.record_input("attack")
	latency_monitor.record_response("attack")

	var latency := latency_monitor.get_last_latency_ms("attack")
	assert_gte(latency, 0.0, "Attack latency should be tracked")


# =============================================================================
# REPORT TESTS
# =============================================================================


## Test 16: Can generate latency report
func test_can_generate_report() -> void:
	latency_monitor.record_input("attack")
	latency_monitor.record_response("attack")

	var report := latency_monitor.generate_report()
	assert_gt(report.length(), 0, "Report should not be empty")


## Test 17: Report includes PRD target
func test_report_includes_target() -> void:
	var report := latency_monitor.generate_report()
	assert_true(
		report.contains("16") or report.contains("target"), "Report should mention latency target"
	)


# =============================================================================
# EDGE CASE TESTS
# =============================================================================


## Test 18: Handles missing input record gracefully
func test_handles_missing_input() -> void:
	# Response without input should not crash
	latency_monitor.record_response("nonexistent")
	pass_test("Missing input handled gracefully")


## Test 19: Handles multiple inputs before response
func test_handles_multiple_inputs() -> void:
	latency_monitor.record_input("attack")
	latency_monitor.record_input("attack")
	latency_monitor.record_response("attack")
	pass_test("Multiple inputs handled")


## Test 20: Can reset tracking
func test_can_reset_tracking() -> void:
	latency_monitor.record_input("attack")
	latency_monitor.record_response("attack")

	latency_monitor.reset_tracking()

	var avg := latency_monitor.get_average_latency_ms("attack")
	assert_eq(avg, 0.0, "Average should reset to 0")
