# Architecture Decision Records (ADRs)

**Project**: Pond Conspiracy
**Date**: 2025-12-13
**Status**: ✅ Architecture Complete (7 ADRs)

---

## What are ADRs?

Architecture Decision Records document important architectural decisions made during the project. Each ADR captures:
- **Context**: Why we needed to make this decision
- **Decision**: What we decided to do
- **Consequences**: Trade-offs and impacts of the decision
- **Alternatives**: Other options we considered and why we rejected them

---

## ADR Index

| ADR | Title | Status | Date | Key Decision |
|-----|-------|--------|------|--------------|
| [ADR-001](./ADR-001-platform-deployment.md) | Platform & Deployment Strategy | ✅ Accepted | 2025-12-13 | Steam-exclusive PC game (Windows/Linux/Steam Deck), no servers, GitHub Actions CI/CD |
| [ADR-002](./ADR-002-system-architecture.md) | System Architecture & Module Structure | ✅ Accepted | 2025-12-13 | Modular monolith using Godot scenes, EventBus for decoupling, 5 core modules |
| [ADR-003](./ADR-003-communication-patterns.md) | Communication Patterns & API Strategy | ✅ Accepted | 2025-12-13 | Event-driven architecture (EventBus), Steam API integration via GodotSteam |
| [ADR-004](./ADR-004-data-architecture.md) | Data Architecture & Storage Strategy | ✅ Accepted | 2025-12-13 | JSON file-based saves with CRC32 checksums, Steam Cloud sync |
| [ADR-005](./ADR-005-authentication-security.md) | Authentication & Security Architecture | ✅ Accepted | 2025-12-13 | Steam-based auth (automatic), minimal security (single-player, no sensitive data) |
| [ADR-006](./ADR-006-technology-stack.md) | Technology Stack Selection | ✅ Accepted | 2025-12-13 | Godot 4.2+ with GDScript, BulletUpHell plugin, GodotSteam, GitHub Actions |
| [ADR-007](./ADR-007-frontend-architecture.md) | Frontend Architecture (UI & Conspiracy Board) | ✅ Accepted | 2025-12-13 | Godot Control nodes, scene-based UI components, Bezier string physics, 3 colorblind modes |

---

## Decision Themes

### Core Architecture Decisions

**Simplicity Over Complexity**:
- Single-player desktop app (no servers)
- File-based saves (no database)
- Modular monolith (no microservices)
- EventBus for decoupling (no complex message queues)

**Team-Appropriate Technology**:
- Godot (solo dev-friendly, fast iteration)
- GDScript (no compile step)
- JSON (human-readable, easy to debug)
- GitHub Actions (free tier sufficient)

**Performance-First**:
- 60fps minimum requirement
- <16ms input lag
- Object pooling for bullets
- Optimized for GTX 1060 (5-year-old hardware)

**Accessibility Built-In**:
- 3 colorblind modes (CI-3.2)
- Text scaling (3 sizes)
- Rebindable controls
- Keyboard-only navigation

---

## Key Technical Decisions Summary

### Platform
- **Target**: Windows, Linux, Steam Deck
- **Distribution**: Steam exclusive (Early Access → 1.0)
- **No servers**: Fully local game
- **Cloud**: Steam Cloud for save sync only

### Architecture
- **Style**: Modular monolith (Godot scenes)
- **Modules**: Core Systems, Combat, Conspiracy Board, MetaGame, Shared/Utilities
- **Communication**: EventBus pattern (pub/sub)
- **Dependencies**: One-way (modules → Core, never Core → modules)

### Data
- **Format**: JSON files (human-readable)
- **Storage**: Godot's `user://` directory (cross-platform)
- **Sync**: Steam Cloud (last-write-wins)
- **Integrity**: CRC32 checksums + backup files

### Security
- **Auth**: Steam-based (automatic, zero dev work)
- **Save encryption**: None (no sensitive data)
- **Anti-cheat**: None (single-player, player can cheat themselves)
- **DRM**: Steam's built-in only (no additional DRM)

### Technology Stack
- **Engine**: Godot 4.2+ (open-source, MIT license)
- **Language**: GDScript (fast iteration, Python-like)
- **Plugins**: BulletUpHell (forked), GodotSteam
- **CI/CD**: GitHub Actions (automated builds)
- **Testing**: GUT (Godot Unit Test framework)

### Frontend
- **UI Framework**: Godot Control nodes (built-in)
- **Combat HUD**: Minimal (HP, timer, pollution index)
- **Conspiracy Board**: Rich (drag-drop, Bezier strings, 300ms animations)
- **Accessibility**: 3 colorblind modes, text scaling, keyboard nav

---

## Decision Dependencies

```
ADR-001 (Platform)
    ├─→ ADR-002 (System Architecture)
    ├─→ ADR-006 (Tech Stack)
    └─→ ADR-005 (Security)

ADR-002 (System Architecture)
    ├─→ ADR-003 (Communication Patterns)
    ├─→ ADR-004 (Data Architecture)
    └─→ ADR-007 (Frontend Architecture)

ADR-006 (Tech Stack)
    ├─→ ADR-002 (System Architecture)
    └─→ ADR-007 (Frontend Architecture)
```

**Foundation Decisions** (must be made first):
- ADR-001 (Platform): Defines deployment target
- ADR-006 (Tech Stack): Defines implementation technology

**Architecture Decisions** (depend on foundation):
- ADR-002 (System Architecture): How to structure the code
- ADR-003 (Communication): How modules talk to each other
- ADR-004 (Data): How to persist state
- ADR-005 (Security): How to protect the app

**Implementation Decisions** (depend on architecture):
- ADR-007 (Frontend): How to build the UI

---

## How to Use These ADRs

### For Developers

1. **Read ADR-001 & ADR-006 first**: Understand platform and tech stack
2. **Read ADR-002**: Understand system structure before coding
3. **Reference relevant ADR when implementing**: e.g., read ADR-007 before building UI
4. **Update ADRs if decisions change**: Add "Superseded by ADR-XXX" note

### For New Team Members

1. **Start with this README**: Get high-level overview
2. **Read ADRs in order**: Follow the dependency chain
3. **Ask questions**: If ADR is unclear, request clarification
4. **Respect decisions**: Don't re-litigate without new information

### For Stakeholders

- **ADR-001**: Business impact (platform, distribution, costs)
- **ADR-006**: Technology risk assessment
- **ADR-005**: Security and compliance posture

---

## ADR Lifecycle

**Proposed** → **Accepted** → **Deprecated** / **Superseded**

**Current Status**: All 7 ADRs are **Accepted** (ready for implementation)

**Future ADRs** (when needed):
- ADR-008: Mod API Design (deferred to Year 2)
- ADR-009: Leaderboard Architecture (deferred to Beta)
- ADR-010: Dynamic Music System (deferred to Alpha)

---

## Questions & Contacts

**Architecture Questions**: Contact Chief Architect or Technical Lead
**Implementation Questions**: Refer to specific ADR
**Challenges to Decisions**: Bring new data, not just opinions

---

**Last Updated**: 2025-12-13
**Next Review**: Week 0 (Pre-Development Kickoff)
**Status**: ✅ Architecture Planning Complete
