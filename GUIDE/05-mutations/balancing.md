# Mutation Balancing

Balancing mutations is an ongoing process. This chapter covers the philosophy, parameter guidelines, and tools for tuning the mutation system.

---

## Design Philosophy

### Core Principles

1. **No Useless Mutations**: Every mutation should be pickable in some build
2. **No Must-Picks**: No mutation should be optimal in every situation
3. **Pollution = Risk/Reward**: Pollution mutations are powerful but dangerous
4. **Synergies Reward Planning**: Building toward synergies should feel rewarding
5. **10 Mutations = Powerful Frog**: A full build should feel strong

### The Ideal Run

A balanced run might look like:

```
Wave 1-3:   2 mutations (basic power)
Wave 4-6:   4 mutations (specialization begins)
Wave 7-9:   6-7 mutations (synergy achieved)
Wave 10+:   8-10 mutations (peak power)
```

Players should feel progression without trivializing late game.

---

## Stat Modifier Guidelines

### Speed Modifiers

| Category | Range | Example |
|----------|-------|---------|
| Minor | +10-15% | Slippery |
| Standard | +20% | Speed Boost |
| Synergy | +50% | Swamp King bonus |
| Max Stacked | ~100% | 400 px/s from 200 base |

**Design Note**: Speed caps naturally at ~400 px/s (2x base) before movement becomes difficult to control.

### Damage Modifiers

| Category | Range | Example |
|----------|-------|---------|
| Minor | +10-15% | Strong Legs |
| Standard | +20-25% | -- |
| Risky | +50% | Mercury Blood |
| Synergy | +25-40% | Apex Predator |

**Design Note**: Damage stacks multiplicatively. Three +25% mutations = 1.25^3 = 1.95x damage.

### Cooldown Modifiers

| Category | Range | Example |
|----------|-------|---------|
| Minor | -10% | Slippery |
| Standard | -20% | Quick Tongue |
| Synergy | -25% | Apex Predator |
| Effective Cap | -60% | Beyond this feels frantic |

**Design Note**: Cooldown reduction is powerful. Base 0.5s cooldown with -50% = 0.25s (4 attacks/second).

### HP Modifiers

| Category | Value | Example |
|----------|-------|---------|
| Positive | +1 | Tough Skin |
| Negative | -1 | Mercury Blood |
| Synergy | +1 | Pollution Immune |

**Design Note**: With 5 base HP, each HP point is 20% of total survivability. HP modifiers are impactful.

---

## Pollution Cost Guidelines

| Risk Level | Pollution Cost | Examples |
|------------|----------------|----------|
| Safe | 0 | All FROG type mutations |
| Low Risk | 10-12 | Toxic Aura (12) |
| Medium Risk | 15 | Oil Slick (15) |
| High Risk | 20 | Mercury Blood (20) |

### Pollution Budget

| Pollution Level | Status | Mutations |
|-----------------|--------|-----------|
| 0-33 | Safe | 0-2 pollution mutations |
| 34-67 | Caution | 2-3 pollution mutations |
| 68-100 | Danger | 3+ pollution mutations |

Taking all three pollution mutations: 12 + 15 + 20 = 47 base (with weights: ~81)

---

## Synergy Balance

### Bonus Magnitude

| Bonus Size | When to Use |
|------------|-------------|
| Small (+10-15%) | Broad synergies (many valid mutations) |
| Medium (+25-30%) | Standard synergies (3 specific mutations) |
| Large (+50%+) | Difficult synergies (rare combinations) |

### Current Synergies Analysis

**Apex Predator** (-25% cooldown)
- Requirements: 3 offensive mutations
- Difficulty: Medium (common mutations)
- Power: High (stacks with Quick Tongue)
- **Assessment**: Well-balanced

**Pollution Immune** (+1 HP)
- Requirements: 2 pollution + 1 defense
- Difficulty: High (requires pollution commitment)
- Power: Medium (offsets risk)
- **Assessment**: Could be stronger (+2 HP?)

**Swamp King** (+50% speed)
- Requirements: 3 mobility mutations
- Difficulty: Medium-High (Lily Pad is ability-based)
- Power: High (combined with base bonuses = extreme speed)
- **Assessment**: Potentially too strong, monitor

---

## Testing Methodology

### Playtesting Checklist

```markdown
## Mutation Balance Test

### Individual Mutations
- [ ] Each mutation is picked at least once across 10 runs
- [ ] No mutation is always picked
- [ ] Pollution mutations feel risky but worthwhile

### Synergies
- [ ] Each synergy is achieved at least once in 20 runs
- [ ] Synergy activation feels rewarding
- [ ] Synergy bonuses are noticeable

### Build Diversity
- [ ] Multiple viable build paths exist
- [ ] Speed builds, damage builds, and tank builds all work
- [ ] Pollution builds are high-risk/high-reward

### Power Curve
- [ ] Early game (1-3 mutations): Manageable challenge
- [ ] Mid game (4-6 mutations): Growing power
- [ ] Late game (7-10 mutations): Power fantasy
```

### Metrics to Track

| Metric | Target | Red Flag |
|--------|--------|----------|
| Pick rate per mutation | 5-15% | <2% or >25% |
| Synergy completion rate | 10-30% | <5% or >50% |
| Pollution build win rate | 40-60% | <30% or >70% |
| Average mutations at boss | 5-7 | <4 or >8 |

---

## Tuning Individual Mutations

### Weak Mutation Indicators

- Pick rate below 3%
- Never picked when offered with alternatives
- "Noob trap" reputation in community

### Weak Mutation Fixes

1. **Increase modifier**: +15% → +20%
2. **Add secondary effect**: Speed + slight dodge
3. **Reduce pollution cost**: 15 → 10
4. **Add synergy potential**: Include in new synergy

### Overpowered Mutation Indicators

- Pick rate above 20%
- Always picked regardless of build
- Enables one-shot builds

### Overpowered Mutation Fixes

1. **Reduce modifier**: +50% → +35%
2. **Add downside**: +Damage, -HP
3. **Increase pollution cost**: 10 → 15
4. **Make situational**: Effect only triggers conditionally

---

## Parameter Reference

### System Parameters

```gdscript
# mutation_manager.gd
@export var max_mutations: int = 10
@export var allow_duplicates: bool = false
```

### UI Parameters

```gdscript
# level_up_ui.gd
@export var options_count: int = 3
@export var card_width: int = 200
@export var card_height: int = 280
@export var card_spacing: int = 40
@export var animation_duration: float = 0.3
```

### Pollution Parameters

```gdscript
# pollution_meter.gd
@export var pollution_per_mutation: float = 15.0
@export var oil_mutation_weight: float = 1.5
@export var toxic_mutation_weight: float = 1.2
@export var mercury_mutation_weight: float = 2.0
@export var max_pollution: float = 100.0
@export var threshold_low: float = 0.33
@export var threshold_high: float = 0.67
```

---

## Future Balance Considerations

### Alpha Phase

- Add 8 more mutations
- Ensure new mutations don't obsolete existing ones
- Add 2 new synergies
- Test mutation combinations thoroughly

### Beta Phase

- Balance for Endless Mode
- Add mutation-boss interactions
- Test with Daily Challenge seeds
- Community feedback integration

### Launch

- Final balance pass
- Document "intended" build archetypes
- Leave room for player-discovered meta

---

## Sidebar: Balance Is Iterative

Perfect balance doesn't exist. The goal is:

1. **No obviously broken options**
2. **Multiple viable strategies**
3. **Interesting decisions at each level-up**
4. **Power fantasy at full build**

Track data, listen to players, and iterate. Balance is a process, not a destination.

---

## Quick Tuning Guide

| Want More... | Adjust |
|--------------|--------|
| Build diversity | Reduce outlier mutation power |
| Risk/reward | Increase pollution costs, increase pollution mutation power |
| Synergy hunting | Increase synergy bonuses, add synergy hints |
| Late-game power | Increase modifier caps, allow stronger stacking |
| Early-game challenge | Reduce early mutation power, increase option count |

---

## Summary

| Aspect | Guideline |
|--------|-----------|
| Speed mods | 10-25% standard, cap at ~100% total |
| Damage mods | 10-50%, multiplicative stacking |
| Cooldown mods | 10-25%, cap at ~60% reduction |
| HP mods | ±1-2, each point is ~20% survivability |
| Pollution costs | 0 (safe) to 20 (high risk) |
| Synergy bonuses | 25-50% based on difficulty |

Balance with data, iterate with playtesting, and remember: fun trumps math.

---

[← Back to Pollution Index](pollution-index.md) | [Back to Overview](overview.md)
