extends Node
class_name DoubleJumpAbility

## Double Jump (Dash) ability - allows mid-air dash
## Part of base frog mutation set

@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

var cooldown_timer: float = 0.0
var can_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

signal dash_started()
signal dash_ended()

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	# Handle cooldown
	if not can_dash:
		cooldown_timer += delta
		if cooldown_timer >= dash_cooldown:
			can_dash = true
			cooldown_timer = 0.0

	# Handle dash duration
	if is_dashing:
		dash_timer += delta
		if dash_timer >= dash_duration:
			_end_dash()

func use_ability(direction: Vector2) -> bool:
	if not can_dash or is_dashing:
		return false

	_start_dash(direction)
	return true

func _start_dash(direction: Vector2) -> void:
	dash_direction = direction.normalized()
	is_dashing = true
	can_dash = false
	dash_timer = 0.0
	dash_started.emit()

func _end_dash() -> void:
	is_dashing = false
	dash_direction = Vector2.ZERO
	dash_ended.emit()

func get_dash_velocity() -> Vector2:
	if is_dashing:
		return dash_direction * dash_speed
	return Vector2.ZERO
