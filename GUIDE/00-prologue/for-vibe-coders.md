# For Vibe Coders

You prompt AI to write code. You iterate until it works. You might not know every algorithm by name, but you know when something feels right. This manual is built for you.

---

## What's a Vibe Coder?

Someone who:
- Uses AI (Claude, GPT, Copilot) as a primary tool
- Understands code well enough to debug it
- Learns by doing, not by reading textbooks
- Cares more about shipping than credentials

The Pond was built this way. Every system was drafted with AI assistance, refined through iteration, and validated through testing.

---

## How to Use AI with This Codebase

### Context Is Everything

AI doesn't know your codebase. You have to tell it. When prompting:

**Bad prompt:**
> "Fix the enemy movement"

**Good prompt:**
> "In player_controller.gd, enemies are stacking on top of each other. The separation force (line 245) uses spatial hashing but doesn't seem strong enough. Current separation_radius is 30.0. What should I change?"

### Reference This Manual

When working on a system, include relevant documentation in your prompt:

> "I'm working on the string physics. Here's the current implementation from string_renderer.gd and the documentation from GUIDE/04-conspiracy-board/string-physics.md. The strings feel too stiff. What parameters should I adjust?"

### Tunable Parameters First

Before asking AI to rewrite code, check the tunable parameters tables. Most "bugs" are just wrong values:

| Problem | Solution |
|---------|----------|
| Strings too stiff | Lower `string_stiffness` |
| Enemies too fast | Lower `enemy_speed` |
| Boss too easy | Raise `boss_hp`, lower `phase_threshold` |

---

## Effective Prompting Patterns

### The Context-Problem-Question Pattern

```
CONTEXT: I'm working on [system]. The relevant file is [file].
Current behavior: [what happens]
Expected behavior: [what should happen]
QUESTION: [specific ask]
```

### The Debug Pattern

```
This code isn't working as expected:
[paste relevant code]

Error/Behavior: [what's wrong]
I've tried: [what you attempted]
The code should: [expected behavior]
```

### The Feature Pattern

```
I need to add [feature] to [system].
Existing patterns in the codebase:
- [similar feature 1 in file1.gd]
- [similar feature 2 in file2.gd]

Requirements:
- [requirement 1]
- [requirement 2]

What's the best approach?
```

---

## When AI Gets It Wrong

AI will:
- Suggest deprecated patterns
- Ignore your project structure
- Invent functions that don't exist
- Oversimplify or overcomplicate

### How to Catch Errors

1. **Run the code.** Sounds obvious, but always test.
2. **Check the imports.** Does the file it references exist?
3. **Verify the syntax.** GDScript isn't Python isn't JavaScript.
4. **Read the error.** Godot's errors are usually clear.

### How to Fix Errors

1. **Be specific.** "That function doesn't exist in Godot 4.2" beats "It doesn't work."
2. **Show the error.** Paste the actual error message.
3. **Provide context.** What file? What line? What were you trying to do?

---

## Learning Through This Codebase

### Start with Working Code

Every system in The Pond works. Before modifying:
1. Read the implementation section in this manual
2. Open the file and trace the logic
3. Run the game and see it in action

### Sidebars Are Your Friends

When you see a term you don't know, check for a sidebar:

> **Sidebar**: [What is Object Pooling?](../02-combat-system/sidebars/what-is-object-pooling.md)

Sidebars explain concepts in 1-2 paragraphs. Quick reads, not deep dives.

### Modify, Don't Rewrite

When fixing something:
1. Change one thing
2. Test
3. Repeat

Rewriting entire systems usually breaks more than it fixes.

---

## Common Vibe Coder Mistakes

### Trusting AI Too Much

AI will confidently suggest wrong solutions. Always verify.

### Not Reading Errors

The error message usually tells you exactly what's wrong. Read it.

### Changing Too Much at Once

One change per test. Otherwise you won't know what fixed (or broke) things.

### Skipping the Docs

This manual exists because the code alone doesn't explain intent. Read the relevant chapter before diving in.

---

## Your Workflow

A suggested approach:

1. **Find the chapter** that covers what you're working on
2. **Read the overview** to understand the system
3. **Check tunable parameters** before changing code
4. **Locate the file** via Story Traceability
5. **Make one change**, test, repeat
6. **Document** what you changed if it affects parameters

---

## AI as a Partner, Not a Replacement

AI is excellent at:
- Explaining code you don't understand
- Suggesting solutions to specific problems
- Generating boilerplate
- Catching obvious bugs

AI is terrible at:
- Understanding your game's feel
- Knowing what players want
- Making design decisions
- Testing on real hardware

You're the developer. AI is a very fast junior programmer who needs supervision.

---

## Building Confidence

Every developer started not knowing things. The difference between stuck and unstuck is usually:

1. **Knowing what to search for**
2. **Having context to understand answers**
3. **Being willing to experiment**

This manual provides the context. AI provides the speed. You provide the judgment.

---

[← Back to The Journey So Far](the-journey-so-far.md) | [Back to Index](../index.md)
