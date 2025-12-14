## hint_system.gd - META-006: Hint System
## Manages hint availability and usage (3 hints per run)

extends Node
class_name HintSystem

signal hint_available_changed(hints_remaining: int)
signal hint_used(hint_id: String, hint_text: String, hints_remaining: int)
signal hint_cooldown_started(cooldown_seconds: float)
signal all_hints_depleted

const MAX_HINTS_PER_RUN := 3
const HINT_COOLDOWN_SECONDS := 60.0  # 1 minute cooldown between hints

var meta_progression: MetaProgression
var informant_manager: InformantManager

var hints_remaining: int = MAX_HINTS_PER_RUN
var hints_used_this_run: Array[String] = []
var last_hint_time: float = 0.0
var cooldown_active: bool = false

func _ready() -> void:
	# Get singletons
	if has_node("/root/MetaProgression"):
		meta_progression = get_node("/root/MetaProgression")
	if has_node("/root/InformantManager"):
		informant_manager = get_node("/root/InformantManager")

	# Initialize hints for current run
	_reset_hints_for_run()

## Reset hints when starting new run
func _reset_hints_for_run() -> void:
	hints_remaining = MAX_HINTS_PER_RUN
	hints_used_this_run.clear()
	last_hint_time = 0.0
	cooldown_active = false

	hint_available_changed.emit(hints_remaining)
	print("[HintSystem] Hints reset: %d available" % hints_remaining)

## Use a hint
func use_hint(hint_id: String = "") -> Dictionary:
	# Check if hints available
	if hints_remaining <= 0:
		push_warning("[HintSystem] No hints remaining")
		all_hints_depleted.emit()
		return {}

	# Check cooldown
	var current_time := Time.get_ticks_msec() / 1000.0
	if cooldown_active and (current_time - last_hint_time) < HINT_COOLDOWN_SECONDS:
		var remaining_cooldown := HINT_COOLDOWN_SECONDS - (current_time - last_hint_time)
		push_warning("[HintSystem] Hint on cooldown: %.1f seconds remaining" % remaining_cooldown)
		return {}

	# Get hint from informant manager
	var hint_data: Dictionary = {}

	if hint_id != "":
		# Specific hint requested
		if informant_manager:
			hint_data = informant_manager.get_hint(hint_id)
	else:
		# Get contextual hint based on game state
		hint_data = _get_contextual_hint()

	if hint_data.is_empty():
		push_warning("[HintSystem] No hint available")
		return {}

	# Use hint
	hints_remaining -= 1
	hints_used_this_run.append(hint_data.id)
	last_hint_time = current_time

	# Start cooldown if hints still remain
	if hints_remaining > 0:
		cooldown_active = true
		hint_cooldown_started.emit(HINT_COOLDOWN_SECONDS)

	# Update statistics
	if meta_progression:
		meta_progression.meta_state.statistics.hints_used += 1

	hint_used.emit(hint_data.id, hint_data.text, hints_remaining)
	hint_available_changed.emit(hints_remaining)

	print("[HintSystem] Hint used: %s (%d remaining)" % [hint_data.id, hints_remaining])

	if hints_remaining == 0:
		all_hints_depleted.emit()

	return hint_data

## Get contextual hint based on current game state
func _get_contextual_hint() -> Dictionary:
	if not informant_manager or not meta_progression:
		return {}

	# Priority order for hints:
	# 1. Boss strategy hints if boss not defeated
	# 2. Evidence location hints if evidence not collected
	# 3. Exploration hints for secret areas

	# Check boss status
	var lobbyist_defeated := meta_progression.meta_state.evidence.boss_defeats.get("lobbyist", 0) > 0
	var ceo_defeated := meta_progression.meta_state.evidence.boss_defeats.get("ceo", 0) > 0

	# Suggest lobbyist strategy if not defeated
	if not lobbyist_defeated:
		var hint := informant_manager.get_hint("hint_lobbyist_weakness")
		if not hint.is_empty() and hint.id not in hints_used_this_run:
			return hint

	# Suggest CEO strategy if lobbyist defeated but CEO not defeated
	if lobbyist_defeated and not ceo_defeated:
		var hint := informant_manager.get_hint("hint_ceo_weakness")
		if not hint.is_empty() and hint.id not in hints_used_this_run:
			return hint

	# Check evidence collection
	var evidence_count := meta_progression.meta_state.evidence.unlocked_logs.size()

	# Suggest evidence locations if not all collected
	if evidence_count < 7:
		# Try evidence hints first
		for hint_id in ["hint_evidence_location_1", "hint_evidence_location_2"]:
			if hint_id not in hints_used_this_run:
				var hint := informant_manager.get_hint(hint_id)
				if not hint.is_empty():
					return hint

		# Then secret area hints
		for hint_id in ["hint_secret_area_1", "hint_secret_area_2"]:
			if hint_id not in hints_used_this_run:
				var hint := informant_manager.get_hint(hint_id)
				if not hint.is_empty():
					return hint

	# Fallback: get any available hint from unlocked informants
	var all_informants := informant_manager.get_all_unlocked_informants()
	for informant in all_informants:
		var available_hints := informant_manager.get_available_hints(informant.id)
		for hint_id in available_hints:
			if hint_id not in hints_used_this_run:
				var hint := informant_manager.get_hint(hint_id)
				if not hint.is_empty():
					return hint

	return {}

## Get hints remaining
func get_hints_remaining() -> int:
	return hints_remaining

## Get max hints per run
func get_max_hints() -> int:
	return MAX_HINTS_PER_RUN

## Check if hint available (not on cooldown)
func is_hint_available() -> bool:
	if hints_remaining <= 0:
		return false

	if not cooldown_active:
		return true

	var current_time := Time.get_ticks_msec() / 1000.0
	return (current_time - last_hint_time) >= HINT_COOLDOWN_SECONDS

## Get remaining cooldown time
func get_cooldown_remaining() -> float:
	if not cooldown_active:
		return 0.0

	var current_time := Time.get_ticks_msec() / 1000.0
	var remaining := HINT_COOLDOWN_SECONDS - (current_time - last_hint_time)
	return max(0.0, remaining)

## Get hint usage statistics
func get_hint_stats() -> Dictionary:
	return {
		"hints_remaining": hints_remaining,
		"hints_used_this_run": hints_used_this_run.size(),
		"max_hints_per_run": MAX_HINTS_PER_RUN,
		"cooldown_active": cooldown_active,
		"cooldown_remaining": get_cooldown_remaining(),
		"total_hints_used_all_time": meta_progression.meta_state.statistics.hints_used if meta_progression else 0
	}

## Get all available hint categories
func get_hint_categories() -> Array[String]:
	var categories: Array[String] = []

	if not informant_manager:
		return categories

	# Get all unlocked informants
	var informants := informant_manager.get_all_unlocked_informants()
	for informant in informants:
		for hint_id in informant.hints_available:
			var hint := informant_manager.get_hint(hint_id)
			if not hint.is_empty():
				var category: String = hint.category
				if category not in categories:
					categories.append(category)

	return categories

## Get hints by category
func get_hints_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	if not informant_manager:
		return result

	var informants := informant_manager.get_all_unlocked_informants()
	for informant in informants:
		for hint_id in informant.hints_available:
			var hint := informant_manager.get_hint(hint_id)
			if not hint.is_empty() and hint.category == category:
				result.append(hint)

	return result

## Preview next contextual hint without using it
func preview_next_hint() -> Dictionary:
	return _get_contextual_hint()
