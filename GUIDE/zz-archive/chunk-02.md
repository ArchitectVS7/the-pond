
## COMBAT-011: Audio Feedback Wet Thwap Glorp

**File**: `shared/scripts/audio_manager.gd`

### Overview

Sound effects provide auditory feedback for combat actions. Uses AudioStreamPlayer pooling for performance. PRD requirement: "wet thwap on hit, glorp on enemy death".

### Main Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `sfx_enabled` | bool | true | Master toggle for accessibility |
| `master_volume` | float | 1.0 | Volume level (0.0 to 1.0) |
| `pitch_variation` | float | 0.1 | Random pitch range (+/- 10%) |
| `max_simultaneous_sounds` | int | 16 | Audio player pool size |

### Sound Resources

| Setting | Type | Default Path | Description |
|---------|------|--------------|-------------|
| `hit_sound` | AudioStream | null | Direct resource for hit sound |
| `death_sound` | AudioStream | null | Direct resource for death sound |
| `hit_sound_path` | String | `res://assets/audio/sfx/hit_thwap.wav` | Fallback path |
| `death_sound_path` | String | `res://assets/audio/sfx/death_glorp.wav` | Fallback path |

### Understanding the Settings

#### `pitch_variation`
Adds random pitch variation to prevent repetitive sound.
- **0.0**: No variation - same pitch every time (robotic)
- **0.05**: Subtle variation - barely noticeable
- **0.1** (default): Natural variation - sounds organic
- **0.2+**: Noticeable variation - may feel inconsistent

**Why Change It**: Increase for more varied sounds (especially with many rapid kills). Decrease for more consistent audio.

#### `max_simultaneous_sounds`
Size of AudioStreamPlayer pool.
- **8**: Minimum - may cut off sounds in intense combat
- **16** (default): Good balance for most scenarios
- **32+**: High - for very rapid sound events

**Why Change It**: Increase if sounds are being cut off during intense combat. Decrease to save memory.

### Audio Asset Requirements

Create audio files at these paths:
```
res://assets/audio/sfx/hit_thwap.wav    # Tongue hit sound
res://assets/audio/sfx/death_glorp.wav  # Enemy death sound
```

**Recommended Audio Specs**:
- **Format**: WAV (uncompressed) or OGG (compressed)
- **Sample Rate**: 44100 Hz
- **Channels**: Mono (stereo unnecessary for SFX)
- **Bit Depth**: 16-bit
- **Duration**: 0.1s - 0.5s (short, punchy)

**Sound Character**:
- **Hit (thwap)**: Wet, fleshy impact. Think frog tongue slapping.
- **Death (glorp)**: Squishy, bubbly pop. Think toxic slime bursting.

### Usage from Code

```gdscript
# Get AudioManager autoload
var audio := get_node("/root/AudioManager")

# Play combat sounds
audio.play_hit()    # Wet thwap
audio.play_death()  # Glorp

# Generic method
audio.play_sfx("hit")
audio.play_sfx("death")

# Check state
var playing := audio.get_playing_count()

# Stop all sounds
audio.stop_all()
```

### Signals

```gdscript
# Connect to sound events
audio.sound_played.connect(_on_sound_played)

func _on_sound_played(sound_type: String) -> void:
    print("Played: %s" % sound_type)
```

### Setup (Autoload)

Add to `project.godot` autoloads:
```
[autoload]
AudioManager="*res://shared/scripts/audio_manager.gd"
```

### Audio Bus Configuration

For proper mixing, create an "SFX" bus in Godot:
1. Open Audio tab (bottom panel)
2. Add bus named "SFX"
3. Adjust volume relative to Master and Music

```
Master
├── Music (for background music)
└── SFX (for sound effects)
```

### Pooling System

AudioManager uses a pool of AudioStreamPlayer nodes:
- Pre-creates `max_simultaneous_sounds` players on startup
- Uses round-robin selection for next player
- Reuses players that finished or replays if still playing
- No runtime allocations during gameplay

### Accessibility Notes

SFX MUST be toggleable per PRD NFR-002. The `sfx_enabled` setting:
- Defaults to `true`
- Should be exposed in Settings menu
- When `false`, no sounds play
- Volume slider should also be available

### Missing Audio Handling

AudioManager gracefully handles missing audio files:
- No errors thrown if file not found
- Signal still emitted (for subtitles/captions)
- Game continues to function normally

This allows development without audio assets while maintaining the feedback system hooks.

---

## COMBAT-012: Performance 60fps GTX 1060 Validation

**File**: `shared/scripts/performance_monitor.gd`

### Overview

Performance monitoring and validation infrastructure to ensure 60fps minimum on target hardware (GTX 1060 @ 1080p). This story provides profiling tools and documents validation procedures.

### PRD Requirements

| Metric | Target | Context |
|--------|--------|---------|
| Minimum FPS | 60 | GTX 1060 / RX 580 @ 1080p |
| Average FPS | 90+ | Streaming headroom |
| Enemies on screen | 500+ | With spatial hash optimization |
| Steam Deck FPS | 55 | @ 800p medium settings |

### PerformanceMonitor Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `target_fps` | float | 60.0 | Target FPS for validation |
| `warning_threshold_fps` | float | 55.0 | Emit warning below this |
| `tracking_enabled` | bool | false | Auto-start tracking |
| `smoothing_frames` | int | 30 | Frames for FPS averaging |

### Usage from Code

```gdscript
# Get PerformanceMonitor (if autoload)
var perf := get_node("/root/PerformanceMonitor")

# Or create instance for specific profiling
var perf := PerformanceMonitor.new()
add_child(perf)

# Start tracking
perf.start_tracking()

# ... run game for a while ...

# Get statistics
var stats := perf.get_statistics()
print("Min FPS: ", stats.min_fps)
print("Avg FPS: ", stats.avg_fps)
print("Meeting target: ", stats.meeting_target)

# Generate full report
perf.print_report()

# Stop tracking
perf.stop_tracking()
```

### Statistics Available

```gdscript
var stats := perf.get_statistics()
# Returns:
# {
#   fps: 62.0,              # Current FPS
#   fps_smoothed: 61.5,     # Averaged FPS
#   frame_time_ms: 16.1,    # Current frame time
#   min_fps: 58.0,          # Minimum recorded
#   max_fps: 120.0,         # Maximum recorded
#   avg_fps: 75.0,          # Average over session
#   frame_count: 3600,      # Frames tracked
#   duration_seconds: 60.0, # Tracking duration
#   memory_mb: 128.5,       # Memory usage
#   object_count: 1500,     # Godot objects
#   target_fps: 60.0,       # Target
#   meeting_target: false   # Pass/fail
# }
```

### Manual Hardware Validation

Since automated tests cannot verify real hardware performance, manual testing is required:

#### Test Environment
- **GPU**: GTX 1060 6GB or RX 580 8GB
- **Resolution**: 1920x1080 (1080p)
- **Settings**: Maximum (no quality reduction)
- **Streaming**: Test with OBS running (Game Capture)

#### Test Scenarios

**Scenario 1: Enemy Stress Test**
1. Spawn 500 enemies
2. Enable PerformanceMonitor tracking
3. Play for 60 seconds
4. Check `min_fps >= 60`

**Scenario 2: Combat Intensity**
1. Start with 100 enemies
2. Attack continuously (all feedback systems active)
3. Verify no frame drops during:
   - Screen shake
   - Particle effects
   - Hit-stop freeze
   - Audio playback

**Scenario 3: Streaming Test**
1. Launch OBS (Game Capture mode)
2. Record at 1080p60
3. Play game at max intensity
4. Verify game maintains 60fps
5. Verify recording is smooth

#### Validation Checklist

```markdown
## Hardware Validation Checklist

### Environment
- [ ] GTX 1060 6GB or equivalent
- [ ] 1080p resolution
- [ ] Maximum quality settings
- [ ] V-Sync OFF (for true FPS measurement)

### Tests
- [ ] 500 enemies: min_fps >= 60
- [ ] Combat stress: no drops below 60
- [ ] Streaming (OBS): min_fps >= 60
- [ ] 10-minute session: avg_fps >= 90

### Results
- Min FPS: ___
- Avg FPS: ___
- Max enemies tested: ___
- Issues found: ___
```

### Optimization Techniques Used

The following optimizations ensure 60fps:

| System | Technique | Story |
|--------|-----------|-------|
| Enemy separation | Spatial hash O(n*k) | COMBAT-007 |
| Particles | Object pooling, 200 cap | COMBAT-009 |
| Audio | AudioStreamPlayer pool | COMBAT-011 |
| Hit-stop | Engine.time_scale (zero overhead) | COMBAT-010 |
| Screen shake | Trauma decay (simple math) | COMBAT-008 |

### Debugging Performance Issues

**If FPS drops below 60:**

1. **Check spatial hash stats**
```gdscript
var stats := spawner.get_spatial_hash_stats()
if stats.avg_per_cell > 30:
    print("Increase spatial_hash_cell_size")
```

2. **Check particle count**
```gdscript
var count := particle_manager.get_active_count()
if count >= 200:
    print("At particle limit - reduce particle amounts")
```

3. **Check audio pool**
```gdscript
var playing := audio_manager.get_playing_count()
if playing >= 16:
    print("Audio pool saturated - increase max_simultaneous_sounds")
```

4. **Use Godot profiler**
   - Run game with `--debug`
   - Open Debugger → Profiler tab
   - Identify functions > 1ms per frame

### Setup (Autoload - Optional)

For global access, add to `project.godot`:
```
[autoload]
PerformanceMonitor="*res://shared/scripts/performance_monitor.gd"
```

---

## COMBAT-013: Input Lag 16ms Validation

**File**: `shared/scripts/input_latency_monitor.gd`

### Overview

Input latency monitoring ensures responsive controls. PRD requires <16ms input lag (1 frame at 60fps). This story provides measurement tools and documents best practices.

### PRD Requirements

| Metric | Target | Calculation |
|--------|--------|-------------|
| Input Lag | <16ms | 1000ms / 60fps = 16.67ms |
| Frame Budget | 16.67ms | Time from input to response |

### InputLatencyMonitor Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `target_latency_ms` | float | 16.67 | Target latency (1 frame) |
| `warn_on_exceed` | bool | true | Push warning on exceed |

### Usage from Code

```gdscript
# Get InputLatencyMonitor (if autoload)
var latency := get_node("/root/InputLatencyMonitor")

# Record input event (in _physics_process or _input)
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        latency.record_input("attack")
        _start_attack()

# Record response (when action takes effect)
func _start_attack() -> void:
    latency.record_response("attack")
    # ... attack logic ...
```

### Measuring Latency

```gdscript
# Get last measurement
var last := latency.get_last_latency_ms("attack")

# Get statistics
var avg := latency.get_average_latency_ms("attack")
var max := latency.get_max_latency_ms("attack")
var min := latency.get_min_latency_ms("attack")

# Check if acceptable
if latency.is_action_acceptable("attack"):
    print("Attack latency OK")

# Generate full report
latency.print_report()
```

### Best Practices for Low Latency

#### 1. Use _physics_process for Input

```gdscript
# GOOD: Input handled in _physics_process
# Consistent 60fps timing, synchronized with physics
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        perform_attack()

# BAD: Input handled in _process
# Variable frame rate, unpredictable timing
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        perform_attack()
```

**Why**: `_physics_process` runs at a fixed 60fps, giving predictable 16.67ms frame timing. `_process` runs every frame which can vary.

#### 2. Avoid Input Accumulation for Critical Actions

```gdscript
# For lower latency (but more input checks):
Input.use_accumulated_input = false

# For default behavior (one check per frame):
Input.use_accumulated_input = true  # default
```

**Trade-off**: Disabling accumulation can reduce latency but increases input processing overhead.

#### 3. Respond Immediately in Same Frame

```gdscript
# GOOD: Immediate response
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        # Action happens same frame as input
        current_state = State.EXTENDING
        velocity = direction * speed

# BAD: Deferred response
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        # Action deferred to next frame
        call_deferred("_start_attack")
```

#### 4. Keep Input Processing Light

```gdscript
# GOOD: Light processing in input handler
func _physics_process(delta: float) -> void:
    handle_movement()  # Simple velocity calculation
    handle_attack()    # State machine update

# BAD: Heavy processing in input handler
func _physics_process(delta: float) -> void:
    recalculate_all_ai()  # Don't do heavy work here
    rebuild_spatial_hash()  # This blocks input response
```

### Latency Breakdown

At 60fps, the frame budget is 16.67ms:

```
Input Event → Input Processing → Game Logic → Render → Display
   0ms           ~1ms              ~5ms        ~10ms    ~16ms
```

**Where latency occurs**:
1. **Input polling**: ~0.5ms (hardware + driver)
2. **Godot input system**: ~0.5ms
3. **_physics_process call**: ~0ms (just function call)
4. **Game logic**: 1-5ms (depends on complexity)
5. **Rendering**: 5-10ms (GPU work)
6. **Display sync**: 0-16ms (V-Sync)

**We control**: Steps 3-4 (game logic)
**Hardware controls**: Steps 1-2, 5-6

### V-Sync Considerations

| V-Sync Setting | Latency Impact | Notes |
|----------------|----------------|-------|
| OFF | Lowest | Screen tearing, but responsive |
| ON | +16ms worst case | Smooth, but adds latency |
| Adaptive | Variable | Best of both |
| Triple Buffer | +16ms | Smooth, extra buffer |

**Recommendation**: Let player choose V-Sync in settings. Document impact.

### Manual Validation

#### Hardware Setup
For precise measurement, use:
- High-speed camera (240fps+)
- Light sensor on screen
- LED on input device trigger

#### Software Approximation
Use InputLatencyMonitor during gameplay:
```gdscript
# Enable tracking
latency.warn_on_exceed = true

# Play normally for 5 minutes
# Check for warnings in console

# Generate report
latency.print_report()
```

### Validation Checklist

```markdown
## Input Latency Validation

### Environment
- [ ] V-Sync OFF for testing
- [ ] 60fps stable (check PerformanceMonitor)
- [ ] No background processes

### Tests
- [ ] Movement: avg < 16ms
- [ ] Attack: avg < 16ms
- [ ] All actions: max < 32ms (2 frames acceptable spike)

### Results
- Movement avg: ___ ms
- Attack avg: ___ ms
- Max latency seen: ___ ms
- Unacceptable spikes: ___
```

### Setup (Autoload - Optional)

For global access, add to `project.godot`:
```
[autoload]
InputLatencyMonitor="*res://shared/scripts/input_latency_monitor.gd"
```

---

## COMBAT-014: Object Pooling 500+ Enemies

**Files**:
- `shared/scripts/object_pool.gd` - Generic ObjectPool class
- `combat/scripts/enemy_spawner.gd` - Integration with pooling
- `combat/scripts/enemy_base.gd` - Pooling support methods

### Overview

Object pooling eliminates runtime allocations during gameplay by reusing enemy instances. When an enemy dies, it's returned to the pool instead of being freed; when a new enemy is needed, one is acquired from the pool instead of being instantiated.

### PRD Requirements

| Metric | Target | Method |
|--------|--------|--------|
| Enemies on screen | 500+ | Object pooling |
| Frame drops | 0 | Zero allocations in hot path |
| Memory usage | Stable | Pre-warmed pool |

### EnemySpawner Pooling Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `pooling_enabled` | bool | true | Enable/disable pooling system |
| `pool_prewarm_count` | int | 50 | Enemies to pre-create per type at startup |
| `pool_max_size` | int | 500 | Maximum pool size per enemy type |

### ObjectPool Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `max_pool_size` | int | 500 | Maximum objects in pool (0 = unlimited) |
| `auto_grow` | bool | true | Create new objects when pool exhausted |
| `pool_container` | Node | self | Parent node for pooled objects |

### Understanding the Settings

#### `pooling_enabled`
Master toggle for the pooling system.
- **true** (default): Enemies acquired from pool, released on death
- **false**: Traditional instantiate/queue_free behavior

**Why Change It**: Disable for debugging, or if pooling causes unexpected behavior. Enable (default) for production performance.

#### `pool_prewarm_count`
How many enemies to create at game start.
- **0**: No pre-warming - first enemies cause allocation spike
- **25**: Light pre-warm - fewer startup cost, some allocations later
- **50** (default): Good balance - handles early waves without allocation
- **100+**: Full pre-warm - higher startup cost, no allocations during play

**Why Change It**: Increase if you see frame drops early in gameplay. Decrease if startup time is too long.

#### `pool_max_size`
Maximum enemies per scene type that can be pooled.
- **100**: Light pooling - saves memory, may allocate during intense combat
- **500** (default): PRD requirement - handles maximum enemy count
- **1000+**: Heavy pooling - uses more memory, handles extreme scenarios

**Why Change It**: Increase for higher enemy counts. Decrease to save memory if you never exceed 100 enemies.

### How Pooling Works

```
Game Start:
1. EnemySpawner._init_enemy_pool() creates ObjectPool
2. ObjectPool.prewarm(basic_enemy_scene, 50) pre-creates enemies
3. Pre-warmed enemies are hidden and disabled

During Gameplay (Spawn):
1. _create_enemy() calls enemy_pool.acquire(scene)
2. Pool returns existing hidden enemy (or creates new if empty)
3. Pool calls on_acquire callback → enemy.reset()
4. Enemy is visible, processing enabled, HP restored

During Gameplay (Death):
1. enemy.die() emits died signal, doesn't queue_free (if pooled)
2. Spawner._on_enemy_died() calls enemy_pool.release(enemy)
3. Pool calls on_release callback → enemy.deactivate()
4. Enemy is hidden, processing disabled, stays in scene tree
```

### Enemy Lifecycle Callbacks

The pool uses callbacks for state management:

```gdscript
# Called when enemy is acquired from pool
func reset() -> void:
    current_hp = max_hp
    is_active = true
    visible = true
    velocity = Vector2.ZERO
    set_physics_process(true)

# Called when enemy is released to pool
func deactivate() -> void:
    is_active = false
    visible = false
    velocity = Vector2.ZERO
    set_physics_process(false)
```

### Usage from Code

```gdscript
# Creating a custom pool
var pool := ObjectPool.new()
pool.max_pool_size = 100
pool.auto_grow = true
add_child(pool)

# Set up callbacks
pool.on_acquire = func(obj): obj.reset()
pool.on_release = func(obj): obj.hide()

# Pre-warm with objects
pool.prewarm(my_scene, 20)

# Acquire an object
var obj := pool.acquire(my_scene)
obj.global_position = spawn_pos

# Release back to pool
pool.release(obj)

# Get statistics
var stats := pool.get_statistics()
print("Active: %d, Available: %d, Reused: %d" % [
    stats.active_count, stats.available_count, stats.reuse_count
])
```

### Statistics Available

```gdscript
var stats := pool.get_statistics()
# Returns:
# {
#   total_created: 75,      # Objects ever created
#   available_count: 50,    # Objects waiting in pool
#   active_count: 25,       # Objects currently in use
#   reuse_count: 200,       # Times objects were reused
#   scene_types: 2          # Number of different scenes pooled
# }
```

### Debugging Pool Behavior

Enable pool statistics during gameplay:

```gdscript
# In EnemySpawner or debug script
func _physics_process(delta: float) -> void:
    if Engine.get_physics_frames() % 60 == 0:  # Every second
        var stats := get_pool_stats()
        print("Pool: %d active, %d available, %d reused" % [
            stats.active_count, stats.available_count, stats.reuse_count
        ])
```

**Healthy stats**:
- `reuse_count` should increase during gameplay
- `total_created` should stabilize after pre-warm
- `active_count` + `available_count` ≤ `max_pool_size`

**Warning signs**:
- `total_created` keeps increasing → pool exhausted, increase prewarm
- `reuse_count` is 0 → pooling not working, check `use_pooling` flag

### Performance Impact

| Metric | Without Pooling | With Pooling |
|--------|-----------------|--------------|
| Allocations/sec | ~10 per enemy spawn | 0 |
| Frame spikes | On spawn/death | None |
| Memory churn | High (GC pressure) | Low (stable) |
| Startup cost | None | Pre-warm time |

### Edge Cases Handled

1. **Pool Exhausted**: Creates new object if `auto_grow = true`
2. **Double Release**: Ignored (checks if already in available pool)
3. **Invalid Object**: Skipped if `is_instance_valid()` fails
4. **Scene Not Found**: Returns null, no crash
5. **Max Pool Reached**: Oldest objects freed, new ones added

### Disabling Pooling

For debugging or testing without pooling:

```gdscript
# In EnemySpawner
pooling_enabled = false

# Or in EnemyBase (already killed enemies)
use_pooling = false
```

### Integration with Other Systems

| System | Integration | Notes |
|--------|-------------|-------|
| Spatial Hash | Enemies removed on death, added on spawn | Via spawner callbacks |
| Particles | Spawn at death position before deactivate | Works normally |
| Audio | Play at death before deactivate | Works normally |
| Hit-Stop | Triggers before pool release | Works normally |
| Screen Shake | Triggers before pool release | Works normally |

---

## Input Actions

**File**: `project.godot`

| Action | Default Binding | Description |
|--------|-----------------|-------------|
| `move_up` | W | Move up |
| `move_down` | S | Move down |
| `move_left` | A | Move left |
| `move_right` | D | Move right |
| `attack` | Left Mouse Button | Tongue attack |
| `quit` | Escape | Exit game |

---

## Collision Layers

| Layer | Name | Used By |
|-------|------|---------|
| 1 | Player | Player body |
| 2 | Environment | Walls, obstacles |
| 3 | Enemies | Enemy bodies |
| 4 | PlayerAttack | Tongue hit area |

**Mask Configuration**:
- Player: Layer 1, Mask 2 (collides with environment)
- Tongue HitArea: Layer 4, Mask 3 (detects enemies via `get_overlapping_bodies()`)
- Enemies: Layer 3, Mask 1+2+4 (collides with player, environment, and player attacks)

**Important**: HitArea uses `monitorable = false` since it only monitors enemies, enemies don't need to detect it.

---

## Performance Targets

| Metric | Target | Validation |
|--------|--------|------------|
| FPS | 60 minimum | GTX 1060 @ 1080p |
| Input Lag | <16ms | 1 frame at 60fps |
| Enemies on screen | 500+ | Object pooling |
| Bullets on screen | 500+ | BulletUpHell plugin |

---

## Future Mutations (Reference)

These mutations will modify the settings above:

| Mutation | Effect | Setting Modified |
|----------|--------|------------------|
| Longer Tongue | +50% range | `max_range: 216` |
| Faster Tongue | +50% attack speed | `attack_cooldown: 0.15` |
| Multi-Tongue | Attack in 3 directions | New logic needed |
| Sticky Tongue | Enemies stick briefly | New mechanic |

---

## Changelog

| Date | Story | Changes |
|------|-------|---------|
| 2025-12-13 | COMBAT-001 | Added `move_speed` |
| 2025-12-13 | COMBAT-002 | Added aim system notes |
| 2025-12-13 | COMBAT-003 | Added tongue attack settings |
| 2025-12-13 | COMBAT-004 | Added elastic physics settings |
| 2025-12-13 | COMBAT-005 | Added enemy spawner settings |
| 2025-12-13 | COMBAT-006 | Added enemy AI behavior settings |
| 2025-12-13 | COMBAT-007 | Added spatial hash documentation |
| 2025-12-13 | COMBAT-008 | Added screen shake documentation |
| 2025-12-13 | COMBAT-009 | Added particle system documentation |
| 2025-12-13 | COMBAT-010 | Added hit-stop documentation |
| 2025-12-13 | COMBAT-011 | Added audio manager documentation |
| 2025-12-13 | COMBAT-012 | Added performance monitoring documentation |
| 2025-12-13 | COMBAT-013 | Added input latency documentation |
| 2025-12-13 | COMBAT-014 | Added object pooling documentation |
| 2025-12-13 | BULLET-003 | Added basic bullet patterns documentation |
| 2025-12-13 | BULLET-006 | Added bullet pooling optimization documentation |
| 2025-12-13 | EPIC-003 | Noted blocked stories for manual completion |

---