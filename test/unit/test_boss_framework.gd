extends GutTest

var boss: BossBase
var boss_scene_path = "res://combat/scripts/boss_base.gd"

func before_each() -> void:
	boss = BossBase.new()
	boss.total_hp = 100
	boss.intro_duration = 0.1  # Speed up tests
	boss.phase_transition_duration = 0.1
	add_child(boss)

func after_each() -> void:
	if boss:
		boss.queue_free()
	boss = null

func test_boss_starts_idle() -> void:
	assert_eq(boss.current_state, BossBase.BossState.IDLE, "Boss should start in IDLE state")

func test_boss_initial_hp() -> void:
	assert_eq(boss.current_hp, 100, "Boss should start with full HP")

func test_boss_starts_invulnerable() -> void:
	assert_true(boss.is_invulnerable, "Boss should start invulnerable")

func test_boss_transitions_to_phase2() -> void:
	boss.current_phase = 1
	boss.is_invulnerable = false
	boss.current_hp = 65  # Below 66%
	boss._check_phase_transition()
	await wait_frames(1)
	assert_eq(boss.current_phase, 2, "Boss should transition to phase 2 at 66% HP")

func test_boss_transitions_to_phase3() -> void:
	boss.current_phase = 2
	boss.is_invulnerable = false
	boss.current_hp = 32  # Below 33%
	boss._check_phase_transition()
	await wait_frames(1)
	assert_eq(boss.current_phase, 3, "Boss should transition to phase 3 at 33% HP")

func test_boss_defeated_at_zero_hp() -> void:
	boss.is_invulnerable = false
	boss.current_phase = 1
	boss.take_damage(100)
	await wait_frames(1)
	assert_eq(boss.current_state, BossBase.BossState.DEFEATED, "Boss should be defeated at 0 HP")

func test_invulnerable_blocks_damage() -> void:
	boss.is_invulnerable = true
	var initial_hp = boss.current_hp
	boss.take_damage(50)
	assert_eq(boss.current_hp, initial_hp, "Invulnerable boss should not take damage")

func test_boss_emits_phase_changed_signal() -> void:
	watch_signals(boss)
	boss.current_phase = 0
	boss._transition_to_phase(1)
	await wait_frames(1)
	assert_signal_emitted(boss, "phase_changed", "Boss should emit phase_changed signal")

func test_boss_emits_defeated_signal() -> void:
	watch_signals(boss)
	boss.is_invulnerable = false
	boss.current_phase = 1
	boss.take_damage(100)
	await wait_frames(1)
	assert_signal_emitted(boss, "boss_defeated", "Boss should emit boss_defeated signal")

func test_difficulty_scaling_increases_hp() -> void:
	var initial_hp = boss.total_hp
	boss.apply_difficulty_scaling(5, false)  # 5 mutations
	assert_gt(boss.total_hp, initial_hp, "Difficulty scaling should increase total HP")

func test_difficulty_scaling_hard_mode() -> void:
	boss.apply_difficulty_scaling(0, false)
	var normal_hp = boss.total_hp

	boss.total_hp = 100  # Reset
	boss.apply_difficulty_scaling(0, true)
	var hard_hp = boss.total_hp

	assert_gt(hard_hp, normal_hp, "Hard mode should increase HP more than normal")

func test_difficulty_scaling_respects_max() -> void:
	boss.apply_difficulty_scaling(1000, false)  # Huge mutation count
	var scaled_hp = boss.total_hp
	var max_possible = int(100 * boss.max_scaling)
	assert_lte(scaled_hp, max_possible, "Scaling should respect max_scaling limit")

func test_phase_2_threshold() -> void:
	boss.current_phase = 1
	boss.is_invulnerable = false
	boss.current_hp = 67  # Just above 66%
	boss._check_phase_transition()
	await wait_frames(1)
	assert_eq(boss.current_phase, 1, "Boss should stay in phase 1 above threshold")

	boss.current_hp = 66  # At 66%
	boss._check_phase_transition()
	await wait_frames(1)
	assert_eq(boss.current_phase, 2, "Boss should transition at exact threshold")

func test_phase_3_threshold() -> void:
	boss.current_phase = 2
	boss.is_invulnerable = false
	boss.current_hp = 34  # Just above 33%
	boss._check_phase_transition()
	await wait_frames(1)
	assert_eq(boss.current_phase, 2, "Boss should stay in phase 2 above threshold")

	boss.current_hp = 33  # At 33%
	boss._check_phase_transition()
	await wait_frames(1)
	assert_eq(boss.current_phase, 3, "Boss should transition at exact threshold")

func test_boss_becomes_invulnerable_during_transition() -> void:
	boss.is_invulnerable = false
	boss._transition_to_phase(2)
	assert_true(boss.is_invulnerable, "Boss should become invulnerable during transition")

func test_take_damage_reduces_hp() -> void:
	boss.is_invulnerable = false
	boss.current_phase = 1
	var initial_hp = boss.current_hp
	boss.take_damage(25)
	assert_eq(boss.current_hp, initial_hp - 25, "Taking damage should reduce HP")

func test_evidence_id_set() -> void:
	boss.evidence_id = "test_evidence"
	assert_eq(boss.evidence_id, "test_evidence", "Evidence ID should be settable")
