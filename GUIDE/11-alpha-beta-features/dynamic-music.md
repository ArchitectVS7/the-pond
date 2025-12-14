# Dynamic Music

Dynamic music crossfades between layers based on combat intensity. Calm exploration has ambient tones. Combat ramps up. Boss fights get their own tracks.

---

## Overview

| Story | Description | Epic |
|-------|-------------|------|
| MUSIC-001 | Combat intensity calculation | EPIC-016 |
| MUSIC-002 | Music layer system | EPIC-016 |
| MUSIC-003 | Crossfade implementation | EPIC-016 |
| MUSIC-004 | Boss music triggers | EPIC-016 |
| MUSIC-005 | Victory/defeat stingers | EPIC-016 |
| MUSIC-006 | Audio mixing balance | EPIC-016 |

---

## Music Layers

### Layer Types

| Layer | When Active | Volume |
|-------|-------------|--------|
| Ambient | No enemies nearby | 100% |
| Combat Low | 1-10 enemies | 100% |
| Combat High | 10+ enemies | 100% |
| Boss | Boss fight | 100% |

All layers play simultaneously. Only volume changes.

### Layer System

```gdscript
# dynamic_music_manager.gd
class_name DynamicMusicManager
extends Node

enum MusicState { AMBIENT, COMBAT_LOW, COMBAT_HIGH, BOSS }

@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer
@onready var combat_low_player: AudioStreamPlayer = $CombatLowPlayer
@onready var combat_high_player: AudioStreamPlayer = $CombatHighPlayer
@onready var boss_player: AudioStreamPlayer = $BossPlayer

var current_state: MusicState = MusicState.AMBIENT
var target_volumes: Dictionary = {
    "ambient": 1.0,
    "combat_low": 0.0,
    "combat_high": 0.0,
    "boss": 0.0
}
```

---

## Intensity Calculation

```gdscript
func calculate_intensity() -> float:
    var enemy_count = enemy_spawner.get_active_enemy_count()
    var boss_active = boss_manager.is_boss_active()

    if boss_active:
        return 1.0  # Max intensity

    # Scale 0-1 based on enemy count
    return clamp(enemy_count / INTENSITY_ENEMY_MAX, 0.0, 1.0)
```

### Intensity Thresholds

| Intensity | Music State |
|-----------|-------------|
| 0.0 | Ambient |
| 0.01-0.4 | Combat Low |
| 0.4+ | Combat High |
| Boss active | Boss |

```gdscript
@export var combat_low_threshold: float = 0.01
@export var combat_high_threshold: float = 0.4
@export var intensity_enemy_max: float = 25.0
```

---

## Crossfade Implementation

### Linear Crossfade

```gdscript
func crossfade_to(new_state: MusicState, duration: float = 2.0) -> void:
    if new_state == current_state:
        return

    current_state = new_state
    _set_target_volumes(new_state)

    var tween = create_tween()
    tween.set_parallel(true)

    tween.tween_property(ambient_player, "volume_db",
        _to_db(target_volumes.ambient), duration)
    tween.tween_property(combat_low_player, "volume_db",
        _to_db(target_volumes.combat_low), duration)
    tween.tween_property(combat_high_player, "volume_db",
        _to_db(target_volumes.combat_high), duration)
    tween.tween_property(boss_player, "volume_db",
        _to_db(target_volumes.boss), duration)

func _to_db(linear: float) -> float:
    if linear <= 0.0:
        return -80.0  # Effectively silent
    return linear_to_db(linear)
```

### Target Volumes

```gdscript
func _set_target_volumes(state: MusicState) -> void:
    target_volumes = {
        "ambient": 0.0,
        "combat_low": 0.0,
        "combat_high": 0.0,
        "boss": 0.0
    }

    match state:
        MusicState.AMBIENT:
            target_volumes.ambient = 1.0
        MusicState.COMBAT_LOW:
            target_volumes.combat_low = 1.0
        MusicState.COMBAT_HIGH:
            target_volumes.combat_high = 1.0
        MusicState.BOSS:
            target_volumes.boss = 1.0
```

---

## Update Loop

```gdscript
func _process(delta: float) -> void:
    var intensity = calculate_intensity()
    var new_state = _determine_state(intensity)

    if new_state != current_state:
        crossfade_to(new_state)

func _determine_state(intensity: float) -> MusicState:
    if boss_manager.is_boss_active():
        return MusicState.BOSS

    if intensity >= combat_high_threshold:
        return MusicState.COMBAT_HIGH
    elif intensity >= combat_low_threshold:
        return MusicState.COMBAT_LOW
    else:
        return MusicState.AMBIENT
```

---

## Tunable Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `crossfade_duration` | 2.0 | 0.5-5.0 | Transition smoothness |
| `combat_low_threshold` | 0.01 | 0.0-0.5 | When combat music starts |
| `combat_high_threshold` | 0.4 | 0.2-0.8 | When intense music starts |
| `intensity_enemy_max` | 25.0 | 10-50 | Enemy count for max intensity |
| `boss_volume_multiplier` | 1.2 | 1.0-1.5 | Boss music prominence |

---

## Stingers

Short musical phrases for events:

### Victory Stinger

```gdscript
func play_victory_stinger() -> void:
    var stinger = preload("res://audio/music/victory_stinger.ogg")
    $StingerPlayer.stream = stinger
    $StingerPlayer.play()

    # Duck other music
    _duck_music(0.3, 2.0)
```

### Defeat Stinger

```gdscript
func play_defeat_stinger() -> void:
    var stinger = preload("res://audio/music/defeat_stinger.ogg")
    $StingerPlayer.stream = stinger
    $StingerPlayer.play()

    # Fade out combat music
    crossfade_to(MusicState.AMBIENT, 1.0)
```

### Boss Intro Stinger

```gdscript
func play_boss_intro() -> void:
    var stinger = preload("res://audio/music/boss_intro.ogg")
    $StingerPlayer.stream = stinger
    $StingerPlayer.play()

    # Delay boss music until stinger ends
    await $StingerPlayer.finished
    crossfade_to(MusicState.BOSS, 0.5)
```

---

## Audio Bus Setup

```
Master
├── Music
│   ├── MusicAmbient
│   ├── MusicCombat
│   └── MusicBoss
├── SFX
└── UI
```

```gdscript
func _ready() -> void:
    ambient_player.bus = "MusicAmbient"
    combat_low_player.bus = "MusicCombat"
    combat_high_player.bus = "MusicCombat"
    boss_player.bus = "MusicBoss"
```

---

## Avoiding Pops/Clicks

### Sync Playback Position

All layers must be time-synchronized:

```gdscript
func _sync_players() -> void:
    var position = ambient_player.get_playback_position()
    combat_low_player.seek(position)
    combat_high_player.seek(position)
    boss_player.seek(position)
```

### Loop Points

Music tracks must loop seamlessly:
- Same BPM across all layers
- Same length (or multiples)
- Clean loop points (no audio at boundaries)

---

## Files to Create

| File | Purpose |
|------|---------|
| `core/scripts/dynamic_music_manager.gd` | Music system |
| `audio/music/ambient.ogg` | Exploration music |
| `audio/music/combat_low.ogg` | Light combat |
| `audio/music/combat_high.ogg` | Intense combat |
| `audio/music/boss.ogg` | Boss fight |
| `audio/music/victory_stinger.ogg` | Win sound |
| `audio/music/defeat_stinger.ogg` | Lose sound |

---

## Human Dependencies

| Asset | Requirement |
|-------|-------------|
| Ambient track | 2-4 minutes, loopable |
| Combat tracks | Same BPM as ambient |
| Boss track | Distinct, high energy |
| Stingers | 2-5 seconds each |

All tracks should be composed at the same BPM to allow seamless crossfading.

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Intensity tracking | Enemy count-based |
| Layer switching | Volume crossfade |
| Boss music | Separate trigger |
| Stingers | One-shot with ducking |

Dynamic music makes The Pond feel responsive. Combat intensity has audio feedback. Boss entrances feel dramatic. Victory and defeat have punctuation.

---

[← Back to Visual Mutations](visual-mutations.md) | [Next: Daily Challenges →](daily-challenges.md)
