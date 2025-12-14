# Conspiracy Board Overview

The conspiracy board is The Pond's unique differentiator. It's where players connect environmental evidence, uncover corporate plots, and experience the narrative. This chapter covers its implementation.

---

## The Core Concept

You're a frog. Someone poisoned your pond. The conspiracy board is where you prove it.

Players discover data logs during combat. Each log is a piece of evidence - corporate memos, scientific reports, witness statements. On the board, players arrange these logs and draw connections between them, gradually uncovering the conspiracy.

This isn't just a menu - it's a core gameplay pillar.

---

## What's Here

| File | What It Covers |
|------|----------------|
| [Drag-Drop System](drag-drop.md) | Card interaction, positioning, snapping |
| [String Physics](string-physics.md) | Connection rendering, spring simulation |
| [Document Viewer](document-viewer.md) | Reading evidence, scroll behavior |
| [Accessibility](accessibility.md) | Screen reader support, keyboard navigation |

---

## System Architecture

```
ConspiracyBoard (Control)
├── CardContainer (Control)
│   └── DataLogCard (scenes) - dynamically spawned
├── StringContainer (Node2D)
│   └── StringConnection (scenes) - connection lines
├── PinBoard (Control)
│   └── Pin positions for snapping
└── DocumentViewer (Control)
    └── Fullscreen evidence reader
```

---

## Key Files

| File | Purpose |
|------|---------|
| `conspiracy_board/scenes/ConspiracyBoard.tscn` | Main board scene |
| `conspiracy_board/scripts/conspiracy_board.gd` | Board logic |
| `conspiracy_board/scenes/DataLogCard.tscn` | Card component |
| `conspiracy_board/scripts/data_log_card.gd` | Card interaction |
| `conspiracy_board/resources/DataLogResource.gd` | Card data |
| `conspiracy_board/scripts/string_renderer.gd` | Connection physics |

---

## Data Log Structure

Each evidence card uses a DataLogResource:

```gdscript
# conspiracy_board/resources/DataLogResource.gd
class_name DataLogResource
extends Resource

@export var id: String              # Unique identifier
@export var title: String           # Display title
@export var summary: String         # Short preview (TL;DR)
@export var full_text: String       # Complete content
@export var discovered: bool        # Discovery state
@export var category: String        # For grouping
@export var connections: Array[String]  # Connected log IDs
```

### Card States

| State | Appearance | Interaction |
|-------|------------|-------------|
| Undiscovered | 30% opacity, "???" title | Non-interactive |
| Discovered | Full opacity, real content | Draggable, clickable |

---

## Interaction Flow

### Discovering Logs

1. Player finds evidence during combat
2. `ConspiracyBoard.discover_log(log_id)` called
3. Card transitions from undiscovered to discovered
4. Animation plays (fade in, slight bounce)

### Placing Cards

1. Player drags card on board
2. Card follows mouse with offset
3. On release, snaps to nearest pin (if within 50px)
4. Position saved to game state

### Making Connections

1. Player drags from card edge
2. String follows mouse
3. Drop on another card creates connection
4. Connection validated against game logic

### Reading Documents

1. Player clicks discovered card
2. Document viewer opens fullscreen
3. Full text displayed with scroll
4. ESC or click outside closes

---

## Tunable Parameters Quick Reference

### Card Settings

| Parameter | Default | Effect |
|-----------|---------|--------|
| `card_width` | 200 | Card width (px) |
| `card_height` | 150 | Card height (px) |
| `preview_max_chars` | 80 | Text truncation |
| `undiscovered_alpha` | 0.3 | Hidden card opacity |

### String Physics

| Parameter | Default | Effect |
|-----------|---------|--------|
| `string_stiffness` | 150.0 | Spring tightness |
| `string_damping` | 8.0 | Oscillation reduction |
| `string_segments` | 20 | Render resolution |

### Drag-Drop

| Parameter | Default | Effect |
|-----------|---------|--------|
| `drag_threshold` | 5.0 | Pixels before drag starts |
| `snap_distance` | 50.0 | Pin snap range |

---

## Story Traceability

| Story | Description | Status |
|-------|-------------|--------|
| BOARD-001 | Figma prototype | BLOCKED (design tools) |
| BOARD-002 | Recruit testers | BLOCKED (human task) |
| BOARD-003 | 8/10 satisfaction | BLOCKED (depends on testing) |
| BOARD-004 | Data log content | Complete |
| BOARD-005 | Card component | Complete |
| BOARD-006 | Drag-drop system | Complete |
| BOARD-007 | Pin snapping | Complete |
| BOARD-008 | String connections | Complete |
| BOARD-009 | Document viewer | Complete |
| BOARD-010 | Accessibility | Complete |

---

## Design Principles

### Tactile Feel

The board should feel like a real investigation board:
- Cork texture background
- Paper-like cards
- String connections that sway
- Thumbtack sounds on pin

### Information Architecture

Evidence is organized by category:
- **Corporate**: Company memos, financial records
- **Scientific**: Lab reports, environmental data
- **Witness**: Testimonies, observations
- **Media**: News clippings, leaked documents

### Progressive Discovery

Players don't see all evidence at once:
- Undiscovered cards show "[LOCKED]"
- Connections only possible between discovered logs
- Story unfolds through discoveries

---

## Integration Points

### With Save System

```gdscript
# Board state saved automatically
save_data.conspiracy_data = {
    "discovered_logs": discovered_logs,
    "connections": connections,
    "card_positions": card_positions,
    "completion_percentage": get_completion()
}
```

### With Combat

```gdscript
# After defeating enemies
if enemy.drops_evidence:
    ConspiracyBoard.discover_log(enemy.evidence_id)
```

### With Mutations

Some mutations affect the board:
- **Keen Eye**: Reveals hint about undiscovered logs
- **Journalist Instinct**: Shows connection possibilities

---

## Accessibility Features

The board includes:
- Screen reader support for all cards
- Keyboard navigation (Tab, Arrow keys)
- High contrast mode
- Text scaling
- Colorblind-friendly connection colors

See [Accessibility](accessibility.md) for implementation details.

---

## Next Steps

If you're implementing the board:

1. Start with [Drag-Drop System](drag-drop.md) - core interaction
2. Add [String Physics](string-physics.md) - visual connections
3. Implement [Document Viewer](document-viewer.md) - content reading
4. Test with [Accessibility](accessibility.md) - inclusive design

---

[Back to Index](../index.md) | [Next: Drag-Drop System →](drag-drop.md)
