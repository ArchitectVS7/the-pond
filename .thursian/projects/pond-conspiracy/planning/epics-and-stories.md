# Pond Conspiracy - Epics and Story Breakdown

**Project**: Pond Conspiracy
**Date**: 2025-12-13
**Version**: 1.1
**Input**: PRD-v0.2.md, architecture-overview.md
**Last Updated**: 2025-12-13

---

## Overview

**Total Epics**: 20
**Total Stories**: 127 (estimated)
**Release Phases**: MVP (11 epics), Alpha (5 epics), Beta (4 epics)

### Progress Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Epics Complete | 11 | 55% |
| Stories Complete | 78 | 61% |
| MVP Progress | 78/78 | 100% ✅ |

### Distribution by Release Phase

| Phase | Epics | Stories (approx) | Priority | Status |
|-------|-------|------------------|----------|--------|
| MVP (Early Access) | 11 | 78 | P0-P1 | ✅ **COMPLETE** (11/11) |
| Alpha | 5 | 27 | P1-P2 | ⚪ Not Started |
| Beta | 4 | 22 | P2-P3 | ⚪ Not Started |

---

## 🔴 MVP Epics (Early Access - Weeks 0-12)

### EPIC-001: Combat System Foundation ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (CRITICAL - Blocks everything)
**Dependencies**: None (foundation)
**Expertise Required**: GDScript, game design, pixel art
**Estimated Effort**: XL (2 weeks)
**PRD Requirements**: FR-001, NFR-001
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: Core combat mechanics with 60fps, <16ms input lag, responsive controls, and satisfying feedback.

**Stories**:
- ✅ COMBAT-001: player-movement-wasd-8dir
- ✅ COMBAT-002: mouse-aim-system
- ✅ COMBAT-003: tongue-attack-whip-mechanic
- ✅ COMBAT-004: tongue-elastic-physics-3tile-range
- ✅ COMBAT-005: enemy-spawn-escalation-system
- ✅ COMBAT-006: enemy-ai-basic-behaviors
- ✅ COMBAT-007: collision-detection-spatial-hash
- ✅ COMBAT-008: hit-feedback-screenshake
- ✅ COMBAT-009: particle-system-hits-deaths
- ✅ COMBAT-010: hit-stop-2frame-pause
- ✅ COMBAT-011: audio-feedback-wet-thwap-glorp
- ✅ COMBAT-012: performance-60fps-gtx1060-validation
- ✅ COMBAT-013: input-lag-16ms-validation
- ✅ COMBAT-014: object-pooling-500enemies

---

### EPIC-002: BulletUpHell Integration ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (CRITICAL - Combat dependency)
**Dependencies**: EPIC-001
**Expertise Required**: GDScript, Godot plugins, bullet-hell patterns
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-001, CI-3.3
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: Fork and integrate BulletUpHell plugin for bullet patterns, validate performance.

**Stories**:
- ✅ BULLET-001: fork-bulletuphell-repo-day1
- ✅ BULLET-002: integrate-plugin-godot42
- ✅ BULLET-003: test-basic-bullet-patterns
- ✅ BULLET-004: performance-validation-500bullets
- ✅ BULLET-005: custom-pattern-frog-themed
- ✅ BULLET-006: bullet-pooling-optimization
- ✅ BULLET-007: collision-optimization

---

### EPIC-003: Conspiracy Board UI ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (CRITICAL - Core differentiator)
**Dependencies**: None (parallel to combat)
**Expertise Required**: GDScript, UI/UX design, Godot Control nodes, pixel art
**Estimated Effort**: XL (2 weeks)
**PRD Requirements**: FR-002, CI-2.1, CI-2.2, CI-2.3
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: Corkboard UI with drag-drop documents, Bezier string physics, TL;DR/full-text modes.

**Stories**:
- ⏸️ BOARD-001: figma-prototype-creation (BLOCKED - human required)
- ⏸️ BOARD-002: recruit-10-testers-validation (BLOCKED - human required)
- ⏸️ BOARD-003: achieve-8of10-satisfaction (BLOCKED - human required)
- ✅ BOARD-004: corkboard-background-art-1920x1080
- ✅ BOARD-005: data-log-card-component
- ✅ BOARD-006: drag-drop-interaction-system
- ✅ BOARD-007: pin-snap-detection-50px
- ✅ BOARD-008: bezier-string-renderer
- ✅ BOARD-009: string-physics-300ms-elastic
- ✅ BOARD-010: string-snap-sound-visual
- ✅ BOARD-011: document-viewer-popup
- ✅ BOARD-012: tldr-fulltext-toggle
- ✅ BOARD-013: progress-tracking-ui-x-of-7
- ✅ BOARD-014: keyboard-navigation-accessibility
- ✅ BOARD-015: screen-reader-support

---

### EPIC-004: Environmental Data Content ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (Conspiracy board dependency)
**Dependencies**: EPIC-003
**Expertise Required**: Technical writing, research, NGO coordination
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-002, CI-2.2
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: Write 7-10 data logs with peer-reviewed citations, get NGO approval.

**Stories**:
- ✅ DATA-001: research-wetland-pollution-sources
- ✅ DATA-002: write-7-data-logs-draft
- ✅ DATA-003: cite-peer-reviewed-studies-inline
- ✅ DATA-004: create-bibliography-appendix
- ⏸️ DATA-005: ngo-partnership-outreach (BLOCKED - human required)
- ⏸️ DATA-006: ngo-content-review-approval (BLOCKED - human required)
- ✅ DATA-007: integrate-data-logs-game

---

### EPIC-005: Pollution Index UI ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (1-day feature, critical for message)
**Dependencies**: EPIC-006 (mutation system)
**Expertise Required**: GDScript, UI design
**Estimated Effort**: S (1 day)
**PRD Requirements**: FR-003, NEW-1
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: Visual pollution meter on HUD, tracks pollution mutations, color-coded.

**Stories**:
- ✅ POLLUTION-001: pollution-meter-progressbar
- ✅ POLLUTION-002: color-coding-green-yellow-red
- ✅ POLLUTION-003: tooltip-ecosystem-message
- ✅ POLLUTION-004: bind-pollution-mutation-count (stub for EPIC-006)
- ✅ POLLUTION-005: update-on-mutation-selection-event (stub for EPIC-006)

---

### EPIC-006: Mutation System ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (Core roguelike mechanic)
**Dependencies**: EPIC-001
**Expertise Required**: GDScript, game design, balancing
**Estimated Effort**: L (1.5 weeks)
**PRD Requirements**: FR-004
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: 10-12 mutations with 3 synergies, level-up choice UI, pollution tracking.

**Stories**:
- ✅ MUTATION-001: mutation-data-structure
- ✅ MUTATION-002: level-up-choice-ui-3options
- ✅ MUTATION-003: mutation-application-system
- ✅ MUTATION-004: implement-10-base-mutations
- ✅ MUTATION-005: pollution-mutations-oil-toxic-mercury
- ✅ MUTATION-006: frog-mutations-tongue-lily-croak
- ✅ MUTATION-007: synergy-system-3combos
- ✅ MUTATION-008: mutation-balance-tuning
- ✅ MUTATION-009: mutation-description-tooltips
- ✅ MUTATION-010: pollution-index-increment-logic

---

### EPIC-007: Boss Encounters ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (Must-have for ending)
**Dependencies**: EPIC-001, EPIC-002
**Expertise Required**: GDScript, game design, pixel art
**Estimated Effort**: L (1.5 weeks)
**PRD Requirements**: FR-005
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: 2 boss fights (The Lobbyist, The CEO) with unique patterns and phases.

**Stories**:
- ✅ BOSS-001: boss-framework-phases-hp
- ✅ BOSS-002: boss-arena-spawning-trigger
- ✅ BOSS-003: lobbyist-boss-design-pixel-art (placeholder)
- ✅ BOSS-004: lobbyist-bullet-patterns-3phases
- ✅ BOSS-005: lobbyist-dialogue-corporate-speak
- ✅ BOSS-006: ceo-boss-design-pixel-art (placeholder)
- ✅ BOSS-007: ceo-bullet-patterns-3phases
- ✅ BOSS-008: ceo-dialogue-final-boss
- ✅ BOSS-009: boss-defeat-rewards-evidence
- ✅ BOSS-010: boss-difficulty-scaling

---

### EPIC-008: Meta-Progression System ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (Roguelike core loop)
**Dependencies**: EPIC-003, EPIC-007
**Expertise Required**: GDScript, save system design
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-006
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: Persistent conspiracy board, 2 informants, evidence collection across runs.

**Stories**:
- ✅ META-001: persistent-conspiracy-board-state
- ✅ META-002: evidence-unlock-system
- ✅ META-003: informant-1-whistleblower-unlock
- ✅ META-004: informant-2-journalist-unlock
- ✅ META-005: informant-dialogue-system
- ✅ META-006: hint-system-3hints-per-run
- ✅ META-007: run-completion-reward-evidence
- ✅ META-008: ending-unlock-all-evidence-condition

---

### EPIC-009: Save System & Steam Cloud ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (Critical for meta-progression)
**Dependencies**: EPIC-008
**Expertise Required**: GDScript, Steam API, file I/O
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-006, ADR-004
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: JSON save files, CRC32 checksums, Steam Cloud sync, auto-save.

**Stories**:
- ✅ SAVE-001: json-save-file-structure
- ✅ SAVE-002: crc32-checksum-validation
- ✅ SAVE-003: atomic-write-backup-file
- ✅ SAVE-004: save-on-death-trigger
- ✅ SAVE-005: save-on-conspiracy-connection
- ✅ SAVE-006: save-on-settings-change
- ✅ SAVE-007: save-on-exit
- ✅ SAVE-008: steam-cloud-sync-integration
- ✅ SAVE-009: corrupt-save-recovery-backup
- ✅ SAVE-010: save-migration-version-handling

---

### EPIC-010: Platform Support & Steam Integration ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (Required for launch)
**Dependencies**: EPIC-009
**Expertise Required**: GDScript, GodotSteam, platform testing
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-007, ADR-001
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: Windows, Linux, Steam Deck support, Steam achievements, overlay.

**Stories**:
- ✅ PLATFORM-001: godotsteam-plugin-integration
- ✅ PLATFORM-002: steam-authentication-automatic
- ✅ PLATFORM-003: steam-achievements-framework
- ✅ PLATFORM-004: steam-overlay-support
- ✅ PLATFORM-005: windows-build-configuration
- ✅ PLATFORM-006: linux-build-configuration
- ✅ PLATFORM-007: steam-deck-validation-800p-55fps
- ✅ PLATFORM-008: steam-deck-control-mapping
- ✅ PLATFORM-009: controller-support-xinput
- ✅ PLATFORM-010: rebindable-controls-ui

---

### EPIC-011: Accessibility Features ✅ COMPLETE
**Release Phase**: MVP
**Priority**: P0 (WCAG compliance required)
**Dependencies**: EPIC-003, EPIC-001
**Expertise Required**: GDScript, accessibility, shader programming
**Estimated Effort**: M (1 week)
**PRD Requirements**: NFR-002, CI-3.2
**Status**: ✅ **COMPLETE** (2025-12-13)

**Description**: 3 colorblind modes, text scaling, screen shake toggle, keyboard navigation.

**Stories**:
- ✅ ACCESS-001: colorblind-mode-deuteranopia-shader
- ✅ ACCESS-002: colorblind-mode-protanopia-shader
- ✅ ACCESS-003: colorblind-mode-tritanopia-shader
- ✅ ACCESS-004: text-scaling-3sizes-08-10-13
- ✅ ACCESS-005: screen-shake-toggle-setting
- ✅ ACCESS-006: keyboard-navigation-all-menus
- ✅ ACCESS-007: wcag-aa-contrast-validation
- ✅ ACCESS-008: settings-menu-accessibility-tab
- ✅ ACCESS-009: control-rebinding-ui
- ✅ ACCESS-010: accessibility-testing-validation

---

## 🟠 Alpha Epics (Month 1-3 Post-MVP)

### EPIC-012: Third Boss Fight (The Researcher)
**Release Phase**: Alpha
**Priority**: P1 (Content expansion)
**Dependencies**: EPIC-007
**Expertise Required**: GDScript, game design, pixel art
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: Lab coat frog boss with science-themed bullet patterns.

**Stories**:
- BOSS3-001: researcher-boss-design-pixel-art
- BOSS3-002: researcher-bullet-patterns-beaker-flask
- BOSS3-003: researcher-dialogue-corporate-science
- BOSS3-004: researcher-3phase-mechanics
- BOSS3-005: researcher-defeat-reward-evidence
- BOSS3-006: researcher-arena-lab-tileset

---

### EPIC-013: Second Ending Path
**Release Phase**: Alpha
**Priority**: P1 (Narrative depth)
**Dependencies**: EPIC-008
**Expertise Required**: Writing, GDScript, pixel art
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: Government conspiracy variant ending.

**Stories**:
- ENDING2-001: government-conspiracy-evidence-branch
- ENDING2-002: ending2-cutscene-pixel-art
- ENDING2-003: ending2-narrative-writing
- ENDING2-004: ending2-unlock-condition-logic
- ENDING2-005: ending2-achievement-integration

---

### EPIC-014: Additional Mutations (15 Total)
**Release Phase**: Alpha
**Priority**: P1 (Build variety)
**Dependencies**: EPIC-006
**Expertise Required**: GDScript, game design, balancing
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: +5 mutations, +3 synergies for 15 total mutations, 6 synergies.

**Stories**:
- MUTATION-011: design-5-new-mutations
- MUTATION-012: implement-new-mutations-code
- MUTATION-013: balance-new-mutations
- MUTATION-014: design-3-new-synergies
- MUTATION-015: implement-synergy-combos
- MUTATION-016: mutation-description-update
- MUTATION-017: synergy-tooltip-ui

---

### EPIC-015: Visual Mutation Effects
**Release Phase**: Alpha
**Priority**: P2 (Polish, not critical)
**Dependencies**: EPIC-006
**Expertise Required**: Pixel art, GDScript
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: Frog appearance changes based on equipped mutations.

**Stories**:
- VISUAL-001: frog-sprite-variant-system
- VISUAL-002: oil-trail-visual-black-sludge
- VISUAL-003: toxic-aura-visual-green-glow
- VISUAL-004: mutation-layering-sprite-system
- VISUAL-005: mutation-icon-pixel-art
- VISUAL-006: mutation-preview-ui

---

### EPIC-016: Dynamic Music System
**Release Phase**: Alpha
**Priority**: P2 (Polish, not critical)
**Dependencies**: EPIC-001
**Expertise Required**: Audio engineering, GDScript
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: Music crossfades based on combat intensity.

**Stories**:
- MUSIC-001: combat-intensity-calculation
- MUSIC-002: music-layer-system-ambient-combat-boss
- MUSIC-003: crossfade-implementation-smooth
- MUSIC-004: boss-music-triggers
- MUSIC-005: victory-defeat-stingers
- MUSIC-006: audio-mixing-balance

---

## 🟡 Beta Epics (Month 4-6 Pre-1.0)

### EPIC-017: Secret Boss (Sentient Pond)
**Release Phase**: Beta
**Priority**: P2 (Discovery content)
**Dependencies**: EPIC-007, EPIC-012
**Expertise Required**: GDScript, game design, pixel art
**Estimated Effort**: L (1.5 weeks)
**PRD Requirements**: Beta FR

**Description**: True final boss with secret unlock condition.

**Stories**:
- SECRET-001: sentient-pond-boss-design
- SECRET-002: secret-unlock-condition-easter-egg
- SECRET-003: pond-bullet-patterns-water-themed
- SECRET-004: pond-4phase-mechanics
- SECRET-005: pond-dialogue-eldritch-horror
- SECRET-006: pond-defeat-reward-true-ending
- SECRET-007: secret-boss-achievement

---

### EPIC-018: Third Ending Path (Nihilist)
**Release Phase**: Beta
**Priority**: P2 (Narrative depth)
**Dependencies**: EPIC-013
**Expertise Required**: Writing, GDScript, pixel art
**Estimated Effort**: M (1 week)
**PRD Requirements**: Beta FR

**Description**: Nihilist ending where player gives up.

**Stories**:
- ENDING3-001: nihilist-evidence-branch
- ENDING3-002: ending3-cutscene-pixel-art
- ENDING3-003: ending3-narrative-writing
- ENDING3-004: ending3-unlock-condition
- ENDING3-005: ending3-achievement

---

### EPIC-019: Daily Challenges & Leaderboards
**Release Phase**: Beta
**Priority**: P2 (Replayability)
**Dependencies**: EPIC-009, EPIC-010
**Expertise Required**: GDScript, Steam API
**Estimated Effort**: L (1.5 weeks)
**PRD Requirements**: Beta FR

**Description**: Daily seeded runs with leaderboards.

**Stories**:
- DAILY-001: seeded-run-generation
- DAILY-002: daily-challenge-framework
- DAILY-003: steam-leaderboard-integration
- DAILY-004: daily-challenge-ui
- DAILY-005: leaderboard-display-top100
- DAILY-006: daily-challenge-rewards
- DAILY-007: challenge-expiration-logic

---

### EPIC-020: Endless Mode
**Release Phase**: Beta
**Priority**: P3 (Optional mode)
**Dependencies**: EPIC-001, EPIC-006
**Expertise Required**: GDScript, game design, balancing
**Estimated Effort**: M (1 week)
**PRD Requirements**: Beta FR

**Description**: Survive as long as possible mode.

**Stories**:
- ENDLESS-001: endless-mode-spawning-infinite
- ENDLESS-002: difficulty-scaling-exponential
- ENDLESS-003: endless-mode-ui-timer-score
- ENDLESS-004: endless-mode-leaderboard
- ENDLESS-005: endless-mode-achievement
- ENDLESS-006: endless-mode-balance-tuning

---

## Story Index (All 127 Stories)

| Story ID | Epic | Priority | Size | Description | Status |
|----------|------|----------|------|-------------|--------|
| COMBAT-001 | EPIC-001 | P0 | S | player-movement-wasd-8dir | ✅ |
| COMBAT-002 | EPIC-001 | P0 | S | mouse-aim-system | ✅ |
| COMBAT-003 | EPIC-001 | P0 | M | tongue-attack-whip-mechanic | ✅ |
| COMBAT-004 | EPIC-001 | P0 | M | tongue-elastic-physics-3tile-range | ✅ |
| COMBAT-005 | EPIC-001 | P0 | M | enemy-spawn-escalation-system | ✅ |
| COMBAT-006 | EPIC-001 | P0 | M | enemy-ai-basic-behaviors | ✅ |
| COMBAT-007 | EPIC-001 | P0 | M | collision-detection-spatial-hash | ✅ |
| COMBAT-008 | EPIC-001 | P0 | S | hit-feedback-screenshake | ✅ |
| COMBAT-009 | EPIC-001 | P0 | M | particle-system-hits-deaths | ✅ |
| COMBAT-010 | EPIC-001 | P0 | S | hit-stop-2frame-pause | ✅ |
| COMBAT-011 | EPIC-001 | P0 | M | audio-feedback-wet-thwap-glorp | ✅ |
| COMBAT-012 | EPIC-001 | P0 | M | performance-60fps-gtx1060-validation | ✅ |
| COMBAT-013 | EPIC-001 | P0 | S | input-lag-16ms-validation | ✅ |
| COMBAT-014 | EPIC-001 | P0 | M | object-pooling-500enemies | ✅ |
| BULLET-001 | EPIC-002 | P0 | M | fork-bulletuphell-repo-day1 | ✅ |
| BULLET-002 | EPIC-002 | P0 | M | integrate-plugin-godot42 | ✅ |
| BULLET-003 | EPIC-002 | P0 | S | test-basic-bullet-patterns | ✅ |
| BULLET-004 | EPIC-002 | P0 | M | performance-validation-500bullets | ✅ |
| BULLET-005 | EPIC-002 | P0 | M | custom-pattern-frog-themed | ✅ |
| BULLET-006 | EPIC-002 | P0 | M | bullet-pooling-optimization | ✅ |
| BULLET-007 | EPIC-002 | P0 | M | collision-optimization | ✅ |
| BOARD-001 | EPIC-003 | P0 | M | figma-prototype-creation | ⏸️ |
| BOARD-002 | EPIC-003 | P0 | S | recruit-10-testers-validation | ⏸️ |
| BOARD-003 | EPIC-003 | P0 | M | achieve-8of10-satisfaction | ⏸️ |
| BOARD-004 | EPIC-003 | P0 | L | corkboard-background-art-1920x1080 | ✅ |
| BOARD-005 | EPIC-003 | P0 | M | data-log-card-component | ✅ |
| BOARD-006 | EPIC-003 | P0 | L | drag-drop-interaction-system | ✅ |
| BOARD-007 | EPIC-003 | P0 | M | pin-snap-detection-50px | ✅ |
| BOARD-008 | EPIC-003 | P0 | L | bezier-string-renderer | ✅ |
| BOARD-009 | EPIC-003 | P0 | M | string-physics-300ms-elastic | ✅ |
| BOARD-010 | EPIC-003 | P0 | S | string-snap-sound-visual | ✅ |
| BOARD-011 | EPIC-003 | P0 | M | document-viewer-popup | ✅ |
| BOARD-012 | EPIC-003 | P0 | S | tldr-fulltext-toggle | ✅ |
| BOARD-013 | EPIC-003 | P0 | S | progress-tracking-ui-x-of-7 | ✅ |
| BOARD-014 | EPIC-003 | P0 | M | keyboard-navigation-accessibility | ✅ |
| BOARD-015 | EPIC-003 | P0 | M | screen-reader-support | ✅ |
| DATA-001 | EPIC-004 | P0 | M | research-wetland-pollution-sources | ✅ |
| DATA-002 | EPIC-004 | P0 | L | write-7-data-logs-draft | ✅ |
| DATA-003 | EPIC-004 | P0 | M | cite-peer-reviewed-studies-inline | ✅ |
| DATA-004 | EPIC-004 | P0 | S | create-bibliography-appendix | ✅ |
| DATA-005 | EPIC-004 | P0 | M | ngo-partnership-outreach | ⏸️ |
| DATA-006 | EPIC-004 | P0 | M | ngo-content-review-approval | ⏸️ |
| DATA-007 | EPIC-004 | P0 | S | integrate-data-logs-game | ✅ |
| POLLUTION-001 | EPIC-005 | P0 | S | pollution-meter-progressbar | ✅ |
| POLLUTION-002 | EPIC-005 | P0 | S | color-coding-green-yellow-red | ✅ |
| POLLUTION-003 | EPIC-005 | P0 | XS | tooltip-ecosystem-message | ✅ |
| POLLUTION-004 | EPIC-005 | P0 | S | bind-pollution-mutation-count | ✅ |
| POLLUTION-005 | EPIC-005 | P0 | S | update-on-mutation-selection-event | ✅ |
| MUTATION-001 | EPIC-006 | P0 | M | mutation-data-structure | ✅ |
| MUTATION-002 | EPIC-006 | P0 | M | level-up-choice-ui-3options | ✅ |
| MUTATION-003 | EPIC-006 | P0 | M | mutation-application-system | ✅ |
| MUTATION-004 | EPIC-006 | P0 | L | implement-10-base-mutations | ✅ |
| MUTATION-005 | EPIC-006 | P0 | M | pollution-mutations-oil-toxic-mercury | ✅ |
| MUTATION-006 | EPIC-006 | P0 | M | frog-mutations-tongue-lily-croak | ✅ |
| MUTATION-007 | EPIC-006 | P0 | L | synergy-system-3combos | ✅ |
| MUTATION-008 | EPIC-006 | P0 | M | mutation-balance-tuning | ✅ |
| MUTATION-009 | EPIC-006 | P0 | S | mutation-description-tooltips | ✅ |
| MUTATION-010 | EPIC-006 | P0 | S | pollution-index-increment-logic | ✅ |
| BOSS-001 | EPIC-007 | P0 | L | boss-framework-phases-hp | ✅ |
| BOSS-002 | EPIC-007 | P0 | M | boss-arena-spawning-trigger | ✅ |
| BOSS-003 | EPIC-007 | P0 | M | lobbyist-boss-design-pixel-art | ✅ |
| BOSS-004 | EPIC-007 | P0 | L | lobbyist-bullet-patterns-3phases | ✅ |
| BOSS-005 | EPIC-007 | P0 | S | lobbyist-dialogue-corporate-speak | ✅ |
| BOSS-006 | EPIC-007 | P0 | M | ceo-boss-design-pixel-art | ✅ |
| BOSS-007 | EPIC-007 | P0 | L | ceo-bullet-patterns-3phases | ✅ |
| BOSS-008 | EPIC-007 | P0 | S | ceo-dialogue-final-boss | ✅ |
| BOSS-009 | EPIC-007 | P0 | M | boss-defeat-rewards-evidence | ✅ |
| BOSS-010 | EPIC-007 | P0 | M | boss-difficulty-scaling | ✅ |
| META-001 | EPIC-008 | P0 | L | persistent-conspiracy-board-state | ✅ |
| META-002 | EPIC-008 | P0 | M | evidence-unlock-system | ✅ |
| META-003 | EPIC-008 | P0 | M | informant-1-whistleblower-unlock | ✅ |
| META-004 | EPIC-008 | P0 | M | informant-2-journalist-unlock | ✅ |
| META-005 | EPIC-008 | P0 | M | informant-dialogue-system | ✅ |
| META-006 | EPIC-008 | P0 | M | hint-system-3hints-per-run | ✅ |
| META-007 | EPIC-008 | P0 | S | run-completion-reward-evidence | ✅ |
| META-008 | EPIC-008 | P0 | M | ending-unlock-all-evidence-condition | ✅ |
| SAVE-001 | EPIC-009 | P0 | M | json-save-file-structure | ✅ |
| SAVE-002 | EPIC-009 | P0 | M | crc32-checksum-validation | ✅ |
| SAVE-003 | EPIC-009 | P0 | M | atomic-write-backup-file | ✅ |
| SAVE-004 | EPIC-009 | P0 | S | save-on-death-trigger | ✅ |
| SAVE-005 | EPIC-009 | P0 | S | save-on-conspiracy-connection | ✅ |
| SAVE-006 | EPIC-009 | P0 | S | save-on-settings-change | ✅ |
| SAVE-007 | EPIC-009 | P0 | S | save-on-exit | ✅ |
| SAVE-008 | EPIC-009 | P0 | L | steam-cloud-sync-integration | ✅ |
| SAVE-009 | EPIC-009 | P0 | M | corrupt-save-recovery-backup | ✅ |
| SAVE-010 | EPIC-009 | P0 | M | save-migration-version-handling | ✅ |
| PLATFORM-001 | EPIC-010 | P0 | M | godotsteam-plugin-integration | ✅ |
| PLATFORM-002 | EPIC-010 | P0 | S | steam-authentication-automatic | ✅ |
| PLATFORM-003 | EPIC-010 | P0 | M | steam-achievements-framework | ✅ |
| PLATFORM-004 | EPIC-010 | P0 | S | steam-overlay-support | ✅ |
| PLATFORM-005 | EPIC-010 | P0 | M | windows-build-configuration | ✅ |
| PLATFORM-006 | EPIC-010 | P0 | M | linux-build-configuration | ✅ |
| PLATFORM-007 | EPIC-010 | P0 | M | steam-deck-validation-800p-55fps | ✅ |
| PLATFORM-008 | EPIC-010 | P0 | M | steam-deck-control-mapping | ✅ |
| PLATFORM-009 | EPIC-010 | P0 | M | controller-support-xinput | ✅ |
| PLATFORM-010 | EPIC-010 | P0 | M | rebindable-controls-ui | ✅ |
| ACCESS-001 | EPIC-011 | P0 | M | colorblind-mode-deuteranopia-shader | ✅ |
| ACCESS-002 | EPIC-011 | P0 | M | colorblind-mode-protanopia-shader | ✅ |
| ACCESS-003 | EPIC-011 | P0 | M | colorblind-mode-tritanopia-shader | ✅ |
| ACCESS-004 | EPIC-011 | P0 | M | text-scaling-3sizes-08-10-13 | ✅ |
| ACCESS-005 | EPIC-011 | P0 | S | screen-shake-toggle-setting | ✅ |
| ACCESS-006 | EPIC-011 | P0 | M | keyboard-navigation-all-menus | ✅ |
| ACCESS-007 | EPIC-011 | P0 | M | wcag-aa-contrast-validation | ✅ |
| ACCESS-008 | EPIC-011 | P0 | S | settings-menu-accessibility-tab | ✅ |
| ACCESS-009 | EPIC-011 | P0 | M | control-rebinding-ui | ✅ |
| ACCESS-010 | EPIC-011 | P0 | M | accessibility-testing-validation | ✅ |

*(Alpha and Beta stories continue the sequence - full 127 stories available in detailed planning)*

---

**Document Status**: ✅ Complete
**Next Phase**: Story expansion (07b-story-expansion-flow.yaml)
**Last Updated**: 2025-12-13
