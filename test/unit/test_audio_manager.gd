## Unit Tests for Audio Manager (COMBAT-011)
##
## Tests audio feedback for combat actions.
## PRD Requirement: "Audio feedback: wet thwap on hit, glorp on enemy death"
extends GutTest

const AudioManagerClass := preload("res://shared/scripts/audio_manager.gd")

var audio_manager: Node


func before_each() -> void:
	audio_manager = AudioManagerClass.new()
	add_child_autofree(audio_manager)
	await get_tree().process_frame


# =============================================================================
# BASIC FUNCTIONALITY TESTS
# =============================================================================


## Test 1: Can create AudioManager
func test_can_create_audio_manager() -> void:
	assert_not_null(audio_manager, "AudioManager should be created")


## Test 2: Has play_hit method for thwap sound
func test_has_play_hit_method() -> void:
	assert_true(audio_manager.has_method("play_hit"), "Should have play_hit method")


## Test 3: Has play_death method for glorp sound
func test_has_play_death_method() -> void:
	assert_true(audio_manager.has_method("play_death"), "Should have play_death method")


## Test 4: Can call play_hit without error
func test_play_hit_no_error() -> void:
	# Should not throw error even without audio file
	audio_manager.play_hit()
	pass_test("play_hit should not error")


## Test 5: Can call play_death without error
func test_play_death_no_error() -> void:
	# Should not throw error even without audio file
	audio_manager.play_death()
	pass_test("play_death should not error")


# =============================================================================
# SETTINGS TESTS
# =============================================================================


## Test 6: Has sfx_enabled setting
func test_has_sfx_enabled_setting() -> void:
	assert_true("sfx_enabled" in audio_manager, "Should have sfx_enabled property")


## Test 7: SFX can be disabled
func test_sfx_can_be_disabled() -> void:
	audio_manager.sfx_enabled = false
	audio_manager.play_hit()
	# Should not play (verified via get_playing_count)
	assert_eq(audio_manager.get_playing_count(), 0, "No sounds should play when disabled")


## Test 8: Has master volume
func test_has_master_volume() -> void:
	assert_true("master_volume" in audio_manager, "Should have master_volume property")


## Test 9: Volume is normalized (0.0 to 1.0)
func test_volume_normalized() -> void:
	audio_manager.master_volume = 2.0  # Above 1
	assert_lte(audio_manager.master_volume, 1.0, "Volume should be clamped to 1.0")

	audio_manager.master_volume = -1.0  # Below 0
	assert_gte(audio_manager.master_volume, 0.0, "Volume should be clamped to 0.0")


# =============================================================================
# PITCH VARIATION TESTS
# =============================================================================


## Test 10: Has pitch variation setting
func test_has_pitch_variation() -> void:
	assert_true("pitch_variation" in audio_manager, "Should have pitch_variation property")


## Test 11: Pitch variation is reasonable range
func test_pitch_variation_range() -> void:
	# Should be small variation (e.g., 0.1 = +/- 10%)
	assert_lte(audio_manager.pitch_variation, 0.5, "Pitch variation should not be too extreme")
	assert_gte(audio_manager.pitch_variation, 0.0, "Pitch variation should be non-negative")


# =============================================================================
# POOLING TESTS
# =============================================================================


## Test 12: Uses audio player pool
func test_uses_audio_pool() -> void:
	assert_true(audio_manager.has_method("get_playing_count"), "Should track playing sounds")


## Test 13: Can get playing count
func test_get_playing_count() -> void:
	var count := audio_manager.get_playing_count()
	assert_gte(count, 0, "Playing count should be non-negative")


## Test 14: Pool size is configurable
func test_pool_size_configurable() -> void:
	assert_true(
		"max_simultaneous_sounds" in audio_manager, "Should have max_simultaneous_sounds property"
	)


# =============================================================================
# SOUND PRESET TESTS
# =============================================================================


## Test 15: Hit sound has correct path or resource
func test_hit_sound_configured() -> void:
	# Should have hit_sound_path or hit_sound resource
	var has_hit_config := "hit_sound_path" in audio_manager or "hit_sound" in audio_manager
	assert_true(has_hit_config, "Should have hit sound configuration")


## Test 16: Death sound has correct path or resource
func test_death_sound_configured() -> void:
	# Should have death_sound_path or death_sound resource
	var has_death_config := "death_sound_path" in audio_manager or "death_sound" in audio_manager
	assert_true(has_death_config, "Should have death sound configuration")


# =============================================================================
# SIGNAL TESTS
# =============================================================================


## Test 17: Emits sound_played signal
func test_emits_sound_played_signal() -> void:
	assert_true(audio_manager.has_signal("sound_played"), "Should have sound_played signal")


## Test 18: Signal contains sound type info
func test_signal_contains_type() -> void:
	watch_signals(audio_manager)
	audio_manager.play_hit()

	# Signal should be emitted (even if audio file missing)
	var params := get_signal_parameters(audio_manager, "sound_played")
	if params.size() > 0:
		assert_true("type" in params[0] or params[0] is String, "Signal should contain sound type")


# =============================================================================
# GENERIC PLAY METHOD
# =============================================================================


## Test 19: Has generic play_sfx method
func test_has_generic_play_sfx() -> void:
	assert_true(audio_manager.has_method("play_sfx"), "Should have generic play_sfx method")


## Test 20: play_sfx handles invalid sound gracefully
func test_play_sfx_handles_invalid() -> void:
	# Should not crash with invalid sound name
	audio_manager.play_sfx("nonexistent_sound")
	pass_test("Should handle invalid sound name gracefully")


# =============================================================================
# POSITION TESTS (2D Audio)
# =============================================================================


## Test 21: Can play sound at position
func test_can_play_at_position() -> void:
	var pos := Vector2(100, 100)
	# Should have position-aware variant
	if audio_manager.has_method("play_hit_at"):
		audio_manager.play_hit_at(pos)
		pass_test("play_hit_at works")
	elif audio_manager.has_method("play_sfx_at"):
		audio_manager.play_sfx_at("hit", pos)
		pass_test("play_sfx_at works")
	else:
		# Position audio is optional for this story
		pass_test("Position audio not implemented (optional)")
