# ADR-003: Communication Patterns & API Strategy

**Status**: Accepted
**Date**: 2025-12-13
**Decision Makers**: Chief Architect, Backend Architect, Integration Architect
**Related ADRs**: ADR-002 (System Architecture), ADR-006 (Tech Stack)

---

## Context

As a single-player desktop game, Pond Conspiracy has minimal external communication requirements. However, we need to define:

1. **Internal communication** between game modules (Combat ↔ Conspiracy Board ↔ Meta-Progression)
2. **Steam integration** patterns (achievements, cloud saves)
3. **Future extensibility** (mod support, leaderboards in Beta)

### Requirements

**From ADR-002**:
- Loosely coupled modules (Combat, Conspiracy Board, MetaGame)
- EventBus pattern recommended for decoupling
- No circular dependencies

**From PRD**:
- Steam Cloud save synchronization
- Steam Achievements
- (Future Beta) Leaderboards, daily challenges
- (Future Year 2) Mod API / Workshop support

---

## Decision

### Internal Communication: **Event-Driven Architecture (EventBus Pattern)**

**Pattern**: Global event aggregator using Godot signals

**Implementation**:
```gdscript
# core/event_bus.gd (Autoload Singleton)
extends Node

# Gameplay events
signal player_died(run_stats)
signal boss_defeated(boss_id)
signal mutation_selected(mutation_data)
signal run_started()

# Meta-progression events
signal evidence_unlocked(data_log_id)
signal informant_unlocked(informant_id)
signal conspiracy_connection_made(from_id, to_id)

# System events
signal save_completed()
signal save_failed(error_message)
signal steam_achievement_unlocked(achievement_id)
```

**Usage Pattern**:
```gdscript
# Emitter (Combat Module)
func _on_player_death():
    var run_stats = {
        "time_survived": timer.get_time(),
        "enemies_killed": enemy_count,
        "boss_defeated": boss_defeated_flag
    }
    EventBus.emit_signal("player_died", run_stats)

# Listener (GameManager)
func _ready():
    EventBus.connect("player_died", self, "_on_player_died")

func _on_player_died(run_stats):
    # Handle death logic, transition to DeathScreen
    change_scene_to("res://metagame/scenes/DeathScreen.tscn")
```

**Benefits**:
- ✅ **Decoupling**: Combat module doesn't know about Conspiracy Board
- ✅ **Testability**: Can emit events in tests without full game state
- ✅ **Debuggability**: Single place to log all events
- ✅ **Extensibility**: Add new listeners without modifying emitters

**Guardrails**:
- ❌ **No synchronous returns**: Events are fire-and-forget
- ❌ **No circular event chains**: If Event A triggers Event B triggers Event A → deadlock
- ✅ **Document all events**: Maintain event catalog in EventBus comments

---

### External Communication: **Steam API Integration (GodotSteam Plugin)**

**Pattern**: Wrapper singleton around GodotSteam

**Implementation**:
```gdscript
# core/steam_api.gd (Autoload Singleton)
extends Node

var steam_enabled: bool = false

func _ready():
    if OS.has_feature("Steam"):
        steam_enabled = Steam.steamInit()
        if steam_enabled:
            print("Steam initialized successfully")
        else:
            print("Warning: Steam init failed, running offline")

func unlock_achievement(achievement_id: String):
    if not steam_enabled:
        return

    Steam.setAchievement(achievement_id)
    Steam.storeStats()
    EventBus.emit_signal("steam_achievement_unlocked", achievement_id)

func sync_cloud_save(save_data: Dictionary):
    if not steam_enabled:
        return

    var save_json = JSON.print(save_data)
    Steam.fileWrite("save_game.json", save_json.to_utf8())
    print("Saved to Steam Cloud")

func load_cloud_save() -> Dictionary:
    if not steam_enabled:
        return {}

    if Steam.fileExists("save_game.json"):
        var file_data = Steam.fileRead("save_game.json")
        return JSON.parse(file_data.get_string_from_utf8()).result
    return {}
```

**Communication Flow**:
```
SaveManager → SteamAPI.sync_cloud_save(data)
                   ↓
           GodotSteam Plugin
                   ↓
           Steam Client API
                   ↓
           Steam Cloud (Valve servers)
```

**Error Handling**:
- If Steam is unavailable → game runs offline, saves locally only
- If cloud sync fails → retry once, then fallback to local-only
- User sees warning toast: "Cloud save unavailable, using local saves"

---

### Future Communication Patterns

#### Mod API (Year 2)

**Pattern**: Plugin system using Godot's resource loading

**Concept** (not implemented in MVP):
```gdscript
# Load mod from workshop folder
var mod = load("user://workshop/mods/custom_mutation.tres")
if mod is MutationResource:
    MutationManager.register_mod_mutation(mod)
```

**Security**:
- ❌ **No GDScript execution from mods**: Only load `.tres` resource files (data-only)
- ✅ **Sandboxed**: Mods can't access file system or network
- ✅ **Validation**: Check mod schema before loading

---

#### Leaderboards (Beta)

**Pattern**: Asynchronous Steam API calls

**Implementation** (deferred to Beta):
```gdscript
func submit_daily_challenge_score(score: int):
    if not steam_enabled:
        return

    Steam.uploadLeaderboardScore(score, true, PoolIntArray([]))
    # Async callback: _on_leaderboard_score_uploaded()
```

**Rationale**: Defer to Beta because:
1. MVP doesn't have daily challenges
2. Requires Steam app configuration (can't test until Steam page is live)
3. Adds 2-3 days of work (not critical for Early Access)

---

## Communication Protocols

### EventBus Event Catalog

| Event Name | Payload | Emitters | Listeners | Purpose |
|-----------|---------|----------|-----------|---------|
| `player_died` | `{time, kills, boss_defeated}` | Player | GameManager | Trigger death screen |
| `boss_defeated` | `{boss_id}` | Boss | MetaProgression | Unlock data log |
| `mutation_selected` | `{mutation_id, pollution_level}` | MutationUI | Player, PollutionIndexUI | Apply ability + update UI |
| `evidence_unlocked` | `{data_log_id}` | MetaProgression | ConspiracyBoard | Show new document |
| `run_started` | `{}` | GameManager | CombatScene, AudioManager | Reset state, start music |
| `save_completed` | `{}` | SaveManager | HUD | Show save icon |
| `save_failed` | `{error}` | SaveManager | HUD | Show error toast |
| `conspiracy_connection_made` | `{from_id, to_id}` | ConspiracyBoard | MetaProgression | Track progress |

**Event Naming Convention**: `<subject>_<action>` (past tense)
- Good: `player_died`, `boss_defeated`, `save_completed`
- Bad: `on_player_death`, `defeat_boss`, `saving`

---

### Steam API Call Patterns

**Synchronous** (blocking, immediate result):
- `Steam.steamInit()` - Initialize Steam client
- `Steam.setAchievement(id)` - Unlock achievement
- `Steam.fileWrite(file, data)` - Write to cloud

**Asynchronous** (callbacks via signals):
- `Steam.requestCurrentStats()` → signal `current_stats_received`
- `Steam.uploadLeaderboardScore()` → signal `leaderboard_score_uploaded`

**Godot Integration**:
```gdscript
func _ready():
    Steam.connect("current_stats_received", self, "_on_stats_received")

func _on_stats_received(game_id, result, user_id):
    if result == 1: # Success
        print("Stats received from Steam")
```

---

## Consequences

### Positive

✅ **Loose coupling**: Modules communicate via events, not direct calls
✅ **Simple patterns**: EventBus + wrapper singletons are easy to understand
✅ **Testable**: Can mock SteamAPI singleton in tests
✅ **Godot-native**: Uses signals (built-in Godot pattern)
✅ **Offline-friendly**: Game works without Steam (graceful degradation)
✅ **Scalable**: Adding new events or Steam features is straightforward

### Negative

❌ **Event hell risk**: Too many events create spaghetti (mitigated by catalog + code review)
❌ **No type safety**: Godot signals are dynamically typed (mitigated by payload documentation)
❌ **Debugging harder**: Event chains can be opaque (mitigated by logging)

### Neutral

🔷 **No network layer**: Appropriate for single-player game
🔷 **Steam dependency**: Acceptable, as Steam is primary distribution platform

---

## Alternatives Considered

### Alternative 1: Direct Method Calls (No EventBus)

**Example**: `GameManager.on_player_died()` called directly from Player

**Pros**:
- Simpler (no EventBus to maintain)
- Type-safe (direct function calls)
- Easier to trace in debugger

**Cons**:
- Tight coupling (Player needs reference to GameManager)
- Circular dependency risk
- Hard to add new listeners (modify Player code every time)

**Rejected**: Coupling makes future changes brittle

---

### Alternative 2: Godot Groups + `get_tree().call_group()`

**Example**: `get_tree().call_group("listeners", "on_player_died", stats)`

**Pros**:
- Built-in Godot feature
- No custom EventBus needed

**Cons**:
- Hard to discover what groups exist
- No type safety or payload structure
- Difficult to debug (which nodes are in which groups?)

**Rejected**: Less explicit than EventBus singleton

---

### Alternative 3: REST API for Steam Integration

**Example**: Query Steam Web API directly

**Pros**:
- Bypasses Steam client dependency
- Could work on non-Steam platforms

**Cons**:
- Requires Steam Web API key (OAuth)
- Network dependency (offline mode breaks)
- More complex than GodotSteam plugin
- Steam client already handles authentication

**Rejected**: GodotSteam plugin is simpler and offline-capable

---

## Related Decisions

- **ADR-001**: Platform (Steam distribution)
- **ADR-002**: System Architecture (module boundaries)
- **ADR-004**: Data Architecture (save files)
- **ADR-006**: Technology Stack (GodotSteam plugin)

---

## Implementation Guidelines

### EventBus Best Practices

**DO**:
- ✅ Document payload structure in comments
- ✅ Use past tense for event names (`player_died` not `player_dies`)
- ✅ Keep payloads small (only essential data)
- ✅ Log events in debug mode for troubleshooting

**DON'T**:
- ❌ Return values from events (fire-and-forget only)
- ❌ Create circular event chains (A → B → A)
- ❌ Emit events every frame (performance cost)
- ❌ Use events for time-critical communication (use direct calls for <16ms latency requirements)

---

### Steam API Guidelines

**Initialization**:
```gdscript
# In SteamAPI._ready()
if not OS.has_feature("Steam"):
    print("Not running on Steam, disabling Steam features")
    steam_enabled = false
    return

steam_enabled = Steam.steamInit()
if not steam_enabled:
    push_warning("Steam init failed, cloud saves disabled")
```

**Achievement Pattern**:
```gdscript
func unlock_achievement(achievement_id: String):
    if not steam_enabled:
        return # Silent failure OK, game works without Steam

    if not Steam.getAchievement(achievement_id).achieved:
        Steam.setAchievement(achievement_id)
        Steam.storeStats() # Persist to Steam
        EventBus.emit_signal("steam_achievement_unlocked", achievement_id)
        # Show in-game toast: "Achievement Unlocked!"
```

**Cloud Save Pattern**:
```gdscript
# SaveManager calls this after writing local file
func sync_to_cloud(local_save_path: String):
    if not steam_enabled:
        return

    var file = File.new()
    if file.open(local_save_path, File.READ) != OK:
        push_error("Failed to read local save for cloud sync")
        return

    var save_data = file.get_as_text()
    file.close()

    if Steam.fileWrite("save_game.json", save_data.to_utf8()):
        print("Cloud save synced successfully")
    else:
        push_warning("Cloud save failed, local save still valid")
```

---

## Testing Strategy

### EventBus Testing

**Unit Tests** (GUT framework):
```gdscript
func test_player_died_event_emits_correctly():
    var listener_called = false
    var received_stats = {}

    EventBus.connect("player_died", self, "_on_test_player_died")

    EventBus.emit_signal("player_died", {"time": 120, "kills": 50})

    assert_true(listener_called)
    assert_eq(received_stats.time, 120)

func _on_test_player_died(stats):
    listener_called = true
    received_stats = stats
```

**Integration Tests**:
- Emit `player_died` → verify GameManager transitions to DeathScreen
- Emit `boss_defeated` → verify MetaProgression unlocks data log

---

### Steam API Testing

**Mock Steam API** (for CI/CD):
```gdscript
# test/mocks/mock_steam_api.gd
extends Node

var steam_enabled = true
var achievements = {}

func setAchievement(id: String):
    achievements[id] = true

func getAchievement(id: String):
    return {"achieved": achievements.get(id, false)}
```

**Manual Testing**:
- Test with Steam client running → verify achievements unlock
- Test WITHOUT Steam client → verify game runs offline
- Test cloud save sync → save on PC 1, load on PC 2

---

**Approved By**:
- ✅ Chief Architect
- ✅ Backend Architect
- ✅ Integration Architect

**Next ADR**: ADR-004 - Data Architecture & Storage Strategy
