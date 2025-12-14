## informant_manager.gd - META-003/004: Informant Characters
## Manages Deep Croak (Whistleblower) and Lily Padsworth (Journalist)

extends Node
class_name InformantManager

signal informant_unlocked(informant_id: String)
signal dialogue_completed(informant_id: String, topic: String)
signal hint_received(hint_id: String, hint_text: String)

## Informant character data
class Informant:
	var id: String
	var name: String
	var title: String
	var description: String
	var unlock_condition: String  # "lobbyist_defeated", "ceo_defeated"
	var portrait: String  # Path to portrait resource
	var dialogue_topics: Array[String]
	var hints_available: Array[String]
	var lore: String

	func _init(data: Dictionary) -> void:
		id = data.get("id", "")
		name = data.get("name", "Unknown")
		title = data.get("title", "")
		description = data.get("description", "")
		unlock_condition = data.get("unlock_condition", "")
		portrait = data.get("portrait", "")
		dialogue_topics = data.get("dialogue_topics", [])
		hints_available = data.get("hints_available", [])
		lore = data.get("lore", "")

## Informant definitions
const INFORMANTS := {
	"deep_croak": {
		"id": "deep_croak",
		"name": "Deep Croak",
		"title": "Anonymous Whistleblower",
		"description": "A shadowy figure who knows too much about the conspiracy",
		"unlock_condition": "lobbyist_defeated",
		"portrait": "res://assets/portraits/deep_croak.png",
		"dialogue_topics": [
			"lobbyist_connections",
			"political_corruption",
			"evidence_locations",
			"personal_story",
			"final_warning"
		],
		"hints_available": [
			"hint_lobbyist_weakness",
			"hint_secret_area_1",
			"hint_evidence_location_1"
		],
		"lore": "Once a government insider, Deep Croak risked everything to expose the truth. Now living in hiding, they communicate through encrypted channels, guiding those brave enough to challenge the conspiracy."
	},
	"lily_padsworth": {
		"id": "lily_padsworth",
		"name": "Lily Padsworth",
		"title": "Investigative Journalist",
		"description": "A relentless reporter who won't let this story die",
		"unlock_condition": "ceo_defeated",
		"portrait": "res://assets/portraits/lily_padsworth.png",
		"dialogue_topics": [
			"ceo_investigation",
			"corporate_coverup",
			"media_suppression",
			"publish_evidence",
			"final_expose"
		],
		"hints_available": [
			"hint_ceo_weakness",
			"hint_secret_area_2",
			"hint_evidence_location_2"
		],
		"lore": "Lily Padsworth built her career on exposing corporate malfeasance. When her editor killed her story about the pond conspiracy, she went independent. Now she's ready to publish everything - if she can get the proof."
	}
}

## Hint database
const HINTS := {
	"hint_lobbyist_weakness": {
		"id": "hint_lobbyist_weakness",
		"text": "The Lobbyist's shield is powered by corruption. Target the connections to his allies first - break his network, and he becomes vulnerable.",
		"category": "boss_strategy",
		"informant": "deep_croak"
	},
	"hint_ceo_weakness": {
		"id": "hint_ceo_weakness",
		"text": "The CEO surrounds himself with lawyers and PR. His attacks are predictable - watch for the pattern in his 'legal maneuvers' and strike during his 'board meeting' recovery phase.",
		"category": "boss_strategy",
		"informant": "lily_padsworth"
	},
	"hint_secret_area_1": {
		"id": "hint_secret_area_1",
		"text": "There's a hidden drainage tunnel in the Industrial Zone. Look for the broken fence near the old water treatment plant. The evidence you need is inside.",
		"category": "exploration",
		"informant": "deep_croak"
	},
	"hint_secret_area_2": {
		"id": "hint_secret_area_2",
		"text": "The CEO's private office is accessible through the executive elevator. You'll need a keycard from one of the security guards. Check the break room on Floor 12.",
		"category": "exploration",
		"informant": "lily_padsworth"
	},
	"hint_evidence_location_1": {
		"id": "hint_evidence_location_1",
		"text": "Dr. Marsh's field notes are hidden in her old research station at Willow Bend. The building looks abandoned, but the basement lab is still intact.",
		"category": "evidence",
		"informant": "deep_croak"
	},
	"hint_evidence_location_2": {
		"id": "hint_evidence_location_2",
		"text": "The contract you're looking for is in a safety deposit box at First Pond Bank. Box 237. The key is... harder to find. Try checking the Lobbyist's office after you've dealt with him.",
		"category": "evidence",
		"informant": "lily_padsworth"
	}
}

var meta_progression: MetaProgression
var unlocked_informants: Dictionary = {}  # {informant_id: Informant}

func _ready() -> void:
	# Get meta-progression singleton
	if has_node("/root/MetaProgression"):
		meta_progression = get_node("/root/MetaProgression")

	# Load unlocked informants
	_load_unlocked_informants()

## Load informants from meta-progression
func _load_unlocked_informants() -> void:
	if not meta_progression:
		return

	for informant_id in meta_progression.meta_state.informants.unlocked:
		if INFORMANTS.has(informant_id):
			var informant := Informant.new(INFORMANTS[informant_id])
			unlocked_informants[informant_id] = informant

## Unlock informant
func unlock_informant(informant_id: String) -> bool:
	if unlocked_informants.has(informant_id):
		print("[InformantManager] Informant already unlocked: " + informant_id)
		return false

	if not INFORMANTS.has(informant_id):
		push_error("[InformantManager] Unknown informant: " + informant_id)
		return false

	# Check unlock condition
	var informant_data = INFORMANTS[informant_id]
	if not _check_unlock_condition(informant_data.unlock_condition):
		print("[InformantManager] Unlock condition not met for: " + informant_id)
		return false

	# Create and unlock informant
	var informant := Informant.new(informant_data)
	unlocked_informants[informant_id] = informant

	# Update meta-progression
	if meta_progression:
		if informant_id not in meta_progression.meta_state.informants.unlocked:
			meta_progression.meta_state.informants.unlocked.append(informant_id)
			meta_progression.meta_state.informants.dialogue_progress[informant_id] = {}
			meta_progression.save_meta_state()

	informant_unlocked.emit(informant_id)
	print("[InformantManager] Informant unlocked: %s (%s)" % [informant.name, informant.title])
	return true

## Check if unlock condition is met
func _check_unlock_condition(condition: String) -> bool:
	if not meta_progression:
		return false

	match condition:
		"lobbyist_defeated":
			return meta_progression.meta_state.evidence.boss_defeats.get("lobbyist", 0) > 0
		"ceo_defeated":
			return meta_progression.meta_state.evidence.boss_defeats.get("ceo", 0) > 0
		_:
			return true

## Check if informant is unlocked
func is_informant_unlocked(informant_id: String) -> bool:
	return unlocked_informants.has(informant_id)

## Get informant
func get_informant(informant_id: String) -> Informant:
	return unlocked_informants.get(informant_id)

## Get all unlocked informants
func get_all_unlocked_informants() -> Array[Informant]:
	var result: Array[Informant] = []
	result.assign(unlocked_informants.values())
	return result

## Complete dialogue topic
func complete_dialogue_topic(informant_id: String, topic: String) -> void:
	if not unlocked_informants.has(informant_id):
		push_warning("[InformantManager] Informant not unlocked: " + informant_id)
		return

	if not meta_progression:
		return

	# Update dialogue progress
	if not meta_progression.meta_state.informants.dialogue_progress.has(informant_id):
		meta_progression.meta_state.informants.dialogue_progress[informant_id] = {}

	meta_progression.meta_state.informants.dialogue_progress[informant_id][topic] = true
	meta_progression.save_meta_state()

	dialogue_completed.emit(informant_id, topic)
	print("[InformantManager] Dialogue completed: %s - %s" % [informant_id, topic])

## Get dialogue progress for informant
func get_dialogue_progress(informant_id: String) -> Dictionary:
	if not meta_progression:
		return {}

	return meta_progression.meta_state.informants.dialogue_progress.get(informant_id, {})

## Check if dialogue topic is completed
func is_dialogue_completed(informant_id: String, topic: String) -> bool:
	var progress := get_dialogue_progress(informant_id)
	return progress.get(topic, false)

## Get available hints from informant
func get_available_hints(informant_id: String) -> Array[String]:
	if not unlocked_informants.has(informant_id):
		return []

	var informant := unlocked_informants[informant_id]
	var available: Array[String] = []

	for hint_id in informant.hints_available:
		if not _is_hint_received(hint_id):
			available.append(hint_id)

	return available

## Receive hint from informant
func receive_hint(hint_id: String) -> Dictionary:
	if not HINTS.has(hint_id):
		push_error("[InformantManager] Unknown hint: " + hint_id)
		return {}

	var hint := HINTS[hint_id]

	# Update meta-progression
	if meta_progression:
		if hint_id not in meta_progression.meta_state.informants.hints_received:
			meta_progression.meta_state.informants.hints_received.append(hint_id)
			meta_progression.save_meta_state()

	hint_received.emit(hint_id, hint.text)
	print("[InformantManager] Hint received: " + hint_id)

	return hint

## Check if hint has been received
func _is_hint_received(hint_id: String) -> bool:
	if not meta_progression:
		return false

	return hint_id in meta_progression.meta_state.informants.hints_received

## Get hint data
func get_hint(hint_id: String) -> Dictionary:
	return HINTS.get(hint_id, {})

## Get all received hints
func get_received_hints() -> Array[Dictionary]:
	if not meta_progression:
		return []

	var result: Array[Dictionary] = []
	for hint_id in meta_progression.meta_state.informants.hints_received:
		if HINTS.has(hint_id):
			result.append(HINTS[hint_id])

	return result
