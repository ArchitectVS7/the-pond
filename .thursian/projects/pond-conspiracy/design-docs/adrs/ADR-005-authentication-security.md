# ADR-005: Authentication & Security Architecture

**Status**: Accepted
**Date**: 2025-12-13
**Decision Makers**: Chief Architect, Security Architect, Backend Architect
**Related ADRs**: ADR-001 (Platform), ADR-004 (Data Architecture)

---

## Context

Pond Conspiracy is a single-player PC game with minimal security requirements. However, we need to address:

1. **User authentication** (Steam-based, automatic)
2. **Save file integrity** (prevent corruption)
3. **Achievement validation** (prevent cheating)
4. **No sensitive data** (no PII, no payment info)

### Threat Model

**Low-Risk** (single-player game, no PvP, no economy):
- ✅ **Save file tampering**: Acceptable (players can edit saves, it's their game)
- ✅ **Achievement cheating**: Low impact (no competitive element)
- ❌ **Code injection**: Mitigated by Godot engine sandboxing
- ❌ **Network attacks**: N/A (no multiplayer or servers)
- ❌ **Data breaches**: N/A (no user accounts, no passwords)

---

## Decision

### Authentication: **Steam-Based (Automatic)**

**Strategy**: Leverage Steam's authentication system

**Implementation**:
```gdscript
# On game launch, Steam client handles auth
func _ready():
    if not Steam.isSteamRunning():
        push_warning("Steam not running, offline mode")
        return

    var steam_id = Steam.getSteamID()
    var username = Steam.getPersonaName()

    print("Logged in as: ", username, " (", steam_id, ")")
    # No password, no login screen, Steam handles everything
```

**Benefits**:
- ✅ Zero authentication code to write
- ✅ Seamless UX (auto-login via Steam)
- ✅ No password management
- ✅ Steam handles security (2FA, etc.)

**No Additional Auth**:
- ❌ No email/password login
- ❌ No social logins (Google, Facebook)
- ❌ No custom accounts

---

### Save File Integrity: **CRC32 Checksums**

**Goal**: Detect accidental corruption (not prevent intentional tampering)

**Implementation**:
```gdscript
func save_game_with_checksum():
    var save_data = MetaProgression.to_dict()
    var json_string = JSON.print(save_data)

    # Calculate CRC32 checksum
    var checksum = json_string.hash()

    var file_data = {
        "version": "1.0.0",
        "checksum": checksum,
        "data": save_data
    }

    write_to_file("save_game.json", JSON.print(file_data))

func load_game_with_validation():
    var file_data = read_from_file("save_game.json")
    var parsed = JSON.parse(file_data).result

    var expected_checksum = JSON.print(parsed["data"]).hash()
    var actual_checksum = parsed["checksum"]

    if expected_checksum != actual_checksum:
        push_warning("Save file corrupted, loading backup")
        return load_backup()

    return parsed["data"]
```

**Rationale**:
- Detects accidental corruption (disk errors, incomplete writes)
- Does NOT prevent intentional editing (players can recalculate checksum)
- **This is acceptable**: Single-player game, player can cheat themselves

---

### Achievement Validation: **Steam-Side (Valve Servers)**

**Strategy**: Rely on Steam's server-side validation

**No Client-Side Validation**:
- Game calls `Steam.setAchievement("boss_defeated_lobbyist")`
- Steam client validates with Valve servers
- If player uses SAM (Steam Achievement Manager) to cheat → their choice, no impact on others

**Rate Limiting**:
```gdscript
func unlock_achievement(id: String):
    # Prevent spam (max 1 unlock per second per achievement)
    if achievement_cooldowns.has(id):
        var elapsed = OS.get_ticks_msec() - achievement_cooldowns[id]
        if elapsed < 1000:
            push_warning("Achievement unlock rate limited: ", id)
            return

    Steam.setAchievement(id)
    achievement_cooldowns[id] = OS.get_ticks_msec()
```

---

### Data Security

**No Encryption**:
- Save files are plain JSON (not encrypted)
- **Rationale**: No sensitive data to protect (no passwords, no credit cards, no PII)
- Player can read and edit their own saves (this is a feature, not a bug)

**No HTTPS**:
- No network communication (except Steam API, which uses Steam's encryption)

**No DRM**:
- Game trusts the player
- Steam handles copy protection (if enabled by publisher)
- We will NOT use additional DRM (Denuvo, etc.) - player-hostile and unnecessary

---

### Input Validation

**User Input Sources**:
1. Keyboard/mouse/controller (trusted, OS-level sandboxing)
2. Save files (validated with checksums)
3. Settings files (validated schema)

**No Untrusted Input**:
- No web forms
- No user-generated content (mods deferred to Year 2)
- No chat or text input

**File Path Validation** (settings/save files):
```gdscript
func validate_save_path(path: String) -> bool:
    # Only allow user:// paths (sandboxed directory)
    if not path.begins_with("user://"):
        push_error("Invalid save path: ", path)
        return false

    # No directory traversal
    if "../" in path or "..\\" in path:
        push_error("Path traversal detected: ", path)
        return false

    return true
```

---

### Compliance

**GDPR**: Not applicable
- No personal data collected (Steam handles user data)
- No analytics or tracking (Steam stats only)
- No cookies (desktop app, not web)

**COPPA**: Not applicable
- No user registration
- No collection of data from children
- Age gating handled by Steam (17+ rating assumed)

**CCPA**: Not applicable
- No sale of personal data
- No data collection

---

## Consequences

### Positive

✅ **Zero auth code**: Steam handles everything
✅ **Simple security model**: No passwords, no encryption complexity
✅ **Player-friendly**: No invasive DRM
✅ **Low maintenance**: No security patches needed
✅ **Trust-based**: Assume player is not malicious (correct for single-player)

### Negative

❌ **Save editing possible**: Players can cheat (acceptable tradeoff)
❌ **Achievement cheating possible**: SAM exists (acceptable, no competitive element)
❌ **No anti-cheat**: Intentional decision (not needed for single-player)

### Neutral

🔷 **Steam dependency**: Acceptable (primary distribution platform)
🔷 **No encryption**: Appropriate (no sensitive data)

---

## Alternatives Considered

### Alternative 1: Custom Account System

**Rejected**: Adds weeks of dev time, no benefit for single-player game

### Alternative 2: Encrypt Save Files

**Rejected**: Obfuscates debugging, provides false sense of security (players can decrypt). No sensitive data to protect.

### Alternative 3: Server-Side Validation

**Rejected**: Requires servers, adds latency, unnecessary for local game

---

## Related Decisions

- **ADR-001**: Platform (Steam-exclusive)
- **ADR-003**: Communication Patterns (Steam API)
- **ADR-004**: Data Architecture (JSON saves)

---

## Security Best Practices (Minimal for Single-Player)

**DO**:
- ✅ Validate save file checksums
- ✅ Use Godot's sandboxed `user://` paths
- ✅ Prevent directory traversal in file paths
- ✅ Trust Steam's authentication

**DON'T**:
- ❌ Roll custom crypto (use CRC32 for corruption detection only)
- ❌ Implement anti-cheat (not needed)
- ❌ Add DRM beyond Steam's built-in
- ❌ Collect telemetry without consent

---

**Approved By**: ✅ Chief Architect, Security Architect, Backend Architect

**Next ADR**: ADR-006 - Technology Stack Selection
