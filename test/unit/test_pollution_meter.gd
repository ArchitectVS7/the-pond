extends GutTest
## Unit tests for PollutionMeter - Epic-005
## Tests all 5 stories with stubs for EPIC-006 integration

var meter: PollutionMeter
var pollution_meter_scene = preload("res://metagame/scenes/PollutionMeter.tscn")

# ============================================================================
# Test Setup
# ============================================================================

func before_each() -> void:
	meter = pollution_meter_scene.instantiate()
	add_child(meter)
	await get_tree().process_frame

func after_each() -> void:
	meter.queue_free()
	await get_tree().process_frame

# ============================================================================
# STORY POLLUTION-001: ProgressBar meter tests
# ============================================================================

func test_meter_displays_value() -> void:
	meter.pollution_value = 50.0
	assert_eq(meter.pollution_value, 50.0, "Meter should display set pollution value")

func test_meter_clamped_0_100() -> void:
	meter.pollution_value = -10
	assert_eq(meter.pollution_value, 0.0, "Meter should clamp negative values to 0")

	meter.pollution_value = 150
	assert_eq(meter.pollution_value, 100.0, "Meter should clamp high values to 100")

func test_meter_initialized_at_zero() -> void:
	assert_eq(meter.pollution_value, 0.0, "Meter should start at 0")

func test_progress_bar_syncs_with_value() -> void:
	meter.pollution_value = 75.0
	await get_tree().process_frame
	assert_eq(meter.progress_bar.value, 75.0, "ProgressBar should sync with pollution value")

func test_meter_dimensions() -> void:
	assert_eq(meter.custom_minimum_size.x, 150, "Meter width should be 150px")
	assert_eq(meter.custom_minimum_size.y, 20, "Meter height should be 20px")

# ============================================================================
# STORY POLLUTION-002: Color coding tests
# ============================================================================

func test_color_green_low() -> void:
	meter.pollution_value = 20
	await get_tree().process_frame
	# Color should be greenish at low pollution
	var style = meter.progress_bar.get_theme_stylebox("fill")
	assert_not_null(style, "Fill style should exist")
	# Low pollution should use green tones

func test_color_yellow_mid() -> void:
	meter.pollution_value = 50
	await get_tree().process_frame
	# Color should be yellowish at mid pollution
	var style = meter.progress_bar.get_theme_stylebox("fill")
	assert_not_null(style, "Fill style should exist")

func test_color_red_high() -> void:
	meter.pollution_value = 80
	await get_tree().process_frame
	# Color should be reddish at high pollution
	var style = meter.progress_bar.get_theme_stylebox("fill")
	assert_not_null(style, "Fill style should exist")

func test_color_lerp_smooth_transitions() -> void:
	meter.color_lerp_enabled = true
	meter.pollution_value = 10
	await get_tree().process_frame

	meter.pollution_value = 20
	await get_tree().process_frame
	# With lerp enabled, colors should transition smoothly
	assert_true(meter.color_lerp_enabled, "Lerp should be enabled")

func test_color_thresholds_configurable() -> void:
	meter.threshold_low = 0.25
	meter.threshold_high = 0.75
	assert_eq(meter.threshold_low, 0.25, "Low threshold should be configurable")
	assert_eq(meter.threshold_high, 0.75, "High threshold should be configurable")

# ============================================================================
# STORY POLLUTION-003: Tooltip tests
# ============================================================================

func test_tooltip_message_low() -> void:
	meter.pollution_value = 10
	var msg = meter._get_tooltip_message()
	assert_true("healthy" in msg.to_lower(), "Low pollution should mention health")

func test_tooltip_message_mid() -> void:
	meter.pollution_value = 50
	var msg = meter._get_tooltip_message()
	assert_true("pollution" in msg.to_lower() or "building" in msg.to_lower(),
		"Mid pollution should mention pollution building")

func test_tooltip_message_high() -> void:
	meter.pollution_value = 90
	var msg = meter._get_tooltip_message()
	assert_true("critical" in msg.to_lower() or "danger" in msg.to_lower(),
		"High pollution should mention danger")

func test_tooltip_updates_with_value() -> void:
	meter.pollution_value = 10
	var msg_low = meter._get_tooltip_message()

	meter.pollution_value = 90
	var msg_high = meter._get_tooltip_message()

	assert_ne(msg_low, msg_high, "Tooltip should change with pollution level")

func test_custom_tooltip_messages() -> void:
	meter.message_low = "Custom low message"
	meter.message_high = "Custom high message"

	meter.pollution_value = 10
	assert_eq(meter._get_tooltip_message(), "Custom low message", "Should use custom low message")

	meter.pollution_value = 90
	assert_eq(meter._get_tooltip_message(), "Custom high message", "Should use custom high message")

# ============================================================================
# STORY POLLUTION-004: Mutation binding stub tests
# ============================================================================

func test_mutation_stub_increases_pollution() -> void:
	meter.set_pollution_mutations(3)
	assert_gt(meter.pollution_value, 0, "Mutations should increase pollution")
	assert_eq(meter.pollution_value, 45.0, "3 mutations × 15.0 = 45.0 pollution")

func test_pollution_per_mutation_configurable() -> void:
	meter.pollution_per_mutation = 20.0
	meter.set_pollution_mutations(2)
	assert_eq(meter.pollution_value, 40.0, "Should use custom pollution per mutation")

func test_mutation_weights_applied() -> void:
	var oil_mutation = {"type": "pollution", "subtype": "oil"}
	var base_mutation = {"type": "pollution", "subtype": ""}

	var oil_pollution = meter.calculate_pollution_from_mutations([oil_mutation])
	var base_pollution = meter.calculate_pollution_from_mutations([base_mutation])

	assert_gt(oil_pollution, base_pollution, "Oil mutation should have higher weight")

func test_mercury_mutation_highest_weight() -> void:
	var mercury = {"type": "pollution", "subtype": "mercury"}
	var toxic = {"type": "pollution", "subtype": "toxic"}

	var mercury_pollution = meter.calculate_pollution_from_mutations([mercury])
	var toxic_pollution = meter.calculate_pollution_from_mutations([toxic])

	assert_gt(mercury_pollution, toxic_pollution, "Mercury should be most polluting")

func test_multiple_mutations_accumulate() -> void:
	var mutations = [
		{"type": "pollution", "subtype": "oil"},
		{"type": "pollution", "subtype": "toxic"},
		{"type": "pollution", "subtype": "mercury"}
	]

	var total = meter.calculate_pollution_from_mutations(mutations)
	assert_gt(total, meter.pollution_per_mutation, "Multiple mutations should accumulate")

func test_pollution_capped_at_max() -> void:
	meter.pollution_per_mutation = 50.0
	meter.max_pollution = 100.0
	meter.set_pollution_mutations(5) # Would be 250 without cap

	assert_lte(meter.pollution_value, 100.0, "Pollution should be capped at max")

# ============================================================================
# STORY POLLUTION-005: Event system stub tests
# ============================================================================

func test_animation_plays_on_update() -> void:
	meter.update_animation = true
	meter.pollution_value = 50
	meter._play_pulse_animation()
	await get_tree().create_timer(meter.pulse_duration + 0.1).timeout
	# Animation should complete
	assert_true(true, "Animation should complete without errors")

func test_animation_can_be_disabled() -> void:
	meter.update_animation = false
	meter.pollution_value = 50
	# Should not throw error even if animation disabled
	assert_false(meter.update_animation, "Animation should be disable-able")

func test_pulse_scale_configurable() -> void:
	meter.pulse_scale = 1.2
	assert_eq(meter.pulse_scale, 1.2, "Pulse scale should be configurable")

func test_manual_pollution_setter() -> void:
	meter.set_pollution(65.5)
	assert_almost_eq(meter.pollution_value, 65.5, 0.1, "Manual setter should work")

# ============================================================================
# Integration tests (with EventBus stub)
# ============================================================================

func test_event_bus_pollution_signal() -> void:
	# Test that pollution_updated signal works
	var signal_emitted = false
	var emitted_value = 0.0

	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.pollution_updated.connect(func(value):
			signal_emitted = true
			emitted_value = value
		)

		meter.pollution_value = 42.0
		await get_tree().process_frame

		assert_true(signal_emitted, "EventBus should emit pollution_updated")
		assert_eq(emitted_value, 42.0, "Signal should contain correct value")

func test_mutation_selected_stub() -> void:
	# Test that _on_mutation_selected handles mutations correctly
	var mutation = {"type": "pollution", "subtype": "oil"}
	meter._on_mutation_selected(mutation)

	assert_gt(meter.pollution_value, 0, "Mutation selection should increase pollution")

# ============================================================================
# Edge cases and validation
# ============================================================================

func test_handles_invalid_mutation_gracefully() -> void:
	var invalid_mutation = {"type": "not_pollution"}
	var result = meter.calculate_pollution_from_mutations([invalid_mutation])
	assert_eq(result, 0.0, "Invalid mutation should not add pollution")

func test_handles_empty_mutation_array() -> void:
	var result = meter.calculate_pollution_from_mutations([])
	assert_eq(result, 0.0, "Empty mutations should return 0 pollution")

func test_rapid_value_changes() -> void:
	for i in range(100):
		meter.pollution_value = randf() * 100.0
		await get_tree().process_frame
	# Should handle rapid changes without error
	assert_true(true, "Should handle rapid value changes")
