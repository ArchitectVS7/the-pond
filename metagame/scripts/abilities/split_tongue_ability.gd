extends Node
class_name SplitTongueAbility

## Split Tongue ability - attack hits in 30-degree cone
## Part of special frog mutation set
## Modifies player attack behavior

@export var cone_angle: float = 30.0
@export var cone_range: float = 120.0

## Check if target is within cone from origin in given direction
func is_in_cone(origin: Vector2, direction: Vector2, target_pos: Vector2) -> bool:
	var to_target = (target_pos - origin).normalized()
	var angle_to_target = direction.angle_to(to_target)

	# Check if within cone angle
	if abs(angle_to_target) > deg_to_rad(cone_angle / 2.0):
		return false

	# Check if within range
	if origin.distance_to(target_pos) > cone_range:
		return false

	return true

## Get all enemies in cone
func get_enemies_in_cone(origin: Vector2, direction: Vector2) -> Array[Node]:
	var enemies: Array[Node] = []
	var all_enemies = get_tree().get_nodes_in_group("enemy")

	for enemy in all_enemies:
		if enemy is Node2D:
			var enemy_pos = (enemy as Node2D).global_position
			if is_in_cone(origin, direction, enemy_pos):
				enemies.append(enemy)

	return enemies
