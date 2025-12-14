## ScreenShake - Camera shake effect for hit feedback
##
## COMBAT-008: Hit feedback screenshake
## PRD NFR-002: Screen shake toggle (accessibility)
##
## Uses trauma-based shake system:
## - Actions add trauma (0.0 to 1.0)
## - Trauma decays over time
## - Shake intensity = trauma^shake_power (exponential feel)
## - Camera offset randomized each frame
##
## Architecture Notes:
## - Designed as autoload singleton (add to project.godot)
## - Respects shake_enabled for accessibility
## - Uses Perlin noise for smooth randomness (optional upgrade)
## - No allocations in _process() for performance
class_name ScreenShake
extends Node

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when shake starts
signal shake_started(intensity: float)

## Emitted when shake ends (trauma reaches 0)
signal shake_ended

# =============================================================================
# EXPORTS (Tunable in Editor - see DEVELOPERS_MANUAL.md)
# =============================================================================

## Whether screen shake is enabled (accessibility toggle)
@export var shake_enabled: bool = true

## Base intensity multiplier (higher = more shake for same trauma)
@export var base_intensity: float = 1.0

## Maximum shake offset in pixels
@export var max_offset: float = 16.0

## How quickly trauma decays (trauma per second)
## Higher = faster decay = shorter shakes
@export var trauma_decay_rate: float = 1.5

## Maximum trauma accumulation
@export var max_trauma: float = 1.0

## Shake power (higher = more responsive to small trauma)
## 2.0 = quadratic feel (standard)
## 3.0 = cubic feel (less shake at low trauma)
@export var shake_power: float = 2.0

# =============================================================================
# PRESET INTENSITIES
# =============================================================================

## Trauma added on tongue hit
@export var hit_trauma: float = 0.2

## Trauma added on enemy kill
@export var kill_trauma: float = 0.4

## Duration for hit shake (affects decay timing)
@export var hit_duration: float = 0.15

## Duration for kill shake
@export var kill_duration: float = 0.25

# =============================================================================
# STATE
# =============================================================================

## Current trauma level (0.0 to max_trauma)
var current_trauma: float = 0.0

## Remaining shake duration (seconds)
var _shake_duration: float = 0.0

## Cached camera reference
var _camera: Camera2D = null

## Whether we were shaking last frame (for signal)
var _was_shaking: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	# Try to find camera
	_update_camera_reference()


func _process(delta: float) -> void:
	# Respect accessibility setting
	if not shake_enabled:
		_stop_shake()
		return

	# Update camera reference if needed
	if not _camera or not is_instance_valid(_camera):
		_update_camera_reference()
		if not _camera:
			return

	# Check if we're actively shaking
	if current_trauma <= 0.0:
		if _was_shaking:
			_camera.offset = Vector2.ZERO
			shake_ended.emit()
			_was_shaking = false
		return

	# Calculate shake amount (exponential for better feel)
	var shake_amount := pow(current_trauma, shake_power)

	# Apply random offset
	var offset := Vector2(
		randf_range(-1.0, 1.0) * max_offset * shake_amount * base_intensity,
		randf_range(-1.0, 1.0) * max_offset * shake_amount * base_intensity
	)
	_camera.offset = offset

	# Decay trauma
	current_trauma -= trauma_decay_rate * delta
	current_trauma = maxf(current_trauma, 0.0)

	_was_shaking = true


# =============================================================================
# PUBLIC API
# =============================================================================


## Trigger a screen shake
## intensity: Trauma to add (0.0-1.0)
## duration: How long before trauma fully decays (affects decay rate)
func shake(intensity: float, duration: float) -> void:
	if not shake_enabled:
		return

	# Clamp inputs
	intensity = maxf(intensity, 0.0)
	duration = maxf(duration, 0.0)

	# Add trauma (capped at max)
	current_trauma = minf(current_trauma + intensity, max_trauma)

	# Track duration (uses longest active duration)
	_shake_duration = maxf(_shake_duration, duration)

	if not _was_shaking and current_trauma > 0.0:
		shake_started.emit(intensity)


## Preset: Shake for hitting an enemy
func shake_hit() -> void:
	shake(hit_trauma, hit_duration)


## Preset: Shake for killing an enemy
func shake_kill() -> void:
	shake(kill_trauma, kill_duration)


## Check if currently shaking
func is_shaking() -> bool:
	return shake_enabled and current_trauma > 0.0


## Stop shake immediately
func stop_shake() -> void:
	_stop_shake()


# =============================================================================
# INTERNAL
# =============================================================================


## Internal stop shake
func _stop_shake() -> void:
	current_trauma = 0.0
	_shake_duration = 0.0

	if _camera and is_instance_valid(_camera):
		_camera.offset = Vector2.ZERO

	if _was_shaking:
		shake_ended.emit()
		_was_shaking = false


## Update camera reference
func _update_camera_reference() -> void:
	var viewport := get_viewport()
	if viewport:
		_camera = viewport.get_camera_2d()
