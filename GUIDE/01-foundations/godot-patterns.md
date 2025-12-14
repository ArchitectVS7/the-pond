# Godot Patterns

This chapter covers the patterns used throughout The Pond. When adding features, follow these patterns for consistency.

---

## Scene Structure

### Composition Over Inheritance

Prefer composing nodes over deep inheritance trees:

```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── TongueAttack (Area2D)
│   └── TongueCollision
├── HitBox (Area2D)
└── AudioStreamPlayer2D
```

Each child handles one responsibility.

### Script Attachment

Scripts attach to the root node of their scene:

```gdscript
# Player.tscn root has player_controller.gd attached
extends CharacterBody2D
class_name PlayerController
```

---

## Class Naming

### Convention

```gdscript
class_name PlayerController     # PascalCase
extends CharacterBody2D

var move_speed: float = 200.0   # snake_case for variables
const MAX_HEALTH := 100        # SCREAMING_SNAKE for constants

func handle_movement() -> void: # snake_case for functions
    pass
```

### File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Scenes | PascalCase.tscn | `Player.tscn` |
| Scripts | snake_case.gd | `player_controller.gd` |
| Resources | snake_case.tres | `enemy_data.tres` |

---

## Export Variables

Use `@export` for tunable parameters:

```gdscript
## Movement speed in pixels per second
@export var move_speed: float = 200.0

## Damage dealt per hit
@export_range(1, 100) var damage: int = 10

## Enemy types this spawner can create
@export var enemy_types: Array[PackedScene] = []
```

### Documentation

Every export should have a comment explaining what it does:

```gdscript
## How long the string takes to settle after being disturbed
## Lower values = snappier, higher values = floatier
@export var settle_time: float = 0.3
```

---

## Signals

### Declaring Signals

```gdscript
## Emitted when player takes damage
signal damage_taken(amount: int, source: Node)

## Emitted when health reaches zero
signal died()
```

### Connecting Signals

Prefer code connections over editor connections for important logic:

```gdscript
func _ready() -> void:
    health_component.damage_taken.connect(_on_damage_taken)
    health_component.died.connect(_on_died)
```

### Emitting Signals

```gdscript
func take_damage(amount: int, source: Node) -> void:
    current_health -= amount
    damage_taken.emit(amount, source)

    if current_health <= 0:
        died.emit()
```

---

## State Machines

For objects with distinct behaviors:

```gdscript
enum State { IDLE, CHASING, ATTACKING, DYING }

var current_state: State = State.IDLE

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            _process_idle(delta)
        State.CHASING:
            _process_chasing(delta)
        State.ATTACKING:
            _process_attacking(delta)
        State.DYING:
            _process_dying(delta)

func change_state(new_state: State) -> void:
    var old_state = current_state
    current_state = new_state
    _on_state_changed(old_state, new_state)
```

---

## Object Pooling

For frequently created/destroyed objects:

```gdscript
class_name ObjectPool
extends Node

var pool: Array[Node] = []
var scene: PackedScene

func _init(p_scene: PackedScene, initial_size: int = 10) -> void:
    scene = p_scene
    for i in range(initial_size):
        var instance = scene.instantiate()
        instance.set_process(false)
        pool.append(instance)

func get_instance() -> Node:
    if pool.is_empty():
        return scene.instantiate()
    var instance = pool.pop_back()
    instance.set_process(true)
    return instance

func return_instance(instance: Node) -> void:
    instance.set_process(false)
    pool.append(instance)
```

Usage:

```gdscript
var enemy_pool: ObjectPool

func _ready() -> void:
    enemy_pool = ObjectPool.new(enemy_scene, 50)

func spawn_enemy() -> void:
    var enemy = enemy_pool.get_instance()
    add_child(enemy)
    enemy.initialize(spawn_position)
```

---

## Resource Classes

For data that needs to be shared or saved:

```gdscript
# mutation_data.gd
class_name MutationData
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var icon: Texture2D
@export var effects: Dictionary
@export var pollution_value: int
```

Create instances in the editor or code:

```gdscript
var mutation = MutationData.new()
mutation.id = "toxic_skin"
mutation.name = "Toxic Skin"
```

---

## Autoloads (Singletons)

For globally accessible systems:

```gdscript
# In project.godot autoload section
[autoload]
GameState="*res://core/autoloads/GameState.gd"
SaveManager="*res://core/scripts/save_manager.gd"
```

Access anywhere:

```gdscript
func _ready() -> void:
    var player_level = GameState.player_level
    SaveManager.save_game()
```

### When to Use Autoloads

| Use Autoload | Don't Use Autoload |
|--------------|-------------------|
| Save system | Scene-specific logic |
| Settings | UI controllers |
| Steam integration | Individual entities |
| Global state | Temporary data |

---

## Component Pattern

For reusable behaviors:

```gdscript
# health_component.gd
class_name HealthComponent
extends Node

signal damage_taken(amount: int)
signal healed(amount: int)
signal died()

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    damage_taken.emit(amount)
    if current_health == 0:
        died.emit()

func heal(amount: int) -> void:
    current_health = min(max_health, current_health + amount)
    healed.emit(amount)
```

Attach to any entity that needs health:

```
Enemy (CharacterBody2D)
├── HealthComponent
├── Sprite2D
└── ...
```

---

## Error Handling

### Guard Clauses

Exit early for invalid states:

```gdscript
func apply_mutation(mutation_id: String) -> bool:
    if not mutations.has(mutation_id):
        push_error("Unknown mutation: %s" % mutation_id)
        return false

    if active_mutations.size() >= MAX_MUTATIONS:
        push_warning("Cannot apply mutation: max reached")
        return false

    # Actual logic here
    active_mutations.append(mutation_id)
    return true
```

### Null Checks

Godot uses `null` for missing references:

```gdscript
func _on_enemy_died(enemy: Enemy) -> void:
    if enemy == null:
        return

    enemy_pool.return_instance(enemy)
```

---

## Physics Patterns

### CharacterBody2D Movement

```gdscript
func _physics_process(delta: float) -> void:
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_dir * move_speed
    move_and_slide()
```

### Area2D Detection

```gdscript
func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body is Enemy:
        enemies_in_range.append(body)
```

---

## Code Organization

### Section Headers

Use comments to organize large files:

```gdscript
# =============================================================================
# SIGNALS
# =============================================================================

signal something_happened()

# =============================================================================
# EXPORTS
# =============================================================================

@export var some_value: float = 1.0

# =============================================================================
# STATE
# =============================================================================

var current_state: State = State.IDLE

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass
```

---

## Summary

| Pattern | When to Use |
|---------|-------------|
| Composition | Building complex objects from simple parts |
| State Machine | Objects with distinct behavior modes |
| Object Pool | Frequently spawned/despawned objects |
| Resource Class | Shared or saved data |
| Autoload | Globally accessible systems |
| Component | Reusable behaviors |
| Guard Clause | Early exit for invalid states |

Follow these patterns for consistency. When in doubt, look at existing code in the same system.

---

[← Back to Project Anatomy](project-anatomy.md) | [Next: Testing with GUT →](testing-with-gut.md)
