# Hardware Testing

Your game runs great on your machine. That means nothing. Hardware testing validates that The Pond works on the machines your players actually own.

This guide covers testing methodology for your three target platforms: GTX 1060-tier PCs, Steam Deck, and Linux.

---

## Target Specifications

### Minimum PC (GTX 1060 Tier)

This represents a 2016-era mid-range PC. Steam hardware surveys show this is still a huge chunk of the player base.

| Component | Spec |
|-----------|------|
| GPU | GTX 1060 6GB (or RX 580) |
| CPU | Intel i5-6500 or Ryzen 3 1200 |
| RAM | 8 GB |
| Resolution | 1920x1080 |
| Target FPS | 60 (minimum) |

**Why this spec**: If it runs on a GTX 1060, it runs on ~70% of gaming PCs. If it doesn't, you're leaving players behind.

### Steam Deck

Valve's handheld is a significant market. Verified status boosts visibility.

| Component | Spec |
|-----------|------|
| GPU | AMD RDNA 2 (roughly GTX 1050 equivalent) |
| CPU | AMD Zen 2, 4 cores |
| RAM | 16 GB (shared) |
| Resolution | 1280x800 |
| Target FPS | 55+ (Deck runs 40Hz mode for battery) |
| Battery | 2+ hours target |

### Linux

SteamOS is Linux. If you're on Steam Deck, you're on Linux. But desktop Linux has its own considerations.

| Distro | Priority |
|--------|----------|
| SteamOS 3.0 | High (Steam Deck) |
| Ubuntu 22.04 LTS | High (most common desktop) |
| Fedora 38+ | Medium |
| Arch Linux | Medium (enthusiast crowd) |

---

## Performance Metrics

### What to Measure

| Metric | Tool | Target |
|--------|------|--------|
| FPS (average) | Godot profiler, Steam overlay | 60+ |
| FPS (1% low) | External tools | 45+ |
| Frame time | Godot profiler | <16.67ms (60fps) |
| VRAM usage | GPU-Z, nvidia-smi | <4GB |
| RAM usage | Task Manager / htop | <2GB |
| Load time | Stopwatch | <10 seconds |

### Stress Test Scenarios

Your game needs to handle worst-case scenarios:

1. **Maximum Enemies**: 500 enemies on screen (object pool limit)
2. **Maximum Particles**: 200 particles per system active
3. **Boss + Bullet Hell**: Complex patterns during boss fights
4. **Conspiracy Board Full**: All data logs discovered, many connections

Run each scenario for 2+ minutes. If FPS drops below 45, you have a problem.

---

## Testing Methodology

### Pre-Test Checklist

Before testing on any hardware:

- [ ] Export a release build (not debug)
- [ ] Disable any development tools/overlays
- [ ] Close background applications
- [ ] Update GPU drivers
- [ ] Note the exact build version being tested

### GTX 1060 Testing Protocol

**Time**: 2-4 hours

If you don't have access to a GTX 1060 machine:
- Borrow a friend's older gaming PC
- Use a cloud gaming service (Shadow, GeForce Now) for basic validation
- Rent GPU time on a service like Vast.ai

**Test Steps**:

1. **Cold Start**
   - Launch game from clean boot
   - Measure time to main menu
   - Note any hitching during load

2. **Menu Navigation**
   - All menus respond instantly
   - Settings apply correctly
   - Audio levels persist

3. **Gameplay Stress**
   - Play through first 3 waves
   - Trigger 500-enemy spawn scenario
   - Monitor FPS via Steam overlay (Shift+Tab > Settings > In-Game > FPS Counter)

4. **Boss Encounter**
   - Fight The Lobbyist
   - Note FPS during bullet patterns
   - Verify no frame drops during phase transitions

5. **Conspiracy Board**
   - Open board with 20+ discovered logs
   - Drag cards rapidly
   - Create/delete connections quickly

6. **Extended Play**
   - 30-minute continuous session
   - Watch for memory leaks (RAM usage climbing)
   - Check for any crashes or freezes

### Steam Deck Testing Protocol

**Time**: 2-4 hours

If you don't own a Steam Deck:
- Find a friend with one
- Valve has a developer kit program (lengthy waitlist)
- Test on SteamOS in a VM (limited, but catches major issues)

**Test Steps**:

1. **Install and Launch**
   - Install via Steam
   - Verify game shows controller glyphs
   - Check the game launches to Gaming Mode

2. **Controls**
   - All inputs map correctly
   - Trackpads work for conspiracy board (if enabled)
   - D-pad navigation in menus

3. **Performance**
   - Enable performance overlay (Quick Access > Performance)
   - Target 55-60 FPS at native resolution
   - Note battery drain percentage per hour

4. **Display**
   - UI readable at 1280x800
   - Text size adequate (see [Accessibility](accessibility-validation.md))
   - No elements cut off at screen edges

5. **Suspend/Resume**
   - Press Steam button to suspend
   - Resume after 5 minutes
   - Verify game state preserved
   - Check audio resumes correctly

6. **Battery Life**
   - Play for 30 minutes
   - Extrapolate battery life
   - Target: 2+ hours of gameplay

**Deck Verified Checklist**:

Valve checks these criteria. Meeting them all = Verified badge.

| Criterion | Status |
|-----------|--------|
| Controller support | ○ |
| No launcher required | ○ |
| Native resolution support | ○ |
| Default config functional | ○ |
| Text legible | ○ |
| No compatibility warnings | ○ |

### Linux Testing Protocol

**Time**: 2-4 hours

If you don't run Linux:
- Install Ubuntu in VirtualBox (limited GPU, but catches major issues)
- Use Windows Subsystem for Linux 2 with GPU passthrough
- Spin up a cloud Linux VM with GPU

**Test Steps**:

1. **Installation**
   - Download from Steam on Linux
   - Verify no missing dependencies
   - Game launches without terminal commands

2. **Basic Functionality**
   - All menus work
   - Gameplay functional
   - Save/load works

3. **Audio**
   - Sound plays (Linux audio can be finicky)
   - Volume controls work
   - No crackling or delays

4. **Controller**
   - Xbox controller detected
   - PlayStation controller detected (if supporting)
   - Correct glyphs displayed

5. **File Paths**
   - Saves write correctly (Linux paths differ)
   - No case-sensitivity issues in asset loading

---

## Known Issues by Platform

### Common GTX 1060 Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Shader compilation stutter | First-time shader cache | Pre-compile shaders or accept first-run stutter |
| VRAM overflow | Too many unique textures | Texture atlasing, compression |
| Thermal throttling | Extended play on hot day | Not your problem, but lower settings help |

### Common Steam Deck Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| UI too small | 800p display | Scale UI elements up |
| Trackpad awkward | Default mapping | Provide good controller scheme |
| Battery drain | High GPU load | Offer "Deck Mode" lower settings |
| Audio cuts out | Suspend/resume bug | Handle audio device changes |

### Common Linux Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| No audio | PulseAudio vs PipeWire | Test on both, use Godot defaults |
| Controller not detected | Permission issues | Document udev rules if needed |
| Crash on launch | glibc version | Build on older Ubuntu (20.04) for compatibility |
| Case-sensitive paths | Linux filesystem | Ensure consistent asset naming |

---

## Profiling Tools

### Godot Built-in

- **Debugger > Profiler**: Frame time breakdown
- **Debugger > Monitors**: Memory, objects, FPS
- **Debugger > Visual Profiler**: GPU time per shader

### External Tools

| Platform | Tool | Purpose |
|----------|------|---------|
| Windows | GPU-Z | VRAM monitoring |
| Windows | MSI Afterburner | FPS, thermals |
| Linux | nvidia-smi | NVIDIA GPU stats |
| Linux | radeontop | AMD GPU stats |
| Steam Deck | MangoHud | Built-in overlay |
| All | Steam Overlay | Quick FPS check |

---

## Optimization Strategies

If testing reveals problems:

### Quick Wins
- Reduce particle counts
- Lower shadow resolution
- Simplify distant enemy rendering
- Reduce audio channels

### Medium Effort
- Implement LOD (Level of Detail) for enemies
- Add graphics quality presets
- Optimize shaders
- Pool more objects

### Nuclear Options
- Reduce target resolution
- Cut visual features
- Limit enemy count further
- Remove background effects

**Priority**: Always fix the minimum spec first. If GTX 1060 struggles, everything else is secondary.

---

## Testing Log Template

Use this for each test session:

```markdown
## Test Session: [Date]

**Platform**: [GTX 1060 / Steam Deck / Linux]
**Build Version**: [e.g., v0.8.2]
**Tester**: [Name]

### Configuration
- Resolution:
- Settings: [Low/Medium/High]
- Driver version:

### Results

| Test | Pass/Fail | Notes |
|------|-----------|-------|
| Launch | | |
| Menu navigation | | |
| Combat (normal) | | |
| Combat (stress) | | |
| Boss fight | | |
| Conspiracy board | | |
| Extended play | | |

### Performance Metrics
- Average FPS:
- 1% Low FPS:
- VRAM usage:
- RAM usage:

### Issues Found
1.
2.
3.

### Notes

```

---

## Status Checklist

| Platform | Status | Notes |
|----------|--------|-------|
| GTX 1060 PC | Not Started | - |
| Steam Deck | Not Started | - |
| Linux (Ubuntu) | Not Started | - |
| Linux (SteamOS) | Not Started | - |

---

[Back to Human Steps Overview](overview.md) | [Previous: Steam Store Setup](steam-store-setup.md) | [Next: NGO Outreach](ngo-outreach.md)
