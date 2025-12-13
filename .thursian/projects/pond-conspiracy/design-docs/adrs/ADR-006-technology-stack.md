# ADR-006: Technology Stack Selection

**Status**: Accepted
**Date**: 2025-12-13
**Decision Makers**: Chief Architect, Backend Architect, Frontend Architect, DevOps Architect
**Related ADRs**: ADR-001 (Platform), ADR-002 (System Architecture)

---

## Context

Need to select languages, frameworks, libraries, and tools that:
- Support 60fps bullet-hell combat
- Enable rapid iteration (10-12 week MVP)
- Match team expertise (solo dev + pixel artist)
- Support Windows/Linux/Steam Deck
- Minimal dependencies

---

## Decision

### Game Engine: **Godot 4.2+ (GDScript)**

**Why Godot**:
- ✅ Free and open-source (MIT license)
- ✅ Excellent 2D performance (60fps easily achievable)
- ✅ Cross-platform exports (Windows, Linux, macOS)
- ✅ Built-in Steam Deck support
- ✅ Fast iteration (hot reload, visual editor)
- ✅ Small binary size (<50MB)
- ✅ Active community, good documentation
- ✅ No royalties (vs Unity/Unreal 5% after $1M)

**Why GDScript** (over C#):
- ✅ Tighter Godot integration
- ✅ Faster iteration (no compile step)
- ✅ Python-like syntax (easy to learn)
- ✅ Built-in type hints (static typing available)
- ❌ Slower than C# (acceptable for this game's scope)

**Godot Version**: 4.2.1 (latest stable as of Dec 2025)

---

### Technology Stack Summary

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Engine** | Godot Engine | 4.2.1 | Core game engine |
| **Language** | GDScript | (built-in) | Game logic, UI |
| **Bullet Patterns** | BulletUpHell Plugin | 2.0+ (forked) | Bullet-hell engine |
| **Steam Integration** | GodotSteam | 4.7+ | Achievements, cloud saves |
| **Version Control** | Git + GitHub | - | Code repository |
| **CI/CD** | GitHub Actions | - | Automated builds |
| **Asset Creation** | Aseprite | 1.3+ | Pixel art sprites |
| **Audio** | Godot AudioStreamPlayer | (built-in) | Music & SFX |
| **Testing** | GUT (Godot Unit Test) | 9.2+ | Unit/integration tests |

---

### Third-Party Dependencies

#### 1. BulletUpHell Plugin (MIT License)

**Purpose**: Bullet-hell pattern engine

**Features**:
- Radial bullet patterns
- Custom trajectories
- Object pooling
- Performance-optimized for 500+ bullets

**Risk Mitigation** (from PRD CI-3.3):
- **Fork on Day 1**: Create internal copy
- **Repository**: `github.com/[our-org]/BulletUpHell-fork`
- **Rationale**: If upstream development stops, we own the code

**Integration**:
```gdscript
# res://addons/BulletUpHell/
# Autoload as singleton, accessed via BulletManager
```

---

#### 2. GodotSteam Plugin (MIT License)

**Purpose**: Steam API wrapper

**Features**:
- Achievements
- Cloud saves
- Leaderboards (future)
- Workshop (future)

**Installation**: Compile from source or use prebuilt binaries

**Documentation**: https://godotsteam.com

**Fallback**: Game works without Steam (offline mode)

---

### Development Tools

**IDE/Editor**: VS Code with GDScript LSP extension
- Syntax highlighting
- Autocomplete
- Error checking
- Git integration

**Version Control**:
- **Git** for code
- **GitHub** for repository (private during dev, public post-launch)
- **Git LFS** for large assets (sprites, audio) if needed

**Build Automation**: GitHub Actions
```yaml
# .github/workflows/build.yml
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Export Godot Project
        uses: firebelley/godot-export@v5
        with:
          godot_version: 4.2.1
          export_preset: Windows
      - name: Upload Artifact
        uses: actions/upload-artifact@v3
```

**Testing Framework**: GUT (Godot Unit Test)
```gdscript
# test/unit/test_mutation_system.gd
extends GutTest

func test_oil_trails_mutation_applies_correctly():
    var player = Player.new()
    player.apply_mutation("oil_trails")
    assert_true(player.has_mutation("oil_trails"))
    assert_eq(player.get_pollution_level(), 1)
```

---

### Asset Pipeline

**Sprites**: Aseprite (.ase → .png export)
- 16x16 base tile size
- 2x or 3x scaling for HD displays
- Export as PNG sprite sheets

**Audio**:
- **SFX**: 16-bit WAV files (small, fast loading)
- **Music**: OGG Vorbis (compressed, looping)
- Tools: Audacity (free) or LMMS

**Fonts**: Google Fonts (Open Font License)
- Monospace font for data logs (terminal aesthetic)
- Sans-serif for UI

---

### Performance Tools

**Profiling**: Godot's built-in profiler
- Frame time breakdown
- Script execution time
- Memory usage

**Debugging**: Godot's debugger
- Breakpoints
- Variable inspection
- Remote debugging on Steam Deck

**Monitoring** (runtime):
```gdscript
func _process(delta):
    if OS.is_debug_build():
        var fps = Engine.get_frames_per_second()
        var memory = OS.get_static_memory_usage() / 1048576.0 # MB
        DebugOverlay.update_stats(fps, memory)
```

---

## Tech Stack Decision Matrix

### Engine Comparison

| Feature | Godot | Unity | Unreal |
|---------|-------|-------|--------|
| **2D Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Learning Curve** | ⭐⭐⭐⭐⭐ (easiest) | ⭐⭐⭐ | ⭐⭐ (hardest) |
| **Binary Size** | 50MB | 200MB+ | 500MB+ |
| **Cost** | Free | Free (Unity 6 Personal) | 5% after $1M |
| **Linux Support** | ⭐⭐⭐⭐⭐ (native) | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Steam Deck** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Community** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ (largest) | ⭐⭐⭐⭐ |
| **Maturity** | ⭐⭐⭐⭐ (4.x stable) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Verdict**: Godot wins for solo 2D indie game

---

### Language Comparison (for Godot)

| Feature | GDScript | C# |
|---------|----------|-----|
| **Performance** | ⭐⭐⭐⭐ (fast enough) | ⭐⭐⭐⭐⭐ (faster) |
| **Godot Integration** | ⭐⭐⭐⭐⭐ (1st-class) | ⭐⭐⭐⭐ |
| **Iteration Speed** | ⭐⭐⭐⭐⭐ (no compile) | ⭐⭐⭐ (compile step) |
| **Learning Curve** | ⭐⭐⭐⭐⭐ (Python-like) | ⭐⭐⭐ (C# syntax) |
| **Type Safety** | ⭐⭐⭐⭐ (optional types) | ⭐⭐⭐⭐⭐ (static) |
| **Debugging** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

**Verdict**: GDScript for faster iteration (60fps achievable)

---

## Consequences

### Positive

✅ **Zero licensing costs**: Godot + all tools are free/open-source
✅ **Fast iteration**: Hot reload, no compile step
✅ **Small footprint**: <50MB engine + <100MB game = <150MB total
✅ **Active community**: Discord, Reddit, forums, tutorials
✅ **Cross-platform**: Windows/Linux/Steam Deck from single codebase
✅ **Future-proof**: Open-source, can't be "shut down" by vendor

### Negative

❌ **Smaller ecosystem**: Fewer plugins than Unity
❌ **Less enterprise adoption**: Fewer AAA games use Godot
❌ **GDScript performance**: Slower than C++/C# (acceptable for this game)
❌ **Tooling maturity**: VS Code extension less polished than Unity's editor

### Neutral

🔷 **Godot 4.x is young**: 4.0 released 2023, some bugs expected (mitigated by using 4.2 stable)
🔷 **Limited job market**: GDScript not widely used in industry (irrelevant for solo indie)

---

## Alternatives Considered

### Alternative 1: Unity

**Pros**: Larger asset store, more tutorials, industry standard

**Cons**: Runtime fees (after $200K revenue), larger binary size, overkill for 2D

**Rejected**: Godot is better fit for indie 2D

---

### Alternative 2: Custom Engine (C++/SDL)

**Pros**: Full control, maximum performance

**Cons**: 6+ months just to build engine, reinvent wheels (physics, audio, etc.)

**Rejected**: Not viable for 10-12 week timeline

---

### Alternative 3: Unreal Engine

**Pros**: Best graphics, AAA-quality tooling

**Cons**: Massive download (100GB+), overkill for 2D pixel art, 5% revenue share

**Rejected**: Wrong tool for this project

---

## Migration Strategy (Future-Proofing)

**If Godot 5.0 releases during development**:
- Stay on 4.2.x until MVP ships
- Evaluate migration for post-launch updates
- Breaking changes unlikely (Godot has good backward compat)

**If we need C# performance later**:
- Godot 4.x supports C# alongside GDScript
- Can rewrite performance-critical scripts incrementally
- Unlikely to be needed (60fps achievable in GDScript)

**If we need custom shaders**:
- Godot supports GLSL shaders
- Can add visual effects in post-processing without engine change

---

## Related Decisions

- **ADR-001**: Platform (Windows/Linux/Steam Deck)
- **ADR-002**: System Architecture (Godot scenes)
- **ADR-007**: Frontend Architecture (Godot UI system)

---

## Implementation

### Week 0 Setup

```bash
# Install Godot 4.2.1
wget https://downloads.tuxfamily.org/godotengine/4.2.1/Godot_v4.2.1-stable_linux.x86_64.zip

# Clone BulletUpHell plugin
git clone https://github.com/Dark-Peace/BulletUpHell.git
# Fork to our org for safety (CI-3.3)

# Install GodotSteam
# Download prebuilt binaries from godotsteam.com

# Setup project structure
mkdir -p res://core res://combat res://conspiracy_board res://metagame res://shared res://assets
```

### Dependencies Manifest

```toml
# project.godot
[plugins]
BulletUpHell = { version = "2.0", source = "local_fork" }
GodotSteam = { version = "4.7", source = "https://godotsteam.com" }

[addons]
gut = { version = "9.2", source = "asset_library" }
```

---

**Approved By**: ✅ Chief Architect, Backend Architect, Frontend Architect, DevOps Architect

**Next ADR**: ADR-007 - Frontend Architecture (Conspiracy Board UI)
