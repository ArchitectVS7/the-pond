extends GutTest

var ceo: BossCEO

func before_each() -> void:
	ceo = BossCEO.new()
	ceo.intro_duration = 0.1
	ceo.phase_transition_duration = 0.1
	add_child(ceo)

func after_each() -> void:
	if ceo:
		ceo.queue_free()
	ceo = null

func test_ceo_has_correct_hp() -> void:
	assert_eq(ceo.total_hp, 150, "CEO should have 150 HP (higher than Lobbyist)")

func test_ceo_has_dialogue() -> void:
	assert_true(ceo.dialogue_data.has("intro"), "CEO should have intro dialogue")
	assert_true(ceo.dialogue_data.has("phase2"), "CEO should have phase 2 dialogue")
	assert_true(ceo.dialogue_data.has("phase3"), "CEO should have phase 3 dialogue")
	assert_true(ceo.dialogue_data.has("defeat"), "CEO should have defeat dialogue")

func test_ceo_evidence_id() -> void:
	assert_eq(ceo.evidence_id, "ceo_evidence", "CEO should have correct evidence ID")

func test_ceo_wall_count() -> void:
	assert_eq(ceo.ceo_p1_wall_count, 5, "Phase 1 should fire 5 bullet walls")

func test_ceo_chaos_count() -> void:
	assert_eq(ceo.ceo_p3_chaos_count, 8, "Phase 3 should fire 8 chaos bullets")

func test_ceo_dialogue_on_phase_change() -> void:
	watch_signals(ceo)
	ceo._on_phase_changed(2)
	assert_signal_emitted(ceo, "dialogue_triggered", "Should emit dialogue on phase change")

func test_ceo_scaling_affects_bullet_speed() -> void:
	var initial_speed = ceo.ceo_p1_wall_speed
	ceo.apply_difficulty_scaling(5, false)
	assert_gt(ceo.ceo_p1_wall_speed, initial_speed, "Scaling should increase bullet speed")

func test_ceo_has_homing_strength() -> void:
	assert_gt(ceo.ceo_p2_homing_strength, 0, "CEO should have homing bullet strength")

func test_ceo_is_harder_than_lobbyist() -> void:
	var lobbyist_hp = 100
	assert_gt(ceo.total_hp, lobbyist_hp, "CEO should have more HP than Lobbyist")
