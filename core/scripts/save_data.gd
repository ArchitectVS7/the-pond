## SAVE-001: JSON save structure with version, checksum, all data
## Defines the complete save data structure for The Pond
extends RefCounted
class_name SaveData

const SAVE_VERSION := 1

# Main save structure
var version: int = SAVE_VERSION
var timestamp: String = ""
var checksum: String = ""
var player_data: Dictionary = {}
var conspiracy_data: Dictionary = {}
var metagame_data: Dictionary = {}
var settings_data: Dictionary = {}

func _init() -> void:
	timestamp = Time.get_datetime_string_from_system()
	_initialize_default_data()

func _initialize_default_data() -> void:
	# Player progression
	player_data = {
		"level": 1,
		"xp": 0,
		"deaths": 0,
		"total_kills": 0,
		"play_time_seconds": 0.0,
		"position": Vector2.ZERO,
		"health": 100.0,
		"max_health": 100.0,
		"unlocked_mutations": [],
		"active_mutations": [],
		"stats": {
			"damage_dealt": 0.0,
			"damage_taken": 0.0,
			"distance_traveled": 0.0
		}
	}

	# Conspiracy board state
	conspiracy_data = {
		"discovered_logs": [],
		"connected_pairs": [],
		"board_layout": [],
		"completion_percentage": 0.0,
		"unlocked_documents": [],
		"reading_progress": {}
	}

	# Metagame state
	metagame_data = {
		"pollution_level": 0.0,
		"unlocked_abilities": [],
		"synergy_discoveries": [],
		"mutation_tree_progress": {},
		"achievements": []
	}

	# Settings (separate from config for per-save preferences)
	settings_data = {
		"difficulty": "normal",
		"accessibility_options": {}
	}

## Convert to dictionary for JSON serialization
func to_dict() -> Dictionary:
	return {
		"version": version,
		"timestamp": timestamp,
		"checksum": checksum,
		"player_data": player_data,
		"conspiracy_data": conspiracy_data,
		"metagame_data": metagame_data,
		"settings_data": settings_data
	}

## Load from dictionary (JSON deserialization)
func from_dict(data: Dictionary) -> void:
	version = data.get("version", SAVE_VERSION)
	timestamp = data.get("timestamp", "")
	checksum = data.get("checksum", "")
	player_data = data.get("player_data", {})
	conspiracy_data = data.get("conspiracy_data", {})
	metagame_data = data.get("metagame_data", {})
	settings_data = data.get("settings_data", {})

## Get JSON string representation (without checksum)
func to_json_string() -> String:
	var data_copy := to_dict()
	data_copy.erase("checksum")  # Don't include checksum in the data being checksummed
	return JSON.stringify(data_copy, "\t")

## Validate data integrity
func is_valid() -> bool:
	return version > 0 and not timestamp.is_empty() and not player_data.is_empty()

## Update timestamp
func update_timestamp() -> void:
	timestamp = Time.get_datetime_string_from_system()

## Deep copy
func duplicate_data() -> SaveData:
	var new_save := SaveData.new()
	new_save.from_dict(to_dict())
	return new_save
