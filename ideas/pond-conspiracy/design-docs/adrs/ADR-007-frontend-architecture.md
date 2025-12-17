# ADR-007: Frontend Architecture (UI & Conspiracy Board)

**Status**: Accepted
**Date**: 2025-12-13
**Decision Makers**: Chief Architect, Frontend Architect, UX Lead
**Related ADRs**: ADR-002 (System Architecture), ADR-006 (Tech Stack)

---

## Context

Pond Conspiracy has two distinct UI requirements:

1. **Game UI** (Combat HUD): Minimal, performance-critical (60fps)
2. **Conspiracy Board UI**: Rich, interactive, narrative-focused (8/10 user satisfaction requirement)

### Requirements from PRD

**Combat HUD (FR-001)**:
- HP display
- Timer (run duration)
- Pollution index meter (NEW in v0.2)
- Minimal visual clutter
- <16ms input lag

**Conspiracy Board (FR-002)**:
- Corkboard aesthetic (wood, pins, string)
- Drag-and-drop documents
- Red string physics (Bezier curves, 300ms animation, CI-2.1)
- TL;DR + full-text reading modes
- Accessibility (keyboard navigation, screen reader support)
- **8/10 satisfaction score** (Figma prototype required, CI-2.3)

**Accessibility (NFR-002)**:
- 3 colorblind modes (Deuteranopia, Protanopia, Tritanopia, CI-3.2)
- Text scaling (Small, Medium, Large)
- Screen shake toggle
- Rebindable controls

---

## Decision

### UI Framework: **Godot's Built-In UI System (Control Nodes)**

**Rationale**: Godot's UI is mature, performant, and integrated

**Key Node Types**:
- **Control**: Base UI element (anchors, margins, sizing)
- **Panel**: Containers with backgrounds
- **Label**: Text rendering
- **TextureRect**: Image display
- **Button**: Interactive buttons
- **MarginContainer**, **VBoxContainer**, **HBoxContainer**: Layout

---

### Architecture Pattern: **Scene-Based UI Components**

**Structure**:
```
UI Hierarchy:
├── Combat HUD (Canvas Layer)
│   ├── HP Bar (ProgressBar)
│   ├── Timer Label (Label)
│   ├── Pollution Index (Custom Control)
│   └── Pause Menu (Popup)
│
├── Conspiracy Board (Full-Screen Scene)
│   ├── Corkboard Background (TextureRect)
│   ├── Document Container (Control)
│   │   ├── DataLog_01 (Custom draggable scene)
│   │   ├── DataLog_02
│   │   └── ... (7 total)
│   ├── String Renderer (Control with _draw override)
│   ├── Document Viewer Popup (Panel)
│   └── Progress UI (HBoxContainer)
│
└── Menus (Separate scenes)
    ├── Main Menu (VBoxContainer)
    ├── Settings Menu (TabContainer)
    └── Death Screen (Panel)
```

---

## Combat HUD Design

### Layout (Anchored Corners)

```
┌─────────────────────────────────────┐
│ HP ████████░░ 80/100       Timer: 5:42 │
│                  Pollution: ██░░░░ 40%│
│                                       │
│          [GAMEPLAY AREA]              │
│                                       │
│                                       │
│              [ESC = Pause]            │
└───────────────────────────────────────┘
```

**Implementation**:
```gdscript
# combat/ui/CombatHUD.tscn
extends CanvasLayer

@onready var hp_bar = $HPBar
@onready var timer_label = $TimerLabel
@onready var pollution_meter = $PollutionMeter

func _process(delta):
    # Update at 60fps
    timer_label.text = "Timer: " + format_time(GameManager.run_timer)
    hp_bar.value = Player.current_hp
    pollution_meter.value = Player.get_pollution_level()

func format_time(seconds: float) -> String:
    var minutes = int(seconds / 60)
    var secs = int(seconds) % 60
    return "%d:%02d" % [minutes, secs]
```

**Performance Optimization**:
- Update UI at 60fps (lightweight, no impact on gameplay)
- Use `_process()` for real-time updates
- Avoid complex calculations in UI code (read from Player singleton)

---

## Conspiracy Board Design

### Visual Aesthetic

**Corkboard Background**:
- Wood texture (warm brown, grain visible)
- Subtle vignette (darker edges)
- Pushpins (red, yellow, green variety)

**Documents**:
- Aged paper texture (slight yellowing)
- Typewriter font for text (monospace, terminal feel)
- Coffee stains, creases (subtle details)

**Red String**:
- Bright red (#FF3333)
- 3px thick Bezier curves
- Subtle shadow for depth

---

### Interaction Model

**Drag-and-Drop**:
```gdscript
# conspiracy_board/DataLog.gd
extends Control

var is_dragging = false
var drag_offset = Vector2.ZERO

func _gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                # Start drag
                is_dragging = true
                drag_offset = get_global_mouse_position() - global_position
            else:
                # End drag (snap to pin if near one)
                is_dragging = false
                check_pin_snap()

    elif event is InputEventMouseMotion and is_dragging:
        # Update position while dragging
        global_position = get_global_mouse_position() - drag_offset

func check_pin_snap():
    var pins = get_tree().get_nodes_in_group("pins")
    for pin in pins:
        if global_position.distance_to(pin.global_position) < 50:
            # Snap to pin
            global_position = pin.global_position
            EventBus.emit_signal("document_pinned", self.data_log_id, pin.id)
            play_pin_sound()
            break
```

---

### String Physics (Bezier Curves)

**Requirements from PRD (CI-2.1)**:
- Bezier curves with subtle elasticity
- 300ms animation with easing
- Satisfying "snap" sound when connection locks

**Implementation**:
```gdscript
# conspiracy_board/StringRenderer.gd
extends Control

var connections = []  # Array of {from: Vector2, to: Vector2, progress: float}

func _draw():
    for conn in connections:
        # Bezier curve with control points
        var start = conn.from
        var end = conn.to
        var mid = (start + end) / 2.0
        var control1 = Vector2(mid.x, start.y)
        var control2 = Vector2(mid.x, end.y)

        # Draw curve
        draw_bezier(start, control1, control2, end, Color.RED, 3.0)

func add_connection(from_pos: Vector2, to_pos: Vector2):
    var conn = {
        "from": from_pos,
        "to": to_pos,
        "progress": 0.0  # For animation
    }
    connections.append(conn)

    # Animate string appearing
    var tween = create_tween()
    tween.tween_property(conn, "progress", 1.0, 0.3) \
         .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

    tween.finished.connect(_on_connection_complete.bind(conn))

func _on_connection_complete(conn):
    # Play satisfying snap sound
    AudioManager.play_sfx("string_snap")
    # Visual feedback (brief pulse)
    flash_connection(conn)
```

**Easing Function**: `TRANS_ELASTIC` gives slight "bounce" at end (300ms duration)

---

### Document Viewer (Popup)

**Two Modes**:
1. **TL;DR**: 1-sentence summary (always visible on hover)
2. **Full Text**: Complete document with citations

**Implementation**:
```gdscript
# conspiracy_board/DocumentViewer.tscn
extends Panel

@onready var title_label = $VBox/TitleLabel
@onready var summary_label = $VBox/SummaryLabel
@onready var full_text = $VBox/ScrollContainer/FullText
@onready var citation_label = $VBox/CitationLabel

var current_log: DataLog

func show_document(log: DataLog):
    current_log = log
    title_label.text = log.title
    summary_label.text = log.tldr
    full_text.text = log.full_text
    citation_label.text = log.citation  # From CI-2.2 (NGO-reviewed)

    popup_centered()
```

**Keyboard Navigation**:
```gdscript
func _input(event):
    if event.is_action_pressed("ui_cancel"):  # ESC key
        hide()
    elif event.is_action_pressed("ui_accept"):  # Enter key
        if current_log:
            # Pin this document to center board
            pin_to_center()
```

---

### Accessibility Features

#### Colorblind Modes (CI-3.2)

**Implementation**:
```gdscript
# shared/accessibility_manager.gd
enum ColorblindMode { NONE, DEUTERANOPIA, PROTANOPIA, TRITANOPIA }

var current_mode = ColorblindMode.NONE

func apply_colorblind_filter(mode: ColorblindMode):
    match mode:
        ColorblindMode.DEUTERANOPIA:
            # Red-weak: Shift reds to yellows/browns
            RenderingServer.global_shader_parameter_set("colorblind_matrix",
                Basis(0.625, 0.375, 0.0,  # Deuteranopia matrix
                      0.7, 0.3, 0.0,
                      0.0, 0.3, 0.7))
        ColorblindMode.PROTANOPIA:
            # Red-blind: Similar to Deuteranopia but stronger
            # ... (matrix values)
        ColorblindMode.TRITANOPIA:
            # Blue-blind: Shift blues to greens
            # ... (matrix values)
```

**Testing**: Use Godot's shader preview + online colorblind simulators

---

#### Text Scaling

**Implementation**:
```gdscript
# shared/accessibility_manager.gd
enum TextSize { SMALL, MEDIUM, LARGE }

func set_text_size(size: TextSize):
    var scale_factor = 1.0
    match size:
        TextSize.SMALL: scale_factor = 0.8
        TextSize.MEDIUM: scale_factor = 1.0
        TextSize.LARGE: scale_factor = 1.3

    # Apply to all labels
    get_tree().call_group("scalable_text", "set_scale", Vector2(scale_factor, scale_factor))
```

**Responsive Layout**: Use `MarginContainer` to prevent text overflow

---

#### Screen Shake Toggle

**Implementation**:
```gdscript
# shared/screen_shake.gd
var shake_enabled: bool = true

func shake_camera(intensity: float, duration: float):
    if not shake_enabled:
        return  # Skip shake if disabled

    var camera = get_viewport().get_camera_2d()
    var tween = create_tween()
    # ... shake logic
```

**Settings Menu**: Toggle via checkbox in Settings → Accessibility

---

## State Management (UI)

**Pattern**: Reactive UI updates via signals

**Example** (Pollution Index UI):
```gdscript
# combat/ui/PollutionMeter.gd
extends ProgressBar

func _ready():
    EventBus.connect("mutation_selected", self, "_on_mutation_selected")

func _on_mutation_selected(mutation_data):
    if mutation_data.is_pollution_type:
        # Increment pollution level
        value += 1
        update_color()

func update_color():
    # Green (0-30%), Yellow (31-60%), Red (61-100%)
    if value <= 30:
        modulate = Color.GREEN
    elif value <= 60:
        modulate = Color.YELLOW
    else:
        modulate = Color.RED
```

---

## Component Reusability

**Custom UI Components** (for consistency):

1. **FrogButton** (themed button):
```gdscript
# shared/ui/FrogButton.tscn
extends Button
# Custom hover/press animations
# Consistent sound effects
# Thematic styling
```

2. **DataLogCard** (draggable document):
```gdscript
# conspiracy_board/DataLogCard.tscn
extends Panel
# Drag-and-drop logic
# Hover tooltips (TL;DR)
# Pin snap detection
```

3. **PollutionMeter** (custom progress bar):
```gdscript
# combat/ui/PollutionMeter.tscn
extends ProgressBar
# Color-coded (green/yellow/red)
# Tooltip on hover
# Animated fill
```

---

## Consequences

### Positive

✅ **Godot-native**: No external UI framework needed
✅ **Performant**: 60fps HUD with zero UI lag
✅ **Scene-based**: Reusable UI components
✅ **Accessible**: Colorblind modes, text scaling, keyboard nav
✅ **Testable**: UI scenes can be loaded in isolation
✅ **Flexible**: Easy to iterate on layouts

### Negative

❌ **Limited styling**: Godot's theming less powerful than CSS
❌ **Manual layout**: No flexbox/grid (must use containers)
❌ **Less tooling**: No visual UI builder as polished as Unity's

### Neutral

🔷 **Custom components needed**: Some UI widgets require custom scripts (acceptable)
🔷 **Figma prototype required**: Additional design step (mitigates UX risk per CI-2.3)

---

## Alternatives Considered

### Alternative 1: HTML5 UI (WebView)

**Rejected**: Adds complexity, poor performance, not idiomatic for Godot

### Alternative 2: ImGui (Immediate Mode GUI)

**Rejected**: C++ dependency, not suitable for game UI (debug tools only)

### Alternative 3: Custom Renderer

**Rejected**: Reinventing wheel, Godot's UI is sufficient

---

## Related Decisions

- **ADR-002**: System Architecture (scene-based modules)
- **ADR-003**: Communication Patterns (EventBus for UI updates)
- **ADR-006**: Technology Stack (Godot engine)

---

## Implementation Checklist

### Week 0-1 (Figma Prototype)

- [ ] Design conspiracy board mockup in Figma
- [ ] Create clickable prototype (drag-drop simulation)
- [ ] Recruit 10 target users for testing
- [ ] Achieve 8/10 satisfaction score (CI-2.3)

### Week 5-6 (Conspiracy Board Implementation)

- [ ] Corkboard background art (pixel art, 1920x1080)
- [ ] 7 data log documents (content + NGO review, CI-2.2)
- [ ] Drag-and-drop implementation (DataLog.gd script)
- [ ] String physics (Bezier curves, 300ms animation, CI-2.1)
- [ ] Document viewer popup (TL;DR + full text modes)

### Week 9 (Accessibility & Polish)

- [ ] 3 colorblind modes (shader implementation, CI-3.2)
- [ ] Text scaling (3 sizes)
- [ ] Screen shake toggle
- [ ] Pollution index meter (NEW, 1 day, NEW-1)

---

**Approved By**: ✅ Chief Architect, Frontend Architect, UX Lead

**Final ADR**: All 7 ADRs complete. Next: Architecture Overview Document.
