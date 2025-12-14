# Save System

The save system uses JSON files with checksums and atomic writes. If the main save corrupts, it recovers from backup. This chapter covers the implementation.

---

## Save File Locations

```gdscript
const SAVE_PATH := "user://savegame.json"
const SAVE_TEMP_PATH := "user://savegame.json.tmp"
const SAVE_BACKUP_PATH := "user://savegame.json.bak"
```

| File | Purpose |
|------|---------|
| `savegame.json` | Main save file |
| `savegame.json.tmp` | Temporary write target |
| `savegame.json.bak` | Backup for recovery |

On Windows: `%APPDATA%\Godot\app_userdata\The Pond\`
On Linux: `~/.local/share/godot/app_userdata/The Pond/`

---

## SaveData Structure

**File**: `core/scripts/save_data.gd`

```gdscript
class_name SaveData
extends RefCounted

const SAVE_VERSION := 1

var version: int = SAVE_VERSION
var timestamp: String = ""
var checksum: String = ""
var player_data: Dictionary = {}
var conspiracy_data: Dictionary = {}
var metagame_data: Dictionary = {}
var settings_data: Dictionary = {}
```

### Player Data

```gdscript
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
```

### Conspiracy Data

```gdscript
conspiracy_data = {
    "discovered_logs": [],      # Array of log IDs
    "connected_pairs": [],       # Array of [log_a, log_b] pairs
    "board_layout": [],          # Card positions
    "completion_percentage": 0.0,
    "unlocked_documents": [],
    "reading_progress": {}       # {log_id: scroll_position}
}
```

### Metagame Data

```gdscript
metagame_data = {
    "pollution_level": 0.0,
    "unlocked_abilities": [],
    "synergy_discoveries": [],
    "mutation_tree_progress": {},
    "achievements": []
}
```

---

## Atomic Write Process

Saves use a three-step atomic write to prevent corruption:

```gdscript
func save_game(save_data: SaveData) -> bool:
    # STEP 1: Write to temporary file
    var json_string := JSON.stringify(save_data.to_dict(), "\t")
    var temp_file := FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
    temp_file.store_string(json_string)
    temp_file.close()

    # STEP 2: Verify temp file was written correctly
    var verify_file := FileAccess.open(SAVE_TEMP_PATH, FileAccess.READ)
    var verify_data := verify_file.get_as_text()
    verify_file.close()

    if verify_data != json_string:
        return false  # Write verification failed

    # STEP 3: Backup existing save, then rename temp to main
    if FileAccess.file_exists(SAVE_PATH):
        dir.copy(SAVE_PATH, SAVE_BACKUP_PATH)

    dir.rename(SAVE_TEMP_PATH, SAVE_PATH)
    return true
```

**Why atomic writes matter**: If the game crashes during a save, the worst case is a corrupt temp file. The main save and backup remain intact.

---

## Checksum Validation

Each save includes a checksum for integrity verification:

```gdscript
# Calculate checksum before saving
save_data.checksum = Checksum.calculate_for_save(save_data)

# Validate checksum on load
if not Checksum.validate_save(save_data):
    push_error("Checksum validation failed")
    return null
```

The checksum is calculated over all save data except the checksum field itself.

---

## Corruption Recovery

If the main save is corrupt, recovery is automatic:

```gdscript
func load_game() -> SaveData:
    var save_data := _load_from_file(SAVE_PATH)

    # If main save is corrupt, try backup
    if save_data == null and FileAccess.file_exists(SAVE_BACKUP_PATH):
        push_warning("Main save corrupted, loading backup")
        corruption_detected.emit(false)

        save_data = _load_from_file(SAVE_BACKUP_PATH)

        if save_data != null:
            corruption_detected.emit(true)  # Recovery successful
            save_game(save_data)  # Restore main save
```

---

## Save Triggers

### Death Save (SAVE-004)

```gdscript
func trigger_death_save() -> void:
    current_save.player_data["deaths"] += 1
    save_game()
```

### Conspiracy Connection Save (SAVE-005)

Conspiracy connections use debouncing to avoid excessive saves:

```gdscript
const CONSPIRACY_SAVE_DEBOUNCE := 2.0  # seconds

func trigger_conspiracy_save() -> void:
    _pending_conspiracy_save = true
    _conspiracy_save_timer.start()

func _on_conspiracy_save_timeout() -> void:
    if _pending_conspiracy_save:
        save_game()
        _pending_conspiracy_save = false
```

Players often make multiple connections quickly. Debouncing prevents 10 saves in 5 seconds.

### Exit Save (SAVE-007)

```gdscript
func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
        get_tree().quit()
```

---

## Version Migration

**File**: `core/scripts/save_migration.gd`

When the save format changes, migrations handle upgrades:

```gdscript
static func migrate_to_current(save_data: SaveData) -> bool:
    if save_data.version == CURRENT_VERSION:
        return true

    # Apply migrations in sequence
    var current_version := save_data.version
    while current_version < CURRENT_VERSION:
        var next_version := current_version + 1
        if not _migrate_version(save_data, next_version):
            return false
        current_version = next_version

    save_data.version = CURRENT_VERSION
    return true
```

### Adding a Migration

```gdscript
# Example: v1 to v2 migration
static func migrate_v1_to_v2(save_data: SaveData) -> bool:
    # Add new field with default value
    if not "new_field" in save_data.player_data:
        save_data.player_data["new_field"] = default_value
    return true
```

---

## Serialization

### To JSON

```gdscript
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

func to_json_string() -> String:
    var data_copy := to_dict()
    data_copy.erase("checksum")  # Don't include in checksum calculation
    return JSON.stringify(data_copy, "\t")
```

### From JSON

```gdscript
func from_dict(data: Dictionary) -> void:
    version = data.get("version", SAVE_VERSION)
    timestamp = data.get("timestamp", "")
    checksum = data.get("checksum", "")
    player_data = data.get("player_data", {})
    conspiracy_data = data.get("conspiracy_data", {})
    metagame_data = data.get("metagame_data", {})
    settings_data = data.get("settings_data", {})
```

---

## Save Info Display

For title screen save slot display:

```gdscript
func get_save_info() -> Dictionary:
    if not save_exists():
        return {}

    var save_data := _load_from_file(SAVE_PATH)

    return {
        "exists": true,
        "version": save_data.version,
        "timestamp": save_data.timestamp,
        "player_level": save_data.player_data.get("level", 0),
        "deaths": save_data.player_data.get("deaths", 0),
        "play_time": save_data.player_data.get("play_time_seconds", 0.0),
        "corrupted": false
    }
```

---

## Testing

### Manual Testing

```gdscript
# Create new save
var save_manager = SaveManager.new()
save_manager.create_new_save()

# Modify and save
save_manager.current_save.player_data["deaths"] = 5
save_manager.save_game()

# Load and verify
var loaded = save_manager.load_game()
assert(loaded.player_data["deaths"] == 5)
```

### Corruption Testing

```gdscript
# Corrupt the main save
var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
file.store_string("corrupted data")
file.close()

# Load should recover from backup
var save_data = save_manager.load_game()
assert(save_data != null)  # Should succeed via backup
```

---

## Common Issues

**Save not persisting:**
- Check `user://` path is writable
- Verify `save_game()` returns true
- Check for file permission errors

**Checksum validation failing:**
- Ensure checksum is excluded from calculation
- Check for JSON serialization differences
- Verify no data modification after checksum

**Migration not running:**
- Check `SAVE_VERSION` constant
- Verify `needs_migration()` returns true
- Add migration handler to `_migration_handlers`

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Format | JSON with version |
| Integrity | SHA256 checksum |
| Safety | Atomic write with temp file |
| Recovery | Automatic backup restore |
| Migration | Sequential version handlers |

The save system is designed to never lose player progress. Even catastrophic failures (power loss, crash) recover gracefully.

---

[← Back to Overview](overview.md) | [Next: Steam Cloud →](steam-cloud.md)
