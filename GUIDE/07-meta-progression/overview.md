# Meta-Progression Overview

Meta-progression is what makes The Pond a roguelike worth replaying. Between runs, players unlock informants, discover evidence, and carry forward story progress. This chapter covers the save system, Steam Cloud integration, and informant characters.

---

## What's Here

| File | What It Covers |
|------|----------------|
| [Save System](save-system.md) | JSON structure, atomic writes, corruption recovery |
| [Steam Cloud](steam-cloud.md) | Cloud sync, conflict resolution |
| [Informants](informants.md) | Deep Croak, Lily Padsworth, hints system |

---

## System Architecture

```
core/scripts/
├── save_data.gd           # Save structure definition
├── save_manager.gd        # Save/load operations
├── save_migration.gd      # Version migration
├── checksum.gd            # Data integrity
├── steam_cloud.gd         # Cloud sync (stub)
└── steam_manager.gd       # Steam integration (stub)

metagame/scripts/
└── informant_manager.gd   # NPC informants
```

---

## Key Files

| File | Purpose |
|------|---------|
| `core/scripts/save_data.gd` | SaveData class definition |
| `core/scripts/save_manager.gd` | Atomic save/load with recovery |
| `core/scripts/save_migration.gd` | Forward compatibility |
| `metagame/scripts/informant_manager.gd` | Informant characters |

---

## What Persists Between Runs

### Per-Run Data (Reset)

- Current HP
- Active mutations
- Wave progress
- Current position

### Meta-Progression Data (Persists)

| Category | Examples |
|----------|----------|
| Player Stats | Total deaths, play time, kills |
| Conspiracy Progress | Discovered logs, connections, completion % |
| Informants | Unlocked characters, dialogue progress |
| Achievements | Unlocked achievements, progress |

---

## Save Data Structure

```gdscript
class_name SaveData

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
    "unlocked_mutations": [],
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
    "discovered_logs": [],
    "connected_pairs": [],
    "board_layout": [],
    "completion_percentage": 0.0,
    "unlocked_documents": [],
    "reading_progress": {}
}
```

---

## Save Triggers

The game auto-saves at these moments:

| Trigger | Debounce | Story |
|---------|----------|-------|
| Player death | None | SAVE-004 |
| Conspiracy connection | 2 seconds | SAVE-005 |
| Settings change | None | SAVE-006 |
| Application exit | None | SAVE-007 |

---

## Signals

| Signal | When Emitted |
|--------|--------------|
| `save_completed` | Save successful |
| `save_failed` | Save error |
| `load_completed` | Load successful |
| `load_failed` | Load error |
| `corruption_detected` | Main save corrupt |

---

## Story Traceability

| Story | Description | Status |
|-------|-------------|--------|
| SAVE-001 | JSON save structure | Complete |
| SAVE-002 | Checksum validation | Complete |
| SAVE-003 | Atomic write | Complete |
| SAVE-004 | Save on death | Complete |
| SAVE-005 | Conspiracy debounce | Complete |
| SAVE-006 | Settings save | Complete |
| SAVE-007 | Exit save | Complete |
| SAVE-008 | Steam Cloud sync | Stub |
| SAVE-009 | Corruption recovery | Complete |
| SAVE-010 | Version migration | Complete |
| META-003 | Deep Croak informant | Complete |
| META-004 | Lily Padsworth informant | Complete |

---

## Integration Points

### With Conspiracy Board

```gdscript
# Board notifies save manager of connections
ConspiracyBoard.connection_made.connect(save_manager.trigger_conspiracy_save)
```

### With Boss Defeats

```gdscript
# Boss defeat unlocks informants
func _on_boss_defeated(boss_name: String) -> void:
    match boss_name:
        "lobbyist":
            informant_manager.unlock_informant("deep_croak")
        "ceo":
            informant_manager.unlock_informant("lily_padsworth")
```

### With Steam

```gdscript
# Cloud sync after save
func save_game(save_data: SaveData) -> bool:
    # ... save locally ...
    _steam_cloud.upload_file(SAVE_PATH, "savegame.json")
```

---

## Next Steps

If you're working on meta-progression:

1. Start with [Save System](save-system.md) - understand data integrity
2. Review [Steam Cloud](steam-cloud.md) - cloud sync preparation
3. Implement [Informants](informants.md) - narrative rewards

---

[Back to Index](../index.md) | [Next: Save System](save-system.md)
