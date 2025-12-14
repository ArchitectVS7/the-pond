# How to Use This Manual

This manual exists to help you build The Pond from where it is now to a polished 1.0 release on Steam. It's not a reference encyclopedia. It's a map through the territory.

---

## What This Is

**A Developer's Guide**

Written for the person (or AI) actually doing the work. Each chapter covers a system, explains why it exists, shows how to modify it, and documents every knob you can turn.

**Not a Design Document**

The PRD and architecture documents live elsewhere. This manual assumes the "what" is decided - it focuses on "how to build it" and "how to change it."

---

## Who It's For

**Vibe Coders**

Developers who work with AI assistance. You prompt, you iterate, you ship. You might not have a CS degree, but you understand enough to know when something's wrong. This manual is built for your workflow.

**Solo Developers**

One person doing everything. The chapters are written so you can context-switch between combat code and Steam integration without losing your place.

**Future Maintainers**

Someone will inherit this codebase. Maybe it's you in six months. The documentation explains *why* things work, not just *what* they do.

---

## How to Navigate

### Starting Fresh?

Read these in order:
1. [The Journey So Far](the-journey-so-far.md) - Where the project has been
2. [For Vibe Coders](for-vibe-coders.md) - How to use AI effectively with this codebase
3. [Project Anatomy](../01-foundations/project-anatomy.md) - Where everything lives

### Working on a Feature?

Jump directly to the relevant chapter:
- Combat system broken? → [Chapter 02](../02-combat-system/overview.md)
- Board dragging feels off? → [Chapter 04](../04-conspiracy-board/overview.md)
- Boss too easy/hard? → [Chapter 06](../06-boss-encounters/overview.md)

### Need to Ship Something?

[Human Steps](../12-human-steps/overview.md) has actionable checklists for art, audio, Steam, and testing.

### Curious About a Concept?

Sidebars explain terms in 1-2 paragraphs:
> **Sidebar**: [What is Spatial Hashing?](../02-combat-system/sidebars/what-is-spatial-hashing.md)
> Why checking 500 enemies every frame doesn't kill performance.

---

## Chapter Structure

Each chapter follows a pattern:

| Section | What's There |
|---------|--------------|
| **Overview** | What the system does, why it exists |
| **Implementation** | How the code works, with key files |
| **Tunable Parameters** | Every `@export` variable, documented |
| **Story Traceability** | Which stories map to which code |
| **Sidebars** | Quick concept explanations |

---

## Reading the Code

This manual references actual code files. When you see:

```
**File**: `combat/scripts/player_controller.gd:245`
```

That's the file path and line number. Open it in your editor.

### Code Snippets

Snippets show the essential pattern, not always the full implementation:

```gdscript
# Pattern: Object pooling
func get_enemy() -> Enemy:
    if pool.is_empty():
        return Enemy.new()
    return pool.pop_back()
```

For the complete code, read the actual file.

---

## Making Changes

### Tunable Parameters

Every chapter has a tunable parameters table:

| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `string_stiffness` | 150.0 | 50-300 | Higher = snappier |

Change these values first. No code modification needed.

### Behavior Changes

If tunables aren't enough:
1. Find the relevant chapter
2. Understand the current implementation
3. Locate the file via Story Traceability
4. Make your change
5. Run tests: `npm run test`

### Adding Features

For new features:
1. Check [Alpha/Beta Features](../11-alpha-beta-features/overview.md) - it might be planned
2. Find the most similar existing system
3. Follow its patterns
4. Document your tunables

---

## Progress Tracking

The [index](../index.md) shows chapter completion status:

| Chapter | Status |
|---------|--------|
| 02-combat-system | **Complete** |
| 07-meta-progression | Draft |

"Complete" means documented. "Draft" means stub files exist.

---

## Updating This Manual

### When to Update

- Adding a tunable parameter → Add to the parameters table
- Changing behavior → Update the implementation section
- Adding a feature → Document in the relevant chapter

### Style

Follow the [Style Guide](../style-guide.md). Key points:
- Specific over vague: "300ms" not "fast"
- Why alongside what: Explain the reason
- No exclamation marks: Enthusiasm is for code, not docs

---

## Getting Help

**Stuck on implementation?**
Ask your AI assistant with context from this manual.

**Found a bug in the docs?**
Fix it and commit. Documentation is code.

**Need a feature documented?**
Follow the chapter structure pattern.

---

[Next: The Journey So Far →](the-journey-so-far.md)
