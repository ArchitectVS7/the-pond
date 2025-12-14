class_name BossLobbyist
extends BossBase

@export var p1_bullet_speed: float = 150.0
@export var p1_cooldown: float = 2.0
@export var p2_bullet_speed: float = 200.0
@export var p2_cooldown: float = 1.5
@export var p2_radial_count: int = 8
@export var p3_bullet_speed: float = 250.0
@export var p3_cooldown: float = 1.0
@export var p3_spiral_speed: float = 90.0

var attack_timer: float = 0.0
var dialogue_data: Dictionary = {
	"intro": "Ah, a concerned citizen! Let me show you our... stakeholder engagement process.",
	"phase2": "Time for aggressive negotiations!",
	"phase3": "This is YOUR fault for not synergizing!",
	"defeat": "My... quarterly reports... ruined..."
}

func _ready() -> void:
	total_hp = 100
	evidence_id = "lobbyist_evidence"
	super._ready()

	# Connect to phase changes for dialogue
	phase_changed.connect(_on_phase_changed)

func _physics_process(delta: float) -> void:
	if current_state in [BossState.PHASE_1, BossState.PHASE_2, BossState.PHASE_3]:
		attack_timer += delta
		_process_attack(delta)

func _process_attack(delta: float) -> void:
	var cooldown = _get_current_cooldown()
	if attack_timer >= cooldown:
		attack_timer = 0.0
		match current_phase:
			1: _phase1_attack()
			2: _phase2_attack()
			3: _phase3_attack()

func _phase1_attack() -> void:
	# Aimed single shot - "Business Cards"
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		_spawn_bullet(direction, p1_bullet_speed)

func _phase2_attack() -> void:
	# Radial burst - "Marketing Blitz"
	for i in range(p2_radial_count):
		var angle = (2 * PI / p2_radial_count) * i
		var direction = Vector2.RIGHT.rotated(angle)
		_spawn_bullet(direction, p2_bullet_speed)

func _phase3_attack() -> void:
	# Spiral + aimed - "Hostile Takeover"
	var time = Time.get_ticks_msec() / 1000.0
	var spiral_angle = deg_to_rad(time * p3_spiral_speed)
	var spiral_dir = Vector2.RIGHT.rotated(spiral_angle)
	_spawn_bullet(spiral_dir, p3_bullet_speed)

	# Also aim at player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		_spawn_bullet(direction, p3_bullet_speed * 0.8)

func _spawn_bullet(direction: Vector2, speed: float) -> void:
	# Use BulletUpHell spawner
	if bullet_spawner:
		bullet_spawner.fire_bullet(direction, speed)

func _get_current_cooldown() -> float:
	match current_phase:
		1: return p1_cooldown
		2: return p2_cooldown
		3: return p3_cooldown
	return 1.0

func _on_phase_changed(new_phase: int) -> void:
	match new_phase:
		1: dialogue_triggered.emit(dialogue_data["intro"])
		2: dialogue_triggered.emit(dialogue_data["phase2"])
		3: dialogue_triggered.emit(dialogue_data["phase3"])

func _defeat() -> void:
	dialogue_triggered.emit(dialogue_data["defeat"])
	super._defeat()

func apply_difficulty_scaling(mutation_count: int, hard_mode: bool = false) -> void:
	super.apply_difficulty_scaling(mutation_count, hard_mode)

	# Apply speed scaling to bullet speeds
	var speed_scale = 1.0 + min(mutation_count * speed_scale_per_mutation, max_scaling - 1.0)
	if hard_mode:
		speed_scale *= hard_mode_multiplier

	p1_bullet_speed *= speed_scale
	p2_bullet_speed *= speed_scale
	p3_bullet_speed *= speed_scale
