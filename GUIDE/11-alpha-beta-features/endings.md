# Endings

The Pond has multiple endings. Different evidence combinations reveal different conspiracies. This chapter covers all three ending paths.

---

## Overview

| Ending | Phase | Unlock |
|--------|-------|--------|
| Corporate Conspiracy | MVP | Follow the money |
| Government Coverup | Alpha | Follow the regulations |
| Nihilist | Beta | Give up |
| True Ending | Beta | Defeat secret boss |

---

## Ending 1: Corporate Conspiracy (MVP)

### Unlock Condition

Collect evidence that follows the money trail:
- Corporate Memo (cost reduction)
- Internal Email (implementation)
- Financial Records (profits)
- Complete all conspiracy board connections

### Narrative Summary

The player exposes AgriCorp's deliberate pollution. The corporation's cost-cutting memo proves they knew the damage they were causing. The CEO is arrested. Media coverage forces cleanup.

### Cutscene Flow

1. Evidence montage
2. News broadcast of arrest
3. Cleanup crews at the pond
4. Frog returns home
5. "The fight isn't over" message

---

## Ending 2: Government Coverup (Alpha)

### Unlock Condition

Connect evidence differently:
- Regulatory Filing (rubber-stamped)
- Senator Correspondence (lobbying)
- EPA Internal Memo (ignored warnings)
- Connect government-related logs

```gdscript
const GOVERNMENT_EVIDENCE := [
    "regulatory_filing",
    "senator_letter",
    "epa_memo"
]

func check_government_ending() -> bool:
    for evidence_id in GOVERNMENT_EVIDENCE:
        if not evidence_manager.is_discovered(evidence_id):
            return false
    return true
```

### Narrative Summary

The conspiracy goes higher. Regulatory capture let AgriCorp pollute with impunity. Government officials who looked the other way face investigation. The system itself was complicit.

### Cutscene Flow

1. Evidence connecting government officials
2. Congressional hearing footage
3. Resignations and investigations
4. Systemic reform message
5. "The rot goes deeper" warning

---

## Ending 3: Nihilist (Beta)

### Unlock Condition

Requirements:
- Die 50+ times
- Have <30% conspiracy completion
- Choose "Give Up" dialogue option

```gdscript
func check_nihilist_ending() -> bool:
    return (
        save_data.player_data.deaths >= 50 and
        evidence_manager.get_completion_percentage() < 0.3 and
        has_chosen_give_up_option
    )
```

### Narrative Summary

The frog gives up. The evidence is too scattered, the enemies too many, the conspiracy too vast. The pond dies. Life moves on elsewhere. Some fights can't be won.

### Cutscene Flow

1. Frog sitting alone
2. Pond slowly dying (time-lapse)
3. "You tried" message
4. Credits roll silently
5. Post-credits: "Or did you?"

### Design Intent

This ending is intentionally unsatisfying. It's for players who struggle but won't give up on the real endings. Seeing it should motivate another attempt.

---

## True Ending (Beta)

### Unlock Condition

1. Complete either Ending 1 or Ending 2
2. Defeat the secret boss (Sentient Pond)
3. Collect the final evidence piece

```gdscript
func check_true_ending() -> bool:
    return (
        (has_ending_1 or has_ending_2) and
        secret_boss_defeated and
        evidence_manager.has_final_evidence()
    )
```

### Narrative Summary

The pond itself was conscious - polluted into sentience. Defeating it was mercy. The full truth combines corporate greed, government failure, and the unintended consequences of pollution. The frog becomes a symbol of resistance.

### Cutscene Flow

1. Secret boss defeat
2. Pond becoming peaceful
3. Full evidence spread revealed
4. "The whole truth" summary
5. Thank you message to player
6. Full credits with environmental tips

---

## Ending Manager

```gdscript
# ending_manager.gd
class_name EndingManager
extends Node

signal ending_triggered(ending_id: String)

func check_endings() -> String:
    if check_true_ending():
        return "true"
    if check_nihilist_ending():
        return "nihilist"
    if check_government_ending():
        return "government"
    if check_corporate_ending():
        return "corporate"
    return ""

func trigger_ending(ending_id: String) -> void:
    ending_triggered.emit(ending_id)

    var cutscene = _load_cutscene(ending_id)
    await cutscene.play()

    _unlock_achievement(ending_id)
    _save_ending_state(ending_id)
```

---

## Ending Detection

### When to Check

```gdscript
func _on_conspiracy_board_complete() -> void:
    var ending = ending_manager.check_endings()
    if ending != "":
        ending_manager.trigger_ending(ending)

func _on_boss_defeated(boss_id: String) -> void:
    if boss_id == "secret_pond":
        var ending = ending_manager.check_endings()
        if ending == "true":
            ending_manager.trigger_ending(ending)
```

### Priority

Endings have priority (higher = checked first):

| Priority | Ending | Rationale |
|----------|--------|-----------|
| 1 | True | Most difficult to achieve |
| 2 | Nihilist | Special condition |
| 3 | Government | Requires specific evidence |
| 4 | Corporate | Default completion |

---

## Achievements

| Achievement | Ending | Description |
|-------------|--------|-------------|
| Case Closed | Corporate | Complete the corporate ending |
| Deep State | Government | Complete the government ending |
| Gave Up | Nihilist | Give in to despair |
| The Whole Truth | True | Achieve the true ending |
| Completionist | All | See all four endings |

---

## Cutscene Implementation

### Structure

```
metagame/
├── scenes/
│   ├── Ending1Cutscene.tscn
│   ├── Ending2Cutscene.tscn
│   ├── Ending3Cutscene.tscn
│   └── TrueEndingCutscene.tscn
└── content/
    └── endings/
        ├── ending1_script.json
        ├── ending2_script.json
        ├── ending3_script.json
        └── true_ending_script.json
```

### Script Format

```json
{
    "id": "ending_corporate",
    "scenes": [
        {
            "image": "evidence_montage",
            "text": "The evidence was undeniable.",
            "duration": 3.0
        },
        {
            "image": "arrest",
            "text": "Marcus Chen, former VP of Cost Optimization, was arrested.",
            "duration": 4.0
        }
    ]
}
```

---

## Human Dependencies

| Asset | Endings |
|-------|---------|
| Cutscene art (8-10 images each) | All |
| Ending music tracks | All |
| Voice acting (optional) | All |
| Credits scroll | All |

---

## Replay Value

### New Game+

After completing an ending:
- Mutations carry over
- Evidence collection persists
- New dialogue options unlock
- Different ending paths available

### Ending Gallery

```gdscript
func get_ending_gallery() -> Array:
    return save_data.endings_achieved.keys()

func is_ending_seen(ending_id: String) -> bool:
    return save_data.endings_achieved.has(ending_id)
```

---

## Summary

| Ending | Tone | Difficulty |
|--------|------|------------|
| Corporate | Hopeful | Easy |
| Government | Systemic | Medium |
| Nihilist | Bleak | Special |
| True | Cathartic | Hard |

Multiple endings reward different playstyles and persistence. The nihilist ending exists to make the other endings feel earned. The true ending is for completionists who want the whole picture.

---

[← Back to Endless Mode](endless-mode.md) | [Back to Overview](overview.md)
