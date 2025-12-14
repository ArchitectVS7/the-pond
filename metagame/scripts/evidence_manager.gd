## evidence_manager.gd - META-002: Evidence Unlock System
## Manages evidence collection, boss drops, and data log unlocks

extends Node
class_name EvidenceManager

signal evidence_unlocked(evidence_id: String, evidence_data: Dictionary)
signal boss_defeated(boss_name: String, evidence_dropped: Array)
signal all_evidence_collected

## Evidence piece resource definition
class EvidencePiece:
	var id: String
	var title: String
	var description: String
	var category: String  # "email", "document", "recording", "photo"
	var unlock_source: String  # "lobbyist", "ceo", "exploration", "secret"
	var conspiracy_connections: Array[String]  # IDs of related conspiracy cards
	var lore_text: String
	var unlock_timestamp: float

	func _init(data: Dictionary) -> void:
		id = data.get("id", "")
		title = data.get("title", "Unknown Evidence")
		description = data.get("description", "")
		category = data.get("category", "document")
		unlock_source = data.get("unlock_source", "exploration")
		conspiracy_connections = data.get("conspiracy_connections", [])
		lore_text = data.get("lore_text", "")
		unlock_timestamp = Time.get_unix_time_from_system()

## Boss drop tables
const BOSS_DROPS := {
	"lobbyist": [
		{
			"id": "log_001_lobby_emails",
			"title": "Lobbying Correspondence",
			"description": "Encrypted emails between The Lobbyist and government officials",
			"category": "email",
			"unlock_source": "lobbyist",
			"conspiracy_connections": ["politician", "regulation", "permits"],
			"lore_text": "These emails reveal systematic bribery to fast-track construction permits in protected wetlands."
		},
		{
			"id": "log_002_campaign_finance",
			"title": "Campaign Finance Records",
			"description": "Detailed records of political donations and favors",
			"category": "document",
			"unlock_source": "lobbyist",
			"conspiracy_connections": ["politician", "lobbyist", "money"],
			"lore_text": "Follow the money trail - millions in 'campaign contributions' tied to specific policy changes."
		}
	],
	"ceo": [
		{
			"id": "log_003_board_minutes",
			"title": "Executive Board Minutes",
			"description": "Secret board meeting discussing environmental violations",
			"category": "document",
			"unlock_source": "ceo",
			"conspiracy_connections": ["ceo", "pollution", "coverup"],
			"lore_text": "The board knowingly approved dumping toxic waste, prioritizing profits over ecosystem safety."
		},
		{
			"id": "log_004_ceo_recording",
			"title": "CEO Private Recording",
			"description": "Audio of CEO admitting to conspiracy",
			"category": "recording",
			"unlock_source": "ceo",
			"conspiracy_connections": ["ceo", "conspiracy", "truth"],
			"lore_text": "In his own words: 'We own the regulators. The pond is just collateral damage for progress.'"
		}
	]
}

## Exploration evidence (found in secret areas)
const EXPLORATION_EVIDENCE := [
	{
		"id": "log_005_scientist_notes",
		"title": "Researcher's Field Notes",
		"description": "Environmental scientist's observations before disappearing",
		"category": "document",
		"unlock_source": "exploration",
		"conspiracy_connections": ["science", "disappearance", "evidence"],
		"lore_text": "Dr. Marsh documented unprecedented pollution levels. She vanished before publishing her findings."
	},
	{
		"id": "log_006_whistleblower_photo",
		"title": "Midnight Dumping Photo",
		"description": "Grainy photo of illegal waste disposal",
		"category": "photo",
		"unlock_source": "exploration",
		"conspiracy_connections": ["pollution", "illegal", "coverup"],
		"lore_text": "This photo, taken at 3 AM, shows corporate trucks dumping barrels into the pond's tributaries."
	},
	{
		"id": "log_007_contract",
		"title": "Redacted Contract",
		"description": "Partially destroyed contract revealing the full conspiracy",
		"category": "document",
		"unlock_source": "secret",
		"conspiracy_connections": ["all"],
		"lore_text": "The smoking gun: a contract binding politicians, corporations, and regulators in systematic destruction."
	}
]

var meta_progression: MetaProgression
var unlocked_evidence: Dictionary = {}  # {evidence_id: EvidencePiece}

func _ready() -> void:
	# Get meta-progression singleton
	if has_node("/root/MetaProgression"):
		meta_progression = get_node("/root/MetaProgression")

	# Load previously unlocked evidence
	_load_unlocked_evidence()

## Load evidence from meta-progression state
func _load_unlocked_evidence() -> void:
	if not meta_progression:
		return

	for log_id in meta_progression.meta_state.evidence.unlocked_logs:
		# Find evidence data
		var evidence_data := _find_evidence_data(log_id)
		if evidence_data.is_empty():
			continue

		var evidence := EvidencePiece.new(evidence_data)
		unlocked_evidence[log_id] = evidence

## Find evidence data by ID
func _find_evidence_data(evidence_id: String) -> Dictionary:
	# Check boss drops
	for boss in BOSS_DROPS:
		for evidence in BOSS_DROPS[boss]:
			if evidence.id == evidence_id:
				return evidence

	# Check exploration evidence
	for evidence in EXPLORATION_EVIDENCE:
		if evidence.id == evidence_id:
			return evidence

	return {}

## Handle boss defeat and drop evidence
func on_boss_defeated(boss_name: String) -> Array[EvidencePiece]:
	var dropped_evidence: Array[EvidencePiece] = []

	if not BOSS_DROPS.has(boss_name):
		push_warning("[EvidenceManager] Unknown boss: " + boss_name)
		return dropped_evidence

	# Update boss defeat count
	if meta_progression:
		if not meta_progression.meta_state.evidence.boss_defeats.has(boss_name):
			meta_progression.meta_state.evidence.boss_defeats[boss_name] = 0
		meta_progression.meta_state.evidence.boss_defeats[boss_name] += 1

	# Drop all evidence for this boss
	for evidence_data in BOSS_DROPS[boss_name]:
		var evidence := unlock_evidence(evidence_data.id, evidence_data)
		if evidence:
			dropped_evidence.append(evidence)

	# Check for informant unlocks
	_check_informant_unlocks(boss_name)

	boss_defeated.emit(boss_name, dropped_evidence.map(func(e): return e.id))
	print("[EvidenceManager] Boss defeated: %s, dropped %d evidence pieces" % [boss_name, dropped_evidence.size()])

	return dropped_evidence

## Unlock evidence piece
func unlock_evidence(evidence_id: String, evidence_data: Dictionary = {}) -> EvidencePiece:
	# Check if already unlocked
	if unlocked_evidence.has(evidence_id):
		print("[EvidenceManager] Evidence already unlocked: " + evidence_id)
		return unlocked_evidence[evidence_id]

	# Get evidence data if not provided
	if evidence_data.is_empty():
		evidence_data = _find_evidence_data(evidence_id)
		if evidence_data.is_empty():
			push_error("[EvidenceManager] Evidence not found: " + evidence_id)
			return null

	# Create evidence piece
	var evidence := EvidencePiece.new(evidence_data)
	unlocked_evidence[evidence_id] = evidence

	# Update meta-progression
	if meta_progression:
		if evidence_id not in meta_progression.meta_state.evidence.unlocked_logs:
			meta_progression.meta_state.evidence.unlocked_logs.append(evidence_id)
			meta_progression.meta_state.evidence.total_evidence_pieces += 1
			meta_progression.save_meta_state()

		# Add to current run evidence
		if evidence_id not in meta_progression.current_session.evidence_this_run:
			meta_progression.current_session.evidence_this_run.append(evidence_id)

		# Check ending unlock condition
		meta_progression.check_ending_unlock()

	evidence_unlocked.emit(evidence_id, evidence_data)
	print("[EvidenceManager] Evidence unlocked: " + evidence.title)

	# Check if all evidence collected
	_check_all_evidence_collected()

	return evidence

## Check if informants should be unlocked
func _check_informant_unlocks(boss_name: String) -> void:
	if not meta_progression:
		return

	var informant_manager = get_node_or_null("/root/InformantManager")
	if not informant_manager:
		return

	match boss_name:
		"lobbyist":
			# Unlock Deep Croak (Whistleblower) after defeating Lobbyist
			informant_manager.unlock_informant("deep_croak")
		"ceo":
			# Unlock Lily Padsworth (Journalist) after defeating CEO
			informant_manager.unlock_informant("lily_padsworth")

## Check if all evidence has been collected
func _check_all_evidence_collected() -> void:
	if not meta_progression:
		return

	var total_evidence := 7  # 2 from lobbyist + 2 from CEO + 3 exploration
	if unlocked_evidence.size() >= total_evidence:
		all_evidence_collected.emit()
		print("[EvidenceManager] ALL EVIDENCE COLLECTED!")

## Get evidence by ID
func get_evidence(evidence_id: String) -> EvidencePiece:
	return unlocked_evidence.get(evidence_id)

## Check if evidence is unlocked
func is_evidence_unlocked(evidence_id: String) -> bool:
	return unlocked_evidence.has(evidence_id)

## Get all unlocked evidence
func get_all_unlocked_evidence() -> Array[EvidencePiece]:
	var result: Array[EvidencePiece] = []
	result.assign(unlocked_evidence.values())
	return result

## Get evidence by category
func get_evidence_by_category(category: String) -> Array[EvidencePiece]:
	var result: Array[EvidencePiece] = []
	for evidence in unlocked_evidence.values():
		if evidence.category == category:
			result.append(evidence)
	return result

## Get evidence by unlock source
func get_evidence_by_source(source: String) -> Array[EvidencePiece]:
	var result: Array[EvidencePiece] = []
	for evidence in unlocked_evidence.values():
		if evidence.unlock_source == source:
			result.append(evidence)
	return result

## Get evidence connected to conspiracy card
func get_evidence_for_card(card_id: String) -> Array[EvidencePiece]:
	var result: Array[EvidencePiece] = []
	for evidence in unlocked_evidence.values():
		if card_id in evidence.conspiracy_connections:
			result.append(evidence)
	return result

## Get collection progress
func get_collection_progress() -> Dictionary:
	var total := 7
	var unlocked := unlocked_evidence.size()

	return {
		"unlocked": unlocked,
		"total": total,
		"percentage": (float(unlocked) / total) * 100.0,
		"remaining": total - unlocked,
		"by_source": {
			"lobbyist": get_evidence_by_source("lobbyist").size(),
			"ceo": get_evidence_by_source("ceo").size(),
			"exploration": get_evidence_by_source("exploration").size(),
			"secret": get_evidence_by_source("secret").size()
		}
	}
