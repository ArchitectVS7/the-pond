# Epic Runner Instructions

## Usage
Pass this file to Claude Code with the Epic number:

```bash
claude --prompt "Run Epic-XXX using the workflow in .thursian/projects/pond-conspiracy/scripts/run-epic.md"
```

## Epic Execution Workflow

### Phase 1: Initialize
1. Read the Epic plan from `.thursian/projects/pond-conspiracy/planning/01-MVP/Epic-XXX.md`
2. Read `DEVELOPERS_MANUAL.md` for prior context and blocked items
3. Create todos for all stories in the Epic

### Phase 2: Execute Stories
For each story in dependency order:

#### Step A: CODER Agent
```
Spawn coder agent with:
- Story ID and acceptance criteria
- Test cases from plan
- Implementation steps
- Tunable parameters to extract
```

#### Step B: REVIEWER Agent
```
Spawn reviewer agent with:
- Adversarial review checklist from plan
- Architecture compliance check
- Code quality validation
- Performance requirements
```

#### Step C: TESTER Agent
```
Spawn tester agent with:
- Test cases from plan
- Run GUT tests
- Validate all tests pass
- Report any failures
```

#### Step D: Complete Story
1. Update DEVELOPERS_MANUAL.md with tunable parameters
2. Git commit with story ID
3. Mark story complete in todos
4. Proceed to next story

### Phase 3: Epic Complete
1. Verify all stories passed
2. Document any blocked items
3. Git commit with Epic completion message
4. Report: "Epic-XXX complete. X stories passed, Y blocked."

## Blocker Handling
If a story has blockers:
1. Skip the blocked steps
2. Note in DEVELOPERS_MANUAL.md under "## Blocked Steps"
3. Proceed to next story
4. Do NOT stop the Epic

## Agent Spawning Pattern

```javascript
// In single message, spawn all three for a story:
Task("CODER", "[story details]", "coder")
// Wait for completion
Task("REVIEWER", "[review checklist]", "reviewer")
// Wait for completion
Task("TESTER", "[test cases]", "tester")
```
