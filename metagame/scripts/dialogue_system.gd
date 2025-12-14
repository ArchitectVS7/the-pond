## dialogue_system.gd - META-005: Dialogue Tree System
## Manages branching dialogue trees for informant interactions

extends Node
class_name DialogueSystem

signal dialogue_started(informant_id: String, topic: String)
signal dialogue_line_displayed(speaker: String, text: String, choices: Array)
signal dialogue_choice_selected(choice_id: String)
signal dialogue_ended(informant_id: String, rewards: Dictionary)

## Dialogue node structure
class DialogueNode:
	var id: String
	var speaker: String  # "informant", "player", "narrator"
	var text: String
	var choices: Array[DialogueChoice] = []
	var next_node: String  # Auto-advance to next node (if no choices)
	var conditions: Dictionary = {}  # {condition_type: value} for gating dialogue
	var effects: Dictionary = {}  # {effect_type: value} for dialogue outcomes
	var emotion: String = "neutral"  # "neutral", "serious", "worried", "happy", "angry"

	func _init(data: Dictionary) -> void:
		id = data.get("id", "")
		speaker = data.get("speaker", "informant")
		text = data.get("text", "")
		next_node = data.get("next_node", "")
		conditions = data.get("conditions", {})
		effects = data.get("effects", {})
		emotion = data.get("emotion", "neutral")

		# Parse choices
		for choice_data in data.get("choices", []):
			choices.append(DialogueChoice.new(choice_data))

## Dialogue choice structure
class DialogueChoice:
	var id: String
	var text: String
	var next_node: String
	var conditions: Dictionary = {}
	var effects: Dictionary = {}
	var hint_cost: int = 0  # Cost in hints to select this choice

	func _init(data: Dictionary) -> void:
		id = data.get("id", "")
		text = data.get("text", "")
		next_node = data.get("next_node", "")
		conditions = data.get("conditions", {})
		effects = data.get("effects", {})
		hint_cost = data.get("hint_cost", 0)

## Dialogue tree definitions
const DIALOGUE_TREES := {
	"deep_croak_intro": {
		"start": {
			"id": "start",
			"speaker": "informant",
			"text": "You found me. Not many do. The question is... can I trust you?",
			"emotion": "serious",
			"choices": [
				{
					"id": "trust_me",
					"text": "I'm here to expose the truth.",
					"next_node": "trust_path"
				},
				{
					"id": "who_are_you",
					"text": "Who are you?",
					"next_node": "identity_path"
				},
				{
					"id": "prove_it",
					"text": "Prove you have real information.",
					"next_node": "proof_path"
				}
			]
		},
		"trust_path": {
			"id": "trust_path",
			"speaker": "informant",
			"text": "Good answer. The Lobbyist you defeated? He was just middle management. The real power lies higher up.",
			"emotion": "serious",
			"next_node": "reveal_conspiracy"
		},
		"identity_path": {
			"id": "identity_path",
			"speaker": "informant",
			"text": "Names don't matter anymore. I worked inside the system. When I learned what they were doing to the pond... I had to speak out. Now I'm in hiding.",
			"emotion": "worried",
			"next_node": "reveal_conspiracy"
		},
		"proof_path": {
			"id": "proof_path",
			"speaker": "informant",
			"text": "Fair enough. I can tell you where to find the encrypted emails. The ones that link the politicians directly to the CEO. Will that satisfy you?",
			"emotion": "neutral",
			"effects": {"unlock_hint": "hint_evidence_location_1"},
			"next_node": "reveal_conspiracy"
		},
		"reveal_conspiracy": {
			"id": "reveal_conspiracy",
			"speaker": "informant",
			"text": "The conspiracy goes deeper than you think. Politicians, corporations, even the media - all working together. The pond is just one target. There are others.",
			"emotion": "serious",
			"choices": [
				{
					"id": "ask_more",
					"text": "Tell me everything you know.",
					"next_node": "deep_lore"
				},
				{
					"id": "ask_help",
					"text": "How can you help me?",
					"next_node": "offer_help"
				}
			]
		},
		"deep_lore": {
			"id": "deep_lore",
			"speaker": "informant",
			"text": "Everything? That would take years. But I can tell you this: the CEO has a board meeting every Tuesday. That's when he's most vulnerable. And the contract - the one that binds them all - it's hidden in a bank vault. Box 237.",
			"emotion": "serious",
			"effects": {"complete_topic": "lobbyist_connections"},
			"next_node": "end"
		},
		"offer_help": {
			"id": "offer_help",
			"speaker": "informant",
			"text": "I can provide hints. Guidance. Information about weaknesses, secret locations, hidden evidence. But use them wisely - I can only help so much before they trace my signal.",
			"emotion": "worried",
			"effects": {"unlock_hints": true},
			"next_node": "end"
		},
		"end": {
			"id": "end",
			"speaker": "informant",
			"text": "Stay safe out there. And remember - they're always watching.",
			"emotion": "serious",
			"effects": {"end_dialogue": true}
		}
	},

	"lily_padsworth_intro": {
		"start": {
			"id": "start",
			"speaker": "informant",
			"text": "You actually took down the CEO? I've been investigating him for three years. This is incredible! Do you have the evidence?",
			"emotion": "happy",
			"choices": [
				{
					"id": "show_evidence",
					"text": "I have some documents and recordings.",
					"next_node": "examine_evidence",
					"conditions": {"has_ceo_evidence": true}
				},
				{
					"id": "need_help",
					"text": "I need help understanding what I've found.",
					"next_node": "journalist_help"
				},
				{
					"id": "who_are_you",
					"text": "You're a journalist?",
					"next_node": "identity"
				}
			]
		},
		"examine_evidence": {
			"id": "examine_evidence",
			"speaker": "informant",
			"text": "Let me see... Oh my god. This is it. This is the smoking gun. Board meeting minutes admitting to environmental violations. The CEO's own voice on tape. This is front-page material!",
			"emotion": "happy",
			"next_node": "publish_question"
		},
		"journalist_help": {
			"id": "journalist_help",
			"speaker": "informant",
			"text": "That's what I do - connect the dots. Corporate malfeasance is my specialty. Let me explain what you're looking at...",
			"emotion": "neutral",
			"next_node": "explain_conspiracy"
		},
		"identity": {
			"id": "identity",
			"speaker": "informant",
			"text": "Lily Padsworth, investigative journalist. Or I was, until my editor killed my story about the pond conspiracy. Corporate pressure. So I went independent. Now I publish the truth on my own terms.",
			"emotion": "serious",
			"next_node": "publish_question"
		},
		"explain_conspiracy": {
			"id": "explain_conspiracy",
			"speaker": "informant",
			"text": "The corporation needed permits to build on the wetlands. They paid off politicians through 'campaign contributions.' The politicians pressured regulators to approve the permits. The regulators looked the other way while the corporation dumped toxic waste. Everyone profits except the pond.",
			"emotion": "serious",
			"effects": {"complete_topic": "corporate_coverup"},
			"next_node": "publish_question"
		},
		"publish_question": {
			"id": "publish_question",
			"speaker": "informant",
			"text": "Here's what I can do: publish your evidence. Give you credit as an anonymous source. Bring this whole conspiracy into the public eye. But I need ALL the evidence. All seven data logs. Can you get them?",
			"emotion": "serious",
			"choices": [
				{
					"id": "accept_mission",
					"text": "I'll find every piece of evidence.",
					"next_node": "mission_accepted"
				},
				{
					"id": "ask_hints",
					"text": "Can you help me find the missing pieces?",
					"next_node": "offer_hints"
				}
			]
		},
		"mission_accepted": {
			"id": "mission_accepted",
			"speaker": "informant",
			"text": "That's the spirit. When you have all seven logs, come back to me. Together, we'll expose this conspiracy to the world.",
			"emotion": "happy",
			"effects": {"unlock_mission": "collect_all_evidence"},
			"next_node": "end"
		},
		"offer_hints": {
			"id": "offer_hints",
			"speaker": "informant",
			"text": "Of course. I've done extensive research. I know where some of the evidence is hidden. Let me mark some locations on your map...",
			"emotion": "neutral",
			"effects": {"unlock_hints": true},
			"next_node": "end"
		},
		"end": {
			"id": "end",
			"speaker": "informant",
			"text": "Good luck out there. The truth is on your side.",
			"emotion": "happy",
			"effects": {"end_dialogue": true}
		}
	}
}

var meta_progression: MetaProgression
var informant_manager: InformantManager
var current_tree: String = ""
var current_node: DialogueNode = null
var dialogue_history: Array[String] = []

func _ready() -> void:
	# Get singletons
	if has_node("/root/MetaProgression"):
		meta_progression = get_node("/root/MetaProgression")
	if has_node("/root/InformantManager"):
		informant_manager = get_node("/root/InformantManager")

## Start dialogue with informant on specific topic
func start_dialogue(informant_id: String, topic: String) -> bool:
	# Check if informant is unlocked
	if informant_manager and not informant_manager.is_informant_unlocked(informant_id):
		push_warning("[DialogueSystem] Informant not unlocked: " + informant_id)
		return false

	# Map topic to dialogue tree
	var tree_id := informant_id + "_" + topic
	if not DIALOGUE_TREES.has(tree_id):
		push_error("[DialogueSystem] Dialogue tree not found: " + tree_id)
		return false

	current_tree = tree_id
	dialogue_history.clear()

	# Start at first node
	_load_node("start")

	dialogue_started.emit(informant_id, topic)
	print("[DialogueSystem] Started dialogue: %s - %s" % [informant_id, topic])
	return true

## Load dialogue node
func _load_node(node_id: String) -> void:
	if not DIALOGUE_TREES.has(current_tree):
		push_error("[DialogueSystem] Current tree not found: " + current_tree)
		return

	var tree := DIALOGUE_TREES[current_tree]
	if not tree.has(node_id):
		push_error("[DialogueSystem] Node not found: %s in tree %s" % [node_id, current_tree])
		return

	current_node = DialogueNode.new(tree[node_id])
	dialogue_history.append(node_id)

	# Check conditions
	if not _check_conditions(current_node.conditions):
		# Skip to next node or end dialogue
		if current_node.next_node != "":
			_load_node(current_node.next_node)
		return

	# Apply effects
	_apply_effects(current_node.effects)

	# Display dialogue
	_display_node()

## Display current dialogue node
func _display_node() -> void:
	if not current_node:
		return

	# Filter available choices based on conditions
	var available_choices: Array[DialogueChoice] = []
	for choice in current_node.choices:
		if _check_conditions(choice.conditions):
			available_choices.append(choice)

	# Emit signal with dialogue line and choices
	dialogue_line_displayed.emit(current_node.speaker, current_node.text, available_choices)

	# Auto-advance if no choices
	if available_choices.is_empty() and current_node.next_node != "":
		# Add small delay for reading
		await get_tree().create_timer(2.0).timeout
		_load_node(current_node.next_node)

## Select dialogue choice
func select_choice(choice_id: String) -> void:
	if not current_node:
		return

	# Find choice
	var selected_choice: DialogueChoice = null
	for choice in current_node.choices:
		if choice.id == choice_id:
			selected_choice = choice
			break

	if not selected_choice:
		push_error("[DialogueSystem] Choice not found: " + choice_id)
		return

	# Apply choice effects
	_apply_effects(selected_choice.effects)

	dialogue_choice_selected.emit(choice_id)

	# Load next node
	if selected_choice.next_node != "":
		_load_node(selected_choice.next_node)

## Check dialogue conditions
func _check_conditions(conditions: Dictionary) -> bool:
	if conditions.is_empty():
		return true

	for condition_type in conditions:
		var value = conditions[condition_type]

		match condition_type:
			"has_ceo_evidence":
				if not meta_progression:
					return false
				var has_evidence := meta_progression.meta_state.evidence.boss_defeats.get("ceo", 0) > 0
				if has_evidence != value:
					return false

			"has_lobbyist_evidence":
				if not meta_progression:
					return false
				var has_evidence := meta_progression.meta_state.evidence.boss_defeats.get("lobbyist", 0) > 0
				if has_evidence != value:
					return false

			"evidence_count_min":
				if not meta_progression:
					return false
				if meta_progression.meta_state.evidence.unlocked_logs.size() < value:
					return false

			"dialogue_completed":
				if not informant_manager:
					return false
				var parts := (value as String).split(":")
				if parts.size() != 2:
					return false
				if not informant_manager.is_dialogue_completed(parts[0], parts[1]):
					return false

	return true

## Apply dialogue effects
func _apply_effects(effects: Dictionary) -> void:
	if effects.is_empty():
		return

	for effect_type in effects:
		var value = effects[effect_type]

		match effect_type:
			"unlock_hint":
				if informant_manager:
					informant_manager.receive_hint(value)

			"unlock_hints":
				# General hint unlock flag
				print("[DialogueSystem] Hints unlocked")

			"complete_topic":
				if informant_manager:
					# Extract informant ID from current tree
					var parts := current_tree.split("_")
					if parts.size() >= 2:
						var informant_id := parts[0] + "_" + parts[1]
						informant_manager.complete_dialogue_topic(informant_id, value)

			"unlock_mission":
				print("[DialogueSystem] Mission unlocked: " + str(value))

			"end_dialogue":
				_end_dialogue()

## End dialogue
func _end_dialogue() -> void:
	# Extract informant ID
	var informant_id := ""
	var parts := current_tree.split("_")
	if parts.size() >= 2:
		informant_id = parts[0] + "_" + parts[1]

	# Calculate rewards (if any)
	var rewards := {
		"experience": 0,
		"insights": dialogue_history.size()
	}

	dialogue_ended.emit(informant_id, rewards)
	print("[DialogueSystem] Dialogue ended: " + current_tree)

	current_tree = ""
	current_node = null
	dialogue_history.clear()

## Get current dialogue state
func get_current_state() -> Dictionary:
	if not current_node:
		return {}

	return {
		"tree": current_tree,
		"node": current_node.id,
		"speaker": current_node.speaker,
		"text": current_node.text,
		"emotion": current_node.emotion,
		"has_choices": current_node.choices.size() > 0
	}
