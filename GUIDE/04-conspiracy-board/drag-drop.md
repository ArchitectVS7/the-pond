# Drag-Drop System

Cards need to feel grabbable. The drag-drop system handles picking up cards, moving them around the board, and snapping them to pin positions.

---

## Core Mechanics (BOARD-006)

**File**: `conspiracy_board/scripts/data_log_card.gd`

### Interaction States

```gdscript
enum InteractionState { IDLE, HOVER, PRESSED, DRAGGING }
var interaction_state := InteractionState.IDLE
```

| State | Visual | Behavior |
|-------|--------|----------|
| IDLE | Normal | Waiting for input |
| HOVER | Slight glow | Mouse over card |
| PRESSED | Pressed effect | Mouse down, not yet dragging |
| DRAGGING | Lifted, semi-transparent | Following mouse |

### The Drag Threshold

Movement below `drag_threshold` (5px) is a click. Movement above is a drag.

```gdscript
func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            _start_potential_drag(event.position)
        elif not event.pressed:
            _end_interaction()

    elif event is InputEventMouseMotion and interaction_state == InteractionState.PRESSED:
        var distance := event.position.distance_to(press_start_position)
        if distance > drag_threshold:
            _start_drag()
```

**Why a threshold?**
Without it, every click becomes a tiny drag. Players would accidentally move cards when trying to open them.

---

## Tunable Parameters

| Parameter | Type | Default | Range | Effect |
|-----------|------|---------|-------|--------|
| `drag_threshold` | float | 5.0 | 2-10 | Pixels before drag activates |
| `drag_opacity` | float | 0.8 | 0.5-1.0 | Opacity while dragging |
| `lift_scale` | float | 1.05 | 1.0-1.2 | Scale while dragging |
| `snap_distance` | float | 50.0 | 30-100 | Pin snap range |

### Tuning Drag Threshold

| Value | Effect | Use Case |
|-------|--------|----------|
| 2-3px | Very sensitive | Precision users |
| 5px | Default | Most users |
| 8-10px | Less sensitive | Touch/imprecise input |

### Tuning Snap Distance

| Value | Effect |
|-------|--------|
| 30px | Must be very close to pin |
| 50px | Comfortable default |
| 100px | Aggressive snapping |

---

## Drag Implementation

### Starting a Drag

```gdscript
func _start_drag() -> void:
    interaction_state = InteractionState.DRAGGING

    # Store original position for potential cancel
    original_position = global_position

    # Calculate offset from mouse to card corner
    drag_offset = global_position - get_global_mouse_position()

    # Visual feedback
    z_index = 100  # Bring to top
    modulate.a = drag_opacity
    scale = Vector2(lift_scale, lift_scale)

    # Notify board
    emit_signal("drag_started", self)
```

### During Drag

```gdscript
func _process(delta: float) -> void:
    if interaction_state == InteractionState.DRAGGING:
        global_position = get_global_mouse_position() + drag_offset
```

### Ending Drag

```gdscript
func _end_drag() -> void:
    interaction_state = InteractionState.IDLE

    # Reset visuals
    z_index = original_z_index
    modulate.a = 1.0 if discovered else undiscovered_alpha
    scale = Vector2.ONE

    # Notify board (handles snapping)
    emit_signal("drag_ended", self)
```

---

## Pin Snapping (BOARD-007)

When a card is released, it snaps to the nearest pin if within range.

**File**: `conspiracy_board/scripts/conspiracy_board.gd`

```gdscript
func _on_card_drag_ended(card: DataLogCard) -> void:
    var nearest_pin := _find_nearest_pin(card.global_position)

    if nearest_pin and _distance_to_pin(card, nearest_pin) <= snap_distance:
        _snap_card_to_pin(card, nearest_pin)
    else:
        # Card stays where dropped
        pass

    _save_card_position(card)

func _find_nearest_pin(position: Vector2) -> Pin:
    var nearest: Pin = null
    var nearest_dist := INF

    for pin in pins:
        var dist := position.distance_to(pin.global_position)
        if dist < nearest_dist:
            nearest_dist = dist
            nearest = pin

    return nearest

func _snap_card_to_pin(card: DataLogCard, pin: Pin) -> void:
    # Animate snap
    var tween := create_tween()
    tween.tween_property(card, "global_position", pin.global_position, 0.15)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)

    # Play snap sound
    AudioManager.play_sfx("pin_snap")
```

### Pin Layout

Pins are pre-positioned on the board:
```
+------------------------------------------+
|  [Pin]   [Pin]   [Pin]   [Pin]   [Pin]   |
|                                          |
|  [Pin]   [Pin]   [Pin]   [Pin]   [Pin]   |
|                                          |
|  [Pin]   [Pin]   [Pin]   [Pin]   [Pin]   |
+------------------------------------------+
```

---

## Click vs Drag

The system distinguishes clicks from drags:

```gdscript
func _end_interaction() -> void:
    match interaction_state:
        InteractionState.PRESSED:
            # Didn't move enough - it's a click
            _handle_click()
        InteractionState.DRAGGING:
            # Was dragging - end the drag
            _end_drag()

    interaction_state = InteractionState.IDLE

func _handle_click() -> void:
    if discovered:
        emit_signal("card_clicked", self)
        # Board opens document viewer
```

---

## Signals

| Signal | When Emitted | Parameters |
|--------|--------------|------------|
| `card_clicked` | Click without drag | `card: DataLogCard` |
| `drag_started` | Drag begins | `card: DataLogCard` |
| `drag_ended` | Drag ends | `card: DataLogCard` |
| `discovery_changed` | State changes | `card: DataLogCard, discovered: bool` |

---

## Visual Feedback

### Hover State

```gdscript
func _on_mouse_entered() -> void:
    if interaction_state == InteractionState.IDLE:
        interaction_state = InteractionState.HOVER
        _apply_hover_effect()

func _apply_hover_effect() -> void:
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(1.02, 1.02), 0.1)
    # Optional: glow shader
```

### Drag State

```gdscript
func _apply_drag_effect() -> void:
    # Lift effect
    scale = Vector2(lift_scale, lift_scale)
    modulate.a = drag_opacity

    # Optional: drop shadow
    $DropShadow.visible = true
```

### Snap Animation

```gdscript
func _animate_snap(target_pos: Vector2) -> void:
    var tween := create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)  # Slight overshoot
    tween.tween_property(self, "global_position", target_pos, 0.15)
```

---

## Constraints

### Board Bounds

Cards should stay within the board:

```gdscript
func _clamp_to_board(position: Vector2) -> Vector2:
    var board_rect := get_parent().get_rect()
    var half_size := size / 2

    position.x = clamp(position.x, half_size.x, board_rect.size.x - half_size.x)
    position.y = clamp(position.y, half_size.y, board_rect.size.y - half_size.y)

    return position
```

### Undiscovered Cards

Undiscovered cards cannot be dragged:

```gdscript
func _start_potential_drag(position: Vector2) -> void:
    if not discovered:
        return  # Can't drag undiscovered cards

    interaction_state = InteractionState.PRESSED
    press_start_position = position
```

---

## Touch Support

For Steam Deck and touch screens:

```gdscript
func _gui_input(event: InputEvent) -> void:
    # Handle touch as mouse
    if event is InputEventScreenTouch:
        var mouse_event := InputEventMouseButton.new()
        mouse_event.position = event.position
        mouse_event.pressed = event.pressed
        mouse_event.button_index = MOUSE_BUTTON_LEFT
        _handle_mouse_button(mouse_event)

    elif event is InputEventScreenDrag:
        var motion_event := InputEventMouseMotion.new()
        motion_event.position = event.position
        _handle_mouse_motion(motion_event)
```

---

## Debugging

### Visualize Drag State

```gdscript
func _draw() -> void:
    if interaction_state == InteractionState.DRAGGING:
        # Draw snap range
        draw_circle(Vector2.ZERO, snap_distance, Color(0, 1, 0, 0.2))
```

### Log Interactions

```gdscript
func _start_drag() -> void:
    print("Drag started: ", resource.title)
    # ...

func _end_drag() -> void:
    print("Drag ended at: ", global_position)
    # ...
```

---

## Common Issues

**Cards don't respond to clicks:**
- Check `mouse_filter` is `MOUSE_FILTER_STOP`
- Verify card is not behind another node

**Dragging feels laggy:**
- Ensure position update is in `_process`, not `_physics_process`
- Check for expensive operations in drag handler

**Snap doesn't work:**
- Verify pin positions are correct
- Check `snap_distance` is reasonable
- Ensure pins are in the `pins` array

**Click registers as drag:**
- Increase `drag_threshold`
- Check for mouse position jitter

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Click detection | Movement < threshold |
| Drag | Movement >= threshold |
| Snapping | Distance to nearest pin |
| Visual feedback | Scale, opacity, z-index |

The drag-drop system makes the board feel tactile. Cards should feel like real paper you're pinning to a cork board.

---

[← Back to Overview](overview.md) | [Next: String Physics →](string-physics.md)
