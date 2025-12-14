# Informants

Informants are NPCs who provide narrative context and gameplay hints. Deep Croak and Lily Padsworth unlock after defeating bosses, rewarding meta-progression with story content.

---

## The Concept

Informants serve multiple purposes:

- **Narrative depth**: Flesh out the conspiracy story
- **Meta-progression reward**: Something to unlock beyond stats
- **Hint system**: Help struggling players
- **World-building**: Characters with personality and lore

---

## Informant Characters

### Deep Croak

**Unlock**: Defeat The Lobbyist

```gdscript
{
    "id": "deep_croak",
    "name": "Deep Croak",
    "title": "Anonymous Whistleblower",
    "description": "A shadowy figure who knows too much about the conspiracy",
    "unlock_condition": "lobbyist_defeated",
    "lore": "Once a government insider, Deep Croak risked everything to expose the truth. Now living in hiding, they communicate through encrypted channels..."
}
```

**Dialogue Topics**:
- `lobbyist_connections`
- `political_corruption`
- `evidence_locations`
- `personal_story`
- `final_warning`

**Hints Available**:
- `hint_lobbyist_weakness`: Boss strategy
- `hint_secret_area_1`: Exploration hint
- `hint_evidence_location_1`: Evidence location

---

### Lily Padsworth

**Unlock**: Defeat The CEO

```gdscript
{
    "id": "lily_padsworth",
    "name": "Lily Padsworth",
    "title": "Investigative Journalist",
    "description": "A relentless reporter who won't let this story die",
    "unlock_condition": "ceo_defeated",
    "lore": "Lily built her career on exposing corporate malfeasance. When her editor killed her story about the pond conspiracy, she went independent..."
}
```

**Dialogue Topics**:
- `ceo_investigation`
- `corporate_coverup`
- `media_suppression`
- `publish_evidence`
- `final_expose`

**Hints Available**:
- `hint_ceo_weakness`: Boss strategy
- `hint_secret_area_2`: Exploration hint
- `hint_evidence_location_2`: Evidence location

---

## InformantManager Structure

**File**: `metagame/scripts/informant_manager.gd`

```gdscript
class_name InformantManager
extends Node

signal informant_unlocked(informant_id: String)
signal dialogue_completed(informant_id: String, topic: String)
signal hint_received(hint_id: String, hint_text: String)

class Informant:
    var id: String
    var name: String
    var title: String
    var description: String
    var unlock_condition: String
    var portrait: String
    var dialogue_topics: Array[String]
    var hints_available: Array[String]
    var lore: String
```

---

## Unlocking Informants

```gdscript
func unlock_informant(informant_id: String) -> bool:
    if unlocked_informants.has(informant_id):
        return false  # Already unlocked

    if not INFORMANTS.has(informant_id):
        return false  # Unknown informant

    # Check unlock condition
    if not _check_unlock_condition(INFORMANTS[informant_id].unlock_condition):
        return false

    # Create and unlock
    var informant := Informant.new(INFORMANTS[informant_id])
    unlocked_informants[informant_id] = informant

    informant_unlocked.emit(informant_id)
    return true

func _check_unlock_condition(condition: String) -> bool:
    match condition:
        "lobbyist_defeated":
            return meta_progression.meta_state.evidence.boss_defeats.get("lobbyist", 0) > 0
        "ceo_defeated":
            return meta_progression.meta_state.evidence.boss_defeats.get("ceo", 0) > 0
        _:
            return true
```

---

## Hint System

### Hint Database

```gdscript
const HINTS := {
    "hint_lobbyist_weakness": {
        "id": "hint_lobbyist_weakness",
        "text": "The Lobbyist's shield is powered by corruption. Target the connections to his allies first...",
        "category": "boss_strategy",
        "informant": "deep_croak"
    },
    "hint_secret_area_1": {
        "id": "hint_secret_area_1",
        "text": "There's a hidden drainage tunnel in the Industrial Zone. Look for the broken fence...",
        "category": "exploration",
        "informant": "deep_croak"
    }
}
```

### Receiving Hints

```gdscript
func receive_hint(hint_id: String) -> Dictionary:
    if not HINTS.has(hint_id):
        return {}

    var hint := HINTS[hint_id]

    # Track received hints in meta-progression
    if hint_id not in meta_progression.meta_state.informants.hints_received:
        meta_progression.meta_state.informants.hints_received.append(hint_id)
        meta_progression.save_meta_state()

    hint_received.emit(hint_id, hint.text)
    return hint
```

### Available Hints

```gdscript
func get_available_hints(informant_id: String) -> Array[String]:
    if not unlocked_informants.has(informant_id):
        return []

    var informant := unlocked_informants[informant_id]
    var available: Array[String] = []

    for hint_id in informant.hints_available:
        if not _is_hint_received(hint_id):
            available.append(hint_id)

    return available
```

---

## Dialogue Progress

Track which conversations players have completed:

```gdscript
func complete_dialogue_topic(informant_id: String, topic: String) -> void:
    if not unlocked_informants.has(informant_id):
        return

    meta_progression.meta_state.informants.dialogue_progress[informant_id][topic] = true
    meta_progression.save_meta_state()

    dialogue_completed.emit(informant_id, topic)

func is_dialogue_completed(informant_id: String, topic: String) -> bool:
    var progress := get_dialogue_progress(informant_id)
    return progress.get(topic, false)
```

---

## UI Integration

### Informant Menu

```gdscript
func _populate_informant_list() -> void:
    for informant in informant_manager.get_all_unlocked_informants():
        var entry = InformantEntry.instantiate()
        entry.setup(informant)
        entry.selected.connect(_on_informant_selected)
        $InformantList.add_child(entry)
```

### Dialogue UI

```gdscript
func _show_dialogue(informant_id: String, topic: String) -> void:
    var dialogue_text = _get_dialogue_text(informant_id, topic)
    $DialogueBox.show_dialogue(dialogue_text)

    # Mark as completed when finished
    $DialogueBox.dialogue_finished.connect(
        func(): informant_manager.complete_dialogue_topic(informant_id, topic)
    )
```

### Hint Request

```gdscript
func _on_hint_button_pressed() -> void:
    var available = informant_manager.get_available_hints(current_informant.id)
    if available.is_empty():
        $NoHintsLabel.visible = true
        return

    var hint = informant_manager.receive_hint(available[0])
    $HintText.text = hint.text
```

---

## Writing Informant Content

### Dialogue Guidelines

**Deep Croak** (Whistleblower):
- Speaks cryptically, paranoid
- Uses metaphors and code words
- Knows internal company details
- Reluctant to reveal everything at once

**Lily Padsworth** (Journalist):
- Direct, professional
- Asks as many questions as she answers
- Focused on evidence and proof
- Optimistic about exposing the truth

### Hint Writing

Good hints:
- Specific enough to help
- Vague enough to not spoil
- Fit the character's voice
- Reference in-game locations/mechanics

```
# Good hint
"The CEO surrounds himself with lawyers and PR. His attacks are predictable -
watch for the pattern in his 'legal maneuvers' and strike during his
'board meeting' recovery phase."

# Too vague
"The CEO has a weakness."

# Too specific
"Dodge left during phase 2, attack window is 1.5 seconds."
```

---

## Future Informants (Alpha/Beta)

| Informant | Unlock | Theme |
|-----------|--------|-------|
| Dr. Marsh | Researcher defeated | Scientist who regrets |
| Senator Ribbit | All evidence collected | Political insider |
| The Pond (voice) | True ending path | Nature itself |

---

## Persistence

Informant state saves to meta-progression:

```gdscript
meta_state.informants = {
    "unlocked": ["deep_croak", "lily_padsworth"],
    "dialogue_progress": {
        "deep_croak": {"lobbyist_connections": true, "personal_story": true},
        "lily_padsworth": {}
    },
    "hints_received": ["hint_lobbyist_weakness", "hint_secret_area_1"]
}
```

---

## Summary

| Informant | Unlock | Hints | Topics |
|-----------|--------|-------|--------|
| Deep Croak | Lobbyist defeated | 3 | 5 |
| Lily Padsworth | CEO defeated | 3 | 5 |

Informants reward meta-progression with story content. They're not required to beat the game, but they enrich the experience and help struggling players.

---

[← Back to Steam Cloud](steam-cloud.md) | [Back to Overview](overview.md)
