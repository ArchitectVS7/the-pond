# ADR-002: System Architecture & Module Structure

**Status**: Accepted
**Date**: 2025-12-13
**Decision Makers**: Chief Architect, Backend Architect, Frontend Architect
**Related ADRs**: ADR-001 (Platform), ADR-006 (Tech Stack)

---

## Context

Pond Conspiracy is a single-player PC roguelike game built with Godot Engine. We need to define the high-level system structure that:

- Supports rapid iteration (10-12 week MVP timeline)
- Maintains clear separation of concerns
- Enables testability and debugging
- Scales from MVP → Alpha → Beta → 1.0
- Aligns with Godot's scene-based architecture

### Requirements from PRD

**Core Game Loop**:
- Combat system (tight controls, 60fps)
- Death → Evidence collection → Conspiracy board → Run again
- Meta-progression (persistent board, unlockable informants)

**Key Subsystems**:
1. **Combat**: Movement, tongue attack, enemy AI, bullet patterns
2. **Mutation System**: 10-12 mutations, 3+ synergies
3. **Boss Encounters**: 2 bosses (MVP), pattern-based fights
4. **Conspiracy Board**: Evidence collection, string connections, meta-game UI
5. **Meta-Progression**: Save/load, Steam Cloud sync, achievements
6. **Steam Integration**: Achievements, cloud saves, workshop (future)

**Team Constraints**:
- 1 programmer + 1 pixel artist
- No backend/server components
- Simple architecture preferred over complex

---

## Decision

### Architecture Style: **Modular Monolith (Godot Scenes)**

**High-Level Structure**:

```
Pond Conspiracy (Godot Project)
│
├── Core Systems (Autoloaded Singletons)
│   ├── GameManager (orchestration, state machine)
│   ├── SaveManager (persistence, Steam Cloud)
│   ├── EventBus (global pub/sub for decoupling)
│   ├── MetaProgression (unlock tracking, persistent data)
│   └── SteamAPI (GodotSteam wrapper)
│
├── Combat Module (Game Scenes)
│   ├── Player (movement, attack, mutations)
│   ├── EnemySpawner (wave management)
│   ├── Enemies (types, AI, bullet patterns)
│   ├── Bosses (pattern-based fights)
│   ├── ProjectileManager (bullet pooling)
│   └── CombatHUD (HP, pollution index, timer)
│
├── Conspiracy Board Module (UI Scenes)
│   ├── ConspiracyBoard (main board scene)
│   ├── DataLogManager (evidence collection state)
│   ├── StringPhysics (Bezier curve connections)
│   ├── DocumentViewer (TL;DR + full text modes)
│   └── ProgressTracker (X/7 completion UI)
│
├── Meta-Game Module
│   ├── MainMenu (start, continue, settings)
│   ├── RunSummary (death screen, stats, evidence)
│   ├── InformantUnlock (meta-progression rewards)
│   └── Settings (audio, video, accessibility)
│
└── Shared / Utilities
    ├── InputManager (rebindable controls, controller support)
    ├── AudioManager (music, SFX, crossfades)
    ├── ScreenShake (camera effects, toggleable)
    └── AccessibilityManager (colorblind modes, text scaling)
```

### Module Boundaries

**1. Core Systems** (Autoloaded, Global Access)
- **Responsibility**: Orchestrate game state, persistence, cross-scene communication
- **Implementation**: Godot autoload singletons
- **Dependencies**: None (no circular deps allowed)
- **Access Pattern**: `GameManager.start_run()`, `SaveManager.save_game()`

**2. Combat Module** (Game Loop)
- **Responsibility**: Real-time gameplay, enemy spawning, player controls
- **Entry Point**: `CombatScene.tscn` (loaded when run starts)
- **Exit Point**: Player death → triggers `EventBus.player_died` event
- **Dependencies**: Core Systems only (no dependencies on Conspiracy Board)
- **Data Flow**: Combat → EventBus → GameManager → ConspiracyBoard (loosely coupled)

**3. Conspiracy Board Module** (Meta-Game UI)
- **Responsibility**: Evidence presentation, investigation, narrative progression
- **Entry Point**: Loaded after player death OR from main menu
- **Dependencies**: Core Systems (reads MetaProgression data)
- **Data Flow**: Reads from SaveManager, updates MetaProgression state

**4. Meta-Game Module** (Menus, Settings)
- **Responsibility**: Non-gameplay UI, configuration, save management
- **Entry Point**: MainMenu (application start)
- **Dependencies**: Core Systems + Settings data

**5. Shared/Utilities** (Cross-Cutting)
- **Responsibility**: Input, audio, accessibility, visual effects
- **Access**: Available to all modules
- **No Business Logic**: Pure utility functions only

---

## System Context (C4 Model Level 1)

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│              Pond Conspiracy (Desktop App)          │
│                                                     │
│  ┌───────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │  Combat   │  │ Conspiracy   │  │ Meta-Game   │ │
│  │  System   │  │    Board     │  │   Menus     │ │
│  └───────────┘  └──────────────┘  └─────────────┘ │
│         │                │                │        │
│         └────────────────┴────────────────┘        │
│                       │                            │
│                 ┌─────▼──────┐                     │
│                 │    Core    │                     │
│                 │  Systems   │                     │
│                 └─────┬──────┘                     │
│                       │                            │
└───────────────────────┼────────────────────────────┘
                        │
                ┌───────▼────────┐
                │     Steam      │
                │  (Steamworks)  │
                └────────────────┘
```

**External Systems**:
- **Steam**: Achievements, cloud saves, workshop (via GodotSteam plugin)
- **Player**: Local file system for save files
- **OS**: Input devices (keyboard, mouse, controller)

---

## Container View (C4 Model Level 2)

**Core Systems Container** (Autoloaded Singletons):

1. **GameManager**
   - **Role**: Game state orchestrator
   - **Responsibilities**:
     - Run lifecycle (start → gameplay → death → board → restart)
     - Scene transitions
     - Difficulty scaling (time-based)
   - **State Machine**: MainMenu → CombatScene → DeathScreen → ConspiracyBoard → Loop
   - **No UI**: Pure logic

2. **SaveManager**
   - **Role**: Persistence layer
   - **Responsibilities**:
     - Save/load game state (JSON files)
     - Steam Cloud synchronization
     - Auto-save on death
     - Manual save from menu
   - **Save Format**: JSON (human-readable for debugging)
   - **Location**: `user://saves/` (cross-platform Godot path)

3. **EventBus**
   - **Role**: Global event aggregator (pub/sub pattern)
   - **Purpose**: Decouple modules (Combat doesn't know about ConspiracyBoard)
   - **Events**:
     - `player_died` → triggers death screen + evidence unlocked
     - `mutation_selected` → updates pollution index
     - `boss_defeated` → unlocks data log
     - `evidence_collected` → updates conspiracy board state
   - **Pattern**: `EventBus.emit_signal("player_died", {run_stats})`

4. **MetaProgression**
   - **Role**: Persistent player progress tracker
   - **Tracks**:
     - Unlocked informants (2 in MVP)
     - Collected data logs (7 in MVP)
     - Conspiracy connections made (string links)
     - Run count, total deaths, bosses defeated
   - **Persisted**: Yes (saved by SaveManager)

5. **SteamAPI**
   - **Role**: Wrapper around GodotSteam plugin
   - **Responsibilities**:
     - Initialize Steam on app launch
     - Trigger achievements
     - Sync save files to cloud
     - (Future) Leaderboards, workshop
   - **Graceful Degradation**: Game works without Steam (for testing)

---

**Combat Module Container**:

```
CombatScene.tscn (Root)
├── Player.tscn (movement, attack, health)
├── EnemySpawner (wave management, difficulty scaling)
├── ProjectileManager (object pooling for bullets)
├── BulletPatterns (BulletUpHell integration)
├── Boss_Lobbyist.tscn (boss 1, pattern fight)
├── Boss_CEO.tscn (boss 2, pattern fight)
├── CombatHUD (UI overlay: HP, timer, pollution index)
└── EnvironmentVisuals (wetland background, particle effects)
```

**Key Design Patterns**:
- **Object Pooling**: Reuse bullet instances (500+ on-screen)
- **Component Pattern**: Player has `MutationComponent` for ability management
- **State Machine**: Boss fights use state machines (Phase 1 → Phase 2 → Death)

---

**Conspiracy Board Module Container**:

```
ConspiracyBoard.tscn (Root)
├── Corkboard (visual container, wood texture)
├── DataLogContainer (grid of 7 document slots)
│   ├── DataLog_01.tscn (draggable, pinnable)
│   ├── DataLog_02.tscn
│   └── ... (7 total)
├── StringManager (Bezier curve physics)
│   ├── StringRenderer (draws curves between pins)
│   └── ConnectionLogic (validates connections)
├── DocumentViewer (popup for TL;DR + full text)
├── ProgressUI (X/7 collected, aha! feedback)
└── BoardHUD (back button, settings)
```

**Key Design Patterns**:
- **Drag-and-Drop**: Godot's `_gui_input()` for mouse interactions
- **Bezier Curves**: `draw_bezier()` with custom easing functions (CI-2.1)
- **State Management**: Each data log has `unlocked` bool in MetaProgression

---

## Data Flow Architecture

### Run Lifecycle Flow

```
1. Player starts run from Main Menu
   ↓
2. GameManager.start_run()
   - Loads CombatScene.tscn
   - Initializes player with base stats
   - Resets run timer
   ↓
3. Combat Loop (real-time gameplay)
   - Player attacks enemies
   - Mutations drop and apply
   - Boss fight triggers at specific intervals
   ↓
4. Player dies (health reaches 0)
   - EventBus.emit_signal("player_died", {run_stats})
   - GameManager listens → triggers scene transition
   ↓
5. DeathScreen.tscn (summary)
   - Shows stats (time survived, enemies killed)
   - Unlocks evidence if boss defeated
   - "View Evidence" button
   ↓
6. ConspiracyBoard.tscn (meta-game)
   - Reads MetaProgression.unlocked_data_logs
   - Player pins and connects documents
   - SaveManager auto-saves progress
   ↓
7. "Start New Run" button
   - Returns to step 2 (loop continues)
```

### Evidence Unlock Flow

```
Boss defeated → EventBus.emit("boss_defeated", {boss_id})
             ↓
   MetaProgression.unlock_data_log(boss_id)
             ↓
   SaveManager.save_game() (auto-save)
             ↓
   ConspiracyBoard UI updates (new document appears)
```

---

## Consequences

### Positive

✅ **Simple mental model**: Clear module boundaries match game mechanics
✅ **Godot-native**: Leverages scene system, no fighting the engine
✅ **Fast iteration**: Change one module without breaking others
✅ **Testable**: Core Systems are singletons → easy to mock in tests
✅ **Loosely coupled**: EventBus prevents tight dependencies
✅ **Team-appropriate**: 1 programmer can hold entire architecture in head
✅ **Scalable to 1.0**: Add bosses, mutations, endings without restructuring

### Negative

❌ **Singleton overuse risk**: Too many autoloads create global state spaghetti (mitigated by strict naming conventions)
❌ **EventBus abuse potential**: Easy to create "event hell" if not disciplined (mitigated by code reviews)
❌ **Scene size**: CombatScene.tscn could get large (mitigated by sub-scenes)

### Neutral

🔷 **Not microservices**: Game is monolithic, but for desktop games this is correct
🔷 **No database**: File-based saves are appropriate for single-player
🔷 **No API**: Steam is only external integration

---

## Alternatives Considered

### Alternative 1: ECS (Entity Component System)

**Example**: Use Godot's node system as pure ECS

**Pros**:
- Optimal performance for thousands of entities
- Data-oriented design
- Better for large-scale bullet-hell games

**Cons**:
- Overkill for 500 enemies max
- Steeper learning curve
- Godot's scene system fights ECS patterns
- Would slow down 10-week development

**Rejected**: Premature optimization, not needed for this scale

---

### Alternative 2: MVC (Model-View-Controller) with strict layers

**Example**: Separate `Models/`, `Views/`, `Controllers/` folders

**Pros**:
- Clear separation of concerns
- Familiar pattern from web development

**Cons**:
- Godot scenes already mix view + logic (not idiomatic)
- Forces folder structure that doesn't match engine
- No benefit for single-player game

**Rejected**: Fighting Godot's scene-based architecture

---

### Alternative 3: Feature-Based Modules (Vertical Slices)

**Example**: `features/combat/`, `features/conspiracy_board/` with everything per feature

**Pros**:
- Co-locates related code
- Easy to find all files for a feature

**Cons**:
- Shared code duplication risk
- Harder to enforce layering
- Godot's scene dependencies prefer hierarchical structure

**Partially Adopted**: We use modules (Combat, Conspiracy Board) but keep Core Systems separate to avoid duplication

---

## Related Decisions

- **ADR-001**: Platform (desktop app, no server)
- **ADR-003**: Communication Patterns (EventBus for decoupling)
- **ADR-004**: Data Architecture (file-based saves)
- **ADR-006**: Technology Stack (Godot Engine)

---

## Implementation Guidelines

### Naming Conventions

**Autoload Singletons**: `PascalCase` (GameManager, SaveManager)
**Scenes**: `PascalCase.tscn` (Player.tscn, ConspiracyBoard.tscn)
**Scripts**: `snake_case.gd` (player_controller.gd, enemy_spawner.gd)
**Signals**: `snake_case` (player_died, boss_defeated)

### Folder Structure

```
res://
├── core/
│   ├── game_manager.gd
│   ├── save_manager.gd
│   ├── event_bus.gd
│   ├── meta_progression.gd
│   └── steam_api.gd
├── combat/
│   ├── scenes/ (Player.tscn, enemies, bosses)
│   ├── scripts/ (player_controller.gd, enemy_ai.gd)
│   └── mutations/ (mutation definitions, effects)
├── conspiracy_board/
│   ├── scenes/ (ConspiracyBoard.tscn, DataLog.tscn)
│   ├── scripts/ (string_physics.gd, document_viewer.gd)
│   └── data/ (data_log_content.json)
├── metagame/
│   ├── scenes/ (MainMenu.tscn, Settings.tscn)
│   └── scripts/ (menu_controller.gd, settings_manager.gd)
├── shared/
│   ├── input_manager.gd
│   ├── audio_manager.gd
│   ├── screen_shake.gd
│   └── accessibility_manager.gd
└── assets/ (sprites, audio, fonts)
```

### Dependency Rules

**Allowed Dependencies**:
- Combat → Core Systems ✅
- ConspiracyBoard → Core Systems ✅
- MetaGame → Core Systems ✅
- All modules → Shared/Utilities ✅

**Forbidden Dependencies**:
- Combat → ConspiracyBoard ❌ (use EventBus instead)
- ConspiracyBoard → Combat ❌ (read from MetaProgression)
- Core Systems → Any module ❌ (core is lowest layer)

**Enforcement**: Code review + manual checks (no automated tooling for Godot)

---

## Testing Strategy

**Unit Tests** (Godot's GUT framework):
- Core Systems: SaveManager, MetaProgression logic
- Mutation synergy calculations
- Difficulty scaling formulas

**Integration Tests**:
- EventBus signal flow (emit → handler called)
- Save/load round-trip (write file → read → verify)
- Steam Cloud sync (mock Steam API)

**Playtesting** (Manual QA):
- Combat feel (60fps, input lag)
- Conspiracy board UX (Figma prototype → implementation)
- Full run loop (combat → death → board → repeat)

---

## Migration Path (MVP → 1.0)

### Alpha (Month 1-3)
- Add 3rd boss: New scene `Boss_Researcher.tscn` in `combat/scenes/`
- Add +5 mutations: New files in `combat/mutations/`
- Visual mutation effects: Add `MutationVisuals` component to Player
- Dynamic music: Extend AudioManager with crossfade logic

**No architectural changes needed** ✅

### Beta (Month 4-6)
- Secret boss: New scene `Boss_SentientPond.tscn`
- Daily challenges: New `DailyChallengeManager` autoload singleton
- Leaderboards: Extend SteamAPI with leaderboard methods

**Minor additions, no restructuring** ✅

### 1.0 Launch
- 3 endings: Branching logic in `GameManager.end_run(ending_id)`
- Endless mode: New `EndlessMode.tscn` scene variant

**Architecture scales cleanly** ✅

---

**Approved By**:
- ✅ Chief Architect
- ✅ Backend Architect
- ✅ Frontend Architect

**Next ADR**: ADR-003 - Communication Patterns & API Strategy
