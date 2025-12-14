# The Journey So Far

The Pond started as an idea: What if a bullet hell roguelike had something to say? Not a message bolted on, but gameplay that made you feel the consequences of environmental destruction. Here's where we've been.

---

## The Concept

**A frog in a dying pond.**

Your home is poisoned. Corporate runoff has mutated the ecosystem. You fight through waves of polluted creatures, absorbing their mutations to survive. Between runs, you piece together evidence of who's responsible.

The conspiracy board isn't just a menu. It's the core loop. Combat feeds investigation. Investigation gives purpose to combat.

---

## Development Timeline

### Phase: Foundation

Built the core systems:
- **Combat System**: 8-directional movement, tongue attack with elastic physics
- **BulletUpHell Integration**: Forked plugin for frog-themed bullet patterns
- **Enemy System**: Spatial hashing for 500+ enemies at 60fps

### Phase: Core Features

Implemented the differentiators:
- **Conspiracy Board**: Drag-drop cards with Bezier string physics
- **Document Viewer**: TL;DR and full-text modes for evidence
- **Mutation System**: 10 mutations with 3 synergies, pollution tracking

### Phase: Content

Filled in the experience:
- **Boss Encounters**: The Lobbyist and The CEO with unique patterns
- **Meta-Progression**: Persistent evidence, unlockable informants
- **Save System**: Atomic writes, corruption recovery, Steam Cloud ready

### Phase: Polish

Made it shippable:
- **Accessibility**: 3 colorblind modes, text scaling, keyboard navigation
- **Platform Support**: Windows, Linux, Steam Deck, controllers
- **Performance**: 60fps on GTX 1060, 55fps on Steam Deck

---

## Where We Are Now

| Phase | Status | Stories |
|-------|--------|---------|
| **MVP** | Complete | 78/78 |
| **Alpha** | Not Started | 0/27 |
| **Beta** | Not Started | 0/22 |

**The code is written.** All MVP systems are functional. Tests pass. Performance targets met.

**The human work remains:**
- Art assets (sprites, backgrounds, UI)
- Audio (SFX, music)
- Steam integration (App ID, achievements, store page)
- NGO partnership (environmental content review)
- Hardware testing (real devices, not emulators)

---

## Technical Decisions

### Why Godot 4.2?

- GDScript is readable by AI and humans
- Built-in physics and UI good enough
- Steam Deck support via Proton
- Free, open source, no royalties

### Why BulletUpHell?

The plugin handles bullet patterns efficiently. Rather than build from scratch, we forked it and customized for frog-themed gameplay.

### Why JSON Saves?

- Human-readable for debugging
- Easy to migrate between versions
- Works with Steam Cloud
- Good enough performance for our data size

### Why Not Unity/Unreal?

Godot's simplicity matches the project scope. A solo developer doesn't need entity component systems or cinematic lighting. We need something that works.

---

## What Didn't Work

### Initial String Physics

First attempt used full physics simulation. Too expensive for 20+ strings. Replaced with damped spring approximation - same visual result, fraction of the cost.

### Enemy AI Complexity

Early designs had complex behavior trees. Simpler state machines worked better. Enemies that feel smart don't need to be smart.

### Figma Prototype Delay

Should have tested the conspiracy board UI earlier. Waiting until code was written meant rebuilding after user feedback.

---

## Lessons Learned

**Test the feel early.** Combat tuning took longer than combat implementation. The code was done in days; making it feel good took weeks.

**Scope ruthlessly.** The PRD had 50 features. MVP shipped with 20. The cut features went to Alpha/Beta where they belong.

**Document as you go.** This manual exists because writing it later would have been impossible. The decisions were fresh when documented.

**AI is a multiplier.** Every chapter was drafted with AI assistance. The code, the docs, the planning - all faster with AI. But AI can't tell you what to build. That's still your job.

---

## What's Next

### Alpha

- Third boss (The Researcher)
- Visual mutation effects
- Dynamic music system
- Second ending path

### Beta

- Secret boss (Sentient Pond)
- Daily challenges
- Leaderboards
- Endless mode
- Third ending path

### 1.0 Launch

- Full art pass
- Professional audio
- Steam achievements
- Marketing push
- Price increase ($10 → $15)

---

## The Message

The Pond isn't a documentary. It's a game. But the conspiracy is grounded in real patterns:

- Corporations have dumped waste in wetlands
- Regulatory capture happens
- Whistleblowers face retaliation
- Local ecosystems die from pollution

We're not preaching. We're showing. Through gameplay, through evidence, through a frog who lost family to corporate negligence.

If players finish The Pond and think differently about their local wetland, the message worked.

---

[← Back to How to Use This Manual](how-to-use-this-manual.md) | [Next: For Vibe Coders →](for-vibe-coders.md)
