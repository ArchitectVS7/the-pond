# Appendix C: API Reference

Key classes, methods, and signals across The Pond codebase.

---

## Combat System

### PlayerController
`combat/scripts/player_controller.gd`

**Signals**:
```gdscript
signal player_hit(damage: int)
signal player_died()
signal position_changed(new_position: Vector2)
```

**Key Methods**:
```gdscript
func get_aim_direction() -> Vector2
    # Returns normalized vector toward mouse cursor

func take_damage(amount: int) -> void
    # Applies damage, triggers hit feedback, checks death

func heal(amount: int) -> void
    # Restores HP up to max_hp
```

### TongueAttack
`combat/scripts/tongue_attack.gd`

**Signals**:
```gdscript
signal attack_started()
signal attack_hit(target: Node2D)
signal attack_ended()
```

**Key Methods**:
```gdscript
func can_attack() -> bool
    # Returns true if cooldown has elapsed

func start_attack(direction: Vector2) -> void
    # Initiates tongue extension toward direction

func get_current_reach() -> float
    # Returns current tongue length during animation
```

### EnemyBase
`combat/scripts/enemy_base.gd`

**Signals**:
```gdscript
signal enemy_died(enemy: Node2D, score: int)
signal enemy_hit(damage: int)
```

**Key Methods**:
```gdscript
func take_damage(amount: int) -> void
    # Applies damage, plays hit animation, checks death

func set_target(target: Node2D) -> void
    # Sets chase target (usually player)

func get_behavior_velocity() -> Vector2
    # Returns movement vector based on behavior_mode
```

### EnemySpawner
`combat/scripts/enemy_spawner.gd`

**Signals**:
```gdscript
signal enemy_spawned(enemy: Node2D)
signal wave_complete(wave_number: int)
signal escalation_triggered(new_interval: float)
```

**Key Methods**:
```gdscript
func start_spawning() -> void
    # Begins spawn loop

func stop_spawning() -> void
    # Halts spawn loop

func spawn_enemy(scene: PackedScene) -> Node2D
    # Instantiates enemy from pool at valid location

func get_active_enemy_count() -> int
    # Returns number of living enemies

func clear_all_enemies() -> void
    # Despawns all enemies (boss transition)
```

### SpatialHash
`combat/scripts/spatial_hash.gd`

**Key Methods**:
```gdscript
func insert(object: Node2D) -> void
    # Adds object to spatial hash

func remove(object: Node2D) -> void
    # Removes object from spatial hash

func query_radius(center: Vector2, radius: float) -> Array[Node2D]
    # Returns all objects within radius of center

func query_rect(rect: Rect2) -> Array[Node2D]
    # Returns all objects within rectangle

func clear() -> void
    # Removes all objects
```

---

## Boss System

### BossBase
`combat/scripts/boss_base.gd`

**Signals**:
```gdscript
signal phase_changed(new_phase: int)
signal boss_defeated()
signal health_changed(new_hp: int, max_hp: int)
signal dialogue_triggered(dialogue_id: String)
```

**Key Methods**:
```gdscript
func start_fight() -> void
    # Initializes boss, plays intro, starts patterns

func take_damage(amount: int) -> void
    # Applies damage, checks phase transitions

func get_current_phase() -> int
    # Returns 1, 2, or 3

func trigger_phase_transition(phase: int) -> void
    # Plays transition animation, changes patterns

func spawn_evidence() -> void
    # Spawns evidence pickup on defeat
```

### BossDialogue
`combat/scripts/boss_dialogue.gd`

**Signals**:
```gdscript
signal dialogue_finished()
```

**Key Methods**:
```gdscript
func show_dialogue(text: String, duration: float = -1) -> void
    # Displays dialogue with optional duration override

func queue_dialogue(lines: Array[String]) -> void
    # Queues multiple lines to show sequentially

func skip_current() -> void
    # Skips to next line or ends dialogue
```

---

## Conspiracy Board

### ConspiracyBoard
`conspiracy_board/scripts/conspiracy_board.gd`

**Signals**:
```gdscript
signal card_placed(card: DataLogCard, pin: Vector2)
signal connection_made(from_card: DataLogCard, to_card: DataLogCard)
signal progress_updated(current: int, total: int)
signal board_complete()
```

**Key Methods**:
```gdscript
func add_card(data: DataLogResource, position: Vector2) -> DataLogCard
    # Creates and positions a data log card

func create_connection(from: DataLogCard, to: DataLogCard) -> void
    # Creates string connection between cards

func get_progress() -> Dictionary
    # Returns {discovered: int, total: int, connections: int}

func save_board_state() -> Dictionary
    # Serializes current board for save file

func load_board_state(state: Dictionary) -> void
    # Restores board from save data
```

### DataLogCard
`conspiracy_board/scripts/data_log_card.gd`

**Signals**:
```gdscript
signal card_clicked(card: DataLogCard)
signal card_dragged(card: DataLogCard, position: Vector2)
signal card_dropped(card: DataLogCard, position: Vector2)
signal card_double_clicked(card: DataLogCard)
```

**Key Methods**:
```gdscript
func set_data(resource: DataLogResource) -> void
    # Populates card with data log content

func set_discovered(discovered: bool) -> void
    # Updates visual state for discovered/hidden

func show_preview() -> void
    # Displays TL;DR preview

func show_full_text() -> void
    # Opens document viewer with full text
```

### StringRenderer
`conspiracy_board/scripts/string_renderer.gd`

**Key Methods**:
```gdscript
func connect_points(from: Vector2, to: Vector2) -> void
    # Creates string between two points

func update_endpoint(index: int, position: Vector2) -> void
    # Moves string endpoint (for dragging)

func apply_physics(delta: float) -> void
    # Updates string physics simulation

func is_settled() -> bool
    # Returns true when string has stopped moving
```

### DocumentViewer
`conspiracy_board/scripts/document_viewer.gd`

**Signals**:
```gdscript
signal viewer_opened(data: DataLogResource)
signal viewer_closed()
signal text_mode_changed(is_full_text: bool)
```

**Key Methods**:
```gdscript
func open(data: DataLogResource) -> void
    # Opens viewer with data log content

func close() -> void
    # Closes viewer with animation

func toggle_text_mode() -> void
    # Switches between TL;DR and full text

func is_showing_full_text() -> bool
    # Returns current text mode
```

---

## Mutation System

### MutationManager
`metagame/scripts/mutation_manager.gd`

**Signals**:
```gdscript
signal mutation_added(mutation: MutationResource)
signal mutation_removed(mutation: MutationResource)
signal synergy_activated(synergy: SynergyResource)
signal mutations_changed(mutations: Array[MutationResource])
```

**Key Methods**:
```gdscript
func add_mutation(mutation: MutationResource) -> bool
    # Adds mutation, returns false if at max

func remove_mutation(mutation_id: String) -> void
    # Removes mutation by ID

func has_mutation(mutation_id: String) -> bool
    # Returns true if player has mutation

func get_active_mutations() -> Array[MutationResource]
    # Returns all active mutations

func check_synergies() -> Array[SynergyResource]
    # Returns newly activated synergies

func apply_modifiers(player: PlayerController) -> void
    # Applies all mutation stat modifiers
```

### LevelUpUI
`metagame/scripts/level_up_ui.gd`

**Signals**:
```gdscript
signal mutation_selected(mutation: MutationResource)
signal level_up_cancelled()
```

**Key Methods**:
```gdscript
func show_choices(mutations: Array[MutationResource]) -> void
    # Displays mutation choice cards

func hide() -> void
    # Closes level-up UI

func get_random_mutations(count: int) -> Array[MutationResource]
    # Returns random valid mutation choices
```

### PollutionMeter
`metagame/scripts/pollution_meter.gd`

**Signals**:
```gdscript
signal pollution_changed(new_value: float, max_value: float)
signal threshold_crossed(level: String)  # "low", "mid", "high"
```

**Key Methods**:
```gdscript
func add_pollution(amount: float) -> void
    # Increases pollution level

func get_current_pollution() -> float
    # Returns current value (0 to max)

func get_pollution_percentage() -> float
    # Returns 0.0 to 1.0

func get_current_level() -> String
    # Returns "low", "mid", or "high"
```

---

## Save System

### SaveManager
`core/scripts/save_manager.gd`

**Signals**:
```gdscript
signal save_completed(success: bool)
signal load_completed(success: bool)
signal save_corrupted(backup_available: bool)
```

**Key Methods**:
```gdscript
func save_game() -> bool
    # Saves current game state, returns success

func load_game() -> bool
    # Loads save file, returns success

func has_save_file() -> bool
    # Returns true if save exists

func delete_save() -> void
    # Deletes save file (new game)

func get_save_data() -> Dictionary
    # Returns current save data structure

func validate_checksum(data: Dictionary) -> bool
    # Verifies save file integrity
```

### SteamManager
`core/scripts/steam_manager.gd`

**Signals**:
```gdscript
signal steam_initialized(success: bool)
signal cloud_sync_completed(success: bool)
signal achievement_unlocked(achievement_id: String)
signal leaderboard_uploaded(success: bool)
```

**Key Methods**:
```gdscript
func is_steam_running() -> bool
    # Returns true if Steam client is active

func upload_to_cloud(filename: String, data: PackedByteArray) -> void
    # Uploads save data to Steam Cloud

func download_from_cloud(filename: String) -> PackedByteArray
    # Downloads save from Steam Cloud

func unlock_achievement(achievement_id: String) -> void
    # Unlocks Steam achievement

func upload_score(leaderboard: String, score: int) -> void
    # Uploads score to Steam leaderboard
```

### AchievementManager
`core/scripts/achievement_manager.gd`

**Signals**:
```gdscript
signal achievement_unlocked(id: String, name: String)
signal achievement_progress(id: String, current: int, target: int)
```

**Key Methods**:
```gdscript
func unlock_achievement(id: String) -> void
    # Unlocks achievement locally and on Steam

func is_unlocked(id: String) -> bool
    # Returns true if achievement unlocked

func increment_progress(id: String, amount: int = 1) -> void
    # Increments progress-based achievements

func get_all_achievements() -> Array[Dictionary]
    # Returns all achievements with unlock status
```

---

## Game Feel

### ScreenShake
`shared/scripts/screen_shake.gd`

**Key Methods**:
```gdscript
func add_trauma(amount: float) -> void
    # Adds screen shake trauma

func shake_hit() -> void
    # Convenience for hit_trauma amount

func shake_kill() -> void
    # Convenience for kill_trauma amount

func stop_shake() -> void
    # Immediately stops all shake
```

### HitStop
`shared/scripts/hit_stop.gd`

**Key Methods**:
```gdscript
func trigger_hit_stop(duration: float = -1) -> void
    # Freezes game for duration (default: default_duration)

func trigger_kill_stop() -> void
    # Longer freeze for kills

func is_stopped() -> bool
    # Returns true during hit stop
```

### ParticleManager
`shared/scripts/particle_manager.gd`

**Key Methods**:
```gdscript
func spawn_hit_particles(position: Vector2, direction: Vector2) -> void
    # Spawns hit effect particles

func spawn_death_particles(position: Vector2) -> void
    # Spawns death/kill particles

func clear_all() -> void
    # Removes all active particles
```

### AudioManager
`shared/scripts/audio_manager.gd`

**Key Methods**:
```gdscript
func play_hit_sound() -> void
    # Plays hit SFX with pitch variation

func play_death_sound() -> void
    # Plays death SFX with pitch variation

func play_sfx(stream: AudioStream, pitch_vary: bool = true) -> void
    # Plays arbitrary sound effect

func set_volume(volume: float) -> void
    # Sets master volume (0.0-1.0)
```

---

## Accessibility

### AccessibilityManager
`shared/scripts/accessibility_manager.gd`

**Signals**:
```gdscript
signal colorblind_mode_changed(mode: String)
signal text_scale_changed(scale: float)
signal screen_shake_toggled(enabled: bool)
```

**Key Methods**:
```gdscript
func set_colorblind_mode(mode: String) -> void
    # "none", "deuteranopia", "protanopia", "tritanopia"

func set_text_scale(scale: float) -> void
    # 0.8, 1.0, or 1.3

func set_screen_shake_enabled(enabled: bool) -> void
    # Toggles screen shake

func get_settings() -> Dictionary
    # Returns all accessibility settings
```

### InputManager
`core/scripts/input_manager.gd`

**Signals**:
```gdscript
signal controller_connected(device_id: int)
signal controller_disconnected(device_id: int)
signal input_method_changed(method: String)  # "keyboard", "controller"
```

**Key Methods**:
```gdscript
func get_input_method() -> String
    # Returns current input method

func is_controller_connected() -> bool
    # Returns true if any controller connected

func get_controller_type() -> String
    # "xbox", "playstation", "steam_deck", "generic"

func rebind_action(action: String, event: InputEvent) -> void
    # Rebinds action to new input
```

---

## Object Pool

### ObjectPool
`shared/scripts/object_pool.gd`

**Key Methods**:
```gdscript
func get_object() -> Node
    # Returns pooled object (or creates new if empty)

func return_object(object: Node) -> void
    # Returns object to pool

func prewarm(count: int) -> void
    # Pre-instantiates objects

func get_pool_size() -> int
    # Returns current pool capacity

func get_active_count() -> int
    # Returns objects currently in use
```

---

## Usage Patterns

### Connecting Signals
```gdscript
func _ready() -> void:
    var spawner = $EnemySpawner
    spawner.enemy_spawned.connect(_on_enemy_spawned)
    spawner.escalation_triggered.connect(_on_escalation)

func _on_enemy_spawned(enemy: Node2D) -> void:
    enemy.enemy_died.connect(_on_enemy_died)
```

### Querying Systems
```gdscript
func _process(_delta: float) -> void:
    var nearby = spatial_hash.query_radius(player.position, 100.0)
    for enemy in nearby:
        # Process nearby enemies
        pass
```

### Save/Load Pattern
```gdscript
func save_progress() -> void:
    var state = {
        "board": conspiracy_board.save_board_state(),
        "mutations": mutation_manager.get_active_mutations(),
        "pollution": pollution_meter.get_current_pollution()
    }
    SaveManager.get_save_data()["progress"] = state
    SaveManager.save_game()
```

---

[Back to Index](../index.md)
