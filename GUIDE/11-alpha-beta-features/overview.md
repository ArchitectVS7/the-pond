# Alpha/Beta Features Overview

MVP is complete. This chapter documents what comes next: the features planned for Alpha (months 1-3) and Beta (months 4-6) releases.

---

## Roadmap

### Alpha (Post-MVP, Months 1-3)

| Epic | Feature | Stories |
|------|---------|---------|
| EPIC-012 | Third Boss (The Researcher) | 6 |
| EPIC-013 | Second Ending Path | 5 |
| EPIC-014 | Additional Mutations (15 total) | 7 |
| EPIC-015 | Visual Mutation Effects | 6 |
| EPIC-016 | Dynamic Music System | 6 |

**Total**: 27 stories

### Beta (Pre-1.0, Months 4-6)

| Epic | Feature | Stories |
|------|---------|---------|
| EPIC-017 | Secret Boss (Sentient Pond) | 7 |
| EPIC-018 | Third Ending Path (Nihilist) | 5 |
| EPIC-019 | Daily Challenges & Leaderboards | 7 |
| EPIC-020 | Endless Mode | 6 |

**Total**: 22 stories

---

## What's Here

| File | Feature | Phase |
|------|---------|-------|
| [Visual Mutations](visual-mutations.md) | Frog appearance changes | Alpha |
| [Dynamic Music](dynamic-music.md) | Intensity-based crossfades | Alpha |
| [Daily Challenges](daily-challenges.md) | Seeded runs, leaderboards | Beta |
| [Endless Mode](endless-mode.md) | Infinite survival | Beta |
| [Endings](endings.md) | Multiple ending paths | Alpha/Beta |

---

## Alpha Features

### Third Boss: The Researcher

A lab coat-wearing frog boss with science-themed attacks.

**Patterns**:
- Phase 1: "Controlled Experiment" - Grid patterns
- Phase 2: "Chemical Reaction" - Expanding bubbles
- Phase 3: "Unstable Compound" - Explosive bursts

**Dialogue Style**: Academic, detached, references "data" and "results"

### Visual Mutation Effects

Player frog appearance changes based on mutations:

| Mutation | Visual Effect |
|----------|---------------|
| Oil Trail | Black sludge trail |
| Toxic Aura | Green particle glow |
| Mercury Skin | Metallic sheen |

### Dynamic Music

Music layers crossfade based on combat intensity:

| Layer | Trigger |
|-------|---------|
| Ambient | No combat |
| Combat Low | 1-10 enemies |
| Combat High | 10+ enemies |
| Boss | Boss active |

### Second Ending

Government conspiracy variant. Different evidence connections lead to regulatory capture reveal.

---

## Beta Features

### Secret Boss: Sentient Pond

The pond itself, polluted into consciousness.

**Unlock Condition**:
1. Defeat all 3 main bosses
2. Collect all 7 evidence pieces
3. Find 3 hidden "Pond Memory" collectibles
4. Return to starting area

**Patterns**:
- Phase 1: Rising Tide - Waves from edges
- Phase 2: Whirlpool - Spiral pulling
- Phase 3: Tsunami - Screen-filling chaos
- Phase 4: Fake death, then surprise attack

### Daily Challenges

Seeded runs where everyone plays the same challenge:

- Same seed = same run globally
- One attempt per day
- Steam leaderboards
- Streak rewards

### Endless Mode

Survive as long as possible:

- Infinite enemy scaling
- Score-based leaderboard
- Mutation choices continue
- High score tracking

### Third Ending

Nihilist path. Give up on the conspiracy.

---

## Implementation Priority

### Alpha Priority Order

1. **Additional Mutations** (EPIC-014) - Most impact for effort
2. **Third Boss** (EPIC-012) - Content expansion
3. **Second Ending** (EPIC-013) - Narrative depth
4. **Visual Mutations** (EPIC-015) - Polish
5. **Dynamic Music** (EPIC-016) - Polish

### Beta Priority Order

1. **Daily Challenges** (EPIC-019) - Replayability
2. **Secret Boss** (EPIC-017) - Discovery content
3. **Endless Mode** (EPIC-020) - Additional mode
4. **Third Ending** (EPIC-018) - Narrative completion

---

## Dependencies

```
MVP Complete
    │
    ├── EPIC-012 (Third Boss) ──► EPIC-017 (Secret Boss)
    │
    ├── EPIC-013 (Second Ending) ──► EPIC-018 (Third Ending)
    │
    ├── EPIC-014 (More Mutations)
    │
    ├── EPIC-015 (Visual Mutations)
    │
    ├── EPIC-016 (Dynamic Music)
    │
    └── EPIC-019 (Daily Challenges)
            │
            └── EPIC-020 (Endless Mode)
```

---

## Technical Considerations

### Visual Mutations

- Sprite layering system needed
- Performance impact of additional draw calls
- Particle effects for auras

### Dynamic Music

- Audio bus management
- Smooth crossfade algorithm
- Memory for multiple tracks

### Daily Challenges

- Server time synchronization
- Steam leaderboard API
- Seed determinism testing

### Secret Boss

- Larger arena requirements
- Environmental hazard system
- 4-phase state machine (not 3)

---

## Success Metrics

### Alpha

- Third boss feels unique from existing bosses
- Visual mutations don't impact performance
- Music crossfades smoothly (no pops/clicks)
- Early Access reviews remain 80%+ positive

### Beta

- Secret boss discoverable by <10% of players
- Daily challenges drive daily active users
- Endless mode leaderboard has competition
- All 3 endings feel distinct

---

## Human Dependencies

Some features need human work:

| Feature | Human Need |
|---------|------------|
| Third Boss | Boss sprite art |
| Visual Mutations | Mutation visual art |
| Dynamic Music | Additional music tracks |
| Secret Boss | Unique boss art |
| All Endings | Cutscene art |

See [Human Steps](../12-human-steps/overview.md) for details.

---

## Next Steps

Review the detailed documentation for each feature:
1. [Visual Mutations](visual-mutations.md) - Sprite system
2. [Dynamic Music](dynamic-music.md) - Audio layers
3. [Daily Challenges](daily-challenges.md) - Seeding and leaderboards
4. [Endless Mode](endless-mode.md) - Infinite scaling
5. [Endings](endings.md) - Multiple paths

---

[Back to Index](../index.md) | [Next: Visual Mutations](visual-mutations.md)
