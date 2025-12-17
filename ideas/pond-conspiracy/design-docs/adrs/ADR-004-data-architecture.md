# ADR-004: Data Architecture & Storage Strategy

**Status**: Accepted
**Date**: 2025-12-13
**Decision Makers**: Chief Architect, Data Architect, Backend Architect
**Related ADRs**: ADR-002 (System Architecture), ADR-003 (Communication Patterns)

---

## Context

Pond Conspiracy needs to persist:
1. **Save game state** (meta-progression, unlocked content, conspiracy board)
2. **Player settings** (audio, video, accessibility, controls)
3. **Run statistics** (for achievements, leaderboards in future)

### Requirements

- **Auto-save** on death (no manual save prompt)
- **Steam Cloud sync** for cross-device play
- **Fast load times** (<3s)
- **Minimal storage** (<5MB save files)
- **No database** (single-player, local)
- **Human-readable** format (debugging ease)

---

## Decision

### Storage Format: **JSON (File-Based)**

**Primary Save File**: `user://saves/save_game.json`

```json
{
  "version": "1.0.0",
  "meta_progression": {
    "run_count": 42,
    "total_deaths": 38,
    "unlocked_informants": ["informant_01", "informant_02"],
    "unlocked_data_logs": ["log_01", "log_02", "log_03"],
    "conspiracy_connections": [
      {"from": "log_01", "to": "log_02"},
      {"from": "log_02", "to": "log_03"}
    ],
    "bosses_defeated": {
      "lobbyist": 15,
      "ceo": 8
    }
  },
  "settings": {
    "master_volume": 0.8,
    "music_volume": 0.7,
    "sfx_volume": 0.9,
    "colorblind_mode": "deuteranopia",
    "screen_shake_enabled": true,
    "text_size": "medium"
  },
  "statistics": {
    "total_playtime_seconds": 14400,
    "longest_run_seconds": 720,
    "enemies_killed_total": 5420,
    "mutations_discovered": ["oil_trails", "toxic_aura", "mercury_rush"]
  },
  "last_modified": "2025-12-13T18:45:00Z"
}
```

**Benefits**:
- ✅ Human-readable (can edit in text editor for debugging)
- ✅ Godot has built-in JSON support (no extra dependencies)
- ✅ Small file size (~2-5KB)
- ✅ Version migrations easy (`if version < "1.1.0": migrate()`)

---

### Save Location: **Godot User Directory**

**Path**: `user://saves/` (cross-platform)
- Windows: `%APPDATA%\Roaming\Godot\app_userdata\PondConspiracy\saves\`
- Linux: `~/.local/share/godot/app_userdata/PondConspiracy/saves/`
- Steam Deck: Same as Linux

**File Structure**:
```
user://
├── saves/
│   ├── save_game.json (main save)
│   ├── save_backup.json (previous version, for recovery)
│   └── .save_lock (prevents concurrent writes)
└── settings/
    └── keybindings.json (rebindable controls)
```

---

### Persistence Strategy

**Auto-Save Triggers**:
1. **On player death** (before death screen)
2. **On conspiracy connection made** (immediate feedback)
3. **On settings change** (prevent loss on crash)
4. **On game exit** (clean shutdown)

**Save Flow**:
```
1. SaveManager.save_game()
   ↓
2. Serialize MetaProgression → JSON
   ↓
3. Write to temp file: save_game.tmp
   ↓
4. Verify file integrity (checksum)
   ↓
5. Rename save_game.json → save_backup.json
   ↓
6. Rename save_game.tmp → save_game.json
   ↓
7. Sync to Steam Cloud (async, non-blocking)
   ↓
8. EventBus.emit_signal("save_completed")
```

**Corruption Protection**:
- Atomic writes (temp file → rename, never overwrite directly)
- Backup copy (previous save preserved)
- Checksum validation on load

**Load Flow**:
```
1. Check Steam Cloud for newer save
   ↓
2. If cloud newer: download and use
   ↓
3. Else: load local save_game.json
   ↓
4. Validate JSON structure
   ↓
5. If corrupt: try save_backup.json
   ↓
6. If both corrupt: fresh save (warn player)
   ↓
7. Populate MetaProgression singleton
```

---

### Data Models

**MetaProgression** (in-memory singleton):
```gdscript
# core/meta_progression.gd
extends Node

var run_count: int = 0
var total_deaths: int = 0
var unlocked_informants: Array = []
var unlocked_data_logs: Array = []
var conspiracy_connections: Array = []
var bosses_defeated: Dictionary = {}

func unlock_data_log(log_id: String):
    if not unlocked_data_logs.has(log_id):
        unlocked_data_logs.append(log_id)
        EventBus.emit_signal("evidence_unlocked", log_id)
        SaveManager.save_game() # Auto-save

func to_dict() -> Dictionary:
    return {
        "run_count": run_count,
        "total_deaths": total_deaths,
        "unlocked_informants": unlocked_informants,
        "unlocked_data_logs": unlocked_data_logs,
        "conspiracy_connections": conspiracy_connections,
        "bosses_defeated": bosses_defeated
    }

func from_dict(data: Dictionary):
    run_count = data.get("run_count", 0)
    total_deaths = data.get("total_deaths", 0)
    # ... (load all fields)
```

---

### Steam Cloud Integration

**Sync Strategy**: Last-write-wins (simple, appropriate for single-player)

**Conflict Resolution**:
- Compare `last_modified` timestamps
- Newer save wins (overwrite older)
- No merge logic (single-player, no concurrent edits)

**Implementation**:
```gdscript
func sync_to_cloud():
    if not SteamAPI.steam_enabled:
        return

    var save_data = load_local_save_as_string()
    SteamAPI.sync_cloud_save({"save_game.json": save_data})

func sync_from_cloud():
    if not SteamAPI.steam_enabled:
        return

    var cloud_data = SteamAPI.load_cloud_save()
    if cloud_data.has("save_game.json"):
        var cloud_timestamp = get_cloud_timestamp()
        var local_timestamp = get_local_timestamp()

        if cloud_timestamp > local_timestamp:
            write_local_save(cloud_data["save_game.json"])
            print("Cloud save is newer, using cloud version")
```

---

## Consequences

### Positive

✅ **Simple**: JSON files, no database setup
✅ **Fast**: <50ms save/load times
✅ **Small**: ~2-5KB save files
✅ **Debuggable**: Human-readable format
✅ **Reliable**: Atomic writes + backups prevent corruption
✅ **Cloud-enabled**: Steam Cloud sync built-in

### Negative

❌ **No query capability**: Can't query "all players who defeated boss X" (acceptable for single-player)
❌ **Manual migration**: Schema changes require code updates
❌ **No encryption**: Save files are plain text (not sensitive data, acceptable)

---

## Alternatives Considered

### Alternative 1: SQLite Database

**Rejected**: Overkill for single-player. JSON is simpler and faster for small datasets (<1000 records).

### Alternative 2: Binary Format (Godot's ResourceSaver)

**Rejected**: Not human-readable, harder to debug, no significant performance benefit for small files.

### Alternative 3: Cloud Database (Firebase, Supabase)

**Rejected**: Requires internet, adds latency, unnecessary for local-only game.

---

## Related Decisions

- **ADR-001**: Platform (local desktop, no servers)
- **ADR-003**: Communication Patterns (Steam Cloud sync)
- **ADR-005**: Security (no encryption needed)

---

**Approved By**: ✅ Chief Architect, Data Architect, Backend Architect

**Next ADR**: ADR-005 - Authentication & Security Architecture
