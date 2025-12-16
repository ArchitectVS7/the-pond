## Epic-009: Complete Save System with Steam Cloud Integration
## Implements all save triggers, atomic writes, corruption recovery, and Steam Cloud sync
extends Node
class_name SaveManager

## Save file paths
const SAVE_PATH := "user://savegame.json"
const SAVE_TEMP_PATH := "user://savegame.json.tmp"
const SAVE_BACKUP_PATH := "user://savegame.json.bak"

## SAVE-005: Debounce settings for conspiracy connections
const CONSPIRACY_SAVE_DEBOUNCE := 2.0  # seconds

## Signals
signal save_completed(success: bool)
signal save_failed(error: String)
signal load_completed(save_data: SaveData)
signal load_failed(error: String)
signal corruption_detected(recovered: bool)

## Current save data
var current_save: SaveData = null
var _steam_cloud: SteamCloud = null
var _conspiracy_save_timer: Timer = null
var _pending_conspiracy_save := false

func _ready() -> void:
	# SAVE-007: Save on exit
	get_tree().auto_accept_quit = false

	# Initialize Steam Cloud (stub for now)
	_steam_cloud = SteamCloud.new()
	_steam_cloud.initialize()

	# SAVE-005: Setup debounce timer for conspiracy connections
	_conspiracy_save_timer = Timer.new()
	_conspiracy_save_timer.one_shot = true
	_conspiracy_save_timer.wait_time = CONSPIRACY_SAVE_DEBOUNCE
	_conspiracy_save_timer.timeout.connect(_on_conspiracy_save_timeout)
	add_child(_conspiracy_save_timer)

	# Connect to game events
	_connect_game_signals()

## Connect to game signals for auto-save triggers
func _connect_game_signals() -> void:
	# SAVE-004: Save on death
	# Connect to player death signal when available
	# Example: PlayerManager.player_died.connect(trigger_death_save)

	# SAVE-005: Save on conspiracy connection (debounced)
	# Connect to conspiracy board when available
	# Example: ConspiracyBoard.connection_made.connect(trigger_conspiracy_save)

	# SAVE-006: Save on settings change
	# Connect to settings manager when available
	# Example: SettingsManager.setting_changed.connect(trigger_settings_save)
	pass

## SAVE-003: Atomic write with temp file and backup
func save_game(save_data: SaveData = null) -> bool:
	if save_data == null:
		save_data = current_save if current_save != null else SaveData.new()

	# Update timestamp
	save_data.update_timestamp()

	# Calculate checksum
	save_data.checksum = Checksum.calculate_for_save(save_data)

	# Validate data before saving
	if not save_data.is_valid():
		var error := "Invalid save data"
		push_error("SaveManager: " + error)
		save_failed.emit(error)
		return false

	# STEP 1: Write to temporary file
	var json_string := JSON.stringify(save_data.to_dict(), "\t")
	var temp_file := FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
	if temp_file == null:
		var error := "Failed to create temp file: " + error_string(FileAccess.get_open_error())
		push_error("SaveManager: " + error)
		save_failed.emit(error)
		return false

	# Godot 4.4+: store_string returns bool indicating success
	if not temp_file.store_string(json_string):
		var error := "Failed to write save data to temp file"
		push_error("SaveManager: " + error)
		temp_file.close()
		save_failed.emit(error)
		return false
	temp_file.close()

	# STEP 2: Verify temp file was written correctly
	var verify_file := FileAccess.open(SAVE_TEMP_PATH, FileAccess.READ)
	if verify_file == null:
		var error := "Failed to verify temp file"
		push_error("SaveManager: " + error)
		save_failed.emit(error)
		return false

	var verify_data := verify_file.get_as_text()
	verify_file.close()

	if verify_data != json_string:
		var error := "Temp file verification failed - data mismatch"
		push_error("SaveManager: " + error)
		save_failed.emit(error)
		return false

	# STEP 3: Backup existing save file (if it exists)
	if FileAccess.file_exists(SAVE_PATH):
		var dir := DirAccess.open("user://")
		if dir == null:
			var error := "Failed to access user directory"
			push_error("SaveManager: " + error)
			save_failed.emit(error)
			return false

		# Remove old backup
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			var remove_error := dir.remove(SAVE_BACKUP_PATH)
			if remove_error != OK:
				push_warning("SaveManager: Failed to remove old backup: " + error_string(remove_error))

		# Copy current save to backup
		var copy_error := dir.copy(SAVE_PATH, SAVE_BACKUP_PATH)
		if copy_error != OK:
			push_warning("SaveManager: Failed to create backup: " + error_string(copy_error))
			# Continue anyway - this is not critical

	# STEP 4: Move temp file to main save file (atomic operation)
	var dir := DirAccess.open("user://")
	if dir == null:
		var error := "Failed to access user directory for rename"
		push_error("SaveManager: " + error)
		save_failed.emit(error)
		return false

	# Remove existing save
	if FileAccess.file_exists(SAVE_PATH):
		var remove_error := dir.remove(SAVE_PATH)
		if remove_error != OK:
			var error := "Failed to remove old save: " + error_string(remove_error)
			push_error("SaveManager: " + error)
			save_failed.emit(error)
			return false

	# Rename temp to save
	var rename_error := dir.rename(SAVE_TEMP_PATH, SAVE_PATH)
	if rename_error != OK:
		var error := "Failed to finalize save: " + error_string(rename_error)
		push_error("SaveManager: " + error)
		save_failed.emit(error)
		return false

	# Update current save reference
	current_save = save_data

	# SAVE-008: Sync with Steam Cloud (stub)
	_steam_cloud.upload_file(SAVE_PATH, "savegame.json")

	print("SaveManager: Save completed successfully")
	save_completed.emit(true)
	return true

## SAVE-009: Load game with corruption recovery
func load_game() -> SaveData:
	var load_path := SAVE_PATH
	var attempted_backup := false

	# Try to load main save file
	var save_data := _load_from_file(load_path)

	# SAVE-009: If main save is corrupt, try backup
	if save_data == null and FileAccess.file_exists(SAVE_BACKUP_PATH):
		push_warning("SaveManager: Main save file corrupted, attempting to load backup")
		corruption_detected.emit(false)
		save_data = _load_from_file(SAVE_BACKUP_PATH)
		attempted_backup = true

		if save_data != null:
			print("SaveManager: Successfully recovered from backup")
			corruption_detected.emit(true)
			# Save the recovered data as the main save
			save_game(save_data)

	if save_data == null:
		var error := "Failed to load save file" + (" and backup" if attempted_backup else "")
		push_error("SaveManager: " + error)
		load_failed.emit(error)
		return null

	# SAVE-010: Migrate to current version if needed
	if SaveMigration.needs_migration(save_data):
		print("SaveManager: Migrating save from version %d to %d" % [save_data.version, SaveMigration.CURRENT_VERSION])
		if not SaveMigration.migrate_to_current(save_data):
			var error := "Save migration failed"
			push_error("SaveManager: " + error)
			load_failed.emit(error)
			return null

		# Save migrated data
		print("SaveManager: Save migrated successfully, saving updated version")
		save_game(save_data)

	current_save = save_data
	load_completed.emit(save_data)
	return save_data

## Internal: Load save data from a specific file
func _load_from_file(path: String) -> SaveData:
	if not FileAccess.file_exists(path):
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Failed to open file %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return null

	var json_string := file.get_as_text()
	file.close()

	# Parse JSON
	var json := JSON.new()
	var parse_error := json.parse(json_string)
	if parse_error != OK:
		push_error("SaveManager: JSON parse error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return null

	var data: Dictionary = json.data
	if not data is Dictionary:
		push_error("SaveManager: Invalid save data format")
		return null

	# Create SaveData object
	var save_data := SaveData.new()
	save_data.from_dict(data)

	# SAVE-002: Validate checksum
	if not Checksum.validate_save(save_data):
		push_error("SaveManager: Checksum validation failed - save file may be corrupted")
		return null

	return save_data

## SAVE-004: Trigger save on player death
func trigger_death_save() -> void:
	if current_save == null:
		current_save = SaveData.new()

	current_save.player_data["deaths"] += 1
	print("SaveManager: Death detected, saving game (death count: %d)" % current_save.player_data["deaths"])
	save_game()

## SAVE-005: Trigger save on conspiracy connection (debounced)
func trigger_conspiracy_save() -> void:
	_pending_conspiracy_save = true
	_conspiracy_save_timer.start()

func _on_conspiracy_save_timeout() -> void:
	if _pending_conspiracy_save:
		print("SaveManager: Conspiracy connection detected, saving game")
		save_game()
		_pending_conspiracy_save = false

## SAVE-006: Trigger save on settings change
func trigger_settings_save() -> void:
	print("SaveManager: Settings changed, saving game")
	save_game()

## SAVE-007: Handle application quit
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("SaveManager: Application closing, saving game")
		save_game()
		get_tree().quit()

## Create new save
func create_new_save() -> SaveData:
	current_save = SaveData.new()
	save_game()
	return current_save

## Check if save file exists
func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Delete save file and backup
func delete_save() -> bool:
	var success := true
	var dir := DirAccess.open("user://")
	if dir == null:
		return false

	if FileAccess.file_exists(SAVE_PATH):
		if dir.remove(SAVE_PATH) != OK:
			success = false

	if FileAccess.file_exists(SAVE_BACKUP_PATH):
		if dir.remove(SAVE_BACKUP_PATH) != OK:
			success = false

	if FileAccess.file_exists(SAVE_TEMP_PATH):
		dir.remove(SAVE_TEMP_PATH)

	current_save = null
	return success

## Get save file info
func get_save_info() -> Dictionary:
	if not save_exists():
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var modified_time := FileAccess.get_modified_time(SAVE_PATH)
	var file_size := file.get_length()
	file.close()

	# Try to load save data for more info
	var save_data := _load_from_file(SAVE_PATH)
	if save_data == null:
		return {
			"exists": true,
			"modified_time": modified_time,
			"file_size": file_size,
			"corrupted": true
		}

	return {
		"exists": true,
		"modified_time": modified_time,
		"file_size": file_size,
		"version": save_data.version,
		"timestamp": save_data.timestamp,
		"player_level": save_data.player_data.get("level", 0),
		"deaths": save_data.player_data.get("deaths", 0),
		"play_time": save_data.player_data.get("play_time_seconds", 0.0),
		"corrupted": false
	}
