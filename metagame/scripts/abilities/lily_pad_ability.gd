extends Node2D
class_name LilyPadAbility

## Lily Pad ability - creates temporary platform
## Part of special frog mutation set

@export var platform_duration: float = 5.0
@export var ability_cooldown: float = 8.0
@export var platform_scene: PackedScene

var cooldown_timer: float = 0.0
var can_use: bool = true

func _ready() -> void:
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

	if not platform_scene:
		return false

	_spawn_platform()
	can_use = false
	return true

func _spawn_platform() -> void:
	var platform = platform_scene.instantiate()
	platform.global_position = global_position
	platform.lifetime = platform_duration
	get_tree().current_scene.add_child(platform)

	EventBus.ability_used.emit({
		"ability": "lily_pad",
		"position": global_position
	})
