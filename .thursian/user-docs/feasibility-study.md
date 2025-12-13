 Based on my analysis of your workflow system, I can provide comprehensive recommendations for each of your questions. Let me organize this systematically:     

  (a) File Location & Organization Analysis

  Current State Assessment

  Good News: Your workflows are logically organized, but there are inconsistencies that need addressing.

  Recommended Structure

  .thursian/
  ├── workflows/                          # ← ALL workflow definitions here
  │   ├── 00-metadata.yaml               # ← NEW: Master workflow registry
  │   ├── 01-ideation-flow.yaml         # ← RENAME from 02-ideation-flow.yaml
  │   ├── 02-focus-group-flow.yaml      # ← RENAME from 03-focus-group-flow.yaml
  │   ├── 03-engineering-meeting-flow.yaml # ← RENAME from 04-
  │   ├── 04-stakeholder-review-flow.yaml  # ← RENAME from 05-
  │   └── 05-technical-design-flow.yaml    # ← Future workflow
  │
  ├── agents/                             # ← Core system agents
  │   ├── orchestrator.md
  │   ├── planner.md
  │   ├── developer.md
  │   ├── reviewer.md
  │   └── executive-proxy.md
  │
  ├── personas/                           # ← NEW: All workflow personas
  │   ├── ideation/
  │   │   ├── dreamer.md
  │   │   ├── doer.md
  │   │   └── synthesizer.md
  │   ├── focus-group/
  │   │   ├── facilitator.md
  │   │   └── researcher.md
  │   ├── engineering/
  │   │   ├── technical-lead.md
  │   │   ├── product-manager.md
  │   │   ├── marketing-analyst.md
  │   │   ├── ux-lead.md
  │   │   └── technical-researcher.md
  │   └── stakeholder/
  │       └── engineering-manager.md
  │
  ├── projects/                           # ← NEW: Per-project workspace
  │   └── {project-name}/                # e.g., pond-conspiracy
  │       ├── metadata.json              # ← NEW: Project metadata
  │       ├── ideas/
  │       │   └── initial-idea.md
  │       ├── visions/
  │       │   └── vision-v1.md
  │       ├── focus-groups/
  │       │   ├── report.md
  │       │   └── conversations/
  │       │       └── full-transcript.md
  │       ├── prds/
  │       │   ├── prd-v1.md
  │       │   └── stakeholder-feedback.md
  │       └── sessions/                  # ← NEW: Session logs
  │           ├── 2025-12-13_ideation.json
  │           ├── 2025-12-13_focus-group.json
  │           └── workflow-state.json
  │
  ├── templates/                          # ← Move from ideation/docs
  │   ├── idea-template.md
  │   ├── vision-template.md
  │   ├── focus-group-template.md
  │   ├── prd-template.md
  │   └── stakeholder-feedback-template.md
  │
  └── docs/                              # ← Documentation & guides
      ├── workflows/
      │   ├── ideation-guide.md
      │   ├── focus-group-guide.md
      │   ├── engineering-guide.md
      │   └── stakeholder-guide.md
      └── examples/
          └── pond-conspiracy/           # Full example project

  Key Changes:

  1. Consolidate workflows in .thursian/workflows/
  2. Separate agents from personas - agents are system-level, personas are workflow-specific
  3. Project-centric structure - each project gets its own folder with all artifacts
  4. Add metadata tracking - both at workflow and project level

  ---
  (b) Additional Files Needed

  1. Workflow Metadata Registry (.thursian/workflows/00-metadata.yaml)

  name: thursian-workflow-registry
  version: 2.0.0
  description: Master registry of all Thursian workflows

  workflows:
    - id: ideation
      file: 01-ideation-flow.yaml
      name: "Ideation: Dreamer ↔ Doer Dialectic"
      description: "Transform raw ideas into exciting, feasible visions"
      inputs: [idea-file]
      outputs: [vision-document]
      next_workflow: focus-group
      status: active

    - id: focus-group
      file: 02-focus-group-flow.yaml
      name: "Focus Group: Multi-Persona Validation"
      description: "Validate vision with domain-specific user personas + parallel research"
      inputs: [vision-document]
      outputs: [focus-group-report]
      next_workflow: engineering-meeting
      status: active

    - id: engineering-meeting
      file: 03-engineering-meeting-flow.yaml
      name: "Engineering Meeting: Technical PRD Creation"
      description: "Transform validated vision into comprehensive PRD with technical research"
      inputs: [focus-group-report]
      outputs: [prd-document, technical-research-report]
      next_workflow: stakeholder-review
      status: active

    - id: stakeholder-review
      file: 04-stakeholder-review-flow.yaml
      name: "Stakeholder Review: PRD Validation"
      description: "Validate PRD with original ideation team and focus group participants"
      inputs: [prd-document]
      outputs: [approved-prd, stakeholder-feedback]
      next_workflow: technical-design
      status: active

    - id: technical-design
      file: 05-technical-design-flow.yaml
      name: "Technical Design: Architecture & Implementation Plan"
      description: "Create detailed technical design from approved PRD"
      inputs: [approved-prd]
      outputs: [technical-design-document]
      next_workflow: development
      status: planned

  execution_modes:
    - id: full-pipeline
      name: "Complete Ideation → Development Pipeline"
      workflows: [ideation, focus-group, engineering-meeting, stakeholder-review, technical-design]
      mode: sequential

    - id: ideation-to-prd
      name: "Ideation → PRD (No Development)"
      workflows: [ideation, focus-group, engineering-meeting, stakeholder-review]
      mode: sequential

  2. Project Metadata Template (.thursian/templates/project-metadata.json)

  {
    "project_name": "{{project-name}}",
    "created_at": "{{timestamp}}",
    "created_by": "{{user}}",
    "status": "in-progress",
    "current_workflow": "ideation",
    "completed_workflows": [],
    "next_workflow": "focus-group",

    "workflows": {
      "ideation": {
        "status": "in-progress",
        "started_at": "{{timestamp}}",
        "completed_at": null,
        "session_id": "ideation-{{session-id}}",
        "artifacts": []
      },
      "focus-group": {
        "status": "pending",
        "started_at": null,
        "completed_at": null,
        "session_id": null,
        "artifacts": []
      },
      "engineering-meeting": {
        "status": "pending",
        "started_at": null,
        "completed_at": null,
        "session_id": null,
        "artifacts": []
      },
      "stakeholder-review": {
        "status": "pending",
        "started_at": null,
        "completed_at": null,
        "session_id": null,
        "artifacts": []
      }
    },

    "tags": ["{{domain}}", "{{category}}"],
    "domain": "{{auto-detected-domain}}",
    "target_audience": [],

    "artifacts": {
      "idea": ".thursian/projects/{{project-name}}/ideas/initial-idea.md",
      "vision": ".thursian/projects/{{project-name}}/visions/vision-v1.md",
      "focus_group_report": ".thursian/projects/{{project-name}}/focus-groups/report.md",
      "prd": ".thursian/projects/{{project-name}}/prds/prd-v1.md",
      "approved_prd": null
    },

    "memory": {
      "backend": "agentdb",
      "session_namespace": "{{project-name}}",
      "persistence": true
    }
  }

  3. Session State Tracker (.thursian/templates/session-state.json)

  {
    "session_id": "{{workflow-name}}-{{timestamp}}",
    "workflow": "{{workflow-name}}",
    "project_name": "{{project-name}}",
    "started_at": "{{timestamp}}",
    "updated_at": "{{timestamp}}",
    "status": "in-progress",

    "agents": {
      "active": ["dreamer", "doer"],
      "completed": [],
      "pending": ["synthesizer"]
    },

    "state_machine": {
      "current_state": "round_3_dreamer",
      "previous_state": "round_2_doer",
      "next_state": "round_3_doer",
      "total_states": 19,
      "completed_states": 5
    },

    "memory_keys": [
      "conversations/round_1_dreamer",
      "conversations/round_1_doer",
      "conversations/round_2_dreamer",
      "conversations/round_2_doer",
      "conversations/round_3_dreamer"
    ],

    "artifacts_generated": [],

    "resume_instructions": "Resume from round_3_doer state with memory context from all previous rounds"
  }

  4. Conversation Export Template (.thursian/templates/conversation-export.md)

  # {{Workflow Name}} - Full Conversation
  **Project:** {{project-name}}
  **Date:** {{date}}
  **Session ID:** {{session-id}}
  **Workflow:** {{workflow-name}}

  ---

  ## Metadata
  - **Domain:** {{domain}}
  - **Participants:** {{agent-list}}
  - **Duration:** {{duration}}
  - **Rounds Completed:** {{rounds-completed}}
  - **Status:** {{final-status}}

  ---

  ## Round 1: {{Round Title}}

  ### {{Agent 1 Name}}
  {{agent-1-response}}

  ### {{Agent 2 Name}}
  {{agent-2-response}}

  ---

  [Continue for all rounds...]

  ---

  ## Key Insights
  {{extracted-insights}}

  ## Decisions Made
  {{key-decisions}}

  ## Next Steps
  - **Next Workflow:** {{next-workflow}}
  - **Artifacts Generated:** {{artifacts-list}}
  - **Ready for:** {{next-phase}}

  5. N8N Integration Manifest (.thursian/integrations/n8n-manifest.json)

  {
    "integration_type": "n8n",
    "version": "1.0.0",

    "workflows": [
      {
        "id": "thursian-full-pipeline",
        "name": "Thursian: Idea → PRD Pipeline",
        "trigger": "manual",
        "nodes": [
          {
            "type": "webhook",
            "name": "Start Pipeline",
            "config": {
              "method": "POST",
              "path": "/thursian/start",
              "responseMode": "onReceived"
            }
          },
          {
            "type": "function",
            "name": "Initialize Project",
            "code": "// Create project metadata\n// Generate session ID\n// Set up directory structure"
          },
          {
            "type": "ssh",
            "name": "Run Ideation Flow",
            "config": {
              "command": "npx claude-code-cli run-workflow ideation --project {{project-name}}",
              "authentication": "privateKey"
            }
          },
          {
            "type": "code",
            "name": "Check Ideation Status",
            "code": "// Poll for completion\n// Extract artifacts"
          },
          {
            "type": "ssh",
            "name": "Deploy Focus Group Swarm",
            "config": {
              "command": "npx claude-flow@alpha swarm deploy --workflow focus-group --topology mesh --agents 7"
            }
          },
          {
            "type": "wait",
            "name": "Wait for Focus Group",
            "config": {
              "resume": "webhook",
              "amount": 30,
              "unit": "minutes"
            }
          },
          {
            "type": "ssh",
            "name": "Run Engineering Meeting",
            "config": {
              "command": "npx claude-code-cli run-workflow engineering-meeting --continuous"
            }
          },
          {
            "type": "code",
            "name": "Generate Final PRD",
            "code": "// Synthesize all artifacts\n// Create PRD document"
          }
        ]
      }
    ]
  }

  ---
  (c) Feasibility Study: N8N Integration with Claude Code CLI

  Integration Architecture

  ┌─────────────────────────────────────────────────────────────┐
  │                       N8N Orchestrator                       │
  │  (External workflow engine for tight control)                │
  └─────────────────────────────┬───────────────────────────────┘
                                │
                                │ SSH Commands
                                │
          ┌─────────────────────┼─────────────────────┐
          │                     │                     │
          ▼                     ▼                     ▼
  ┌───────────────┐    ┌────────────────┐    ┌──────────────────┐
  │ Claude Code   │    │ Claude Flow    │    │ Continuous       │
  │ CLI           │    │ Swarm Manager  │    │ Claude           │
  │               │    │                │    │                  │
  │ • Single Task │    │ • Multi-Agent  │    │ • Run Until PR   │
  │ • Synchronous │    │ • Parallel     │    │ • Autonomous     │
  │ • Interactive │    │ • Coordinated  │    │ • Git-Driven     │
  └───────────────┘    └────────────────┘    └──────────────────┘

  Feasibility Analysis

  ✅ Highly Feasible Components:

  1. SSH Command Execution
    - N8N has native SSH node
    - Can execute claude CLI commands remotely
    - Supports authentication via SSH keys
  2. Claude Flow Integration
    - Already has MCP server (npx claude-flow@alpha mcp start)
    - Can deploy swarms programmatically
    - Supports topology configuration (mesh, hierarchical, etc.)
  3. State Management
    - N8N can store workflow state in databases
    - Can pass context between nodes
    - Supports webhooks for async resumption

  ⚠️ Moderate Challenges:

  1. Claude Code CLI Limitations
    - Claude Code is interactive by design
    - May require input during execution
    - Not designed for headless/automated use
    - Workaround: Use Claude Code's MCP tools programmatically instead
  2. Continuous Claude Integration
    - Continuous Claude expects Git operations
    - Requires repository setup
    - May conflict with N8N's orchestration
    - Workaround: Use for final implementation phase only, not ideation
  3. Session Persistence
    - Claude Code sessions are ephemeral
    - Need custom memory management via AgentDB
    - Workaround: Use claude-flow's memory coordination

  ❌ Not Feasible (Current State):

  1. Direct Claude Code CLI Automation
    - Claude Code expects human interaction
    - Cannot run fully headless
    - Alternative: Use MCP protocol directly

  Recommended Approach

  Option A: Hybrid MCP + N8N (Recommended)

  # N8N Workflow Node Sequence
  1. Webhook Trigger
     ↓
  2. Initialize Project (N8N Function)
     - Create project folder structure
     - Generate metadata.json
     - Set up memory namespaces
     ↓
  3. MCP: Initialize Ideation Swarm
     Command: npx claude-flow@alpha swarm init --topology hierarchical --agents 3
     ↓
  4. MCP: Run Ideation Workflow
     Command: npx claude-flow@alpha task orchestrate --task "Run ideation-flow.yaml for {{project}}"
     ↓
  5. Poll for Completion (N8N Loop)
     Command: npx claude-flow@alpha task status --task-id {{task-id}}
     ↓
  6. Extract Artifacts (N8N Function)
     - Read generated vision document
     - Update project metadata
     ↓
  7. MCP: Deploy Focus Group Swarm
     Command: npx claude-flow@alpha swarm init --topology mesh --agents 7
     ↓
  8. MCP: Run Focus Group
     Command: npx claude-flow@alpha task orchestrate --task "Run focus-group-flow.yaml"
     ↓
  ... (continue for remaining workflows)

  Advantages:
  - ✅ Claude Flow designed for automation
  - ✅ N8N provides orchestration layer
  - ✅ Can monitor progress via MCP status tools
  - ✅ Supports parallel agent execution
  - ✅ Memory persistence via AgentDB

  Disadvantages:
  - ⚠️ Requires claude-flow implementation of workflow execution
  - ⚠️ Need to build workflow → MCP task translation layer

  Option B: Direct SSH to Claude Code (Limited)

  # N8N SSH Node
  SSH Execute:
    command: |
      cd /path/to/project
      claude code --prompt "Run ideation workflow for {{project-name}}"
    mode: interactive  # Problem: Requires manual input

  Advantages:
  - ✅ Uses existing Claude Code
  - ✅ Familiar interface

  Disadvantages:
  - ❌ Cannot run headless
  - ❌ Requires manual interaction
  - ❌ Not suitable for automation
  - ❌ No programmatic control

  Option C: Continuous Claude for Implementation Only

  # Use Continuous Claude for final build phase
  N8N Node:
    type: ssh
    command: |
      npx continuous-claude \
        --task "Implement features from {{prd-path}}" \
        --repo {{repo-url}} \
        --branch feature/{{project-name}} \
        --until-pr

  Advantages:
  - ✅ Autonomous implementation
  - ✅ Creates PR automatically
  - ✅ Runs until completion

  Disadvantages:
  - ⚠️ Only suitable for implementation phase
  - ⚠️ Not for ideation/planning
  - ⚠️ Requires pre-existing codebase

  Final Recommendation: Layered Approach

  Phase 1: Ideation → PRD
  ├─ Orchestrator: N8N
  ├─ Execution: Claude Flow (MCP)
  └─ Agents: Swarm coordination

  Phase 2: Implementation
  ├─ Orchestrator: N8N
  ├─ Execution: Continuous Claude
  └─ Output: Pull Request

  Phase 3: Review & Merge
  ├─ Orchestrator: N8N
  ├─ Execution: GitHub Actions + Claude Code
  └─ Human: Final approval

  Implementation Roadmap

  1. Week 1-2: Restructure File Organization
    - Implement recommended directory structure
    - Create metadata templates
    - Add session state tracking
  2. Week 3-4: Build MCP Translation Layer
    - Convert workflow YAML → MCP task format
    - Implement workflow state machine in N8N
    - Add artifact extraction logic
  3. Week 5-6: N8N Workflow Development
    - Build N8N workflow for ideation → PRD pipeline
    - Add error handling and retry logic
    - Implement status monitoring
  4. Week 7-8: Integration Testing
    - Test full pipeline with real projects
    - Tune agent coordination
    - Optimize memory usage
  5. Week 9-10: Continuous Claude Integration
    - Add implementation phase automation
    - Configure Git workflows
    - Test PR creation

  Cost & Resource Estimates

  - Development Time: 8-10 weeks
  - Dependencies:
    - N8N (self-hosted or cloud)
    - Claude Flow MCP server
    - AgentDB for memory
    - SSH access to execution environment
    - Git repository for continuous-claude
  - Ongoing Costs:
    - Claude API usage (high during swarm execution)
    - N8N hosting (if cloud)
    - Storage for AgentDB

  Risk Assessment

  | Risk                                    | Probability | Impact | Mitigation                             |
  |-----------------------------------------|-------------|--------|----------------------------------------|
  | Claude Code not suitable for automation | High        | High   | Use MCP protocol directly              |
  | Workflow state loss between phases      | Medium      | High   | Implement robust session persistence   |
  | Agent coordination failures             | Medium      | Medium | Add retry logic and error recovery     |
  | High API costs during swarm execution   | High        | Medium | Implement cost limits and monitoring   |
  | N8N complexity overhead                 | Low         | Medium | Start simple, add complexity gradually |

  ---
  Summary of Recommendations

  (a) File Organization

  - ✅ Consolidate workflows in .thursian/workflows/
  - ✅ Separate agents from personas (system vs. workflow-specific)
  - ✅ Project-centric structure with metadata tracking
  - ✅ Consistent naming (01-, 02-, 03-, etc.)

  (b) Additional Files

  - ✅ Workflow registry (00-metadata.yaml)
  - ✅ Project metadata template
  - ✅ Session state tracker
  - ✅ Conversation export template for ALL workflows
  - ✅ N8N integration manifest

  (c) N8N Integration Feasibility

  - ✅ FEASIBLE using Claude Flow MCP + N8N orchestration
  - ⚠️ NOT FEASIBLE using direct Claude Code CLI automation
  - ✅ RECOMMENDED hybrid approach:
    - Phase 1 (Ideation → PRD): N8N + Claude Flow
    - Phase 2 (Implementation): N8N + Continuous Claude
    - Phase 3 (Review): N8N + GitHub Actions + Human