# Epic-007: Boss Encounters - Implementation Documentation

## Overview
Complete implementation of 2 boss fights for Pond Conspiracy: The Lobbyist (mid-boss) and The CEO (final boss).

## Architecture

### Core Systems

#### BossBase (boss_base.gd)
Base class for all boss encounters with:
- **3-Phase State Machine**: IDLE -> PHASE_1 -> PHASE_2 -> PHASE_3 -> DEFEATED
- **HP-Based Transitions**: Auto-transition at 66% (Phase 2) and 33% (Phase 3)
- **Invulnerability Frames**: During intro and phase transitions
- **Evidence System**: Spawns evidence items on defeat
- **Difficulty Scaling**: HP and speed scaling based on mutation count + hard mode

**State Flow:**
```
IDLE (intro) -> PHASE_1 (66% HP) -> PHASE_2 (33% HP) -> PHASE_3 (0% HP) -> DEFEATED
```

#### BossArena (boss_arena.gd)
Arena management system:
- **Trigger System**: Player entry triggers boss spawn
- **Arena Locking**: Walls appear and lock player in arena
- **Enemy Clearing**: Removes regular enemies before boss spawn
- **Spawn Delay**: Cinematic pause before boss appears

### Boss Implementations

#### The Lobbyist (boss_lobbyist.gd)
**Difficulty**: Medium | **HP**: 100

**Phase 1 - "Business Cards"**
- Pattern: Aimed single shots
- Speed: 150 px/s
- Cooldown: 2.0s
- Strategy: Simple tracking bullets

**Phase 2 - "Marketing Blitz"**
- Pattern: 8-way radial burst
- Speed: 200 px/s
- Cooldown: 1.5s
- Strategy: Circle of bullets forces movement

**Phase 3 - "Hostile Takeover"**
- Pattern: Spiral + aimed combo
- Speed: 250 px/s (spiral), 200 px/s (aimed)
- Cooldown: 1.0s
- Strategy: Dual-threat pattern

**Dialogue:**
- Intro: "Ah, a concerned citizen! Let me show you our... stakeholder engagement process."
- Phase 2: "Time for aggressive negotiations!"
- Phase 3: "This is YOUR fault for not synergizing!"
- Defeat: "My... quarterly reports... ruined..."

#### The CEO (boss_ceo.gd)
**Difficulty**: Hard | **HP**: 150

**Phase 1 - "Board Meeting"**
- Pattern: 5 vertical bullet walls
- Speed: 120 px/s
- Spacing: 100px between walls
- Strategy: Navigate through gaps

**Phase 2 - "Leveraged Buyout"**
- Pattern: Homing bullets
- Homing Strength: 2.0
- Duration: 3.0s
- Strategy: Bullets track player position

**Phase 3 - "Market Crash"**
- Pattern: 8 random-direction bullets
- Speed: 100-300 px/s (random)
- Cooldown: 1.2s
- Strategy: Screen-filling chaos

**Dialogue:**
- Intro: "You think you can stop PROGRESS? I AM the pond. I AM the pollution. I AM... THE MARKET!"
- Phase 2: "Your little investigation ends HERE!"
- Phase 3: "ENOUGH! I'll bury you like I buried the evidence!"
- Defeat: "No... the board will hear about this..."

### Supporting Systems

#### BossDialogue (boss_dialogue.gd)
UI system for boss dialogue:
- **Queue System**: Multiple dialogue lines with auto-sequencing
- **Fade Animations**: 0.3s fade in/out
- **Display Duration**: 3.0s per line
- **Auto-Clear**: Removes dialogue after display

## File Structure

```
combat/
├── scripts/
│   ├── boss_base.gd          # Base boss class
│   ├── boss_arena.gd         # Arena management
│   ├── boss_lobbyist.gd      # Lobbyist implementation
│   ├── boss_ceo.gd           # CEO implementation
│   └── boss_dialogue.gd      # Dialogue UI system
└── scenes/
    ├── BossArena.tscn        # Arena scene template
    ├── BossLobbyist.tscn     # Lobbyist boss scene
    ├── BossCEO.tscn          # CEO boss scene
    └── BossDialogue.tscn     # Dialogue UI scene

test/unit/
├── test_boss_framework.gd    # BossBase tests
├── test_boss_lobbyist.gd     # Lobbyist tests
├── test_boss_ceo.gd          # CEO tests
└── test_boss_arena.gd        # Arena tests
```

## Integration Points

### Dependencies (Already Complete)
- **EPIC-001**: Combat system (Player, Enemy base classes)
- **EPIC-002**: BulletUpHell integration (bullet_spawner node)
- **EventBus**: `core/event_bus.gd` (boss_defeated, evidence_dropped signals)

### Signals
```gdscript
# BossBase
signal phase_changed(new_phase: int)
signal boss_defeated
signal dialogue_triggered(text: String)

# BossArena
signal boss_spawned
signal arena_locked
signal arena_unlocked
```

### EventBus Integration
```gdscript
# On boss defeat
EventBus.boss_defeated.emit(boss_class_name)

# On evidence drop
EventBus.evidence_dropped.emit(evidence_id)
```

## Difficulty Scaling

### Mutation Scaling
- **HP Scaling**: +5% per mutation (max 150% total HP)
- **Speed Scaling**: +2% per mutation (max 150% speed)
- **Formula**: `scaled_value = base_value * (1 + min(mutations * scale_rate, max_scaling - 1))`

### Hard Mode
- **Multiplier**: 1.5x on top of mutation scaling
- **Example**: 5 mutations + hard mode = 1.25 * 1.5 = 1.875x HP

### Application
```gdscript
boss.apply_difficulty_scaling(mutation_count, hard_mode_enabled)
```

## Placeholder Art

Current implementation uses ColorRect placeholders:
- **Lobbyist**: 64x64 blue rectangle with "LOBBYIST" label
- **CEO**: 96x96 red rectangle with "THE CEO" label
- **Arena Walls**: Red rectangles (800x600 arena)

**Note**: Replace with pixel art assets before final release. Placeholder art allows testing gameplay mechanics without art dependency.

## Testing

### Test Coverage
- **test_boss_framework.gd**: 17 tests for BossBase
- **test_boss_lobbyist.gd**: 8 tests for Lobbyist
- **test_boss_ceo.gd**: 8 tests for CEO
- **test_boss_arena.gd**: 8 tests for Arena system

### Test Categories
1. **State Management**: Phase transitions, state machine
2. **Damage System**: HP reduction, invulnerability
3. **Signals**: Phase changes, defeat events
4. **Difficulty Scaling**: HP/speed scaling, hard mode
5. **Arena Logic**: Locking, spawning, triggering

### Running Tests
```bash
# All boss tests
godot --headless -s addons/gut/gut_cmdln.gd -gdir=test/unit -gprefix=test_boss

# Specific test
godot --headless -s addons/gut/gut_cmdln.gd -gtest=test_boss_framework.gd
```

## Story Completion

### BOSS-001: Boss Framework ✓
- 3-phase state machine
- HP-based transitions
- Invulnerability system
- Phase change signals

### BOSS-002: Arena System ✓
- Trigger-based spawning
- Arena locking mechanism
- Enemy clearing
- Wall collision system

### BOSS-003: Lobbyist Design ✓
- Placeholder sprite (64x64)
- Scene setup with AnimationPlayer
- Health bar UI

### BOSS-004: Lobbyist Patterns ✓
- Phase 1: Aimed shots
- Phase 2: Radial burst
- Phase 3: Spiral + aimed combo
- BulletUpHell integration

### BOSS-005: Lobbyist Dialogue ✓
- Corporate speak dialogue
- Phase-based triggers
- Defeat message

### BOSS-006: CEO Design ✓
- Placeholder sprite (96x96, larger)
- Scene setup with AnimationPlayer
- Health bar UI

### BOSS-007: CEO Patterns ✓
- Phase 1: Bullet walls
- Phase 2: Homing bullets
- Phase 3: Chaos pattern
- Advanced bullet mechanics

### BOSS-008: CEO Dialogue ✓
- Final boss dialogue
- Dramatic phase messages
- Defeat message

### BOSS-009: Evidence Drops ✓
- Evidence spawning on defeat
- EventBus integration
- Evidence ID system

### BOSS-010: Difficulty Scaling ✓
- Mutation-based scaling
- Hard mode multiplier
- Max scaling cap

## Next Steps

1. **Art Integration**: Replace placeholder ColorRects with pixel art sprites
2. **BulletUpHell Patterns**: Create custom .json pattern files in `combat/resources/bullet_patterns/`
3. **Sound Effects**: Add SFX for phase transitions, attacks, defeat
4. **Music**: Boss battle music tracks
5. **VFX**: Particle effects for attacks, phase transitions
6. **Animation**: Proper sprite animations for idle, attack, transition, defeat

## Technical Notes

### Performance Considerations
- Boss bullets use BulletUpHell pooling system (from EPIC-002)
- Max bullets per phase managed by cooldown timers
- Arena walls use static collision (no physics updates)

### Known Limitations
1. **Homing Bullets**: Requires custom BulletUpHell implementation or workaround
2. **Bullet Spawning at Position**: `_spawn_bullet_at()` uses position reset (may flicker)
3. **Evidence Scene**: Assumes `res://metagame/scenes/Evidence.tscn` exists (EPIC-004 dependency)

### Future Enhancements
- Additional boss phases (4-5 phases for harder difficulties)
- Boss attack combinations (attack patterns that combo together)
- Environmental hazards in arena
- Mid-fight cutscenes
- Boss rush mode

## Credits
- Framework: Epic-007 specification
- Implementation: Hierarchical swarm coordination
- Testing: GUT framework (Godot Unit Testing)
