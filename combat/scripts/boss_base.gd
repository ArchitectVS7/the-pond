class_name BossBase
extends CharacterBody2D

signal phase_changed(new_phase: int)
signal boss_defeated
signal dialogue_triggered(text: String)

enum BossState { IDLE, PHASE_1, PHASE_2, PHASE_3, TRANSITIONING, DEFEATED }

@export var total_hp: int = 100
@export var phase_2_threshold: float = 0.66
@export var phase_3_threshold: float = 0.33
@export var phase_transition_duration: float = 2.0
@export var intro_duration: float = 3.0
@export var evidence_spawn_delay: float = 1.0
@export var evidence_id: String = ""
@export var hp_scale_per_mutation: float = 0.05
@export var speed_scale_per_mutation: float = 0.02
@export var max_scaling: float = 1.5
@export var hard_mode_multiplier: float = 1.5

var current_hp: int
var current_state: BossState = BossState.IDLE
var current_phase: int = 0
var is_invulnerable: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var bullet_spawner = $BuHSpawner
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	current_hp = total_hp
	_start_intro()

func _start_intro() -> void:
	current_state = BossState.IDLE
	# Play intro animation, show dialogue
	await get_tree().create_timer(intro_duration).timeout
	_transition_to_phase(1)

func take_damage(amount: int) -> void:
	if is_invulnerable:
		return

	current_hp -= amount
	_check_phase_transition()

	if current_hp <= 0:
		_defeat()

func _check_phase_transition() -> void:
	var hp_percent = float(current_hp) / float(total_hp)

	if current_phase == 1 and hp_percent <= phase_2_threshold:
		_transition_to_phase(2)
	elif current_phase == 2 and hp_percent <= phase_3_threshold:
		_transition_to_phase(3)

func _transition_to_phase(new_phase: int) -> void:
	current_state = BossState.TRANSITIONING
	is_invulnerable = true
	current_phase = new_phase
	phase_changed.emit(new_phase)

	# Play transition animation
	await get_tree().create_timer(phase_transition_duration).timeout

	current_state = BossState["PHASE_%d" % new_phase]
	is_invulnerable = false
	_start_phase_pattern(new_phase)

func _start_phase_pattern(phase: int) -> void:
	# Override in subclass
	pass

func _defeat() -> void:
	current_state = BossState.DEFEATED
	is_invulnerable = true
	boss_defeated.emit()

	await get_tree().create_timer(evidence_spawn_delay).timeout
	_spawn_evidence()

func _spawn_evidence() -> void:
	if evidence_id != "":
		var evidence = preload("res://metagame/scenes/Evidence.tscn").instantiate()
		evidence.evidence_id = evidence_id
		evidence.position = global_position
		get_parent().add_child(evidence)
		EventBus.evidence_dropped.emit(evidence_id)

func apply_difficulty_scaling(mutation_count: int, hard_mode: bool = false) -> void:
	var hp_scale = 1.0 + min(mutation_count * hp_scale_per_mutation, max_scaling - 1.0)
	var speed_scale = 1.0 + min(mutation_count * speed_scale_per_mutation, max_scaling - 1.0)

	if hard_mode:
		hp_scale *= hard_mode_multiplier
		speed_scale *= hard_mode_multiplier

	total_hp = int(total_hp * hp_scale)
	current_hp = total_hp
	# Speed scaling to be applied by subclasses to their bullet speeds
