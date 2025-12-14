# Testing with GUT

GUT (Godot Unit Test) is The Pond's testing framework. Every system has tests. When you change code, run them.

---

## Quick Start

### Running Tests

```bash
# Run all tests
npm run test

# Or directly with Godot
godot --headless -s addons/gut/gut_cmdln.gd
```

### Running Specific Tests

```bash
# Run one test file
godot --headless -s addons/gut/gut_cmdln.gd -gtest=test/unit/test_player_controller.gd

# Run tests matching a pattern
godot --headless -s addons/gut/gut_cmdln.gd -ginclude_subdirs -gprefix=test_ -gsuffix=.gd
```

---

## Test Structure

### File Location

```
tests/
├── unit/
│   ├── test_player_controller.gd
│   ├── test_enemy_spawner.gd
│   ├── test_string_renderer.gd
│   └── test_save_manager.gd
└── integration/
    ├── test_combat_flow.gd
    └── test_board_flow.gd
```

### Test File Template

```gdscript
extends GutTest

# Subject under test
var player: PlayerController

func before_each() -> void:
    player = PlayerController.new()
    add_child(player)

func after_each() -> void:
    player.queue_free()

func test_initial_health() -> void:
    assert_eq(player.health, 100, "Player should start with 100 health")

func test_take_damage_reduces_health() -> void:
    player.take_damage(25)
    assert_eq(player.health, 75, "Health should be 75 after 25 damage")

func test_cannot_have_negative_health() -> void:
    player.take_damage(150)
    assert_eq(player.health, 0, "Health should not go below 0")
```

---

## GUT Assertions

### Equality

```gdscript
assert_eq(actual, expected, "message")     # Equal
assert_ne(actual, expected, "message")     # Not equal
assert_almost_eq(a, b, 0.01, "message")    # Float comparison
```

### Truthiness

```gdscript
assert_true(condition, "message")
assert_false(condition, "message")
assert_null(value, "message")
assert_not_null(value, "message")
```

### Ranges

```gdscript
assert_gt(actual, expected, "message")     # Greater than
assert_lt(actual, expected, "message")     # Less than
assert_gte(actual, expected, "message")    # Greater or equal
assert_lte(actual, expected, "message")    # Less or equal
assert_between(value, low, high, "message")
```

### Signals

```gdscript
func test_damage_emits_signal() -> void:
    watch_signals(player)
    player.take_damage(10)
    assert_signal_emitted(player, "damage_taken")
    assert_signal_emit_count(player, "damage_taken", 1)
```

### Called

```gdscript
func test_method_called() -> void:
    var mock = double(Enemy).new()
    mock.take_damage(10)
    assert_called(mock, "take_damage")
    assert_call_count(mock, "take_damage", 1)
```

---

## Test Patterns

### Setup and Teardown

```gdscript
# Run once before all tests in this file
func before_all() -> void:
    # Load resources, etc.
    pass

# Run before each test
func before_each() -> void:
    # Create fresh instances
    pass

# Run after each test
func after_each() -> void:
    # Clean up
    pass

# Run once after all tests
func after_all() -> void:
    # Final cleanup
    pass
```

### Testing Signals

```gdscript
func test_death_signal() -> void:
    watch_signals(player)

    player.health = 10
    player.take_damage(10)

    assert_signal_emitted(player, "died")
```

### Testing Scenes

```gdscript
func test_scene_loads() -> void:
    var scene = load("res://combat/scenes/Player.tscn")
    var instance = scene.instantiate()
    add_child(instance)

    assert_not_null(instance)
    assert_true(instance is PlayerController)

    instance.queue_free()
```

---

## Test Categories

### Unit Tests

Test individual functions in isolation:

```gdscript
# test_spatial_hash.gd
func test_insert_and_query() -> void:
    var hash = SpatialHash.new(32.0)
    var entity = Node2D.new()
    entity.position = Vector2(50, 50)

    hash.insert(entity)
    var nearby = hash.query(Vector2(55, 55), 10.0)

    assert_true(nearby.has(entity))
```

### Integration Tests

Test systems working together:

```gdscript
# test_combat_flow.gd
func test_killing_enemy_grants_xp() -> void:
    var player = create_player()
    var enemy = create_enemy()
    var initial_xp = player.xp

    # Simulate combat
    enemy.take_damage(enemy.max_health)
    await get_tree().process_frame

    assert_gt(player.xp, initial_xp, "XP should increase")
```

### Performance Tests

Validate performance requirements:

```gdscript
# test_performance.gd
func test_500_enemies_60fps() -> void:
    var spawner = EnemySpawner.new()
    add_child(spawner)

    # Spawn 500 enemies
    for i in range(500):
        spawner.spawn_enemy()

    # Measure frame time
    var start = Time.get_ticks_usec()
    for i in range(60):
        await get_tree().process_frame
    var elapsed = Time.get_ticks_usec() - start

    var avg_frame_time = elapsed / 60.0 / 1000.0  # ms
    assert_lt(avg_frame_time, 16.67, "Should maintain 60fps")
```

---

## Mocking

### Double (Mock)

```gdscript
func test_with_mock() -> void:
    var mock_enemy = double(Enemy).new()

    # Stub a method
    stub(mock_enemy, "get_health").to_return(50)

    # Use the mock
    var health = mock_enemy.get_health()

    assert_eq(health, 50)
    assert_called(mock_enemy, "get_health")
```

### Partial Double

```gdscript
func test_partial_mock() -> void:
    var partial = partial_double(Enemy).new()

    # Only stub specific methods
    stub(partial, "get_health").to_return(50)

    # Other methods work normally
    partial.take_damage(10)  # Real implementation
```

---

## Best Practices

### Test One Thing

Each test should verify one behavior:

```gdscript
# Good
func test_damage_reduces_health() -> void:
    player.take_damage(25)
    assert_eq(player.health, 75)

# Bad (testing multiple things)
func test_player_damage() -> void:
    player.take_damage(25)
    assert_eq(player.health, 75)
    assert_signal_emitted(player, "damage_taken")
    assert_true(player.is_invulnerable)
```

### Descriptive Names

```gdscript
# Good
func test_player_dies_when_health_reaches_zero() -> void:

# Bad
func test_death() -> void:
```

### Arrange-Act-Assert

```gdscript
func test_healing_cannot_exceed_max() -> void:
    # Arrange
    player.health = 50
    player.max_health = 100

    # Act
    player.heal(100)

    # Assert
    assert_eq(player.health, 100, "Health should cap at max")
```

---

## When to Write Tests

### Always Test

- Core game mechanics (damage, movement, spawning)
- Save/load operations
- Math-heavy code (physics, patterns)
- State transitions

### Consider Testing

- UI interactions (often easier to test manually)
- Visual effects (hard to assert)
- Audio (requires human verification)

### Skip Testing

- Godot built-in functionality
- Trivial getters/setters
- Prototype code (test when stabilized)

---

## Running in CI

Tests run automatically on commit via GitHub Actions:

```yaml
# .github/workflows/test.yml
- name: Run Tests
  run: godot --headless -s addons/gut/gut_cmdln.gd
```

All tests must pass before merging.

---

## Debugging Failed Tests

### Get More Output

```bash
godot --headless -s addons/gut/gut_cmdln.gd -glog=3
```

Log levels:
- 0: Errors only
- 1: + Warnings
- 2: + Info
- 3: + Debug (verbose)

### Run Single Test

```bash
godot --headless -s addons/gut/gut_cmdln.gd -gtest=test/unit/test_player.gd -ginner_class=test_damage_reduces_health
```

### Print in Tests

```gdscript
func test_something() -> void:
    gut.p("Debug info: %s" % some_value)
    # or
    print("Debug: ", some_value)
```

---

## Summary

| Command | Purpose |
|---------|---------|
| `npm run test` | Run all tests |
| `assert_eq(a, b)` | Check equality |
| `watch_signals(obj)` | Track signal emissions |
| `double(Class)` | Create mock object |
| `before_each()` | Setup per test |

Tests are documentation. When you're not sure how something should behave, read its tests.

---

[← Back to Godot Patterns](godot-patterns.md) | [Back to Index](../index.md)
