# Achievements

The achievement system tracks progress locally and syncs with Steam. Four core achievements ship with MVP, with more planned for Alpha and Beta.

---

## Achievement Framework

**File**: `core/scripts/achievement_manager.gd`

```gdscript
class_name AchievementManager
extends Node

class Achievement:
    var id: String
    var name: String
    var description: String
    var unlocked: bool = false
    var unlock_time: int = 0
    var progress: float = 0.0
    var max_progress: float = 100.0
```

### Signals

```gdscript
signal achievement_unlocked(achievement_id: String)
signal achievement_progress_updated(achievement_id: String, progress: float, max_progress: float)
```

---

## Core Achievements (MVP)

### 1. Down the Rabbit Hole

```gdscript
achievements["FIRST_CONNECTION"] = Achievement.new(
    "FIRST_CONNECTION",
    "Down the Rabbit Hole",
    "Connect your first conspiracy theory thread",
    1.0  # Unlocks immediately on first connection
)
```

**Trigger**: First conspiracy board connection made.

### 2. Case Closed

```gdscript
achievements["CASE_CLOSED"] = Achievement.new(
    "CASE_CLOSED",
    "Case Closed",
    "Complete your first full investigation",
    1.0
)
```

**Trigger**: Complete 100% of conspiracy board connections.

### 3. Bullet Time Master

```gdscript
achievements["BULLET_MASTER"] = Achievement.new(
    "BULLET_MASTER",
    "Bullet Time Master",
    "Dodge 100 bullets using bullet time",
    100.0  # Progress-based: 100 dodges
)
```

**Trigger**: Incremental progress. Tracks across all runs.

### 4. Conspiracy Theorist

```gdscript
achievements["THEORY_MASTER"] = Achievement.new(
    "THEORY_MASTER",
    "Conspiracy Theorist",
    "Create 10 different conspiracy theories",
    10.0  # Progress-based: 10 theories
)
```

**Trigger**: Connect 10 unique pairs on the conspiracy board.

---

## Updating Progress

### Increment Progress

```gdscript
func update_progress(achievement_id: String, progress_increment: float = 1.0) -> void:
    var achievement: Achievement = achievements[achievement_id]

    if achievement.unlocked:
        return  # Already done

    achievement.progress += progress_increment
    achievement.progress = min(achievement.progress, achievement.max_progress)

    achievement_progress_updated.emit(achievement_id, achievement.progress, achievement.max_progress)

    # Auto-unlock when max reached
    if achievement.progress >= achievement.max_progress:
        unlock_achievement(achievement_id)
    else:
        _save_achievements()
```

### Unlock Achievement

```gdscript
func unlock_achievement(achievement_id: String) -> void:
    var achievement: Achievement = achievements[achievement_id]

    if achievement.unlocked:
        return

    achievement.unlocked = true
    achievement.progress = achievement.max_progress
    achievement.unlock_time = Time.get_unix_time_from_system()

    _save_achievements()

    # Sync with Steam
    if steam_manager and steam_manager.is_initialized():
        steam_manager.unlock_achievement(achievement_id)

    achievement_unlocked.emit(achievement_id)
```

---

## Integration Examples

### Conspiracy Board Connection

```gdscript
# In conspiracy_board.gd
func _on_connection_made(log_a: String, log_b: String) -> void:
    # Track for achievement
    achievement_manager.update_progress("THEORY_MASTER", 1.0)

    # First connection special
    if _connection_count == 1:
        achievement_manager.unlock_achievement("FIRST_CONNECTION")
```

### Bullet Time Dodge

```gdscript
# In combat system
func _on_bullet_dodged_in_bullet_time() -> void:
    achievement_manager.update_progress("BULLET_MASTER", 1.0)
```

### Board Completion

```gdscript
# In conspiracy_board.gd
func _on_board_completed() -> void:
    achievement_manager.unlock_achievement("CASE_CLOSED")
```

---

## Local Persistence

Achievements save to `user://achievements.save`:

```gdscript
func _save_achievements() -> void:
    var data = {}

    for achievement_id in achievements.keys():
        var achievement: Achievement = achievements[achievement_id]
        data[achievement_id] = {
            "unlocked": achievement.unlocked,
            "unlock_time": achievement.unlock_time,
            "progress": achievement.progress
        }

    var file = FileAccess.open(save_file_path, FileAccess.WRITE)
    file.store_string(JSON.stringify(data, "\t"))
    file.close()
```

### Load on Startup

```gdscript
func _load_achievements() -> void:
    if not FileAccess.file_exists(save_file_path):
        return

    var file = FileAccess.open(save_file_path, FileAccess.READ)
    var json = JSON.new()
    json.parse(file.get_as_text())
    file.close()

    var data = json.data
    for achievement_id in data.keys():
        if achievements.has(achievement_id):
            var achievement = achievements[achievement_id]
            var saved = data[achievement_id]
            achievement.unlocked = saved.get("unlocked", false)
            achievement.unlock_time = saved.get("unlock_time", 0)
            achievement.progress = saved.get("progress", 0.0)
```

---

## Steam Configuration

### Steamworks Dashboard

1. Navigate to **App Admin** → **Stats & Achievements**
2. Click **New Achievement**
3. Fill in:
   - **API Name**: `FIRST_CONNECTION` (matches code)
   - **Display Name**: "Down the Rabbit Hole"
   - **Description**: "Connect your first conspiracy theory thread"
   - **Icon**: 64x64 PNG (unlocked state)
   - **Icon (Gray)**: 64x64 PNG (locked state)

### Achievement Icons

| State | Size | Notes |
|-------|------|-------|
| Unlocked | 64x64 | Full color |
| Locked | 64x64 | Grayscale/silhouette |

### Progress Display

For progress-based achievements (BULLET_MASTER), enable "Progress Stat" in Steamworks to show completion percentage.

---

## Query Functions

### Get Achievement

```gdscript
func get_achievement(achievement_id: String) -> Achievement:
    return achievements.get(achievement_id)
```

### Check Unlocked

```gdscript
func is_unlocked(achievement_id: String) -> bool:
    if not achievements.has(achievement_id):
        return false
    return achievements[achievement_id].unlocked
```

### Get Progress

```gdscript
func get_progress(achievement_id: String) -> float:
    if not achievements.has(achievement_id):
        return 0.0
    return achievements[achievement_id].progress
```

### Completion Percentage

```gdscript
func get_completion_percentage() -> float:
    if achievements.is_empty():
        return 0.0

    var unlocked_count = get_unlocked_achievements().size()
    return (float(unlocked_count) / float(achievements.size())) * 100.0
```

---

## Reset Functions (Testing)

```gdscript
func reset_achievement(achievement_id: String) -> void:
    var achievement: Achievement = achievements[achievement_id]
    achievement.unlocked = false
    achievement.unlock_time = 0
    achievement.progress = 0.0
    _save_achievements()

func reset_all_achievements() -> void:
    for achievement in achievements.values():
        achievement.unlocked = false
        achievement.unlock_time = 0
        achievement.progress = 0.0
    _save_achievements()
```

---

## Future Achievements (Alpha/Beta)

| Achievement | Description | Phase |
|-------------|-------------|-------|
| Corporate Ladder | Defeat The CEO | Alpha |
| Whistleblower | Unlock Deep Croak | Alpha |
| No Stone Unturned | Find all hidden areas | Alpha |
| Speed Runner | Complete run in under 15 minutes | Beta |
| Pacifist | Complete run without attacking | Beta |
| Mutant Master | Unlock all mutations | Beta |

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Progress tracking | Local save (JSON) |
| Steam sync | Via SteamManager |
| Query API | get_achievement(), is_unlocked(), get_progress() |
| Reset (testing) | reset_achievement(), reset_all_achievements() |

The achievement system works offline and syncs when Steam is available. Progress persists across runs via local save.

---

[← Back to Steam Setup](steam-setup.md) | [Next: Steam Deck →](steam-deck.md)
