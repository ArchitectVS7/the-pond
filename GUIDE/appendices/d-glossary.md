# Appendix D: Glossary

Game development terms used throughout this manual.

---

## A

### Atomic Write
Writing a file in a way that prevents corruption if interrupted. First write to a temporary file, then rename to the final location. If the process crashes, you either have the old file or the new file - never a partial/corrupted one.

### Autoload
A Godot feature (also called "singleton") that makes a node available globally. Used for managers like SaveManager, AudioManager, etc. Configured in Project Settings > AutoLoad.

---

## B

### Bezier Curve
A mathematical curve defined by control points. Used in the conspiracy board strings for smooth, natural-looking connections between cards. Godot provides `draw_line()` for straight lines and custom Bezier drawing for curves.

### Boss Phase
A distinct stage of a boss fight with different attack patterns. The Pond bosses have 3 phases, triggered at HP thresholds (66% and 33%). Each phase increases difficulty.

### Bullet Hell
A game genre featuring large numbers of projectiles (bullets) in complex patterns. Players must navigate through gaps. The Pond uses the BulletUpHell plugin for this.

---

## C

### Colorblind Mode
Display filters that adjust colors for players with color vision deficiency. The three common types:
- **Deuteranopia**: Red-green (most common, ~6% of males)
- **Protanopia**: Red-green (different type)
- **Tritanopia**: Blue-yellow (rare, ~0.01%)

### Cooldown
The waiting period between uses of an ability or attack. The tongue attack has a 0.3s cooldown. Cooldowns prevent spam and add rhythm to combat.

### CRC32 / SHA256
Checksum algorithms for detecting file corruption. CRC32 is faster but less secure. SHA256 is cryptographically secure. Used to validate save files haven't been corrupted (or tampered with).

---

## D

### Delta Time
The time elapsed since the last frame, typically passed to `_process(delta)`. Used to make movement frame-rate independent: `position += velocity * delta`. Without delta, movement would be faster at higher frame rates.

### Drag Threshold
The minimum distance (in pixels) the mouse must move before a click becomes a drag. Prevents accidental drags when clicking. The conspiracy board uses 5.0 pixels.

---

## E

### Elastic Physics
Physics simulation using spring-like forces. The tongue attack uses elastic physics for satisfying snap-back behavior. Key parameters: stiffness (spring strength) and damping (energy loss).

### Entity
A game object with behavior - enemies, players, bosses. Distinguished from static objects like tiles or UI elements.

### Epic
A large feature group containing multiple user stories. Example: EPIC-001 (Combat System) contains 14 stories from player movement to object pooling.

### Export Variable
A GDScript variable marked with `@export` that appears in the Godot Inspector. Allows tweaking values without editing code. Essential for tuning game feel.

---

## F

### Frame
A single rendered image. At 60fps, each frame is ~16.67ms. A "2-frame hit stop" means ~33ms of freeze.

### FPS (Frames Per Second)
How many frames render each second. 60fps is the target for The Pond. Below 55fps triggers warnings.

---

## G

### Game Feel (Juice)
The responsiveness and satisfaction of game controls. Achieved through:
- Screen shake
- Hit stop (frame freeze)
- Particles
- Sound effects
- Responsive controls (<16ms input lag)

### GDScript
Godot's Python-like scripting language. Used throughout The Pond. Alternative to C# or GDExtension.

### GodotSteam
A plugin that wraps the Steamworks SDK for Godot. Provides achievements, cloud saves, leaderboards, etc.

### GUT (Godot Unit Test)
A testing framework for Godot. Tests are GDScript files with methods starting with `test_`. Located in `test/` folders.

---

## H

### Hit Stop
A brief freeze (1-3 frames) when attacks connect. Creates impact feel. Also called "hit pause" or "freeze frame."

### Homing
Projectiles that track a target. The CEO boss uses homing missiles in phase 2. Controlled by homing_strength (turn rate) and homing_duration (active time).

---

## I

### Input Latency
The delay between pressing a button and seeing the result on screen. Target: <16ms. Affected by frame rate, processing time, and display lag.

### Informant
NPCs who provide hints and story context. The Pond has two: Deep Croak (whistleblower frog) and Lily Padsworth (journalist frog).

---

## J

### JSON
JavaScript Object Notation. A text format for structured data. Used for save files in The Pond. Human-readable but larger than binary formats.

---

## L

### Leaderboard
A ranked list of player scores. Steam provides global leaderboards. The Pond will have leaderboards for daily challenges and endless mode.

### Level Up
Gaining enough XP to increase in power and choose a new mutation. In roguelikes, level-ups are per-run (not persistent).

---

## M

### Meta-Progression
Progress that persists between runs. In The Pond: conspiracy board state, unlocked evidence, informant availability. Contrasted with per-run progression (mutations, HP).

### Mutation
A power-up that modifies player abilities. Can be "frog" themed (natural adaptations) or "pollution" themed (toxic effects). Roguelikes call these "items," "relics," or "upgrades."

---

## N

### Node
The building block of Godot scenes. Everything is a node: sprites, sounds, UI, physics. Nodes form a tree hierarchy.

### NGO
Non-Governmental Organization. The Pond partners with environmental NGOs for content accuracy and credibility.

---

## O

### Object Pool
A collection of pre-instantiated objects for reuse. Instead of creating/destroying enemies constantly (expensive), take from pool and return when done. Critical for performance with 500+ enemies.

### Overshoot
In animation, going past the target then bouncing back. The tongue extends 15% past max range then snaps back. Creates organic feel.

---

## P

### Packed Scene
A Godot resource (`.tscn` or `.scn`) containing a node tree. Can be instantiated multiple times. Enemy types, bullets, and UI elements are packed scenes.

### Pattern (Bullet)
A formation of bullets. Types include:
- **Radial**: Bullets in a circle
- **Spiral**: Rotating radial patterns
- **Wall**: Lines of bullets
- **Homing**: Target-seeking bullets

### Phase
A distinct section of a boss fight or gameplay. The Pond uses 3-phase bosses. Development uses phases: MVP, Alpha, Beta, 1.0.

### Pixel Art
Art style using visible pixels at low resolution. The Pond targets 32x32 character sprites.

### Pool (See Object Pool)

### Prewarm
Creating pooled objects before they're needed. Prevents frame drops when first spawning enemies. The spawner prewarns 50 enemies.

---

## R

### Radial Pattern
Bullets spawned in a circle from a center point. Defined by bullet count and angle spacing. 8 bullets = 45° apart.

### Refund Rate
Percentage of buyers who request refunds. Target: <10%. High refund rates indicate quality issues or misleading marketing.

### Roguelike
A genre featuring:
- Permadeath (lose progress on death)
- Procedural generation
- Resource management
- Meta-progression

The Pond is a "roguelite" - lighter on permadeath (conspiracy board persists).

### Run
A single playthrough from start to death/victory. Each run resets mutations and HP but not meta-progression.

---

## S

### Scene
A collection of nodes that form a game element - a level, menu, entity, etc. Godot games are composed of nested scenes.

### Seed (Random)
A starting value for random number generation. Same seed = same "random" sequence. Used for daily challenges to ensure identical runs globally.

### Separation (Flocking)
A behavior where entities avoid overlapping. Enemies use separation to spread out rather than clumping.

### Signal
Godot's event system. Nodes emit signals, other nodes connect to them. Decouples communication. Example: `enemy_died.emit()` triggers connected functions.

### Spatial Hash
A data structure for efficient spatial queries. Divides space into cells. Only checks objects in nearby cells instead of all objects. Critical for collision with 500+ entities.

### Spiral Pattern
A radial pattern that rotates over time. Creates classic bullet-hell swirling patterns.

### Spring (Physics)
A force that increases with distance from rest position. F = -kx where k is stiffness and x is displacement. Used for elastic physics (tongue, strings).

### Stinger (Audio)
A short musical phrase that plays at specific moments - victory, defeat, level complete. Usually 1-5 seconds.

### Story (User Story)
A unit of work in agile development. Format: "As a [user], I want [feature] so that [benefit]." Stories have IDs like COMBAT-001.

### Synergy
A bonus effect when combining specific mutations. Example: Oil + Toxic = Burning Slick (oil trail ignites from toxic damage).

---

## T

### Tileset
A collection of tiles for building levels. The lab arena has a tileset for the Researcher boss fight.

### TL;DR
"Too Long; Didn't Read" - a brief summary. Data logs have TL;DR summaries and full text versions.

### Trauma
A value (0 to 1) representing accumulated screen shake. Decays over time. Higher trauma = stronger shake.

### Trigger
An event that causes something to happen. Boss arena triggers when player enters. Phase transitions trigger at HP thresholds.

### Tween
Animated interpolation between values. Godot's Tween class handles smooth transitions for position, scale, color, etc.

---

## U

### UI (User Interface)
All visual elements the player interacts with - menus, HUD, popups. Built with Godot's Control nodes.

### User Story (See Story)

---

## V

### Vector2
A 2D point or direction (x, y). Used for position, velocity, direction. Normalized vectors have length 1.

### Vibe Coder
A developer who uses AI tools to assist coding, understanding concepts through guided exploration rather than memorizing syntax.

### Vignette
A darkening effect at screen edges. Draws focus to center. The conspiracy board uses vignette for atmosphere.

---

## W

### Wave
A group of enemies that spawn together. Waves escalate in difficulty over time.

### WCAG
Web Content Accessibility Guidelines. AA level requires 4.5:1 contrast ratio for text. The Pond validates against WCAG AA.

### Wishlists
Steam users adding games to their wishlist for later. Indicates interest before launch. High wishlists correlate with better launch sales.

---

## X

### XP (Experience Points)
Points earned by defeating enemies. When XP reaches threshold, player levels up and chooses a mutation.

---

## Z

### Z-Index
Draw order. Higher z-index draws on top. Used to ensure UI appears above game elements.

---

[Back to Index](../index.md)
