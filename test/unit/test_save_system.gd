## Comprehensive unit tests for Epic-009 Save System
## Tests all 10 stories: SAVE-001 through SAVE-010
extends GutTest

const SaveData = preload("res://core/scripts/save_data.gd")
const Checksum = preload("res://core/scripts/checksum.gd")
const SaveMigration = preload("res://core/scripts/save_migration.gd")
const SteamCloud = preload("res://core/scripts/steam_cloud.gd")
const SaveManager = preload("res://core/scripts/save_manager.gd")

var save_manager: SaveManager
var test_save_path := "user://test_save.json"
var test_backup_path := "user://test_save.json.bak"
var test_temp_path := "user://test_save.json.tmp"

func before_each() -> void:
	save_manager = SaveManager.new()
	add_child_autofree(save_manager)
	_clean_test_files()

func after_each() -> void:
	_clean_test_files()

func _clean_test_files() -> void:
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove(test_save_path)
		dir.remove(test_backup_path)
		dir.remove(test_temp_path)
		dir.remove("savegame.json")
		dir.remove("savegame.json.bak")
		dir.remove("savegame.json.tmp")

## SAVE-001: JSON save structure with version, checksum, all data
func test_save_data_initialization() -> void:
	var save_data := SaveData.new()

	assert_not_null(save_data, "SaveData should be created")
	assert_eq(save_data.version, 1, "Version should be 1")
	assert_false(save_data.timestamp.is_empty(), "Timestamp should be set")
	assert_true(save_data.checksum.is_empty(), "Checksum should be empty on init")
	assert_false(save_data.player_data.is_empty(), "Player data should be initialized")
	assert_false(save_data.conspiracy_data.is_empty(), "Conspiracy data should be initialized")
	assert_false(save_data.metagame_data.is_empty(), "Metagame data should be initialized")
	assert_false(save_data.settings_data.is_empty(), "Settings data should be initialized")

func test_save_data_to_dict() -> void:
	var save_data := SaveData.new()
	save_data.player_data["level"] = 5
	save_data.player_data["xp"] = 1000

	var dict := save_data.to_dict()

	assert_eq(dict["version"], 1, "Dictionary should contain version")
	assert_eq(dict["player_data"]["level"], 5, "Dictionary should contain player level")
	assert_eq(dict["player_data"]["xp"], 1000, "Dictionary should contain player xp")

func test_save_data_from_dict() -> void:
	var original := SaveData.new()
	original.player_data["level"] = 10
	original.player_data["deaths"] = 3

	var dict := original.to_dict()
	var loaded := SaveData.new()
	loaded.from_dict(dict)

	assert_eq(loaded.player_data["level"], 10, "Level should be loaded correctly")
	assert_eq(loaded.player_data["deaths"], 3, "Deaths should be loaded correctly")

func test_save_data_to_json_string() -> void:
	var save_data := SaveData.new()
	var json_string := save_data.to_json_string()

	assert_false(json_string.is_empty(), "JSON string should not be empty")
	assert_true(json_string.contains("version"), "JSON should contain version")
	assert_true(json_string.contains("player_data"), "JSON should contain player_data")
	assert_false(json_string.contains("checksum"), "JSON should not contain checksum field")

func test_save_data_validation() -> void:
	var valid_save := SaveData.new()
	assert_true(valid_save.is_valid(), "Initialized save should be valid")

	var invalid_save := SaveData.new()
	invalid_save.version = 0
	assert_false(invalid_save.is_valid(), "Save with version 0 should be invalid")

func test_save_data_deep_copy() -> void:
	var original := SaveData.new()
	original.player_data["level"] = 7

	var copy := original.duplicate_data()
	copy.player_data["level"] = 10

	assert_eq(original.player_data["level"], 7, "Original should not be modified")
	assert_eq(copy.player_data["level"], 10, "Copy should have new value")

## SAVE-002: CRC32 checksum validation
func test_checksum_crc32_calculation() -> void:
	var data := "Hello, World!"
	var checksum := Checksum.calculate_crc32(data)

	assert_not_null(checksum, "Checksum should be calculated")
	assert_eq(checksum.length(), 8, "CRC32 should be 8 hex characters")
	assert_false(checksum.is_empty(), "Checksum should not be empty")

func test_checksum_consistency() -> void:
	var data := "Test data for consistency"
	var checksum1 := Checksum.calculate_crc32(data)
	var checksum2 := Checksum.calculate_crc32(data)

	assert_eq(checksum1, checksum2, "Same data should produce same checksum")

func test_checksum_different_data() -> void:
	var data1 := "First data"
	var data2 := "Second data"
	var checksum1 := Checksum.calculate_crc32(data1)
	var checksum2 := Checksum.calculate_crc32(data2)

	assert_ne(checksum1, checksum2, "Different data should produce different checksums")

func test_checksum_validation() -> void:
	var data := "Validate this data"
	var checksum := Checksum.calculate_crc32(data)

	assert_true(Checksum.validate(data, checksum), "Valid checksum should pass")
	assert_false(Checksum.validate(data, "00000000"), "Invalid checksum should fail")
	assert_false(Checksum.validate("Wrong data", checksum), "Wrong data should fail")

func test_checksum_for_save_data() -> void:
	var save_data := SaveData.new()
	save_data.player_data["level"] = 5

	var checksum := Checksum.calculate_for_save(save_data)

	assert_not_null(checksum, "Save checksum should be calculated")
	assert_eq(checksum.length(), 8, "Save checksum should be 8 hex characters")

func test_checksum_save_validation() -> void:
	var save_data := SaveData.new()
	save_data.checksum = Checksum.calculate_for_save(save_data)

	assert_true(Checksum.validate_save(save_data), "Valid save should pass checksum")

	save_data.player_data["level"] = 999  # Modify data after checksum
	assert_false(Checksum.validate_save(save_data), "Modified save should fail checksum")

func test_checksum_empty() -> void:
	var save_data := SaveData.new()
	save_data.checksum = ""

	assert_false(Checksum.validate_save(save_data), "Empty checksum should fail validation")

## SAVE-003: Atomic write with temp file and backup
func test_save_game_creates_file() -> void:
	var save_data := SaveData.new()
	var success := save_manager.save_game(save_data)

	assert_true(success, "Save should succeed")
	assert_true(FileAccess.file_exists(SaveManager.SAVE_PATH), "Save file should exist")

func test_save_game_atomic_write() -> void:
	# First save
	var save1 := SaveData.new()
	save1.player_data["level"] = 1
	save_manager.save_game(save1)

	# Second save (should create backup of first)
	var save2 := SaveData.new()
	save2.player_data["level"] = 2
	save_manager.save_game(save2)

	assert_true(FileAccess.file_exists(SaveManager.SAVE_PATH), "Main save should exist")
	assert_true(FileAccess.file_exists(SaveManager.SAVE_BACKUP_PATH), "Backup should exist")

	# Load main save
	var loaded := save_manager.load_game()
	assert_eq(loaded.player_data["level"], 2, "Main save should have level 2")

func test_save_game_verifies_write() -> void:
	var save_data := SaveData.new()
	save_data.player_data["test"] = "verification"

	var success := save_manager.save_game(save_data)
	assert_true(success, "Save should verify correctly")

	# Load and verify content
	var loaded := save_manager.load_game()
	assert_eq(loaded.player_data["test"], "verification", "Saved data should match")

func test_save_game_updates_checksum() -> void:
	var save_data := SaveData.new()
	save_data.player_data["level"] = 3

	save_manager.save_game(save_data)
	assert_false(save_data.checksum.is_empty(), "Checksum should be set after save")

func test_save_game_updates_timestamp() -> void:
	var save_data := SaveData.new()
	var original_timestamp := save_data.timestamp

	await get_tree().create_timer(0.1).timeout  # Small delay

	save_manager.save_game(save_data)
	assert_ne(save_data.timestamp, original_timestamp, "Timestamp should be updated")

## SAVE-004: Save on death trigger
func test_trigger_death_save() -> void:
	save_manager.current_save = SaveData.new()
	var initial_deaths := save_manager.current_save.player_data["deaths"]

	save_manager.trigger_death_save()

	assert_eq(save_manager.current_save.player_data["deaths"], initial_deaths + 1, "Death count should increment")
	assert_true(FileAccess.file_exists(SaveManager.SAVE_PATH), "Save should be created on death")

func test_trigger_death_save_creates_save() -> void:
	save_manager.current_save = null
	save_manager.trigger_death_save()

	assert_not_null(save_manager.current_save, "Death should create new save if none exists")

## SAVE-005: Save on conspiracy connection (debounced)
func test_trigger_conspiracy_save_debounced() -> void:
	save_manager.current_save = SaveData.new()

	# Trigger multiple times quickly
	save_manager.trigger_conspiracy_save()
	save_manager.trigger_conspiracy_save()
	save_manager.trigger_conspiracy_save()

	# Should only save once after debounce
	await get_tree().create_timer(SaveManager.CONSPIRACY_SAVE_DEBOUNCE + 0.1).timeout
	assert_true(FileAccess.file_exists(SaveManager.SAVE_PATH), "Save should exist after debounce")

## SAVE-006: Save on settings change
func test_trigger_settings_save() -> void:
	save_manager.current_save = SaveData.new()
	save_manager.trigger_settings_save()

	assert_true(FileAccess.file_exists(SaveManager.SAVE_PATH), "Save should be created on settings change")

## SAVE-007: Save on exit (tested via notification)
func test_exit_save_notification() -> void:
	save_manager.current_save = SaveData.new()
	save_manager._notification(NOTIFICATION_WM_CLOSE_REQUEST)

	# Note: This will queue quit, but in test we just verify save was called
	assert_true(FileAccess.file_exists(SaveManager.SAVE_PATH), "Save should be created on exit")

## SAVE-008: Steam Cloud sync (STUB)
func test_steam_cloud_unavailable() -> void:
	var steam := SteamCloud.new()
	steam.initialize()

	assert_false(steam.is_available(), "Steam Cloud should be unavailable (stub)")
	assert_eq(steam.get_status(), SteamCloud.CloudStatus.UNAVAILABLE, "Status should be UNAVAILABLE")

func test_steam_cloud_status_string() -> void:
	var steam := SteamCloud.new()
	var status_string := steam.get_status_string()

	assert_true(status_string.contains("Unavailable"), "Status string should mention unavailable")
	assert_true(status_string.contains("GodotSteam"), "Status string should mention GodotSteam")

func test_steam_cloud_upload_stub() -> void:
	var steam := SteamCloud.new()
	steam.initialize()

	var result := steam.upload_file("local.json", "cloud.json")
	assert_false(result, "Upload should fail in stub mode")

func test_steam_cloud_download_stub() -> void:
	var steam := SteamCloud.new()
	steam.initialize()

	var result := steam.download_file("cloud.json", "local.json")
	assert_false(result, "Download should fail in stub mode")

## SAVE-009: Corrupt save recovery from backup
func test_corrupt_save_recovery() -> void:
	# Create a valid save
	var valid_save := SaveData.new()
	valid_save.player_data["level"] = 5
	save_manager.save_game(valid_save)

	# Corrupt the main save file
	var corrupt_file := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
	corrupt_file.store_string("THIS IS CORRUPTED DATA!!!")
	corrupt_file.close()

	# Try to load - should recover from backup
	var loaded := save_manager.load_game()

	assert_not_null(loaded, "Should recover from backup")
	assert_eq(loaded.player_data["level"], 5, "Recovered data should match original")

func test_corrupt_save_both_files() -> void:
	# Corrupt both files
	var corrupt_main := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
	corrupt_main.store_string("CORRUPTED")
	corrupt_main.close()

	var corrupt_backup := FileAccess.open(SaveManager.SAVE_BACKUP_PATH, FileAccess.WRITE)
	corrupt_backup.store_string("ALSO CORRUPTED")
	corrupt_backup.close()

	# Should fail to load
	var loaded := save_manager.load_game()
	assert_null(loaded, "Should fail when both files are corrupt")

func test_checksum_detects_corruption() -> void:
	var save_data := SaveData.new()
	save_data.checksum = Checksum.calculate_for_save(save_data)

	# Manually corrupt data
	save_data.player_data["level"] = 9999

	assert_false(Checksum.validate_save(save_data), "Checksum should detect corruption")

## SAVE-010: Save migration for version handling
func test_save_migration_current_version() -> void:
	var save_data := SaveData.new()
	assert_false(SaveMigration.needs_migration(save_data), "Current version should not need migration")

	var result := SaveMigration.migrate_to_current(save_data)
	assert_true(result, "Migration of current version should succeed")

func test_save_migration_needs_check() -> void:
	var old_save := SaveData.new()
	old_save.version = 0

	assert_true(SaveMigration.needs_migration(old_save), "Old version should need migration")

func test_save_migration_path() -> void:
	var path := SaveMigration.get_migration_path(0)
	assert_false(path.is_empty(), "Migration path should exist for old versions")

func test_save_migration_newer_version() -> void:
	var future_save := SaveData.new()
	future_save.version = 999

	var result := SaveMigration.migrate_to_current(future_save)
	assert_false(result, "Future version should fail migration")

## Integration tests
func test_full_save_load_cycle() -> void:
	# Create and save
	var original := SaveData.new()
	original.player_data["level"] = 10
	original.player_data["xp"] = 5000
	original.player_data["deaths"] = 3
	original.conspiracy_data["discovered_logs"] = ["log1", "log2"]

	save_manager.save_game(original)

	# Load
	var loaded := save_manager.load_game()

	assert_not_null(loaded, "Load should succeed")
	assert_eq(loaded.player_data["level"], 10, "Level should match")
	assert_eq(loaded.player_data["xp"], 5000, "XP should match")
	assert_eq(loaded.player_data["deaths"], 3, "Deaths should match")
	assert_eq(loaded.conspiracy_data["discovered_logs"].size(), 2, "Discovered logs should match")

func test_save_info() -> void:
	var save_data := SaveData.new()
	save_data.player_data["level"] = 7
	save_manager.save_game(save_data)

	var info := save_manager.get_save_info()

	assert_true(info["exists"], "Save should exist")
	assert_eq(info["player_level"], 7, "Level should be in info")
	assert_false(info["corrupted"], "Save should not be corrupted")

func test_create_new_save() -> void:
	var new_save := save_manager.create_new_save()

	assert_not_null(new_save, "New save should be created")
	assert_true(FileAccess.file_exists(SaveManager.SAVE_PATH), "Save file should exist")

func test_delete_save() -> void:
	save_manager.create_new_save()
	assert_true(save_manager.save_exists(), "Save should exist")

	var success := save_manager.delete_save()
	assert_true(success, "Delete should succeed")
	assert_false(save_manager.save_exists(), "Save should not exist after delete")

func test_save_exists() -> void:
	assert_false(save_manager.save_exists(), "Save should not exist initially")

	save_manager.create_new_save()
	assert_true(save_manager.save_exists(), "Save should exist after creation")
