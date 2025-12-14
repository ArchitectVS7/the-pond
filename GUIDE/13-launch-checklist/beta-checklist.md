# Beta Checklist

Beta is the final content phase before 1.0. Secret boss, third ending, daily challenges, and endless mode complete the package.

---

## Timeline

**Start**: 4 months post-MVP (after Alpha)
**Duration**: 2 months
**Stories**: 22 (across 4 epics)
**Goal**: Feature complete, ready for 1.0 polish

---

## Epic Status

| Epic | Stories | Status |
|------|---------|--------|
| EPIC-017: Secret Boss (Sentient Pond) | 7 | Not Started |
| EPIC-018: Third Ending (Nihilist) | 5 | Not Started |
| EPIC-019: Daily Challenges | 7 | Not Started |
| EPIC-020: Endless Mode | 6 | Not Started |

---

## EPIC-017: Secret Boss (Sentient Pond)

### Stories

- [ ] SECRET-001: Sentient Pond boss design
- [ ] SECRET-002: Secret unlock condition (easter egg)
- [ ] SECRET-003: Water-themed bullet patterns
- [ ] SECRET-004: 4-phase mechanics
- [ ] SECRET-005: Eldritch horror dialogue
- [ ] SECRET-006: True ending reward
- [ ] SECRET-007: Secret boss achievements

### Unlock Requirements

1. Defeat all 3 main bosses
2. Collect all 7 evidence pieces
3. Find 3 hidden "Pond Memory" collectibles
4. Return to starting area

### Success Criteria

- Secret is discoverable by <10% of players naturally
- Fight feels climactic and unique
- 4 phases (more than other bosses)
- True ending is satisfying

---

## EPIC-018: Third Ending (Nihilist)

### Stories

- [ ] ENDING3-001: Nihilist evidence branch
- [ ] ENDING3-002: Ending 3 cutscene art
- [ ] ENDING3-003: Ending 3 narrative writing
- [ ] ENDING3-004: Unlock condition logic
- [ ] ENDING3-005: Achievement integration

### Unlock Requirements

- 50+ deaths
- <30% conspiracy completion
- Choose "Give Up" dialogue option

### Success Criteria

- Ending feels intentionally unsatisfying
- Motivates players to try again
- Distinct from other endings
- Post-credits tease encourages retry

---

## EPIC-019: Daily Challenges

### Stories

- [ ] DAILY-001: Seeded run generation
- [ ] DAILY-002: Daily challenge framework
- [ ] DAILY-003: Steam leaderboard integration
- [ ] DAILY-004: Daily challenge UI
- [ ] DAILY-005: Leaderboard display (top 100)
- [ ] DAILY-006: Challenge rewards
- [ ] DAILY-007: Expiration logic

### Success Criteria

- Same seed = same run globally
- One attempt per day
- Leaderboards update in real-time
- Rewards feel worthwhile
- Streak system drives retention

---

## EPIC-020: Endless Mode

### Stories

- [ ] ENDLESS-001: Infinite spawning system
- [ ] ENDLESS-002: Exponential difficulty scaling
- [ ] ENDLESS-003: Endless mode UI
- [ ] ENDLESS-004: Endless leaderboard
- [ ] ENDLESS-005: Endless achievements
- [ ] ENDLESS-006: Balance tuning

### Success Criteria

- Difficulty scales smoothly
- Most players survive 3-7 minutes
- Top players can survive 15-20 minutes
- Leaderboard is competitive
- Mutations remain useful at high difficulty

---

## Human Work

### Art

- [ ] Sentient Pond boss sprite (large, animated)
- [ ] Pond arena (special water effects)
- [ ] Ending 3 cutscene images (5-8)
- [ ] Daily challenge UI elements
- [ ] Endless mode HUD

### Audio

- [ ] Secret boss music (epic, unsettling)
- [ ] Ending 3 music (melancholy)
- [ ] Daily challenge fanfare
- [ ] Endless mode music (escalating)

### Writing

- [ ] Sentient Pond dialogue (philosophical, creepy)
- [ ] Ending 3 narrative (bleak but honest)
- [ ] Daily challenge flavor text
- [ ] Achievement descriptions

---

## Technical Requirements

### Seeded RNG

- [ ] All gameplay RNG uses seed
- [ ] Same seed produces identical run
- [ ] Seed displayed optionally

### Steam Integration

- [ ] Leaderboard API working
- [ ] Score upload reliable
- [ ] Offline handling graceful

### Performance

- [ ] Endless mode stable at difficulty 20+
- [ ] Secret boss arena handles complex effects
- [ ] No memory leaks in long sessions

---

## Testing

### Secret Boss

- [ ] Unlock condition works correctly
- [ ] All 4 phases function
- [ ] True ending triggers properly
- [ ] Achievement unlocks

### Daily Challenges

- [ ] Server time sync accurate
- [ ] One attempt enforced
- [ ] Scores upload correctly
- [ ] Leaderboard displays properly

### Endless Mode

- [ ] Difficulty scales as designed
- [ ] No crashes in long sessions
- [ ] Scores save on death
- [ ] Leaderboard functional

### Balance

- [ ] Secret boss challenging but fair
- [ ] Daily challenges completable
- [ ] Endless difficulty curve feels right

---

## Release Criteria

### Must Have

- [ ] Secret boss fully playable
- [ ] All 4 endings achievable
- [ ] Daily challenges functional
- [ ] Endless mode playable
- [ ] No critical bugs
- [ ] No performance regressions

### Should Have

- [ ] Steam leaderboards working
- [ ] All achievements functional
- [ ] Player feedback addressed
- [ ] Polish pass complete

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Reviews | 85%+ positive (stretch goal) |
| Secret boss discovery | <10% natural |
| Secret boss defeat | 50%+ of those who find |
| Daily challenge participation | 20%+ DAU |
| Endless high score | Top score > 30 min survival |

---

## Post-Beta (1.0 Prep)

1. Final polish pass
2. Marketing push prep
3. Press kit update
4. 1.0 pricing decision ($10 → $15)
5. Launch date announcement

---

[← Back to Alpha Checklist](alpha-checklist.md) | [Next: 1.0 Checklist →](1.0-checklist.md)
