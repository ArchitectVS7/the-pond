# The Researcher

**Status**: Planned for Alpha Phase

The Researcher is the third boss, representing the scientists who knew about the pollution but stayed silent. This document outlines the design direction.

---

## Character Concept

**Name**: Dr. [REDACTED]
**Title**: Chief Research Scientist
**Theme**: Lab experiments gone wrong

**Personality**: Nervous, defensive, justifies actions with "the greater good" and "scientific progress." Unlike the Lobbyist's smugness or CEO's megalomania, the Researcher is sympathetic - they're trapped, not evil.

---

## Narrative Role

The Researcher provides moral complexity:

- **The Lobbyist**: Corruption (greed)
- **The CEO**: Power (ambition)
- **The Researcher**: Complicity (fear/career)

Their evidence reveals the company knew the dangers but suppressed findings. Scientists who tried to speak up were fired.

---

## Proposed Dialogue

```gdscript
var dialogue_data: Dictionary = {
    "intro": "I... I was just following protocol. The data was inconclusive! That's what they told me to write...",
    "phase2": "You don't understand! They would have ruined me!",
    "phase3": "Fine! If I'm going down, I'll take you with me! FOR SCIENCE!",
    "defeat": "Maybe... maybe this is for the best. Take the files. Expose them all."
}
```

The Researcher is the only boss who accepts defeat with relief.

---

## Proposed Patterns

### Phase 1: Lab Protocols

**Concept**: Predictable, methodical patterns

- Bullets spawn in grid formations
- Easy to read, like data points
- Theme: Order, control, denial

**Gameplay**: Players learn the grid patterns quickly. Low stress intro.

### Phase 2: Contamination

**Concept**: Patterns start breaking down

- Grid becomes unstable
- Bullets leave trails (pollution)
- Some bullets split into smaller ones

**Gameplay**: Increased chaos, but still readable. Represents data being corrupted.

### Phase 3: Total Meltdown

**Concept**: Lab containment fails

- Bullets mutate mid-flight (change direction/speed)
- Spawns "test subject" enemies
- Screen effects (flickering, corruption)

**Gameplay**: Final skill check. Bullet mutation is the unique mechanic.

---

## Proposed Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| HP | 125 | Between Lobbyist and CEO |
| Phase 2 threshold | 0.60 | Slightly earlier |
| Phase 3 threshold | 0.30 | Standard |
| P1 grid size | 4x4 | 16 bullets per pattern |
| P2 trail duration | 1.5s | Lingering danger |
| P3 mutation chance | 30% | Per bullet |

---

## Unique Mechanics

### Bullet Mutation (Phase 3)

```gdscript
# Concept code
func _process_bullet_mutation(bullet: Node2D) -> void:
    if current_phase == 3 and randf() < mutation_chance:
        # Random mutation effect
        match randi() % 3:
            0: bullet.velocity = bullet.velocity.rotated(deg_to_rad(45))
            1: bullet.velocity *= 1.5
            2: _split_bullet(bullet)
```

Players must stay alert - bullets don't always behave predictably.

### Test Subject Spawns (Phase 3)

Small mutated creatures spawn during Phase 3:

- Weak enemies (1 HP)
- Add pressure during bullet dodging
- Drop small health if killed
- Theme: Failed experiments escaping

---

## Evidence Preview

```
RESEARCH LOG - CONFIDENTIAL

Day 147: Contamination levels exceed safe limits by 400%.
Dr. Chen recommended immediate disclosure to EPA.

Day 148: Dr. Chen was "reassigned to another project."

Day 149: I was told to revise the findings. "Margin of error."

Day 150: I revised them. God forgive me.

Day 151: The frogs are dying.
```

---

## Visual Direction

### Environment

- Lab setting with broken equipment
- Green toxic glow
- Test tubes and beakers as background elements

### Boss Design

- Disheveled scientist frog in lab coat
- Glowing eyes (chemical exposure)
- Phase 3: Lab coat burns, reveals mutations

### Bullet Aesthetics

- Phase 1: Clean white data points
- Phase 2: Green-tinted, leaving trails
- Phase 3: Unstable, flickering, mutating

---

## Audio Direction

- Phase 1: Clinical beeps, lab ambient
- Phase 2: Warning alarms begin
- Phase 3: Full alarm, glass breaking, chaos

---

## Development Priority

### Alpha Must-Have

- [ ] Basic three-phase structure
- [ ] Grid-based Phase 1 pattern
- [ ] Trail mechanic for Phase 2
- [ ] Bullet mutation for Phase 3
- [ ] Evidence drop

### Alpha Nice-to-Have

- [ ] Test subject spawns
- [ ] Screen corruption effects
- [ ] Unique bullet visuals

### Can Defer to Beta

- [ ] Full animation set
- [ ] Voice lines
- [ ] Environmental destruction

---

## Implementation Notes

The Researcher can reuse most of `BossBase`:

```gdscript
class_name BossResearcher
extends BossBase

func _ready() -> void:
    total_hp = 125
    evidence_id = "researcher_evidence"
    super._ready()
```

New systems needed:
- Bullet trail renderer
- Bullet mutation system
- Test subject spawner (optional)

---

## Balance Considerations

The Researcher sits between Lobbyist (easy) and CEO (hard):

| Aspect | Lobbyist | Researcher | CEO |
|--------|----------|------------|-----|
| HP | 100 | 125 | 150 |
| Pattern complexity | Low | Medium | High |
| Unique mechanic | None | Mutation | Chaos |
| Difficulty | Easy | Medium | Hard |

Players should feel prepared for the CEO after mastering the Researcher's unpredictability.

---

## Summary

The Researcher adds:

1. **Moral depth**: Complicity vs. active evil
2. **New mechanic**: Bullet mutation
3. **Narrative bridge**: Links Lobbyist evidence to CEO evidence
4. **Difficulty curve**: Medium challenge between two extremes

Design finalization during Alpha sprint.

---

[← Back to The CEO](ceo.md) | [Next: Sentient Pond →](sentient-pond.md)
