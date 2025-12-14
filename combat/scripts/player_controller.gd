## PlayerController - Handles player movement and aiming
##
## COMBAT-001: 8-directional WASD movement with normalized diagonal movement
## COMBAT-002: Mouse aim system for tongue attack direction
##
## Acceptance Criteria (PRD FR-001):
## - WASD movement (8-directional)
## - Mouse aim tracks cursor position
## - 60fps minimum on GTX 1060 @ 1080p
## - <16ms input lag (1 frame at 60fps)
## - Diagonal movement normalized (no speed boost)
## - Movement speed ~200 pixels/second
##
## Architecture Notes:
## - Attached to CharacterBody2D (Player.tscn)
## - Uses Input.get_axis() for smooth analog support
## - No allocations in _physics_process() for performance
## - aim_direction used by COMBAT-003 (tongue attack)
##
## Collision Layers:
## - Layer 1 = Player (what IS the player)
## - Mask 2 = Environment (what the player COLLIDES with)
class_name PlayerController
extends CharacterBody2D

# =============================================================================
# EXPORTS (Tunable in Editor)
# =============================================================================

## Movement speed in pixels per second
## Tune this in the editor without code changes
@export var move_speed: float = 200.0

# =============================================================================
# AIM STATE (COMBAT-002)
# =============================================================================

## Current aim direction - normalized vector pointing toward mouse cursor
## Used by tongue attack (COMBAT-003) to determine attack direction
var aim_direction: Vector2 = Vector2.RIGHT

## Current aim angle in radians (0 = right, PI/2 = down, PI = left, -PI/2 = up)
## Used for rotating aim indicator sprite
var aim_angle: float = 0.0

## Reference to aim pivot node (set safely in _ready, not @onready)
## This avoids crash if AimPivot node is missing
var aim_pivot: Node2D = null

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	# Add to player group for enemy targeting
	add_to_group("player")

	# Safely get AimPivot reference (avoids @onready crash if node missing)
	if has_node("AimPivot"):
		aim_pivot = get_node("AimPivot")
	else:
		push_warning("PlayerController: AimPivot node not found. Aim visual will not rotate.")


# =============================================================================
# PHYSICS PROCESS
# =============================================================================


## Called every physics frame at fixed 60fps (project.godot: physics_ticks_per_second=60)
## Note: _delta is unused because physics timestep is fixed (always 1/60 = 0.0166s)
## Velocity is already in pixels/second, applied by move_and_slide() each fixed frame
## Performance: No heap allocations, only stack variables
func _physics_process(_delta: float) -> void:
	# COMBAT-001: Movement
	var input_direction := _get_input_direction()
	velocity = input_direction * move_speed
	move_and_slide()

	# COMBAT-002: Aim
	_update_aim()


# =============================================================================
# INPUT HANDLING (COMBAT-001)
# =============================================================================


## Get the normalized input direction vector
## Uses Input.get_axis() for proper analog stick support
## Returns: Normalized Vector2 (length 0 or 1)
func _get_input_direction() -> Vector2:
	var direction := Vector2.ZERO

	# Use get_axis for smooth input (supports controllers)
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	# ALWAYS normalize if there's any input
	# This ensures consistent speed regardless of input method (keyboard vs analog)
	# Uses length_squared() for performance (avoids sqrt)
	if direction.length_squared() > 0.0:
		direction = direction.normalized()

	return direction


# =============================================================================
# AIM HANDLING (COMBAT-002)
# =============================================================================


## Update aim direction to point toward mouse cursor
## Called every physics frame for responsive aiming
## Performance: No allocations, uses stack variables only
func _update_aim() -> void:
	var mouse_pos := get_global_mouse_position()
	var direction := mouse_pos - global_position

	# Normalize if mouse is not exactly at player position
	# Uses length_squared() for performance (avoids sqrt in check)
	if direction.length_squared() > 0.0:
		aim_direction = direction.normalized()
		aim_angle = aim_direction.angle()

		# Rotate aim pivot to face mouse (if it exists)
		if aim_pivot:
			aim_pivot.rotation = aim_angle
	# If mouse is at player position, keep previous aim direction (don't reset)
