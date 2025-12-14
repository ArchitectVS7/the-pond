# The Pond - Developer's Manual

Welcome to the complete guide for building The Pond, from where we are now to a polished 1.0 release on Steam.

This isn't a wall of documentation. It's a map through the territory - written for developers who work with AI, want to understand their code, and prefer guides over encyclopedias.

---

## Where We Are

| Phase | Status | Progress |
|-------|--------|----------|
| **MVP** | Complete | 78/78 stories |
| **Alpha** | Not Started | 0/27 stories |
| **Beta** | Not Started | 0/22 stories |
| **1.0 Launch** | Pending | - |

The code is written. The systems work. What remains is the human work: art assets, audio, Steam integration, testing on real hardware, and the NGO partnership that gives our environmental message credibility.

---

## Start Here

**Need to do something right now?**
Go to [Human Steps](12-human-steps/overview.md) - actionable checklists for art, audio, Steam setup, and testing.

**Want to understand a system?**
Pick your chapter:
- [Combat System](02-combat-system/overview.md) - Movement, tongue attack, enemies, game feel
- [Conspiracy Board](04-conspiracy-board/overview.md) - The core differentiator
- [Mutations](05-mutations/overview.md) - Roguelike progression
- [Boss Encounters](06-boss-encounters/overview.md) - The Lobbyist, The CEO, and beyond

**New to the project?**
Start with [The Journey So Far](00-prologue/the-journey-so-far.md) for context.

**Learning as you go?**
Read [For Vibe Coders](00-prologue/for-vibe-coders.md) - this manual is built for you.

---

## The Chapters

### Part I: Getting Started
| Chapter | Description |
|---------|-------------|
| [00 - Prologue](00-prologue/) | How to use this manual, where we've been, the vibe coder philosophy |
| [01 - Foundations](01-foundations/) | Project structure, Godot patterns, testing with GUT |

### Part II: Core Systems
| Chapter | Description |
|---------|-------------|
| [02 - Combat System](02-combat-system/) | Player movement, tongue attack, enemies, performance, game feel |
| [03 - BulletUpHell](03-bulletuphell/) | Plugin integration, patterns, performance tuning |
| [04 - Conspiracy Board](04-conspiracy-board/) | Drag-drop, string physics, document viewer, accessibility |
| [05 - Mutations](05-mutations/) | Data structure, synergies, pollution index, balancing |
| [06 - Boss Encounters](06-boss-encounters/) | Framework, The Lobbyist, The CEO, pattern design |

### Part III: Integration
| Chapter | Description |
|---------|-------------|
| [07 - Meta-Progression](07-meta-progression/) | Save system, Steam Cloud, informants |
| [08 - Platform Integration](08-platform-integration/) | Steam setup, achievements, Steam Deck, controllers |
| [09 - Accessibility](09-accessibility/) | Colorblind modes, text scaling, WCAG compliance |
| [10 - Content Creation](10-content-creation/) | Writing data logs, dialogue, tone guide |

### Part IV: The Road Ahead
| Chapter | Description |
|---------|-------------|
| [11 - Alpha/Beta Features](11-alpha-beta-features/) | Visual mutations, dynamic music, daily challenges, endings |
| [12 - Human Steps](12-human-steps/) | Art checklists, Steam setup, hardware testing, NGO outreach |
| [13 - Launch Checklist](13-launch-checklist/) | MVP, Alpha, Beta, and 1.0 milestones |

### Reference
| Appendix | Description |
|----------|-------------|
| [A - Tunable Parameters](appendices/a-tunable-parameters-index.md) | Every `@export` variable in one place |
| [B - Story Traceability](appendices/b-story-traceability.md) | COMBAT-001 maps to which file |
| [C - API Reference](appendices/c-api-reference.md) | Key classes, methods, signals |
| [D - Glossary](appendices/d-glossary.md) | Game dev terms explained |
| [E - Bibliography](appendices/e-bibliography.md) | Environmental research sources |

---

## Chapter Progress

| Chapter | Status | Files |
|---------|--------|-------|
| 00-prologue | **Complete** | 3/3 |
| 01-foundations | **Complete** | 3/3 |
| 02-combat-system | **Complete** | 7/7 |
| 03-bulletuphell | **Complete** | 4/4 |
| 04-conspiracy-board | **Complete** | 5/5 |
| 05-mutations | **Complete** | 5/5 |
| 06-boss-encounters | **Complete** | 6/6 |
| 07-meta-progression | **Complete** | 4/4 |
| 08-platform-integration | **Complete** | 5/5 |
| 09-accessibility | **Complete** | 4/4 |
| 10-content-creation | **Complete** | 3/3 |
| 11-alpha-beta | **Complete** | 6/6 |
| 12-human-steps | **Complete** | 7/7 |
| 13-launch-checklist | **Complete** | 4/4 |
| appendices | **Complete** | 5/5 |

---

## How This Manual Works

Each chapter follows a pattern:

1. **Overview** - What this system does, why it exists
2. **Implementation** - How the code works, with educational sidebars
3. **Tunable Parameters** - Every knob you can turn
4. **Sidebars** - Quick concept explanations (1-2 paragraphs each)

Sidebars are for learning. If you see something like:

> **Sidebar**: [What is Spatial Hashing?](02-combat-system/sidebars/what-is-spatial-hashing.md)
> Why checking 500 enemies every frame doesn't kill performance.

...that's your invitation to understand the concept, not just copy the code.

---

## Writing Voice

This manual is written for humans, not search engines. We aim for:

- **Specific over vague**: "300ms settle time" not "fast"
- **Honest over hype**: No "amazing" or "incredible"
- **Direct over hedged**: Say what you mean
- **Why over just what**: Context matters

See the full [Style Guide](style-guide.md) for details.

---

*Last updated: 2025-12-14*
