# The Pond - Developer's Manual

## Epic-003: Conspiracy Board Module - Tunable Parameters Reference

This document provides a comprehensive reference of all tunable parameters in the Conspiracy Board module for designers and developers.

---

## Module Overview

The Conspiracy Board module (`conspiracy_board/`) provides an interactive corkboard interface for discovering and connecting data logs in the game. Players can drag cards, snap them to pins, and view detailed information in a popup viewer.

**Key Features:**
- Drag-and-drop card positioning
- Magnetic pin snapping with physics
- String connections with elastic bezier curves
- Discovery system with progress tracking
- Document viewer with TL;DR toggle
- Full keyboard navigation
- Screen reader accessibility support

---

## ConspiracyBoard (Main Board Controller)

**Script:** `conspiracy_board/scripts/conspiracy_board.gd`
**Scene:** `conspiracy_board/scenes/ConspiracyBoard.tscn`

### Visual Appearance

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `vignette_strength` | float (0.0-1.0) | 0.2 | Edge darkening intensity for depth effect |
| `vignette_radius` | float (0.0-1.0) | 0.8 | Vignette start radius from center |

### Pin Snap System (BOARD-007)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `snap_distance` | float | 50.0 | Distance in pixels for magnetic snap to pin |
| `snap_animation_duration` | float | 0.1 | Duration of snap animation in seconds |
| `pin_positions` | Array[Vector2] | [9 positions] | Grid of pin locations on board |

### Audio/Visual Feedback (BOARD-010)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pulse_duration` | float | 0.2 | Duration of pulse animation on snap (seconds) |
| `pulse_scale` | float | 1.1 | Scale multiplier for pulse effect (1.1 = 10% larger) |

**Note:** AudioStreamPlayer for snap sound is placeholder. Assign audio file to enable sound.

### Progress Tracking (BOARD-013)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `progress_total` | int | 7 | Total number of discoverable data logs |

### Keyboard Navigation (BOARD-014)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `focus_border_width` | float | 3.0 | Width of focus border in pixels |
| `focus_border_color` | Color | YELLOW | Color of focus border for keyboard navigation |

**Keyboard Controls:**
- **Tab / Shift+Tab:** Cycle through cards
- **Arrow Keys:** Navigate between cards
- **Enter / Space:** Open selected card
- **Escape:** Close document viewer

---

## DataLogCard (Card Component)

**Script:** `conspiracy_board/scripts/data_log_card.gd`
**Scene:** `conspiracy_board/scenes/DataLogCard.tscn`

### Card Appearance

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `card_width` | int | 200 | Width of card in pixels |
| `card_height` | int | 150 | Height of card in pixels |
| `preview_max_chars` | int | 80 | Maximum characters in preview before truncation |
| `undiscovered_alpha` | float (0.0-1.0) | 0.3 | Opacity when card is undiscovered |

### Drag Settings (BOARD-006)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `drag_threshold` | float | 5.0 | Pixels of movement before drag activates |
| `drag_opacity` | float (0.0-1.0) | 0.8 | Opacity while dragging |

### Colors

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `discovered_color` | Color | (0.92, 0.88, 0.78) | Background color for discovered cards (beige) |
| `undiscovered_color` | Color | (0.3, 0.3, 0.3, 0.3) | Background color for undiscovered cards |
| `title_color` | Color | (0.1, 0.1, 0.1) | Title text color |
| `preview_color` | Color | (0.2, 0.2, 0.2) | Preview text color |

### Accessibility (BOARD-015)

Cards automatically update `accessibility_name` and `accessibility_description` based on discovery state.

---

## DocumentViewer (Popup Viewer)

**Script:** `conspiracy_board/scripts/document_viewer.gd`
**Scene:** `conspiracy_board/scenes/DocumentViewer.tscn`

### Viewer Dimensions (BOARD-011)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `viewer_width` | int | 600 | Width of viewer panel in pixels |
| `viewer_height` | int | 400 | Height of viewer panel in pixels |

### Animation Settings (BOARD-011)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `animation_duration` | float | 0.3 | Duration of open/close animations in seconds |
| `open_scale_overshoot` | float | 1.05 | Scale overshoot for bounce effect on open |

### Features (BOARD-012)

- **Toggle Button:** Switches between summary and full text
- **Click Outside:** Close viewer by clicking overlay
- **Escape Key:** Close viewer with keyboard
- **State Persistence:** Toggle state persists during session (resets on new document)

### Accessibility (BOARD-015)

Viewer includes accessibility properties for screen readers:
- Dialog name: "Document Viewer Dialog"
- Close button: "Close Document Viewer"
- Toggle button: Dynamic description based on current mode

---

## StringRenderer (Connection Lines)

**Script:** `conspiracy_board/scripts/string_renderer.gd`
**Scene:** `conspiracy_board/scenes/StringConnection.tscn`

### Visual Settings (BOARD-008)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `string_width` | float | 2.0 | Line thickness in pixels |
| `string_color` | Color | RED | Color of connection string |
| `string_segments` | int (4-100) | 20 | Number of bezier curve segments (higher = smoother) |

### Physics Settings (BOARD-009)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `string_stiffness` | float | 150.0 | Spring constant (higher = stiffer) |
| `string_damping` | float | 8.0 | Damping coefficient (higher = faster settle) |
| `settle_time` | float | 0.3 | Target settle time in seconds |
| `max_stretch` | float (1.0-3.0) | 1.5 | Maximum stretch ratio before wobble (1.5 = 50% stretch) |
| `physics_enabled` | bool | true | Enable/disable physics simulation |
| `bezier_curve_amount` | float | 50.0 | Base curve amount for control point offset |

**Performance:** Optimized for 10+ strings simultaneously. Average processing time tracked via `get_average_performance()`.

---

## DataLogResource (Data Model)

**Script:** `conspiracy_board/resources/DataLogResource.gd`

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier |
| `title` | String | Display title |
| `summary` | String | Short TL;DR text |
| `full_text` | String (multiline) | Full content |
| `discovered` | bool | Discovery state |
| `category` | String | Optional grouping tag |
| `connections` | Array[String] | Connection IDs to other logs |

### Methods

- `get_preview(max_chars: int = 80)` - Get truncated summary
- `discover()` - Mark as discovered
- `is_connected_to(other_id: String)` - Check connection
- `add_connection(other_id: String)` - Add connection
- `remove_connection(other_id: String)` - Remove connection

---

## Testing

All stories include comprehensive unit tests in `tests/`:

- `test_board_010_sound_visual.gd` - Audio/visual feedback
- `test_board_011_document_viewer.gd` - Popup viewer
- `test_board_012_toggle_text.gd` - TL;DR toggle
- `test_board_013_progress_tracking.gd` - Progress UI
- `test_board_014_keyboard_navigation.gd` - Keyboard controls
- `test_board_015_accessibility.gd` - Screen reader support

**Run tests:**
```bash
# Run all conspiracy board tests
godot --headless --script addons/gut/gut_cmdln.gd -gdir=tests -gprefix=test_board_

# Run specific test
godot --headless --script addons/gut/gut_cmdln.gd -gdir=tests -gtest=test_board_013_progress_tracking.gd
```

---

## Accessibility Notes (BOARD-015)

### Godot 4.2+ Features Used

The Conspiracy Board uses Godot 4.2+ accessibility properties:
- `accessibility_name` - Screen reader label
- `accessibility_description` - Screen reader description

### Current Limitations

As of Godot 4.2, screen reader support has the following limitations:
1. **Platform-specific:** Full support on Windows (NVDA/JAWS) and macOS (VoiceOver)
2. **Linux support:** Varies by distribution and screen reader (Orca)
3. **Focus management:** Manual focus system implemented via keyboard navigation
4. **Dynamic updates:** Accessibility descriptions update on state changes

### Future Improvements

When Godot adds native ARIA-like role support:
- Add `role="button"` to interactive cards
- Add `role="dialog"` to document viewer
- Add `aria-live` regions for progress updates

---

## Integration Example

```gdscript
# Create a conspiracy board
var board = ConspiracyBoard.new()
add_child(board)

# Configure tunable parameters
board.snap_distance = 75.0  # Larger snap radius
board.pulse_scale = 1.2     # More dramatic pulse
board.progress_total = 10   # 10 data logs to find

# Create and add a card
var card = DataLogCard.new()
var data = DataLogResource.new(
    "log-001",
    "Strange Signal",
    "A mysterious transmission detected...",
    "Full investigation report here...",
    false  # Starts undiscovered
)
card.data = data
board.add_card(card)

# Connect to discovery events
card.discovery_changed.connect(func(c, discovered):
    if discovered:
        print("New discovery: ", c.data.title)
)

# Create viewer for displaying details
var viewer = DocumentViewer.new()
add_child(viewer)

# Connect card clicks to viewer
card.card_clicked.connect(func(c):
    if c.is_discovered():
        viewer.show_document(c.data)
)
```

---

## Version History

- **v1.0** - Initial release (BOARD-004 through BOARD-009)
- **v1.1** - Added audio/visual feedback, document viewer, progress tracking, keyboard navigation, accessibility (BOARD-010 through BOARD-015)

---

## Support

For questions or issues, see project documentation or contact development team.
