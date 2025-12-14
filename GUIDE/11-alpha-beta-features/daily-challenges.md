# Daily Challenges

Daily challenges give players a reason to return every day. Everyone plays the same seeded run. Scores go on a leaderboard. Streaks reward consistency.

---

## Overview

| Story | Description | Epic |
|-------|-------------|------|
| DAILY-001 | Seeded run generation | EPIC-019 |
| DAILY-002 | Daily challenge framework | EPIC-019 |
| DAILY-003 | Steam leaderboard integration | EPIC-019 |
| DAILY-004 | Daily challenge UI | EPIC-019 |
| DAILY-005 | Leaderboard display (top 100) | EPIC-019 |
| DAILY-006 | Daily challenge rewards | EPIC-019 |
| DAILY-007 | Challenge expiration logic | EPIC-019 |

---

## Seeded RNG

### Seed Generation

```gdscript
func generate_daily_seed() -> String:
    var date = Time.get_date_dict_from_system()
    return "DAILY_%04d%02d%02d" % [date.year, date.month, date.day]

# Example: "DAILY_20251214"
```

### Seeded Random

```gdscript
# seeded_rng.gd
class_name SeededRNG
extends RefCounted

var rng: RandomNumberGenerator

func _init(seed_string: String) -> void:
    rng = RandomNumberGenerator.new()
    rng.seed = hash(seed_string)

func next_int(max_value: int) -> int:
    return rng.randi() % max_value

func next_float() -> float:
    return rng.randf()

func shuffle(array: Array) -> void:
    for i in range(array.size() - 1, 0, -1):
        var j = next_int(i + 1)
        var temp = array[i]
        array[i] = array[j]
        array[j] = temp
```

### What the Seed Controls

| System | Seeded? | Notes |
|--------|---------|-------|
| Enemy spawns | Yes | Types and positions |
| Mutation offerings | Yes | Which 3 appear |
| Boss patterns | Yes | Attack timing |
| Item drops | Yes | Loot tables |
| Player input | No | Obviously |

---

## Challenge Framework

### One Attempt Per Day

```gdscript
func can_attempt_challenge() -> bool:
    var today = _get_today_string()
    return not _has_attempted_today(today)

func _has_attempted_today(date: String) -> bool:
    return save_data.daily_attempts.has(date)

func record_attempt(score: int) -> void:
    var today = _get_today_string()
    save_data.daily_attempts[today] = {
        "score": score,
        "timestamp": Time.get_unix_time_from_system()
    }
    save_manager.save_game()
```

### Practice Mode

Allow non-scoring practice runs:

```gdscript
func start_challenge(is_practice: bool = false) -> void:
    if not is_practice and not can_attempt_challenge():
        push_warning("Already attempted today's challenge")
        return

    var seed = generate_daily_seed()
    if is_practice:
        seed += "_PRACTICE"

    game_manager.start_seeded_run(seed, is_practice)
```

---

## Steam Leaderboards

### Initialization

```gdscript
func _ready() -> void:
    Steam.connect("leaderboard_find_result", _on_leaderboard_found)
    Steam.connect("leaderboard_score_uploaded", _on_score_uploaded)
    Steam.connect("leaderboard_scores_downloaded", _on_scores_downloaded)

    Steam.findOrCreateLeaderboard("daily_%s" % _get_today_string(),
        Steam.LEADERBOARD_SORT_METHOD_DESCENDING,
        Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)
```

### Upload Score

```gdscript
func upload_score(score: int) -> void:
    if not steam_manager.is_initialized():
        push_warning("Steam not available, score not uploaded")
        return

    Steam.uploadLeaderboardScore(score, true, [])
```

### Download Scores

```gdscript
func download_scores(start: int = 1, end: int = 100) -> void:
    Steam.downloadLeaderboardEntries(start, end,
        Steam.LEADERBOARD_DATA_REQUEST_GLOBAL)

func _on_scores_downloaded(entries: Array) -> void:
    leaderboard_entries.clear()
    for entry in entries:
        leaderboard_entries.append({
            "rank": entry.rank,
            "steam_id": entry.steam_id,
            "name": Steam.getFriendPersonaName(entry.steam_id),
            "score": entry.score
        })
    leaderboard_updated.emit()
```

---

## Tunable Parameters

| Parameter | Default | Effect |
|-----------|---------|--------|
| `challenge_reset_utc_hour` | 0 | When new challenge starts |
| `attempts_per_day` | 1 | Runs allowed |
| `practice_mode_enabled` | true | Allow non-scoring runs |
| `grace_period_minutes` | 30 | Extra time for active runs |
| `leaderboard_page_size` | 20 | Entries per page |

---

## Challenge UI

### Main Menu Entry

```gdscript
func _populate_challenge_info() -> void:
    var can_play = daily_manager.can_attempt_challenge()
    $ChallengeButton.disabled = not can_play

    if can_play:
        $ChallengeStatus.text = "Today's Challenge Ready!"
    else:
        $ChallengeStatus.text = "Already Attempted"
        $YourScore.text = "Your Score: %d" % daily_manager.get_today_score()

    _update_countdown()
```

### Countdown Timer

```gdscript
func _update_countdown() -> void:
    var seconds_until_reset = _get_seconds_until_reset()
    var hours = seconds_until_reset / 3600
    var minutes = (seconds_until_reset % 3600) / 60

    $CountdownLabel.text = "Next challenge in: %02d:%02d" % [hours, minutes]
```

---

## Rewards

### Tier System

| Tier | Requirement | Reward |
|------|-------------|--------|
| Participant | Complete challenge | 10 currency |
| Top 50% | Beat median | 25 currency |
| Top 10% | Top 10% | 50 currency |
| Champion | #1 daily | Special cosmetic |

### Streak Rewards

```gdscript
func calculate_streak_bonus() -> int:
    var streak = save_data.daily_streak
    return min(streak * 5, 50)  # Cap at 50 bonus

func update_streak() -> void:
    var yesterday = _get_yesterday_string()
    if save_data.daily_attempts.has(yesterday):
        save_data.daily_streak += 1
    else:
        save_data.daily_streak = 1
```

| Streak | Bonus |
|--------|-------|
| 1 day | +5 |
| 3 days | +15 |
| 7 days | +35 + badge |
| 30 days | +50 + special cosmetic |

---

## Expiration Logic

### Challenge Window

```gdscript
func is_challenge_active() -> bool:
    var now = Time.get_unix_time_from_system()
    var challenge_end = _get_challenge_end_time()
    return now < challenge_end

func _get_challenge_end_time() -> int:
    var today = Time.get_date_dict_from_system()
    # Next midnight UTC
    return Time.get_unix_time_from_datetime_dict({
        "year": today.year,
        "month": today.month,
        "day": today.day + 1,
        "hour": 0,
        "minute": 0,
        "second": 0
    })
```

### Grace Period

```gdscript
func can_submit_score() -> bool:
    # Allow submission during grace period for in-progress runs
    var grace_end = _get_challenge_end_time() + (GRACE_PERIOD_MINUTES * 60)
    return Time.get_unix_time_from_system() < grace_end
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `metagame/scripts/daily_challenge.gd` | Challenge system |
| `metagame/scripts/seeded_rng.gd` | Deterministic RNG |
| `metagame/scripts/leaderboard_manager.gd` | Steam leaderboards |
| `metagame/scenes/DailyChallengeMenu.tscn` | Challenge UI |
| `metagame/scenes/LeaderboardDisplay.tscn` | Leaderboard UI |

---

## Human Dependencies

| Dependency | Notes |
|------------|-------|
| Steam API access | Requires GodotSteam integration |
| Server time | UTC-based, no custom server needed |

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Same run for everyone | Date-based seed |
| One attempt | Local tracking + Steam |
| Leaderboards | Steam API |
| Rewards | Currency + cosmetics |
| Streaks | Consecutive day tracking |

Daily challenges drive retention. The competitive element and streak system give players reasons to launch the game every day.

---

[← Back to Dynamic Music](dynamic-music.md) | [Next: Endless Mode →](endless-mode.md)
