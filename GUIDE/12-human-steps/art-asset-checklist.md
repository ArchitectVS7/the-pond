# Art Asset Checklist

You need approximately 15 distinct art assets before launch. This guide breaks down exactly what's needed, in what format, and what decisions you'll make along the way.

---

## The Decision: Style Direction

Before commissioning or creating anything, nail down your visual style. The Pond has an environmental horror-comedy tone. Your art needs to support that.

**Questions to answer:**
- Pixel art or vector? (Pixel is more forgiving for solo devs)
- Color palette? (Muted swamp greens with toxic neon accents works thematically)
- Animation complexity? (More frames = more work, but smoother feel)

Once decided, document it. Every asset should feel like it belongs in the same game.

---

## Player Character: The Frog

| Asset | Dimensions | Frames | Notes |
|-------|------------|--------|-------|
| Idle | 32x32 | 4-8 | Breathing, subtle movement |
| Move | 32x32 | 6-8 | Hopping or walking cycle |
| Attack (Tongue) | 32x64+ | 4-6 | Tongue extends, consider separate tongue sprite |
| Hurt | 32x32 | 2-4 | Flash or recoil |
| Death | 32x32 | 4-6 | Dramatic enough to feel impactful |

**Total frames**: 20-38 minimum

The frog is your most-seen asset. Spend time here. A satisfying idle animation makes the game feel alive even when nothing's happening.

**Tip**: Consider the tongue as a separate sprite that stretches. Animating a full tongue-lash frame-by-frame is expensive. A stretching/rotating sprite is more flexible.

---

## Enemies (3 Types for MVP)

### Enemy 1: Polluted Tadpole
| Asset | Dimensions | Frames | Notes |
|-------|------------|--------|-------|
| Swim | 16x16 | 4 | Basic enemy, simple animation |
| Death | 16x16 | 3 | Poof or dissolve |

### Enemy 2: Toxic Minnow
| Asset | Dimensions | Frames | Notes |
|-------|------------|--------|-------|
| Swim | 24x16 | 4-6 | Faster, more aggressive silhouette |
| Attack | 24x16 | 2-3 | Lunge or bite telegraph |
| Death | 24x16 | 3 | Burst into particles |

### Enemy 3: (Future Alpha)
Reserve design space for a third enemy type. Could be a larger threat, a ranged attacker, or something that spawns smaller enemies.

**Design principle**: Enemies should read instantly. Players need to identify threat types in a chaotic screen. Distinct silhouettes matter more than detail.

---

## Bosses (4 Total)

### The Lobbyist (MVP)
| Asset | Dimensions | Frames | Notes |
|-------|------------|--------|-------|
| Idle | 128x128 | 4-6 | Imposing, suited figure or mutated corporate creature |
| Attack phases | 128x128 | 3-4 per attack | Multiple attack patterns |
| Hurt | 128x128 | 2 | Brief vulnerability state |
| Death | 128x128 | 8-12 | Satisfying defeat animation |

### The CEO (MVP)
Similar scope to Lobbyist. Consider visual escalation - this boss should feel like a step up.

### The Researcher (Alpha)
### The Sentient Pond (Beta)

**Boss art is the most time-intensive**. If commissioning, budget accordingly. If creating yourself, these are your stretch goals - get the gameplay working with placeholder art first.

---

## Conspiracy Board Assets

| Asset | Dimensions | Notes |
|-------|------------|-------|
| Board background | 1920x1080 | Cork board texture, or digital equivalent |
| Data log card (undiscovered) | 200x150 | Redacted/mysterious look |
| Data log card (discovered) | 200x150 | Readable, distinct by category |
| String/connection line | Tileable | The strings connecting evidence |
| Pin/thumbtack | 16x16 | Small detail, but visible |

The conspiracy board is your unique mechanic. It should feel tactile - like a real investigation board. Reference real conspiracy theory aesthetics, then add your environmental twist.

---

## Mutation Icons (15)

Each mutation needs a distinct icon. These appear in the mutation selection UI.

| Category | Examples | Style Notes |
|----------|----------|-------------|
| Offensive | Toxic Spit, Venomous Tongue | Aggressive colors, sharp shapes |
| Defensive | Thick Skin, Regeneration | Shields, organic curves |
| Utility | Speed Boost, Extended Range | Movement lines, range indicators |

**Size**: 64x64 works well for UI. Larger than you think - these need to read at a glance during gameplay.

**Consistency**: Same border treatment, same color language across all icons. Players should recognize a mutation icon even if they haven't seen that specific one.

---

## Informant Portraits (2)

| Character | Dimensions | Variants |
|-----------|------------|----------|
| Deep Croak | 256x256 | Neutral, concerned, excited |
| Lily Padsworth | 256x256 | Neutral, skeptical, determined |

These appear during dialogue. They're your narrative voice. Give them personality through expression variants.

---

## UI Elements

| Element | Notes |
|---------|-------|
| Health bar | Frog-themed? Lily pad segments? |
| Mutation slots | 3 slots, clear active/inactive states |
| Pause menu background | Semi-transparent, maintains game visibility |
| Button states | Normal, hover, pressed, disabled |
| Slider tracks and handles | Volume controls, accessibility settings |
| Panel backgrounds | For menus, popups, dialogs |

**UI art is often underestimated**. Budget time for it. Consistent UI makes the game feel polished even if the core art is simple.

---

## Steam Store Assets

These are required for Steam release:

| Asset | Dimensions | Required |
|-------|------------|----------|
| Capsule (Main) | 460x215 | Yes |
| Capsule (Small) | 231x87 | Yes |
| Capsule (Header) | 460x215 | Yes |
| Hero | 3840x1240 | Recommended |
| Library asset | 600x900 | Recommended |
| Screenshots | 1920x1080 | 5+ required |

**The main capsule is critical**. It's what appears in search results and recommendations. Invest in this.

---

## Asset Acquisition Options

### Option 1: Create Yourself
- **Pros**: Full control, no cost, learn new skills
- **Cons**: Time-intensive, learning curve
- **Tools**: Aseprite ($20, industry standard for pixel art), Piskel (free), GraphicsGale (free)

### Option 2: Commission
- **Pros**: Professional quality, faster
- **Cons**: Costs money, requires clear communication
- **Where**: Fiverr, ArtStation, Twitter/X art communities, itch.io devlogs
- **Budget estimate**: $50-200 per major asset, $10-30 per icon/small asset

### Option 3: AI Generation + Cleanup
- **Pros**: Fast iteration, cheap
- **Cons**: Requires significant cleanup, consistency issues, ethical debates
- **Note**: AI-generated art often needs hand-editing to match a coherent style

### Option 4: Asset Store
- **Pros**: Immediate, cheap
- **Cons**: Not unique, may not match your vision
- **Where**: itch.io game assets, OpenGameArt, Kenney.nl (free)

---

## Priority Order

If you're doing this incrementally:

1. **Player frog** (core gameplay)
2. **One enemy type** (something to fight)
3. **Basic UI** (health, mutations)
4. **Steam capsule** (required for store page)
5. **Remaining enemies**
6. **First boss**
7. **Conspiracy board assets**
8. **Mutation icons**
9. **Informant portraits**
10. **Remaining bosses**

---

## Tracking Progress

| Asset | Status | Notes |
|-------|--------|-------|
| Player frog (all states) | Not Started | - |
| Polluted Tadpole | Not Started | - |
| Toxic Minnow | Not Started | - |
| Enemy 3 | Not Started | Design pending |
| The Lobbyist | Not Started | - |
| The CEO | Not Started | - |
| The Researcher | Not Started | Alpha |
| The Sentient Pond | Not Started | Beta |
| Board background | Not Started | - |
| Data log cards | Not Started | - |
| Mutation icons (15) | Not Started | - |
| Deep Croak portrait | Not Started | - |
| Lily Padsworth portrait | Not Started | - |
| UI elements | Not Started | - |
| Steam capsules | Not Started | - |

---

## Resources

- **Lospec Palette List**: https://lospec.com/palette-list - Curated pixel art palettes
- **Aseprite**: https://www.aseprite.org/ - Pixel art editor
- **Reference boards**: Create a Pinterest or PureRef board of games with similar aesthetic goals

---

[Back to Human Steps Overview](overview.md) | [Next: Audio Asset Checklist](audio-asset-checklist.md)
