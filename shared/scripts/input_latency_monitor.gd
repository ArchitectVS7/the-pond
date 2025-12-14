## InputLatencyMonitor - Measures input-to-action latency
##
## COMBAT-013: Input lag 16ms validation
## PRD Requirement: <16ms input lag for all player actions
##
## Features:
## - Records input event timestamps
## - Records action response timestamps
## - Calculates per-action latency
## - Tracks min/max/average statistics
## - Validates against PRD target
##
## Architecture Notes:
## - Designed for development/debugging, not production
## - Uses Time.get_ticks_usec() for microsecond precision
## - Can be autoload or instantiated for specific tests
## - Zero overhead when not actively measuring
##
## Usage:
## 1. Call record_input("action") when input is detected
## 2. Call record_response("action") when action executes
## 3. Check latency with get_last_latency_ms("action")
class_name InputLatencyMonitor
extends Node

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when latency exceeds target
signal latency_exceeded(action: String, latency_ms: float, target_ms: float)

## Emitted when latency is recorded
signal latency_recorded(action: String, latency_ms: float)

# =============================================================================
# EXPORTS
# =============================================================================

## Target latency in milliseconds (PRD: <16ms = 1 frame at 60fps)
@export var target_latency_ms: float = 16.67

## Whether to emit warnings for exceeded latency
@export var warn_on_exceed: bool = true

# =============================================================================
# STATE
# =============================================================================

## Pending input timestamps (action -> timestamp_usec)
var _pending_inputs: Dictionary = {}

## Recorded latencies per action (action -> Array[float])
var _latency_history: Dictionary = {}

## Last recorded latency per action (action -> float)
var _last_latency: Dictionary = {}

## Maximum recorded latency per action
var _max_latency: Dictionary = {}

## Minimum recorded latency per action
var _min_latency: Dictionary = {}

## Sum of latencies per action (for averaging)
var _latency_sum: Dictionary = {}

## Count of measurements per action
var _measurement_count: Dictionary = {}

# =============================================================================
# PUBLIC API - RECORDING
# =============================================================================


## Record when an input event is detected
## Call this in _input() or _physics_process() when input is first detected
func record_input(action: String) -> void:
	_pending_inputs[action] = Time.get_ticks_usec()


## Record when the action response occurs
## Call this when the game responds to the input (e.g., attack starts)
func record_response(action: String) -> void:
	if not _pending_inputs.has(action):
		# No pending input for this action - ignore
		return

	var input_time: int = _pending_inputs[action]
	var response_time := Time.get_ticks_usec()
	var latency_us := response_time - input_time
	var latency_ms := latency_us / 1000.0

	# Clear pending input
	_pending_inputs.erase(action)

	# Record latency
	_record_latency(action, latency_ms)


## Record a known latency value directly (for testing)
func record_latency(action: String, latency_ms: float) -> void:
	_record_latency(action, latency_ms)


# =============================================================================
# PUBLIC API - QUERY
# =============================================================================


## Get last recorded latency for an action
func get_last_latency_ms(action: String) -> float:
	return _last_latency.get(action, 0.0)


## Get average latency for an action
func get_average_latency_ms(action: String) -> float:
	var count: int = _measurement_count.get(action, 0)
	if count == 0:
		return 0.0
	return _latency_sum.get(action, 0.0) / count


## Get maximum latency for an action
func get_max_latency_ms(action: String) -> float:
	return _max_latency.get(action, 0.0)


## Get minimum latency for an action
func get_min_latency_ms(action: String) -> float:
	return _min_latency.get(action, 0.0)


## Get measurement count for an action
func get_measurement_count(action: String) -> int:
	return _measurement_count.get(action, 0)


## Get all tracked actions
func get_tracked_actions() -> Array:
	return _measurement_count.keys()


# =============================================================================
# PUBLIC API - VALIDATION
# =============================================================================


## Check if a latency value meets the target
func is_latency_acceptable(latency_ms: float) -> bool:
	return latency_ms <= target_latency_ms


## Check if an action's average latency is acceptable
func is_action_acceptable(action: String) -> bool:
	var avg := get_average_latency_ms(action)
	return avg <= target_latency_ms


## Check if all tracked actions are acceptable
func are_all_actions_acceptable() -> bool:
	for action in get_tracked_actions():
		if not is_action_acceptable(action):
			return false
	return true


## Get actions that exceed target latency
func get_failing_actions() -> Array[String]:
	var failing: Array[String] = []
	for action in get_tracked_actions():
		if not is_action_acceptable(action):
			failing.append(action)
	return failing


# =============================================================================
# PUBLIC API - CONTROL
# =============================================================================


## Reset all tracking data
func reset_tracking() -> void:
	_pending_inputs.clear()
	_latency_history.clear()
	_last_latency.clear()
	_max_latency.clear()
	_min_latency.clear()
	_latency_sum.clear()
	_measurement_count.clear()


## Reset tracking for a specific action
func reset_action(action: String) -> void:
	_pending_inputs.erase(action)
	_latency_history.erase(action)
	_last_latency.erase(action)
	_max_latency.erase(action)
	_min_latency.erase(action)
	_latency_sum.erase(action)
	_measurement_count.erase(action)


# =============================================================================
# PUBLIC API - REPORTING
# =============================================================================


## Generate a latency report string
func generate_report() -> String:
	var lines: Array[String] = []

	lines.append("=== INPUT LATENCY REPORT ===")
	lines.append("Target: <%.2f ms (1 frame at 60fps)" % target_latency_ms)
	lines.append("")

	var actions := get_tracked_actions()
	if actions.is_empty():
		lines.append("No actions tracked yet.")
	else:
		for action in actions:
			var avg := get_average_latency_ms(action)
			var max_lat := get_max_latency_ms(action)
			var min_lat := get_min_latency_ms(action)
			var count := get_measurement_count(action)
			var status := "PASS" if is_action_acceptable(action) else "FAIL"

			lines.append("--- %s ---" % action)
			lines.append("  Measurements: %d" % count)
			lines.append("  Avg: %.2f ms" % avg)
			lines.append("  Min: %.2f ms" % min_lat)
			lines.append("  Max: %.2f ms" % max_lat)
			lines.append("  Status: %s" % status)
			lines.append("")

	lines.append("--- Overall ---")
	if are_all_actions_acceptable():
		lines.append("All actions PASSING (<%.2f ms)" % target_latency_ms)
	else:
		var failing := get_failing_actions()
		lines.append("FAILING actions: %s" % ", ".join(failing))

	lines.append("")
	lines.append("============================")

	return "\n".join(lines)


## Print report to console
func print_report() -> void:
	print(generate_report())


# =============================================================================
# INTERNAL
# =============================================================================


## Record a latency measurement
func _record_latency(action: String, latency_ms: float) -> void:
	# Update last
	_last_latency[action] = latency_ms

	# Update max
	if not _max_latency.has(action) or latency_ms > _max_latency[action]:
		_max_latency[action] = latency_ms

	# Update min
	if not _min_latency.has(action) or latency_ms < _min_latency[action]:
		_min_latency[action] = latency_ms

	# Update sum and count
	_latency_sum[action] = _latency_sum.get(action, 0.0) + latency_ms
	_measurement_count[action] = _measurement_count.get(action, 0) + 1

	# Emit signal
	latency_recorded.emit(action, latency_ms)

	# Check for exceeded
	if warn_on_exceed and latency_ms > target_latency_ms:
		latency_exceeded.emit(action, latency_ms, target_latency_ms)
		push_warning(
			(
				"Input latency exceeded: %s = %.2f ms (target: %.2f ms)"
				% [action, latency_ms, target_latency_ms]
			)
		)
