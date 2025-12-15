# N8N Version of GENESIS Pipeline

This directory contains N8N workflow implementations that replicate the GENESIS pipeline originally built with Claude-Flow and Claude Code.

## 📁 Directory Structure

```
docs/N8N-Version/
├── README.md                          # This file
├── guides/
│   ├── 01-GENESIS-Pipeline-Manual.md  # Complete documentation of the original system
│   ├── 02-N8N-Setup-Guide.md          # How to set up N8N for GENESIS
│   ├── 03-Template-Reference.md       # Deep dive into the 5 core templates
│   └── 04-Persona-System.md           # How personas work
├── workflows/
│   ├── phase-01-ideation.json         # N8N workflow for Phase 1
│   ├── phase-02-focus-group.json      # N8N workflow for Phase 2
│   ├── phase-03-engineering-meeting.json
│   ├── phase-04-stakeholder-review.json
│   ├── phase-05-triage.json
│   ├── phase-06-architecture.json
│   ├── phase-07a-epic-planning.json
│   ├── phase-07b-story-planning.json
│   ├── phase-08-approval-gate.json
│   ├── phase-09-build.json
│   ├── phase-10-alpha-testing.json
│   ├── phase-11-beta-testing.json
│   ├── phase-12-release.json
│   └── master-genesis-pipeline.json   # Full orchestration
└── examples/
    ├── pond-conspiracy-config.json    # Config used for the pond game
    ├── webhook-payloads.json          # Example webhook triggers
    └── agent-configurations.json      # Persona mappings

```

## 🎯 What This Is

The **original GENESIS system** ran directly in Claude Code using:
- **Claude Code's Task tool** to spawn agents
- **MCP tools** (claude-flow, ruv-swarm) for coordination
- **Template-based workflows** defined in YAML
- **Direct agent execution** without external orchestration

This **N8N version** replicates that entire system using:
- **N8N workflows** for orchestration
- **Webhook triggers** for phase execution
- **Claude API calls** for agent spawning
- **Persistent storage** for artifacts

## 📊 Comparison

| Feature | Original (Claude Code) | N8N Version |
|---------|----------------------|-------------|
| **Trigger** | Manual Claude Code commands | HTTP webhooks |
| **Orchestration** | Claude-Flow MCP tools | N8N workflow engine |
| **Agent Execution** | Task tool (direct) | HTTP → Claude API |
| **Memory** | AgentDB (local) | N8N database + file storage |
| **Artifacts** | Local filesystem | Configurable storage |
| **Monitoring** | CLI status | N8N dashboard |
| **Scalability** | Single machine | Distributed |

## 🚀 Quick Start

1. **Read the guides** (start with `guides/01-GENESIS-Pipeline-Manual.md`)
2. **Set up N8N** (follow `guides/02-N8N-Setup-Guide.md`)
3. **Import workflows** from the `workflows/` directory
4. **Configure webhooks** using examples from `examples/`
5. **Trigger a phase** with an HTTP POST

## 📚 Documentation Order

For best understanding, read in this order:

1. **guides/01-GENESIS-Pipeline-Manual.md** - Understand what was built
2. **guides/03-Template-Reference.md** - Learn the 5 core templates
3. **guides/04-Persona-System.md** - Understand agent personalities
4. **guides/02-N8N-Setup-Guide.md** - Set up your N8N instance

## 🎮 The Pond Conspiracy Example

The `pond-conspiracy` project was generated using Phases 1-6 of GENESIS:
- Started with a simple idea: "A game where you're a frog in a pond"
- Went through ideation, focus groups, PRD creation, stakeholder review, triage, and architecture
- Generated 20 epics, 7 ADRs, complete architecture docs, and implementation plans
- All in about 14 hours of automated multi-agent work

See the complete artifact trail in `.thursian/projects/pond-conspiracy/`

## 🔗 Integration with Automaton Project

These N8N workflows are designed to integrate with the **Automaton** project at `C:\dev\GIT\automaton`.

The workflows expect:
- **Claude API access** (via Anthropic API key)
- **File storage** (local or cloud)
- **Webhook endpoints** (for triggering phases)
- **Memory backend** (AgentDB or compatible)

## 📝 License & Attribution

Original GENESIS architecture: Thursian Engineering Division
N8N adaptation: Part of the Automaton project
Template system: Based on Claude-Flow patterns

---

**Next**: Read [guides/01-GENESIS-Pipeline-Manual.md](guides/01-GENESIS-Pipeline-Manual.md) to understand the complete system.
