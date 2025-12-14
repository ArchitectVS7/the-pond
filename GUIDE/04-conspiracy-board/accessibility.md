# Conspiracy Board Accessibility

The conspiracy board must be usable by players with various accessibility needs. This chapter covers screen reader support, keyboard navigation, and visual accommodations.

---

## Accessibility Requirements

Per PRD NFR-002, the game must support:
- Screen reader navigation
- Keyboard-only interaction
- Colorblind-friendly visuals
- Text scaling

The conspiracy board is interaction-heavy, making accessibility particularly important.

---

## Screen Reader Support (BOARD-010)

### Accessible Names

Every interactive element needs an accessible name:

```gdscript
# Data log card
func _ready() -> void:
    # Set accessible name
    access_name = resource.title if resource.discovered else "Undiscovered evidence"

    # Set accessible description
    access_description = resource.summary if resource.discovered else "Evidence not yet found"
```

### Focus Management

```gdscript
# When board opens
func _on_board_opened() -> void:
    # Focus first discovered card
    var first_card := _get_first_discovered_card()
    if first_card:
        first_card.grab_focus()
    else:
        $HelpText.grab_focus()  # Focus instructions if no cards
```

### Announcements

Announce important state changes:

```gdscript
func discover_log(log_id: String) -> void:
    var card := _get_card(log_id)
    card.resource.discovered = true

    # Announce to screen reader
    _announce("New evidence discovered: " + card.resource.title)

func create_connection(card_a: DataLogCard, card_b: DataLogCard) -> void:
    # ... create connection ...

    _announce("Connected: %s to %s" % [card_a.resource.title, card_b.resource.title])

func _announce(text: String) -> void:
    # Use accessibility API or aria-live equivalent
    AccessibilityManager.announce(text)
```

---

## Keyboard Navigation

### Focus Order

Cards should be navigable in logical order:

```gdscript
func _ready() -> void:
    # Set focus neighbors based on grid position
    for i in range(cards.size()):
        var card := cards[i]

        # Left/Right navigation
        if i > 0:
            card.focus_neighbor_left = cards[i - 1].get_path()
        if i < cards.size() - 1:
            card.focus_neighbor_right = cards[i + 1].get_path()

        # Up/Down navigation (assuming grid)
        var cols := 5
        if i >= cols:
            card.focus_neighbor_top = cards[i - cols].get_path()
        if i + cols < cards.size():
            card.focus_neighbor_bottom = cards[i + cols].get_path()
```

### Keyboard Controls

| Key | Action |
|-----|--------|
| Tab | Move to next card |
| Shift+Tab | Move to previous card |
| Arrow keys | Navigate grid |
| Enter/Space | Open document viewer |
| C | Create connection (from focused card) |
| X | Remove connection |
| Escape | Close viewer / Exit board |

### Implementation

```gdscript
func _input(event: InputEvent) -> void:
    if not visible:
        return

    var focused := get_viewport().gui_get_focus_owner()
    if focused is DataLogCard:
        _handle_card_input(focused, event)

func _handle_card_input(card: DataLogCard, event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):  # Enter/Space
        if card.resource.discovered:
            $DocumentViewer.show_document(card.resource)
        get_viewport().set_input_as_handled()

    if event.is_action_pressed("create_connection"):  # C key
        _start_connection_mode(card)
        get_viewport().set_input_as_handled()
```

---

## Connection Mode (Keyboard)

Creating connections without a mouse:

```gdscript
var connection_mode := false
var connection_start_card: DataLogCard = null

func _start_connection_mode(card: DataLogCard) -> void:
    if not card.resource.discovered:
        _announce("Cannot connect undiscovered evidence")
        return

    connection_mode = true
    connection_start_card = card
    _announce("Connection mode. Navigate to target card and press C to connect.")

func _handle_connection_mode_input(card: DataLogCard, event: InputEvent) -> void:
    if not connection_mode:
        return

    if event.is_action_pressed("create_connection"):
        if card == connection_start_card:
            _announce("Cannot connect card to itself")
            return

        if card.resource.discovered:
            create_connection(connection_start_card, card)
            connection_mode = false
            connection_start_card = null
        else:
            _announce("Cannot connect to undiscovered evidence")

    if event.is_action_pressed("ui_cancel"):
        connection_mode = false
        connection_start_card = null
        _announce("Connection cancelled")
```

---

## Visual Accessibility

### Colorblind-Friendly Connections

Don't rely on color alone:

```gdscript
# Bad: Only color differentiates
discovered_color = Color.GREEN
undiscovered_color = Color.RED

# Good: Pattern + color
# Discovered cards have solid border
# Undiscovered cards have dashed border
func _draw_card_border(card: DataLogCard) -> void:
    if card.resource.discovered:
        draw_rect(rect, border_color, false, 2.0)
    else:
        _draw_dashed_rect(rect, border_color)
```

### String Connection Colors

Use shape in addition to color:

```gdscript
# Connections between different categories use different patterns
func _get_connection_style(card_a: DataLogCard, card_b: DataLogCard) -> Dictionary:
    var style := {
        "color": string_color,
        "width": 2.0,
        "pattern": "solid"
    }

    # Same category: solid line
    # Different category: dashed line
    if card_a.resource.category != card_b.resource.category:
        style.pattern = "dashed"

    return style
```

### High Contrast Mode

```gdscript
func apply_high_contrast() -> void:
    # Increase contrast for all elements
    $Background.color = Color.BLACK
    card_background_color = Color.WHITE
    card_text_color = Color.BLACK
    string_color = Color.YELLOW  # High visibility
```

---

## Text Scaling

### Respecting User Settings

```gdscript
func _ready() -> void:
    _apply_text_scale()
    AccessibilityManager.text_scale_changed.connect(_apply_text_scale)

func _apply_text_scale() -> void:
    var scale := AccessibilityManager.text_scale  # 1.0 to 2.0

    # Scale card text
    for card in cards:
        card.title_label.add_theme_font_size_override(
            "font_size",
            int(base_title_size * scale)
        )
        card.preview_label.add_theme_font_size_override(
            "font_size",
            int(base_preview_size * scale)
        )

    # Scale document viewer
    $DocumentViewer.apply_text_scale(scale)
```

### Dynamic Card Sizing

Cards may need to grow with text:

```gdscript
func _apply_text_scale() -> void:
    var scale := AccessibilityManager.text_scale

    # Scale card dimensions
    var new_width := int(base_card_width * scale)
    var new_height := int(base_card_height * scale)

    for card in cards:
        card.custom_minimum_size = Vector2(new_width, new_height)
```

---

## Focus Indicators

Visible focus is required for keyboard users:

```gdscript
# In card theme
var focus_style := StyleBoxFlat.new()
focus_style.border_width_left = 3
focus_style.border_width_right = 3
focus_style.border_width_top = 3
focus_style.border_width_bottom = 3
focus_style.border_color = Color.CYAN  # High visibility
add_theme_stylebox_override("focus", focus_style)
```

### Animated Focus

```gdscript
func _process(_delta: float) -> void:
    if has_focus():
        # Pulsing outline
        var pulse := (sin(Time.get_ticks_msec() * 0.005) + 1) / 2
        var color := Color.CYAN.lerp(Color.WHITE, pulse)
        $FocusOutline.modulate = color
        $FocusOutline.visible = true
    else:
        $FocusOutline.visible = false
```

---

## Reduced Motion

Some users are sensitive to motion:

```gdscript
func _play_open_animation() -> void:
    if AccessibilityManager.reduce_motion:
        # Skip animation, just show
        visible = true
        return

    # Normal animation
    # ...

func _animate_string() -> void:
    if AccessibilityManager.reduce_motion:
        # Static line instead of physics
        _draw_straight_line()
        return

    # Normal physics
    # ...
```

---

## Testing Accessibility

### Manual Testing Checklist

```markdown
## Accessibility Testing - Conspiracy Board

### Screen Reader
- [ ] All cards have accessible names
- [ ] Focus moves logically with Tab
- [ ] State changes are announced
- [ ] Document content is readable

### Keyboard
- [ ] Can navigate to all cards
- [ ] Can open document viewer
- [ ] Can create connections
- [ ] Can close viewer with ESC

### Visual
- [ ] Text readable at 200% scale
- [ ] Colors distinguishable (colorblind sim)
- [ ] Focus indicator visible
- [ ] High contrast mode works

### Motion
- [ ] Reduced motion respected
- [ ] Animations can be skipped
```

### Automated Testing

```gdscript
func test_accessibility_names() -> void:
    for card in cards:
        assert_not_empty(card.access_name, "Card missing accessible name")

func test_focus_order() -> void:
    var prev_card: DataLogCard = null
    for card in cards:
        if prev_card:
            assert_eq(card.focus_neighbor_left, prev_card.get_path())
        prev_card = card
```

---

## Integration with AccessibilityManager

The board should respect global accessibility settings:

```gdscript
func _ready() -> void:
    # Connect to accessibility changes
    AccessibilityManager.settings_changed.connect(_on_accessibility_changed)
    _apply_accessibility_settings()

func _on_accessibility_changed() -> void:
    _apply_accessibility_settings()

func _apply_accessibility_settings() -> void:
    _apply_text_scale()
    _apply_colorblind_mode()
    _apply_high_contrast()
    _apply_reduced_motion()
```

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Screen reader | Accessible names, announcements |
| Keyboard | Tab navigation, shortcuts |
| Visual | Colorblind-friendly, high contrast |
| Text scaling | Dynamic font sizes |
| Motion | Reduced motion option |

Accessibility isn't optional - it's part of the game. The conspiracy board should be fully usable regardless of how players interact with it.

---

[← Back to Document Viewer](document-viewer.md) | [Back to Overview](overview.md)
