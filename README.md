# Pond Conspiracy

A bullet-hell roguelite where you play as a frog uncovering a corporate environmental conspiracy. Combat is how you gather evidence. The conspiracy board is why you keep playing.

---

## What It Is

You live in a dying pond. Corporate runoff has mutated the ecosystem. You fight through waves of polluted creatures, absorbing their toxins as mutation upgrades. Every boss you defeat drops evidence — a data log, an internal memo, a leaked document. Between runs, you pin that evidence to a cork board, connect the threads, and piece together who poisoned your home.

The conspiracy board is not a menu. It is the core loop.

**Platform:** Steam — Windows, Linux, Steam Deck
**Genre:** Bullet-hell roguelite / investigation
**Engine:** Godot 4.2+

---

## Status

| Phase | Stories | Status |
|---|---|---|
| MVP | 78 / 78 | Complete |
| Alpha | 0 / 27 | Not started |
| Beta | 0 / 22 | Not started |

MVP systems are implemented, tested, and performance-validated (60 FPS on GTX 1060 with 500+ entities). What remains before Alpha: art assets, audio, a main menu, and the full run loop connecting combat → board → next run.

---

## Running the Project

**Requirements:** Godot 4.2 or later

```bash
# Open the project
godot project.godot

# Launch the test arena directly (current main scene)
# Press F5 in the Godot editor, or:
godot --path . res://combat/scenes/TestArena.tscn
```

**Controls:**
- `WASD` — Move
- `Mouse` — Aim
- `Left click` — Tongue attack
- `Escape` — Pause

---

## Running Tests

Tests use the [GUT](https://github.com/bitwes/Gut) framework included in `addons/gut/`.

```bash
# All unit tests
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/

# All integration tests
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/

# Conspiracy board tests
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/conspiracy_board/
```

---

## Architecture

The codebase uses an event-driven architecture. All inter-module communication goes through `EventBus` (autoloaded singleton). Modules never import each other directly.

```
core/               Event bus, save system, Steam integration
combat/             Player, enemies, bosses, bullet patterns
conspiracy_board/   Cork board UI, evidence cards, string connections
metagame/           Mutations, abilities, meta-progression
shared/             Audio, particles, accessibility, screen shake
```

Key technical decisions are documented in `.thursian/projects/pond-conspiracy/design-docs/adrs/`.

---

## Documentation

- **Developer's Manual:** [`GUIDE/index.md`](GUIDE/index.md) — 14 chapters covering every system, tunable parameters, API reference, and the road to launch
- **Architecture Decisions:** `.thursian/projects/pond-conspiracy/design-docs/adrs/`
- **Implementation Reports:** `dev-docs/` — 39 per-epic technical reports

---

## Tech Stack

| Component | Choice | Notes |
|---|---|---|
| Engine | Godot 4.2+ (Forward+ renderer) | GDScript only |
| Bullet system | BulletUpHell (forked) | Customized for frog-themed patterns |
| Testing | GUT framework | 48 test files, ~8,500 lines |
| Save format | JSON + CRC32 checksums | Steam Cloud ready |
| Platform | GodotSteam | Achievements, Cloud, Steam Deck |

---

## Contributing

Read [`CLAUDE.md`](CLAUDE.md) for development conventions, module boundaries, and testing requirements. Read [`GUIDE/index.md`](GUIDE/index.md) before touching any system you haven't worked in before.

The environmental research grounding the conspiracy narrative is sourced in [`GUIDE/appendices/e-bibliography.md`](GUIDE/appendices/e-bibliography.md).
