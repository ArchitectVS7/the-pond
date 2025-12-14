extends GutTest

var lobbyist: BossLobbyist

func before_each() -> void:
	lobbyist = BossLobbyist.new()
	lobbyist.intro_duration = 0.1
	lobbyist.phase_transition_duration = 0.1
	add_child(lobbyist)

func after_each() -> void:
	if lobbyist:
		lobbyist.queue_free()
	lobbyist = null

func test_lobbyist_has_correct_hp() -> void:
	assert_eq(lobbyist.total_hp, 100, "Lobbyist should have 100 HP")

func test_lobbyist_has_dialogue() -> void:
	assert_true(lobbyist.dialogue_data.has("intro"), "Lobbyist should have intro dialogue")
	assert_true(lobbyist.dialogue_data.has("phase2"), "Lobbyist should have phase 2 dialogue")
	assert_true(lobbyist.dialogue_data.has("phase3"), "Lobbyist should have phase 3 dialogue")
	assert_true(lobbyist.dialogue_data.has("defeat"), "Lobbyist should have defeat dialogue")

func test_lobbyist_evidence_id() -> void:
	assert_eq(lobbyist.evidence_id, "lobbyist_evidence", "Lobbyist should have correct evidence ID")

func test_lobbyist_cooldown_phase1() -> void:
	lobbyist.current_phase = 1
	var cooldown = lobbyist._get_current_cooldown()
	assert_eq(cooldown, lobbyist.p1_cooldown, "Phase 1 should use p1_cooldown")

func test_lobbyist_cooldown_phase2() -> void:
	lobbyist.current_phase = 2
	var cooldown = lobbyist._get_current_cooldown()
	assert_eq(cooldown, lobbyist.p2_cooldown, "Phase 2 should use p2_cooldown")

func test_lobbyist_cooldown_phase3() -> void:
	lobbyist.current_phase = 3
	var cooldown = lobbyist._get_current_cooldown()
	assert_eq(lobbyist._get_current_cooldown(), lobbyist.p3_cooldown, "Phase 3 should use p3_cooldown")

func test_lobbyist_dialogue_on_phase_change() -> void:
	watch_signals(lobbyist)
	lobbyist._on_phase_changed(2)
	assert_signal_emitted(lobbyist, "dialogue_triggered", "Should emit dialogue on phase change")

func test_lobbyist_scaling_affects_bullet_speed() -> void:
	var initial_speed = lobbyist.p1_bullet_speed
	lobbyist.apply_difficulty_scaling(5, false)
	assert_gt(lobbyist.p1_bullet_speed, initial_speed, "Scaling should increase bullet speed")

func test_lobbyist_radial_count() -> void:
	assert_eq(lobbyist.p2_radial_count, 8, "Phase 2 should fire 8 radial bullets")
