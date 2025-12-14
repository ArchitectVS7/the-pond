# Project Anatomy

This chapter maps The Pond's folder structure. When you need to find something, start here.

---

## Root Structure

```
the-pond/
├── addons/           # Third-party plugins
├── assets/           # Art, audio, fonts
├── combat/           # Combat system
├── conspiracy_board/ # Board UI and content
├── core/             # Shared systems (save, steam, etc.)
├── docs/             # Legacy documentation
├── GUIDE/            # This manual
├── metagame/         # Meta-progression, informants
├── shared/           # Utilities, accessibility
├── test/             # GUT test framework
├── tests/            # Test files
├── project.godot     # Godot project file
└── export_presets.cfg # Build configurations
```

---

## Combat System

```
combat/
├── scenes/
│   ├── Player.tscn          # Player character scene
│   ├── Enemy.tscn           # Base enemy scene
│   ├── EnemyTadpole.tscn    # Polluted tadpole variant
│   ├── EnemyMinnow.tscn     # Toxic minnow variant
│   ├── BossLobbyist.tscn    # The Lobbyist boss
│   ├── BossCEO.tscn         # The CEO boss
│   └── BulletPattern.tscn   # Bullet pattern templates
├── scripts/
│   ├── player_controller.gd # Movement, attacking
│   ├── tongue_attack.gd     # Tongue mechanics
│   ├── enemy_base.gd        # Base enemy class
│   ├── enemy_spawner.gd     # Wave management
│   ├── spatial_hash.gd      # Performance optimization
│   ├── boss_base.gd         # Boss framework
│   ├── boss_lobbyist.gd     # Lobbyist patterns
│   └── boss_ceo.gd          # CEO patterns
└── resources/
    ├── enemy_data/          # Enemy configuration
    └── bullet_patterns/     # Pattern definitions
```

### Key Files

| File | Purpose |
|------|---------|
| `player_controller.gd` | All player movement and input |
| `enemy_spawner.gd` | Wave progression, enemy creation |
| `boss_base.gd` | Shared boss behavior (phases, HP) |
| `spatial_hash.gd` | O(n*k) collision optimization |

---

## Conspiracy Board

```
conspiracy_board/
├── scenes/
│   ├── ConspiracyBoard.tscn    # Main board scene
│   ├── DataLogCard.tscn        # Draggable card
│   ├── StringRenderer.tscn     # Bezier strings
│   └── DocumentViewer.tscn     # Full-text popup
├── scripts/
│   ├── conspiracy_board.gd     # Board controller
│   ├── data_log_card.gd        # Card behavior
│   ├── string_renderer.gd      # String physics
│   ├── string_manager.gd       # String connections
│   └── document_viewer.gd      # Document display
└── content/
    ├── data_logs/              # Evidence documents
    │   ├── 01_corporate_memo.md
    │   ├── 02_internal_email.md
    │   └── ...
    └── outreach_template.md    # NGO email template
```

### Key Files

| File | Purpose |
|------|---------|
| `conspiracy_board.gd` | Drag-drop, zoom, pan |
| `string_renderer.gd` | Damped spring physics |
| `data_log_card.gd` | Card states, interactions |
| `document_viewer.gd` | TL;DR and full-text modes |

---

## Core Systems

```
core/
├── scenes/
│   └── GameManager.tscn      # Global autoload
├── scripts/
│   ├── save_data.gd          # Save structure
│   ├── save_manager.gd       # Save/load operations
│   ├── save_migration.gd     # Version handling
│   ├── checksum.gd           # Data integrity
│   ├── steam_manager.gd      # Steam API (stub)
│   ├── steam_cloud.gd        # Cloud sync (stub)
│   ├── achievement_manager.gd # Achievement tracking
│   └── input_manager.gd      # Controller detection
└── autoloads/
    └── GameState.gd          # Global state
```

### Key Files

| File | Purpose |
|------|---------|
| `save_manager.gd` | Atomic writes, corruption recovery |
| `steam_manager.gd` | Steam SDK wrapper |
| `input_manager.gd` | Controller type detection |
| `achievement_manager.gd` | Local + Steam achievements |

---

## Metagame

```
metagame/
├── scenes/
│   ├── MetaProgressionUI.tscn  # Between-run menu
│   └── InformantUI.tscn        # Informant dialogue
├── scripts/
│   ├── meta_progression.gd     # Persistent state
│   ├── evidence_manager.gd     # Evidence tracking
│   └── informant_manager.gd    # NPC informants
└── content/
    └── informants/             # Dialogue data
```

### Key Files

| File | Purpose |
|------|---------|
| `meta_progression.gd` | Cross-run persistence |
| `informant_manager.gd` | Deep Croak, Lily Padsworth |
| `evidence_manager.gd` | Discovery tracking |

---

## Shared Utilities

```
shared/
├── scenes/
│   └── AccessibilityOverlay.tscn  # Colorblind filter
├── scripts/
│   ├── accessibility_manager.gd   # A11y settings
│   ├── input_latency_monitor.gd   # <16ms validation
│   └── object_pool.gd             # Generic pooling
└── shaders/
    └── colorblind_filter.gdshader # Color transform
```

### Key Files

| File | Purpose |
|------|---------|
| `accessibility_manager.gd` | Colorblind, text scale, shake |
| `object_pool.gd` | Reusable for any object type |
| `colorblind_filter.gdshader` | Three filter modes |

---

## Assets

```
assets/
├── sprites/
│   ├── player/           # Frog animations
│   ├── enemies/          # Enemy sprites
│   ├── bosses/           # Boss sprites
│   └── ui/               # Interface elements
├── audio/
│   ├── sfx/              # Sound effects
│   └── music/            # Background tracks
├── fonts/                # UI fonts
└── themes/               # Godot theme resources
```

Most asset folders contain placeholders. See [Human Steps](../12-human-steps/overview.md) for asset requirements.

---

## Tests

```
tests/
├── unit/
│   ├── test_player_controller.gd
│   ├── test_enemy_spawner.gd
│   ├── test_string_renderer.gd
│   ├── test_save_manager.gd
│   └── ...
└── integration/
    ├── test_combat_flow.gd
    ├── test_board_flow.gd
    └── ...
```

Run tests with:
```bash
npm run test
# or
godot --headless -s addons/gut/gut_cmdln.gd
```

---

## Finding Things

### By Feature

| Feature | Primary Location |
|---------|------------------|
| Player movement | `combat/scripts/player_controller.gd` |
| Tongue attack | `combat/scripts/tongue_attack.gd` |
| Enemy spawning | `combat/scripts/enemy_spawner.gd` |
| Boss fights | `combat/scripts/boss_*.gd` |
| Board dragging | `conspiracy_board/scripts/conspiracy_board.gd` |
| String physics | `conspiracy_board/scripts/string_renderer.gd` |
| Saving | `core/scripts/save_manager.gd` |
| Accessibility | `shared/scripts/accessibility_manager.gd` |

### By Story ID

See [Appendix B: Story Traceability](../appendices/b-story-traceability.md) for the full mapping.

---

## Autoloads

Godot autoloads (singletons) accessible anywhere:

| Autoload | Script | Purpose |
|----------|--------|---------|
| GameState | `core/autoloads/GameState.gd` | Global state |
| SaveManager | `core/scripts/save_manager.gd` | Save operations |
| AccessibilityManager | `shared/scripts/accessibility_manager.gd` | A11y settings |
| SteamManager | `core/scripts/steam_manager.gd` | Steam SDK |
| InputManager | `core/scripts/input_manager.gd` | Controllers |

Access via:
```gdscript
SaveManager.save_game()
AccessibilityManager.set_colorblind_mode(1)
```

---

[Back to Index](../index.md) | [Next: Godot Patterns →](godot-patterns.md)
