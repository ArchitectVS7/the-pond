# ADR-001: Platform & Deployment Strategy

**Status**: Accepted
**Date**: 2025-12-13
**Decision Makers**: Chief Architect, Platform Architect, DevOps Architect
**Stakeholders**: Engineering Team, Product Manager

---

## Context

Pond Conspiracy is a PC roguelike bullet-hell game targeting the indie gaming market. We need to select target platforms, hosting strategy, and deployment approach that balance:

- **Market reach** vs development cost
- **Performance requirements** (60fps minimum, <16ms input lag)
- **Team expertise** (solo dev + pixel artist)
- **Time constraints** (10-12 week MVP)
- **Budget constraints** ($5-8K total)

### Requirements from PRD

**Platform Support (FR-007)**:
- Windows (primary market)
- Linux (Steam Deck compatibility)
- Steam Deck @ 800p 55fps minimum

**Performance (NFR-001)**:
- 60fps minimum on GTX 1060 / RX 580 @ 1080p
- 90fps+ average (streaming headroom)
- <16ms input lag
- <3s load times run-to-run

**Distribution**:
- Steam as primary platform
- Early Access launch → 1.0 transition
- Steam Cloud save sync

---

## Decision

### Target Platforms

**Supported**:
1. **Windows 10/11** (64-bit only)
   - Primary development and testing platform
   - Largest market share (~80% of Steam users)
   - First-class support

2. **Linux** (Ubuntu 22.04+ LTS, Proton compatibility)
   - Native Linux build via Godot export
   - Steam Deck enabler
   - ~5% market share but growing

3. **Steam Deck** (SteamOS 3.0+)
   - Verified compatibility tier
   - 800p @ 55fps minimum
   - Controller support required

**NOT Supported** (deferred):
- macOS (low priority, <5% market, defer to Post-Launch)
- Mobile (iOS/Android) - fundamentally different UX
- Consoles (Switch/Xbox/PlayStation) - Year 2 if game succeeds

### Deployment Strategy

**Distribution**: Steam exclusive
- Leverage Steam's distribution infrastructure
- No self-hosting / update servers required
- Built-in DRM (optional, will NOT use invasive DRM)
- Workshop potential (mod support in Year 2)

**Release Strategy**:
- **Early Access**: $10, 10-12 weeks from kickoff
- **1.0 Launch**: $15, 7-9 months post-EA
- **No other storefronts initially** (itch.io/GOG deferred to post-1.0)

**Update Delivery**:
- Steam's automatic update system
- Hotfix capability (patch within hours if critical bug)
- Opt-in beta branch for testing

### Infrastructure

**Hosting**: None required
- Fully local game, no servers
- No backend APIs or databases
- No matchmaking or multiplayer

**Cloud Services**:
- **Steam Cloud**: Save file synchronization (built-in, free)
- **Steamworks SDK**: Achievements, leaderboards (future), cloud saves
- **No external cloud** (AWS/Azure/GCP) - not needed

### Build Pipeline

**CI/CD**: GitHub Actions (free tier sufficient)
- Automated builds on commit to `main`
- Godot export for Windows, Linux
- Steam Deck compatibility validation
- Artifact storage in GitHub Releases

**Testing Environments**:
- **Development**: Developer machine (Windows 11)
- **Testing**: Windows 10 + Linux VM + actual Steam Deck hardware
- **No staging environment** (local-only game)

**Deployment Process**:
1. Build via GitHub Actions
2. Manual QA on Windows/Linux/Steam Deck
3. Upload to Steam via Steamworks (manual initially, automate later)
4. Push to Early Access or beta branch

### Containerization

**Decision**: NOT using Docker/containers
- No server-side components
- Game distributed as compiled binaries
- Godot handles cross-platform builds natively
- Containers add no value for desktop games

---

## Consequences

### Positive

✅ **Simple architecture**: No servers, no backend, no ops overhead
✅ **Cost-effective**: $0/month hosting, free CI/CD (GitHub Actions)
✅ **Fast iteration**: Deploy updates instantly via Steam
✅ **Proven distribution**: Steam handles 100% of deployment infrastructure
✅ **Team-appropriate**: No devops expertise required
✅ **Performance**: Local execution, no network latency concerns

### Negative

❌ **Platform lock-in**: Heavy reliance on Steam ecosystem
❌ **Limited reach initially**: No GOG, itch.io, Epic
❌ **Steam Deck testing burden**: Requires actual hardware (~$400)
❌ **No telemetry infrastructure**: Can't track user behavior (mitigated by Steam stats)

### Neutral

🔷 **macOS deferred**: Lose 5% potential market, but saves 2+ weeks dev time
🔷 **Console deferred**: Large market, but porting cost ~$20-40K + certification
🔷 **No multiplayer**: Simplifies architecture but limits social features

---

## Alternatives Considered

### Alternative 1: Multi-Store Day 1 (Steam + GOG + itch.io)

**Pros**:
- Wider reach
- DRM-free option (GOG)
- Lower Steam revenue cut for some sales

**Cons**:
- 3x deployment complexity
- Update coordination headache
- Testing burden (3 platforms)
- Minimal incremental revenue (<10% uplift estimated)

**Rejected**: Not worth complexity for 10-12 week MVP

---

### Alternative 2: Web-Based (WebAssembly)

**Pros**:
- Zero installation friction
- Cross-platform automatically
- Browser-based distribution

**Cons**:
- Godot WebAssembly export immature
- Performance issues (60fps hard to guarantee)
- No Steam integration (achievements, cloud saves)
- Monetization harder (no Steam marketplace)

**Rejected**: Performance requirements incompatible with web

---

### Alternative 3: Mobile-First (iOS/Android)

**Pros**:
- Larger potential market (billions of devices)
- In-app purchase revenue potential

**Cons**:
- Touch controls fundamentally change gameplay
- Bullet-hell genre poor fit for mobile
- Conspiracy board UI requires large screen
- 6+ month porting effort
- Target audience is PC gamers, not mobile

**Rejected**: Wrong platform for this game concept

---

## Related Decisions

- **ADR-002**: System Architecture (monolithic desktop app)
- **ADR-006**: Technology Stack (Godot Engine, GodotSteam plugin)
- **ADR-012**: Observability (Steam stats instead of custom analytics)

---

## Notes

### Steam Deck Verification Process

To achieve "Verified" status on Steam Deck:
1. 55fps minimum @ 800p (medium settings)
2. Controller support (full navigation, no mouse required)
3. Text readability (minimum font size 18px)
4. Proton compatibility (test on actual hardware)

**Plan**: Week 9-10 QA includes Steam Deck testing

### Performance Validation

**Target hardware**: GTX 1060 6GB / RX 580 8GB (5-year-old mid-range)
- Represents 40% of Steam Hardware Survey
- Conservative target ensures wide compatibility
- 90fps average leaves headroom for streaming

**Testing approach**:
- Profile with Godot's built-in profiler
- Test on actual GTX 1060 hardware (borrow or rent)
- Validate with OBS running (streaming scenario per CI-4.1)

### Future Platform Expansion

**Year 2 (if game succeeds)**:
- GOG release (DRM-free version)
- itch.io (indie-friendly platform)
- macOS build (if porting cost < $5K)

**Year 3+**:
- Console ports (Switch, Xbox, PlayStation)
- Requires external porting house (~$30-50K investment)
- Wait until PC version proves commercial viability

---

## Implementation

### Week 0 (Pre-Development)

- [ ] Set up GitHub repository
- [ ] Configure GitHub Actions for Godot exports
- [ ] Register Steamworks developer account ($100 one-time)
- [ ] Create Steam app listing (private)

### Week 1-8 (Development)

- [ ] Develop on Windows, test on Linux VM weekly
- [ ] Build exports automated via GitHub Actions

### Week 9-10 (QA)

- [ ] Test on Windows 10, Windows 11
- [ ] Test on Ubuntu 22.04 (or Steam Deck directly)
- [ ] Acquire/borrow Steam Deck for hardware testing
- [ ] Validate 60fps on GTX 1060, 55fps on Steam Deck
- [ ] Test controller support end-to-end

### Week 11-12 (Launch Prep)

- [ ] Upload build to Steam (Coming Soon page live)
- [ ] Configure Steam Cloud for save files
- [ ] Set Early Access pricing ($10)
- [ ] Prepare launch assets (trailer, screenshots)

---

**Approved By**:
- ✅ Chief Architect
- ✅ Platform Architect
- ✅ DevOps Architect

**Next ADR**: ADR-002 - System Architecture & Module Structure
