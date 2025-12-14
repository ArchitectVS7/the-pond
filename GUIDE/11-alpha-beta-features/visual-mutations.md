# Visual Mutations

Visual mutations change the player frog's appearance based on equipped mutations. This chapter covers the sprite layering system and effects.

---

## Overview

| Story | Description | Epic |
|-------|-------------|------|
| VISUAL-001 | Frog sprite variant system | EPIC-015 |
| VISUAL-002 | Oil trail visual (black sludge) | EPIC-015 |
| VISUAL-003 | Toxic aura visual (green glow) | EPIC-015 |
| VISUAL-004 | Mutation layering sprite system | EPIC-015 |
| VISUAL-005 | Mutation icon pixel art | EPIC-015 |
| VISUAL-006 | Mutation preview UI | EPIC-015 |

---

## Sprite Layer System

### Layer Order

```
Base Frog Sprite (bottom)
├── Body Modification Layer (skin changes)
├── Effect Layer (trails, particles)
├── Aura Layer (glows, shields)
└── Accessory Layer (top)
```

### Implementation

```gdscript
# visual_mutation_manager.gd
class_name VisualMutationManager
extends Node2D

var active_visuals: Array[VisualEffect] = []

@onready var body_layer: Sprite2D = $BodyLayer
@onready var effect_layer: Node2D = $EffectLayer
@onready var aura_layer: Node2D = $AuraLayer

func apply_visual(mutation_id: String) -> void:
    match mutation_id:
        "oil_trail":
            _add_trail_effect("oil", Color.BLACK)
        "toxic_skin":
            _add_aura_effect("toxic", Color.GREEN)
        "mercury_blood":
            _apply_skin_shader("metallic")
```

---

## Visual Effects

### Oil Trail

Black sludge particles left behind during movement.

```gdscript
func _add_oil_trail() -> void:
    var trail = preload("res://effects/OilTrail.tscn").instantiate()
    trail.color = Color(0.1, 0.1, 0.1, 0.8)
    trail.emission_rate = 10
    trail.lifetime = 2.0
    effect_layer.add_child(trail)
```

**Tunable Parameters**:

| Parameter | Default | Effect |
|-----------|---------|--------|
| `oil_particle_count` | 10 | Particles per second |
| `oil_particle_lifetime` | 2.0 | Seconds before fade |
| `oil_spread_radius` | 5.0 | Trail width |

### Toxic Aura

Green particle glow around the frog.

```gdscript
func _add_toxic_aura() -> void:
    var aura = preload("res://effects/ToxicAura.tscn").instantiate()
    aura.radius = 20.0
    aura.color = Color(0.2, 0.8, 0.2, 0.5)
    aura_layer.add_child(aura)
```

**Tunable Parameters**:

| Parameter | Default | Effect |
|-----------|---------|--------|
| `aura_radius` | 20.0 | Glow size |
| `aura_pulse_speed` | 1.0 | Breathing effect |
| `aura_opacity` | 0.5 | Transparency |

### Mercury Skin

Metallic shader effect on body.

```gdscript
func _apply_mercury_skin() -> void:
    var material = ShaderMaterial.new()
    material.shader = preload("res://shaders/metallic.gdshader")
    material.set_shader_parameter("metallic_intensity", 0.7)
    body_layer.material = material
```

---

## Combining Effects

Multiple mutations stack visually:

```gdscript
func update_visuals(mutations: Array[String]) -> void:
    clear_all_effects()

    for mutation in mutations:
        var visual_data = MUTATION_VISUALS.get(mutation)
        if visual_data:
            apply_visual(visual_data)
```

### Conflict Resolution

When effects conflict (e.g., two skin changes):

```gdscript
func _resolve_conflicts() -> void:
    # Priority: later mutations override earlier
    var skin_effects = active_visuals.filter(func(v): return v.type == "skin")
    if skin_effects.size() > 1:
        # Keep only the last one
        for i in range(skin_effects.size() - 1):
            skin_effects[i].queue_free()
```

---

## Performance

### Particle Budget

| Scenario | Max Particles | Notes |
|----------|---------------|-------|
| Normal gameplay | 50 | Base effects |
| 3 mutation effects | 150 | Stacked |
| Boss fight + effects | 200 | With bullets |

### Optimization

```gdscript
# Disable particles when off-screen
func _on_visibility_changed() -> void:
    for effect in active_visuals:
        effect.emitting = is_visible_in_tree()
```

### LOD (Level of Detail)

```gdscript
func _apply_lod(camera_distance: float) -> void:
    if camera_distance > LOD_THRESHOLD:
        # Simplify effects at distance
        _set_particle_quality(0.5)
    else:
        _set_particle_quality(1.0)
```

---

## Mutation Preview UI

Show visual effect before choosing mutation:

```gdscript
func preview_mutation(mutation_id: String) -> void:
    var preview_frog = $PreviewFrog
    preview_frog.clear_effects()
    preview_frog.apply_visual(mutation_id)

    # Animate preview
    var tween = create_tween()
    tween.tween_property(preview_frog, "rotation", TAU, 2.0)
```

---

## Visual Data Structure

```gdscript
const MUTATION_VISUALS := {
    "oil_trail": {
        "type": "trail",
        "scene": "res://effects/OilTrail.tscn",
        "layer": "effect"
    },
    "toxic_skin": {
        "type": "aura",
        "scene": "res://effects/ToxicAura.tscn",
        "layer": "aura"
    },
    "mercury_blood": {
        "type": "shader",
        "shader": "res://shaders/metallic.gdshader",
        "layer": "body"
    }
}
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `shared/scripts/visual_mutation_manager.gd` | Visual system |
| `effects/OilTrail.tscn` | Oil trail particles |
| `effects/ToxicAura.tscn` | Toxic glow particles |
| `shaders/metallic.gdshader` | Mercury skin effect |
| `assets/sprites/player/mutations/*.png` | Mutation overlays |

---

## Human Dependencies

| Asset | Requirement |
|-------|-------------|
| Oil trail sprite | 8x8 droplet |
| Toxic particle | 4x4 glow |
| Mutation overlays | Match frog proportions |
| Preview UI | Mutation showcase panel |

---

## Summary

| Visual Type | Implementation | Layer |
|-------------|----------------|-------|
| Trails | Particle emitter | Effect |
| Auras | Particle + shader | Aura |
| Skin changes | Shader material | Body |
| Accessories | Sprite overlay | Accessory |

Visual mutations are cosmetic. They don't affect gameplay, but they make the pollution theme visceral. The player's frog becomes a walking monument to environmental damage.

---

[← Back to Overview](overview.md) | [Next: Dynamic Music →](dynamic-music.md)
