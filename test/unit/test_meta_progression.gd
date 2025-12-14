## test_meta_progression.gd - Unit tests for Epic-008 Meta-Progression System
extends GutTest

var meta_progression: MetaProgression
var evidence_manager: EvidenceManager
var informant_manager: InformantManager
var dialogue_system: DialogueSystem
var hint_system: HintSystem

const TEST_SAVE_PATH := "user://test_meta_progression.save"

func before_all():
	print("\n=== EPIC-008: Meta-Progression System Tests ===\n")

func before_each():
	# Create instances
	meta_progression = MetaProgression.new()
	evidence_manager = EvidenceManager.new()
	informant_manager = InformantManager.new()
	dialogue_system = DialogueSystem.new()
	hint_system = HintSystem.new()

	# Add to scene tree
	add_child_autofree(meta_progression)
	add_child_autofree(evidence_manager)
	add_child_autofree(informant_manager)
	add_child_autofree(dialogue_system)
	add_child_autofree(hint_system)

	# Override save path for testing
	meta_progression.SAVE_PATH = TEST_SAVE_PATH

	# Reset meta state
	meta_progression.reset_meta_progression()

func after_each():
	# Clean up test save file
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)

## ===========================
## META-001: Conspiracy Board State
## ===========================

func test_meta001_save_card_position():
	# Arrange
	var card_id := "politician_card"
	var position := Vector2(100, 200)

	# Act
	meta_progression.save_card_position(card_id, position)
	var retrieved_position := meta_progression.get_card_position(card_id)

	# Assert
	assert_eq(retrieved_position, position, "Card position should be saved and retrieved correctly")

func test_meta001_save_connection():
	# Arrange
	var from_id := "politician_card"
	var to_id := "lobbyist_card"
	var connection_type := "bribery"

	# Act
	meta_progression.save_connection(from_id, to_id, connection_type)
	var connections := meta_progression.get_connections()

	# Assert
	assert_eq(connections.size(), 1, "Should have one connection saved")
	assert_eq(connections[0].from, from_id, "Connection from ID should match")
	assert_eq(connections[0].to, to_id, "Connection to ID should match")
	assert_eq(connections[0].type, connection_type, "Connection type should match")

func test_meta001_remove_connection():
	# Arrange
	meta_progression.save_connection("card1", "card2", "link")

	# Act
	meta_progression.remove_connection("card1", "card2")
	var connections := meta_progression.get_connections()

	# Assert
	assert_eq(connections.size(), 0, "Connection should be removed")

func test_meta001_discoveries():
	# Arrange
	var discovery_id := "toxic_dumping"

	# Act
	meta_progression.add_discovery(discovery_id)

	# Assert
	assert_true(meta_progression.has_discovery(discovery_id), "Discovery should be tracked")
	assert_false(meta_progression.has_discovery("nonexistent"), "Nonexistent discovery should return false")

func test_meta001_card_notes():
	# Arrange
	var card_id := "ceo_card"
	var note := "Suspicious activity on Tuesdays"

	# Act
	meta_progression.save_card_note(card_id, note)
	var retrieved_note := meta_progression.get_card_note(card_id)

	# Assert
	assert_eq(retrieved_note, note, "Card note should be saved and retrieved")

func test_meta001_persistence():
	# Arrange
	meta_progression.save_card_position("test_card", Vector2(50, 50))
	meta_progression.add_discovery("test_discovery")

	# Act
	var saved := meta_progression.save_meta_state()
	meta_progression.reset_meta_progression()
	var loaded := meta_progression.load_meta_state()

	# Assert
	assert_true(saved, "Should save successfully")
	assert_true(loaded, "Should load successfully")
	assert_true(meta_progression.has_discovery("test_discovery"), "Discovery should persist")

## ===========================
## META-002: Evidence System
## ===========================

func test_meta002_boss_defeat_lobbyist():
	# Act
	var dropped_evidence := evidence_manager.on_boss_defeated("lobbyist")

	# Assert
	assert_eq(dropped_evidence.size(), 2, "Lobbyist should drop 2 evidence pieces")
	assert_eq(dropped_evidence[0].id, "log_001_lobby_emails", "Should drop lobby emails")
	assert_eq(dropped_evidence[1].id, "log_002_campaign_finance", "Should drop campaign finance records")

func test_meta002_boss_defeat_ceo():
	# Act
	var dropped_evidence := evidence_manager.on_boss_defeated("ceo")

	# Assert
	assert_eq(dropped_evidence.size(), 2, "CEO should drop 2 evidence pieces")
	assert_eq(dropped_evidence[0].id, "log_003_board_minutes", "Should drop board minutes")
	assert_eq(dropped_evidence[1].id, "log_004_ceo_recording", "Should drop CEO recording")

func test_meta002_unlock_evidence():
	# Arrange
	var evidence_data := {
		"id": "test_evidence",
		"title": "Test Evidence",
		"description": "Test description",
		"category": "document",
		"unlock_source": "exploration",
		"conspiracy_connections": [],
		"lore_text": "Test lore"
	}

	# Act
	var evidence := evidence_manager.unlock_evidence("test_evidence", evidence_data)

	# Assert
	assert_not_null(evidence, "Should unlock evidence")
	assert_true(evidence_manager.is_evidence_unlocked("test_evidence"), "Evidence should be marked as unlocked")

func test_meta002_evidence_collection_progress():
	# Act
	evidence_manager.on_boss_defeated("lobbyist")
	var progress := evidence_manager.get_collection_progress()

	# Assert
	assert_eq(progress.unlocked, 2, "Should have 2 pieces unlocked")
	assert_eq(progress.total, 7, "Total should be 7")
	assert_almost_eq(progress.percentage, 28.571, 0.01, "Should be approximately 28.57%")

## ===========================
## META-003: Deep Croak Informant
## ===========================

func test_meta003_unlock_deep_croak():
	# Arrange - Defeat lobbyist first
	evidence_manager.on_boss_defeated("lobbyist")

	# Act
	var unlocked := informant_manager.unlock_informant("deep_croak")

	# Assert
	assert_true(unlocked, "Deep Croak should unlock after lobbyist defeat")
	assert_true(informant_manager.is_informant_unlocked("deep_croak"), "Deep Croak should be marked as unlocked")

func test_meta003_deep_croak_hints():
	# Arrange
	evidence_manager.on_boss_defeated("lobbyist")
	informant_manager.unlock_informant("deep_croak")

	# Act
	var available_hints := informant_manager.get_available_hints("deep_croak")

	# Assert
	assert_eq(available_hints.size(), 3, "Deep Croak should have 3 hints available")
	assert_has(available_hints, "hint_lobbyist_weakness", "Should include lobbyist weakness hint")

## ===========================
## META-004: Lily Padsworth Informant
## ===========================

func test_meta004_unlock_lily_padsworth():
	# Arrange - Defeat CEO first
	evidence_manager.on_boss_defeated("ceo")

	# Act
	var unlocked := informant_manager.unlock_informant("lily_padsworth")

	# Assert
	assert_true(unlocked, "Lily Padsworth should unlock after CEO defeat")
	assert_true(informant_manager.is_informant_unlocked("lily_padsworth"), "Lily Padsworth should be marked as unlocked")

func test_meta004_lily_hints():
	# Arrange
	evidence_manager.on_boss_defeated("ceo")
	informant_manager.unlock_informant("lily_padsworth")

	# Act
	var available_hints := informant_manager.get_available_hints("lily_padsworth")

	# Assert
	assert_eq(available_hints.size(), 3, "Lily should have 3 hints available")
	assert_has(available_hints, "hint_ceo_weakness", "Should include CEO weakness hint")

## ===========================
## META-005: Dialogue System
## ===========================

func test_meta005_start_dialogue():
	# Arrange
	evidence_manager.on_boss_defeated("lobbyist")
	informant_manager.unlock_informant("deep_croak")

	# Act
	var started := dialogue_system.start_dialogue("deep_croak", "intro")

	# Assert
	assert_true(started, "Should start dialogue")
	var state := dialogue_system.get_current_state()
	assert_eq(state.tree, "deep_croak_intro", "Should load correct dialogue tree")

func test_meta005_dialogue_choices():
	# Arrange
	evidence_manager.on_boss_defeated("lobbyist")
	informant_manager.unlock_informant("deep_croak")
	dialogue_system.start_dialogue("deep_croak", "intro")

	# Act
	var state := dialogue_system.get_current_state()

	# Assert
	assert_true(state.has_choices, "First node should have choices")
	assert_eq(state.node, "start", "Should be at start node")

func test_meta005_dialogue_progression():
	# Arrange
	evidence_manager.on_boss_defeated("lobbyist")
	informant_manager.unlock_informant("deep_croak")
	dialogue_system.start_dialogue("deep_croak", "intro")

	# Act
	dialogue_system.select_choice("trust_me")
	var state := dialogue_system.get_current_state()

	# Assert
	assert_eq(state.node, "trust_path", "Should progress to trust path")

## ===========================
## META-006: Hint System
## ===========================

func test_meta006_hint_availability():
	# Assert
	assert_eq(hint_system.get_hints_remaining(), 3, "Should start with 3 hints per run")
	assert_eq(hint_system.get_max_hints(), 3, "Max hints should be 3")

func test_meta006_use_hint():
	# Arrange
	evidence_manager.on_boss_defeated("lobbyist")
	informant_manager.unlock_informant("deep_croak")

	# Act
	var hint := hint_system.use_hint("hint_lobbyist_weakness")

	# Assert
	assert_not_null(hint, "Should return hint data")
	assert_eq(hint_system.get_hints_remaining(), 2, "Should have 2 hints remaining")

func test_meta006_hint_depletion():
	# Arrange
	evidence_manager.on_boss_defeated("lobbyist")
	informant_manager.unlock_informant("deep_croak")

	# Act - Use all 3 hints
	hint_system.use_hint()
	await wait_seconds(1)
	hint_system.use_hint()
	await wait_seconds(1)
	hint_system.use_hint()

	# Assert
	assert_eq(hint_system.get_hints_remaining(), 0, "Should have no hints remaining")
	assert_false(hint_system.is_hint_available(), "Should not be available when depleted")

func test_meta006_contextual_hints():
	# Arrange
	evidence_manager.on_boss_defeated("lobbyist")
	informant_manager.unlock_informant("deep_croak")

	# Act
	var preview := hint_system.preview_next_hint()

	# Assert
	assert_not_null(preview, "Should provide contextual hint")
	assert_true(preview.has("text"), "Hint should have text")

## ===========================
## META-007: Run Rewards
## ===========================

func test_meta007_run_start():
	# Act
	meta_progression.start_run()
	var stats := meta_progression.get_run_stats()

	# Assert
	assert_eq(stats.total_runs, 1, "Should increment total runs")

func test_meta007_death_rewards():
	# Arrange
	meta_progression.start_run()

	# Act
	var rewards := meta_progression.end_run_death()

	# Assert
	assert_gt(rewards, 0, "Should receive rewards on death")
	assert_true(rewards < 200, "Death rewards should be reduced (50%)")

func test_meta007_victory_rewards():
	# Arrange
	meta_progression.start_run()

	# Act
	var rewards := meta_progression.end_run_victory()
	var stats := meta_progression.get_run_stats()

	# Assert
	assert_gt(rewards, 100, "Victory rewards should be higher (150%)")
	assert_eq(stats.successful_runs, 1, "Should increment successful runs")

## ===========================
## META-008: Ending Unlock
## ===========================

func test_meta008_ending_locked_initially():
	# Act
	var unlocked := meta_progression.check_ending_unlock()

	# Assert
	assert_false(unlocked, "Ending should be locked initially")

func test_meta008_ending_requires_all_logs():
	# Arrange - Defeat both bosses
	evidence_manager.on_boss_defeated("lobbyist")
	evidence_manager.on_boss_defeated("ceo")

	# Act
	var unlocked := meta_progression.check_ending_unlock()

	# Assert
	assert_false(unlocked, "Ending should still be locked without all 7 logs")

func test_meta008_ending_unlock_condition():
	# Arrange - Collect all evidence and defeat both bosses
	evidence_manager.on_boss_defeated("lobbyist")  # 2 logs
	evidence_manager.on_boss_defeated("ceo")  # 2 more logs = 4 total

	# Add exploration evidence (3 more = 7 total)
	for evidence_data in evidence_manager.EXPLORATION_EVIDENCE:
		evidence_manager.unlock_evidence(evidence_data.id, evidence_data)

	# Act
	var unlocked := meta_progression.check_ending_unlock()
	var status := meta_progression.get_unlock_status()

	# Assert
	assert_true(status.all_logs_found, "All 7 logs should be found")
	assert_true(status.all_bosses_defeated, "Both bosses should be defeated")
	assert_true(unlocked, "Ending should be unlocked")
	assert_eq(status.logs_collected, 7, "Should have all 7 logs")

## ===========================
## Integration Tests
## ===========================

func test_integration_full_progression():
	# Simulate complete progression
	meta_progression.start_run()

	# Defeat lobbyist
	evidence_manager.on_boss_defeated("lobbyist")
	informant_manager.unlock_informant("deep_croak")

	# Use hints
	var hint1 := hint_system.use_hint()
	assert_not_null(hint1, "Should get first hint")

	# Defeat CEO
	evidence_manager.on_boss_defeated("ceo")
	informant_manager.unlock_informant("lily_padsworth")

	# Collect exploration evidence
	for evidence_data in evidence_manager.EXPLORATION_EVIDENCE:
		evidence_manager.unlock_evidence(evidence_data.id, evidence_data)

	# Check ending unlock
	var ending_unlocked := meta_progression.check_ending_unlock()

	# End run victoriously
	var rewards := meta_progression.end_run_victory()

	# Assert complete progression
	assert_true(ending_unlocked, "Full progression should unlock ending")
	assert_gt(rewards, 0, "Should receive victory rewards")
	assert_true(informant_manager.is_informant_unlocked("deep_croak"), "Deep Croak should be unlocked")
	assert_true(informant_manager.is_informant_unlocked("lily_padsworth"), "Lily Padsworth should be unlocked")

func after_all():
	print("\n=== All META-008 Tests Complete ===")
