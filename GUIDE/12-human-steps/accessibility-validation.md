# Accessibility Validation

You've built colorblind modes. You've added text scaling. But does it actually work for real users with disabilities?

This guide covers testing with actual assistive technology and users. This happens after the other pieces are in place, but before launch.

---

## Why Real User Testing

Automated tools catch maybe 30% of accessibility issues. The rest require human testing:

- Screen reader users have different navigation patterns
- Colorblind users notice things simulators miss
- Motor-impaired players find interaction issues you can't predict
- Cognitive accessibility can only be tested by asking "is this confusing?"

**No amount of technical compliance replaces asking real users.**

---

## WCAG Compliance Targets

The Pond targets **WCAG 2.1 AA** compliance where applicable to games.

| Criterion | Requirement | Game Application |
|-----------|-------------|------------------|
| 1.4.3 Contrast | 4.5:1 for normal text, 3:1 for large | All UI text, menu items |
| 1.4.11 Non-text Contrast | 3:1 for UI components | Buttons, health bars, mutation icons |
| 1.4.1 Use of Color | Don't rely on color alone | Enemy types, connection states |
| 2.1.1 Keyboard | All functionality via keyboard | Menu navigation, pause |
| 2.3.1 Seizure | No flashing >3 times/second | Bullet patterns, effects |

Some WCAG criteria don't apply to action games (timing requirements, for example). Focus on what makes sense for your genre.

---

## Testing Categories

### 1. Screen Reader Testing

**Who needs this**: Blind and low-vision players

**What to test**:
- Menu navigation announces correctly
- Important game state changes are announced
- Conspiracy board documents are readable
- Settings are navigable

**Tools**:
| Tool | Platform | Cost |
|------|----------|------|
| NVDA | Windows | Free |
| JAWS | Windows | $1,000 (trial available) |
| VoiceOver | Mac/iOS | Built-in |
| Orca | Linux | Free |

**NVDA Testing Protocol**:

1. Install NVDA: https://www.nvaccess.org/
2. Launch game
3. Navigate menus with Tab/Arrow keys
4. Verify screen reader announces:
   - Current menu option
   - Button states (enabled/disabled)
   - Settings values
5. Open conspiracy board
6. Navigate to a document
7. Verify document text is readable

**Reality check**: Full screen reader support for action gameplay is extremely difficult. Focus on:
- Menus (achievable)
- Dialogue/story content (achievable)
- Conspiracy board reading mode (achievable)
- Core combat (probably not feasible for blind players)

### 2. Colorblind Testing

**Who needs this**: ~8% of men, 0.5% of women have some color vision deficiency

**Types**:
| Type | Affected Colors | Population |
|------|----------------|------------|
| Deuteranopia | Green/red confusion | 6% of men |
| Protanopia | Red/green, red appears dark | 2% of men |
| Tritanopia | Blue/yellow confusion | 0.1% of population |

**What to test**:
- Enemies distinguishable from background
- Health vs pollution vs mutation indicators
- Conspiracy board connections readable
- UI states (hover, selected, disabled)

**Testing methods**:

1. **Simulation tools**:
   - Windows: Color Oracle (free)
   - Browser: Chrome DevTools > Rendering > Emulate vision deficiencies
   - Game-specific: Your built-in colorblind mode shaders

2. **Real users**:
   - Ask colorblind friends/family
   - Post in colorblind communities (r/ColorBlind)
   - Use accessibility testing services

**The Pond's colorblind modes**:
```gdscript
# AccessibilityManager has three modes:
# - Deuteranopia filter
# - Protanopia filter
# - Tritanopia filter
```

Test each mode:
- Does the game remain playable?
- Are enemies still distinguishable?
- Is text still readable?

### 3. Keyboard-Only Testing

**Who needs this**: Motor-impaired players who can't use mouse/controller

**What to test**:
- All menus navigable with keyboard
- No mouse-only interactions required for core functions
- Tab order makes sense
- Focus indicators visible

**Testing protocol**:

1. Unplug your mouse
2. Launch game
3. Navigate to main menu
4. Start new game
5. Pause game
6. Access all settings
7. Access conspiracy board
8. Navigate documents

**Expected results**:
| Action | Key | Works? |
|--------|-----|--------|
| Menu navigation | Arrow keys | |
| Confirm | Enter/Space | |
| Cancel/Back | Escape | |
| Pause | Escape | |
| Open board | Tab or bound key | |
| Document navigation | Arrow keys | |

### 4. Motor Accessibility Testing

**Who needs this**: Players with limited mobility, one-handed players

**What to test**:
- Can game be played one-handed?
- Are button combinations avoidable?
- Is timing adjustable?
- Are there pause/slow-motion options?

**Considerations**:
- The Pond is a roguelike - difficulty is expected
- But *input barriers* are different from *skill barriers*
- Players should fail because of game challenge, not because they can't press buttons

**Common accommodations**:
| Feature | Implementation |
|---------|---------------|
| Rebindable keys | Settings menu |
| Toggle vs hold | Option for actions like run |
| Input buffer | Forgiveness window for commands |
| Pause anywhere | No forced unpausable sections |
| One-handed mode | All inputs on one side of keyboard |

### 5. Cognitive Accessibility Testing

**Who needs this**: Players with ADHD, dyslexia, cognitive disabilities

**What to test**:
- Is UI overwhelming?
- Is text readable (font, size, spacing)?
- Are instructions clear?
- Are there too many things to track?

**Harder to test**, but ask:
- Can someone explain the game after watching 2 minutes?
- Are conspiracy board connections visually overwhelming?
- Is there a "quiet" mode with reduced stimulation?

---

## Finding Testers

### Option 1: Accessibility Testing Services

| Service | What They Offer | Cost |
|---------|-----------------|------|
| AbleGamers | Player panels, consultation | Donation-based |
| SpecialEffect | UK-based gaming charity | Free/donation |
| AccessibilityGamers | Paid testing panels | Varies |

### Option 2: Community Outreach

Post in:
- r/disabledgamers
- r/ColorBlind
- AccessibleGaming Discord servers
- Twitter accessibility hashtags (#a11y, #GameAccessibility)

### Option 3: Friends and Family

Know someone colorblind? Ask them. Have a family member who uses screen readers? Ask them. First-hand testing is invaluable.

### What to Provide Testers

1. **Game build** (current state)
2. **Specific testing instructions** (what to test)
3. **Feedback form** (structured questions)
4. **Time estimate** (30 min? 1 hour?)
5. **Compensation** (game key, payment, credit)

---

## Feedback Collection

Use a structured form:

```markdown
## Accessibility Testing Feedback

**Tester name**:
**Date**:
**Accessibility need**: [e.g., colorblindness, screen reader user, motor impairment]
**Time spent**:

### Menu Navigation
- Could you navigate all menus? [Yes/No]
- Any issues?

### Gameplay
- Could you play the core game? [Yes/No]
- What barriers did you encounter?

### Conspiracy Board
- Could you read documents? [Yes/No]
- Could you navigate the board? [Yes/No]
- Any issues?

### Accessibility Features
- Which features did you use?
- Did they work as expected?
- What's missing?

### Overall
- Rating 1-5:
- Would you recommend to others with similar needs?
- Other comments:
```

---

## Issue Prioritization

When you find issues, prioritize:

| Priority | Definition | Example |
|----------|------------|---------|
| Critical | Blocks entire game | Can't start game with screen reader |
| High | Blocks major feature | Can't read conspiracy documents |
| Medium | Significant friction | Menu navigation awkward |
| Low | Minor inconvenience | Suboptimal contrast in one area |

Fix critical and high before launch. Medium can be patched. Low is nice-to-have.

---

## Built-In Accessibility Features

The Pond already has (per Epic implementation):

| Feature | Status | Location |
|---------|--------|----------|
| Colorblind modes (3) | Implemented | `AccessibilityManager` |
| Text scaling | Implemented | Settings > Accessibility |
| High contrast mode | Implemented | Settings > Accessibility |
| Screen reader support (menus) | Implemented | UI components |
| Keyboard navigation | Partial | Menus work, gameplay TBD |
| Remappable controls | Implemented | Settings > Controls |
| Reduced motion option | Implemented | Settings > Accessibility |

Test that these actually work as intended.

---

## Testing Log Template

```markdown
## Accessibility Test: [Date]

**Tester**: [Name or anonymous]
**Accessibility need**: [Colorblindness type / Screen reader / Motor / Cognitive]
**Build version**:

### Tests Performed
1.
2.
3.

### Issues Found

| Issue | Priority | Description |
|-------|----------|-------------|
| | | |

### Positive Findings
- What worked well?

### Recommendations
-

### Tester Compensation
- [Key provided / Payment sent / Credit added]
```

---

## Pre-Launch Checklist

| Task | Status | Notes |
|------|--------|-------|
| NVDA screen reader test | Not Started | - |
| Colorblind mode test (all 3) | Not Started | - |
| Keyboard-only navigation | Not Started | - |
| Real colorblind user test | Not Started | - |
| Real screen reader user test | Not Started | - |
| Motor accessibility review | Not Started | - |
| Cognitive accessibility review | Not Started | - |
| Contrast ratio check (all UI) | Not Started | - |
| Flashing content check | Not Started | - |
| Fix critical issues | Not Started | - |
| Fix high-priority issues | Not Started | - |

---

## Resources

- **Game Accessibility Guidelines**: https://gameaccessibilityguidelines.com/
- **AbleGamers Accessible Player Experience**: https://accessible.games/
- **NVDA Screen Reader**: https://www.nvaccess.org/
- **Color Oracle (colorblind sim)**: https://colororacle.org/
- **WCAG 2.1 Quick Reference**: https://www.w3.org/WAI/WCAG21/quickref/

---

[Back to Human Steps Overview](overview.md) | [Previous: NGO Outreach](ngo-outreach.md)
