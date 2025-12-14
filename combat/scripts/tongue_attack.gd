## TongueAttack - Handles tongue whip attack mechanic
##
## COMBAT-003: Tongue attack whip mechanic
## COMBAT-004: Elastic physics with overshoot and snap-back
## COMBAT-008: Screen shake on hit (via ScreenShake autoload)
## Uses aim_direction from PlayerController (COMBAT-002)
##
## States: IDLE → EXTENDING → RETRACTING → IDLE
## Input: Left Mouse Button (attack action)
##
## Architecture Notes:
## - Child of Player scene (accesses parent for aim_direction)
## - Uses Area2D for hit detection against enemies
## - Triggers ScreenShake on enemy hit (COMBAT-008)
## - No allocations in _physics_process() for performance
## - Elastic easing provides satisfying whip feel (COMBAT-004)
class_name TongueAttack
extends Node2D

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when tongue hits an enemy
## Connected by hit feedback system (COMBAT-008)
signal tongue_hit(enemy: Node2D, damage: int)

## Emitted when attack starts
## Used for audio/visual feedback
signal attack_started

## Emitted when attack completes (retract finished)
## Used for combo tracking, animation sync
signal attack_finished

# =============================================================================
# ENUMS
# =============================================================================

## Attack state machine states
enum State { IDLE, EXTENDING, RETRACTING }

# =============================================================================
# CONSTANTS
# =============================================================================

# Preload to ensure class is available for type checking
const PlayerControllerClass = preload("res://combat/scripts/player_controller.gd")

# =============================================================================
# EXPORTS (Tunable in Editor - see DEVELOPERS_MANUAL.md)
# =============================================================================

## Base damage dealt per hit
## Mutations can modify this (e.g., "Strong Tongue" +1 damage)
@export var base_damage: int = 1

## Time between attacks in seconds
## Mutations can reduce this (e.g., "Faster Tongue" -50%)
@export var attack_cooldown: float = 0.3

## Time to extend tongue (seconds)
## Affects attack feel - shorter = snappier
@export var extend_duration: float = 0.15

## Time to retract tongue (seconds)
## Affects recovery - shorter = faster follow-up
@export var retract_duration: float = 0.1

## Maximum tongue length in pixels
## 3 tiles at 48px/tile = 144 (PRD requirement)
## Mutations can increase (e.g., "Longer Tongue" +50%)
@export var max_range: float = 144.0

# =============================================================================
# ELASTIC PHYSICS (COMBAT-004)
# =============================================================================

## How much the tongue overshoots max_range during extension (0.1 = 10%)
## Higher values = more dramatic whip effect, hits enemies slightly beyond base range
## Set to 0.0 for no overshoot (linear extension)
@export_range(0.0, 0.5, 0.05) var extend_overshoot: float = 0.15

## Elastic bounce intensity (higher = more pronounced bounce)
## Affects how "springy" the tongue feels at max extension
## Lower values (1.0-2.0) = subtle, Higher values (3.0-5.0) = exaggerated
@export_range(1.0, 5.0, 0.5) var elastic_strength: float = 2.0

## Retract snap intensity - how quickly tongue snaps back
## Higher values = faster initial snap, slower end (ease_out feel)
## Set to 1.0 for linear retract, 2.0+ for snappy feel
@export_range(1.0, 4.0, 0.5) var retract_snap: float = 2.5

# =============================================================================
# STATE
# =============================================================================

## Current attack state
var current_state: State = State.IDLE

## Time remaining before next attack allowed
var cooldown_timer: float = 0.0

## Timer for current attack phase (extend or retract)
var attack_timer: float = 0.0

## Current tongue extension length
var current_length: float = 0.0

# =============================================================================
# NODE REFERENCES (Set in _ready, not @onready for safety)
# =============================================================================

## Reference to parent PlayerController for aim_direction
var player = null  # PlayerController

## Tongue visual (Line2D child node)
var tongue_line = null  # Line2D

## Hit detection area (Area2D child node)
var hit_area = null  # Area2D

# =============================================================================
# PRIVATE STATE
# =============================================================================

## Tracks enemies already hit this attack (prevents double-hit)
var _hit_enemies: Array[Node2D] = []

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	# Get parent player reference safely
	var parent := get_parent()
	if parent is PlayerControllerClass:
		player = parent as PlayerControllerClass
	else:
		push_error("TongueAttack: Must be child of PlayerController. Parent is: %s" % parent)
		return

	# Get child nodes safely
	if has_node("TongueLine"):
		tongue_line = get_node("TongueLine") as Line2D
	else:
		push_warning("TongueAttack: TongueLine child not found. Tongue visual disabled.")

	if has_node("HitArea"):
		hit_area = get_node("HitArea") as Area2D
	else:
		push_warning("TongueAttack: HitArea child not found. Hit detection disabled.")


func _physics_process(delta: float) -> void:
	# Skip if not properly initialized
	if not player:
		return

	# Update cooldown timer
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	# Handle attack input (only in IDLE state with no cooldown)
	if current_state == State.IDLE and cooldown_timer <= 0.0:
		if Input.is_action_just_pressed("attack"):
			_start_attack()

	# Update attack state machine
	match current_state:
		State.EXTENDING:
			_update_extending(delta)
		State.RETRACTING:
			_update_retracting(delta)


# =============================================================================
# STATE MACHINE TRANSITIONS
# =============================================================================


## Start a new attack
func _start_attack() -> void:
	current_state = State.EXTENDING
	attack_timer = 0.0
	current_length = 0.0
	_hit_enemies.clear()
	attack_started.emit()


## Update extending state - tongue shoots outward with elastic overshoot
func _update_extending(delta: float) -> void:
	attack_timer += delta
	var progress := minf(attack_timer / extend_duration, 1.0)

	# Apply elastic easing with overshoot (COMBAT-004)
	var eased_progress := _ease_out_elastic(progress)

	# Calculate length with overshoot
	# At peak overshoot, tongue extends beyond max_range
	var overshoot_multiplier := 1.0 + extend_overshoot
	current_length = max_range * eased_progress

	# Clamp to overshoot range (prevents extreme values from elastic math)
	current_length = clampf(current_length, 0.0, max_range * overshoot_multiplier)

	_update_tongue_visual()
	_check_hits()

	# Transition to retracting when animation complete
	if progress >= 1.0:
		current_length = max_range  # Settle at exact max_range
		current_state = State.RETRACTING
		attack_timer = 0.0


## Update retracting state - tongue snaps back with ease-out
func _update_retracting(delta: float) -> void:
	attack_timer += delta
	var progress := minf(attack_timer / retract_duration, 1.0)

	# Apply snap-back easing (fast start, slow end) (COMBAT-004)
	var eased_progress := _ease_out_power(progress, retract_snap)

	current_length = max_range * (1.0 - eased_progress)

	_update_tongue_visual()

	# Transition to idle when fully retracted
	if progress >= 1.0:
		current_state = State.IDLE
		current_length = 0.0
		cooldown_timer = attack_cooldown
		_update_tongue_visual()  # Reset visual to zero length
		attack_finished.emit()


# =============================================================================
# EASING FUNCTIONS (COMBAT-004)
# =============================================================================


## Elastic ease-out: fast start, bouncy overshoot at end
## Used for tongue extension to create whip-like feel
func _ease_out_elastic(t: float) -> float:
	if t <= 0.0:
		return 0.0
	if t >= 1.0:
		return 1.0

	# Attempt overshoot, then settle
	# Formula: attempt to hit (1 + overshoot), then settle back to 1.0
	var p := 0.3  # Period of oscillation
	var a := 1.0 + extend_overshoot  # Amplitude (overshoot amount)

	# Modified elastic formula that overshoots then settles
	var elastic := a * pow(2.0, -10.0 * t) * sin((t - p / 4.0) * TAU / p) + 1.0

	# Scale by elastic_strength (higher = more pronounced bounce)
	var bounce_factor := (elastic - 1.0) * (elastic_strength / 2.0)
	return 1.0 + bounce_factor


## Power-based ease-out: fast start, gradual slow-down
## Used for tongue retraction to create snap-back feel
func _ease_out_power(t: float, power: float) -> float:
	return 1.0 - pow(1.0 - t, power)


# =============================================================================
# VISUAL UPDATE
# =============================================================================


## Update tongue line visual to match current length and direction
func _update_tongue_visual() -> void:
	if not tongue_line or not player:
		return

	# Calculate end point based on aim direction and current length
	var end_point: Vector2 = player.aim_direction * current_length

	# Update line end point (point 0 is origin, point 1 is tip)
	tongue_line.set_point_position(1, end_point)


# =============================================================================
# HIT DETECTION
# =============================================================================


## Check for enemies overlapping with tongue tip
func _check_hits() -> void:
	if not hit_area or not player:
		return

	# Position hit area at tongue tip
	hit_area.position = player.aim_direction * current_length

	# Check for overlapping bodies in "enemies" group
	for body in hit_area.get_overlapping_bodies():
		# Skip if already hit this attack
		if body in _hit_enemies:
			continue

		# Check if body is an enemy
		if body.is_in_group("enemies"):
			_hit_enemies.append(body)
			tongue_hit.emit(body, base_damage)

			# Trigger feedback effects
			_trigger_hit_shake()  # COMBAT-008
			_trigger_hit_particles(body.global_position)  # COMBAT-009
			_trigger_hit_sound()  # COMBAT-011

			# Apply damage directly if enemy has take_damage method
			if body.has_method("take_damage"):
				body.take_damage(base_damage)


## Trigger screen shake for hit feedback (COMBAT-008)
func _trigger_hit_shake() -> void:
	# Get ScreenShake autoload if available
	var screen_shake := get_node_or_null("/root/ScreenShake")
	if screen_shake and screen_shake.has_method("shake_hit"):
		screen_shake.shake_hit()


## Trigger hit particles at enemy position (COMBAT-009)
func _trigger_hit_particles(enemy_pos: Vector2) -> void:
	var particle_manager := get_node_or_null("/root/ParticleManager")
	if particle_manager and particle_manager.has_method("spawn_hit_particles"):
		particle_manager.spawn_hit_particles(enemy_pos)


## Trigger hit sound (wet thwap) (COMBAT-011)
func _trigger_hit_sound() -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("play_hit"):
		audio_manager.play_hit()
