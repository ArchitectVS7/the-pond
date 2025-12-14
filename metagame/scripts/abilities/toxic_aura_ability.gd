extends Area2D
class_name ToxicAuraAbility

## Toxic Aura ability - damages nearby enemies
## Part of pollution mutation set

@export var aura_damage: int = 1
@export var damage_interval: float = 1.0
@export var aura_radius: float = 80.0

var damage_timer: float = 0.0
var enemies_in_range: Array[Node] = []

func _ready() -> void:
	# Setup collision shape
	var shape = CircleShape2D.new()
	shape.radius = aura_radius
	var collision = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	# Setup detection
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	set_process(true)

func _process(delta: float) -> void:
	damage_timer += delta
	if damage_timer >= damage_interval:
		_damage_nearby_enemies()
		damage_timer = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		enemies_in_range.append(area)

func _on_area_exited(area: Area2D) -> void:
	enemies_in_range.erase(area)

func _damage_nearby_enemies() -> void:
	for enemy in enemies_in_range:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.take_damage(aura_damage)
