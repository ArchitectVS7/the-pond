# Endless Mode

Endless mode strips away the story. No evidence, no bosses, no ending. Just you, the enemies, and a score that climbs until you die.

---

## Overview

| Story | Description | Epic |
|-------|-------------|------|
| ENDLESS-001 | Endless mode spawning (infinite) | EPIC-020 |
| ENDLESS-002 | Difficulty scaling (exponential) | EPIC-020 |
| ENDLESS-003 | Endless mode UI (timer, score) | EPIC-020 |
| ENDLESS-004 | Endless mode leaderboard | EPIC-020 |
| ENDLESS-005 | Endless mode achievement | EPIC-020 |
| ENDLESS-006 | Endless mode balance tuning | EPIC-020 |

---

## Core Loop

1. Start with base difficulty
2. Enemies spawn continuously
3. Kill enemies for score
4. Every 30 seconds, difficulty increases
5. Level up grants mutations (no pollution cap)
6. Game ends when player dies
7. Final score submitted to leaderboard

---

## Spawning System

### Infinite Waves

```gdscript
# endless_spawner.gd
class_name EndlessSpawner
extends EnemySpawner

var difficulty_level: int = 1
var time_survived: float = 0.0

func _process(delta: float) -> void:
    time_survived += delta
    _update_difficulty()
    _spawn_enemies_continuous()

func _update_difficulty() -> void:
    var new_level = int(time_survived / DIFFICULTY_INTERVAL) + 1
    if new_level > difficulty_level:
        difficulty_level = new_level
        _on_difficulty_increased()
```

### Enemy Budget

```gdscript
func _calculate_enemy_budget() -> int:
    # Base + exponential growth
    return BASE_BUDGET + int(pow(difficulty_level, GROWTH_EXPONENT))

func _spawn_enemies_continuous() -> void:
    var current_count = get_active_enemy_count()
    var budget = _calculate_enemy_budget()

    while current_count < budget:
        spawn_enemy(_select_enemy_type())
        current_count += 1
```

---

## Difficulty Scaling

### Scaling Formula

```gdscript
@export var base_budget: int = 10
@export var growth_exponent: float = 1.3
@export var difficulty_interval: float = 30.0

# Difficulty 1: 10 enemies
# Difficulty 2: 10 + 2^1.3 = 12 enemies
# Difficulty 5: 10 + 5^1.3 = 18 enemies
# Difficulty 10: 10 + 10^1.3 = 30 enemies
# Difficulty 20: 10 + 20^1.3 = 60 enemies
```

### Enemy Type Distribution

| Difficulty | Basic | Medium | Hard | Elite |
|------------|-------|--------|------|-------|
| 1-5 | 80% | 20% | 0% | 0% |
| 6-10 | 50% | 40% | 10% | 0% |
| 11-15 | 30% | 40% | 25% | 5% |
| 16+ | 20% | 30% | 35% | 15% |

```gdscript
func _select_enemy_type() -> PackedScene:
    var weights = _get_type_weights()
    var roll = randf()
    var cumulative = 0.0

    for type in weights:
        cumulative += weights[type]
        if roll <= cumulative:
            return type

    return basic_enemy  # Fallback
```

### Stat Scaling

```gdscript
func _apply_difficulty_modifiers(enemy: Enemy) -> void:
    var multiplier = 1.0 + (difficulty_level * 0.1)

    enemy.max_health *= multiplier
    enemy.damage *= multiplier
    enemy.move_speed *= (1.0 + difficulty_level * 0.02)  # Slower scaling
```

---

## Tunable Parameters

| Parameter | Default | Effect |
|-----------|---------|--------|
| `base_budget` | 10 | Starting enemy count |
| `growth_exponent` | 1.3 | Scaling curve steepness |
| `difficulty_interval` | 30.0 | Seconds between levels |
| `hp_scaling_per_level` | 0.1 | +10% HP per level |
| `damage_scaling_per_level` | 0.1 | +10% damage per level |
| `speed_scaling_per_level` | 0.02 | +2% speed per level |

---

## Scoring

### Score Sources

| Source | Points | Notes |
|--------|--------|-------|
| Enemy kill | 10-50 | Based on enemy type |
| Survival time | 1/sec | Passive accumulation |
| Difficulty bonus | x1.5 at D10, x2 at D20 | Multiplier |
| Combo kills | +10% per chain | Resets on 2s gap |

### Score Calculation

```gdscript
var base_score: int = 0
var time_score: int = 0
var combo_multiplier: float = 1.0

func add_kill_score(enemy_value: int) -> void:
    var difficulty_mult = 1.0 + (difficulty_level * 0.05)
    var points = int(enemy_value * combo_multiplier * difficulty_mult)
    base_score += points

    _extend_combo()

func _process(delta: float) -> void:
    time_score = int(time_survived)

func get_total_score() -> int:
    return base_score + time_score
```

---

## Mutations in Endless

### No Pollution Cap

```gdscript
func _is_endless_mode() -> bool:
    return GameState.current_mode == GameMode.ENDLESS

func get_max_mutations() -> int:
    if _is_endless_mode():
        return 999  # Effectively unlimited
    return DEFAULT_MAX_MUTATIONS
```

### Repeated Mutations

Allow stacking the same mutation:

```gdscript
func can_select_mutation(mutation_id: String) -> bool:
    if _is_endless_mode():
        return true  # Can stack
    return not active_mutations.has(mutation_id)
```

---

## UI

### HUD Elements

```
┌──────────────────────────────────────────┐
│  SCORE: 12,450      TIME: 03:24          │
│  DIFFICULTY: 7      COMBO: x1.5          │
└──────────────────────────────────────────┘
```

```gdscript
func _update_endless_ui() -> void:
    $ScoreLabel.text = "SCORE: %s" % _format_score(get_total_score())
    $TimeLabel.text = "TIME: %s" % _format_time(time_survived)
    $DifficultyLabel.text = "DIFFICULTY: %d" % difficulty_level
    $ComboLabel.text = "COMBO: x%.1f" % combo_multiplier
```

### Game Over Screen

```gdscript
func _show_endless_results() -> void:
    $FinalScore.text = "Final Score: %s" % _format_score(get_total_score())
    $TimeResult.text = "Survived: %s" % _format_time(time_survived)
    $DifficultyReached.text = "Max Difficulty: %d" % difficulty_level
    $EnemiesKilled.text = "Enemies Defeated: %d" % total_kills

    if is_new_high_score:
        $NewHighScore.visible = true
```

---

## Leaderboard

### Endless-Specific Board

```gdscript
func upload_endless_score() -> void:
    Steam.findOrCreateLeaderboard("endless_alltime",
        Steam.LEADERBOARD_SORT_METHOD_DESCENDING,
        Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)

    await Steam.leaderboard_find_result

    Steam.uploadLeaderboardScore(get_total_score(), true,
        [int(time_survived), difficulty_level])  # Details
```

### Local High Scores

```gdscript
func save_local_high_score() -> void:
    var score = get_total_score()
    if score > save_data.endless_high_score:
        save_data.endless_high_score = score
        save_data.endless_best_time = time_survived
        save_manager.save_game()
```

---

## Achievements

| Achievement | Requirement |
|-------------|-------------|
| Survivor | Reach difficulty 10 |
| Endurance | Survive 10 minutes |
| Unstoppable | Reach difficulty 20 |
| Eternity | Survive 30 minutes |

```gdscript
func _check_endless_achievements() -> void:
    if difficulty_level >= 10:
        achievement_manager.unlock_achievement("SURVIVOR")
    if difficulty_level >= 20:
        achievement_manager.unlock_achievement("UNSTOPPABLE")
    if time_survived >= 600:  # 10 minutes
        achievement_manager.unlock_achievement("ENDURANCE")
    if time_survived >= 1800:  # 30 minutes
        achievement_manager.unlock_achievement("ETERNITY")
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `combat/scripts/endless_spawner.gd` | Endless spawning |
| `combat/scripts/endless_score.gd` | Score tracking |
| `combat/scenes/EndlessMode.tscn` | Mode scene |
| `metagame/scenes/EndlessResults.tscn` | Results screen |

---

## Balance Notes

### Target Difficulty Curve

| Time | Difficulty | Feel |
|------|------------|------|
| 0:00-1:00 | 1-2 | Warm-up |
| 1:00-3:00 | 3-6 | Comfortable |
| 3:00-5:00 | 7-10 | Challenging |
| 5:00-10:00 | 11-20 | Intense |
| 10:00+ | 21+ | Overwhelming |

Most players should die between 3-7 minutes. Top players might survive 15-20 minutes.

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Infinite spawning | Budget-based continuous |
| Difficulty scaling | Exponential growth |
| Scoring | Kills + time + combo |
| Mutations | Unlimited stacking |
| Leaderboard | Steam integration |

Endless mode is pure arcade. No story, no objectives, just a score to beat. It's the mode for players who want to prove their skill.

---

[← Back to Daily Challenges](daily-challenges.md) | [Next: Endings →](endings.md)
