# Pollution Index

The pollution meter visualizes the environmental cost of pollution mutations. It's the risk/reward feedback loop - powerful mutations fill the meter, and a full meter has consequences.

---

## The Concept

Every pollution mutation adds to the meter. The meter provides:

- **Visual feedback**: Green → Yellow → Red as pollution rises
- **Thematic reinforcement**: You're literally polluting the pond
- **Risk signaling**: Players know when they're in danger
- **Narrative weight**: The conspiracy board theme extends to gameplay

---

## PollutionMeter Structure

**File**: `metagame/scripts/pollution_meter.gd`

```gdscript
extends Control
class_name PollutionMeter

# Meter dimensions
@export var meter_width: int = 150
@export var meter_height: int = 20
@export var meter_position: Vector2 = Vector2(20, 20)

# Current value (0-100)
var pollution_value: float = 0.0:
    set(value):
        pollution_value = clamp(value, 0.0, 100.0)
        _update_meter()

# Color thresholds
@export var color_low: Color = Color.GREEN
@export var color_mid: Color = Color.YELLOW
@export var color_high: Color = Color.RED
@export var threshold_low: float = 0.33
@export var threshold_high: float = 0.67
@export var color_lerp_enabled: bool = true

# Tooltip messages
@export var message_low: String = "The pond is healthy. Keep it that way!"
@export var message_mid: String = "Pollution is building up... The frogs are worried."
@export var message_high: String = "CRITICAL: Ecosystem in danger! Corporate greed is killing the pond!"
```

---

## Tunable Parameters

### Meter Dimensions

| Parameter | Type | Default | Effect |
|-----------|------|---------|--------|
| `meter_width` | int | 150 | Width in pixels |
| `meter_height` | int | 20 | Height in pixels |
| `meter_position` | Vector2 | (20, 20) | Screen position |
| `fill_direction` | int | 0 | 0=left-to-right |

### Color Coding

| Parameter | Type | Default | Effect |
|-----------|------|---------|--------|
| `color_low` | Color | GREEN | 0-33% color |
| `color_mid` | Color | YELLOW | 33-67% color |
| `color_high` | Color | RED | 67-100% color |
| `threshold_low` | float | 0.33 | Green-yellow boundary |
| `threshold_high` | float | 0.67 | Yellow-red boundary |
| `color_lerp_enabled` | bool | true | Smooth color transitions |

### Mutation Weights

| Parameter | Type | Default | Effect |
|-----------|------|---------|--------|
| `pollution_per_mutation` | float | 15.0 | Base pollution per mutation |
| `oil_mutation_weight` | float | 1.5 | Oil Slick multiplier |
| `toxic_mutation_weight` | float | 1.2 | Toxic Aura multiplier |
| `mercury_mutation_weight` | float | 2.0 | Mercury Blood multiplier |
| `max_pollution` | float | 100.0 | Maximum meter value |

### Animation

| Parameter | Type | Default | Effect |
|-----------|------|---------|--------|
| `update_animation` | bool | true | Enable pulse on update |
| `pulse_duration` | float | 0.3 | Pulse animation time |
| `pulse_scale` | float | 1.1 | Pulse scale factor |

---

## Color System

The meter smoothly transitions between colors:

```gdscript
func _update_color() -> void:
    var normalized = pollution_value / 100.0
    var target_color: Color

    if normalized <= threshold_low:
        if color_lerp_enabled:
            target_color = color_low.lerp(color_mid, normalized / threshold_low)
        else:
            target_color = color_low
    elif normalized <= threshold_high:
        if color_lerp_enabled:
            var t = (normalized - threshold_low) / (threshold_high - threshold_low)
            target_color = color_mid.lerp(color_high, t)
        else:
            target_color = color_mid
    else:
        if color_lerp_enabled:
            var t = (normalized - threshold_high) / (1.0 - threshold_high)
            target_color = color_high.lerp(Color.DARK_RED, t)
        else:
            target_color = color_high

    # Apply to ProgressBar fill
    var style = StyleBoxFlat.new()
    style.bg_color = target_color
    style.corner_radius_top_left = 4
    # ... set other corners
    progress_bar.add_theme_stylebox_override("fill", style)
```

### Color Ranges

| Pollution | Color | Meaning |
|-----------|-------|---------|
| 0-33% | Green → Yellow | Safe zone |
| 33-67% | Yellow → Orange | Caution zone |
| 67-100% | Red → Dark Red | Danger zone |

---

## Tooltip System

Hover over the meter for contextual messages:

```gdscript
func _get_tooltip_message() -> String:
    var normalized = pollution_value / 100.0
    if normalized <= threshold_low:
        return message_low  # "The pond is healthy..."
    elif normalized <= threshold_high:
        return message_mid  # "Pollution is building up..."
    else:
        return message_high  # "CRITICAL: Ecosystem in danger!"

func _make_custom_tooltip(for_text: String) -> Object:
    var label = Label.new()
    label.text = _get_tooltip_message()

    var panel = PanelContainer.new()
    # ... styling
    panel.add_child(label)

    return panel
```

---

## Mutation Integration

### Calculating Pollution

```gdscript
func calculate_pollution_from_mutations(mutations: Array) -> float:
    var total = 0.0
    for mutation in mutations:
        if mutation.has("type") and mutation.type == "pollution":
            var weight = 1.0
            match mutation.get("subtype", ""):
                "oil":
                    weight = oil_mutation_weight
                "toxic":
                    weight = toxic_mutation_weight
                "mercury":
                    weight = mercury_mutation_weight
            total += pollution_per_mutation * weight
    return min(total, max_pollution)
```

### Pollution Costs by Mutation

| Mutation | Base Cost | Weight | Effective Cost |
|----------|-----------|--------|----------------|
| Oil Slick | 15 | 1.5x | ~23 |
| Toxic Aura | 12 | 1.2x | ~18 |
| Mercury Blood | 20 | 2.0x | ~40 |

With defaults, taking all three pollution mutations fills the meter to ~81%.

---

## Event Integration

### Connecting to Mutation System

```gdscript
func _ready() -> void:
    # Connect to EventBus
    if has_node("/root/EventBus"):
        var event_bus = get_node("/root/EventBus")
        if event_bus.has_signal("mutation_selected"):
            event_bus.mutation_selected.connect(_on_mutation_selected)

func _on_mutation_selected(mutation: Dictionary) -> void:
    if mutation.get("type", "") == "pollution":
        _pollution_mutation_count += 1
        pollution_value = calculate_pollution_from_mutations([mutation])
        if update_animation:
            _play_pulse_animation()
```

### Emitting Pollution Updates

```gdscript
func _update_meter() -> void:
    if not is_node_ready():
        return

    progress_bar.value = pollution_value
    tooltip_text = _get_tooltip_message()
    _update_color()

    # Notify other systems
    if has_node("/root/EventBus"):
        var event_bus = get_node("/root/EventBus")
        if event_bus.has_signal("pollution_updated"):
            event_bus.pollution_updated.emit(pollution_value)
```

---

## Visual Feedback

### Pulse Animation

When pollution increases:

```gdscript
func _play_pulse_animation() -> void:
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_ELASTIC)
    tween.tween_property(self, "scale", Vector2(pulse_scale, pulse_scale), pulse_duration / 2)
    tween.tween_property(self, "scale", Vector2.ONE, pulse_duration / 2)
```

### Styling

```gdscript
# Background style
var bg_style = StyleBoxFlat.new()
bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
bg_style.corner_radius_top_left = 4
bg_style.corner_radius_top_right = 4
bg_style.corner_radius_bottom_left = 4
bg_style.corner_radius_bottom_right = 4
progress_bar.add_theme_stylebox_override("background", bg_style)
```

---

## Scene Structure

```
PollutionMeter (Control)
└── ProgressBar
```

Minimal structure - the meter is just a styled ProgressBar.

---

## Consequences (Planned)

### MVP State

Currently, pollution is informational only. Future phases will add:

### Alpha: Environmental Effects

| Pollution | Effect |
|-----------|--------|
| 50% | Occasional toxic puddles spawn |
| 75% | Enemy spawn rate increases |
| 100% | Mutated enemies appear |

### Beta: Endings Impact

| Pollution | Ending |
|-----------|--------|
| <33% | "Clean Pond" ending |
| 33-67% | "Compromised" ending |
| >67% | "Polluted" ending |

---

## Testing

### Manual Testing

```gdscript
# Set pollution directly for testing
func set_pollution(value: float) -> void:
    pollution_value = value

# Simulate mutation pickup
func set_pollution_mutations(count: int) -> void:
    _pollution_mutation_count = count
    pollution_value = count * pollution_per_mutation
```

### Test Cases

1. **Color Transitions**: Set pollution to 0, 33, 50, 67, 100 and verify colors
2. **Tooltip Updates**: Hover at each threshold, verify message
3. **Pulse Animation**: Add pollution mutation, verify pulse plays
4. **Bounds**: Try setting pollution to -10, 150 - should clamp

---

## Common Issues

**Meter doesn't update:**
- Check `pollution_value` setter is triggering
- Verify `_update_meter()` is called
- Ensure ProgressBar node path is correct

**Colors wrong:**
- Check threshold values (should be 0.0-1.0)
- Verify color values are set
- Test with `color_lerp_enabled = false`

**No pulse animation:**
- Check `update_animation` is true
- Verify tween is created
- Test pulse_scale and pulse_duration values

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Display | ProgressBar with custom StyleBox |
| Colors | Green → Yellow → Red lerp |
| Tooltips | Threshold-based messages |
| Animation | Scale pulse on update |
| Integration | EventBus signals |

The pollution meter turns an abstract number into emotional feedback. Green is safe. Red is danger. Players feel the consequences of their choices.

---

[← Back to Synergies](synergies.md) | [Next: Balancing →](balancing.md)
