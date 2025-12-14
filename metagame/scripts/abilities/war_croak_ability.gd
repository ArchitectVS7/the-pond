extends Area2D
class_name WarCroakAbility

## War Croak ability - stuns enemies in radius
## Part of special frog mutation set

@export var stun_duration: float = 2.0
@export var stun_radius: float = 150.0
@export var ability_cooldown: float = 10.0

var cooldown_timer: float = 0.0
var can_use: bool = true

func _ready() -> void:
	# Setup collision shape
	var shape = CircleShape2D.new()
	shape.radius = stun_radius
	var collision = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	# Disable by default (only check on use)
	monitoring = false
	set_process(true)

func _process(delta: float) -> void:
	if not can_use:
		cooldown_timer += delta
		if cooldown_timer >= ability_cooldown:
			can_use = true
			cooldown_timer = 0.0

func use_ability() -> bool:
	if not can_use:
		return false

	_stun_enemies()
	can_use = false
	return true

func _stun_enemies() -> void:
	monitoring = true
	await get_tree().process_frame

	var enemies_hit = 0
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("apply_stun"):
			body.apply_stun(stun_duration)
			enemies_hit += 1

	for area in get_overlapping_areas():
		if area.is_in_group("enemy") and area.has_method("apply_stun"):
			area.apply_stun(stun_duration)
			enemies_hit += 1

	monitoring = false

	EventBus.ability_used.emit({
		"ability": "war_croak",
		"enemies_hit": enemies_hit,
		"position": global_position
	})
