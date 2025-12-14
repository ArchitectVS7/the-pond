# EPIC-008: Meta-Progression System - Development Plan

## Overview

**Epic**: EPIC-008 (Meta-Progression System)
**Release Phase**: MVP
**Priority**: P0 (Roguelike core loop)
**Dependencies**: EPIC-003, EPIC-007 (Conspiracy Board, Boss Encounters)
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-006

**Description**: Persistent conspiracy board, 2 informants, evidence collection across runs.

---

## Automated Workflow Protocol

### Before Each Story
1. **READ THIS PLAN** for re-alignment before starting
2. Verify dependencies from previous stories are complete
3. Check DEVELOPERS_MANUAL.md for any tunable parameters from prior work

### Story Completion Criteria
- All tests pass (adversarial workflow complete)
- Tunable parameters documented in DEVELOPERS_MANUAL.md
- No human sign-off required - proceed immediately to next story

### Blocker Handling
- If a story cannot be completed due to blockers or human-required actions:
  - **SKIP** the blocked steps
  - **NOTE** in DEVELOPERS_MANUAL.md under "Blocked Steps" section
  - **PROCEED** to next story

---

## Stories

### META-001: persistent-conspiracy-board-state
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] Board state persists between runs
- [ ] Card positions saved
- [ ] String connections saved
- [ ] Discovery progress saved

**Data Structure**:
```gdscript
var board_state = {
    "discovered_logs": [],
    "card_positions": {},
    "connections": [],
    "last_modified": 0
}
```

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `auto_save_interval` | float | 30.0 | Seconds between auto-saves |
| `max_connections` | int | 20 | Maximum string connections |

---

### META-002: evidence-unlock-system
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Evidence items defined
- [ ] Each boss drops unique evidence
- [ ] Evidence unlocks data logs
- [ ] Progressive revelation of conspiracy

**Evidence Mapping**:
| ID | Name | Source | Unlocks |
|----|------|--------|---------|
| 1 | Memo Fragment | Lobbyist | Data logs 1-3 |
| 2 | Financial Records | CEO | Data logs 4-6 |
| 3 | Full Dossier | Both defeated | Data log 7 + ending |

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `logs_per_evidence` | int | 3 | Data logs unlocked per evidence |

---

### META-003: informant-1-whistleblower-unlock
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Whistleblower NPC unlockable
- [ ] Requires defeating Lobbyist once
- [ ] Provides gameplay hints

**Informant Info**:
- **Name**: "Deep Croak"
- **Unlock**: Defeat Lobbyist first time
- **Role**: Hints about boss patterns

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `informant_hint_count` | int | 3 | Hints per run from informant |

---

### META-004: informant-2-journalist-unlock
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Journalist NPC unlockable
- [ ] Requires defeating CEO once
- [ ] Provides lore/story context

**Informant Info**:
- **Name**: "Lily Padsworth"
- **Unlock**: Defeat CEO first time
- **Role**: Story exposition, ending hints

---

### META-005: informant-dialogue-system
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Dialogue tree structure
- [ ] Multiple dialogue options per informant
- [ ] Dialogue advances with progress

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `dialogue_text_speed` | float | 0.05 | Seconds per character |
| `dialogue_auto_advance` | float | 3.0 | Auto-advance delay |

---

### META-006: hint-system-3hints-per-run
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] 3 hints available per run
- [ ] Hints context-sensitive
- [ ] Hint counter visible in HUD

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `hints_per_run` | int | 3 | Starting hint count |
| `hint_cooldown` | float | 30.0 | Seconds between hint requests |

---

### META-007: run-completion-reward-evidence
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Run completion grants rewards
- [ ] Failed runs partial progress
- [ ] Victory runs bonus progress

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `death_progress_kept` | float | 0.5 | % of run progress kept on death |
| `victory_bonus` | float | 1.5 | Victory reward multiplier |

---

### META-008: ending-unlock-all-evidence-condition
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Ending requires all 7 data logs
- [ ] Both bosses must be defeated at least once
- [ ] Final connection unlocks ending

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `required_logs` | int | 7 | Logs needed for ending |
| `show_completion_percent` | bool | true | Display completion % |

---

## Files to Create

| File | Purpose |
|------|---------|
| `metagame/scripts/meta_progression.gd` | Core progression logic |
| `metagame/scripts/evidence_manager.gd` | Evidence tracking |
| `metagame/scripts/informant_manager.gd` | Informant unlocks |
| `metagame/scripts/dialogue_system.gd` | Dialogue handler |
| `metagame/scripts/hint_system.gd` | Hint management |
| `metagame/resources/informants/*.tres` | Informant definitions |
| `test/unit/test_meta_progression.gd` | Tests |

---

## Success Metrics

- 8 stories completed
- Persistent progression working
- 2 informants unlockable
- Ending condition achievable

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
