## meta_progression.gd - META-001: Persistent Conspiracy Board State
## Manages persistent state across runs, saves card positions, connections, and discoveries

extends Node
class_name MetaProgression

signal meta_state_loaded
signal meta_state_saved
signal progression_updated(category: String, value: Variant)

const SAVE_PATH := "user://meta_progression.save"
const VERSION := "1.0.0"

## Meta-progression state structure
var meta_state := {
	"version": VERSION,
	"conspiracy_board": {
		"card_positions": {},  # {card_id: Vector2}
		"connections": [],  # [{from: id, to: id, type: string}]
		"discoveries": [],  # [discovery_id, ...]
		"notes": {}  # {card_id: string}
	},
	"evidence": {
		"unlocked_logs": [],  # [log_id, ...]
		"boss_defeats": {},  # {boss_name: count}
		"total_evidence_pieces": 0
	},
	"informants": {
		"unlocked": [],  # [informant_id, ...]
		"dialogue_progress": {},  # {informant_id: {topic: progress}}
		"hints_received": []  # [hint_id, ...]
	},
	"runs": {
		"total_runs": 0,
		"successful_runs": 0,
		"total_deaths": 0,
		"best_time": INF,
		"total_rewards": 0
	},
	"unlocks": {
		"ending_unlocked": false,
		"all_logs_found": false,
		"all_bosses_defeated": false
	},
	"statistics": {
		"total_playtime": 0.0,
		"cards_discovered": 0,
		"connections_made": 0,
		"hints_used": 0
	}
}

## Current session data (reset each run)
var current_session := {
	"hints_available": 3,
	"hints_used": 0,
	"evidence_this_run": [],
	"run_start_time": 0.0,
	"run_duration": 0.0
}

func _ready() -> void:
	load_meta_state()

## Load persistent meta-progression state
func load_meta_state() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[MetaProgression] No save file found, using default state")
		save_meta_state()
		meta_state_loaded.emit()
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("[MetaProgression] Failed to open save file: " + str(FileAccess.get_open_error()))
		return false

	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	file.close()

	if parse_result != OK:
		push_error("[MetaProgression] Failed to parse save file: " + json.get_error_message())
		return false

	var loaded_data = json.data
	if loaded_data.has("version"):
		# Merge loaded data with default structure to handle version upgrades
		_merge_state(meta_state, loaded_data)
		print("[MetaProgression] Meta state loaded successfully (v" + str(loaded_data.version) + ")")
	else:
		push_warning("[MetaProgression] Save file has no version, using default state")

	meta_state_loaded.emit()
	return true

## Save persistent meta-progression state
func save_meta_state() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[MetaProgression] Failed to create save file: " + str(FileAccess.get_open_error()))
		return false

	# Godot 4.4+: store_string returns bool indicating success
	if not file.store_string(JSON.stringify(meta_state, "\t")):
		push_error("[MetaProgression] Failed to write meta state")
		file.close()
		return false
	file.close()

	meta_state_saved.emit()
	print("[MetaProgression] Meta state saved successfully")
	return true

## Merge loaded state into default state structure (handles version upgrades)
func _merge_state(target: Dictionary, source: Dictionary) -> void:
	for key in source:
		if target.has(key):
			if typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
				_merge_state(target[key], source[key])
			else:
				target[key] = source[key]

## Save card position on conspiracy board
func save_card_position(card_id: String, position: Vector2) -> void:
	meta_state.conspiracy_board.card_positions[card_id] = {"x": position.x, "y": position.y}
	progression_updated.emit("card_position", card_id)

## Get saved card position
func get_card_position(card_id: String) -> Vector2:
	if meta_state.conspiracy_board.card_positions.has(card_id):
		var pos = meta_state.conspiracy_board.card_positions[card_id]
		return Vector2(pos.x, pos.y)
	return Vector2.ZERO

## Save connection between cards
func save_connection(from_id: String, to_id: String, connection_type: String) -> void:
	var connection := {"from": from_id, "to": to_id, "type": connection_type}
	if connection not in meta_state.conspiracy_board.connections:
		meta_state.conspiracy_board.connections.append(connection)
		meta_state.statistics.connections_made += 1
		progression_updated.emit("connection", connection)

## Remove connection between cards
func remove_connection(from_id: String, to_id: String) -> void:
	meta_state.conspiracy_board.connections = meta_state.conspiracy_board.connections.filter(
		func(conn): return not (conn.from == from_id and conn.to == to_id)
	)
	progression_updated.emit("connection_removed", {"from": from_id, "to": to_id})

## Get all connections
func get_connections() -> Array:
	return meta_state.conspiracy_board.connections

## Add discovery to conspiracy board
func add_discovery(discovery_id: String) -> void:
	if discovery_id not in meta_state.conspiracy_board.discoveries:
		meta_state.conspiracy_board.discoveries.append(discovery_id)
		progression_updated.emit("discovery", discovery_id)

## Check if discovery has been made
func has_discovery(discovery_id: String) -> bool:
	return discovery_id in meta_state.conspiracy_board.discoveries

## Save note for card
func save_card_note(card_id: String, note: String) -> void:
	meta_state.conspiracy_board.notes[card_id] = note
	progression_updated.emit("note", card_id)

## Get card note
func get_card_note(card_id: String) -> String:
	return meta_state.conspiracy_board.notes.get(card_id, "")

## Start new run
func start_run() -> void:
	current_session.hints_available = 3
	current_session.hints_used = 0
	current_session.evidence_this_run = []
	current_session.run_start_time = Time.get_ticks_msec() / 1000.0
	meta_state.runs.total_runs += 1
	print("[MetaProgression] Run started: #" + str(meta_state.runs.total_runs))

## End run (death)
func end_run_death() -> int:
	current_session.run_duration = (Time.get_ticks_msec() / 1000.0) - current_session.run_start_time
	meta_state.runs.total_deaths += 1

	# 50% rewards on death
	var rewards := _calculate_run_rewards() / 2
	meta_state.runs.total_rewards += rewards

	print("[MetaProgression] Run ended (death): %d rewards (50%%)" % rewards)
	save_meta_state()
	return rewards

## End run (victory)
func end_run_victory() -> int:
	current_session.run_duration = (Time.get_ticks_msec() / 1000.0) - current_session.run_start_time
	meta_state.runs.successful_runs += 1

	# Update best time
	if current_session.run_duration < meta_state.runs.best_time:
		meta_state.runs.best_time = current_session.run_duration

	# 150% rewards on victory
	var rewards := int(_calculate_run_rewards() * 1.5)
	meta_state.runs.total_rewards += rewards

	print("[MetaProgression] Run ended (victory): %d rewards (150%%)" % rewards)
	save_meta_state()
	return rewards

## Calculate base run rewards
func _calculate_run_rewards() -> int:
	var base_reward := 100
	var evidence_bonus := current_session.evidence_this_run.size() * 50
	var time_bonus := max(0, 500 - int(current_session.run_duration))
	return base_reward + evidence_bonus + time_bonus

## Get run statistics
func get_run_stats() -> Dictionary:
	return {
		"total_runs": meta_state.runs.total_runs,
		"successful_runs": meta_state.runs.successful_runs,
		"total_deaths": meta_state.runs.total_deaths,
		"win_rate": (float(meta_state.runs.successful_runs) / max(1, meta_state.runs.total_runs)) * 100.0,
		"best_time": meta_state.runs.best_time,
		"total_rewards": meta_state.runs.total_rewards
	}

## Check ending unlock condition (all 7 logs + both bosses)
func check_ending_unlock() -> bool:
	var all_logs := meta_state.evidence.unlocked_logs.size() >= 7
	var lobbyist_defeated := meta_state.evidence.boss_defeats.get("lobbyist", 0) > 0
	var ceo_defeated := meta_state.evidence.boss_defeats.get("ceo", 0) > 0

	meta_state.unlocks.all_logs_found = all_logs
	meta_state.unlocks.all_bosses_defeated = lobbyist_defeated and ceo_defeated
	meta_state.unlocks.ending_unlocked = all_logs and lobbyist_defeated and ceo_defeated

	if meta_state.unlocks.ending_unlocked:
		print("[MetaProgression] ENDING UNLOCKED! All conditions met.")
		progression_updated.emit("ending_unlocked", true)

	return meta_state.unlocks.ending_unlocked

## Get unlock status
func get_unlock_status() -> Dictionary:
	return {
		"ending_unlocked": meta_state.unlocks.ending_unlocked,
		"all_logs_found": meta_state.unlocks.all_logs_found,
		"all_bosses_defeated": meta_state.unlocks.all_bosses_defeated,
		"logs_collected": meta_state.evidence.unlocked_logs.size(),
		"logs_needed": 7
	}

## Reset all meta-progression (for debugging/new game+)
func reset_meta_progression() -> void:
	meta_state = {
		"version": VERSION,
		"conspiracy_board": {
			"card_positions": {},
			"connections": [],
			"discoveries": [],
			"notes": {}
		},
		"evidence": {
			"unlocked_logs": [],
			"boss_defeats": {},
			"total_evidence_pieces": 0
		},
		"informants": {
			"unlocked": [],
			"dialogue_progress": {},
			"hints_received": []
		},
		"runs": {
			"total_runs": 0,
			"successful_runs": 0,
			"total_deaths": 0,
			"best_time": INF,
			"total_rewards": 0
		},
		"unlocks": {
			"ending_unlocked": false,
			"all_logs_found": false,
			"all_bosses_defeated": false
		},
		"statistics": {
			"total_playtime": 0.0,
			"cards_discovered": 0,
			"connections_made": 0,
			"hints_used": 0
		}
	}
	save_meta_state()
	print("[MetaProgression] Meta-progression reset")
