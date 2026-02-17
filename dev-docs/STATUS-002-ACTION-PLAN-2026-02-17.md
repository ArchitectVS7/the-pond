# Action Plan — Pond Conspiracy
**Date:** 2026-02-17
**Status:** MVP complete (78/78 stories) — Pre-Alpha
**Full assessment:** `dev-docs/STATUS-001-PROJECT-ASSESSMENT-2026-02-17.md`

---

## Summary

All systems are built. Nothing is connected into a playable game. The gap between "impressive codebase" and "shippable Early Access" is: a game loop, art, audio, and a Steam presence. These are sequenced below in dependency order.

---

## Priority 1 — Blocking (Do First)

### Integrate the full run loop

**What:** Connect combat → death → board update → return to menu into a single playable experience.

**Why it's blocking:** The project currently has no way for a human to play a full run. Every other milestone depends on this existing. You cannot test feel, cannot show press, cannot submit to Steam Next Fest.

**Concrete tasks:**
- [ ] Create `MainMenu.tscn` with a start-run button
- [ ] Wire `run_ended` EventBus signal → update conspiracy board state
- [ ] Wire board state → save via `save_completed` signal
- [ ] Confirm full chain fires end-to-end without errors
- [ ] Set `MainMenu.tscn` as the project's main scene (replace `TestArena.tscn`)
- [ ] Manual playthroughs: start → die → board shows evidence → start again

**Files to touch:**
- `project.godot` — change `application/run/main_scene`
- `core/event_bus.gd` — verify `run_ended` signal exists and carries run stats
- New: `combat/scenes/MainMenu.tscn` + script

---

## Priority 2 — Quick Win (Done: 2026-02-17)

### ~~Rewrite README.md~~

**Status: Complete.** Commit `47ed0b9`. The 6-line brainstorm note has been replaced with a professional project description covering the pitch, status, how to run, architecture, tech stack, and documentation links.

---

## Priority 3 — High Impact, Pre-Alpha Gate

### Art asset pass — minimum viable visual

**What:** The conspiracy board must be visually recognizable in a trailer. Placeholder geometry does not convey paranoia or environmental dread.

**Minimum viable scope:**
- [ ] Cork board texture (the board is the product differentiator — it must look real)
- [ ] Player frog sprite (idle + tongue attack)
- [ ] One boss sprite — Lobbyist or CEO
- [ ] Evidence card visual design
- [ ] HUD styling (pollution meter must read at a glance)

**What to defer:** Enemy variants, particle polish, background environments. Get the board and player readable first.

---

## Priority 4 — Pre-Alpha Gate

### Audio — minimum viable sound

**What:** Structure exists; content does not. Silent games do not convey genre or tone.

**Minimum viable scope:**
- [ ] Tongue attack SFX
- [ ] Enemy death SFX
- [ ] Cork board pin/connect SFX (this is a tactile moment — audio sells it)
- [ ] Ambient pond loop (sets atmosphere)
- [ ] Boss encounter music (one track, reusable)

**What to defer:** Dynamic music system, per-boss themes, voice acting.

---

## Priority 5 — Steam Strategy (Start Now, Long Lead Time)

### Steam presence — wishlist before Alpha

**What:** Steam store page and capsule image can be created now, before the game is playable. Wishlists accumulate over time. Steam Next Fest applications require existing store pages.

**Tasks:**
- [ ] Write store page description (use README.md pitch as the starting draft)
- [ ] Commission capsule image (the cork board must be visible or implied)
- [ ] Create a 30-second gif/trailer showing: combat → evidence drop → board update
- [ ] Submit store page for Steam review
- [ ] Identify next Steam Next Fest dates and application window

**Why now:** The review process takes weeks. Wishlists collected during Next Fest convert to sales at launch. Every month without a store page is lost wishlist time.

---

## Priority 6 — Technical Debt (Before Beta)

### BulletUpHell fork audit

**What:** Document exactly what was changed from the upstream BulletUpHell plugin.

**Why:** The fork has no change log. If Godot 4.x breaks plugin API compatibility, whoever fixes it starts from zero context. A one-time audit prevents a future crisis.

**Tasks:**
- [ ] Diff current fork against upstream
- [ ] Write `dev-docs/BULLET-008-FORK-DELTA.md` documenting every modification
- [ ] Note which changes are Pond Conspiracy-specific vs. upstream bug fixes

---

## Priority 7 — Content (Alpha Requirement)

### Expand data logs beyond 7

**What:** 7 evidence documents is not enough to sustain a full investigation arc. The conspiracy narrative needs content density to feel real.

**Target:** 15–20 data logs to cover the full corporate conspiracy storyline.

**Reference:** `GUIDE/10-content-creation/` has the tone guide and writing standards. `GUIDE/appendices/b-story-traceability.md` maps the story arc to content slots.

---

## Milestone Map

| Milestone | Blocker | Target |
|---|---|---|
| First playable run loop | Priority 1 (game loop) | ASAP |
| Alpha-ready build | Priorities 1, 3, 4 | After art + audio |
| Steam page live | Priority 5 | Start now, parallel |
| Beta-ready build | Priorities 6, 7 + Alpha feedback | Post-Alpha |
| 1.0 / Early Access | All of the above + QA | See GUIDE/13-launch-checklist/ |

---

## What Is Not on This List

These items exist in the codebase or GUIDE but are deferred per PRD v0.2 scope discipline:

- Visual mutations (Alpha/Beta)
- Dynamic music system (Alpha/Beta)
- Daily challenges (Alpha/Beta)
- Multiple endings (Beta)
- Additional boss encounters beyond Lobbyist + CEO (Beta)
- NGO partnership validation (can be pursued in parallel, not blocking)

---

*Full assessment: `dev-docs/STATUS-001-PROJECT-ASSESSMENT-2026-02-17.md`*
*Developer's Manual: `GUIDE/index.md`*
*Human steps checklist: `GUIDE/12-human-steps/`*
