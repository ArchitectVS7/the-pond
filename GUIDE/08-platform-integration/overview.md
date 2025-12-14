# Platform Integration Overview

Platform integration connects The Pond to Steam, controllers, and Steam Deck. This chapter covers the technical implementation, from GodotSteam setup to controller detection.

---

## What's Here

| File | What It Covers |
|------|----------------|
| [Steam Setup](steam-setup.md) | GodotSteam plugin, App ID, initialization |
| [Achievements](achievements.md) | Achievement framework, progress tracking |
| [Steam Deck](steam-deck.md) | Deck detection, optimizations, Verified status |
| [Controller Support](controller-support.md) | Input detection, rebinding, device types |

---

## System Architecture

```
core/scripts/
├── steam_manager.gd        # Steam API wrapper (stub)
├── achievement_manager.gd  # Achievement tracking
├── input_manager.gd        # Controller detection
└── steam_cloud.gd          # Cloud saves (stub)

shared/scripts/
└── input_latency_monitor.gd  # Latency validation
```

---

## Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| SteamManager | Stub | Awaiting GodotSteam integration |
| AchievementManager | Complete | Local save, Steam-ready |
| InputManager | Complete | All controller types |
| Steam Cloud | Stub | Interface ready |

---

## Key Files

| File | Purpose |
|------|---------|
| `core/scripts/steam_manager.gd` | Steam SDK initialization |
| `core/scripts/achievement_manager.gd` | Achievement state and progress |
| `core/scripts/input_manager.gd` | Controller detection and rebinding |
| `shared/scripts/input_latency_monitor.gd` | Latency validation (<16ms) |

---

## Device Support

### Controllers

| Device | Status | Detection |
|--------|--------|-----------|
| Xbox (XInput) | Complete | Name contains "xbox" or "xinput" |
| PlayStation | Complete | Name contains "playstation", "dualshock", "dualsense" |
| Nintendo | Complete | Name contains "nintendo" or "switch" |
| Steam Deck | Complete | `STEAM_DECK` environment variable |
| Generic | Fallback | Any unrecognized gamepad |

### Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Windows | Primary | Full Steam integration |
| Linux | Supported | SteamOS and standalone |
| Steam Deck | Optimized | 800p, battery-conscious |
| macOS | Planned | Post-launch consideration |

---

## Integration Points

### With Save System

```gdscript
# Steam Cloud sync after local save
func save_game(save_data: SaveData) -> bool:
    # ... local save ...
    steam_cloud.upload_file(SAVE_PATH, "savegame.json")
```

### With Meta-Progression

```gdscript
# Unlock achievement when condition met
func _on_first_connection_made() -> void:
    achievement_manager.unlock_achievement("FIRST_CONNECTION")
```

### With Combat System

```gdscript
# Track bullet dodges for achievement
func _on_bullet_dodged() -> void:
    achievement_manager.update_progress("BULLET_MASTER", 1.0)
```

---

## Signals

| Signal | Class | When Emitted |
|--------|-------|--------------|
| `steam_initialized` | SteamManager | Steam SDK ready |
| `achievement_unlocked` | AchievementManager | Achievement earned |
| `input_device_changed` | InputManager | Controller connected/type changed |
| `gamepad_connected` | InputManager | New gamepad detected |
| `control_rebinded` | InputManager | User changed binding |

---

## Story Traceability

| Story | Description | Status |
|-------|-------------|--------|
| PLATFORM-001 | GodotSteam Plugin Setup | Stub |
| PLATFORM-002 | Steam Authentication | Stub |
| PLATFORM-003 | Achievement Framework | Complete |
| PLATFORM-004 | Steam Overlay Support | Stub |
| PLATFORM-007 | Steam Deck Detection | Complete |
| PLATFORM-008 | Steam Deck Control Mapping | Complete |
| PLATFORM-009 | XInput Controller Support | Complete |
| PLATFORM-010 | Rebindable Controls | Complete |

---

## Implementation Priority

1. **Install GodotSteam** - Plugin enables all Steam features
2. **Replace Stubs** - SteamManager methods with real API calls
3. **Configure Steamworks** - App ID, achievements, cloud quota
4. **Test on Deck** - Verify Verified status requirements
5. **Polish Controller UX** - Prompts, haptics, button glyphs

---

## Next Steps

If you're working on platform integration:

1. Start with [Steam Setup](steam-setup.md) - GodotSteam installation
2. Review [Achievements](achievements.md) - Steam achievement sync
3. Test on [Steam Deck](steam-deck.md) - Performance and controls
4. Customize [Controller Support](controller-support.md) - Rebinding UI

---

[Back to Index](../index.md) | [Next: Steam Setup](steam-setup.md)
