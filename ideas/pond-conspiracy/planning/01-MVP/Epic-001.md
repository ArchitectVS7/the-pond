# Pond Conspiracy - Development Plan

## Overview

**Project**: Pond Conspiracy (Investigative Roguelike Bullet-Hell)
**Tech Stack**: Godot 4.2+, GDScript, BulletUpHell, GodotSteam, GUT Testing
**Location**: C:\dev\GIT\the-pond (Godot project at root)
**First Story**: COMBAT-001: player-movement-wasd-8dir

---

## Plan-Act-Validate Workflow

### PLAN Phase (15-30 min per story)
1. Read story from `epics-and-stories.md`
2. Check PRD requirements via `traceability-matrix.md`
3. Design test cases BEFORE implementation
4. List files to create/modify
5. **[HUMAN CHECKPOINT]** Design approval

### ACT Phase (varies by story size)
1. Create test file with failing tests (red)
2. Implement feature code
3. Run tests after each function (green)
4. Commit after each passing test
5. **[HUMAN CHECKPOINT]** Request assets if needed

### VALIDATE Phase (30-60 min per story)
1. Run full GUT test suite - all green
2. Manual QA in Godot editor
3. Profile for 60fps performance
4. Adversarial code review
5. **[HUMAN CHECKPOINT]** Story sign-off
6. Merge to main branch

---

## Phase 1: Project Setup

### Files to Create

```
C:\dev\GIT\the-pond\
├── project.godot                    # Godot project config
├── core/
│   ├── event_bus.gd                 # Global signal bus
│   ├── game_manager.gd              # Game state orchestration
│   └── save_manager.gd              # Persistence
├── combat/
│   ├── scenes/
│   │   ├── Player.tscn              # Player scene
│   │   └── TestArena.tscn           # Test level
│   └── scripts/
│       └── player_controller.gd     # Movement logic
├── shared/
│   └── input_manager.gd             # Input handling
├── assets/
│   ├── sprites/player/              # Player art (placeholder OK)
│   └── audio/sfx/                   # Sound effects
├── addons/
│   ├── gut/                         # Testing framework
│   └── BulletUpHell/                # Forked plugin
├── test/
│   ├── unit/
│   │   └── test_player_movement.gd
│   └── .gutconfig.json
└── .github/workflows/
    ├── test.yml                     # CI testing
    └── build.yml                    # Release builds
```

### Setup Tasks
1. Initialize Godot 4.2+ project
2. Create folder structure per architecture-overview.md
3. Install GUT testing addon
4. Fork BulletUpHell to addons/ (Day 1 risk mitigation)
5. Configure GitHub Actions CI/CD
6. Set up pre-commit hooks (gdlint, gdformat)

---

## Phase 2: COMBAT-001 Implementation

### Story Details
- **ID**: COMBAT-001
- **Title**: player-movement-wasd-8dir
- **Epic**: EPIC-001 (Combat System Foundation)
- **Priority**: P0 (CRITICAL)
- **Size**: S (Small - ~2 hours)

### Acceptance Criteria (from PRD FR-001)
- [ ] WASD movement (8-directional)
- [ ] 60fps minimum on GTX 1060 @ 1080p
- [ ] <16ms input lag (1 frame at 60fps)
- [ ] Diagonal movement normalized (no speed boost)
- [ ] Movement speed ~200 pixels/second

### Test Cases
1. `test_wasd_input_creates_velocity` - W/A/S/D produce correct velocity
2. `test_diagonal_movement_normalized` - Diagonal not faster than cardinal
3. `test_no_input_no_velocity` - Zero input = zero velocity
4. `test_8_directional_movement` - All 8 directions work

### Files to Create
| File | Purpose |
|------|---------|
| `project.godot` | Project configuration with input actions |
| `core/event_bus.gd` | Signal bus (foundation) |
| `combat/scenes/Player.tscn` | CharacterBody2D scene |
| `combat/scripts/player_controller.gd` | Movement logic |
| `combat/scenes/TestArena.tscn` | Minimal test level |
| `test/unit/test_player_movement.gd` | Unit tests |

### Review Checklist
```
ARCHITECTURE:
[ ] Player.tscn uses CharacterBody2D
[ ] PlayerController is child Node, not root
[ ] No cross-module dependencies

CODE QUALITY:
[ ] Type hints on all parameters/returns
[ ] MOVE_SPEED is @export for tuning
[ ] File < 500 lines

PERFORMANCE:
[ ] No allocations in _physics_process()
[ ] normalized() prevents diagonal speed boost

TESTING:
[ ] All 8 directions tested
[ ] Edge cases covered
```

---

## Human Checkpoints

| Checkpoint | When | Action Required |
|------------|------|-----------------|
| **Project Setup Approval** | After Phase 1 | Confirm folder structure, CI/CD |
| **Design Approval** | Before each story ACT phase | Review test cases |
| **Asset Request** | During ACT if needed | Provide sprites/audio |
| **Story Sign-off** | After VALIDATE phase | Approve merge |
| **Epic Milestone** | After all stories in epic | Confirm goals met |

### Asset Requirements (COMBAT-001)
- **Player sprite**: 16x16 or 32x32 placeholder (can be colored rectangle)
- **No audio needed** for movement-only story

---

## Implementation Order (First 10 Stories)

| # | Story ID | Name | Rationale |
|---|----------|------|-----------|
| 1 | COMBAT-001 | player-movement-wasd-8dir | Foundation |
| 2 | COMBAT-002 | mouse-aim-system | Needed for attack |
| 3 | COMBAT-003 | tongue-attack-whip-mechanic | Core mechanic |
| 4 | BULLET-001 | fork-bulletuphell-repo | Risk mitigation |
| 5 | BULLET-002 | integrate-plugin-godot42 | Before enemies |
| 6 | COMBAT-005 | enemy-spawn-escalation | Enemies to fight |
| 7 | COMBAT-006 | enemy-ai-basic-behaviors | Playable game |
| 8 | COMBAT-007 | collision-detection-spatial-hash | Combat works |
| 9 | COMBAT-008 | hit-feedback-screenshake | Game feel |
| 10 | COMBAT-010 | hit-stop-2frame-pause | Polish |

---

## Critical Reference Files

| Document | Path | Use For |
|----------|------|---------|
| Epics & Stories | `.thursian/projects/pond-conspiracy/planning/epics-and-stories.md` | Story details, acceptance criteria |
| Architecture | `.thursian/projects/pond-conspiracy/design-docs/architecture-overview.md` | Folder structure, naming conventions |
| PRD v0.2 | `.thursian/projects/pond-conspiracy/design-docs/PRD-v0.2.md` | Requirements (60fps, 16ms lag) |
| Traceability | `.thursian/projects/pond-conspiracy/planning/traceability-matrix.md` | Story → Requirement mapping |
| ADR-002 | `.thursian/projects/pond-conspiracy/design-docs/adrs/ADR-002-system-architecture.md` | Core systems patterns |

---

## Adversarial Code Review Template

After each story, review against:

```markdown
## Code Review: [STORY-ID]

### Architecture
- [ ] Correct module (core/combat/conspiracy_board/metagame/shared)
- [ ] No forbidden dependencies
- [ ] EventBus for cross-module communication

### Code Quality
- [ ] Naming: snake_case scripts, PascalCase scenes
- [ ] File < 500 lines, functions < 50 lines
- [ ] Type hints used throughout
- [ ] No hardcoded magic numbers

### Performance
- [ ] No allocations in _process/_physics_process
- [ ] Object pooling where appropriate
- [ ] Profiler confirms 60fps

### Testing
- [ ] Tests cover happy path
- [ ] Tests cover edge cases
- [ ] All tests pass

### Security (if applicable)
- [ ] No hardcoded secrets
- [ ] Input validation on user data
```

---

## Next Steps

1. **[HUMAN CHECKPOINT]** Approve this plan
2. Create Godot project structure
3. Set up GUT testing framework
4. Implement COMBAT-001 with TDD
5. Adversarial review and sign-off
6. Continue to COMBAT-002

---

**Plan Status**: Ready for approval
**Created**: 2025-12-13
