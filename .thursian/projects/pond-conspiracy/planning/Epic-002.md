# EPIC-002: BulletUpHell Integration - Development Plan

## Overview

**Epic**: EPIC-002 (BulletUpHell Integration)
**Release Phase**: MVP
**Priority**: P0 (CRITICAL - Combat dependency)
**Dependencies**: EPIC-001 (Combat System Foundation)
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-001, CI-3.3

**Description**: Fork and integrate BulletUpHell plugin for bullet patterns, validate performance.

---

## Automated Workflow Protocol

### Before Each Story
1. **READ THIS PLAN** for re-alignment before starting
2. Verify dependencies from previous stories are complete
3. Check DEVELOPERS_MANUAL.md for any tunable parameters from prior work

### Story Completion Criteria
- ✅ All tests pass (adversarial workflow complete)
- ✅ Tunable parameters documented in DEVELOPERS_MANUAL.md
- ✅ No human sign-off required - proceed immediately to next story

### Blocker Handling
- If a story cannot be completed due to blockers or human-required actions:
  - **SKIP** the blocked steps
  - **NOTE** in DEVELOPERS_MANUAL.md under "Blocked Steps" section
  - **PROCEED** to next story

---

## Stories

### BULLET-001: fork-bulletuphell-repo-day1
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] BulletUpHell repository forked to project
- [ ] Fork located in `addons/BulletUpHell/`
- [ ] Original license preserved
- [ ] README updated with fork notes

**Implementation Steps**:
1. Download/clone BulletUpHell from GitHub
2. Copy to `addons/BulletUpHell/`
3. Verify folder structure matches Godot addon requirements
4. Create `addons/BulletUpHell/FORK_NOTES.md` documenting changes

**Test Cases**:
- `test_bulletuphell_addon_exists` - Verify addon folder present
- `test_bulletuphell_plugin_cfg` - Verify plugin.cfg valid

**Tunable Parameters**: None expected

**Potential Blockers**:
- [ ] BulletUpHell repository unavailable → Document in DEVELOPERS_MANUAL.md

---

### BULLET-002: integrate-plugin-godot42
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Plugin enabled in Project Settings
- [ ] No errors on project load
- [ ] BulletUpHell nodes available in scene tree
- [ ] Compatible with Godot 4.2+ API

**Implementation Steps**:
1. Read plan for re-alignment
2. Enable plugin in `Project > Project Settings > Plugins`
3. Fix any Godot 4.2 compatibility issues (GDScript 2.0)
4. Verify BulletSpawner, BulletType nodes appear in Add Node menu
5. Create minimal test scene to validate

**Test Cases**:
- `test_plugin_enabled` - Plugin activates without errors
- `test_bullet_spawner_instantiates` - Can create BulletSpawner node
- `test_bullet_type_resource` - Can create BulletType resource

**Tunable Parameters**: Document any settings in plugin configuration

**Potential Blockers**:
- [ ] Major API changes requiring rewrite → Note scope in DEVELOPERS_MANUAL.md

---

### BULLET-003: test-basic-bullet-patterns
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Create 3 basic bullet patterns (radial, spiral, aimed)
- [ ] Patterns spawn bullets correctly
- [ ] Bullets move in expected directions
- [ ] Bullets despawn off-screen or after timeout

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `combat/resources/bullet_patterns/` folder
3. Define `radial_8way.tres` - 8 bullets in circle
4. Define `spiral_clockwise.tres` - Rotating spawn
5. Define `aimed_single.tres` - Single bullet toward target
6. Create test scene `combat/scenes/BulletPatternTest.tscn`

**Test Cases**:
- `test_radial_spawns_8_bullets` - Radial pattern creates 8 bullets
- `test_spiral_rotates` - Spiral pattern rotates over time
- `test_aimed_follows_target` - Aimed pattern tracks target

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `bullets_per_radial` | int | 8 | Bullets in radial burst |
| `spiral_rotation_speed` | float | 180.0 | Degrees per second |
| `bullet_speed` | float | 200.0 | Bullet movement speed |

---

### BULLET-004: performance-validation-500bullets
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] 500 bullets on screen at 60fps
- [ ] Profile shows no frame drops
- [ ] Memory usage stable (no leaks)
- [ ] Tested on GTX 1060 equivalent specs

**Implementation Steps**:
1. Read plan for re-alignment
2. Create stress test scene with continuous bullet spawning
3. Add frame time monitoring
4. Run for 60 seconds, capture min/max/avg FPS
5. Check memory via Godot profiler

**Test Cases**:
- `test_500_bullets_60fps` - Performance benchmark
- `test_bullet_memory_stable` - No memory growth over time

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `max_bullets` | int | 500 | Performance cap |
| `bullet_lifetime` | float | 5.0 | Seconds before auto-despawn |

**Potential Blockers**:
- [ ] Performance target not met → Document workarounds in DEVELOPERS_MANUAL.md

---

### BULLET-005: custom-pattern-frog-themed
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Create "fly swarm" pattern (small bullets, erratic movement)
- [ ] Create "lily pad spiral" pattern (slow, green, expands outward)
- [ ] Create "ripple wave" pattern (concentric circles)
- [ ] Visual distinction from generic patterns

**Implementation Steps**:
1. Read plan for re-alignment
2. Define `fly_swarm.tres` - Fast, random-offset small bullets
3. Define `lily_pad_spiral.tres` - Slow expansion, nature themed
4. Define `ripple_wave.tres` - Ring patterns at intervals
5. Assign placeholder sprites (can be simple circles with color)

**Test Cases**:
- `test_fly_swarm_random_offset` - Bullets have position variance
- `test_lily_pad_expands` - Pattern grows from center
- `test_ripple_creates_rings` - Multiple ring waves spawn

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `fly_random_offset` | float | 15.0 | Position randomness |
| `lily_expand_rate` | float | 50.0 | Expansion speed |
| `ripple_ring_count` | int | 3 | Concurrent rings |
| `ripple_ring_delay` | float | 0.5 | Seconds between rings |

---

### BULLET-006: bullet-pooling-optimization
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Object pool for bullets implemented
- [ ] Pool pre-warms on scene load
- [ ] Bullets recycle instead of instantiate/free
- [ ] Performance improved vs. naive instantiation

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `combat/scripts/bullet_pool.gd`
3. Implement `acquire()` and `release()` methods
4. Integrate with BulletUpHell spawner
5. Benchmark before/after pooling

**Test Cases**:
- `test_pool_acquire_returns_bullet` - Pool provides bullets
- `test_pool_release_recycles` - Released bullets return to pool
- `test_pool_prewarms` - Initial pool size respected

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `initial_pool_size` | int | 200 | Pre-warmed bullets |
| `max_pool_size` | int | 600 | Maximum bullets allowed |
| `pool_grow_amount` | int | 50 | Bullets added when pool empty |

---

### BULLET-007: collision-optimization
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Bullet collision uses Area2D efficiently
- [ ] Collision layers properly configured
- [ ] No redundant collision checks
- [ ] Performance validated with 500 bullets + 100 enemies

**Implementation Steps**:
1. Read plan for re-alignment
2. Configure bullet collision layer (new Layer 5: Bullets)
3. Bullets mask only Layer 1 (Player)
4. Use `set_deferred()` for collision shape enable/disable
5. Stress test with enemies + bullets

**Test Cases**:
- `test_bullet_collides_player` - Bullets hit player
- `test_bullet_ignores_enemies` - Enemy bullets don't hit enemies
- `test_collision_performance` - 500 bullets + 100 enemies at 60fps

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `collision_layer_bullet` | int | 5 | Bullet collision layer |
| `bullet_hitbox_size` | float | 4.0 | Collision shape radius |

---

## Collision Layer Update

After EPIC-002, collision layers should be:

| Layer | Name | Used By |
|-------|------|---------|
| 1 | Player | Player body |
| 2 | Environment | Walls, obstacles |
| 3 | Enemies | Enemy bodies |
| 4 | PlayerAttack | Tongue hit area |
| 5 | Bullets | Enemy bullets (new) |

---

## Review Checklist (Automated Adversarial)

After each story, verify:

```markdown
## Adversarial Review: [STORY-ID]

### Architecture
- [ ] Files in correct module (`addons/BulletUpHell/`, `combat/`)
- [ ] No circular dependencies
- [ ] Plugin modifications isolated in fork

### Code Quality
- [ ] Type hints on all functions
- [ ] No magic numbers (use constants/exports)
- [ ] Files < 500 lines

### Performance
- [ ] No allocations in _physics_process
- [ ] Object pooling active
- [ ] Profiler confirms 60fps

### Testing
- [ ] All tests pass
- [ ] Edge cases covered
- [ ] Performance benchmarks pass
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `addons/BulletUpHell/` | Forked plugin |
| `addons/BulletUpHell/FORK_NOTES.md` | Change documentation |
| `combat/scripts/bullet_pool.gd` | Object pooling |
| `combat/resources/bullet_patterns/*.tres` | Pattern definitions |
| `combat/scenes/BulletPatternTest.tscn` | Test scene |
| `test/unit/test_bullet_patterns.gd` | Pattern tests |
| `test/unit/test_bullet_pool.gd` | Pool tests |
| `test/unit/test_bullet_performance.gd` | Performance tests |

---

## Dependencies Graph

```
BULLET-001 (fork repo)
    ↓
BULLET-002 (integrate plugin)
    ↓
BULLET-003 (test patterns) ──→ BULLET-005 (frog patterns)
    ↓
BULLET-004 (performance) ──→ BULLET-006 (pooling)
                                   ↓
                            BULLET-007 (collision opt)
```

---

## Success Metrics

- 7 stories completed without human intervention
- All tests passing
- 500 bullets @ 60fps validated
- DEVELOPERS_MANUAL.md updated with all tunable parameters

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
