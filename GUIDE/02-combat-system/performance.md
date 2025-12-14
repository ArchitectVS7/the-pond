# Performance

The PRD requires 60fps on a GTX 1060 with 500 enemies on screen. This chapter covers how we hit that target: spatial hashing, object pooling, and validation tools.

---

## Performance Targets

| Metric | Target | Context |
|--------|--------|---------|
| Minimum FPS | 60 | GTX 1060 @ 1080p |
| Average FPS | 90+ | Streaming headroom |
| Enemies on screen | 500+ | With optimization |
| Bullets on screen | 500+ | BulletUpHell handles this |
| Input lag | <16ms | 1 frame at 60fps |

These aren't aspirational - they're requirements. Every optimization in this chapter exists to meet them.

---

## Spatial Hashing (COMBAT-007)

**File**: `combat/scripts/spatial_hash.gd`

### The Problem

Enemy separation requires checking nearby enemies. Without optimization:

```
500 enemies × check 500 enemies = 250,000 comparisons per frame
At 60fps = 15,000,000 comparisons per second
```

That's too slow. Most comparisons are wasted - enemies 1000 pixels apart don't need to separate.

### The Solution

Divide the world into a grid. Only check enemies in the same cell and adjacent cells.

```
Grid (64px cells):
+-----+-----+-----+
| 2,1 | 3,1 | 4,1 |
+-----+-----+-----+
| 2,2 |[3,2]| 4,2 |  ← Enemy at (200, 150) is in cell [3,2]
+-----+-----+-----+
| 2,3 | 3,3 | 4,3 |
+-----+-----+-----+

Query for nearby: Check 9 cells, not 500 enemies
```

### Performance Impact

| Metric | Without | With |
|--------|---------|------|
| Complexity | O(n²) | O(n×k) |
| 500 enemies | 250,000 checks | ~2,500 checks |
| Speedup | - | **100x** |

### API Reference

```gdscript
# Create spatial hash
var spatial_hash := SpatialHash.new(64.0)  # 64px cells

# Insert entity (must have global_position)
spatial_hash.insert(enemy)

# Query nearby (3×3 cell grid)
var nearby := spatial_hash.query_nearby(position)

# Query exact radius
var in_radius := spatial_hash.query_radius(position, 50.0)

# Update after movement
spatial_hash.update(enemy)

# Remove entity
spatial_hash.remove(enemy)

# Get stats
var stats := spatial_hash.get_stats()
```

### Tuning Cell Size

The `cell_size` should be slightly larger than your largest query radius.

| Cell Size | Effect | Use Case |
|-----------|--------|----------|
| 32px | More cells, fewer entities per cell | Dense swarm games |
| 64px | Balanced | Default |
| 128px | Fewer cells, more entities per cell | Spread-out enemies |

**Formula**: `cell_size ≈ separation_radius × 1.5 to 2.0`

For default `separation_radius = 30px`, a `cell_size = 64px` works well.

### Debugging Spatial Hash

```gdscript
func _physics_process(delta: float) -> void:
    if Engine.get_physics_frames() % 60 == 0:  # Every second
        var stats := spatial_hash.get_stats()
        print("Cells: %d, Entities: %d, Avg/cell: %.1f" % [
            stats.cell_count,
            stats.total_entities,
            stats.avg_per_cell
        ])
```

**Healthy stats**:
- `avg_per_cell`: 5-20
- `max_per_cell`: < 50
- If `avg_per_cell > 30`: Increase `cell_size`

---

## Object Pooling (COMBAT-014)

**File**: `shared/scripts/object_pool.gd`

### The Problem

Creating and destroying objects causes:
- Memory allocation (slow)
- Garbage collection pressure (stutters)
- Scene instantiation overhead

With 500 enemies dying and respawning, that's thousands of allocations per minute.

### The Solution

Pre-create objects. When "spawning", take from pool. When "dying", return to pool. No allocations during gameplay.

### Pool Lifecycle

```
Startup:
1. pool.prewarm(enemy_scene, 50)  # Create 50 enemies
2. All enemies hidden and disabled
3. Stored in available_pool[]

Spawn:
1. enemy = pool.acquire(enemy_scene)
2. pool calls on_acquire callback
3. Enemy visible, enabled, HP reset

Death:
1. pool.release(enemy)
2. pool calls on_release callback
3. Enemy hidden, disabled, stays in tree
```

### API Reference

```gdscript
# Create pool
var pool := ObjectPool.new()
pool.max_pool_size = 500
pool.auto_grow = true
add_child(pool)

# Set callbacks
pool.on_acquire = func(obj): obj.reset()
pool.on_release = func(obj): obj.deactivate()

# Pre-warm
pool.prewarm(enemy_scene, 50)

# Acquire object
var enemy := pool.acquire(enemy_scene)

# Release back
pool.release(enemy)

# Stats
var stats := pool.get_statistics()
```

### Enemy Integration

```gdscript
# In enemy_base.gd
func reset() -> void:
    current_hp = max_hp
    is_active = true
    visible = true
    velocity = Vector2.ZERO
    set_physics_process(true)

func deactivate() -> void:
    is_active = false
    visible = false
    set_physics_process(false)
```

### Pool Parameters

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `pooling_enabled` | true | - | Toggle system |
| `pool_prewarm_count` | 50 | 0-100 | Initial allocation |
| `pool_max_size` | 500 | 100-1000 | Maximum objects |

### Performance Impact

| Metric | Without | With |
|--------|---------|------|
| Spawn time | ~0.5ms | ~0.01ms |
| Memory growth | Linear | Constant |
| GC pressure | High | None |
| Frame spikes | On spawn/death | None |

---

## Performance Monitoring (COMBAT-012)

**File**: `shared/scripts/performance_monitor.gd`

### Real-Time Stats

```gdscript
var perf := PerformanceMonitor.new()
add_child(perf)

perf.start_tracking()

# Later...
var stats := perf.get_statistics()
print("FPS: %.1f (min: %.1f, avg: %.1f)" % [
    stats.fps,
    stats.min_fps,
    stats.avg_fps
])
```

### Stats Available

| Stat | Description |
|------|-------------|
| `fps` | Current frame rate |
| `fps_smoothed` | Averaged over 30 frames |
| `frame_time_ms` | Current frame duration |
| `min_fps` | Minimum recorded |
| `max_fps` | Maximum recorded |
| `avg_fps` | Session average |
| `memory_mb` | Memory usage |
| `object_count` | Godot objects |
| `meeting_target` | Pass/fail for 60fps |

### Parameters

| Parameter | Default | Effect |
|-----------|---------|--------|
| `target_fps` | 60.0 | Target for validation |
| `warning_threshold_fps` | 55.0 | Warning level |
| `smoothing_frames` | 30 | FPS averaging window |

---

## Input Lag Validation (COMBAT-013)

**File**: `shared/scripts/input_latency_monitor.gd`

### Why 16ms Matters

At 60fps, each frame is 16.67ms. Input lag over 16ms means:
- Player presses button
- Game doesn't respond until next frame
- Feels sluggish and unresponsive

### Measuring Latency

```gdscript
var latency := InputLatencyMonitor.new()
add_child(latency)

# In _physics_process
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        latency.record_input("attack")
        _start_attack()

func _start_attack() -> void:
    latency.record_response("attack")
    # ... attack logic
```

### Best Practices

**Use _physics_process for input:**
```gdscript
# GOOD - consistent 60fps timing
func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        _attack()

# BAD - variable timing
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        _attack()
```

**Respond immediately:**
```gdscript
# GOOD - same frame response
if Input.is_action_just_pressed("attack"):
    state = State.ATTACKING

# BAD - deferred response
if Input.is_action_just_pressed("attack"):
    call_deferred("_start_attack")  # +1 frame delay
```

---

## Hardware Validation

### Test Environment

| Component | Spec |
|-----------|------|
| GPU | GTX 1060 6GB (or RX 580) |
| CPU | i5-6500 or Ryzen 3 1200 |
| RAM | 8 GB |
| Resolution | 1920×1080 |
| V-Sync | OFF (for accurate FPS) |

### Test Scenarios

**Scenario 1: Enemy Stress**
1. Spawn 500 enemies
2. Enable PerformanceMonitor
3. Play 60 seconds
4. Check `min_fps >= 60`

**Scenario 2: Combat Intensity**
1. Start with 100 enemies
2. Attack continuously
3. Verify no drops during:
   - Screen shake
   - Particle effects
   - Hit-stop
   - Audio

**Scenario 3: Streaming**
1. Launch OBS (Game Capture)
2. Record 1080p60
3. Play at max intensity
4. Verify 60fps maintained

### Validation Checklist

```markdown
## Hardware Validation

### Environment
- [ ] GTX 1060 or equivalent
- [ ] 1080p resolution
- [ ] V-Sync OFF

### Tests
- [ ] 500 enemies: min_fps >= 60
- [ ] Combat stress: no drops below 60
- [ ] 10-minute session: avg_fps >= 90

### Results
- Min FPS: ___
- Avg FPS: ___
- Issues: ___
```

---

## Optimization Techniques Summary

| System | Technique | Story | Impact |
|--------|-----------|-------|--------|
| Separation | Spatial hash | COMBAT-007 | 100× speedup |
| Enemies | Object pooling | COMBAT-014 | Zero allocations |
| Particles | Pool + 200 cap | COMBAT-009 | Bounded cost |
| Audio | Player pool | COMBAT-011 | Zero allocations |
| Hit-stop | time_scale | COMBAT-010 | Zero overhead |
| Shake | Trauma decay | COMBAT-008 | Simple math |

---

## Debugging Performance

### If FPS Drops Below 60

1. **Check spatial hash**
   ```gdscript
   var stats := spatial_hash.get_stats()
   if stats.avg_per_cell > 30:
       print("Increase cell_size")
   ```

2. **Check particle count**
   ```gdscript
   var count := ParticleManager.get_active_count()
   if count >= 200:
       print("At particle limit")
   ```

3. **Check audio pool**
   ```gdscript
   var playing := AudioManager.get_playing_count()
   if playing >= 16:
       print("Audio pool saturated")
   ```

4. **Use Godot profiler**
   - Run with `--debug`
   - Open Debugger → Profiler
   - Find functions > 1ms per frame

### Common Bottlenecks

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Steady low FPS | Too many draw calls | Reduce unique sprites |
| Spikes on spawn | No pooling | Enable object pooling |
| Spikes on death | GC from queue_free | Use pooling |
| Gradual slowdown | Memory leak | Check for orphan nodes |

---

## Summary

| Optimization | Effect |
|--------------|--------|
| Spatial hash | O(n²) → O(n×k) for separation |
| Object pool | Zero allocations during gameplay |
| Pool pre-warm | No first-spawn stutter |
| Particle cap | Bounded GPU cost |
| Fixed timestep | Consistent input timing |

These optimizations work together. Spatial hashing enables 500 enemies. Object pooling prevents frame spikes. Performance monitoring validates it all works.

---

[← Back to Enemy System](enemy-system.md) | [Next: Game Feel →](game-feel.md)
