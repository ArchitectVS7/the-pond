# Steam Setup

Steam integration uses GodotSteam, a third-party plugin. This chapter covers installation, configuration, and the stub implementation that's waiting for real integration.

---

## Current Status

**Status**: Stub implementation

The code provides interfaces but doesn't connect to Steam yet. Real integration requires the GodotSteam plugin.

```gdscript
func _initialize_steam() -> void:
    # STUB: Replace with actual GodotSteam.isSteamRunning() when integrated
    is_steam_available = _check_steam_available()

    if not is_steam_available:
        push_warning("SteamManager: Steam not available. Running in offline mode.")
```

---

## SteamManager Structure

**File**: `core/scripts/steam_manager.gd`

```gdscript
class_name SteamManager
extends Node

signal steam_initialized(success: bool)
signal authentication_complete(steam_id: int)
signal authentication_failed(error: String)
signal overlay_activated(active: bool)
signal achievement_unlocked(achievement_id: String)

var is_steam_available: bool = false
var steam_app_id: int = 0  # Replace with actual Steam App ID
var steam_user_id: int = 0
var steam_username: String = ""
```

---

## Installation Steps

### 1. Create Steamworks Account

1. Go to [partner.steamgames.com](https://partner.steamgames.com/)
2. Pay the $100 registration fee
3. Wait for approval (1-2 business days)
4. Create a new app entry
5. Note your App ID (replace the stub `480` Spacewar ID)

### 2. Download GodotSteam

From [godotsteam.com](https://godotsteam.com/):

1. Download the version matching your Godot version (4.2+)
2. Extract to your project's `addons/` folder
3. Structure should be:
   ```
   addons/
   └── godotsteam/
       ├── godotsteam.gdextension
       ├── libgodotsteam.*.dll (Windows)
       ├── libgodotsteam.*.so (Linux)
       └── ...
   ```

### 3. Enable the Plugin

1. Open Project Settings → Plugins
2. Enable "GodotSteam"
3. Restart Godot

### 4. Create steam_appid.txt

In your project root:

```
YOUR_APP_ID_HERE
```

This file tells Steam which app you're running during development.

---

## Replacing Stubs

### Initialize Steam

**Before (Stub)**:
```gdscript
func _stub_steam_init() -> bool:
    steam_app_id = 480  # Spacewar
    return true
```

**After (Real)**:
```gdscript
func _initialize_steam() -> void:
    var init_result = Steam.steamInit()

    if init_result.status == 1:
        is_steam_available = true
        steam_app_id = Steam.getAppID()
        _is_initialized = true
        steam_initialized.emit(true)
    else:
        push_error("Steam init failed: %s" % init_result)
        steam_initialized.emit(false)
```

### Check Steam Available

**Before (Stub)**:
```gdscript
func _check_steam_available() -> bool:
    if OS.has_environment("STEAM_RUNTIME"):
        return true
    return false
```

**After (Real)**:
```gdscript
func _check_steam_available() -> bool:
    return Steam.isSteamRunning()
```

### Get User Info

**Before (Stub)**:
```gdscript
func _stub_get_steam_id() -> int:
    return 76561197960287930  # Stub ID

func _stub_get_username() -> String:
    return "StubUser"
```

**After (Real)**:
```gdscript
func authenticate_user() -> void:
    steam_user_id = Steam.getSteamID()
    steam_username = Steam.getPersonaName()
    authentication_complete.emit(steam_user_id)
```

---

## Steam Overlay

The overlay pauses the game when active:

```gdscript
func _on_overlay_toggled(active: bool) -> void:
    is_overlay_enabled = active
    overlay_activated.emit(active)

    # Pause game when overlay is active
    if active:
        get_tree().paused = true
    else:
        get_tree().paused = false
```

### Overlay Dialogs

```gdscript
func activate_overlay(dialog: String = "") -> void:
    if not is_steam_available:
        return

    Steam.activateGameOverlay(dialog)
    # Valid: "Friends", "Community", "Players", "Settings",
    #        "OfficialGameGroup", "Stats", "Achievements"
```

---

## Process Callbacks

Steam requires regular callback processing:

```gdscript
func _process(_delta: float) -> void:
    if is_steam_available:
        Steam.run_callbacks()
```

This must run every frame for Steam events to work.

---

## Shutdown

Clean shutdown when game exits:

```gdscript
func _exit_tree() -> void:
    if is_steam_available:
        Steam.steamShutdown()
```

---

## Testing Without Steam

The stub implementation allows development without Steam:

```gdscript
func is_initialized() -> bool:
    return _is_initialized and is_steam_available
```

When Steam isn't available:
- Game functions normally with local saves
- Achievements save locally
- Cloud sync is skipped
- No error popups or crashes

---

## Steamworks Dashboard Configuration

### App Settings

1. Navigate to App Admin → Edit Steamworks Settings
2. Set:
   - **App Type**: Game
   - **Category**: Single-player
   - **Primary Genre**: Action
   - **Supported Platforms**: Windows, Linux

### Cloud Configuration

1. Navigate to App Admin → Cloud
2. Set:
   - **Quota per user**: 1 MB (sufficient for JSON saves)
   - **Max files per user**: 5
   - **Enable Cloud**: Yes

### Achievement Setup

See [Achievements](achievements.md) for detailed configuration.

---

## Common Issues

**Steam not initializing**:
- Check `steam_appid.txt` exists in project root
- Verify Steam client is running
- Ensure plugin is enabled in Project Settings

**Callbacks not firing**:
- Verify `Steam.run_callbacks()` runs every frame
- Check signal connections
- Ensure Steam is initialized before connecting

**Wrong App ID**:
- Replace stub ID `480` with your actual App ID
- Restart Steam client after changing `steam_appid.txt`

---

## Summary

| Component | Stub | Real Implementation |
|-----------|------|---------------------|
| Init | Returns true | `Steam.steamInit()` |
| Available check | ENV variable | `Steam.isSteamRunning()` |
| User ID | Hardcoded | `Steam.getSteamID()` |
| Username | "StubUser" | `Steam.getPersonaName()` |
| Overlay | Logs only | `Steam.activateGameOverlay()` |
| Shutdown | Logs only | `Steam.steamShutdown()` |

GodotSteam integration is straightforward once you have the App ID. The stub system means you can develop offline and enable Steam when ready.

---

[← Back to Overview](overview.md) | [Next: Achievements →](achievements.md)
