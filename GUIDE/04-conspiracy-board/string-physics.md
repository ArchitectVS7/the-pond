# String Physics

Connections between evidence cards use string rendering with spring physics. The strings wobble when cards move and settle naturally. This chapter covers the implementation.

---

## The Visual Goal

Real conspiracy boards use red string connecting pins. We simulate this:
- String sags slightly due to "gravity"
- String bounces when endpoints move
- String settles with natural damping
- Multiple segments create smooth curves

---

## Spring Model (BOARD-008)

**File**: `conspiracy_board/scripts/string_renderer.gd`

### How It Works

The string is a series of connected points. Each point is pulled:
1. Toward its target position (spring force)
2. By a damping force (reduces oscillation)
3. Optionally by gravity (creates sag)

```gdscript
func _physics_process(delta: float) -> void:
    for i in range(segments.size()):
        var target := _calculate_target_position(i)
        var force := (target - segments[i].position) * stiffness
        var damping_force := -segments[i].velocity * damping

        segments[i].velocity += (force + damping_force) * delta
        segments[i].position += segments[i].velocity * delta
```

### Spring Equation

```
F = -k * x - c * v

Where:
- F = net force
- k = stiffness (spring constant)
- x = displacement from target
- c = damping coefficient
- v = velocity
```

---

## Tunable Parameters

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `string_stiffness` | float | 150.0 | 50-300 | Spring tightness |
| `string_damping` | float | 8.0 | 2-15 | Oscillation reduction |
| `string_segments` | int | 20 | 10-50 | Curve resolution |
| `string_gravity` | float | 50.0 | 0-100 | Sag amount |
| `string_width` | float | 2.0 | 1-5 | Line thickness |
| `string_color` | Color | Red | - | Connection color |

### Tuning Stiffness

| Value | Effect | Feel |
|-------|--------|------|
| 50 | Loose | Floppy, slow |
| 150 | Default | Natural bounce |
| 300 | Tight | Snappy, quick |

### Tuning Damping

| Value | Effect |
|-------|--------|
| 2 | Long oscillation (wobbly) |
| 8 | Moderate (default) |
| 15 | Quick settle (stiff) |

### Settle Time

With defaults (stiffness=150, damping=8):
- String settles in ~300ms
- Natural bounce without feeling sluggish

---

## Implementation

### Segment Structure

```gdscript
class StringSegment:
    var position: Vector2
    var velocity: Vector2

    func _init(pos: Vector2) -> void:
        position = pos
        velocity = Vector2.ZERO
```

### Initialization

```gdscript
func create_string(start: Vector2, end: Vector2) -> void:
    segments.clear()

    for i in range(segment_count):
        var t := float(i) / (segment_count - 1)
        var pos := start.lerp(end, t)
        segments.append(StringSegment.new(pos))

    # First and last segments are anchored
    anchor_start = start
    anchor_end = end
```

### Physics Update

```gdscript
func _physics_process(delta: float) -> void:
    # Update anchors from card positions
    anchor_start = start_card.global_position + start_offset
    anchor_end = end_card.global_position + end_offset

    # Update each segment
    for i in range(segments.size()):
        if i == 0:
            segments[i].position = anchor_start
            segments[i].velocity = Vector2.ZERO
            continue
        if i == segments.size() - 1:
            segments[i].position = anchor_end
            segments[i].velocity = Vector2.ZERO
            continue

        # Calculate target (lerp between anchors with sag)
        var t := float(i) / (segments.size() - 1)
        var base := anchor_start.lerp(anchor_end, t)
        var sag := Vector2(0, sin(t * PI) * string_gravity)
        var target := base + sag

        # Apply spring physics
        var displacement := target - segments[i].position
        var spring_force := displacement * string_stiffness
        var damp_force := -segments[i].velocity * string_damping

        segments[i].velocity += (spring_force + damp_force) * delta
        segments[i].position += segments[i].velocity * delta

    queue_redraw()
```

### Rendering

```gdscript
func _draw() -> void:
    if segments.size() < 2:
        return

    var points := PackedVector2Array()
    for segment in segments:
        points.append(segment.position - global_position)

    draw_polyline(points, string_color, string_width, true)
```

---

## Connection Management

### Creating Connections

```gdscript
# In conspiracy_board.gd
func create_connection(card_a: DataLogCard, card_b: DataLogCard) -> void:
    # Validate connection
    if not _can_connect(card_a, card_b):
        return

    # Create string renderer
    var string := StringRenderer.new()
    string.start_card = card_a
    string.end_card = card_b
    $StringContainer.add_child(string)

    # Store connection
    connections.append({
        "from": card_a.resource.id,
        "to": card_b.resource.id,
        "renderer": string
    })

    emit_signal("connection_made", card_a, card_b)
```

### Removing Connections

```gdscript
func remove_connection(card_a: DataLogCard, card_b: DataLogCard) -> void:
    for i in range(connections.size() - 1, -1, -1):
        var conn := connections[i]
        if _connection_matches(conn, card_a, card_b):
            conn.renderer.queue_free()
            connections.remove_at(i)
```

---

## Visual Polish

### Gradient Color

```gdscript
func _draw() -> void:
    for i in range(segments.size() - 1):
        var t := float(i) / (segments.size() - 1)
        var color := start_color.lerp(end_color, t)
        draw_line(
            segments[i].position - global_position,
            segments[i + 1].position - global_position,
            color,
            string_width
        )
```

### Pin Decorations

Add small circles at endpoints:
```gdscript
func _draw() -> void:
    # Draw string
    draw_polyline(points, string_color, string_width, true)

    # Draw pins
    draw_circle(points[0], 4.0, Color.RED)
    draw_circle(points[-1], 4.0, Color.RED)
```

### Shadow

```gdscript
func _draw() -> void:
    var shadow_offset := Vector2(2, 2)

    # Draw shadow first
    var shadow_points := PackedVector2Array()
    for p in points:
        shadow_points.append(p + shadow_offset)
    draw_polyline(shadow_points, Color(0, 0, 0, 0.3), string_width + 1)

    # Draw string
    draw_polyline(points, string_color, string_width)
```

---

## Performance

### Segment Count

More segments = smoother curves, but more physics calculations.

| Segments | Quality | Performance |
|----------|---------|-------------|
| 10 | Blocky | Fast |
| 20 | Smooth (default) | Good |
| 50 | Very smooth | Slower |

### Update Rate

Strings update in `_physics_process` (60fps). For visual-only physics, you could use `_process` with delta scaling.

### Multiple Strings

With many connections, consider:
- Reducing segment count
- Using simpler physics (no gravity)
- Batching draw calls

---

## Debugging

### Visualize Segments

```gdscript
func _draw() -> void:
    # Draw string
    draw_polyline(points, string_color, string_width)

    # Draw segment points
    for segment in segments:
        draw_circle(segment.position - global_position, 3.0, Color.YELLOW)
```

### Log Physics

```gdscript
func _physics_process(delta: float) -> void:
    var total_velocity := 0.0
    for segment in segments:
        total_velocity += segment.velocity.length()

    if Engine.get_physics_frames() % 60 == 0:
        print("String velocity: %.2f" % total_velocity)
```

### Test Parameters

Create a debug UI to adjust parameters in real-time:
```gdscript
func _on_stiffness_slider_changed(value: float) -> void:
    string_stiffness = value
```

---

## Common Issues

**String doesn't move:**
- Check `_physics_process` is running
- Verify anchor positions update
- Ensure segments aren't all anchored

**String oscillates forever:**
- Increase `string_damping`
- Reduce `string_stiffness`

**String looks jagged:**
- Increase `string_segments`
- Enable antialiasing in draw_polyline

**String sags too much:**
- Reduce `string_gravity`
- Increase `string_stiffness`

---

## Sidebar: Why Spring Physics?

Spring physics creates natural motion because it models real-world behavior:

1. **Displacement creates force**: Further from target = stronger pull
2. **Velocity creates damping**: Moving fast = more resistance
3. **Force changes velocity**: Creates acceleration/deceleration
4. **Result**: Overshoot, oscillation, settle

This is more satisfying than linear interpolation because it has "weight" and "momentum."

---

## Summary

| Parameter | Default | Effect |
|-----------|---------|--------|
| Stiffness | 150 | How tight the spring |
| Damping | 8 | How quickly it settles |
| Segments | 20 | Curve smoothness |
| Gravity | 50 | Sag amount |

The strings make the board feel physical. They respond to card movement, creating a sense of connected evidence that players are literally stringing together.

---

[← Back to Drag-Drop](drag-drop.md) | [Next: Document Viewer →](document-viewer.md)
