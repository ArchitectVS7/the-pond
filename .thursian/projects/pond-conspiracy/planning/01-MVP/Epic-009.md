# EPIC-009: Save System & Steam Cloud - Development Plan

## Overview

**Epic**: EPIC-009 (Save System & Steam Cloud)
**Release Phase**: MVP
**Priority**: P0 (Critical for meta-progression)
**Dependencies**: EPIC-008 (Meta-Progression System)
**Estimated Effort**: M (1 week)
**PRD Requirements**: FR-006, ADR-004

**Description**: JSON save files, CRC32 checksums, Steam Cloud sync, auto-save.

---

## Automated Workflow Protocol

### Before Each Story
1. **READ THIS PLAN** for re-alignment before starting
2. Verify dependencies from previous stories are complete
3. Check DEVELOPERS_MANUAL.md for any tunable parameters from prior work

### Story Completion Criteria
- All tests pass (adversarial workflow complete)
- Tunable parameters documented in DEVELOPERS_MANUAL.md
- No human sign-off required - proceed immediately to next story

### Blocker Handling
- If a story cannot be completed due to blockers or human-required actions:
  - **SKIP** the blocked steps
  - **NOTE** in DEVELOPERS_MANUAL.md under "Blocked Steps" section
  - **PROCEED** to next story

---

## Stories

### SAVE-001: json-save-file-structure
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] JSON schema defined for save file
- [ ] All persistent data included
- [ ] Versioned for migration support

**Save File Structure**:
```json
{
  "version": "1.0.0",
  "created": 1702483200,
  "modified": 1702486800,
  "meta_progression": {
    "discovered_logs": [1, 2, 3],
    "card_positions": {"1": [100, 200]},
    "connections": [[1, 2], [2, 3]],
    "evidence_collected": [1],
    "bosses_defeated": {"lobbyist": true, "ceo": false},
    "informants_unlocked": ["whistleblower"]
  },
  "settings": {
    "music_volume": 0.8,
    "sfx_volume": 1.0,
    "screen_shake": true
  },
  "statistics": {
    "total_runs": 15,
    "total_deaths": 12,
    "enemies_killed": 4523
  },
  "checksum": "a1b2c3d4"
}
```

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `save_version` | String | "1.0.0" | Current save format version |
| `save_file_name` | String | "save.json" | Save file name |

---

### SAVE-002: crc32-checksum-validation
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] CRC32 checksum calculated on save
- [ ] Checksum validated on load
- [ ] Invalid checksum triggers recovery

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `checksum_enabled` | bool | true | Enable checksum validation |
| `allow_dev_bypass` | bool | false | Skip checksum in debug |

---

### SAVE-003: atomic-write-backup-file
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Write to temp file first
- [ ] Rename to actual save (atomic)
- [ ] Keep backup of previous save

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `backup_count` | int | 1 | Number of backups to keep |
| `temp_suffix` | String | ".tmp" | Temp file extension |
| `backup_suffix` | String | ".bak" | Backup file extension |

---

### SAVE-004: save-on-death-trigger
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Save triggers when player dies
- [ ] Run statistics updated before save
- [ ] Death count incremented

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `death_save_delay` | float | 0.5 | Delay before save after death |

---

### SAVE-005: save-on-conspiracy-connection
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Save triggers when string connected
- [ ] Debounced for rapid changes

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `connection_save_debounce` | float | 2.0 | Debounce delay in seconds |

---

### SAVE-006: save-on-settings-change
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Save triggers when settings changed
- [ ] Settings apply on game start

---

### SAVE-007: save-on-exit
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Save triggers on game exit
- [ ] Graceful shutdown

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `exit_save_timeout` | float | 5.0 | Max wait for save on exit |

---

### SAVE-008: steam-cloud-sync-integration
**Size**: L | **Priority**: P0

**Acceptance Criteria**:
- [ ] Save files sync to Steam Cloud
- [ ] Cloud takes priority on conflict
- [ ] Works offline (local fallback)

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `cloud_sync_enabled` | bool | true | Enable Steam Cloud |
| `cloud_priority` | String | "cloud" | Conflict priority |
| `cloud_retry_count` | int | 3 | Retries on sync failure |

**Potential Blockers**:
- [ ] GodotSteam not integrated → SKIP, note in DEVELOPERS_MANUAL.md

---

### SAVE-009: corrupt-save-recovery-backup
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Detect corrupt save files
- [ ] Attempt backup recovery
- [ ] Fallback to new game if both fail

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `show_recovery_dialog` | bool | true | Show recovery notification |
| `auto_recover` | bool | true | Automatic recovery attempt |

---

### SAVE-010: save-migration-version-handling
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Detect save file version
- [ ] Migrate old formats to current
- [ ] Add missing fields with defaults

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `migration_backup` | bool | true | Backup before migration |
| `oldest_supported` | String | "1.0.0" | Oldest migratable version |

---

## Files to Create

| File | Purpose |
|------|---------|
| `core/scripts/save_manager.gd` | Save/load orchestration |
| `core/scripts/save_data.gd` | Save data structure |
| `core/scripts/checksum.gd` | CRC32 implementation |
| `core/scripts/save_migration.gd` | Version migration |
| `core/scripts/steam_cloud.gd` | Steam Cloud wrapper |
| `test/unit/test_save_system.gd` | Tests |

---

## Success Metrics

- 10 stories completed
- Save system fully functional
- Steam Cloud integrated (or blocked with docs)
- Data persists across sessions

---
---

## Epic Completion Protocol

### On Epic Completion
1. Update `.thursian/projects/pond-conspiracy/planning/epics-and-stories.md`:
   - Mark Epic header with ✅ COMPLETE
   - Add **Status**: ✅ **COMPLETE** (date) line
   - Mark all stories with ✅ prefix
   - Update Story Index table with ✅ status
   - Update Progress Summary counts
2. Commit changes with message: "Complete EPIC-XXX: [Epic Name]"
3. Proceed to next Epic in dependency order

---


**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
