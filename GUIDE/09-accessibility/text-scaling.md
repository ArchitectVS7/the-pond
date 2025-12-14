# Text Scaling

Text scaling lets players increase font sizes for readability. Three presets cover most needs: Small (0.8x), Normal (1.0x), and Large (1.3x).

---

## Scale Presets

```gdscript
enum TextScale {
    SMALL = 0,   # 0.8x
    NORMAL = 1,  # 1.0x
    LARGE = 2    # 1.3x
}

const TEXT_SCALE_VALUES = {
    TextScale.SMALL: 0.8,
    TextScale.NORMAL: 1.0,
    TextScale.LARGE: 1.3
}
```

| Scale | Multiplier | Use Case |
|-------|------------|----------|
| SMALL | 0.8x | More content visible |
| NORMAL | 1.0x | Default |
| LARGE | 1.3x | Better readability |

---

## Setting Text Scale

```gdscript
func set_text_scale(scale: TextScale) -> void:
    text_scale = scale
    var scale_value = TEXT_SCALE_VALUES[scale]

    # Apply to all text in scene tree
    apply_text_scale_recursive(get_tree().root, scale_value)

    save_settings()
    text_scale_changed.emit(scale_value)
```

---

## Recursive Application

The scaling walks the entire scene tree:

```gdscript
func apply_text_scale_recursive(node: Node, scale_value: float) -> void:
    if node is Label:
        var label = node as Label
        # Store original size on first scale
        if not label.has_meta("original_font_size"):
            label.set_meta("original_font_size", label.get_theme_font_size("font_size"))
        var original_size = label.get_meta("original_font_size")
        label.add_theme_font_size_override("font_size", int(original_size * scale_value))

    elif node is RichTextLabel:
        var rtl = node as RichTextLabel
        if not rtl.has_meta("original_font_size"):
            rtl.set_meta("original_font_size", rtl.get_theme_font_size("normal_font_size"))
        var original_size = rtl.get_meta("original_font_size")
        rtl.add_theme_font_size_override("normal_font_size", int(original_size * scale_value))

    for child in node.get_children():
        apply_text_scale_recursive(child, scale_value)
```

---

## Original Size Storage

The system stores each node's original font size in metadata:

```gdscript
# First time scaling is applied
if not label.has_meta("original_font_size"):
    label.set_meta("original_font_size", label.get_theme_font_size("font_size"))

# All subsequent applications
var original_size = label.get_meta("original_font_size")
```

This ensures repeated scale changes compound correctly. Without storing the original, scaling 1.0 → 1.3 → 1.0 would result in a smaller size than intended.

---

## Get Current Scale

```gdscript
func get_text_scale_value() -> float:
    return TEXT_SCALE_VALUES[text_scale]
```

Use this when dynamically creating UI:

```gdscript
func create_label(text: String) -> Label:
    var label = Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size",
        int(16 * accessibility_manager.get_text_scale_value()))
    return label
```

---

## Supported Node Types

| Node | Property Scaled |
|------|-----------------|
| Label | `font_size` |
| RichTextLabel | `normal_font_size` |
| Button | Via Label child |
| LineEdit | Not directly (uses theme) |

### Extending Support

To add LineEdit scaling:

```gdscript
elif node is LineEdit:
    var edit = node as LineEdit
    if not edit.has_meta("original_font_size"):
        edit.set_meta("original_font_size", edit.get_theme_font_size("font_size"))
    var original_size = edit.get_meta("original_font_size")
    edit.add_theme_font_size_override("font_size", int(original_size * scale_value))
```

---

## UI Layout Considerations

When designing UI, account for text expansion:

| Consideration | Solution |
|---------------|----------|
| Fixed-width buttons | Use `size_flags_horizontal = SIZE_EXPAND_FILL` |
| Text overflow | Enable `autowrap_mode` on Labels |
| Panel sizing | Use minimum_size, not fixed size |
| Scroll containers | Wrap long content in ScrollContainer |

### Bad Example

```gdscript
# Fixed size - text will overflow
$Button.custom_minimum_size = Vector2(100, 40)
```

### Good Example

```gdscript
# Flexible - grows with content
$Button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
$Button/Label.autowrap_mode = TextServer.AUTOWRAP_WORD
```

---

## Settings Menu Integration

```gdscript
func _populate_text_scale_options() -> void:
    var options = $TextScaleDropdown as OptionButton
    options.add_item("Small (80%)", 0)
    options.add_item("Normal (100%)", 1)
    options.add_item("Large (130%)", 2)

    options.selected = accessibility_manager.text_scale

func _on_text_scale_dropdown_item_selected(index: int) -> void:
    accessibility_manager.set_text_scale(index as AccessibilityManager.TextScale)
```

---

## Reapplying After Scene Changes

Text scaling needs reapplication when scenes change:

```gdscript
func _on_scene_loaded() -> void:
    # Reapply current scale to new scene
    accessibility_manager.apply_all_settings()
```

Or connect to scene tree signals:

```gdscript
func _ready() -> void:
    get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
    if node is Label or node is RichTextLabel:
        apply_text_scale_recursive(node, get_text_scale_value())
```

---

## Minimum Sizes

WCAG recommends minimum text sizes:

| Element | Minimum | At 1.3x |
|---------|---------|---------|
| Body text | 12pt | 16pt |
| Buttons | 12pt | 16pt |
| Headings | 16pt | 21pt |

Design base sizes so that even SMALL (0.8x) remains readable:

```gdscript
# If minimum readable is 12pt, base should be 15pt
# 15 * 0.8 = 12pt (still readable)
# 15 * 1.0 = 15pt (normal)
# 15 * 1.3 = 19pt (large)
```

---

## Performance

Text scaling is applied once when changed, not every frame. Performance impact:

| Operation | Cost |
|-----------|------|
| Initial application | ~5ms for full scene |
| Per-frame | Zero |
| Scene change reapply | ~2ms |

The recursive walk is O(n) where n is node count, but only runs on settings change.

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Scale presets | 0.8x, 1.0x, 1.3x |
| Method | Theme font size override |
| Persistence | Config file |
| Original tracking | Node metadata |
| Node types | Label, RichTextLabel |

Text scaling helps players with vision difficulties enjoy The Pond without external tools. The metadata system ensures scales can be changed freely without compounding errors.

---

[← Back to Colorblind Modes](colorblind-modes.md) | [Next: Input Accessibility →](input-accessibility.md)
