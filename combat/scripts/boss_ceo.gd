class_name BossCEO
extends BossBase

@export var ceo_total_hp: int = 150
@export var ceo_p1_wall_speed: float = 120.0
@export var ceo_p1_wall_count: int = 5
@export var ceo_p1_wall_spacing: float = 100.0
@export var ceo_p2_homing_strength: float = 2.0
@export var ceo_p2_homing_duration: float = 3.0
@export var ceo_p2_cooldown: float = 2.5
@export var ceo_p3_spawn_interval: float = 0.5
@export var ceo_p3_chaos_count: int = 8
@export var ceo_p3_cooldown: float = 1.2

var attack_timer: float = 0.0
var dialogue_data: Dictionary = {
	"intro": "You think you can stop PROGRESS? I AM the pond. I AM the pollution. I AM... THE MARKET!",
	"phase2": "Your little investigation ends HERE!",
	"phase3": "ENOUGH! I'll bury you like I buried the evidence!",
	"defeat": "No... the board will hear about this..."
}

func _ready() -> void:
	total_hp = ceo_total_hp
	evidence_id = "ceo_evidence"
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
	# "Board Meeting" - Bullet walls
	for i in range(ceo_p1_wall_count):
		var offset = (i - ceo_p1_wall_count / 2.0) * ceo_p1_wall_spacing
		var bullet_pos = global_position + Vector2(offset, 0)
		_spawn_bullet_at(Vector2.DOWN, ceo_p1_wall_speed, bullet_pos)

func _phase2_attack() -> void:
	# "Leveraged Buyout" - Homing bullets
	var player = get_tree().get_first_node_in_group("player")
	if player:
		_spawn_homing_bullet(player)

func _phase3_attack() -> void:
	# "Market Crash" - Screen-filling chaos
	for i in range(ceo_p3_chaos_count):
		var angle = randf() * 2 * PI
		var speed = randf_range(100, 300)
		_spawn_bullet(Vector2.RIGHT.rotated(angle), speed)

func _spawn_bullet(direction: Vector2, speed: float) -> void:
	# Use BulletUpHell spawner
	if bullet_spawner:
		bullet_spawner.fire_bullet(direction, speed)

func _spawn_bullet_at(direction: Vector2, speed: float, spawn_position: Vector2) -> void:
	# Spawn bullet at specific position
	if bullet_spawner:
		var original_pos = bullet_spawner.global_position
		bullet_spawner.global_position = spawn_position
		bullet_spawner.fire_bullet(direction, speed)
		bullet_spawner.global_position = original_pos

func _spawn_homing_bullet(target: Node2D) -> void:
	# Create homing bullet that tracks player
	if bullet_spawner:
		var direction = (target.global_position - global_position).normalized()
		# Create bullet with homing properties
		# Note: This requires BulletUpHell to support homing or custom implementation
		bullet_spawner.fire_bullet(direction, 180.0)

func _get_current_cooldown() -> float:
	match current_phase:
		1: return 3.0  # Phase 1 wall attack
		2: return ceo_p2_cooldown
		3: return ceo_p3_cooldown
	return 2.0

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

	ceo_p1_wall_speed *= speed_scale
	ceo_p2_homing_strength *= speed_scale
