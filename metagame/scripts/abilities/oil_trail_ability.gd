extends Node2D
class_name OilTrailAbility

## Oil Slick ability - leaves damaging trail behind player
## Part of pollution mutation set

@export var trail_damage: int = 2
@export var trail_duration: float = 3.0
@export var spawn_interval: float = 0.1
@export var trail_scene: PackedScene

var spawn_timer: float = 0.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		_spawn_oil_puddle()
		spawn_timer = 0.0

func _spawn_oil_puddle() -> void:
	if not trail_scene:
		return

	var puddle = trail_scene.instantiate()
	puddle.global_position = global_position
	puddle.damage = trail_damage
	puddle.lifetime = trail_duration
	get_tree().current_scene.add_child(puddle)
