# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Pond Conspiracy** is an investigative roguelike bullet-hell game built with Godot 4.2+. Players uncover corporate environmental conspiracies through combat and a unique conspiracy board meta-progression system. This is a single-player PC game targeting Steam Early Access.

**Tech Stack:**
- Engine: Godot 4.2+
- Language: GDScript
- Plugins: BulletUpHell (forked), GUT (testing), GodotSteam
- Platform: Windows, Linux, Steam Deck

## Development Commands

### Testing
```bash
# Run all tests via GUT plugin in Godot Editor
# or run specific test suite:
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/conspiracy_board/

# GUT configuration is in test/.gutconfig.json
```

### Running the Game
```bash
# Launch from editor:
# F5 or play button in Godot Editor

# Main scene: res://combat/scenes/TestArena.tscn
```

### Godot Project
```bash
# Open project in Godot:
godot project.godot

# The project.godot file contains all game configuration
```

## Architecture Overview

### Event-Driven Modular Architecture

The codebase uses an **event-driven architecture** centered around `EventBus` (autoloaded singleton). This ensures zero coupling between major systems.

**Core Principle:** Modules emit signals to EventBus, other modules listen. No direct dependencies between major systems.

```gdscript
# Emit from any module
EventBus.player_died.emit(run_stats)

# Listen from any module
EventBus.player_died.connect(_on_player_died)
```

### Directory Structure

```
the-pond/
├── core/                    # Core systems (EventBus, save/load, input)
│   ├── event_bus.gd        # Autoloaded global signal bus
│   └── scripts/            # Core utilities (save_data, achievements, input)
├── combat/                  # Combat system (player, enemies, bullets)
│   ├── scenes/             # Combat scenes and test arenas
│   ├── scripts/            # Combat logic (bosses, arena, attacks)
│   ├── resources/          # Combat resource definitions
│   └── mutations/          # Mutation system definitions
├── conspiracy_board/        # Investigation UI meta-progression
│   ├── scenes/             # Board UI scenes
│   ├── scripts/            # Board logic (pins, strings, documents)
│   ├── content/            # Data logs and evidence content
│   ├── shaders/            # Visual effects (vignette shader)
│   └── tests/              # Board-specific tests
├── metagame/                # Meta-progression (informants, unlocks)
│   ├── scenes/             # Meta UI scenes
│   ├── scripts/            # Meta-progression logic
│   └── resources/          # Meta-progression data
├── shared/                  # Shared utilities and resources
│   ├── scripts/            # Shared helper scripts
│   └── shaders/            # Shared shader effects
├── test/ & tests/           # Unit and integration tests (GUT framework)
├── addons/                  # Third-party plugins
│   ├── BulletUpHell/       # Bullet pattern system (forked)
│   └── gut/                # GUT testing framework
├── .thursian/               # Thursian workflow system (AI-assisted design)
│   ├── workflows/          # Multi-agent workflow definitions
│   ├── projects/           # Project artifacts (PRDs, ADRs, visions)
│   └── personas/           # AI persona definitions
├── .claude/                 # Claude Code configuration
│   ├── agents/             # Agent definitions (54 specialized agents)
│   ├── commands/           # Slash commands for workflows
│   └── skills/             # Reusable skill modules
├── .hive-mind/              # Hive Mind swarm coordination
├── GUIDE/                   # Developer's Manual (implementation guide)
└── docs/                    # Implementation summaries and reports
```

### Key Systems

**EventBus (core/event_bus.gd):**
- Autoloaded singleton providing global signal bus
- Combat signals: `player_died`, `enemy_killed`, `boss_defeated`, `player_damaged`
- Mutation signals: `level_up`, `mutation_selected`, `pollution_changed`
- Conspiracy signals: `evidence_unlocked`, `connection_made`, `board_updated`
- Meta signals: `informant_unlocked`, `hint_given`, `run_ended`
- Save/load signals: `save_completed`, `load_completed`
- Zero dependencies - other modules depend on EventBus, not vice versa

**Combat System (combat/):**
- Player controller with WASD movement + mouse attack
- Boss encounters with unique bullet patterns
- BulletUpHell integration for bullet-hell patterns
- Mutation system for power-ups (pollution-themed)
- Physics layers: Player(1), Environment(2), Enemies(3), PlayerAttack(4), Bullets(5)

**Conspiracy Board (conspiracy_board/):**
- Cork board UI with vignette shader effect
- Evidence cards (data logs) unlocked by defeating bosses
- String connections between documents
- Investigation meta-progression
- 1920x1080 viewport with warm brown aesthetic

**Testing (test/ & tests/):**
- GUT (Godot Unit Testing) framework
- Unit tests in tests/unit/ and test/unit/
- Integration tests in tests/integration/ and test/integration/
- Conspiracy board tests in tests/conspiracy_board/
- Configuration: test/.gutconfig.json

## File Organization Standards

### GDScript File Structure
- **Scenes:** `{module}/scenes/{SceneName}.tscn`
- **Scripts:** `{module}/scripts/{script_name}.gd`
- **Resources:** `{module}/resources/{ResourceType}.tres`
- **Tests:** `test/{module}/test_{component}.gd` or `tests/{component}/test_{feature}.gd`

### Naming Conventions
- GDScript files: `snake_case.gd`
- Scene files: `PascalCase.tscn`
- Resource files: `snake_case.tres` or `PascalCase.tres`
- Test files: `test_{feature}.gd`

### Module Boundaries
Each module is self-contained:
- Own scenes, scripts, resources
- Communicate via EventBus only
- No direct imports across module boundaries (except EventBus)
- Shared utilities go in `shared/`

## Thursian Workflow System

The `.thursian/` directory contains an AI-assisted product development workflow system:

### Project Artifacts (`.thursian/projects/pond-conspiracy/`)
- **PRD:** [design-docs/PRD-v0.2.md](../.thursian/projects/pond-conspiracy/design-docs/PRD-v0.2.md)
- **Architecture Decisions:** [design-docs/adrs/](../.thursian/projects/pond-conspiracy/design-docs/adrs/) (7 ADRs)
- **Vision Documents:** Initial idea, focus group reports, stakeholder feedback
- **Implementation Guide:** Comprehensive Developer's Manual in `GUIDE/`

### Workflow Phases
1. **Ideation** → Vision document
2. **Focus Group** → User validation (100% purchase intent achieved)
3. **Engineering Meeting** → PRD creation
4. **Stakeholder Review** → PRD validation
5. **Architecture Planning** → Technical design (7 ADRs)
6. **Implementation** → Current phase

### Architecture Decision Records (ADRs)
All critical architectural decisions documented in `.thursian/projects/pond-conspiracy/design-docs/adrs/`:
- ADR-001: Platform & Deployment (Steam PC, no servers)
- ADR-002: System Architecture (modular monolith + EventBus)
- ADR-003: Communication Patterns (event-driven)
- ADR-004: Data Architecture (JSON saves + Steam Cloud)
- ADR-005: Authentication & Security (Steam auth, trust-based)
- ADR-006: Technology Stack (Godot 4.2+, GDScript)
- ADR-007: Frontend Architecture (Godot UI, accessibility features)

## Claude Code Integration

### MCP Servers
Three MCP servers are configured (`.mcp.json`):
- **claude-flow@alpha:** Core SPARC workflow orchestration
- **ruv-swarm:** Enhanced swarm coordination (optional)
- **flow-nexus:** Cloud features and advanced orchestration (optional)

### Available Agents (54 total)
Located in `.claude/agents/`, organized by category:
- **Core:** coder, reviewer, tester, planner, researcher
- **Swarm:** hierarchical-coordinator, mesh-coordinator, adaptive-coordinator
- **GitHub:** pr-manager, code-review-swarm, issue-tracker, release-manager
- **SPARC:** sparc-coord, specification, pseudocode, architecture, refinement
- **Specialized:** backend-dev, mobile-dev, ml-developer, cicd-engineer, system-architect

### Slash Commands
Custom commands in `.claude/commands/`:
- `/ideation` - Run ideation orchestration workflow

### Settings
- Auto git checkpoints enabled (`.claude/settings.json`)
- Checkpoint manager: `.claude/helpers/checkpoint-manager.sh`

## Development Workflow

### Before Making Changes
1. Read relevant ADRs in `.thursian/projects/pond-conspiracy/design-docs/adrs/`
2. Check PRD v0.2 for feature requirements and scope
3. Review EventBus signals for existing integration points
4. Check GUIDE/ for implementation patterns and standards

### Adding New Features
1. Emit/listen to EventBus signals (never direct coupling)
2. Place code in appropriate module directory
3. Write GUT tests alongside implementation
4. Update documentation in module README if needed
5. Follow GDScript style: snake_case, type hints, doc comments

### Testing Requirements
- All new scripts must have corresponding GUT tests
- Tests go in `test/{module}/` or `tests/{module}/`
- Run full test suite before committing major changes
- Target: 60 FPS performance (combat is non-negotiable)

### Performance Considerations
- Combat must maintain 60 FPS (project.godot: physics_ticks_per_second=60)
- Use object pooling for bullets and enemies
- Profile before optimizing
- Test on GTX 1060 equivalent (minimum spec)

## Key Constraints

### Scope Discipline
- MVP timeline: 10-12 weeks (currently in implementation phase)
- Feature freeze: Day 28 of implementation
- Cut priority: visual polish → extra bosses → particle effects
- Defer to Alpha/Beta unless explicitly MVP-scoped in PRD v0.2

### Technical Constraints
- Godot 4.2+ only (uses Forward+ renderer)
- GDScript only (no C#, no GDNative)
- Steam-exclusive (no other platforms until post-1.0)
- Single-player only (no multiplayer, no networking)
- File-based saves (JSON + CRC32 checksums)

### Quality Gates
- 60 FPS combat (non-negotiable)
- Zero dependencies between major modules (except EventBus)
- All features must have GUT tests
- Accessibility: 3 colorblind modes required for launch

## Documentation References

- **Developer's Manual:** `GUIDE/index.md` (comprehensive implementation guide)
- **PRD v0.2:** `.thursian/projects/pond-conspiracy/design-docs/PRD-v0.2.md`
- **Architecture Overview:** `.thursian/projects/pond-conspiracy/design-docs/architecture-overview.md`
- **ADRs:** `.thursian/projects/pond-conspiracy/design-docs/adrs/README.md`
- **Conspiracy Board:** `conspiracy_board/README.md`
- **Project Status:** `.thursian/projects/pond-conspiracy/README.md`

## Important Notes

- **Never hardcode paths:** Use `res://` paths for Godot resources
- **Never skip EventBus:** All inter-module communication via signals
- **Test coverage is required:** GUT tests for all new functionality
- **Performance first:** 60 FPS is non-negotiable for combat
- **Consult ADRs:** Check architectural decisions before major changes
- **Follow module boundaries:** Respect the event-driven architecture
