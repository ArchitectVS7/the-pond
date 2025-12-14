# Writing Style Guide

This guide exists because documentation either helps or it doesn't. Dry technical manuals get skimmed. Breathless excitement gets ignored. We're aiming for something different: writing that respects your time and intelligence while actually being readable.

---

## The Voice

**Technical + Human + Natural**

We're writing for developers who:
- Use AI to help them code ("vibe coders")
- Want to understand what's happening, not just copy-paste
- Appreciate when someone gets to the point
- Can handle complexity if it's explained well

---

## Do This

### Lead with facts, not feelings
The reader wants to know what something does before they care how you feel about it.

**Yes:**
> The strings wobble. They settle in 300ms with a satisfying bounce.

**No:**
> The string physics system is an incredibly sophisticated implementation that provides amazing visual feedback!

### Ground in specifics
Numbers are your friends. Vague descriptions waste everyone's time.

**Yes:**
> 60fps minimum on GTX 1060 @ 1080p with 500 enemies on screen.

**No:**
> The game runs smoothly on modern hardware.

### Use brief narratives
A sentence or two of context helps concepts land.

**Yes:**
> When a player drags a card, the string connecting it should feel alive. Not stiff, not floaty - just satisfying. We use a damped spring model.

**No:**
> The StringRenderer class implements damped spring physics using the formula F = -k * x - c * v.

### Respect reader intelligence
Explain concepts when needed, but don't over-explain basics.

**Yes:**
> Object pooling eliminates runtime allocations. Instead of creating and destroying enemies, we reuse them.

**No:**
> Object pooling is a design pattern where, instead of creating new objects each time they are needed and then destroying them when they are no longer needed, a pool of reusable objects is maintained and objects are acquired from and returned to this pool as needed.

### Include "why" alongside "what"
Code is easy to read. Intent is not.

**Yes:**
> `separation_radius = 30.0` prevents enemies from stacking on top of each other. Lower values (15px) create tight swarms. Higher values (50px+) spread them out.

**No:**
> `separation_radius = 30.0` sets the separation radius to 30.

---

## Don't Do This

### Over-exclaim
Exclamation points don't make things exciting.

**No:** "This feature is amazing!" / "The results are incredible!"
**Yes:** "This works." / "The results meet our targets."

### Be dry and sterile
Technical accuracy doesn't require being boring.

**No:** "The input subsystem processes user input events."
**Yes:** "When you press a key, here's what happens."

### Assume jargon knowledge
First use of a term should be explained or link to a sidebar.

**No:** "We use a spatial hash for O(n*k) neighbor queries."
**Yes:** "We use a spatial hash - a grid that lets us check only nearby enemies instead of all 500. [Learn more](sidebars/what-is-spatial-hashing.md)"

### Use AI-sounding hedging
Be direct. If you're not sure, say so plainly.

**No:** "It's important to note that..." / "It should be mentioned that..."
**Yes:** (Just say the thing)

### Pad with filler
Every sentence should carry weight.

**No:** "In order to successfully implement this feature, you will need to..."
**Yes:** "To implement this, you need..."

---

## Sidebar Format

Sidebars explain concepts in 1-2 paragraphs. They're quick reads, not deep dives.

```markdown
# What is Spatial Hashing?

Imagine dividing your game world into a grid. Each enemy lives in exactly one cell. When you need to find nearby enemies, you only check the current cell and its neighbors - not every enemy in the game.

Without spatial hashing, checking 500 enemies against each other is 250,000 comparisons per frame. With it, maybe 2,500. That's the difference between 60fps and a slideshow.

**Why The Pond uses it:** Enemy separation. When enemies push apart to avoid stacking, they only need to know about neighbors within 30 pixels. Spatial hashing makes that query fast.

[Back to Combat System](../02-combat-system/performance.md)
```

---

## Code Comments

Follow the pattern established in the codebase:

```gdscript
## Called every physics frame at fixed 60fps
## Note: _delta is unused because physics timestep is fixed
## Performance: No heap allocations, only stack variables
func _physics_process(_delta: float) -> void:
```

Triple-hash (`###`) for sections, double-hash (`##`) for doc comments.

---

## Section Headers

Use active voice:

**Yes:**
- Setting Up the Project
- Implementing the Spring System
- Testing on Steam Deck

**No:**
- Project Setup
- Spring System Implementation
- Steam Deck Testing

---

## Tunable Parameters Tables

Standard format:

```markdown
| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `string_stiffness` | 150.0 | 50-300 | Higher = snappier bounce |
| `string_damping` | 8.0 | 2-15 | Higher = less oscillation |
```

Always include:
- The actual variable name (backticked)
- Default value
- Reasonable range
- What changing it does (in plain language)

---

## Links

Use descriptive link text, not "click here":

**Yes:**
> See [Steam Deck optimization](08-platform-integration/steam-deck.md) for portable performance.

**No:**
> For Steam Deck optimization, click [here](08-platform-integration/steam-deck.md).

---

## Tone Examples

Here's the same information written three ways:

**Too dry:**
> The AccessibilityManager class provides methods for modifying visual parameters to accommodate users with color vision deficiency.

**Too excited:**
> The amazing AccessibilityManager makes your game accessible to everyone! With just one click, you can enable incredible colorblind support!

**Just right:**
> AccessibilityManager handles colorblind modes. Three shader-based filters - deuteranopia, protanopia, tritanopia - transform the palette in real time. Players toggle them in settings.

---

## When In Doubt

Ask yourself:
1. Would I want to read this?
2. Does every sentence earn its place?
3. Could I explain this out loud to a colleague?

If you're writing something you'd skip over while reading, cut it or rewrite it.

---

*This style guide applies to all GUIDE/ documentation. For in-code comments, see the patterns established in `player_controller.gd`.*
