# MVP Epic Queue Orchestrator

## Purpose
Execute Epics 002-011 sequentially with context isolation to prevent drift.

## Epic Queue

| Order | Epic | Stories | Description |
|-------|------|---------|-------------|
| 1 | Epic-002 | 7 | BulletUpHell Integration |
| 2 | Epic-003 | 15 | Conspiracy Board UI |
| 3 | Epic-004 | 7 | Environmental Data Content |
| 4 | Epic-005 | 5 | Pollution Index UI |
| 5 | Epic-006 | 10 | Mutation System |
| 6 | Epic-007 | 10 | Boss Encounters |
| 7 | Epic-008 | 8 | Meta-Progression System |
| 8 | Epic-009 | 10 | Save System & Steam Cloud |
| 9 | Epic-010 | 10 | Platform Support |
| 10 | Epic-011 | 10 | Accessibility Features |

**Total: 92 stories**

## Execution Protocol

### For Each Epic:

1. **Spawn Story Orchestrator Agent**
   ```
   Task("Story Orchestrator Epic-XXX",
        "Execute all stories in Epic-XXX following run-epic.md workflow",
        "hierarchical-coordinator")
   ```

2. **Wait for Completion**
   - Agent reports: "Epic-XXX complete. X passed, Y blocked."

3. **Validate**
   - Check git log for story commits
   - Check DEVELOPERS_MANUAL.md for tunable params
   - Check for blocked items

4. **Store State**
   ```bash
   npx claude-flow@alpha hooks post-task --task-id "epic-XXX"
   ```

5. **Proceed to Next Epic**

### Context Isolation Rules

- Each Epic starts with FRESH context
- Read ONLY the Epic plan file at start
- DEVELOPERS_MANUAL.md is the cross-epic handoff doc
- Do NOT carry forward conversation context

## CLI Execution

### Option 1: One Epic at a Time (Recommended)
```bash
# Run one Epic, verify, then run next
claude --prompt "Execute Epic-002 following .thursian/projects/pond-conspiracy/scripts/run-epic.md"
# Verify completion, then:
claude --prompt "Execute Epic-003 following .thursian/projects/pond-conspiracy/scripts/run-epic.md"
```

### Option 2: Pipeline All (Autonomous)
```bash
npx claude-flow@alpha sparc pipeline "Execute Epics 002-011 from .thursian/projects/pond-conspiracy/planning/01-MVP/ using hierarchical coordination. Each Epic spawns story orchestrator. Stories use coder/reviewer/tester agents. State in DEVELOPERS_MANUAL.md."
```

## Success Criteria

- All 92 stories have git commits
- All tests pass
- DEVELOPERS_MANUAL.md has all tunable parameters
- Blocked items documented
