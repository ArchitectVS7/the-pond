# Appendix A: Tunable Parameters Index

Every `@export` variable across The Pond, organized by system.

---

## Combat System

### Player Controller
`combat/scripts/player_controller.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `move_speed` | 200.0 | float | Player movement speed (pixels/sec) |

### Tongue Attack
`combat/scripts/tongue_attack.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `base_damage` | 1 | int | Damage per hit |
| `attack_cooldown` | 0.3 | float | Seconds between attacks |
| `extend_duration` | 0.15 | float | Tongue extend animation time |
| `retract_duration` | 0.1 | float | Tongue retract animation time |
| `max_range` | 144.0 | float | Maximum tongue reach (3 tiles) |
| `extend_overshoot` | 0.15 | float | Overshoot ratio (0.0-0.5) |
| `elastic_strength` | 2.0 | float | Elastic snap strength (1.0-5.0) |
| `retract_snap` | 2.5 | float | Retraction snap force (1.0-4.0) |

### Enemy Base
`combat/scripts/enemy_base.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `enemy_name` | "Basic Enemy" | String | Display name |
| `max_hp` | 1 | int | Hit points |
| `move_speed` | 80.0 | float | Movement speed (pixels/sec) |
| `score_value` | 10 | int | Points on kill |
| `contact_damage` | 1 | int | Damage to player on contact |
| `behavior_mode` | CHASE | enum | AI behavior (CHASE/WANDER/ORBIT) |
| `wander_speed` | 40.0 | float | Speed during wander behavior |
| `wander_interval` | 1.5 | float | Seconds between direction changes |
| `orbit_distance` | 100.0 | float | Distance to maintain when orbiting |
| `orbit_speed` | 60.0 | float | Speed during orbit behavior |
| `separation_enabled` | true | bool | Enable flocking separation |
| `separation_radius` | 30.0 | float | Radius for separation check |
| `separation_strength` | 50.0 | float | Force of separation |

### Enemy Spawner
`combat/scripts/enemy_spawner.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `basic_enemy_scene` | - | PackedScene | Basic enemy prefab |
| `fast_enemy_scene` | - | PackedScene | Fast enemy prefab |
| `base_spawn_interval` | 2.0 | float | Starting spawn rate |
| `min_spawn_interval` | 0.3 | float | Fastest spawn rate |
| `spawn_interval_reduction` | 0.15 | float | Reduction per escalation |
| `escalation_interval` | 60.0 | float | Seconds between escalations |
| `spawn_radius` | 600.0 | float | Spawn distance from player |
| `max_enemies` | 100 | int | Maximum active enemies |
| `spatial_hash_cell_size` | 64.0 | float | Cell size for spatial hash |
| `pooling_enabled` | true | bool | Use object pooling |
| `pool_prewarm_count` | 50 | int | Pre-instantiated pool size |
| `pool_max_size` | 500 | int | Maximum pool size |

---

## Boss System

### Boss Base
`combat/scripts/boss_base.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `total_hp` | 100 | int | Total boss HP |
| `phase_2_threshold` | 0.66 | float | HP% for phase 2 |
| `phase_3_threshold` | 0.33 | float | HP% for phase 3 |
| `phase_transition_duration` | 2.0 | float | Transition animation time |
| `intro_duration` | 3.0 | float | Intro sequence time |
| `evidence_spawn_delay` | 1.0 | float | Delay before evidence drop |
| `evidence_id` | "" | String | Evidence ID on defeat |
| `hp_scale_per_mutation` | 0.05 | float | HP increase per player mutation |
| `speed_scale_per_mutation` | 0.02 | float | Speed increase per mutation |
| `max_scaling` | 1.5 | float | Maximum scaling multiplier |
| `hard_mode_multiplier` | 1.5 | float | Hard mode stat multiplier |

### The Lobbyist
`combat/scripts/boss_lobbyist.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `p1_bullet_speed` | 150.0 | float | Phase 1 bullet speed |
| `p1_cooldown` | 2.0 | float | Phase 1 attack cooldown |
| `p2_bullet_speed` | 200.0 | float | Phase 2 bullet speed |
| `p2_cooldown` | 1.5 | float | Phase 2 attack cooldown |
| `p2_radial_count` | 8 | int | Bullets per radial burst |
| `p3_bullet_speed` | 250.0 | float | Phase 3 bullet speed |
| `p3_cooldown` | 1.0 | float | Phase 3 attack cooldown |
| `p3_spiral_speed` | 90.0 | float | Spiral rotation speed (deg/sec) |

### The CEO
`combat/scripts/boss_ceo.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `ceo_total_hp` | 150 | int | CEO total HP |
| `ceo_p1_wall_speed` | 120.0 | float | Bullet wall speed |
| `ceo_p1_wall_count` | 5 | int | Bullets per wall |
| `ceo_p1_wall_spacing` | 100.0 | float | Gap between wall bullets |
| `ceo_p2_homing_strength` | 2.0 | float | Homing missile tracking |
| `ceo_p2_homing_duration` | 3.0 | float | Homing active time |
| `ceo_p2_cooldown` | 2.5 | float | Phase 2 cooldown |
| `ceo_p3_spawn_interval` | 0.5 | float | Chaos spawn interval |
| `ceo_p3_chaos_count` | 8 | int | Bullets per chaos burst |
| `ceo_p3_cooldown` | 1.2 | float | Phase 3 cooldown |

### Boss Arena
`combat/scripts/boss_arena.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `arena_width` | 800 | int | Arena width (pixels) |
| `arena_height` | 600 | int | Arena height (pixels) |
| `spawn_delay` | 1.0 | float | Delay before boss appears |
| `lock_fade_duration` | 0.5 | float | Door lock animation time |
| `boss_scene` | - | PackedScene | Boss scene to spawn |

### Boss Dialogue
`combat/scripts/boss_dialogue.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `display_time` | 3.0 | float | Seconds per dialogue line |
| `font_size` | 16 | int | Dialogue font size |
| `fade_duration` | 0.3 | float | Fade in/out duration |

---

## Conspiracy Board

### Main Board
`conspiracy_board/scripts/conspiracy_board.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `vignette_strength` | 0.2 | float | Edge darkening (0.0-1.0) |
| `vignette_radius` | 0.8 | float | Vignette inner radius |
| `snap_distance` | 50.0 | float | Pin snap detection radius |
| `snap_animation_duration` | 0.1 | float | Snap animation time |
| `pin_positions` | [...] | Array[Vector2] | Valid pin locations |
| `pulse_duration` | 0.2 | float | Connection pulse time |
| `pulse_scale` | 1.1 | float | Pulse scale factor |
| `progress_total` | 7 | int | Total evidence pieces |
| `focus_border_width` | 3.0 | float | Keyboard focus border |
| `focus_border_color` | YELLOW | Color | Focus highlight color |

### Data Log Card
`conspiracy_board/scripts/data_log_card.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `card_width` | 200 | int | Card width (pixels) |
| `card_height` | 150 | int | Card height (pixels) |
| `preview_max_chars` | 80 | int | TL;DR character limit |
| `undiscovered_alpha` | 0.3 | float | Hidden card opacity |
| `drag_threshold` | 5.0 | float | Pixels before drag starts |
| `drag_opacity` | 0.8 | float | Opacity while dragging |
| `discovered_color` | beige | Color | Background for discovered |
| `undiscovered_color` | gray | Color | Background for hidden |
| `title_color` | dark | Color | Title text color |
| `preview_color` | dark | Color | Preview text color |

### String Renderer
`conspiracy_board/scripts/string_renderer.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `string_width` | 2.0 | float | Line thickness |
| `string_color` | RED | Color | String color |
| `string_segments` | 20 | int | Bezier curve segments |
| `string_stiffness` | 150.0 | float | Physics spring constant |
| `string_damping` | 8.0 | float | Physics damping |
| `settle_time` | 0.3 | float | Settle animation duration |
| `max_stretch` | 1.5 | float | Maximum stretch ratio |
| `physics_enabled` | true | bool | Enable physics simulation |
| `bezier_curve_amount` | 50.0 | float | Curve control point offset |

### Document Viewer
`conspiracy_board/scripts/document_viewer.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `viewer_width` | 600 | int | Popup width |
| `viewer_height` | 400 | int | Popup height |
| `animation_duration` | 0.3 | float | Open/close animation time |
| `open_scale_overshoot` | 1.05 | float | Bounce overshoot |

---

## Mutation System

### Mutation Manager
`metagame/scripts/mutation_manager.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `max_mutations` | 10 | int | Max mutations per run |
| `allow_duplicates` | false | bool | Allow duplicate mutations |

### Level Up UI
`metagame/scripts/level_up_ui.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `options_count` | 3 | int | Choices presented |
| `card_width` | 200 | int | Mutation card width |
| `card_height` | 280 | int | Mutation card height |
| `card_spacing` | 40 | int | Space between cards |
| `animation_duration` | 0.3 | float | Card animation time |

### Mutation Card
`metagame/scripts/mutation_card.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `hover_scale` | 1.05 | float | Scale on hover |
| `hover_duration` | 0.15 | float | Hover animation time |

### Pollution Meter
`metagame/scripts/pollution_meter.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `meter_width` | 150 | int | Meter width (pixels) |
| `meter_height` | 20 | int | Meter height (pixels) |
| `meter_position` | (20, 20) | Vector2 | Screen position |
| `fill_direction` | 0 | int | 0=left-to-right |
| `color_low` | GREEN | Color | Low pollution color |
| `color_mid` | YELLOW | Color | Medium pollution color |
| `color_high` | RED | Color | High pollution color |
| `threshold_low` | 0.33 | float | Low/mid threshold |
| `threshold_high` | 0.67 | float | Mid/high threshold |
| `color_lerp_enabled` | true | bool | Smooth color transitions |
| `message_low` | "..." | String | Low pollution tooltip |
| `message_mid` | "..." | String | Medium pollution tooltip |
| `message_high` | "..." | String | High pollution tooltip |
| `tooltip_delay` | 0.5 | float | Tooltip appear delay |
| `pollution_per_mutation` | 15.0 | float | Base pollution per mutation |
| `oil_mutation_weight` | 1.5 | float | Oil mutation multiplier |
| `toxic_mutation_weight` | 1.2 | float | Toxic mutation multiplier |
| `mercury_mutation_weight` | 2.0 | float | Mercury mutation multiplier |
| `max_pollution` | 100.0 | float | Maximum pollution value |
| `update_animation` | true | bool | Animate meter changes |
| `pulse_duration` | 0.3 | float | Pulse animation time |
| `pulse_scale` | 1.1 | float | Pulse scale factor |

---

## Abilities

### Oil Trail
`metagame/scripts/abilities/oil_trail_ability.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `trail_damage` | 2 | int | Damage per tick |
| `trail_duration` | 3.0 | float | Trail lifetime |
| `spawn_interval` | 0.1 | float | Pool spawn rate |
| `trail_scene` | - | PackedScene | Oil pool scene |

### Toxic Aura
`metagame/scripts/abilities/toxic_aura_ability.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `aura_damage` | 1 | int | Damage per tick |
| `damage_interval` | 1.0 | float | Time between ticks |
| `aura_radius` | 80.0 | float | Effect radius |

### War Croak
`metagame/scripts/abilities/war_croak_ability.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `stun_duration` | 2.0 | float | Enemy stun time |
| `stun_radius` | 150.0 | float | Effect radius |
| `ability_cooldown` | 10.0 | float | Cooldown between uses |

### Lily Pad
`metagame/scripts/abilities/lily_pad_ability.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `platform_duration` | 5.0 | float | Platform lifetime |
| `ability_cooldown` | 8.0 | float | Cooldown between uses |
| `platform_scene` | - | PackedScene | Platform scene |

### Double Jump (Dash)
`metagame/scripts/abilities/double_jump_ability.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `dash_speed` | 400.0 | float | Dash velocity |
| `dash_duration` | 0.2 | float | Dash time |
| `dash_cooldown` | 1.0 | float | Cooldown between dashes |

### Split Tongue
`metagame/scripts/abilities/split_tongue_ability.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `cone_angle` | 30.0 | float | Attack cone angle |
| `cone_range` | 120.0 | float | Attack range |

### Regeneration
`metagame/scripts/abilities/regeneration_ability.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `heal_amount` | 1 | int | HP healed per tick |
| `heal_interval` | 30.0 | float | Seconds between heals |

---

## Game Feel

### Screen Shake
`shared/scripts/screen_shake.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `shake_enabled` | true | bool | Enable screen shake |
| `base_intensity` | 1.0 | float | Base shake strength |
| `max_offset` | 16.0 | float | Maximum pixel offset |
| `trauma_decay_rate` | 1.5 | float | Trauma decay per second |
| `max_trauma` | 1.0 | float | Maximum trauma value |
| `shake_power` | 2.0 | float | Trauma-to-shake exponent |
| `hit_trauma` | 0.2 | float | Trauma from hit |
| `kill_trauma` | 0.4 | float | Trauma from kill |
| `hit_duration` | 0.15 | float | Hit shake duration |
| `kill_duration` | 0.25 | float | Kill shake duration |

### Hit Stop
`shared/scripts/hit_stop.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `hit_stop_enabled` | true | bool | Enable hit stop |
| `default_duration` | 0.033 | float | Default freeze (2 frames) |
| `freeze_time_scale` | 0.0 | float | Time scale during freeze |
| `kill_duration_multiplier` | 1.0 | float | Kill duration multiplier |

### Particle Manager
`shared/scripts/particle_manager.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `max_particles` | 200 | int | Maximum active particles |
| `hit_particle_lifetime` | 0.5 | float | Hit particle duration |
| `death_particle_lifetime` | 0.8 | float | Death particle duration |
| `hit_particle_amount` | 8 | int | Particles per hit |
| `death_particle_amount` | 16 | int | Particles per death |
| `hit_particle_speed` | 100.0 | float | Hit particle velocity |
| `death_particle_speed` | 150.0 | float | Death particle velocity |
| `hit_color` | warm white | Color | Hit particle color |
| `death_color` | green | Color | Death particle color |

### Audio Manager
`shared/scripts/audio_manager.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `sfx_enabled` | true | bool | Enable sound effects |
| `master_volume` | 1.0 | float | Master volume (0.0-1.0) |
| `pitch_variation` | 0.1 | float | Random pitch range |
| `max_simultaneous_sounds` | 16 | int | Max concurrent sounds |
| `hit_sound` | - | AudioStream | Hit sound asset |
| `death_sound` | - | AudioStream | Death sound asset |

---

## Performance

### Performance Monitor
`shared/scripts/performance_monitor.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `target_fps` | 60.0 | float | Target framerate |
| `warning_threshold_fps` | 55.0 | float | Warning threshold |
| `tracking_enabled` | false | bool | Enable tracking |
| `smoothing_frames` | 30 | int | FPS averaging window |

### Input Latency Monitor
`shared/scripts/input_latency_monitor.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `target_latency_ms` | 16.67 | float | Target latency (ms) |
| `warn_on_exceed` | true | bool | Log warnings |

### Object Pool
`shared/scripts/object_pool.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `max_pool_size` | 500 | int | Maximum pool capacity |
| `auto_grow` | true | bool | Auto-expand when empty |
| `pool_container` | - | Node | Parent for pooled objects |

### Bullet Pool Manager
`combat/scripts/bullet_pool_manager.gd`

| Parameter | Default | Type | Description |
|-----------|---------|------|-------------|
| `enable_prewarm` | true | bool | Pre-warm on ready |
| `shared_area_name` | "0" | String | SharedArea node name |
| `basic_bullet_pool_size` | 200 | int | Basic bullet pool |
| `fast_bullet_pool_size` | 150 | int | Fast bullet pool |
| `spiral_bullet_pool_size` | 150 | int | Spiral bullet pool |
| `boss_bullet_pool_size` | 500 | int | Boss pattern pool |
| `enable_monitoring` | true | bool | Pool health monitoring |
| `monitor_interval` | 1.0 | float | Health check interval |
| `warn_on_auto_growth` | true | bool | Warn on expansion |
| `debug_logging` | false | bool | Verbose logging |

---

## Usage Notes

### Modifying Parameters

In the Godot Inspector:
1. Select the node with the script
2. Expand "Export Variables" section
3. Modify values directly

In code:
```gdscript
@onready var spawner = $EnemySpawner
spawner.base_spawn_interval = 1.5  # Faster spawning
```

### Balance Guidelines

| System | Sensitive Parameters |
|--------|---------------------|
| Combat | `attack_cooldown`, `max_range`, `move_speed` |
| Enemies | `spawn_interval_reduction`, `max_enemies` |
| Bosses | `phase_thresholds`, `bullet_speed` |
| Mutations | `pollution_per_mutation`, weight values |
| Game Feel | `hit_trauma`, `default_duration` |

Small changes compound. Test thoroughly after any balance adjustment.

---

[Back to Index](../index.md)
