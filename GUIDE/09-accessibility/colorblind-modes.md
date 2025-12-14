# Colorblind Modes

Colorblind filters help players who can't distinguish certain colors. The Pond supports three modes via a viewport shader, covering the most common forms of color vision deficiency.

---

## Mode Types

| Mode | Affects | Population |
|------|---------|------------|
| Deuteranopia | Red-green confusion | ~6% of men |
| Protanopia | Red blindness | ~1% of men |
| Tritanopia | Blue-yellow confusion | ~0.01% |

Deuteranopia is by far the most common, followed by protanopia. Tritanopia is rare but included for completeness.

---

## Implementation

### Enum Definition

```gdscript
enum ColorblindMode {
    NORMAL = 0,
    DEUTERANOPIA = 1,
    PROTANOPIA = 2,
    TRITANOPIA = 3
}
```

### Shader Setup

```gdscript
func setup_colorblind_shader() -> void:
    var shader = load("res://shared/shaders/colorblind_filter.gdshader")
    colorblind_material = ShaderMaterial.new()
    colorblind_material.shader = shader
    colorblind_material.set_shader_parameter("filter_mode", colorblind_mode)
    colorblind_material.set_shader_parameter("filter_strength", 1.0)
```

---

## Setting the Mode

```gdscript
func set_colorblind_mode(mode: ColorblindMode) -> void:
    colorblind_mode = mode

    if colorblind_material:
        colorblind_material.set_shader_parameter("filter_mode", mode)

    var viewport = get_viewport()
    if mode == ColorblindMode.NORMAL:
        # Remove filter
        if viewport.has_meta("colorblind_layer"):
            var layer = viewport.get_meta("colorblind_layer")
            layer.queue_free()
            viewport.remove_meta("colorblind_layer")
    else:
        # Apply filter
        apply_colorblind_filter_to_viewport(viewport)

    save_settings()
    colorblind_mode_changed.emit(mode)
```

---

## Viewport Filter

The filter is a full-screen ColorRect with the shader:

```gdscript
func apply_colorblind_filter_to_viewport(viewport: Viewport) -> void:
    var filter_layer: ColorRect

    if viewport.has_meta("colorblind_layer"):
        filter_layer = viewport.get_meta("colorblind_layer")
    else:
        filter_layer = ColorRect.new()
        filter_layer.name = "ColorblindFilter"
        filter_layer.material = colorblind_material
        filter_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        viewport.add_child(filter_layer)
        viewport.set_meta("colorblind_layer", filter_layer)

    filter_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    filter_layer.material = colorblind_material
```

---

## Shader (colorblind_filter.gdshader)

**File**: `shared/shaders/colorblind_filter.gdshader`

```glsl
shader_type canvas_item;

uniform int filter_mode : hint_range(0, 3) = 0;
uniform float filter_strength : hint_range(0.0, 1.0) = 1.0;

// Color transformation matrices for each type
const mat3 DEUTERANOPIA_MATRIX = mat3(
    vec3(0.625, 0.375, 0.0),
    vec3(0.7, 0.3, 0.0),
    vec3(0.0, 0.3, 0.7)
);

const mat3 PROTANOPIA_MATRIX = mat3(
    vec3(0.567, 0.433, 0.0),
    vec3(0.558, 0.442, 0.0),
    vec3(0.0, 0.242, 0.758)
);

const mat3 TRITANOPIA_MATRIX = mat3(
    vec3(0.95, 0.05, 0.0),
    vec3(0.0, 0.433, 0.567),
    vec3(0.0, 0.475, 0.525)
);

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    if (filter_mode == 0) {
        // Normal - no transformation
        COLOR = color;
    } else {
        mat3 transform;

        if (filter_mode == 1) {
            transform = DEUTERANOPIA_MATRIX;
        } else if (filter_mode == 2) {
            transform = PROTANOPIA_MATRIX;
        } else {
            transform = TRITANOPIA_MATRIX;
        }

        vec3 transformed = transform * color.rgb;
        COLOR = vec4(mix(color.rgb, transformed, filter_strength), color.a);
    }
}
```

---

## Color Considerations

### Colors to Avoid

When designing UI and game elements:

| Avoid | Why |
|-------|-----|
| Red/green differentiation | Indistinguishable for deuteranopia/protanopia |
| Color as only indicator | Always use shape or pattern too |
| Pure red on green | Maximum confusion |

### Good Practices

| Practice | Example |
|----------|---------|
| Use icons with color | Health bar + heart icon |
| High contrast | White text on dark background |
| Patterns | Striped vs solid fills |
| Labels | "Danger" text, not just red |

---

## Testing Colorblind Modes

### Manual Testing

1. Enable each mode in settings
2. Play through key gameplay
3. Verify:
   - Enemy types are distinguishable
   - UI elements are clear
   - Health/damage is visible
   - Conspiracy board connections are clear

### Simulator Tools

- [Coblis](https://www.color-blindness.com/coblis-color-blindness-simulator/)
- [Color Oracle](https://colororacle.org/) (desktop app)
- Browser devtools (Chrome has colorblindness simulation)

### What to Check

| Element | Question |
|---------|----------|
| Enemies | Can you tell enemy types apart? |
| Health | Is damage clearly visible? |
| Board | Are connections distinguishable? |
| Buttons | Are hover/active states clear? |

---

## Filter Strength

The `filter_strength` parameter allows partial application:

```gdscript
# Full colorblind simulation (default)
colorblind_material.set_shader_parameter("filter_strength", 1.0)

# Partial correction (softer adjustment)
colorblind_material.set_shader_parameter("filter_strength", 0.7)
```

Currently fixed at 1.0, but could be exposed as a user setting in future.

---

## Performance

The shader runs on every pixel every frame. Performance impact:

| Hardware | Impact |
|----------|--------|
| Desktop | Negligible |
| Steam Deck | ~1% GPU |
| Integrated | ~2-3% GPU |

The matrix multiplication is simple enough that it doesn't affect frame rate on any target hardware.

---

## Settings Menu Integration

```gdscript
func _populate_colorblind_options() -> void:
    var options = $ColorblindDropdown as OptionButton
    options.add_item("Normal", 0)
    options.add_item("Deuteranopia (Red-Green)", 1)
    options.add_item("Protanopia (Red-Blind)", 2)
    options.add_item("Tritanopia (Blue-Yellow)", 3)

    options.selected = accessibility_manager.colorblind_mode

func _on_colorblind_dropdown_item_selected(index: int) -> void:
    accessibility_manager.set_colorblind_mode(index as AccessibilityManager.ColorblindMode)
```

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Filter types | 3 (Deuteranopia, Protanopia, Tritanopia) |
| Method | Viewport shader |
| Performance | Negligible |
| Strength | 0.0-1.0 (fixed at 1.0) |

Colorblind filters ensure The Pond is playable by everyone. The shader-based approach works across all scenes without modifying individual assets.

---

[← Back to Overview](overview.md) | [Next: Text Scaling →](text-scaling.md)
