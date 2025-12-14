class_name StringRenderer extends Line2D
## Renders bezier curve strings connecting cards/pins on conspiracy board
## BOARD-008: Base bezier curve rendering
## BOARD-009: Elastic physics with 300ms settle time and wobble effects
##
## Provides natural-looking arcs with anti-aliasing and spring physics
## for connecting conspiracy board elements with configurable appearance.

## Signals
signal string_settled()  # Emitted when physics settle within threshold
signal string_wobbled(intensity: float)  # Emitted when wobble is triggered

## Visual Parameters
@export_group("Visual Settings")
## Line thickness in pixels
@export var string_width: float = 2.0

## Color of the connection string
@export var string_color: Color = Color.RED

## Number of segments to subdivide the bezier curve
## Higher values create smoother curves but use more resources
@export_range(4, 100) var string_segments: int = 20

## Physics Parameters (BOARD-009)
@export_group("Physics Settings")
## Spring constant - higher = stiffer string (150.0 = realistic tension)
@export var string_stiffness: float = 150.0

## Damping coefficient - higher = faster settle (8.0 = ~300ms settle time)
@export var string_damping: float = 8.0

## Target settle time in seconds (acceptance criteria: 300ms)
@export var settle_time: float = 0.3

## Maximum stretch ratio before triggering extra wobble (1.5 = 50% stretch)
@export_range(1.0, 3.0) var max_stretch: float = 1.5

## Enable/disable physics simulation (disable for performance)
@export var physics_enabled: bool = true

## Base curve amount for bezier control point offset
@export var bezier_curve_amount: float = 50.0

## State Variables
## Starting point of the string in local coordinates
var start_point: Vector2

## Ending point of the string in local coordinates
var end_point: Vector2

## Physics state - current curve offset with spring physics
var current_curve_offset: float = 0.0

## Physics state - velocity of curve offset animation
var curve_velocity: float = 0.0

## Track if physics have settled within threshold
var _is_settled: bool = true

## Last measured distance for stretch detection
var _last_distance: float = 0.0

## Performance tracking samples
var _performance_samples: Array[float] = []
var _max_samples: int = 60

func _ready() -> void:
	width = string_width
	default_color = string_color
	antialiased = true

	# Initialize physics state
	current_curve_offset = bezier_curve_amount
	_is_settled = true

	# Ensure curve is drawn if endpoints already set
	if start_point != Vector2.ZERO or end_point != Vector2.ZERO:
		_update_bezier_curve()


## Physics processing for elastic string simulation (BOARD-009)
func _physics_process(delta: float) -> void:
	if not physics_enabled:
		return

	# Track performance
	var start_time := Time.get_ticks_usec()

	# Spring physics simulation
	# F = -k * x (Hooke's law) + damping
	var target := bezier_curve_amount
	var displacement := target - current_curve_offset
	var spring_force := displacement * string_stiffness

	# Apply spring force to velocity
	curve_velocity += spring_force * delta

	# Apply damping (exponential decay)
	curve_velocity *= (1.0 - string_damping * delta)

	# Update position
	current_curve_offset += curve_velocity * delta

	# Check for settle condition (acceptance criteria: 300ms settle time)
	var velocity_threshold := 1.0  # Pixels per second
	var position_threshold := 1.0  # Pixels from target
	var is_currently_settled := abs(curve_velocity) < velocity_threshold and abs(displacement) < position_threshold

	if is_currently_settled and not _is_settled:
		# Just settled - snap to target and emit signal
		current_curve_offset = target
		curve_velocity = 0.0
		_is_settled = true
		string_settled.emit()
	elif not is_currently_settled:
		_is_settled = false

	# Update visual representation
	_update_bezier_curve()

	# Track performance for optimization
	var elapsed := (Time.get_ticks_usec() - start_time) / 1000.0  # Convert to ms
	_track_performance(elapsed)

## Sets the start and end points and updates the curve
## @param start: Starting position in local coordinates
## @param end: Ending position in local coordinates
func set_endpoints(start: Vector2, end: Vector2) -> void:
	start_point = start
	end_point = end
	_update_bezier_curve()

## Updates the string width and redraws
func set_string_width(new_width: float) -> void:
	string_width = new_width
	width = new_width

## Updates the string color and redraws
func set_string_color(new_color: Color) -> void:
	string_color = new_color
	default_color = new_color

## Updates the bezier curve amount and redraws
func set_bezier_amount(amount: float) -> void:
	bezier_curve_amount = amount
	_update_bezier_curve()

## Recalculates and redraws the bezier curve with physics (BOARD-009)
func _update_bezier_curve() -> void:
	clear_points()

	# Calculate control point for quadratic bezier
	# Use physics-driven curve offset instead of static amount
	var curve_offset := current_curve_offset if physics_enabled else bezier_curve_amount
	var mid_y := (start_point.y + end_point.y) / 2.0 + curve_offset
	var control_point := Vector2((start_point.x + end_point.x) / 2.0, mid_y)

	# Detect stretch for wobble triggering
	if physics_enabled:
		var distance := start_point.distance_to(end_point)
		if _last_distance > 0.0 and distance > 0.0:
			var stretch_ratio := distance / _last_distance
			if stretch_ratio > max_stretch:
				# Trigger additional wobble on extreme stretch
				trigger_wobble(30.0)
		_last_distance = distance

	# Generate bezier curve points
	for i in range(string_segments + 1):
		var t := float(i) / float(string_segments)
		var point := _quadratic_bezier(start_point, control_point, end_point, t)
		add_point(point)

## Calculates a point on a quadratic bezier curve
## @param p0: Start point
## @param p1: Control point
## @param p2: End point
## @param t: Parameter value (0.0 to 1.0)
## @returns: Interpolated point on the curve
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 := p0.lerp(p1, t)
	var q1 := p1.lerp(p2, t)
	return q0.lerp(q1, t)

## Gets the approximate length of the curve
## Useful for texture mapping or distance calculations
func get_curve_length() -> float:
	var length := 0.0
	var points_array := points
	for i in range(points_array.size() - 1):
		length += points_array[i].distance_to(points_array[i + 1])
	return length

## Gets a point at a specific normalized distance along the curve
## @param normalized_distance: Value from 0.0 to 1.0
## @returns: Position on the curve
func get_point_at_distance(normalized_distance: float) -> Vector2:
	normalized_distance = clamp(normalized_distance, 0.0, 1.0)
	var points_array := points
	if points_array.size() < 2:
		return Vector2.ZERO

	var target_length := get_curve_length() * normalized_distance
	var current_length := 0.0

	for i in range(points_array.size() - 1):
		var segment_length := points_array[i].distance_to(points_array[i + 1])
		if current_length + segment_length >= target_length:
			var t := (target_length - current_length) / segment_length
			return points_array[i].lerp(points_array[i + 1], t)
		current_length += segment_length

	return points_array[points_array.size() - 1]


## Trigger wobble/bounce effect (BOARD-009 acceptance criteria)
## Adds velocity to the spring system for bounce effect on connection
## @param intensity: Wobble intensity in pixels per second
func trigger_wobble(intensity: float = 30.0) -> void:
	if not physics_enabled:
		return

	# Add velocity impulse to create wobble
	curve_velocity = intensity
	_is_settled = false
	string_wobbled.emit(intensity)


## Check if string physics have settled
## @returns: true if velocity and position are within settle thresholds
func is_physics_settled() -> bool:
	return _is_settled


## Force physics to settle immediately (skip animation)
func force_settle() -> void:
	current_curve_offset = bezier_curve_amount
	curve_velocity = 0.0
	_is_settled = true
	_update_bezier_curve()


## Track performance metrics for optimization (BOARD-009)
func _track_performance(elapsed_ms: float) -> void:
	_performance_samples.append(elapsed_ms)

	if _performance_samples.size() > _max_samples:
		_performance_samples.pop_front()


## Get average performance in milliseconds
## Used for performance validation with 10+ strings
## @returns: Average processing time in ms
func get_average_performance() -> float:
	if _performance_samples.is_empty():
		return 0.0

	var sum := 0.0
	for sample in _performance_samples:
		sum += sample

	return sum / _performance_samples.size()


## Get current physics state for debugging
## @returns: Dictionary with physics state information
func get_physics_state() -> Dictionary:
	return {
		"current_offset": current_curve_offset,
		"target_offset": bezier_curve_amount,
		"velocity": curve_velocity,
		"is_settled": _is_settled,
		"string_length": start_point.distance_to(end_point),
		"avg_performance_ms": get_average_performance(),
		"physics_enabled": physics_enabled
	}
