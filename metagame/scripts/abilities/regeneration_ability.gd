extends Node
class_name RegenerationAbility

## Regeneration ability - heals 1 HP every 30 seconds
## Part of base frog mutation set

@export var heal_amount: int = 1
@export var heal_interval: float = 30.0

var heal_timer: float = 0.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	heal_timer += delta
	if heal_timer >= heal_interval:
		_heal_player()
		heal_timer = 0.0

func _heal_player() -> void:
	var player = get_parent()
	if player and player.has_method("heal"):
		player.heal(heal_amount)
		EventBus.player_healed.emit(heal_amount)
