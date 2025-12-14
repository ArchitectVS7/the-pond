# Audio Asset Checklist

Sound is half the game feel. A satisfying "thwap" when your tongue connects, the squelch of an enemy death, the unsettling ambiance of a polluted swamp - these make The Pond feel alive.

This guide covers what you need, in what format, and how to get it.

---

## Audio Specifications

Before sourcing any audio, know your target format:

| Parameter | Recommendation | Why |
|-----------|---------------|-----|
| Format | `.wav` for SFX, `.ogg` for music | WAV is uncompressed (better for short SFX), OGG is smaller (better for long music) |
| Sample rate | 44100 Hz | Standard CD quality, overkill for retro but future-proof |
| Bit depth | 16-bit | Sufficient for games, smaller files than 24-bit |
| Channels | Mono for SFX, Stereo for music | Mono SFX can be positioned in 3D space |

---

## Sound Effects

### Combat SFX

| Sound | Description | Duration | Priority |
|-------|-------------|----------|----------|
| `tongue_shoot.wav` | Tongue extending | 0.2-0.4s | High |
| `tongue_hit.wav` | Tongue connects with enemy | 0.1-0.2s | High |
| `tongue_miss.wav` | Tongue retracts without hit | 0.2-0.3s | Medium |
| `enemy_death_small.wav` | Tadpole/small enemy death | 0.3-0.5s | High |
| `enemy_death_medium.wav` | Minnow death | 0.3-0.5s | High |
| `player_hurt.wav` | Taking damage | 0.2-0.4s | High |
| `player_death.wav` | Player dies | 0.5-1.0s | High |

**Design notes**:
- The tongue attack is your core verb. It needs to feel *satisfying*. Think about the elastic snap of a rubber band combined with a wet impact.
- Enemy deaths should be distinct by enemy type. This helps players track what they're killing in chaos.

### Mutation SFX

| Sound | Description | Duration |
|-------|-------------|----------|
| `mutation_select.wav` | Choosing a mutation | 0.3-0.5s |
| `mutation_activate.wav` | Mutation effect triggers | 0.2-0.4s |
| `level_up.wav` | Gaining a level/mutation slot | 0.5-0.8s |

### UI SFX

| Sound | Description | Duration |
|-------|-------------|----------|
| `menu_hover.wav` | Hovering over button | 0.05-0.1s |
| `menu_click.wav` | Clicking button | 0.1-0.15s |
| `menu_back.wav` | Backing out of menu | 0.1-0.2s |
| `pause_open.wav` | Opening pause menu | 0.2-0.3s |
| `pause_close.wav` | Closing pause menu | 0.2-0.3s |

**Design notes**: UI sounds should be subtle. They're heard constantly - annoying UI sounds will drive players away.

### Conspiracy Board SFX

| Sound | Description | Duration |
|-------|-------------|----------|
| `card_pickup.wav` | Grabbing a data log | 0.1-0.2s |
| `card_drop.wav` | Placing a data log | 0.1-0.2s |
| `string_connect.wav` | Creating a connection | 0.2-0.3s |
| `document_open.wav` | Opening document viewer | 0.2-0.4s |
| `discovery.wav` | Uncovering new evidence | 0.5-0.8s |

**Design notes**: The board is contemplative. Sounds here should feel satisfying but not intrusive - players will be thinking, reading, connecting dots.

### Boss SFX

Each boss needs:
- Phase transition sound
- Unique attack sounds (2-3 per boss)
- Defeat sound (celebratory, impactful)

| Sound | Description | Duration |
|-------|-------------|----------|
| `boss_intro.wav` | Boss appears | 1.0-2.0s |
| `boss_phase_change.wav` | Entering new phase | 0.5-1.0s |
| `boss_defeat.wav` | Boss dies | 1.0-2.0s |

---

## Music

### Track Requirements

| Track | Where it plays | Length | Loop? |
|-------|---------------|--------|-------|
| Main menu | Title screen | 1-2 min | Yes |
| Combat (Normal) | Standard gameplay | 2-3 min | Yes |
| Combat (Intense) | Low health or swarm | 2-3 min | Yes |
| Boss theme | Boss encounters | 2-3 min | Yes |
| Conspiracy board | Board exploration | 2-3 min | Yes |
| Victory | Run complete | 30-60s | No |
| Defeat | Game over | 30-60s | No |

**Minimum viable**: 3 tracks (Menu, Combat, Boss). You can launch with this and add more post-release.

### Music Direction

The Pond sits at an interesting tonal intersection:
- **Horror**: Polluted swamp, mutated creatures, corporate evil
- **Comedy**: You're a frog with a conspiracy board
- **Action**: Fast roguelike combat

Your music needs to support all three. Consider:
- Synth with organic textures (industrial meets nature)
- Minor keys for tension, major for triumph
- Tempo that matches gameplay intensity
- Ambient layers for the conspiracy board (thoughtful, mysterious)

### Looping Considerations

For looping tracks:
- Intro section (plays once): 5-10 seconds
- Loop section (repeats): Rest of track
- No hard cuts - end should flow into beginning
- Mark loop points in your audio editor

Godot handles loop points via import settings. Note the exact sample number where your loop should restart.

---

## Stingers and Transitions

Short musical phrases that punctuate moments:

| Stinger | When it plays | Duration |
|---------|--------------|----------|
| `discovery_stinger.wav` | Major conspiracy connection | 2-4s |
| `mutation_stinger.wav` | Powerful mutation acquired | 1-2s |
| `danger_stinger.wav` | Low health warning | 1-2s |

Stingers should complement, not interrupt, the background music. Consider their key and tempo relationship to your main tracks.

---

## Acquisition Options

### Option 1: Create Yourself

**Free tools**:
- **Audacity**: Recording and editing
- **BFXR/SFXR**: Retro sound effect generator
- **LMMS**: Free digital audio workstation
- **Bosca Ceoil**: Simple music creation for games

**Paid tools**:
- **FL Studio** ($99-499): Industry standard DAW
- **Reaper** ($60): Affordable professional DAW
- **Splice** ($7.99/mo): Sound library subscription

**Learning resources**:
- GDC talks on game audio (free on YouTube)
- "A Sound Effect" blog
- r/GameAudio subreddit

### Option 2: Commission

**Where to find composers/sound designers**:
- Twitter/X game audio community
- Fiverr (varies wildly in quality)
- Reddit r/gameDevClassifieds
- itch.io devlog community

**Budget estimates**:
- SFX pack (20-30 sounds): $100-300
- Music track: $100-500 per minute
- Full audio package: $500-2000

**What to provide commissioners**:
- Reference tracks (games/media with similar vibe)
- Gameplay footage or builds
- Written tone description
- Technical specifications (format, loop points)

### Option 3: Stock Audio

**Free sources**:
- Freesound.org (CC licensed, check each license)
- OpenGameArt.org (specifically for games)
- Kenney.nl (free asset packs)

**Paid sources**:
- Epidemic Sound ($15/mo)
- Artlist ($199/year)
- Asset stores (Unity, itch.io)

**Caution**: Stock audio can feel generic. Plan to layer, edit, and customize to make it yours.

### Option 4: AI-Generated

Tools like Udio, Suno, or ElevenLabs can generate music and SFX.

**Pros**: Fast, cheap, infinite iteration
**Cons**: Quality inconsistency, licensing uncertainty, may sound artificial

If using AI audio, plan for significant post-processing and editing.

---

## Implementation Notes

### Godot Audio Setup

```
res://audio/
├── sfx/
│   ├── combat/
│   ├── ui/
│   ├── board/
│   └── boss/
├── music/
│   ├── menu/
│   ├── combat/
│   ├── boss/
│   └── board/
└── stingers/
```

### Volume Balancing

| Category | Relative Volume | Notes |
|----------|----------------|-------|
| Music | 0.7 (70%) | Baseline |
| Combat SFX | 1.0 (100%) | Needs to cut through |
| UI SFX | 0.5 (50%) | Subtle, not annoying |
| Ambient | 0.6 (60%) | Present but not dominant |

These are starting points. Playtest and adjust.

### Audio Bus Structure

Godot uses audio buses for mixing:
- Master
  - Music
  - SFX
    - Combat
    - UI
    - Ambient
  - Voice (if applicable)

This lets players adjust music vs SFX volume independently.

---

## Priority Order

1. **Core combat SFX** (tongue, hits, deaths) - Makes the game feel playable
2. **One music track** (combat) - Breaks the silence
3. **UI sounds** - Polish feel
4. **Boss music** - Elevates boss encounters
5. **Conspiracy board SFX** - Completes the second pillar
6. **Additional music tracks** - Variety
7. **Stingers** - Polish

---

## Tracking Progress

| Asset | Status | Notes |
|-------|--------|-------|
| tongue_shoot.wav | Not Started | - |
| tongue_hit.wav | Not Started | - |
| enemy_death (small) | Not Started | - |
| enemy_death (medium) | Not Started | - |
| player_hurt.wav | Not Started | - |
| player_death.wav | Not Started | - |
| UI sounds (set) | Not Started | - |
| Board SFX (set) | Not Started | - |
| Combat music | Not Started | - |
| Boss music | Not Started | - |
| Menu music | Not Started | - |
| Board music | Not Started | - |
| Victory stinger | Not Started | - |
| Defeat stinger | Not Started | - |

---

[Back to Human Steps Overview](overview.md) | [Previous: Art Assets](art-asset-checklist.md) | [Next: Steam Store Setup](steam-store-setup.md)
