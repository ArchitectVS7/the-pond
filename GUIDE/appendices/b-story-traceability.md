# Appendix B: Story Traceability Matrix

Every story ID mapped to its implementing files.

---

## Overview

| Phase | Epics | Stories | Status |
|-------|-------|---------|--------|
| MVP | 11 | 78 | Complete |
| Alpha | 5 | 27 | Not Started |
| Beta | 4 | 22 | Not Started |
| **Total** | **20** | **127** | **61% Complete** |

---

## EPIC-001: Combat System

| Story | File(s) | Description |
|-------|---------|-------------|
| COMBAT-001 | `combat/scripts/player_controller.gd` | 8-directional WASD movement |
| COMBAT-002 | `combat/scripts/player_controller.gd` | Mouse aim system |
| COMBAT-003 | `combat/scripts/tongue_attack.gd` | Tongue whip mechanic |
| COMBAT-004 | `combat/scripts/tongue_attack.gd` | Elastic physics (3-tile range) |
| COMBAT-005 | `combat/scripts/enemy_spawner.gd` | Spawn escalation system |
| COMBAT-006 | `combat/scripts/enemy_base.gd` | Enemy AI behaviors |
| COMBAT-007 | `combat/scripts/spatial_hash.gd` | Spatial hash collision |
| COMBAT-008 | `shared/scripts/screen_shake.gd` | Hit feedback screen shake |
| COMBAT-009 | `shared/scripts/particle_manager.gd` | Particle system |
| COMBAT-010 | `shared/scripts/hit_stop.gd` | 2-frame hit pause |
| COMBAT-011 | `shared/scripts/audio_manager.gd` | Audio feedback (thwap, glorp) |
| COMBAT-012 | `shared/scripts/performance_monitor.gd` | 60fps GTX1060 validation |
| COMBAT-013 | `shared/scripts/input_latency_monitor.gd` | <16ms input lag validation |
| COMBAT-014 | `shared/scripts/object_pool.gd` | Object pooling (500 enemies) |

**Tests**: `test/unit/test_player_movement.gd`, `test_tongue_attack.gd`, `test_enemy_ai.gd`, `test_spatial_hash.gd`, etc.

---

## EPIC-002: BulletUpHell

| Story | File(s) | Description |
|-------|---------|-------------|
| BULLET-001 | `addons/BulletUpHell/` | Fork BulletUpHell repo |
| BULLET-002 | `addons/BulletUpHell/*.gd` | Godot 4.2 integration |
| BULLET-003 | `combat/scenes/bullet_pattern_test.gd` | Basic pattern testing |
| BULLET-004 | `test/unit/test_bullet_performance.gd` | 500 bullet validation |
| BULLET-005 | `combat/scripts/bullet_pattern_test.gd` | Frog-themed patterns |
| BULLET-006 | `combat/scripts/bullet_pool_manager.gd` | Bullet pooling |
| BULLET-007 | `combat/scripts/bullet_collision_config.gd` | Collision optimization |

**Tests**: `test/unit/test_bullet_patterns.gd`, `test_bullet_pooling.gd`, `tests/integration/test_bullet_collision_performance.gd`

---

## EPIC-003: Conspiracy Board

| Story | File(s) | Description |
|-------|---------|-------------|
| BOARD-001 | *BLOCKED (human)* | Figma prototype |
| BOARD-002 | *BLOCKED (human)* | Recruit testers |
| BOARD-003 | *BLOCKED (human)* | 8/10 satisfaction |
| BOARD-004 | `conspiracy_board/scenes/ConspiracyBoard.tscn` | Corkboard background |
| BOARD-005 | `conspiracy_board/scripts/data_log_card.gd` | Data log card component |
| BOARD-006 | `conspiracy_board/scripts/data_log_card.gd` | Drag-drop interaction |
| BOARD-007 | `conspiracy_board/scripts/conspiracy_board.gd` | Pin snap detection |
| BOARD-008 | `conspiracy_board/scripts/string_renderer.gd` | Bezier string renderer |
| BOARD-009 | `conspiracy_board/scripts/string_renderer.gd` | String physics (300ms) |
| BOARD-010 | `conspiracy_board/scripts/conspiracy_board.gd` | Snap sound/visual |
| BOARD-011 | `conspiracy_board/scripts/document_viewer.gd` | Document viewer popup |
| BOARD-012 | `conspiracy_board/scripts/document_viewer.gd` | TL;DR/full-text toggle |
| BOARD-013 | `conspiracy_board/scripts/conspiracy_board.gd` | Progress tracking UI |
| BOARD-014 | `conspiracy_board/scripts/conspiracy_board.gd` | Keyboard navigation |
| BOARD-015 | `conspiracy_board/scripts/conspiracy_board.gd` | Screen reader support |

**Tests**: `tests/conspiracy_board/test_conspiracy_board.gd`, `test_string_renderer.gd`, `test_string_physics.gd`

---

## EPIC-004: Environmental Data

| Story | File(s) | Description |
|-------|---------|-------------|
| DATA-001 | `conspiracy_board/content/research/` | Research documentation |
| DATA-002 | `conspiracy_board/content/data_logs/*.md` | 7 data log drafts |
| DATA-003 | `conspiracy_board/content/data_logs/*.md` | Peer-reviewed citations |
| DATA-004 | `conspiracy_board/content/bibliography.md` | Bibliography appendix |
| DATA-005 | *BLOCKED (human)* | NGO partnership outreach |
| DATA-006 | *BLOCKED (human)* | NGO content review |
| DATA-007 | `conspiracy_board/resources/DataLogResource.gd` | Data log integration |

**Content Files**: `01_corporate_memo.md`, `02_regulatory_filing.md`, etc.

---

## EPIC-005: Pollution Index

| Story | File(s) | Description |
|-------|---------|-------------|
| POLLUTION-001 | `metagame/scripts/pollution_meter.gd` | Pollution meter UI |
| POLLUTION-002 | `metagame/scripts/pollution_meter.gd` | Color coding (G/Y/R) |
| POLLUTION-003 | `metagame/scripts/pollution_meter.gd` | Ecosystem tooltip |
| POLLUTION-004 | `metagame/scripts/pollution_meter.gd` | Mutation count binding |
| POLLUTION-005 | `metagame/scripts/pollution_meter.gd` | Update on selection |

**Tests**: `test/unit/test_pollution_meter.gd`

---

## EPIC-006: Mutation System

| Story | File(s) | Description |
|-------|---------|-------------|
| MUTATION-001 | `metagame/resources/MutationResource.gd` | Mutation data structure |
| MUTATION-002 | `metagame/scripts/level_up_ui.gd` | Level-up choice UI |
| MUTATION-003 | `metagame/scripts/mutation_manager.gd` | Mutation application |
| MUTATION-004 | `metagame/scripts/abilities/*.gd` | 10 base mutations |
| MUTATION-005 | `metagame/scripts/abilities/oil_trail_ability.gd`, etc. | Pollution mutations |
| MUTATION-006 | `metagame/scripts/abilities/lily_pad_ability.gd`, etc. | Frog mutations |
| MUTATION-007 | `metagame/scripts/synergy_checker.gd`, `SynergyResource.gd` | Synergy system |
| MUTATION-008 | Various | Balance tuning |
| MUTATION-009 | `metagame/scripts/mutation_card.gd` | Description tooltips |
| MUTATION-010 | `metagame/scripts/pollution_meter.gd` | Pollution increment |

**Tests**: `test/unit/test_mutations.gd`

---

## EPIC-007: Boss Encounters

| Story | File(s) | Description |
|-------|---------|-------------|
| BOSS-001 | `combat/scripts/boss_base.gd` | Boss framework |
| BOSS-002 | `combat/scripts/boss_arena.gd` | Arena spawning |
| BOSS-003 | `combat/scripts/boss_lobbyist.gd` | Lobbyist design |
| BOSS-004 | `combat/scripts/boss_lobbyist.gd` | Lobbyist patterns |
| BOSS-005 | `combat/scripts/boss_dialogue.gd` | Lobbyist dialogue |
| BOSS-006 | `combat/scripts/boss_ceo.gd` | CEO design |
| BOSS-007 | `combat/scripts/boss_ceo.gd` | CEO patterns |
| BOSS-008 | `combat/scripts/boss_dialogue.gd` | CEO dialogue |
| BOSS-009 | `combat/scripts/boss_base.gd` | Defeat rewards |
| BOSS-010 | `combat/scripts/boss_base.gd` | Difficulty scaling |

---

## EPIC-008: Meta-Progression

| Story | File(s) | Description |
|-------|---------|-------------|
| META-001 | `metagame/scripts/progress_manager.gd` | Persistent board state |
| META-002 | `metagame/scripts/evidence_manager.gd` | Evidence unlock system |
| META-003 | `metagame/scripts/informant_manager.gd` | Informant 1 (Deep Croak) |
| META-004 | `metagame/scripts/informant_manager.gd` | Informant 2 (Lily Padsworth) |
| META-005 | `metagame/scripts/dialogue_system.gd` | Informant dialogue |
| META-006 | `metagame/scripts/hint_system.gd` | Hint system (3/run) |
| META-007 | `metagame/scripts/run_manager.gd` | Run completion rewards |
| META-008 | `metagame/scripts/ending_manager.gd` | Ending unlock condition |

---

## EPIC-009: Save System

| Story | File(s) | Description |
|-------|---------|-------------|
| SAVE-001 | `core/scripts/save_manager.gd` | JSON save structure |
| SAVE-002 | `core/scripts/save_manager.gd` | SHA256 checksum |
| SAVE-003 | `core/scripts/save_manager.gd` | Atomic write with backup |
| SAVE-004 | `core/scripts/save_manager.gd` | Save on death |
| SAVE-005 | `core/scripts/save_manager.gd` | Save on connection |
| SAVE-006 | `core/scripts/save_manager.gd` | Save on settings |
| SAVE-007 | `core/scripts/save_manager.gd` | Save on exit |
| SAVE-008 | `core/scripts/steam_manager.gd` | Steam Cloud sync |
| SAVE-009 | `core/scripts/save_manager.gd` | Corruption recovery |
| SAVE-010 | `core/scripts/save_manager.gd` | Version migration |

---

## EPIC-010: Platform Support

| Story | File(s) | Description |
|-------|---------|-------------|
| PLATFORM-001 | `core/scripts/steam_manager.gd` | GodotSteam plugin |
| PLATFORM-002 | `core/scripts/steam_manager.gd` | Steam authentication |
| PLATFORM-003 | `core/scripts/achievement_manager.gd` | Achievement framework |
| PLATFORM-004 | `core/scripts/steam_manager.gd` | Steam overlay |
| PLATFORM-005 | `export_presets.cfg` | Windows build |
| PLATFORM-006 | `export_presets.cfg` | Linux build |
| PLATFORM-007 | `core/scripts/steam_deck_detector.gd` | Steam Deck validation |
| PLATFORM-008 | `core/scripts/input_manager.gd` | Steam Deck controls |
| PLATFORM-009 | `core/scripts/input_manager.gd` | Controller support |
| PLATFORM-010 | `ui/scripts/control_rebind.gd` | Rebindable controls |

---

## EPIC-011: Accessibility

| Story | File(s) | Description |
|-------|---------|-------------|
| ACCESS-001 | `shared/shaders/colorblind_deuteranopia.gdshader` | Deuteranopia mode |
| ACCESS-002 | `shared/shaders/colorblind_protanopia.gdshader` | Protanopia mode |
| ACCESS-003 | `shared/shaders/colorblind_tritanopia.gdshader` | Tritanopia mode |
| ACCESS-004 | `shared/scripts/accessibility_manager.gd` | Text scaling |
| ACCESS-005 | `shared/scripts/accessibility_manager.gd` | Screen shake toggle |
| ACCESS-006 | `shared/scripts/accessibility_manager.gd` | Keyboard navigation |
| ACCESS-007 | `shared/scripts/accessibility_manager.gd` | WCAG AA contrast |
| ACCESS-008 | `ui/scenes/SettingsMenu.tscn` | Accessibility tab |
| ACCESS-009 | `ui/scripts/control_rebind.gd` | Control rebinding |
| ACCESS-010 | `tests/accessibility/` | Accessibility tests |

---

## Alpha Stories (Not Started)

### EPIC-012: Third Boss

| Story | Target File(s) | Description |
|-------|----------------|-------------|
| BOSS3-001 | `combat/scripts/boss_researcher.gd` | Researcher design |
| BOSS3-002 | `combat/scripts/boss_researcher.gd` | Beaker/flask patterns |
| BOSS3-003 | `combat/scripts/boss_dialogue.gd` | Corporate science dialogue |
| BOSS3-004 | `combat/scripts/boss_researcher.gd` | 3-phase mechanics |
| BOSS3-005 | `combat/scripts/boss_researcher.gd` | Defeat reward |
| BOSS3-006 | `combat/tilesets/lab_arena.tres` | Lab arena tileset |

### EPIC-013: Second Ending

| Story | Target File(s) | Description |
|-------|----------------|-------------|
| ENDING2-001 | `metagame/scripts/ending_manager.gd` | Government evidence branch |
| ENDING2-002 | `metagame/scenes/Ending2Cutscene.tscn` | Cutscene art |
| ENDING2-003 | `metagame/content/endings/ending2_script.json` | Narrative writing |
| ENDING2-004 | `metagame/scripts/ending_manager.gd` | Unlock condition |
| ENDING2-005 | `core/scripts/achievement_manager.gd` | Achievement integration |

### EPIC-014: Additional Mutations

| Story | Target File(s) | Description |
|-------|----------------|-------------|
| MUTATION-011 | `docs/design/` | Design 5 new mutations |
| MUTATION-012 | `metagame/scripts/abilities/*.gd` | Implement new mutations |
| MUTATION-013 | Various | Balance new mutations |
| MUTATION-014 | `docs/design/` | Design 3 new synergies |
| MUTATION-015 | `metagame/scripts/synergy_checker.gd` | Implement synergies |
| MUTATION-016 | `metagame/content/` | Update descriptions |
| MUTATION-017 | `metagame/scripts/synergy_tooltip.gd` | Synergy tooltip UI |

### EPIC-015: Visual Mutations

| Story | Target File(s) | Description |
|-------|----------------|-------------|
| VISUAL-001 | `combat/scripts/sprite_variant_system.gd` | Sprite variant system |
| VISUAL-002 | `shared/particles/oil_trail.tscn` | Oil trail visual |
| VISUAL-003 | `shared/particles/toxic_aura.tscn` | Toxic aura visual |
| VISUAL-004 | `combat/scripts/sprite_layer_system.gd` | Mutation layering |
| VISUAL-005 | `assets/ui/mutations/` | Mutation icons |
| VISUAL-006 | `metagame/scripts/mutation_preview.gd` | Preview UI |

### EPIC-016: Dynamic Music

| Story | Target File(s) | Description |
|-------|----------------|-------------|
| MUSIC-001 | `shared/scripts/music_manager.gd` | Intensity calculation |
| MUSIC-002 | `shared/scripts/music_manager.gd` | Music layer system |
| MUSIC-003 | `shared/scripts/music_manager.gd` | Crossfade implementation |
| MUSIC-004 | `shared/scripts/music_manager.gd` | Boss music triggers |
| MUSIC-005 | `assets/audio/music/` | Victory/defeat stingers |
| MUSIC-006 | `shared/scripts/music_manager.gd` | Audio mixing balance |

---

## Beta Stories (Not Started)

### EPIC-017: Secret Boss

| Story | Target File(s) | Description |
|-------|----------------|-------------|
| SECRET-001 | `combat/scripts/boss_sentient_pond.gd` | Sentient Pond design |
| SECRET-002 | `metagame/scripts/secret_unlock.gd` | Easter egg unlock |
| SECRET-003 | `combat/scripts/boss_sentient_pond.gd` | Water-themed patterns |
| SECRET-004 | `combat/scripts/boss_sentient_pond.gd` | 4-phase mechanics |
| SECRET-005 | `combat/scripts/boss_dialogue.gd` | Eldritch horror dialogue |
| SECRET-006 | `metagame/scripts/ending_manager.gd` | True ending reward |
| SECRET-007 | `core/scripts/achievement_manager.gd` | Secret boss achievement |

### EPIC-018: Third Ending

| Story | Target File(s) | Description |
|-------|----------------|-------------|
| ENDING3-001 | `metagame/scripts/ending_manager.gd` | Nihilist evidence branch |
| ENDING3-002 | `metagame/scenes/Ending3Cutscene.tscn` | Cutscene art |
| ENDING3-003 | `metagame/content/endings/ending3_script.json` | Narrative writing |
| ENDING3-004 | `metagame/scripts/ending_manager.gd` | Unlock condition |
| ENDING3-005 | `core/scripts/achievement_manager.gd` | Achievement |

### EPIC-019: Daily Challenges

| Story | Target File(s) | Description |
|-------|----------------|-------------|
| DAILY-001 | `metagame/scripts/daily_challenge.gd` | Seeded run generation |
| DAILY-002 | `metagame/scripts/daily_challenge.gd` | Challenge framework |
| DAILY-003 | `core/scripts/steam_manager.gd` | Leaderboard integration |
| DAILY-004 | `metagame/scenes/DailyChallengeUI.tscn` | Challenge UI |
| DAILY-005 | `metagame/scenes/LeaderboardUI.tscn` | Leaderboard display |
| DAILY-006 | `metagame/scripts/daily_challenge.gd` | Challenge rewards |
| DAILY-007 | `metagame/scripts/daily_challenge.gd` | Expiration logic |

### EPIC-020: Endless Mode

| Story | Target File(s) | Description |
|-------|----------------|-------------|
| ENDLESS-001 | `combat/scripts/endless_spawner.gd` | Infinite spawning |
| ENDLESS-002 | `combat/scripts/endless_spawner.gd` | Difficulty scaling |
| ENDLESS-003 | `metagame/scenes/EndlessHUD.tscn` | Timer/score UI |
| ENDLESS-004 | `core/scripts/steam_manager.gd` | Endless leaderboard |
| ENDLESS-005 | `core/scripts/achievement_manager.gd` | Endless achievements |
| ENDLESS-006 | Various | Balance tuning |

---

## File Index

Quick lookup by file to see which stories it implements.

| File | Stories |
|------|---------|
| `player_controller.gd` | COMBAT-001, COMBAT-002 |
| `tongue_attack.gd` | COMBAT-003, COMBAT-004 |
| `enemy_spawner.gd` | COMBAT-005 |
| `enemy_base.gd` | COMBAT-006 |
| `spatial_hash.gd` | COMBAT-007 |
| `screen_shake.gd` | COMBAT-008 |
| `particle_manager.gd` | COMBAT-009 |
| `hit_stop.gd` | COMBAT-010 |
| `audio_manager.gd` | COMBAT-011 |
| `performance_monitor.gd` | COMBAT-012 |
| `input_latency_monitor.gd` | COMBAT-013 |
| `object_pool.gd` | COMBAT-014 |
| `conspiracy_board.gd` | BOARD-007, 010, 013-015 |
| `data_log_card.gd` | BOARD-005, BOARD-006 |
| `string_renderer.gd` | BOARD-008, BOARD-009 |
| `document_viewer.gd` | BOARD-011, BOARD-012 |
| `pollution_meter.gd` | POLLUTION-001 to 005, MUTATION-010 |
| `mutation_manager.gd` | MUTATION-003 |
| `level_up_ui.gd` | MUTATION-002 |
| `boss_base.gd` | BOSS-001, 009, 010 |
| `boss_lobbyist.gd` | BOSS-003, 004 |
| `boss_ceo.gd` | BOSS-006, 007 |
| `save_manager.gd` | SAVE-001 to 010 |
| `steam_manager.gd` | PLATFORM-001, 002, 004, SAVE-008 |
| `achievement_manager.gd` | PLATFORM-003 |
| `accessibility_manager.gd` | ACCESS-004 to 007 |

---

[Back to Index](../index.md)
