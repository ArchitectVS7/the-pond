# Content Creation Overview

Content is what makes The Pond's environmental message resonate. This chapter covers writing data logs, dialogue, and maintaining the game's distinctive tone.

---

## What's Here

| File | What It Covers |
|------|----------------|
| [Data Logs](data-logs.md) | Writing conspiracy documents |
| [Dialogue](dialogue.md) | Informant conversations, tone guide |

---

## Content Types

| Type | Purpose | Location |
|------|---------|----------|
| Data Logs | Environmental conspiracy evidence | `conspiracy_board/content/data_logs/` |
| Informant Dialogue | Story exposition, hints | `metagame/content/informants/` |
| UI Text | Interface labels, tooltips | Various `.tscn` files |
| Achievement Text | Names and descriptions | `core/scripts/achievement_manager.gd` |

---

## The Pond's Voice

### Core Principles

| Principle | Meaning |
|-----------|---------|
| Grounded | Real environmental issues, real corporate tactics |
| Personal | Told through the frog's perspective |
| Escalating | From local pollution to systemic corruption |
| Hopeful | Change is possible through exposure |

### What We're Not

| Avoid | Why |
|-------|-----|
| Preachy | Players came for a game, not a lecture |
| Depressing | Hopelessness doesn't motivate action |
| Abstract | Specific stories beat general statistics |
| Accusatory | Attack systems, not individuals |

---

## Data Log Structure

Every data log follows a pattern:

```markdown
# Data Log XX: [Title]

## TL;DR
[1-2 sentence summary of what this document reveals]

---

## Full Document
[The actual in-world document - memo, email, report, etc.]

---

## Narrative Context (Player Discovery)
[Where the player found this, how it connects to their story]
```

See [Data Logs](data-logs.md) for detailed writing guidelines.

---

## Dialogue Structure

Informant dialogue uses topics and hints:

```gdscript
var dialogue_topics = [
    "lobbyist_connections",
    "political_corruption",
    "evidence_locations",
    "personal_story",
    "final_warning"
]

var hints_available = [
    "hint_lobbyist_weakness",
    "hint_secret_area_1",
    "hint_evidence_location_1"
]
```

See [Dialogue](dialogue.md) for character voice guides.

---

## Real-World Grounding

The conspiracy is fictional, but based on real patterns:

| Fictional Element | Real-World Parallel |
|-------------------|---------------------|
| AgriCorp | Industrial agriculture pollution |
| Wetland dumping | Actual EPA loopholes |
| Cost reduction memos | Documented corporate decisions |
| NGO suppression | Real cases of whistleblower retaliation |

### Research Sources

- EPA enforcement actions
- Environmental journalism (ProPublica, etc.)
- Corporate misconduct cases
- Wetland ecosystem science

See [Appendix E: Bibliography](../appendices/e-bibliography.md) for specific sources.

---

## Localization Considerations

Content should be localization-friendly:

| Do | Don't |
|----|-------|
| Use separate string files | Hardcode text in code |
| Avoid idioms | "Spill the beans" doesn't translate |
| Keep sentences simple | Complex syntax is harder to translate |
| Use variables | `{company_name}` not "AgriCorp" everywhere |

### String Keys

```gdscript
# Good - localizable
var text = tr("DATA_LOG_01_TITLE")

# Bad - hardcoded
var text = "Corporate Memo - Cost Reduction Initiative"
```

---

## Content Pipeline

1. **Draft** - Write raw content
2. **Review** - Check tone, facts, grammar
3. **Integrate** - Add to game files
4. **Test** - Verify in-game presentation
5. **Iterate** - Polish based on playtest feedback

### File Naming

```
data_logs/
├── 01_corporate_memo.md
├── 02_internal_email.md
├── 03_research_report.md
...
```

Sequential numbering helps track discovery order.

---

## Quality Checklist

Before finalizing content:

- [ ] Follows TL;DR + Full Document + Context structure
- [ ] Appropriate length (not too long for mobile/Deck)
- [ ] Tone matches character voice
- [ ] No real company names
- [ ] Facts are plausible (research-backed)
- [ ] Connects to player's story
- [ ] No spelling/grammar errors
- [ ] Tested in-game layout

---

## Story Traceability

| Story | Description | Status |
|-------|-------------|--------|
| DATA-001 | Corporate Memo data log | Complete |
| DATA-002 | Internal Email data log | Complete |
| DATA-003 | Research Report data log | Complete |
| DATA-004 | NGO Communication data log | Pending content |
| DATA-005 | NGO Partnership outreach | Human step |
| DATA-006 | NGO Content review | Human step |
| DIALOGUE-001 | Deep Croak conversations | Complete |
| DIALOGUE-002 | Lily Padsworth conversations | Complete |

---

## Next Steps

If you're working on content:

1. Review existing logs in `conspiracy_board/content/data_logs/`
2. Read [Data Logs](data-logs.md) for writing guidelines
3. Read [Dialogue](dialogue.md) for character voices
4. Check [Human Steps](../12-human-steps/ngo-outreach.md) for blocked content

---

[Back to Index](../index.md) | [Next: Data Logs](data-logs.md)
