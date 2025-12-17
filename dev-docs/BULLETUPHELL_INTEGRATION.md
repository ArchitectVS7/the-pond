# BulletUpHell Plugin Integration Guide

## Overview

BulletUpHell v4.2.8 has been integrated into The Pond Conspiracy for advanced bullet-hell pattern generation.

## Plugin Status

- **Version**: 4.2.8
- **Godot Compatibility**: 4.2+
- **Location**: `res://addons/BulletUpHell/`
- **Enabled**: Yes (configured in project.godot)

## Configuration

### Project Settings

The plugin is enabled in `project.godot`:

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/BulletUpHell/plugin.cfg", "res://addons/gut/plugin.cfg")
```

### Autoloads

The plugin automatically registers the `Spawning` autoload singleton:
- **Node**: `Spawning` (accessible via `/root/Spawning`)
- **Type**: Node2D with BuHSpawner script
- **Scene**: `res://addons/BulletUpHell/Spawning.tscn`

## Available Custom Node Types

The plugin adds the following custom nodes to the scene tree:

1. **SpawnPattern** (extends Path2D)
   - Main pattern definition node
   - Uses Path2D curve for custom shapes
   - Script: `BuHPattern.gd`

2. **BulletPattern** (extends Path2D)
   - Bullet property configuration
   - Script: `BuHBulletProperties.gd`

3. **TriggerContainer** (extends Node)
   - Event-based bullet triggers
   - Script: `BuHTriggerContainer.gd`

4. **SpawnPoint** (extends Node2D)
   - Individual spawn location marker
   - Script: `BuHSpawnPoint.gd`

5. **InstanceLister** (extends Node)
   - Manages bullet instances
   - Script: `BuHInstanceLister.gd`

6. **BulletNode** (extends Area2D)
   - Individual bullet collision/rendering
   - Script: `BuHBulletNode.gd`

## Key Plugin Parameters

### Spawner (BuHSpawner.gd)

Located at `/root/Spawning` autoload:

#### Collision Groups
```gdscript
GROUP_BOUNCE: String = "Slime"  # Physics group for bouncy bullets
```

#### Resource Lists
```gdscript
sfx_list: Array[AudioStream] = []  # Sound effects for bullets
rand_variation_list: Array[Curve] = []  # Random variation curves
```

#### Optimization Culling
```gdscript
cull_bullets = true  # Delete bullets offscreen
cull_except_for: String = ""  # Props IDs to exempt from culling (semicolon-separated)
cull_margin = 50  # Distance from viewport border (default: STANDARD_BULLET_RADIUS * 10)
cull_trigger = true  # Deactivate triggers offscreen
cull_partial_move = true  # Calculate position but don't move until onscreen
cull_minimum_speed_required = 200  # Bullets slower than this won't cull
cull_fixed_screen = false  # Use fixed screen culling
```

#### Constants
```gdscript
STANDARD_BULLET_RADIUS = 5  # Base bullet size for calculations
```

#### Enums
```gdscript
enum BState { Unactive, Spawning, Spawned, Shooting, Moving, QueuedFree }
enum GROUP_SELECT { Nearest_on_homing, Nearest_on_spawn, Nearest_on_shoot, Nearest_anywhen, Random }
enum SYMTYPE { ClosedShape, Line }
enum CURVE_TYPE { None, LoopFromStart, OnceThenDie, OnceThenStay, LoopFromEnd }
enum LIST_ENDS { Stop, Loop, Reverse }
```

### Bullet Properties (BulletProps.gd)

Properties available when configuring bullet patterns:

- **Homing**: Target types, positions, nodes, mouse cursor
- **Movement**: Speed, acceleration, curves, angular equations
- **Visuals**: Textures, animations, scale, modulation
- **Collisions**: Shapes, groups, bouncing
- **Triggers**: Event-based behavior
- **Special**: Trails, explosions, warnings, lasers

## Signals

### BuHSpawner Signals
```gdscript
signal bullet_collided_area(area: Area2D, area_shape_index: int, bullet: Dictionary, local_shape_index: int, shared_area: Area2D)
signal bullet_collided_body(body: Node, body_shape_index: int, bullet: Dictionary, local_shape_index: int, shared_area: Area2D)
```

## Usage Example

### Basic Bullet Spawner Setup

```gdscript
# Access the spawning autoload
var spawner = get_node("/root/Spawning")

# Configure culling for performance
spawner.cull_bullets = true
spawner.cull_margin = 100
spawner.cull_minimum_speed_required = 150

# Connect to collision signals
spawner.bullet_collided_area.connect(_on_bullet_hit_area)

func _on_bullet_hit_area(area, area_shape_index, bullet, local_shape_index, shared_area):
    print("Bullet hit: ", area.name)
```

### Creating Patterns in Scene

1. Add a `SpawnPattern` node to your scene
2. Draw a path using the Path2D curve editor
3. Add a `BulletPattern` child node
4. Configure bullet properties in the inspector
5. Trigger spawning via script

## Testing

Run integration tests with GUT:
```bash
godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests/integration -gprefix=test_bullet
```

Or use the test scene:
- **Scene**: `res://combat/scenes/BulletPatternTest.tscn`
- **Script**: `res://combat/scenes/bullet_pattern_test.gd`

## Tunable Parameters for Combat Balance

### Performance vs Quality
- `cull_margin`: Increase for smoother edge transitions (higher performance cost)
- `cull_minimum_speed_required`: Lower to cull slow-moving bullets
- `cull_bullets`: Disable for dense patterns in small arenas

### Gameplay Feel
- `GROUP_BOUNCE`: Set to player collision layer for bouncy bullets
- `STANDARD_BULLET_RADIUS`: Base size for all bullet calculations

## Compatibility Notes

### Godot 4.2 Changes
The plugin has been verified compatible with Godot 4.2+:
- Uses `@export` instead of legacy `export`
- Uses `@tool` instead of `tool`
- Uses `PackedDataContainer` for serialization
- Signal connections use `Callable` syntax
- Uses typed arrays (`Array[Type]`)

## Example Scenes

The plugin includes example scenes in `addons/BulletUpHell/ExampleScenes/`:
- `Example1_Pattern_Types.tscn` - Different pattern shapes
- `Example2_Pattern_Properties.tscn` - Property configurations
- `Example3_Cooldowns.tscn` - Timing and cooldowns
- `Example4_Bullet_Customisation.tscn` - Visual customization
- `Example5_Homing.tscn` - Homing bullet behavior
- `Example6_Triggers.tscn` - Event-based triggers
- `Example7_SpawnScenes.tscn` - Scene instantiation

## References

- Plugin Repository: [BulletUpHell Original](https://github.com/Dark-Peace/BulletUpHell)
- Forked Location: `C:\dev\GIT\the-pond\addons\BulletUpHell\`
- Test Scene: `res://combat/scenes/BulletPatternTest.tscn`
- Integration Tests: `res://tests/integration/test_bullet_upHell_integration.gd`

## Next Steps

1. Design enemy bullet patterns using SpawnPattern nodes
2. Configure bullet properties for different enemy types
3. Balance culling parameters for performance
4. Create pattern presets for reuse
5. Integrate with enemy AI systems
