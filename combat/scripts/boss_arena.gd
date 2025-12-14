extends Node2D
class_name BossArena

signal boss_spawned
signal arena_locked
signal arena_unlocked

@export var arena_width: int = 800
@export var arena_height: int = 600
@export var spawn_delay: float = 1.0
@export var lock_fade_duration: float = 0.5
@export var boss_scene: PackedScene

@onready var trigger_area: Area2D = $TriggerArea
@onready var arena_walls: Node2D = $ArenaWalls
@onready var boss_spawn_point: Marker2D = $BossSpawnPoint

var boss_instance: BossBase
var is_locked: bool = false
var has_triggered: bool = false

func _ready() -> void:
	trigger_area.body_entered.connect(_on_player_entered)
	arena_walls.modulate.a = 0

func _on_player_entered(body: Node2D) -> void:
	if has_triggered or not body.is_in_group("player"):
		return

	has_triggered = true
	_lock_arena()
	_clear_regular_enemies()
	await get_tree().create_timer(spawn_delay).timeout
	_spawn_boss()

func _lock_arena() -> void:
	is_locked = true
	arena_locked.emit()
	var tween = create_tween()
	tween.tween_property(arena_walls, "modulate:a", 1.0, lock_fade_duration)
	# Enable collision on walls
	for wall in arena_walls.get_children():
		if wall is CollisionShape2D or wall is StaticBody2D:
			wall.set_deferred("disabled", false)

func _unlock_arena() -> void:
	is_locked = false
	arena_unlocked.emit()
	var tween = create_tween()
	tween.tween_property(arena_walls, "modulate:a", 0.0, lock_fade_duration)
	# Disable collision on walls
	for wall in arena_walls.get_children():
		if wall is CollisionShape2D or wall is StaticBody2D:
			wall.set_deferred("disabled", true)

func _clear_regular_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is BossBase:
			enemy.queue_free()

func _spawn_boss() -> void:
	if boss_scene:
		boss_instance = boss_scene.instantiate()
		boss_instance.position = boss_spawn_point.position
		boss_instance.boss_defeated.connect(_on_boss_defeated)
		add_child(boss_instance)
		boss_spawned.emit()

func _on_boss_defeated() -> void:
	_unlock_arena()
	EventBus.boss_defeated.emit(boss_instance.get_class())
