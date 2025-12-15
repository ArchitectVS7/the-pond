# Template Reference Guide

Complete specification of the 5 core GENESIS templates.

## Overview

The GENESIS pipeline uses **template-based architecture** where 5 reusable patterns handle all 12 phases. Each template is a parameterized state machine that can be customized through configuration.

## Template Types

| Template | File | Used In Phases | Agent Count | Complexity |
|----------|------|----------------|-------------|------------|
| dialectic | dialectic.yaml | 1 | 4 (2 primary + facilitator + synthesizer) | Low |
| roundtable | roundtable.yaml | 2, 4, 10, 11 | 3-17 (facilitator + N participants + researcher + synthesizer) | Medium |
| engineering-board | engineering-board.yaml | 3, 5, 6, 8, 12 | 4-10 (chair + members + researcher + writer) | High |
| planning-session | planning-session.yaml | 7a, 7b | 4-8 (lead + experts + writer) | High |
| build-cycle | build-cycle.yaml | 9 | 8-12 (orchestrator + developers + reviewers + testers) | Very High |

---

## 1. Dialectic Template

**Purpose**: Two-agent creative conversation with synthesis

**Original File**: `.thursian/templates/dialectic.yaml`

### Parameters

```yaml
required:
  agent_a: Agent configuration (expansive thinker)
  agent_b: Agent configuration (practical thinker)
  context_input: File reference (input document)
  output_path: Path template for output

optional:
  synthesizer: Agent config (default: default_synthesizer)
  exit_condition: rounds | consensus | aha_moment | facilitator_call
  max_rounds: integer (default: 8)
  min_rounds: integer (default: 4)
  output_format: vision | recommendation | decision | synthesis
  parallel_research: boolean (default: false)
```

### Agent Slots

1. **agent_a** (dialectic_participant)
   - Role: Expansive thinking
   - Tools: memory.read, memory.write
   - Interaction: Speaks to agent_b, listens to agent_b & facilitator

2. **agent_b** (dialectic_participant)
   - Role: Grounding thinking
   - Tools: memory.read, memory.write
   - Interaction: Speaks to agent_a, listens to agent_a & facilitator

3. **facilitator** (conversation_manager)
   - Role: Manages flow, evaluates exit conditions
   - Tools: memory.read, memory.write
   - Can intervene: Yes

4. **researcher** (background_researcher) - Optional
   - Enabled by: parallel_research parameter
   - Tools: memory.read, memory.write, web.search, web.fetch
   - Runs: Parallel to conversation

5. **synthesizer** (output_writer)
   - Role: Creates final document
   - Tools: memory.read, filesystem.write
   - Output: Formatted document based on output_format

### Workflow States

1. **initialize**: Load context, prepare session
2. **open_dialectic**: Frame conversation, invite first exchange
3. **dialectic_round**: One round of agent_a → agent_b exchange
4. **evaluate_round**: Check exit conditions
5. **prepare_synthesis**: Create synthesis brief
6. **synthesize_output**: Generate final document
7. **synthesis_complete**: Final state

### Exit Conditions

- **rounds**: current_round >= max_rounds
- **consensus**: agents_agree_on_direction (detected by facilitator)
- **aha_moment**: breakthrough_detected (keyword triggers)
- **facilitator_call**: facilitator_determines_complete (manual)

### Output Formats

**vision**:
- Executive Summary
- Vision Statement
- Key Themes
- Opportunities
- Constraints
- Next Steps

**recommendation**:
- Summary
- Recommendation
- Rationale
- Alternatives Considered
- Risks

**decision**:
- Decision
- Context
- Implications
- Action Items

**synthesis**:
- Overview
- Key Insights
- Tensions Resolved
- Open Questions

### Usage Example (Phase 1)

```json
{
  "template": "dialectic",
  "parameters": {
    "agent_a": "personas/ideation/dreamer.md",
    "agent_b": "personas/ideation/doer.md",
    "synthesizer": "personas/ideation/synthesizer.md",
    "context_input": "ideas/initial-idea.md",
    "output_path": "visions/vision-v1.md",
    "exit_condition": "aha_moment",
    "max_rounds": 8,
    "min_rounds": 4,
    "output_format": "vision"
  }
}
```

---

## 2. Roundtable Template

**Purpose**: Multi-persona structured discussion with rounds

**Original File**: `.thursian/templates/roundtable.yaml`

### Parameters

```yaml
required:
  facilitator: Agent configuration
  participants: List of agent configurations (3-15)
  context_input: File reference list
  output_path: Path template for output

optional:
  discussion_topic: string
  round_count: integer (default: 5)
  round_structure: open | guided | section_by_section
  parallel_research: boolean (default: false)
  researcher: Agent config
  synthesizer: Agent config
  output_type: feedback_report | test_report | validation_report | recommendation
  capture_evidence: boolean (default: false)
  evidence_input: Directory reference (for testing)
  triage_output: boolean (default: true)
  triage_categories: string list
```

### Agent Slots

1. **facilitator** (discussion_leader)
   - Manages discussion flow
   - Ensures all voices heard
   - Keeps discussion focused

2. **participants** (discussion_participants)
   - Count: Dynamic (from parameter)
   - Provides: Perspective from persona
   - Speaks: In turn or when called

3. **researcher** (background_researcher) - Optional
   - Runs parallel research
   - Contributes supporting evidence

4. **synthesizer** (report_writer)
   - Creates final report
   - Formats based on output_type

### Default Round Structure

```yaml
Round 1: "Initial Reactions" - What stands out?
Round 2: "Expanding" - Adjacent possibilities
Round 3: "Deep Dive" - Core aspects
Round 4: "Pain Points" - Concerns and gaps
Round 5: "Final Thoughts" - Overall assessment
```

### Workflow States

1. **initialize**: Load context, prepare participants
2. **open_discussion**: Welcome and frame discussion
3. **discussion_round**: Multi-participant round
   - facilitator_opens: Announces round
   - participant_responses: Each participant contributes
   - facilitator_synthesizes: Summarizes round
4. **increment_and_continue**: Move to next round
5. **prepare_synthesis**: Prepare report brief
6. **create_report**: Generate final report
7. **report_complete**: Final state

### Output Types

**feedback_report**:
- Executive Summary
- Participant Profiles
- Round-by-Round Summary
- Key Themes
- Feedback Triage
- Recommendations

**test_report**:
- Executive Summary
- Test Scope
- Participant Feedback
- Issues Found (bugs, UX, missing features)
- Severity Triage
- Evidence Gallery
- Next Steps

**validation_report**:
- Validation Summary
- Criteria Evaluation
- Stakeholder Positions
- Concerns Raised
- Approval Status
- Conditions (if any)

**recommendation**:
- Summary
- Discussion Highlights
- Recommendation
- Supporting Rationale
- Dissenting Views
- Action Items

### Triage System

Feedback is automatically categorized. Default categories:
- **critical**: Must address immediately
- **high**: Should address soon
- **medium**: Address when possible
- **low**: Nice to have
- **out_of_scope**: Beyond current scope

Custom categories per use case:
- **Phase 2**: love_it, like_it, concerned, dealbreaker, suggestion
- **Phase 10**: critical_must_fix, high_should_fix, medium_backlog, low_nice_to_have
- **Phase 11**: critical_blocker, should_fix_pre_launch, backlog, nice_to_have

### Usage Examples

**Phase 2 (Focus Group)**:
```json
{
  "template": "roundtable",
  "parameters": {
    "facilitator": "personas/facilitation/facilitator.md",
    "participants": [
      "personas/focus-group/casual-gamer.md",
      "personas/focus-group/ecology-enthusiast.md",
      "personas/focus-group/strategy-fan.md",
      "personas/focus-group/story-driven-player.md",
      "personas/focus-group/indie-developer.md"
    ],
    "context_input": ["visions/vision-v1.md"],
    "output_path": "focus-groups/report.md",
    "round_count": 5,
    "output_type": "feedback_report",
    "triage_categories": ["love_it", "like_it", "concerned", "dealbreaker", "suggestion"]
  }
}
```

**Phase 10 (Alpha Testing)**:
```json
{
  "template": "roundtable",
  "parameters": {
    "facilitator": "personas/engineering/engineering-manager.md",
    "participants": [/* stakeholders */],
    "context_input": ["build/build-summary.md", "testing/test-report.md"],
    "evidence_input": "testing/screenshots/",
    "output_path": "alpha/alpha-report.md",
    "output_type": "test_report",
    "capture_evidence": true,
    "triage_categories": ["critical_must_fix", "high_should_fix", "medium_backlog", "low_nice_to_have", "out_of_scope"]
  }
}
```

---

## 3. Engineering Board Template

**Purpose**: Technical evaluation, decision-making, document creation

**Original File**: `.thursian/templates/engineering-board.yaml`

### Parameters

```yaml
required:
  board_chair: Agent configuration
  board_members: List of agent configurations
  context_input: File reference list
  output_path: Path template
  evaluation_type: create | review | triage | approve | design

optional:
  researcher: Agent config
  writer: Agent config
  output_type: prd | triage_report | approval_report | adrs | architecture
  approval_threshold: float (0.0-1.0, for approve type)
  max_iterations: integer (for approve type)
  triage_categories: list (for triage type)
  spawn_substages: boolean (for design type)
  substage_domains: list (for design type)
```

### Agent Slots

1. **board_chair** (board_leader)
   - Leads board session
   - Manages voting/consensus
   - Enforces process

2. **board_members** (evaluators)
   - Count: Varies by evaluation_type
   - Expertise: Domain-specific
   - Vote/evaluate based on dimensions

3. **researcher** (technical_researcher) - Optional
   - Technical research
   - Precedent analysis
   - Best practices

4. **writer** (document_author)
   - Creates final output
   - Formats per output_type

### Evaluation Types

**create**:
- Purpose: Create new documents (PRD, design docs)
- Pattern: Brainstorm → Draft → Review → Finalize
- Iterations: Multiple passes
- Output: Major document

**review**:
- Purpose: Review existing documents
- Pattern: Read → Evaluate → Recommend
- Iterations: Single pass
- Output: Review report

**triage**:
- Purpose: Categorize and prioritize items
- Pattern: List items → Evaluate each → Assign category
- Categories: Configurable
- Output: Triage report

**approve**:
- Purpose: Go/no-go decision with scoring
- Pattern: Evaluate dimensions → Score → Vote → Decide
- Threshold: Required score for approval
- Output: Approval report

**design**:
- Purpose: Create architecture with substages
- Pattern: Overview → Spawn domain substages → Create ADRs → Synthesize
- Substages: Parallel domain-specific deep dives
- Output: Architecture overview + ADRs

### Workflow States (vary by type)

**create**:
1. initialize → 2. brainstorm → 3. draft → 4. review → 5. finalize → 6. complete

**triage**:
1. initialize → 2. load_items → 3. evaluate_item (loop) → 4. create_report → 5. complete

**approve**:
1. initialize → 2. evaluate_dimensions → 3. score → 4. vote → 5. decide → 6. complete

**design** (with substages):
1. initialize → 2. main_board_session → 3. spawn_substages (parallel) → 4. collect_adrs → 5. synthesize_overview → 6. complete

### Approval Dimensions (Phase 8)

| Dimension | Weight | Description |
|-----------|--------|-------------|
| Upstream Traceability | 20% | Stories map to requirements |
| Downstream Completeness | 15% | Nothing missing |
| Task Atomicity | 15% | Stories right-sized |
| Quality Gates | 15% | Testing strategy solid |
| Expertise Assignment | 15% | Right skills matched |
| Dependency Clarity | 10% | Build order clear |
| Document Consistency | 10% | No contradictions |

### Substage Domains (Phase 6)

**Required**:
- platform_deployment
- system_structure
- communication_patterns
- data_architecture
- authentication_security
- tech_stack

**Optional** (if applicable):
- frontend_architecture
- mobile_architecture
- api_design
- scalability_performance
- observability

### Usage Examples

**Phase 3 (PRD Creation)**:
```json
{
  "template": "engineering-board",
  "parameters": {
    "board_chair": "personas/engineering/engineering-manager.md",
    "board_members": [
      "personas/engineering/technical-lead.md",
      "personas/engineering/product-manager.md",
      "personas/engineering/qa-lead.md",
      "personas/engineering/ux-lead.md"
    ],
    "writer": "personas/ideation/synthesizer.md",
    "context_input": ["visions/vision-v1.md", "focus-groups/report.md"],
    "output_path": "prds/prd-v1.md",
    "evaluation_type": "create",
    "output_type": "prd"
  }
}
```

**Phase 6 (Architecture)**:
```json
{
  "template": "engineering-board",
  "parameters": {
    "board_chair": "personas/architecture/chief-architect.md",
    "board_members": [/* all architects */],
    "evaluation_type": "design",
    "output_type": "architecture",
    "spawn_substages": true,
    "substage_domains": {
      "required": ["platform_deployment", "system_structure", "communication_patterns", "data_architecture", "authentication_security", "tech_stack"],
      "optional": ["frontend_architecture"]
    },
    "output_path": "design-docs/architecture-overview.md"
  }
}
```

**Phase 8 (Approval Gate)**:
```json
{
  "template": "engineering-board",
  "parameters": {
    "evaluation_type": "approve",
    "output_type": "approval_report",
    "approval_threshold": 0.95,
    "max_iterations": 3,
    "review_dimensions": [
      {"id": "upstream_traceability", "weight": 0.20},
      {"id": "downstream_completeness", "weight": 0.15},
      {"id": "task_atomicity", "weight": 0.15},
      {"id": "quality_gates", "weight": 0.15},
      {"id": "expertise_assignment", "weight": 0.15},
      {"id": "dependency_clarity", "weight": 0.10},
      {"id": "document_consistency", "weight": 0.10}
    ]
  }
}
```

---

## 4. Planning Session Template

**Purpose**: Structured work breakdown with iterative refinement

**Original File**: `.thursian/templates/planning-session.yaml`

### Parameters

```yaml
required:
  lead_planner: Agent configuration
  domain_experts: List of agent configurations
  writer: Agent configuration
  context_input: File reference list
  output_path: Path template
  planning_level: epic | story | task

optional:
  iteration_stages: integer (1-5, default: 1)
  stage_definitions: list of stage configs
  traceability_required: boolean
  traceability_source: file reference
  output_type: epics | stories | tasks | recipes | schedule
  include_dependencies: boolean
  include_resources: boolean
  include_milestones: boolean
```

### Planning Levels

**epic**:
- Breaks architecture into major work streams
- Produces epic definitions with story slugs
- Minimal detail, high-level planning

**story**:
- Expands story slugs into detailed user stories
- Iterates through 5 refinement stages
- Produces implementation recipes

**task**:
- Breaks stories into granular tasks
- Hour/day-level estimates
- Direct assignment to developers

### Iteration Stages (Story Level)

**Stage 1 - Initial Expansion**:
- User story format
- Acceptance criteria
- Priority

**Stage 2 - Technical Deep Dive**:
- Implementation approach
- Files to modify
- Patterns to use
- Complexity estimate

**Stage 3 - Dependency & Blocker Analysis**:
- Technical dependencies
- Potential blockers
- Mitigation strategies

**Stage 4 - Quality & Testing Strategy**:
- Test cases (unit, integration, e2e)
- Quality gates
- Performance requirements

**Stage 5 - Recipe Finalization**:
- Step-by-step guide
- Checkpoints
- Definition of done
- Adversarial review checklist

### Workflow States

1. **initialize**: Load context
2. **planning_round**: One iteration stage
   - lead_planner_opens: Frame the stage
   - experts_contribute: Domain-specific input
   - writer_documents: Capture decisions
3. **next_stage**: Move to next iteration (if story level)
4. **create_output**: Generate final documents
5. **complete**: Final state

### Traceability System

When `traceability_required: true`:
- Each epic/story linked to PRD requirement
- Traceability matrix generated
- Orphan detection (stories without requirements)
- Coverage analysis (requirements without stories)

### Usage Examples

**Phase 7a (Epic Planning)**:
```json
{
  "template": "planning-session",
  "parameters": {
    "lead_planner": "personas/planning/project-manager.md",
    "domain_experts": [
      "personas/engineering/engineering-manager.md",
      "personas/engineering/technical-lead.md",
      "personas/engineering/product-manager.md"
    ],
    "writer": "personas/planning/project-manager.md",
    "context_input": ["design-docs/architecture-overview.md", "design-docs/PRD-v0.2.md"],
    "output_path": "planning/",
    "planning_level": "epic",
    "iteration_stages": 1,
    "traceability_required": true,
    "traceability_source": "design-docs/PRD-v0.2.md",
    "output_type": "epics",
    "include_dependencies": true,
    "include_resources": true,
    "include_milestones": true
  }
}
```

**Phase 7b (Story Planning)**:
```json
{
  "template": "planning-session",
  "parameters": {
    "lead_planner": "personas/planning/project-manager.md",
    "domain_experts": [/* technical experts */],
    "planning_level": "story",
    "iteration_stages": 5,
    "stage_definitions": [
      {"stage": 1, "name": "Initial Expansion", "focus": ["description", "acceptance_criteria"]},
      {"stage": 2, "name": "Technical Deep Dive", "focus": ["approach", "files", "patterns", "complexity"]},
      {"stage": 3, "name": "Dependency & Blocker Analysis", "focus": ["dependencies", "blockers", "mitigations"]},
      {"stage": 4, "name": "Quality & Testing Strategy", "focus": ["testing_approach", "acceptance_tests", "quality_gates"]},
      {"stage": 5, "name": "Recipe Finalization", "focus": ["step_by_step", "checkpoints", "validation"]}
    ],
    "output_type": "recipes"
  }
}
```

---

## 5. Build Cycle Template

**Purpose**: Implementation with code review and testing

**Original File**: `.thursian/templates/build-cycle.yaml`

### Parameters

```yaml
required:
  orchestrator: Agent configuration
  developers: List of agent configurations
  reviewers: List of agent configurations
  testers: List of agent configurations
  spec_validator: Agent configuration
  evidence_collector: Agent configuration
  task_queue: File reference (implementation guide)
  output_path: Path template
  build_mode: initial | fix | feature_add | refactor

optional:
  scope: full | targeted | single
  target_items: list (for targeted scope)
  test_automation: none | unit | integration | e2e | full
  automation_framework: playwright | cypress | selenium
  evidence_capture: boolean
  max_review_iterations: integer
  coverage_threshold: float (0.0-1.0)
  architecture_docs: list of file references
```

### Build Modes

**initial**:
- First implementation
- All MVP stories
- Full test suite creation

**fix**:
- Bug fixes from testing
- Targeted scope
- Focus on specific issues

**feature_add**:
- Add new features post-MVP
- Incremental additions
- Integration with existing code

**refactor**:
- Code improvements
- No functionality changes
- Performance/maintainability

### Workflow States

1. **initialize**: Load task queue, prepare build
2. **assign_task**: Orchestrator assigns story to developer
3. **implement**: Developer writes code
4. **review**: Reviewer performs adversarial review
   - Architecture compliance
   - Code quality
   - Security
   - Performance
5. **test**: Testers run automated tests
   - Unit tests
   - Integration tests
   - E2E tests
6. **validate_spec**: Spec validator checks acceptance criteria
7. **capture_evidence**: Evidence collector takes screenshots/videos
8. **decide**: Pass → next task, Fail → iterate (max 3 times)
9. **next_task**: Move to next story
10. **complete**: All tasks done

### Review Dimensions

- **Architecture Compliance**: Follows ADRs and patterns
- **Code Quality**: Clean, maintainable, documented
- **Security**: No vulnerabilities
- **Performance**: Meets requirements
- **Test Coverage**: Adequate test coverage

### Test Automation Levels

- **none**: Manual testing only
- **unit**: Unit tests only
- **integration**: Unit + integration tests
- **e2e**: Unit + integration + end-to-end
- **full**: All above + performance + security

### Evidence Collection

When `evidence_capture: true`:
- Screenshots of UI
- Video recordings of workflows
- Performance metrics
- Test results
- Build artifacts

### Usage Example (Phase 9)

```json
{
  "template": "build-cycle",
  "parameters": {
    "orchestrator": "personas/planning/project-manager.md",
    "developers": [
      "personas/development/senior-developer.md",
      "personas/development/backend-developer.md",
      "personas/development/frontend-developer.md"
    ],
    "reviewers": [
      "personas/development/code-reviewer.md",
      "personas/architecture/security-architect.md"
    ],
    "testers": [
      "personas/testing/test-lead.md",
      "personas/testing/e2e-tester.md",
      "personas/testing/integration-tester.md"
    ],
    "spec_validator": "personas/engineering/qa-lead.md",
    "evidence_collector": "personas/ideation/synthesizer.md",
    "task_queue": "planning/implementation-guide.md",
    "architecture_docs": ["design-docs/architecture-overview.md", "design-docs/adrs/"],
    "output_path": "build/",
    "evidence_path": "testing/",
    "build_mode": "initial",
    "scope": "full",
    "test_automation": "full",
    "automation_framework": "playwright",
    "evidence_capture": true,
    "max_review_iterations": 3,
    "coverage_threshold": 0.80
  }
}
```

---

## Template Composition Patterns

### Sequential Chaining
Phase → Phase → Phase
```
Phase 1 (dialectic) → Phase 2 (roundtable) → Phase 3 (engineering-board)
```

### Conditional Branching
```
Phase 10 (roundtable:test_report)
  └─> If critical_issues → Phase 9 (build-cycle:fix)
  └─> Else → Phase 11
```

### Iterative Loops
```
Phase 7b: planning-session (iteration_stages: 5)
  Stage 1 → Stage 2 → Stage 3 → Stage 4 → Stage 5
```

### Parallel Substages
```
Phase 6: engineering-board (spawn_substages: true)
  ├─> Substage: Platform Deployment
  ├─> Substage: System Architecture
  ├─> Substage: Communication Patterns
  └─> ... (all run in parallel)
```

---

## Customizing Templates

### Adding New Output Formats

Edit template YAML:
```yaml
output_templates:
  custom_format:
    title: "Custom Document"
    sections:
      - name: custom_section
        description: "Your section"
```

### Modifying Agent Roles

Add new agent slot:
```yaml
agents:
  - id: new_agent
    role: custom_role
    persona_file: .thursian/personas/custom/agent.md
    tools: [memory.read, memory.write]
```

### Extending Workflow States

Add custom state:
```yaml
states:
  custom_state:
    agent: agent_id
    description: "Custom processing"
    actions:
      - type: custom_action
    transitions:
      on_success: next_state
```

---

## Best Practices

1. **Persona Consistency**: Use same personas across phases for continuity
2. **Memory Namespaces**: Organize by `{pipeline}/{project}/{phase}`
3. **Artifact Naming**: Follow convention `{phase}-{type}-{version}.md`
4. **Exit Conditions**: Balance min_rounds vs quality (don't exit too early)
5. **Triage Categories**: Align with release phases (MVP, Alpha, Beta)
6. **Review Iterations**: Limit to 3 max to avoid infinite loops
7. **Evidence Capture**: Enable for testing phases, disable for planning
8. **Parallel Research**: Enable for complex phases (3, 6), disable for simple

---

**Next**: See [04-Persona-System.md](04-Persona-System.md) for agent personality details.
