# Mutation System Balance Documentation

## Overview
This document outlines the balance philosophy and tuning rationale for the Pond Conspiracy mutation system. All values are subject to playtest adjustment.

## Balance Philosophy

### Core Principles
1. **Risk vs Reward**: Pollution mutations offer higher power but increase game difficulty
2. **Build Diversity**: No single mutation should dominate all builds
3. **Synergy Discovery**: Powerful combinations reward exploration
4. **Progressive Power**: Players should feel stronger with each mutation while maintaining challenge

### Power Budget System
- Base mutations: 100% power budget (no pollution cost)
- Pollution mutations: 150-200% power budget (+12-20 pollution cost)
- Synergies: +25-50% bonus to existing stats

## Base Frog Mutations (10 Total)

### Tier 1: Core Stats
**Swift Legs** - +20% move speed
- Rationale: Mobility is valuable but not game-breaking
- Synergy potential: High (works with most builds)
- Power level: 1.0x

**Tough Skin** - +1 max HP
- Rationale: 20% HP increase (from base 5) is significant survival boost
- Synergy potential: Medium (defensive builds)
- Power level: 1.1x

**Strong Legs** - +10% damage
- Rationale: Modest damage increase, stackable with other bonuses
- Synergy potential: High (offensive builds)
- Power level: 1.0x

### Tier 2: Attack Modifiers
**Quick Tongue** - -15% attack cooldown
- Rationale: DPS increase ~17%, balanced against damage modifiers
- Synergy potential: Very High (Apex Predator combo)
- Power level: 1.2x

**Long Reach** - +30% tongue range
- Rationale: Safety and positioning advantage
- Synergy potential: Very High (Apex Predator combo)
- Power level: 1.1x

**Big Eyes** - +10% crit chance
- Rationale: Base 5% + 10% = 15% crit rate, noticeable but not overpowered
- Synergy potential: Medium (requires crit damage system)
- Power level: 1.0x

### Tier 3: Evasion & Utility
**Slippery Skin** - +15% dodge chance
- Rationale: Direct survivability without HP increase
- Synergy potential: High (Swamp King combo)
- Power level: 1.2x

**Sticky Feet** - Immune to knockback
- Rationale: Situational but very strong against specific enemies
- Synergy potential: Low (niche defensive)
- Power level: 0.8x (situational)

### Tier 4: Special Abilities
**Power Dash** - Dash ability (1s cooldown)
- Rationale: Massive mobility spike, skill-based evasion
- Synergy potential: Medium
- Power level: 1.3x

**Regeneration** - Heal 1 HP every 30s
- Rationale: 2 HP per minute sustain, rewards patient play
- Synergy potential: Low
- Power level: 1.1x

## Pollution Mutations (3 Total)

### Oil Slick - +15 pollution
**Stats**: Damaging trail (2 damage over 3s)
- Power budget: 1.6x (zone control + damage)
- Risk: Moderate pollution gain
- Ideal for: Aggressive kiting builds

### Toxic Aura - +12 pollution
**Stats**: 1 DPS in 80 unit radius
- Power budget: 1.5x (passive AOE damage)
- Risk: Lower pollution than Oil Slick
- Ideal for: Close-range builds

### Mercury Blood - +20 pollution
**Stats**: +50% damage, -1 max HP
- Power budget: 2.0x (massive damage spike)
- Risk: High pollution + HP reduction = glass cannon
- Ideal for: Skilled players seeking maximum damage
- Balance note: Most risky mutation in game

## Special Frog Mutations (3 Total)

### Split Tongue
**Stats**: Attack hits 30-degree cone
- Power budget: 1.4x (multi-target potential)
- Synergy: Apex Predator combo
- Ideal for: Crowd control

### Lily Pad
**Stats**: Temporary platform (5s duration, 8s cooldown)
- Power budget: 1.2x (utility/positioning)
- Synergy: Swamp King combo
- Ideal for: Vertical level navigation

### War Croak
**Stats**: AOE stun (2s duration, 150 radius, 10s cooldown)
- Power budget: 1.5x (powerful crowd control)
- Balance note: Long cooldown prevents spam
- Ideal for: Emergency survival

## Synergy Combinations (3 Total)

### Apex Predator
**Requirements**: Quick Tongue + Long Reach + Strong Legs
**Bonus**: -25% attack cooldown (total: -40% with Quick Tongue)
- Rationale: Offensive combo requires 3 mutations, provides top-tier DPS
- Power multiplier: 1.5x total build power
- Playstyle: Aggressive, high-skill ceiling

### Pollution Immune
**Requirements**: Oil Slick + Toxic Aura + Tough Skin
**Bonus**: +1 HP (counters pollution HP loss)
- Rationale: Requires heavy pollution investment (27 total)
- Power multiplier: 1.3x (makes pollution builds viable)
- Playstyle: Tank/AOE hybrid

### Swamp King
**Requirements**: Lily Pad + Slippery + Swift Legs
**Bonus**: +50% move speed (total: +70% with Swift Legs)
- Rationale: Mobility/evasion combo with utility
- Power multiplier: 1.4x
- Playstyle: Hit-and-run, platform mastery

## Pollution System Integration

### Pollution Thresholds
- 0-10: Safe zone
- 11-25: Minor enemy buffs
- 26-50: Moderate enemy buffs + environmental hazards
- 51+: Severe enemy buffs + boss modifications

### Pollution Mutation Strategy
- Single pollution mutation (12-20): Manageable risk
- Two pollution mutations (24-40): High risk, high reward
- Three pollution mutations (36-60): Expert-only builds
- Pollution Immune synergy: Unlocks safe 3-pollution builds

## Tunable Parameters

### Base Frog Mutations
1. Swift Legs: `speed_modifier = 0.2` (range: 0.15-0.30)
2. Tough Skin: `hp_modifier = 1` (range: 1-2)
3. Quick Tongue: `attack_cooldown_modifier = -0.15` (range: -0.10 to -0.20)
4. Long Reach: `range_modifier = 0.3` (range: 0.25-0.40)
5. Big Eyes: `crit_chance_modifier = 0.1` (range: 0.05-0.15)
6. Strong Legs: `damage_modifier = 0.1` (range: 0.10-0.20)
7. Slippery: `dodge_chance_modifier = 0.15` (range: 0.10-0.25)
8. Power Dash: `dash_cooldown = 1.0` (range: 0.5-2.0)
9. Regeneration: `heal_interval = 30.0` (range: 20-45)

### Pollution Mutations
10. Oil Slick: `pollution_cost = 15` (range: 10-20)
11. Oil Slick: `trail_damage = 2` (range: 1-3)
12. Toxic Aura: `pollution_cost = 12` (range: 8-15)
13. Toxic Aura: `aura_damage = 1` (range: 1-2)
14. Mercury Blood: `pollution_cost = 20` (range: 15-25)
15. Mercury Blood: `damage_modifier = 0.5` (range: 0.3-0.7)

### Special Frog Mutations
16. Split Tongue: `cone_angle = 30.0` (range: 20-45)
17. Lily Pad: `platform_duration = 5.0` (range: 3-8)
18. Lily Pad: `ability_cooldown = 8.0` (range: 5-12)
19. War Croak: `stun_duration = 2.0` (range: 1.5-3.0)
20. War Croak: `stun_radius = 150.0` (range: 100-200)
21. War Croak: `ability_cooldown = 10.0` (range: 8-15)

### Synergies
22. Apex Predator: `attack_cooldown_bonus = -0.25` (range: -0.20 to -0.35)
23. Pollution Immune: `hp_bonus = 1` (range: 1-2)
24. Swamp King: `speed_bonus = 0.5` (range: 0.3-0.7)

### System Parameters
25. Max mutations: `max_mutations = 10` (range: 8-15)
26. Level-up choices: `options_count = 3` (range: 2-4)
27. Allow duplicates: `allow_duplicates = false` (boolean)
28. Card hover scale: `hover_scale = 1.05` (range: 1.03-1.10)
29. Animation duration: `animation_duration = 0.3` (range: 0.2-0.5)

## Playtest Monitoring

### Key Metrics to Track
1. **Mutation pick rate** - Which mutations are chosen most often?
2. **Synergy completion rate** - How often do players complete synergies?
3. **Pollution distribution** - What's the average pollution level at run end?
4. **Win rate by build** - Which mutation combinations have highest success?
5. **Time to first mutation** - How quickly do players level up?

### Red Flags
- Any mutation picked >50% of the time
- Any mutation picked <5% of the time
- Synergy completion rate >40% (too easy)
- Synergy completion rate <5% (too hard)
- Average pollution >60 (too much pressure)
- Average pollution <15 (not enough incentive)

### Balance Adjustment Strategy
1. **Week 1**: Gather raw data, no changes
2. **Week 2**: Adjust outliers (>50% or <5% pick rate)
3. **Week 3**: Fine-tune synergy bonuses
4. **Week 4**: Final polish based on win rates

## Known Balance Concerns

### Potential Issues
1. **Mercury Blood** might be too risky (HP loss + pollution)
   - Solution: Consider reducing pollution cost to 15

2. **Sticky Feet** very situational
   - Solution: May need additional benefit (e.g., +5% move speed)

3. **Apex Predator** may dominate competitive play
   - Solution: Monitor win rates, consider reducing to -20% cooldown bonus

4. **Swamp King** requires specific level design
   - Solution: Ensure 30%+ of levels have water surfaces

### Future Expansion Ideas
- Add 6 more mutations (total 22)
- Add 2 more synergies (total 5)
- Add HYBRID mutation type (Frog + Pollution)
- Add negative mutations (high power, severe drawbacks)

## Conclusion
This balance framework prioritizes experimentation during early playtests. All values are starting points and should be adjusted based on actual player behavior and feedback.
