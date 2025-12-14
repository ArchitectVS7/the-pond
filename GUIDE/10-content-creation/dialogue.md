# Dialogue

Dialogue comes from informant characters who provide story context and gameplay hints. This chapter covers writing for Deep Croak, Lily Padsworth, and future informants.

---

## Informant Characters

### Deep Croak

**Role**: Anonymous Whistleblower

**Unlock**: Defeat The Lobbyist

**Voice Characteristics**:
- Paranoid, cryptic
- Uses metaphors and code words
- Knows internal company details
- Reluctant to reveal everything at once
- Speaks in warnings

**Example Lines**:
```
"They're watching. They're always watching. Don't use names.
Don't leave trails. I learned that the hard way."

"The Lobbyist wasn't always... what he is now. I remember when
he believed in something. Before the money changed him."

"Look for the pattern in the discharge reports. Every third
Tuesday. That's when they think no one's looking."
```

### Lily Padsworth

**Role**: Investigative Journalist

**Unlock**: Defeat The CEO

**Voice Characteristics**:
- Direct, professional
- Asks as many questions as she answers
- Focused on evidence and proof
- Optimistic about exposing the truth
- Methodical

**Example Lines**:
```
"I've been tracking AgriCorp for three years. Every time I get
close, the story gets killed. But you—you're getting evidence
they can't bury."

"Facts. I need facts. The memo is good, but what about the
financial records? Follow the money. It always leads somewhere."

"My editor thinks I'm crazy. 'Just a local pollution story,'
she says. She doesn't see what I see. What you see."
```

---

## Dialogue Topics

Each informant has conversation topics:

### Deep Croak Topics

| Topic ID | Subject | Content Focus |
|----------|---------|---------------|
| `lobbyist_connections` | The Lobbyist's network | Who he works with, who pays him |
| `political_corruption` | Government complicity | How regulations get weakened |
| `evidence_locations` | Hidden documents | Where to find more proof |
| `personal_story` | Deep Croak's past | Why they became a whistleblower |
| `final_warning` | Endgame stakes | What happens if you fail |

### Lily Padsworth Topics

| Topic ID | Subject | Content Focus |
|----------|---------|---------------|
| `ceo_investigation` | The CEO's history | Rise to power, past scandals |
| `corporate_coverup` | How they hide evidence | Legal tactics, PR strategies |
| `media_suppression` | Why stories get killed | Corporate pressure on media |
| `publish_evidence` | Going public | What it takes to break the story |
| `final_expose` | The big picture | Connecting all the pieces |

---

## Dialogue Structure

### Topic Conversation

```gdscript
var dialogue_data = {
    "lobbyist_connections": {
        "intro": "So you want to know about The Lobbyist's friends...",
        "body": [
            "He's got connections in every regulatory agency.",
            "The EPA, the state board, even the local council.",
            "None of them make a move without checking with him first."
        ],
        "conclusion": "Be careful. These people play for keeps.",
        "unlocks": ["hint_lobbyist_weakness"]
    }
}
```

### Hint Delivery

```gdscript
var hints = {
    "hint_lobbyist_weakness": {
        "text": "The Lobbyist's shield is powered by corruption. Target
                 the connections to his allies first...",
        "category": "boss_strategy",
        "character_voice": "I shouldn't be telling you this, but...
                           watch his shield. It's not invincible.
                           Every ally he loses weakens it."
    }
}
```

---

## Writing Hints

### Good Hints

| Characteristic | Example |
|----------------|---------|
| Specific enough to help | "Watch for the pattern in his 'legal maneuvers'" |
| Vague enough to not spoil | Not "Dodge left during phase 2" |
| In character voice | Deep Croak speaks differently than Lily |
| References game mechanics | "His 'board meeting' recovery phase" |

### Bad Hints

| Problem | Example |
|---------|---------|
| Too vague | "The CEO has a weakness" |
| Too specific | "Dodge left, attack window is 1.5 seconds" |
| Out of character | Deep Croak being cheerful |
| Game-breaking | Trivializes the challenge |

### Example: Good Boss Hint

```
# Deep Croak on The Lobbyist
"His shield... it feeds on his network. Every ally he's got in that
room makes him stronger. Cut the connections first. Isolate him.
That's when he's vulnerable."

# Lily on The CEO
"The CEO surrounds himself with lawyers and PR people. His attacks
are predictable—watch for the pattern in his 'legal maneuvers' and
strike during his 'board meeting' recovery phase."
```

---

## Dialogue Progress

Track which conversations the player has completed:

```gdscript
func complete_dialogue_topic(informant_id: String, topic: String) -> void:
    meta_progression.meta_state.informants.dialogue_progress[informant_id][topic] = true
    meta_progression.save_meta_state()
    dialogue_completed.emit(informant_id, topic)
```

### Unlocking New Topics

Some topics unlock after others:

```gdscript
func get_available_topics(informant_id: String) -> Array[String]:
    var available: Array[String] = []
    var progress = get_dialogue_progress(informant_id)

    for topic in informant.dialogue_topics:
        var prereqs = TOPIC_PREREQUISITES.get(topic, [])
        if _all_prereqs_met(progress, prereqs):
            available.append(topic)

    return available
```

---

## Voice Consistency

### Deep Croak Speech Patterns

| Pattern | Example |
|---------|---------|
| Interrupted thoughts | "They're... no, I shouldn't say." |
| Paranoid asides | "(Keep your voice down.)" |
| Code names | "The Suit", "The Network", "The Machine" |
| Warnings | "Be careful. Don't trust. Verify everything." |

### Lily Padsworth Speech Patterns

| Pattern | Example |
|---------|---------|
| Questions | "What did you find? Where? When?" |
| Professional terms | "Source", "corroboration", "on the record" |
| Optimism | "We're close. I can feel it." |
| Journalistic ethics | "I need two independent sources." |

---

## Localization

Dialogue should be localization-friendly:

```gdscript
# Good - uses translation key
var text = tr("DEEP_CROAK_INTRO_01")

# Bad - hardcoded
var text = "They're watching. They're always watching."
```

### String File Structure

```
localization/en/informants.csv
DEEP_CROAK_INTRO_01,"They're watching. They're always watching."
DEEP_CROAK_LOBBYIST_01,"The Lobbyist wasn't always what he is now."
LILY_INTRO_01,"I've been tracking AgriCorp for three years."
```

---

## Future Informants

| Informant | Unlock | Personality |
|-----------|--------|-------------|
| Dr. Marsh | Defeat Researcher | Regretful scientist, technical |
| Senator Ribbit | All evidence | Political insider, pragmatic |
| The Pond (voice) | True ending | Nature itself, ancient, vast |

### Dr. Marsh (Planned)

```
"I thought I was helping. 'Acceptable risk,' they told me.
'Natural resilience.' I believed them. I wanted to believe them.

The data was right there. I just... didn't want to see it."
```

### Senator Ribbit (Planned)

```
"Kid, you don't understand how this town works. You think one
document changes anything? I've seen a hundred documents. They
get buried. They get 'lost.' They get explained away.

But you... you're not playing by their rules. That scares them."
```

---

## Quality Checklist

Before finalizing dialogue:

- [ ] Matches character voice
- [ ] Appropriate length (not too long)
- [ ] Hints are helpful but not spoilers
- [ ] No real names/companies
- [ ] Advances story or provides value
- [ ] Can be localized (no untranslatable idioms)
- [ ] Grammar and spelling checked

---

## Summary

| Character | Voice | Purpose |
|-----------|-------|---------|
| Deep Croak | Paranoid, cryptic | Insider knowledge, warnings |
| Lily Padsworth | Professional, optimistic | Investigation guidance |
| Future characters | Varied | Expand story scope |

Good dialogue serves the player: it reveals story, provides hints, and builds the world. Each character should feel distinct and memorable, with a consistent voice that players learn to recognize.

---

[← Back to Data Logs](data-logs.md) | [Back to Overview](overview.md)
