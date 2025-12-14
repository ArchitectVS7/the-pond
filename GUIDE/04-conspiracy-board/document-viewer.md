# Document Viewer

When players click a discovered card, the document viewer opens. It displays the full evidence text - corporate memos, scientific reports, witness statements. This chapter covers its implementation.

---

## The User Experience

1. Player clicks discovered card
2. Screen dims, viewer slides in
3. Full document displayed with title
4. Player reads at their own pace
5. ESC or click outside closes viewer

The viewer should feel like opening a case file - immersive but not intrusive.

---

## Structure (BOARD-009)

**File**: `conspiracy_board/scripts/document_viewer.gd`

```gdscript
# Document viewer scene structure
DocumentViewer (Control)
├── Background (ColorRect)       # Dim overlay
├── Panel (PanelContainer)       # Document container
│   ├── VBoxContainer
│   │   ├── CloseButton (Button)
│   │   ├── Title (Label)
│   │   ├── Separator (HSeparator)
│   │   └── ScrollContainer
│   │       └── Content (RichTextLabel)
└── AnimationPlayer
```

---

## Opening the Viewer

```gdscript
func show_document(log_resource: DataLogResource) -> void:
    current_document = log_resource

    # Set content
    $Panel/VBox/Title.text = log_resource.title
    $Panel/VBox/ScrollContainer/Content.text = log_resource.full_text

    # Reset scroll
    $Panel/VBox/ScrollContainer.scroll_vertical = 0

    # Animate in
    _play_open_animation()

    # Capture focus for accessibility
    $Panel/VBox/Content.grab_focus()
```

### Open Animation

```gdscript
func _play_open_animation() -> void:
    visible = true

    # Fade in background
    $Background.modulate.a = 0.0
    var bg_tween := create_tween()
    bg_tween.tween_property($Background, "modulate:a", 0.7, 0.2)

    # Slide in panel
    $Panel.position.y = get_viewport_rect().size.y
    var panel_tween := create_tween()
    panel_tween.set_ease(Tween.EASE_OUT)
    panel_tween.set_trans(Tween.TRANS_BACK)
    panel_tween.tween_property($Panel, "position:y", center_y, 0.3)
```

---

## Closing the Viewer

```gdscript
func close_viewer() -> void:
    _play_close_animation()
    await get_tree().create_timer(0.3).timeout
    visible = false
    emit_signal("viewer_closed")

func _input(event: InputEvent) -> void:
    if not visible:
        return

    # Close on ESC
    if event.is_action_pressed("ui_cancel"):
        close_viewer()
        get_viewport().set_input_as_handled()

    # Close on click outside panel
    if event is InputEventMouseButton and event.pressed:
        if not _is_inside_panel(event.position):
            close_viewer()
            get_viewport().set_input_as_handled()
```

---

## Content Formatting

### RichTextLabel

Using RichTextLabel allows formatting:

```gdscript
# Plain text
content.text = log_resource.full_text

# With BBCode
content.bbcode_enabled = true
content.text = "[b]CONFIDENTIAL[/b]\n\n" + log_resource.full_text
```

### Styling

```gdscript
# Theme overrides
content.add_theme_font_size_override("normal_font_size", 18)
content.add_theme_color_override("default_color", Color(0.9, 0.9, 0.85))
```

### Example Document

```
INTERCEPTED MEMO
From: R. Croakman, VP Operations
To: Executive Team
Re: Phase 2 Disposal

The EPA inspection is scheduled for next month.
We need to accelerate the "alternative disposal"
timeline. The pond site has capacity for another
50,000 gallons before it reaches the aquifer.

Cost savings: $2.3M annually.

Recommend we proceed. Plausible deniability
is maintained through our subsidiary structure.

- R.C.
```

---

## Scroll Behavior

### Basic Scrolling

```gdscript
# ScrollContainer handles this automatically
$Panel/VBox/ScrollContainer.scroll_vertical_enabled = true
```

### Scroll Position Memory

Remember where player was in each document:

```gdscript
var scroll_positions: Dictionary = {}

func show_document(log_resource: DataLogResource) -> void:
    # ... setup ...

    # Restore scroll position
    var scroll_pos := scroll_positions.get(log_resource.id, 0)
    $Panel/VBox/ScrollContainer.scroll_vertical = scroll_pos

func close_viewer() -> void:
    # Save scroll position
    scroll_positions[current_document.id] = $Panel/VBox/ScrollContainer.scroll_vertical

    # ... close ...
```

### Smooth Scrolling

```gdscript
func _scroll_to_top() -> void:
    var tween := create_tween()
    tween.tween_property(
        $Panel/VBox/ScrollContainer,
        "scroll_vertical",
        0,
        0.3
    )
```

---

## Tunable Parameters

| Parameter | Type | Default | Effect |
|-----------|------|---------|--------|
| `background_dim` | float | 0.7 | Overlay opacity |
| `open_duration` | float | 0.3 | Open animation time |
| `close_duration` | float | 0.2 | Close animation time |
| `panel_width` | float | 600 | Document width |
| `panel_height` | float | 500 | Document height |
| `font_size` | int | 18 | Text size |

---

## Accessibility (BOARD-010)

### Screen Reader Support

```gdscript
func show_document(log_resource: DataLogResource) -> void:
    # ... setup ...

    # Announce to screen reader
    $Panel/VBox/Content.grab_focus()

    # Set accessible description
    $Panel/VBox/Content.tooltip_text = log_resource.title
```

### Keyboard Navigation

```gdscript
func _input(event: InputEvent) -> void:
    if not visible:
        return

    # Scroll with arrow keys
    if event.is_action_pressed("ui_down"):
        $Panel/VBox/ScrollContainer.scroll_vertical += 50
    if event.is_action_pressed("ui_up"):
        $Panel/VBox/ScrollContainer.scroll_vertical -= 50

    # Page up/down
    if event.is_action_pressed("ui_page_down"):
        $Panel/VBox/ScrollContainer.scroll_vertical += 300
    if event.is_action_pressed("ui_page_up"):
        $Panel/VBox/ScrollContainer.scroll_vertical -= 300
```

### Text Scaling

Respect accessibility settings:
```gdscript
func _ready() -> void:
    var scale := AccessibilityManager.text_scale
    $Panel/VBox/Content.add_theme_font_size_override(
        "normal_font_size",
        int(base_font_size * scale)
    )
```

---

## Visual Polish

### Paper Texture

```gdscript
# In Panel style
var style := StyleBoxTexture.new()
style.texture = preload("res://assets/textures/paper.png")
$Panel.add_theme_stylebox_override("panel", style)
```

### Drop Shadow

```gdscript
# Panel shadow via shader or 9-patch
$Panel/Shadow.visible = true
```

### Reading Progress

```gdscript
func _process(_delta: float) -> void:
    if not visible:
        return

    var scroll := $Panel/VBox/ScrollContainer
    var progress := float(scroll.scroll_vertical) / max(1, scroll.get_v_scroll_bar().max_value)
    $Panel/ProgressBar.value = progress
```

---

## Integration

### With Conspiracy Board

```gdscript
# In conspiracy_board.gd
func _on_card_clicked(card: DataLogCard) -> void:
    if card.resource.discovered:
        $DocumentViewer.show_document(card.resource)

func _ready() -> void:
    $DocumentViewer.viewer_closed.connect(_on_viewer_closed)
```

### With Save System

```gdscript
# Track read documents
func show_document(log_resource: DataLogResource) -> void:
    # ... show ...

    # Mark as read
    if log_resource.id not in read_documents:
        read_documents.append(log_resource.id)
        emit_signal("document_read", log_resource)
```

---

## Debugging

### Test Long Documents

Create test documents with various lengths:
```gdscript
func _test_long_document() -> void:
    var test_log := DataLogResource.new()
    test_log.title = "Test Document"
    test_log.full_text = "Line\n".repeat(100)
    show_document(test_log)
```

### Test Animation

Slow down animations for debugging:
```gdscript
func _play_open_animation() -> void:
    Engine.time_scale = 0.25  # Slow motion
    # ... animation code ...
```

---

## Common Issues

**Document doesn't show:**
- Check `visible = true` is called
- Verify document has content
- Check z-index vs other UI

**Text is cut off:**
- Verify ScrollContainer settings
- Check Content minimum size
- Ensure RichTextLabel fit_content is correct

**Can't close with ESC:**
- Verify input handling priority
- Check `get_viewport().set_input_as_handled()`

**Scroll doesn't work:**
- Check ScrollContainer has correct size
- Verify content is taller than container
- Check mouse filter settings

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Open | Fade background, slide panel |
| Close | ESC key, click outside |
| Scroll | ScrollContainer, arrow keys |
| Accessibility | Focus management, text scaling |

The document viewer is where story happens. It should be comfortable to read, easy to close, and immersive enough to draw players into the conspiracy.

---

[← Back to String Physics](string-physics.md) | [Next: Accessibility →](accessibility.md)
