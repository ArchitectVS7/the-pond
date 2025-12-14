# Performance Tuning

The PRD requires 500 bullets at 60fps. BulletUpHell handles most of this automatically, but you need to configure it correctly. This chapter covers pooling, optimization, and validation.

---

## Built-in Pooling (BULLET-006)

**Key insight**: BulletUpHell already includes sophisticated object pooling. You don't need to build custom pooling - you need to configure the existing system.

### How BulletUpHell Pools

The plugin uses RID-based pooling via PhysicsServer2D:

```gdscript
# Internal structure (from BuHSpawner.gd)
var poolBullets: Dictionary = {}      # Active bullets
var inactive_pool: Dictionary = {}    # Inactive bullets by type
```

When a bullet "dies":
1. It's moved to `inactive_pool[bullet_type]`
2. Physics shape is disabled (not destroyed)
3. Rendering is disabled

When a bullet spawns:
1. Check `inactive_pool[bullet_type]` for available bullet
2. If found, reactivate and reposition
3. If empty, create new (with warning)

### Pre-Warming Pools

Pre-create bullets at game start to avoid mid-game allocations:

```gdscript
func _ready() -> void:
    Spawning.create_pool("basic_bullet", "0", 200)
    Spawning.create_pool("fast_bullet", "0", 150)
    Spawning.create_pool("boss_bullet", "0", 500)
    print("Pre-warmed bullet pools")
```

**API**:
```gdscript
Spawning.create_pool(bullet_id: String, shared_area: String, amount: int)
```

### Recommended Pool Sizes

| Use Case | Pool Size | Rationale |
|----------|-----------|-----------|
| Normal gameplay | 200 | ~4 seconds at 50/sec spawn |
| Boss fight | 500 | Dense patterns |
| Stress test | 600+ | 500 bullets + headroom |

**Formula**: `pool_size = max_bullets_expected × 1.2` (20% headroom)

---

## Performance Characteristics

### With vs Without Pooling

| Metric | Without Pooling | With Pooling |
|--------|-----------------|--------------|
| Spawn time | ~0.5ms | ~0.01ms |
| Despawn time | ~0.3ms | ~0.005ms |
| Memory growth | Linear | Constant |
| GC pressure | High | None |

### Frame Budget

At 60fps, you have 16.67ms per frame:

```
Total: 16.67ms
├── Physics: ~3ms
├── Bullets: ~2ms (with pooling)
├── Enemies: ~3ms (with spatial hash)
├── Rendering: ~6ms
└── Headroom: ~2.67ms
```

500 bullets with proper pooling uses ~2ms. Without pooling, it could spike to 10ms+ on spawn/despawn.

---

## Tunable Parameters

### BulletPoolManager (Optional Wrapper)

**File**: `combat/scripts/bullet_pool_manager.gd`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enable_prewarm` | bool | true | Pre-warm on _ready |
| `basic_bullet_pool_size` | int | 200 | Basic bullet pool |
| `fast_bullet_pool_size` | int | 150 | Fast bullet pool |
| `boss_bullet_pool_size` | int | 500 | Boss pattern pool |
| `enable_monitoring` | bool | true | Pool health checks |
| `monitor_interval` | float | 1.0 | Check frequency |
| `warn_on_auto_growth` | bool | true | Warn if pool grows |

### Native BulletUpHell Settings

**File**: `addons/BulletUpHell/BuHSpawner.gd`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cull_bullets` | bool | true | Remove off-screen |
| `cull_margin` | float | 50.0 | Distance before cull |
| `cull_minimum_speed_required` | float | 200.0 | Don't cull slow bullets |

---

## Monitoring Pool Health

### Using BulletPoolManager

```gdscript
var pool_mgr := $BulletPoolManager

# Get health stats
var health := pool_mgr.get_pool_health("basic_bullet")
print("Active: %d, Capacity: %d, Utilization: %.1f%%" % [
    health.active,
    health.capacity,
    health.utilization * 100
])

# Print all pools
pool_mgr.print_pool_status()

# Connect to warnings
pool_mgr.pool_auto_grew.connect(_on_pool_grew)
pool_mgr.pool_depleted.connect(_on_pool_depleted)
```

### Direct BulletUpHell Access

```gdscript
# Active bullets
print("Active: ", Spawning.poolBullets.size())

# Inactive in pool
print("Pooled: ", Spawning.inactive_pool["basic_bullet"].size())
```

### Healthy Stats

- Pool utilization: < 80%
- Auto-growth warnings: 0
- Frame time stable

---

## Validation: 500 Bullets at 60fps

### Test Setup

**File**: `test/benchmarks/test_bullet_pooling_performance.gd`

```gdscript
func test_500_bullets_at_60fps() -> void:
    # Pre-warm
    Spawning.create_pool("test_bullet", "0", 600)

    # Spawn 500 bullets
    for i in range(500):
        Spawning.spawn(self, "radial_1way", "0")

    # Measure FPS over 5 seconds
    await get_tree().create_timer(5.0).timeout

    var avg_fps := Performance.get_monitor(Performance.TIME_FPS)
    assert_true(avg_fps >= 60, "FPS should be >= 60, got %f" % avg_fps)
```

### Running the Test

```bash
godot --path . --headless --script addons/gut/gut_cmdln.gd \
    -gtest=test_bullet_pooling_performance
```

### Manual Validation

1. Open BulletPatternTest scene
2. Enable performance monitor overlay
3. Spawn spiral pattern (continuous bullets)
4. Wait until 500+ bullets on screen
5. Check FPS counter stays at 60+

---

## Optimization Techniques

### 1. Pre-Warm Generously

```gdscript
# Better to over-allocate
Spawning.create_pool("bullet", "0", 600)  # 200% headroom
```

### 2. Use Shared Areas Wisely

Group bullets by collision behavior:
```gdscript
# Enemy bullets: SharedArea "0"
Spawning.create_pool("enemy_bullet", "0", 400)

# Boss bullets: SharedArea "1"
Spawning.create_pool("boss_bullet", "1", 200)
```

### 3. Clear Between Levels

```gdscript
func change_level() -> void:
    Spawning.clear_all_bullets()
    await get_tree().process_frame
    # Pool is ready for next level
```

### 4. Limit Pattern Complexity

Dense patterns spawn more bullets:
```gdscript
# Heavy (spawns 24 bullets/wave)
pattern.nbr = 24

# Light (spawns 8 bullets/wave)
pattern.nbr = 8
```

### 5. Use Bullet Lifetimes

Bullets auto-despawn after `death_after_time`:
```gdscript
bullet.death_after_time = 5.0  # Returns to pool after 5s
```

Shorter lifetimes = faster pool recycling.

---

## Debugging Performance

### Common Warnings

| Warning | Cause | Fix |
|---------|-------|-----|
| "No bullet pool for ID X" | Pool not created | Add `create_pool()` |
| "Bullet pool empty" | Pool too small | Increase pool size |
| Pool auto-grew | Exhausted mid-game | Increase pre-warm |

### Profiling

Use Godot's built-in profiler:
1. Run with `--debug`
2. Open Debugger → Profiler
3. Look for:
   - `BuHSpawner._physics_process`
   - `PhysicsServer2D` calls

### Logging Pool Stats

```gdscript
func _physics_process(delta: float) -> void:
    if Engine.get_physics_frames() % 60 == 0:
        print("Active bullets: ", Spawning.poolBullets.size())
        print("Pool available: ", Spawning.inactive_pool.get("basic_bullet", []).size())
```

---

## Performance Checklist

```markdown
## Bullet Performance Validation

### Pre-Warm
- [ ] All bullet types have pools created
- [ ] Pool sizes >= max expected bullets × 1.2
- [ ] No "pool empty" warnings during gameplay

### Runtime
- [ ] 500 bullets: FPS >= 60
- [ ] No frame spikes on spawn
- [ ] No frame spikes on despawn
- [ ] Memory usage stable

### Results
- Peak bullets: ___
- Min FPS: ___
- Avg FPS: ___
- Pool warnings: ___
```

---

## Summary

| Optimization | Method |
|--------------|--------|
| Object pooling | Built into BulletUpHell |
| Pre-warming | `Spawning.create_pool()` |
| Off-screen culling | Automatic (configurable) |
| Batch rendering | Automatic |
| RID-based physics | Built into plugin |

BulletUpHell is already optimized. Your job is to:
1. Pre-warm pools with enough capacity
2. Monitor for warnings
3. Validate 500 bullets at 60fps

---

[← Back to Frog Patterns](frog-patterns.md) | [Back to Overview](overview.md)
