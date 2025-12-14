# Steam Cloud

Steam Cloud allows saves to sync across devices. This chapter covers the integration (currently stubbed, pending GodotSteam).

---

## Current Status

**Status**: Stub implementation

Steam Cloud requires GodotSteam plugin integration. The current code provides the interface but doesn't connect to Steam.

```gdscript
func initialize() -> bool:
    push_warning("SteamCloud: GodotSteam not integrated yet - running in local-only mode")
    _status = CloudStatus.UNAVAILABLE
    return false
```

---

## SteamCloud Structure

**File**: `core/scripts/steam_cloud.gd`

```gdscript
class_name SteamCloud
extends RefCounted

enum CloudStatus {
    UNAVAILABLE,  # GodotSteam not integrated
    DISABLED,     # User has cloud saves disabled
    ENABLED,      # Cloud saves working
    ERROR         # Error state
}

var _status := CloudStatus.UNAVAILABLE
```

---

## Interface Methods

### Upload File

```gdscript
func upload_file(local_path: String, cloud_name: String) -> bool:
    if _status != CloudStatus.ENABLED:
        return false

    # TODO: Steam.fileWrite(cloud_name, file_data)
    return false
```

### Download File

```gdscript
func download_file(cloud_name: String, local_path: String) -> bool:
    if _status != CloudStatus.ENABLED:
        return false

    # TODO: Steam.fileRead(cloud_name)
    return false
```

### Sync File

```gdscript
func sync_file(local_path: String, cloud_name: String) -> bool:
    if _status != CloudStatus.ENABLED:
        return false

    # Compare timestamps, sync appropriately
    return false
```

---

## Integration with SaveManager

The SaveManager calls SteamCloud after local saves:

```gdscript
func save_game(save_data: SaveData) -> bool:
    # ... atomic local save ...

    # Sync with Steam Cloud
    _steam_cloud.upload_file(SAVE_PATH, "savegame.json")
    return true
```

---

## Implementation Checklist

When integrating GodotSteam:

### 1. Add GodotSteam Plugin

Download from [godotsteam.com](https://godotsteam.com/) and add to `addons/`.

### 2. Initialize Steam

```gdscript
func _ready() -> void:
    var init_result = Steam.steamInit()
    if init_result.status == 1:
        print("Steam initialized")
```

### 3. Check Cloud Status

```gdscript
func _check_cloud_available() -> bool:
    return Steam.isCloudEnabledForAccount() and Steam.isCloudEnabledForApp()
```

### 4. Implement File Operations

```gdscript
func upload_file(local_path: String, cloud_name: String) -> bool:
    var file = FileAccess.open(local_path, FileAccess.READ)
    var data = file.get_buffer(file.get_length())
    file.close()

    return Steam.fileWrite(cloud_name, data)

func download_file(cloud_name: String, local_path: String) -> bool:
    var data = Steam.fileRead(cloud_name)
    if data.is_empty():
        return false

    var file = FileAccess.open(local_path, FileAccess.WRITE)
    file.store_buffer(data)
    file.close()
    return true
```

### 5. Handle Callbacks

```gdscript
func _ready() -> void:
    Steam.connect("file_write_async_complete", _on_write_complete)
    Steam.connect("file_read_async_complete", _on_read_complete)
```

---

## Conflict Resolution

When local and cloud saves differ:

```gdscript
func resolve_conflict() -> void:
    var local_time = FileAccess.get_modified_time(SAVE_PATH)
    var cloud_time = Steam.getFileTimestamp("savegame.json")

    if cloud_time > local_time:
        # Cloud is newer - download
        download_file("savegame.json", SAVE_PATH)
    else:
        # Local is newer - upload
        upload_file(SAVE_PATH, "savegame.json")
```

### User Choice (Future)

For conflicting saves with different progress:

```gdscript
signal conflict_detected(local_info: Dictionary, cloud_info: Dictionary)

func _on_conflict() -> void:
    # Let user choose which save to keep
    var local_info = _get_save_info(SAVE_PATH)
    var cloud_info = _get_cloud_save_info()
    conflict_detected.emit(local_info, cloud_info)
```

---

## Steamworks Dashboard Setup

### Cloud Quota

In Steamworks partner dashboard:

1. Navigate to **App Admin** → **Cloud**
2. Set **Quota per user**: 1 MB (sufficient for JSON saves)
3. Set **Max files per user**: 5

### Auto-Cloud vs. Manual

The Pond uses **manual cloud** (API calls) for control over when syncing happens. Auto-cloud is simpler but less predictable.

---

## Testing Without Steam

The stub implementation allows development without Steam:

```gdscript
func is_available() -> bool:
    # Returns false in stub mode
    return false
```

Game functions normally with local saves. Cloud sync activates only when GodotSteam is integrated and Steam is running.

---

## Error Handling

```gdscript
func upload_file(local_path: String, cloud_name: String) -> bool:
    if _status != CloudStatus.ENABLED:
        return false

    var success = Steam.fileWrite(cloud_name, data)

    if not success:
        push_error("SteamCloud: Upload failed for %s" % cloud_name)
        _status = CloudStatus.ERROR
        return false

    return true
```

### Retry Logic (Future)

```gdscript
const MAX_RETRIES := 3
const RETRY_DELAY := 1.0

func upload_with_retry(local_path: String, cloud_name: String) -> bool:
    for i in range(MAX_RETRIES):
        if upload_file(local_path, cloud_name):
            return true
        await get_tree().create_timer(RETRY_DELAY).timeout

    return false
```

---

## Status Display

For settings menu:

```gdscript
func get_status_string() -> String:
    match _status:
        CloudStatus.UNAVAILABLE:
            return "Unavailable (GodotSteam not integrated)"
        CloudStatus.DISABLED:
            return "Disabled by user"
        CloudStatus.ENABLED:
            return "Enabled"
        CloudStatus.ERROR:
            return "Error - check connection"
        _:
            return "Unknown"
```

---

## Summary

| Feature | Status |
|---------|--------|
| Local saves | Complete |
| Cloud interface | Stubbed |
| Upload/download | Pending GodotSteam |
| Conflict resolution | Design ready |
| Retry logic | Future |

Steam Cloud integration is ready for GodotSteam. Once the plugin is added, replace stub methods with actual Steam API calls.

---

[← Back to Save System](save-system.md) | [Next: Informants →](informants.md)
