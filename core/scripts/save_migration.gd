## SAVE-010: Save migration for version handling
## Handles migration of save data between versions
extends RefCounted
class_name SaveMigration

const CURRENT_VERSION := 1

## Migration handlers for each version transition
static var _migration_handlers := {}

static func _static_init() -> void:
	# Register migration handlers
	# Example: _migration_handlers[2] = migrate_v1_to_v2
	pass

## Migrate save data to current version
static func migrate_to_current(save_data: SaveData) -> bool:
	if save_data.version == CURRENT_VERSION:
		return true  # Already current version

	if save_data.version > CURRENT_VERSION:
		push_error("SaveMigration: Save version %d is newer than current version %d" % [save_data.version, CURRENT_VERSION])
		return false

	# Apply migrations in sequence
	var current_version := save_data.version
	while current_version < CURRENT_VERSION:
		var next_version := current_version + 1
		if not _migrate_version(save_data, next_version):
			push_error("SaveMigration: Failed to migrate from version %d to %d" % [current_version, next_version])
			return false
		current_version = next_version

	save_data.version = CURRENT_VERSION
	return true

## Migrate to specific version
static func _migrate_version(save_data: SaveData, target_version: int) -> bool:
	if target_version in _migration_handlers:
		return _migration_handlers[target_version].call(save_data)

	# No migration needed for this version
	push_warning("SaveMigration: No migration handler for version %d, using default" % target_version)
	return true

## Example migration handler (v1 to v2)
## static func migrate_v1_to_v2(save_data: SaveData) -> bool:
##     # Add new fields, transform data, etc.
##     if not "new_field" in save_data.player_data:
##         save_data.player_data["new_field"] = default_value
##     return true

## Check if migration is needed
static func needs_migration(save_data: SaveData) -> bool:
	return save_data.version < CURRENT_VERSION

## Get migration path description
static func get_migration_path(from_version: int) -> Array[String]:
	var path: Array[String] = []
	var current := from_version
	while current < CURRENT_VERSION:
		current += 1
		path.append("v%d -> v%d" % [current - 1, current])
	return path
