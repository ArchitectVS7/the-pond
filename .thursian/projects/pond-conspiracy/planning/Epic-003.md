# EPIC-003: Conspiracy Board UI - Development Plan

## Overview

**Epic**: EPIC-003 (Conspiracy Board UI)
**Release Phase**: MVP
**Priority**: P0 (CRITICAL - Core differentiator)
**Dependencies**: None (parallel to combat)
**Estimated Effort**: XL (2 weeks)
**PRD Requirements**: FR-002, CI-2.1, CI-2.2, CI-2.3

**Description**: Corkboard UI with drag-drop documents, Bezier string physics, TL;DR/full-text modes.

---

## Automated Workflow Protocol

### Before Each Story
1. **READ THIS PLAN** for re-alignment before starting
2. Verify dependencies from previous stories are complete
3. Check DEVELOPERS_MANUAL.md for any tunable parameters from prior work

### Story Completion Criteria
- ✅ All tests pass (adversarial workflow complete)
- ✅ Tunable parameters documented in DEVELOPERS_MANUAL.md
- ✅ No human sign-off required - proceed immediately to next story

### Blocker Handling
- If a story cannot be completed due to blockers or human-required actions:
  - **SKIP** the blocked steps
  - **NOTE** in DEVELOPERS_MANUAL.md under "Blocked Steps" section
  - **PROCEED** to next story

---

## Stories

### BOARD-001: figma-prototype-creation
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Figma mockup of conspiracy board created
- [ ] Shows corkboard background, cards, strings
- [ ] Interactive prototype for user testing
- [ ] Document flow for TL;DR vs full-text

**Implementation Steps**:
1. Read plan for re-alignment
2. Create Figma file with board layout
3. Design card component (front/back)
4. Design string connection visualization
5. Export reference images for implementation

**Test Cases**: N/A (design deliverable)

**Tunable Parameters**: None (design phase)

**Potential Blockers**:
- [ ] No Figma access → SKIP, note in DEVELOPERS_MANUAL.md, proceed with wireframe in-engine

---

### BOARD-002: recruit-10-testers-validation
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] 10 testers recruited for UI validation
- [ ] Testing protocol documented
- [ ] Feedback collection method defined

**Implementation Steps**:
1. Read plan for re-alignment
2. Define tester criteria
3. Create feedback form
4. Recruit testers (Discord, social media)

**Test Cases**: N/A (recruitment task)

**Potential Blockers**:
- [ ] Insufficient testers → SKIP, note minimum viable count in DEVELOPERS_MANUAL.md

---

### BOARD-003: achieve-8of10-satisfaction
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Conduct user testing with prototype
- [ ] 8/10 testers rate satisfaction ≥4/5
- [ ] Iterate on feedback if needed

**Implementation Steps**:
1. Read plan for re-alignment
2. Send prototype to testers
3. Collect feedback via form
4. Analyze results, iterate if needed

**Potential Blockers**:
- [ ] Testing dependent on BOARD-001, BOARD-002 → SKIP if blocked, note in DEVELOPERS_MANUAL.md

---

### BOARD-004: corkboard-background-art-1920x1080
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] Corkboard texture at 1920x1080
- [ ] Warm brown tones matching noir aesthetic
- [ ] Push-pin holes visible texture
- [ ] Edge shadows for depth

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `conspiracy_board/assets/corkboard_bg.png`
3. Set up TextureRect in scene
4. Apply subtle vignette shader (optional)

**Test Cases**:
- `test_corkboard_loads` - Texture loads without error
- `test_corkboard_dimensions` - Correct resolution

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `vignette_strength` | float | 0.2 | Edge darkening intensity |
| `vignette_radius` | float | 0.8 | Vignette start radius |

**Potential Blockers**:
- [ ] Art assets unavailable → Use placeholder solid color, note in DEVELOPERS_MANUAL.md

---

### BOARD-005: data-log-card-component
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] DataLogCard scene created
- [ ] Card has title, preview text, full content
- [ ] Card visual matches paper/document aesthetic
- [ ] Cards can be discovered/undiscovered state

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `conspiracy_board/scenes/DataLogCard.tscn`
3. Add Control-based layout (Panel, Labels)
4. Implement `conspiracy_board/scripts/data_log_card.gd`
5. Define DataLogResource for card data

**Test Cases**:
- `test_card_displays_title` - Title renders correctly
- `test_card_shows_preview` - Preview text truncated
- `test_card_discovered_state` - Visual change on discovery

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `card_width` | int | 200 | Card width in pixels |
| `card_height` | int | 150 | Card height in pixels |
| `preview_max_chars` | int | 80 | Characters before truncation |
| `undiscovered_alpha` | float | 0.3 | Opacity when undiscovered |

---

### BOARD-006: drag-drop-interaction-system
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] Cards can be dragged with mouse
- [ ] Cards snap to release position
- [ ] Drag preview shows card moving
- [ ] Z-index updates (dragged card on top)

**Implementation Steps**:
1. Read plan for re-alignment
2. Implement `_gui_input()` for drag detection
3. Track drag offset from click point
4. Update position during `_process()` while dragging
5. Handle drop with position validation

**Test Cases**:
- `test_card_drag_starts` - Mouse down initiates drag
- `test_card_follows_mouse` - Position tracks cursor
- `test_card_drops` - Mouse up ends drag
- `test_card_z_order` - Dragged card renders on top

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `drag_threshold` | float | 5.0 | Pixels before drag activates |
| `drag_opacity` | float | 0.8 | Opacity while dragging |

---

### BOARD-007: pin-snap-detection-50px
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Pin locations defined on corkboard
- [ ] Cards snap to nearest pin within 50px
- [ ] Visual feedback on snap
- [ ] Cards stay at pin positions

**Implementation Steps**:
1. Read plan for re-alignment
2. Define pin positions as Array[Vector2]
3. On drop, check distance to each pin
4. If within `snap_distance`, snap to pin
5. Play snap sound (placeholder or muted)

**Test Cases**:
- `test_snap_within_threshold` - Card snaps at 49px
- `test_no_snap_beyond_threshold` - Card stays at 51px
- `test_snap_to_nearest` - Chooses closest pin

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `snap_distance` | float | 50.0 | Snap radius in pixels |
| `snap_animation_duration` | float | 0.1 | Snap tween duration |

---

### BOARD-008: bezier-string-renderer
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] Strings connect two cards/pins
- [ ] Bezier curve for natural arc
- [ ] String color can be configured
- [ ] Anti-aliased rendering

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `conspiracy_board/scripts/string_renderer.gd`
3. Extend Line2D or use `_draw()` with Bezier
4. Calculate control points for curve
5. Update on connected card movement

**Test Cases**:
- `test_string_connects_points` - Start/end correct
- `test_string_has_curve` - Not a straight line
- `test_string_updates_on_move` - Redraws when cards move

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `string_width` | float | 2.0 | Line thickness |
| `string_color` | Color | Color.RED | Default string color |
| `bezier_curve_amount` | float | 50.0 | Control point offset for arc |
| `string_segments` | int | 20 | Bezier subdivision quality |

---

### BOARD-009: string-physics-300ms-elastic
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] String has elastic physics when stretched
- [ ] 300ms settle time after release
- [ ] Bounce/wobble effect on connection
- [ ] Performance OK with 10+ strings

**Implementation Steps**:
1. Read plan for re-alignment
2. Add velocity/spring simulation to string
3. Apply damping for 300ms settle
4. Update Bezier control points based on physics

**Test Cases**:
- `test_string_stretches` - Longer when cards apart
- `test_string_settles_300ms` - Stable within threshold
- `test_string_bounces` - Oscillation on connect

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `string_stiffness` | float | 150.0 | Spring constant |
| `string_damping` | float | 8.0 | Oscillation decay |
| `settle_time` | float | 0.3 | Target settle duration |
| `max_stretch` | float | 1.5 | Max stretch ratio (150%) |

---

### BOARD-010: string-snap-sound-visual
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Sound plays when string connects
- [ ] Visual flash/pulse on connection
- [ ] Satisfying feedback moment

**Implementation Steps**:
1. Read plan for re-alignment
2. Add AudioStreamPlayer to string scene
3. Trigger sound on `connect()` call
4. Add AnimationPlayer for pulse effect

**Test Cases**:
- `test_snap_plays_sound` - Audio triggered
- `test_snap_visual_pulse` - Animation plays

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `snap_sound_volume_db` | float | -6.0 | Sound volume |
| `pulse_duration` | float | 0.2 | Visual feedback time |
| `pulse_scale` | float | 1.1 | Scale increase on pulse |

**Potential Blockers**:
- [ ] Audio assets unavailable → Use placeholder/muted, note in DEVELOPERS_MANUAL.md

---

### BOARD-011: document-viewer-popup
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Click card opens full document view
- [ ] Popup centered on screen
- [ ] Close button or click-outside dismisses
- [ ] Scroll for long documents

**Implementation Steps**:
1. Read plan for re-alignment
2. Create `conspiracy_board/scenes/DocumentViewer.tscn`
3. Panel with ScrollContainer, RichTextLabel
4. Implement show/hide with tween
5. Handle input for close

**Test Cases**:
- `test_viewer_opens_on_click` - Single-click opens
- `test_viewer_shows_content` - Full text displayed
- `test_viewer_closes` - Dismiss works

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `viewer_width` | int | 600 | Popup width |
| `viewer_height` | int | 400 | Popup height |
| `open_duration` | float | 0.2 | Animation time |
| `background_dim` | float | 0.5 | Background darken amount |

---

### BOARD-012: tldr-fulltext-toggle
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Toggle button switches TL;DR / Full Text
- [ ] TL;DR shows summary paragraph
- [ ] Full Text shows complete document
- [ ] State persists during session

**Implementation Steps**:
1. Read plan for re-alignment
2. Add toggle button to DocumentViewer
3. DataLogResource has `summary` and `full_text` fields
4. Swap displayed content on toggle

**Test Cases**:
- `test_toggle_switches_content` - Content changes
- `test_tldr_shorter` - Summary < full text
- `test_state_persists` - Closing/reopening keeps mode

**Tunable Parameters**: None (UI toggle)

---

### BOARD-013: progress-tracking-ui-x-of-7
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Progress label shows "X of 7 discovered"
- [ ] Updates when new document found
- [ ] Position fixed on board (corner)

**Implementation Steps**:
1. Read plan for re-alignment
2. Add Label to conspiracy board scene
3. Connect to discovery signals
4. Update text on signal

**Test Cases**:
- `test_progress_starts_zero` - "0 of 7" initially
- `test_progress_increments` - Discovery updates count

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `progress_total` | int | 7 | Total documents to discover |

---

### BOARD-014: keyboard-navigation-accessibility
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Tab cycles through cards
- [ ] Enter opens selected card
- [ ] Arrow keys navigate between pins
- [ ] Escape closes viewer

**Implementation Steps**:
1. Read plan for re-alignment
2. Implement focus system for cards
3. Handle keyboard input in board controller
4. Visual focus indicator on cards

**Test Cases**:
- `test_tab_cycles_cards` - Focus moves through cards
- `test_enter_opens_viewer` - Keyboard activation works
- `test_escape_closes` - Dismiss via keyboard

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `focus_border_width` | float | 3.0 | Focus indicator thickness |
| `focus_border_color` | Color | Color.YELLOW | Focus indicator color |

---

### BOARD-015: screen-reader-support
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Cards have accessible names
- [ ] State announced (discovered/undiscovered)
- [ ] Connection relationships described
- [ ] Works with Godot's built-in accessibility

**Implementation Steps**:
1. Read plan for re-alignment
2. Set `accessibility_name` on cards
3. Set `accessibility_description` with state
4. Test with screen reader if available

**Test Cases**:
- `test_cards_have_accessible_names` - Name property set
- `test_state_described` - Description includes state

**Potential Blockers**:
- [ ] Godot 4.2 accessibility limited → Note limitations in DEVELOPERS_MANUAL.md

---

## Files to Create

| File | Purpose |
|------|---------|
| `conspiracy_board/scenes/ConspiracyBoard.tscn` | Main board scene |
| `conspiracy_board/scenes/DataLogCard.tscn` | Card component |
| `conspiracy_board/scenes/DocumentViewer.tscn` | Popup viewer |
| `conspiracy_board/scenes/StringConnection.tscn` | String visual |
| `conspiracy_board/scripts/conspiracy_board.gd` | Board controller |
| `conspiracy_board/scripts/data_log_card.gd` | Card logic |
| `conspiracy_board/scripts/document_viewer.gd` | Viewer logic |
| `conspiracy_board/scripts/string_renderer.gd` | String rendering |
| `conspiracy_board/resources/DataLogResource.gd` | Card data resource |
| `conspiracy_board/assets/corkboard_bg.png` | Background texture |
| `test/unit/test_conspiracy_board.gd` | Board tests |
| `test/unit/test_data_log_card.gd` | Card tests |
| `test/unit/test_string_physics.gd` | String tests |

---

## Dependencies Graph

```
BOARD-001 (figma) → BOARD-002 (testers) → BOARD-003 (validation)
           ↓
BOARD-004 (background)
           ↓
BOARD-005 (card) → BOARD-006 (drag-drop) → BOARD-007 (snap)
                              ↓
                   BOARD-011 (viewer) → BOARD-012 (toggle)
                              ↓
                   BOARD-013 (progress)

BOARD-008 (string) → BOARD-009 (physics) → BOARD-010 (feedback)

BOARD-014 (keyboard) ──┐
                       ├→ Accessibility
BOARD-015 (screen reader)┘
```

---

## Success Metrics

- 15 stories completed
- Conspiracy board fully functional
- 8/10 user satisfaction (if testing conducted)
- All accessibility features working
- DEVELOPERS_MANUAL.md updated with all tunable parameters

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
