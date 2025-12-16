## achievement_manager.gd
## PLATFORM-003: Achievement Framework
##
## Manages game achievements with Steam integration support

extends Node
class_name AchievementManager

## Achievement definition
class Achievement:
	var id: String
	var name: String
	var description: String
	var unlocked: bool = false
	var unlock_time: int = 0
	var progress: float = 0.0  # For progress-based achievements
	var max_progress: float = 100.0

	func _init(p_id: String, p_name: String, p_description: String, p_max_progress: float = 100.0):
		id = p_id
		name = p_name
		description = p_description
		max_progress = p_max_progress

## Signals
signal achievement_unlocked(achievement_id: String)
signal achievement_progress_updated(achievement_id: String, progress: float, max_progress: float)

## Achievement storage
var achievements: Dictionary = {}
var save_file_path: String = "user://achievements.save"

## Reference to SteamManager (if available)
var steam_manager: SteamManager = null

func _ready() -> void:
	_define_achievements()
	_load_achievements()

	# Try to connect to SteamManager
	if has_node("/root/SteamManager"):
		steam_manager = get_node("/root/SteamManager")

## PLATFORM-003: Define core achievements
func _define_achievements() -> void:
	# Achievement 1: First Conspiracy Connection
	achievements["FIRST_CONNECTION"] = Achievement.new(
		"FIRST_CONNECTION",
		"Down the Rabbit Hole",
		"Connect your first conspiracy theory thread",
		1.0
	)

	# Achievement 2: Complete Investigation
	achievements["CASE_CLOSED"] = Achievement.new(
		"CASE_CLOSED",
		"Case Closed",
		"Complete your first full investigation",
		1.0
	)

	# Achievement 3: Bullet Time Master
	achievements["BULLET_MASTER"] = Achievement.new(
		"BULLET_MASTER",
		"Bullet Time Master",
		"Dodge 100 bullets using bullet time",
		100.0
	)

	# Achievement 4: Conspiracy Theorist
	achievements["THEORY_MASTER"] = Achievement.new(
		"THEORY_MASTER",
		"Conspiracy Theorist",
		"Create 10 different conspiracy theories",
		10.0
	)

## Load achievements from save file
func _load_achievements() -> void:
	if not FileAccess.file_exists(save_file_path):
		return

	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		push_error("AchievementManager: Failed to load achievements")
		return

	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	file.close()

	if parse_result != OK:
		push_error("AchievementManager: Failed to parse achievement data")
		return

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return

	# Restore achievement progress
	for achievement_id in data.keys():
		if achievements.has(achievement_id):
			var achievement: Achievement = achievements[achievement_id]
			var saved_data = data[achievement_id]

			achievement.unlocked = saved_data.get("unlocked", false)
			achievement.unlock_time = saved_data.get("unlock_time", 0)
			achievement.progress = saved_data.get("progress", 0.0)

## Save achievements to file
func _save_achievements() -> void:
	var data = {}

	for achievement_id in achievements.keys():
		var achievement: Achievement = achievements[achievement_id]
		data[achievement_id] = {
			"unlocked": achievement.unlocked,
			"unlock_time": achievement.unlock_time,
			"progress": achievement.progress
		}

	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file == null:
		push_error("AchievementManager: Failed to save achievements")
		return

	# Godot 4.4+: store_string returns bool indicating success
	if not file.store_string(JSON.stringify(data, "\t")):
		push_error("AchievementManager: Failed to write achievement data")
		file.close()
		return
	file.close()

## Update achievement progress
func update_progress(achievement_id: String, progress_increment: float = 1.0) -> void:
	if not achievements.has(achievement_id):
		push_error("AchievementManager: Unknown achievement: %s" % achievement_id)
		return

	var achievement: Achievement = achievements[achievement_id]

	if achievement.unlocked:
		return  # Already unlocked

	achievement.progress += progress_increment
	achievement.progress = min(achievement.progress, achievement.max_progress)

	achievement_progress_updated.emit(achievement_id, achievement.progress, achievement.max_progress)

	# Check if achievement should be unlocked
	if achievement.progress >= achievement.max_progress:
		unlock_achievement(achievement_id)
	else:
		_save_achievements()

## Unlock an achievement
func unlock_achievement(achievement_id: String) -> void:
	if not achievements.has(achievement_id):
		push_error("AchievementManager: Unknown achievement: %s" % achievement_id)
		return

	var achievement: Achievement = achievements[achievement_id]

	if achievement.unlocked:
		return  # Already unlocked

	achievement.unlocked = true
	achievement.progress = achievement.max_progress
	achievement.unlock_time = Time.get_unix_time_from_system()

	_save_achievements()

	# Notify Steam if available
	if steam_manager and steam_manager.is_initialized():
		steam_manager.unlock_achievement(achievement_id)

	# Emit signal
	achievement_unlocked.emit(achievement_id)

	push_warning("Achievement Unlocked: %s - %s" % [achievement.name, achievement.description])

## Get achievement data
func get_achievement(achievement_id: String) -> Achievement:
	return achievements.get(achievement_id)

## Check if achievement is unlocked
func is_unlocked(achievement_id: String) -> bool:
	if not achievements.has(achievement_id):
		return false
	return achievements[achievement_id].unlocked

## Get achievement progress
func get_progress(achievement_id: String) -> float:
	if not achievements.has(achievement_id):
		return 0.0
	return achievements[achievement_id].progress

## Get all achievements
func get_all_achievements() -> Array:
	return achievements.values()

## Get unlocked achievements
func get_unlocked_achievements() -> Array:
	var unlocked = []
	for achievement in achievements.values():
		if achievement.unlocked:
			unlocked.append(achievement)
	return unlocked

## Get locked achievements
func get_locked_achievements() -> Array:
	var locked = []
	for achievement in achievements.values():
		if not achievement.unlocked:
			locked.append(achievement)
	return locked

## Reset achievement (for testing)
func reset_achievement(achievement_id: String) -> void:
	if not achievements.has(achievement_id):
		return

	var achievement: Achievement = achievements[achievement_id]
	achievement.unlocked = false
	achievement.unlock_time = 0
	achievement.progress = 0.0

	_save_achievements()

## Reset all achievements (for testing)
func reset_all_achievements() -> void:
	for achievement in achievements.values():
		achievement.unlocked = false
		achievement.unlock_time = 0
		achievement.progress = 0.0

	_save_achievements()

## Get completion percentage
func get_completion_percentage() -> float:
	if achievements.is_empty():
		return 0.0

	var unlocked_count = get_unlocked_achievements().size()
	return (float(unlocked_count) / float(achievements.size())) * 100.0
