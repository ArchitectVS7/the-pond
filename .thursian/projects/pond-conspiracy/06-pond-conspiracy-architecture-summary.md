# Pond Conspiracy - Architecture Planning Summary

**Date**: 2025-12-13
**Duration**: Architecture Planning Session
**Participants**: Chief Architect, Platform Architect, Backend Architect, Frontend Architect, Data Architect, Security Architect, DevOps Architect
**Project**: pond-conspiracy
**Phase**: 06-architecture-planning (Post-Engineering Review)

---

## Session Overview

The architecture team convened to define the technical foundation for Pond Conspiracy following the successful engineering review and PRD v0.2 approval. The session produced 7 Architecture Decision Records (ADRs) covering all critical domains for the MVP.

**Key Outcome**: ✅ Complete architecture specification ready for Week 0 development kickoff

---

## Architectural Principles Established

1. **Simplicity Over Complexity**: Choose the simplest solution that meets requirements
2. **Make Reversible Decisions**: Prefer choices that can be changed later without rewrites
3. **Defer Decisions When Possible**: Don't over-design for future requirements
4. **Document Tradeoffs Explicitly**: Capture why we chose X over Y in ADRs

---

## Major Architectural Decisions

### 1. Platform & Deployment (ADR-001)

**Decision**: Steam-exclusive PC game (Windows/Linux/Steam Deck), fully local, no servers

**Rationale**:
- **Market reach**: 80% of Steam users on Windows, growing Linux/Steam Deck audience
- **Cost**: $0/month infrastructure (no servers to maintain)
- **Team fit**: Solo dev + artist, no devops expertise required
- **Distribution**: Steam handles 100% of deployment, updates, DRM

**Key Tradeoffs**:
- ✅ Simple: No backend, no ops overhead
- ❌ Platform lock-in: Heavy reliance on Steam ecosystem
- Deferred: macOS (5% market), consoles (Year 2+)

**Consensus**: Unanimous approval. Steam-first makes sense for indie PC roguelike.

---

### 2. System Architecture (ADR-002)

**Decision**: Modular monolith using Godot's scene system with EventBus decoupling

**Rationale**:
- **Godot-native**: Leverage scene architecture, don't fight the engine
- **Clear boundaries**: Combat, Conspiracy Board, MetaGame modules isolated
- **Loose coupling**: EventBus prevents tight dependencies
- **Scalable**: Add bosses/mutations/endings without restructuring

**Module Structure**:
```
Core Systems (Singletons)
    ↑ ↑ ↑
    │ │ │
Combat | Conspiracy Board | MetaGame
```

**Key Tradeoffs**:
- ✅ Fast iteration: Change one module without breaking others
- ❌ Singleton risk: Could create global state spaghetti (mitigated by code review)
- Rejected: ECS (overkill for 500 entities), MVC (fights Godot patterns)

**Consensus**: Strong agreement. Modular monolith fits 10-week timeline and team size.

---

### 3. Communication Patterns (ADR-003)

**Decision**: Event-driven architecture using EventBus (Godot signals) + Steam API wrapper

**Rationale**:
- **Decoupling**: Combat doesn't know about Conspiracy Board
- **Testability**: Can emit events in unit tests without full game state
- **Godot-native**: Signals are built-in, well-understood pattern
- **Steam integration**: GodotSteam plugin wraps complexity

**Event Catalog**:
- `player_died` → Trigger death screen + evidence collection
- `boss_defeated` → Unlock data log
- `mutation_selected` → Update pollution index
- `save_completed` → Show save icon

**Key Tradeoffs**:
- ✅ Loosely coupled modules
- ❌ Event hell risk (mitigated by catalog + code review)
- Rejected: Direct method calls (tight coupling), Godot groups (hard to discover)

**Consensus**: Unanimous. EventBus is proven pattern for Godot games.

---

### 4. Data Architecture (ADR-004)

**Decision**: JSON file-based saves with CRC32 checksums, Steam Cloud sync

**Rationale**:
- **Simple**: No database setup, just read/write JSON
- **Debuggable**: Human-readable format (can edit in text editor)
- **Fast**: <50ms save/load times for 2-5KB files
- **Reliable**: Atomic writes + backup files prevent corruption
- **Cloud-enabled**: Steam Cloud sync built-in (last-write-wins)

**Save Location**: `user://saves/save_game.json` (cross-platform Godot path)

**Key Tradeoffs**:
- ✅ Zero database maintenance
- ❌ No query capability (acceptable for single-player)
- Rejected: SQLite (overkill), binary format (not debuggable), cloud database (unnecessary)

**Consensus**: Strong agreement. JSON is perfect fit for local save files.

---

### 5. Authentication & Security (ADR-005)

**Decision**: Steam-based auth (automatic), minimal security (trust player)

**Rationale**:
- **Zero auth code**: Steam handles login, 2FA, account management
- **Appropriate threat model**: Single-player game, no PII, no economy
- **Player-friendly**: No anti-cheat, no DRM beyond Steam's built-in
- **Save integrity**: CRC32 checksums detect corruption (not prevent tampering)

**Security Posture**:
- ✅ Auth: Steam-based (automatic)
- ✅ Save corruption: Checksums + backups
- ❌ Save editing: Acceptable (players can cheat themselves)
- ❌ Anti-cheat: Not needed (no competitive element)

**Key Tradeoffs**:
- ✅ Zero security code to write
- ❌ Achievement cheating possible (acceptable, low impact)
- Rejected: Custom accounts (adds weeks), encrypted saves (false security), anti-cheat (player-hostile)

**Consensus**: Unanimous. Trust-based security appropriate for single-player.

---

### 6. Technology Stack (ADR-006)

**Decision**: Godot 4.2+ with GDScript, BulletUpHell plugin, GodotSteam, GitHub Actions

**Rationale**:
- **Godot Engine**: Free, open-source, excellent 2D performance, cross-platform
- **GDScript**: Faster iteration (no compile), Python-like syntax, tight Godot integration
- **BulletUpHell**: Proven bullet-hell engine (forked on Day 1 per CI-3.3)
- **GodotSteam**: Steam API wrapper (achievements, cloud saves)
- **GitHub Actions**: Free CI/CD (automated builds)

**Tech Stack Summary**:
| Layer | Choice | Why |
|-------|--------|-----|
| Engine | Godot 4.2+ | Free, 60fps achievable, small binaries |
| Language | GDScript | Fast iteration, no compile step |
| Bullet Patterns | BulletUpHell | Proven, performance-optimized |
| Steam | GodotSteam | Wrapper around Steamworks SDK |
| CI/CD | GitHub Actions | Free tier sufficient |

**Key Tradeoffs**:
- ✅ Zero licensing costs
- ❌ Smaller ecosystem than Unity (acceptable, sufficient plugins exist)
- Rejected: Unity (runtime fees), Unreal (overkill for 2D), custom engine (6+ months)

**Consensus**: Strong agreement. Godot is optimal for solo indie 2D game.

---

### 7. Frontend Architecture (ADR-007)

**Decision**: Godot Control nodes, scene-based UI, Bezier string physics, 3 colorblind modes

**Rationale**:
- **Godot-native**: Built-in UI system (no external framework)
- **Performance**: 60fps HUD with zero UI lag
- **Conspiracy Board**: Figma prototype required (8/10 satisfaction, CI-2.3)
- **Accessibility**: 3 colorblind modes (CI-3.2), text scaling, keyboard nav

**UI Components**:
- **Combat HUD**: Minimal (HP, timer, pollution index)
- **Conspiracy Board**: Rich (drag-drop, Bezier strings, 300ms animations per CI-2.1)
- **Accessibility**: Shader-based colorblind modes, text scaling (0.8x/1.0x/1.3x)

**Key Tradeoffs**:
- ✅ Performant and integrated
- ❌ Less styling power than CSS (acceptable, pixel art aesthetic)
- Rejected: HTML5 UI (performance), ImGui (C++ dependency, debug only)

**Consensus**: Unanimous. Godot's UI fits pixel art aesthetic and performance requirements.

---

## Cross-Domain Consensus

### On Simplicity

**Team Agreement**: "If it can be done with Godot's built-in systems, use those first."

- No custom auth → Steam
- No custom database → JSON files
- No custom UI framework → Godot Control nodes
- No custom message bus → Godot signals (EventBus pattern)

**Quote** (Chief Architect): "We're building a weekend indie game, not a AAA engine. Embrace constraints."

---

### On Performance

**Target**: 60fps minimum on GTX 1060 @ 1080p, <16ms input lag (CI-3.1)

**Strategies**:
- Object pooling (500+ bullets)
- Spatial hashing (collision optimization)
- Culling (off-screen entities)
- Profiling with Godot's built-in profiler

**Quote** (Backend Architect): "Performance is non-negotiable. Tight combat is the foundation—if it doesn't feel good, the entire concept fails."

---

### On Accessibility

**Requirements** (from PRD):
- 3 colorblind modes: Deuteranopia, Protanopia, Tritanopia (CI-3.2)
- Text scaling: Small (0.8x), Medium (1.0x), Large (1.3x)
- Screen shake toggle
- Rebindable controls
- Keyboard-only navigation

**Quote** (UX Lead): "Accessibility isn't a nice-to-have. It's baked into the architecture from day one."

---

## Risk Assessment

### Identified Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **Conspiracy Board UX fails** | MEDIUM → LOW | CRITICAL | Figma prototype + 10-user testing (Week 1, CI-2.3) |
| **Timeline slip** | MEDIUM | HIGH | Cut priority list established (CI-6.2), Week 5-6 split reduces pressure |
| **Performance issues** | LOW | HIGH | 60fps target + streaming validation in QA (CI-4.1) |
| **Scope creep** | LOW → VERY LOW | CRITICAL | Day 28 feature freeze, all stakeholders aligned (CI-6.1) |

**Quote** (Technical Lead): "Week 1 Figma testing is our insurance policy. If conspiracy board UX is bad, we catch it before writing code."

---

## Open Questions & Future Decisions

### Deferred to Implementation

1. **Colorblind shader implementation**: Exact matrix values need testing with real colorblind users
2. **Pollution index visual design**: Prototype in Week 9, iterate based on feedback
3. **Steam Deck control mapping**: Test on actual hardware (Week 9-10)

### Deferred to Alpha (Month 1-3)

1. **Dynamic music system**: Crossfade based on combat intensity
2. **Visual mutation effects**: Frog appearance changes based on mutations
3. **3rd boss patterns**: Design after analyzing player data from Early Access

### Deferred to Beta (Month 4-6)

1. **Leaderboard architecture**: Steam API integration, requires live Steam app
2. **Daily challenge system**: New autoload singleton, after core loop validated
3. **Mod API design**: Research only, implementation in Year 2

### Deferred to Year 2+

1. **macOS support**: If demand exists (<5% market share)
2. **Console ports**: Requires porting house ($30-50K investment)
3. **Workshop integration**: Mod support, community content

---

## Implementation Priorities

### Week 0 (Pre-Development)

**Critical Path**:
1. ✅ Fork BulletUpHell plugin (Day 1 per CI-3.3)
2. ✅ Create Figma conspiracy board prototype (CI-2.3)
3. ✅ Recruit 10 target users for testing (5 roguelike fans, 3 indie gamers, 2 designers)
4. ✅ Contact environmental NGOs (Waterkeeper Alliance, Sierra Club per CI-2.2)
5. ✅ Set up GitHub repository + Actions workflow

**Quote** (DevOps Architect): "Week 0 is about de-risking. Figma test, fork dependencies, line up NGO review."

---

### Week 1-2 (Combat Prototype)

**Focus**: Prove combat feel, validate 60fps target

**Deliverables**:
- Movement + tongue attack functional
- 2 enemy types spawning
- BulletUpHell integration complete
- **Conspiracy board user testing complete (8/10 satisfaction)** (CI-7.1)

**Quote** (Chief Architect): "If combat doesn't feel good by Week 2, we pivot or cut scope. No exceptions."

---

### Week 5-6 (Conspiracy Board)

**Focus**: Implement highest-risk feature (board UX)

**Deliverables**:
- Corkboard UI (matches Figma prototype)
- 7 data logs (NGO-reviewed per CI-2.2)
- String physics (Bezier curves + elasticity per CI-2.1)
- Drag-and-drop fully functional

**Note**: Originally Week 5-6 included save system, now split to Week 6-7 to reduce sprint risk (CI-7.2)

---

### Week 9 (Polish + NEW Feature)

**NEW in v0.2**: Pollution Index UI (1 day, NEW-1)

**Implementation**:
- Visual meter on HUD (0-100% scale)
- Tracks pollution-based mutations equipped
- Color-coded: Green (0-30%), Yellow (31-60%), Red (61-100%)

**Quote** (Product Manager): "Pollution index reinforces systems-driven message (CI-1.4). Players see their complicity visually."

---

## Architecture Review Findings

### Coherence Check

**Question**: Do all decisions work together?

**Answer**: ✅ YES
- Platform (Steam PC) → Tech Stack (Godot) → Data (local saves + Steam Cloud)
- System Architecture (modular monolith) → Communication (EventBus) → Frontend (scene-based UI)
- All decisions reinforce simplicity and rapid iteration

---

### Completeness Check

**Question**: Have we addressed all requirements?

**Answer**: ✅ YES
- All PRD v0.2 functional requirements mapped to architecture
- All non-functional requirements (performance, accessibility) covered
- 6 required domains + 1 optional (frontend) = 7 ADRs complete

---

### Feasibility Check

**Question**: Can we actually build this?

**Answer**: ✅ YES (with 75% confidence from Technical Lead)

**Evidence**:
- Similar games built in Godot (Vampire Survivors clones exist)
- BulletUpHell plugin proven (used in shipped games)
- GodotSteam mature (4.7+ stable)
- Timeline realistic (10-12 weeks for MVP scope)

**Risks Mitigated**:
- Conspiracy board UX de-risked by Figma prototype (Week 1)
- Performance validated early (Week 1-2 combat prototype)
- Cut priority established for timeline slips (CI-6.2)

---

### Identified Gaps

**None critical**, but noted for follow-up:
1. Steam Deck hardware testing (need to borrow/rent device, ~$400)
2. Colorblind mode validation (need real colorblind testers)
3. NGO partnership confirmation (reach out Week 0)

---

## Next Steps

### Immediate (This Week)

1. ✅ **Chief Architect**: Distribute architecture documents for async review (24 hours)
2. ✅ **UX Lead**: Create Figma conspiracy board prototype
3. ✅ **Product Manager**: Contact environmental NGOs (start Week 0 partnerships)
4. ✅ **DevOps Architect**: Set up GitHub repository + Actions workflow

### Week 0 (Pre-Development Kickoff)

1. ✅ Fork BulletUpHell plugin to internal repository
2. ✅ User test Figma prototype with 10 target players (achieve 8/10 satisfaction)
3. ✅ Finalize NGO partnership (content review agreement)
4. ✅ Recruit team: 1 programmer + 1 pixel artist

### Week 1 (Development Begins)

1. ✅ Implement combat prototype (movement + tongue attack)
2. ✅ Integrate BulletUpHell plugin
3. ✅ Validate 60fps on test hardware
4. ✅ Begin asset creation (player sprite, enemy sprites)

---

## Key Quotes from Session

**On Simplicity** (Chief Architect):
> "We're not building a AAA engine. We're building a tight, focused indie game. Every dependency we avoid is time saved and bugs prevented."

**On Combat Feel** (Backend Architect):
> "If combat doesn't feel good, the entire concept fails. 60fps and <16ms input lag are non-negotiable. We measure, we profile, we optimize."

**On Conspiracy Board Risk** (UX Lead):
> "This is our highest UX risk. Figma prototype + 10-user testing Week 1 is our insurance policy. If it tests poorly, we iterate before coding."

**On Accessibility** (Frontend Architect):
> "3 colorblind modes, text scaling, keyboard nav—these aren't afterthoughts. They're baked into the architecture from day one."

**On Timeline Discipline** (Product Manager):
> "Day 28 feature freeze, no exceptions. If someone has a 'brilliant idea' on Day 29, it goes in the post-launch backlog. Scope discipline is how we ship in 10-12 weeks."

**On Trust-Based Design** (Security Architect):
> "We trust the player. No DRM beyond Steam's built-in, no anti-cheat, saves are editable. Single-player games should respect players, not antagonize them."

---

## Deliverables Summary

### Architecture Documents (Complete)

1. **ADR-001**: Platform & Deployment Strategy ✅
2. **ADR-002**: System Architecture & Module Structure ✅
3. **ADR-003**: Communication Patterns & API Strategy ✅
4. **ADR-004**: Data Architecture & Storage Strategy ✅
5. **ADR-005**: Authentication & Security Architecture ✅
6. **ADR-006**: Technology Stack Selection ✅
7. **ADR-007**: Frontend Architecture (UI & Conspiracy Board) ✅
8. **ADR Index**: README.md in adrs/ folder ✅
9. **Architecture Overview**: Master document with diagrams ✅
10. **Architecture Summary**: This document ✅

### Ready for Handoff

**To**: Week 0 Pre-Development Team
**Artifacts**:
- 7 ADRs (detailed architectural decisions)
- Architecture Overview (comprehensive master doc)
- This summary (condensed key decisions)
- PRD v0.2 (product requirements)
- Triage Report (engineering review results)

**Status**: ✅ **APPROVED FOR DEVELOPMENT**

---

## Final Architecture Statement

**Chief Architect's Closing Remarks**:

> "We've completed the architecture planning phase. We have clear decisions documented as ADRs, a coherent technology stack, and a roadmap for implementation. The architecture supports our MVP requirements and provides a foundation for future growth.
>
> Key principles we established:
> 1. **Simplicity wins**: Use Godot's built-in systems, avoid premature abstractions
> 2. **Performance is non-negotiable**: 60fps minimum, measured and validated
> 3. **Trust the player**: No anti-cheat, no hostile DRM, respect single-player experience
> 4. **Accessibility from day one**: 3 colorblind modes, text scaling, keyboard nav
> 5. **Scope discipline**: Day 28 feature freeze, cut priority established
>
> This architecture is optimized for a 10-12 week MVP timeline with a solo developer and pixel artist. It's not over-engineered, it's not under-engineered—it's right-sized for our constraints.
>
> Let's build this."

---

**Session Complete**: 2025-12-13
**Next Milestone**: Week 0 Kickoff → Combat Prototype (Week 1)
**Architecture Status**: ✅ **COMPLETE - READY FOR IMPLEMENTATION**

---

**Participants**:
- ✅ Chief Architect (Session Lead)
- ✅ Platform Architect (Platform & Deployment)
- ✅ Backend Architect (System Architecture, Data)
- ✅ Frontend Architect (UI & Conspiracy Board)
- ✅ Data Architect (Data Architecture & Storage)
- ✅ Security Architect (Auth & Security)
- ✅ DevOps Architect (CI/CD & Deployment)

**Approval**: Unanimous consensus on all 7 ADRs
