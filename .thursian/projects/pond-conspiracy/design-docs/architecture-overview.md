# Pond Conspiracy - Architecture Overview

**Project**: Pond Conspiracy (Investigative Roguelike Bullet-Hell)
**Version**: 1.0 (MVP Architecture)
**Date**: 2025-12-13
**Status**: ✅ Ready for Implementation
**Team**: Solo Developer + Pixel Artist

---

## Executive Summary

Pond Conspiracy is architected as a **modular monolith** desktop game using **Godot 4.2+** with **GDScript**. The architecture prioritizes:

1. **Simplicity**: Single-player local game, no servers, file-based saves
2. **Performance**: 60fps minimum, <16ms input lag, optimized for GTX 1060
3. **Rapid Iteration**: 10-12 week MVP timeline, hot reload, no compile step
4. **Accessibility**: 3 colorblind modes, text scaling, rebindable controls
5. **Scalability to 1.0**: Clean module boundaries for Alpha/Beta content expansion

### Architecture Vision

**"A weekend indie game that punches above its weight through tight focus and smart constraints."**

- **NOT a AAA production**: Embrace limitations (solo dev, 10-12 weeks, $5-8K budget)
- **NOT feature-complete on day 1**: MVP → Early Access → Alpha → Beta → 1.0
- **NOT over-engineered**: Use Godot's built-in systems, avoid premature abstractions
- **YES scalable**: Module boundaries support adding bosses, mutations, endings without rewrites

---

## System Context (C4 Level 1)

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                  Pond Conspiracy (Godot App)                │
│                                                             │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│   │   Combat     │  │ Conspiracy   │  │  Meta-Game   │    │
│   │   System     │  │    Board     │  │    Menus     │    │
│   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│          │                  │                  │            │
│          └──────────────────┴──────────────────┘            │
│                              │                              │
│                      ┌───────▼───────┐                      │
│                      │ Core Systems  │                      │
│                      │ (Singletons)  │                      │
│                      └───────┬───────┘                      │
│                              │                              │
└──────────────────────────────┼──────────────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │       Steam         │
                    │   (Steamworks SDK)  │
                    └─────────────────────┘
```

**External Systems**:
- **Steam**: Authentication, achievements, cloud saves, workshop (future)
- **Player's File System**: Local save files (`user://saves/`)
- **OS**: Input devices (keyboard, mouse, gamepad)

---

## Container View (C4 Level 2)

### Module Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Pond Conspiracy - Module Decomposition                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Core Systems (Autoloaded Singletons)                   │ │
│ │                                                         │ │
│ │  GameManager │ SaveManager │ EventBus │ MetaProgression │ │
│ │  SteamAPI    │                                         │ │
│ └─────────────────────────────────────────────────────────┘ │
│                              ▲                              │
│        ┌─────────────────────┼─────────────────────┐        │
│        │                     │                     │        │
│        │                     │                     │        │
│ ┌──────▼──────┐   ┌──────────▼──────┐   ┌─────────▼─────┐ │
│ │   Combat    │   │   Conspiracy    │   │   Meta-Game   │ │
│ │             │   │      Board      │   │               │ │
│ │ - Player    │   │ - Corkboard UI  │   │ - Main Menu   │ │
│ │ - Enemies   │   │ - Data Logs     │   │ - Settings    │ │
│ │ - Bosses    │   │ - String Physics│   │ - Death Screen│ │
│ │ - Mutations │   │ - Document View │   │ - Informants  │ │
│ │ - HUD       │   │ - Progress UI   │   │               │ │
│ └─────────────┘   └─────────────────┘   └───────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Shared / Utilities (Cross-Cutting)                     │ │
│ │                                                         │ │
│ │  InputManager │ AudioManager │ ScreenShake │           │ │
│ │  AccessibilityManager (colorblind modes, text scaling) │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Core Technologies

| Layer | Technology | Version | License | Purpose |
|-------|-----------|---------|---------|---------|
| **Game Engine** | Godot Engine | 4.2.1 | MIT | 2D game engine with scene system |
| **Language** | GDScript | (built-in) | MIT | Game logic, scripting |
| **Bullet Patterns** | BulletUpHell | 2.0+ (forked) | MIT | Bullet-hell engine plugin |
| **Steam Integration** | GodotSteam | 4.7+ | MIT | Steamworks API wrapper |

### Development Tools

| Tool | Purpose | Cost |
|------|---------|------|
| **GitHub** | Version control + CI/CD | Free (public repo after launch) |
| **GitHub Actions** | Automated builds | Free tier sufficient |
| **Godot Editor** | Visual editing, debugging | Free |
| **VS Code + GDScript LSP** | Code editing | Free |
| **GUT (Godot Unit Test)** | Unit/integration testing | Free |
| **Aseprite** | Pixel art creation | $20 (one-time) |

### Total Infrastructure Cost: **$0/month** (tools cost ~$20 one-time)

---

## System Architecture

### Core Systems (Autoloaded Singletons)

**Purpose**: Provide global access to cross-cutting concerns without tight coupling

```gdscript
# Autoload configuration (Project Settings → Autoload)
GameManager: res://core/game_manager.gd
SaveManager: res://core/save_manager.gd
EventBus: res://core/event_bus.gd
MetaProgression: res://core/meta_progression.gd
SteamAPI: res://core/steam_api.gd
```

**Responsibilities**:
- **GameManager**: Orchestrates game state (menu → combat → death → board → loop)
- **SaveManager**: Handles save/load, Steam Cloud sync, backup files
- **EventBus**: Global pub/sub for decoupling modules
- **MetaProgression**: Tracks unlocks, conspiracy progress, statistics
- **SteamAPI**: Wrapper around GodotSteam (achievements, cloud saves)

**Dependency Rule**: Core Systems have **ZERO dependencies** on other modules
- ✅ Combat → Core Systems (allowed)
- ❌ Core Systems → Combat (forbidden)

---

### Communication Patterns

**Event-Driven Architecture** using EventBus:

```gdscript
# Example: Player dies in Combat module
func _on_player_death():
    EventBus.emit_signal("player_died", {
        "time_survived": 180,
        "enemies_killed": 42,
        "boss_defeated": true
    })

# GameManager listens and transitions to DeathScreen
func _ready():
    EventBus.connect("player_died", self, "_on_player_died")

func _on_player_died(run_stats):
    change_scene_to("res://metagame/scenes/DeathScreen.tscn")
```

**Benefits**:
- Modules don't know about each other (loose coupling)
- Easy to add new listeners without modifying emitters
- Testable (can emit events in unit tests)

**Key Events**:
- `player_died` → Transition to death screen
- `boss_defeated` → Unlock data log
- `mutation_selected` → Update pollution index
- `evidence_unlocked` → Show new document on board
- `save_completed` → Show save icon

---

## Data Architecture

### Save File Format (JSON)

**Location**: `user://saves/save_game.json`

```json
{
  "version": "1.0.0",
  "checksum": 1234567890,
  "meta_progression": {
    "run_count": 42,
    "total_deaths": 38,
    "unlocked_informants": ["informant_01", "informant_02"],
    "unlocked_data_logs": ["log_01", "log_02", "log_03"],
    "conspiracy_connections": [
      {"from": "log_01", "to": "log_02"}
    ],
    "bosses_defeated": {
      "lobbyist": 15,
      "ceo": 8
    }
  },
  "settings": {
    "master_volume": 0.8,
    "colorblind_mode": "deuteranopia",
    "screen_shake_enabled": true,
    "text_size": "medium"
  }
}
```

**Save Strategy**:
- Auto-save on player death
- Auto-save on conspiracy connection made
- Auto-save on settings change
- Atomic writes (temp file → rename, never overwrite directly)
- Backup copy (previous save preserved as `save_backup.json`)

**Steam Cloud Sync**:
- Last-write-wins (simple, appropriate for single-player)
- Compare timestamps, use newer version
- Async upload (non-blocking, happens in background)

---

## Frontend Architecture (UI)

### Combat HUD

**Design**: Minimal, non-intrusive, performance-optimized

```
┌────────────────────────────────────┐
│ HP ████████░░ 80/100    Timer: 5:42 │
│                 Pollution: ██░░░░ 40% │
│                                      │
│         [GAMEPLAY AREA]              │
│                                      │
│           [ESC = Pause]              │
└──────────────────────────────────────┘
```

**Components**:
- HP Bar (ProgressBar)
- Timer Label (Label, updates at 60fps)
- Pollution Index (Custom Control, NEW in v0.2)
- Pause Menu (Popup, hidden by default)

---

### Conspiracy Board UI

**Design**: Rich, interactive, narrative-focused

**Requirements from PRD**:
- Corkboard aesthetic (wood, pins, string)
- Drag-and-drop documents (7 data logs)
- Red string physics (Bezier curves, 300ms animation, CI-2.1)
- TL;DR + full text reading modes
- 8/10 user satisfaction (Figma prototype required, CI-2.3)

**Implementation**:
```gdscript
# conspiracy_board/StringRenderer.gd
func _draw():
    for conn in connections:
        var start = conn.from
        var end = conn.to
        var mid = (start + end) / 2.0
        var control1 = Vector2(mid.x, start.y)
        var control2 = Vector2(mid.x, end.y)

        # Draw Bezier curve (red, 3px thick)
        draw_bezier(start, control1, control2, end, Color.RED, 3.0)
```

**Accessibility**:
- 3 colorblind modes (Deuteranopia, Protanopia, Tritanopia) via shaders
- Text scaling (Small 0.8x, Medium 1.0x, Large 1.3x)
- Keyboard navigation (arrow keys, Enter/ESC)
- Screen reader support (Godot's built-in accessibility)

---

## Cross-Cutting Concerns

### Performance Optimization

**Target**: 60fps minimum on GTX 1060 / RX 580 @ 1080p

**Strategies**:
1. **Object Pooling**: Reuse bullet instances (500+ simultaneous)
2. **Spatial Hashing**: Optimize collision detection
3. **Culling**: Don't render off-screen enemies
4. **Particle Limits**: Cap max particles to 200
5. **Audio Pooling**: Reuse AudioStreamPlayer instances

**Profiling**: Use Godot's built-in profiler (Debugger → Profiler tab)

---

### Security & Authentication

**Authentication**: Steam-based (automatic, zero dev work)
- Game launches, Steam client handles auth
- `Steam.getSteamID()` retrieves user ID
- No password, no login screen

**Save File Integrity**: CRC32 checksums
- Detect accidental corruption (disk errors)
- Does NOT prevent intentional editing (acceptable for single-player)

**No Encryption**: Save files are plain JSON
- No sensitive data (no passwords, no PII)
- Player can edit saves (this is a feature, not a bug)

**No Anti-Cheat**: Single-player game, player can cheat themselves

---

### Observability

**Logging**: Godot's `print()` and `push_warning()` / `push_error()`
- Debug builds: Verbose logging
- Release builds: Errors only

**Metrics**: Steam stats (built-in)
- No custom analytics
- No telemetry

**Crash Reporting**: Godot's built-in crash handler
- Writes crash logs to `user://logs/`
- Player can submit via Steam forums if needed

---

## Deployment Architecture

### Build Pipeline (GitHub Actions)

```yaml
# .github/workflows/build.yml
name: Build Godot Project
on: [push, pull_request]

jobs:
  export-windows:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Export Windows Build
        uses: firebelley/godot-export@v5
        with:
          godot_version: 4.2.1
          export_preset: Windows
      - name: Upload Artifact
        uses: actions/upload-artifact@v3
        with:
          name: pond-conspiracy-windows
          path: builds/windows/

  export-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Export Linux Build
        uses: firebelley/godot-export@v5
        with:
          godot_version: 4.2.1
          export_preset: Linux
      - name: Upload Artifact
        uses: actions/upload-artifact@v3
```

**Deployment Process**:
1. Push code to `main` branch
2. GitHub Actions builds Windows + Linux binaries
3. Developer manually QA tests builds
4. Upload to Steam via Steamworks (manual, then automate later)
5. Push to Early Access or beta branch

---

## Development Guidelines

### Code Organization

**Folder Structure**:
```
res://
├── core/                    # Autoloaded singletons
├── combat/                  # Combat module
│   ├── scenes/             # Player, enemies, bosses
│   ├── scripts/            # Controllers, AI
│   └── mutations/          # Ability definitions
├── conspiracy_board/        # Conspiracy board module
│   ├── scenes/             # Board, documents, UI
│   ├── scripts/            # Drag-drop, string physics
│   └── data/               # Data log content (JSON)
├── metagame/                # Menus, settings
│   ├── scenes/
│   └── scripts/
├── shared/                  # Utilities
│   ├── input_manager.gd
│   ├── audio_manager.gd
│   └── accessibility_manager.gd
└── assets/                  # Art, audio, fonts
    ├── sprites/
    ├── audio/
    └── fonts/
```

### Naming Conventions

- **Singletons**: `PascalCase` (GameManager, SaveManager)
- **Scenes**: `PascalCase.tscn` (Player.tscn, ConspiracyBoard.tscn)
- **Scripts**: `snake_case.gd` (player_controller.gd, enemy_ai.gd)
- **Signals**: `snake_case` (player_died, boss_defeated)
- **Variables**: `snake_case` (current_hp, is_dragging)
- **Constants**: `SCREAMING_SNAKE_CASE` (MAX_ENEMIES, DEFAULT_VOLUME)

### Testing Strategy

**Unit Tests** (GUT framework):
```gdscript
# test/unit/test_meta_progression.gd
extends GutTest

func test_unlock_data_log():
    var meta = MetaProgression.new()
    meta.unlock_data_log("log_01")
    assert_true(meta.unlocked_data_logs.has("log_01"))
```

**Integration Tests**:
- Full save/load cycle
- EventBus signal flow
- Steam Cloud sync (mock Steam API)

**Manual QA**:
- Combat feel (60fps, input lag)
- Conspiracy board UX (Figma prototype → implementation match)
- Full run loop (combat → death → board → repeat)

---

## Implementation Priorities

### MVP Phase (Week 1-12)

**Week 1-2: Core Combat**
- Player movement + tongue attack
- 2 enemy types
- BulletUpHell integration

**Week 3-4: Mutations + Boss 1**
- 10 mutations with 3 synergies
- The Lobbyist boss fight

**Week 5-6: Conspiracy Board**
- Corkboard UI (Figma prototype first, CI-2.3)
- 7 data logs (NGO-reviewed, CI-2.2)
- String physics (Bezier curves, 300ms animation, CI-2.1)

**Week 6-7: Meta-Progression**
- Save/load system
- Steam Cloud sync
- 2 informants unlock

**Week 7-8: Boss 2 + Ending**
- The CEO boss fight
- Protest ending (collective action)

**Week 9-10: Polish + Accessibility**
- 3 colorblind modes (CI-3.2)
- Pollution index UI (NEW-1, 1 day)
- Screen shake toggle
- Controller support

**Week 11-12: Launch Prep**
- Trailer, screenshots
- Steam page finalization
- Early Access release

---

### Alpha Phase (Month 1-3 Post-MVP)

**Content Expansion**:
- 3rd boss (The Researcher)
- 2nd ending path
- +5 mutations, +3 synergies
- Visual mutation effects (frog appearance changes)
- Dynamic music system

---

### Beta Phase (Month 4-6 Post-MVP)

**Polish & Extended Content**:
- Secret boss (Sentient Pond)
- 3rd ending path (nihilist)
- Daily challenges + leaderboards
- Endless mode

---

## Related Documentation

- **[ADRs](./adrs/README.md)**: Architecture Decision Records (7 decisions)
- **[PRD v0.2](./PRD-v0.2.md)**: Product Requirements Document
- **[Triage Report](../05-pond-conspiracy-triage-report.md)**: Engineering review results

---

**Status**: ✅ Architecture Complete, Ready for Implementation
**Next Step**: Week 0 Kickoff → Begin Combat Prototype (Week 1)
**Approved By**: Chief Architect, Technical Team
**Date**: 2025-12-13
