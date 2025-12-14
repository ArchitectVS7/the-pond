## HitStop - Manages frame-freeze effects for combat impact
##
## COMBAT-010: Hit-stop 2-frame pause on enemy kills
## PRD Requirement: "Hit-stop: 2-frame pause on enemy kills"
##
## Features:
## - 2-frame freeze (33ms) on enemy kills for impact
## - Configurable freeze scale (0.0 = full freeze, 0.1 = slow-mo)
## - Accessibility toggle to disable entirely
## - Stacking support (new triggers reset timer)
## - Signals for animation sync
##
## Architecture Notes:
## - Designed as autoload singleton
## - Uses Engine.time_scale for freeze effect
## - Tracks original time_scale for restoration
## - Process mode ALWAYS to continue during freeze
class_name HitStop
extends Node

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when freeze effect starts
signal freeze_started(duration: float)

## Emitted when freeze effect ends
signal freeze_ended

# =============================================================================
# EXPORTS (Tunable in Editor - see DEVELOPERS_MANUAL.md)
# =============================================================================

## Whether hit-stop is enabled (accessibility toggle)
## Set to false for players sensitive to frame pauses
@export var hit_stop_enabled: bool = true

## Default freeze duration in seconds
## At 60fps: 2 frames = 2/60 = 0.0333 seconds
## Increase for more dramatic effect, decrease for subtlety
@export var default_duration: float = 0.033

## Time scale during freeze (0.0 = full stop, 0.1 = slow-mo)
## 0.0 creates hard impact, 0.01-0.1 creates slow-motion effect
## Values above 0.5 may not feel like a freeze
@export_range(0.0, 0.5, 0.01) var freeze_time_scale: float = 0.0

## Kill freeze duration multiplier
## Applied to default_duration for kill effects
## 1.0 = same as default, 2.0 = double duration for kills
@export var kill_duration_multiplier: float = 1.0

# =============================================================================
# STATE
# =============================================================================

## Whether currently frozen
var _is_frozen: bool = false

## Remaining freeze time
var _freeze_timer: float = 0.0

## Original time scale before freeze (for restoration)
var _original_time_scale: float = 1.0

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	# Must process even when time is frozen
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if not _is_frozen:
		return

	# Use unscaled delta for freeze timer (since time is scaled)
	# delta is already affected by time_scale, so we need to compensate
	var unscaled_delta := delta
	if Engine.time_scale > 0.0:
		unscaled_delta = delta / Engine.time_scale
	else:
		# When time_scale is 0, use frame time estimate
		unscaled_delta = 0.016  # ~60fps

	_freeze_timer -= unscaled_delta

	if _freeze_timer <= 0.0:
		_end_freeze()


# =============================================================================
# PUBLIC API
# =============================================================================


## Trigger a hit-stop freeze effect
## duration: How long to freeze in seconds (default: 2 frames at 60fps)
func trigger_hit_stop(duration: float = -1.0) -> void:
	# Use default duration if not specified
	if duration < 0.0:
		duration = default_duration

	# Skip if disabled or invalid duration
	if not hit_stop_enabled or duration <= 0.0:
		return

	# Start or extend freeze
	if not _is_frozen:
		_start_freeze(duration)
	else:
		# Extend freeze (take the longer duration)
		_freeze_timer = maxf(_freeze_timer, duration)


## Convenience method for kill hit-stop (2-frame pause)
func hit_stop_kill() -> void:
	trigger_hit_stop(default_duration * kill_duration_multiplier)


## Force stop any active freeze
func stop_hit_stop() -> void:
	if _is_frozen:
		_end_freeze()


## Check if currently frozen
func is_frozen() -> bool:
	return _is_frozen


## Get remaining freeze time
func get_remaining_time() -> float:
	return maxf(_freeze_timer, 0.0)


# =============================================================================
# INTERNAL
# =============================================================================


## Start the freeze effect
func _start_freeze(duration: float) -> void:
	_is_frozen = true
	_freeze_timer = duration
	_original_time_scale = Engine.time_scale

	# Apply freeze
	Engine.time_scale = freeze_time_scale

	freeze_started.emit(duration)


## End the freeze effect
func _end_freeze() -> void:
	_is_frozen = false
	_freeze_timer = 0.0

	# Restore time scale
	Engine.time_scale = _original_time_scale

	freeze_ended.emit()
