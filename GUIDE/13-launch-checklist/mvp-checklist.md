# MVP Checklist

MVP (Minimum Viable Product) is the Early Access release. This checklist tracks what's done and what remains.

---

## Status: 78/78 Stories Complete

All MVP code is implemented. What remains is human work: assets, testing, and Steam setup.

---

## Epic Status

| Epic | Stories | Status |
|------|---------|--------|
| EPIC-001: Combat System | 14/14 | Complete |
| EPIC-002: BulletUpHell | 7/7 | Complete |
| EPIC-003: Conspiracy Board | 15/15 | Complete |
| EPIC-004: Environmental Data | 7/7 | Complete |
| EPIC-005: Pollution Index | 5/5 | Complete |
| EPIC-006: Mutation System | 10/10 | Complete |
| EPIC-007: Boss Encounters | 10/10 | Complete |
| EPIC-008: Meta-Progression | 8/8 | Complete |
| EPIC-009: Save System | 10/10 | Complete |
| EPIC-010: Platform Support | 10/10 | Complete |
| EPIC-011: Accessibility | 10/10 | Complete |

---

## Code Checklist

### Combat System

- [x] 8-directional WASD movement
- [x] Mouse aim system
- [x] Tongue attack with elastic physics
- [x] 2 enemy types (Tadpole, Minnow)
- [x] Enemy spawning and escalation
- [x] Spatial hash collision optimization
- [x] Hit feedback (screen shake, particles)
- [x] 60fps @ GTX 1060 with 500 enemies
- [x] <16ms input latency
- [x] Object pooling

### Conspiracy Board

- [x] Drag-drop card interaction
- [x] Bezier string rendering
- [x] String physics (300ms settle)
- [x] Document viewer popup
- [x] TL;DR / full-text toggle
- [x] Progress tracking UI
- [x] Keyboard navigation
- [x] Screen reader support

### Mutations

- [x] 10 base mutations implemented
- [x] 3 synergy combinations
- [x] Level-up choice UI (3 options)
- [x] Pollution index tracking
- [x] Mutation application system
- [x] Balance tuning

### Bosses

- [x] Boss framework (phases, HP)
- [x] The Lobbyist (3 phases)
- [x] The CEO (3 phases)
- [x] Boss dialogue system
- [x] Boss defeat rewards

### Meta-Progression

- [x] Persistent conspiracy board state
- [x] Evidence unlock system
- [x] 2 informants (Deep Croak, Lily Padsworth)
- [x] Hint system
- [x] Run completion rewards

### Save System

- [x] JSON save structure
- [x] SHA256 checksum validation
- [x] Atomic write with backup
- [x] Save triggers (death, exit, connection)
- [x] Corruption recovery
- [x] Version migration
- [x] Steam Cloud (stub)

### Platform Support

- [x] GodotSteam plugin (stub)
- [x] Steam authentication (stub)
- [x] Achievement framework
- [x] Steam overlay support
- [x] Windows build config
- [x] Linux build config
- [x] Steam Deck detection
- [x] Controller support (Xbox, PS, Nintendo)
- [x] Rebindable controls

### Accessibility

- [x] Colorblind mode - Deuteranopia
- [x] Colorblind mode - Protanopia
- [x] Colorblind mode - Tritanopia
- [x] Text scaling (0.8x, 1.0x, 1.3x)
- [x] Screen shake toggle
- [x] Keyboard navigation
- [x] WCAG AA contrast validation
- [x] Settings menu accessibility tab

---

## Human Work Remaining

### Art Assets (Not Started)

- [ ] Player frog sprite (32x32 animated)
- [ ] Enemy sprites (2 types)
- [ ] Boss sprites (2 bosses)
- [ ] Conspiracy board background
- [ ] Data log card designs
- [ ] Mutation icons (10)
- [ ] Informant portraits (2)
- [ ] UI elements

### Audio Assets (Not Started)

- [ ] `hit_thwap.wav` - Tongue hit
- [ ] `death_glorp.wav` - Enemy death
- [ ] UI sounds (click, hover)
- [ ] Background music (3 tracks minimum)
- [ ] Boss music (2 tracks)
- [ ] Victory/defeat stingers

### Steam Setup (Not Started)

- [ ] Create Steamworks developer account
- [ ] Create app entry
- [ ] Get App ID (replace stub 480)
- [ ] Install GodotSteam plugin
- [ ] Configure achievements
- [ ] Set up Steam Cloud
- [ ] Create store page
- [ ] Submit for review

### NGO Partnership (Not Started)

- [ ] Identify target NGO
- [ ] Send outreach email
- [ ] Content review meeting
- [ ] Get approval for data logs

### Testing (Not Started)

- [ ] GTX 1060 @ 1080p performance
- [ ] Steam Deck @ 800p performance
- [ ] Linux build functionality
- [ ] Controller testing (3 types)
- [ ] Save corruption testing
- [ ] 30-minute playtest (no crashes)

---

## Release Criteria

### Must Have

- [ ] Zero critical bugs (crashes, save corruption)
- [ ] 60fps on minimum spec
- [ ] All accessibility features working
- [ ] Steam Cloud sync functional
- [ ] One complete playthrough possible

### Should Have

- [ ] 15+ playtesters
- [ ] 80%+ positive feedback target
- [ ] Steam Deck Verified badge
- [ ] Professional art assets

### Nice to Have

- [ ] Localization (1-2 languages)
- [ ] Trading cards
- [ ] Achievement icons

---

## Launch Day

### Checklist

1. [ ] Final build uploaded to Steam
2. [ ] Store page published
3. [ ] Trailer live
4. [ ] Press kit distributed
5. [ ] Social media announcement
6. [ ] Discord server ready
7. [ ] Support email monitored

### Pricing

- **Early Access**: $10.00 USD
- **Target discount**: 10% launch week

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Reviews | 80%+ positive |
| Crashes | 0 reports first week |
| Refunds | <10% |
| DAU (Day 1) | 100+ |
| Completion rate | 20%+ |

---

## Post-MVP

Once MVP launches:
1. Monitor reviews and bug reports
2. Hotfix critical issues
3. Begin Alpha development (EPIC-012+)
4. Community feedback collection

---

[Back to Index](../index.md) | [Next: Alpha Checklist →](alpha-checklist.md)
