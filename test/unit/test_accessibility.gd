extends GutTest

## Comprehensive accessibility feature tests
## Validates all Epic-011 requirements

var accessibility_manager: AccessibilityManager
var test_viewport: Viewport
var test_label: Label
var test_button: Button

func before_each():
    accessibility_manager = AccessibilityManager.new()
    add_child_autoqfree(accessibility_manager)

    test_viewport = Viewport.new()
    add_child_autoqfree(test_viewport)

    test_label = Label.new()
    test_label.text = "Test Label"
    test_label.add_theme_font_size_override("font_size", 16)
    add_child_autoqfree(test_label)

    test_button = Button.new()
    test_button.text = "Test Button"
    test_button.add_theme_font_size_override("font_size", 14)
    add_child_autoqfree(test_button)

## ACCESS-001: Test Deuteranopia colorblind filter
func test_deuteranopia_colorblind_mode():
    accessibility_manager.set_colorblind_mode(AccessibilityManager.ColorblindMode.DEUTERANOPIA)

    assert_eq(accessibility_manager.colorblind_mode, AccessibilityManager.ColorblindMode.DEUTERANOPIA,
        "Should set deuteranopia mode")

    assert_not_null(accessibility_manager.colorblind_material,
        "Should create colorblind material")

    var shader_mode = accessibility_manager.colorblind_material.get_shader_parameter("filter_mode")
    assert_eq(shader_mode, 1, "Shader should be set to deuteranopia mode (1)")

## ACCESS-002: Test Protanopia colorblind filter
func test_protanopia_colorblind_mode():
    accessibility_manager.set_colorblind_mode(AccessibilityManager.ColorblindMode.PROTANOPIA)

    assert_eq(accessibility_manager.colorblind_mode, AccessibilityManager.ColorblindMode.PROTANOPIA,
        "Should set protanopia mode")

    var shader_mode = accessibility_manager.colorblind_material.get_shader_parameter("filter_mode")
    assert_eq(shader_mode, 2, "Shader should be set to protanopia mode (2)")

## ACCESS-003: Test Tritanopia colorblind filter
func test_tritanopia_colorblind_mode():
    accessibility_manager.set_colorblind_mode(AccessibilityManager.ColorblindMode.TRITANOPIA)

    assert_eq(accessibility_manager.colorblind_mode, AccessibilityManager.ColorblindMode.TRITANOPIA,
        "Should set tritanopia mode")

    var shader_mode = accessibility_manager.colorblind_material.get_shader_parameter("filter_mode")
    assert_eq(shader_mode, 3, "Shader should be set to tritanopia mode (3)")

## ACCESS-004: Test text scaling (0.8x, 1.0x, 1.3x)
func test_text_scaling_small():
    test_label.set_meta("original_font_size", 16)

    accessibility_manager.set_text_scale(AccessibilityManager.TextScale.SMALL)

    assert_eq(accessibility_manager.text_scale, AccessibilityManager.TextScale.SMALL,
        "Should set small text scale")

    var scale_value = accessibility_manager.get_text_scale_value()
    assert_almost_eq(scale_value, 0.8, 0.01, "Small scale should be 0.8x")

func test_text_scaling_normal():
    accessibility_manager.set_text_scale(AccessibilityManager.TextScale.NORMAL)

    var scale_value = accessibility_manager.get_text_scale_value()
    assert_almost_eq(scale_value, 1.0, 0.01, "Normal scale should be 1.0x")

func test_text_scaling_large():
    accessibility_manager.set_text_scale(AccessibilityManager.TextScale.LARGE)

    var scale_value = accessibility_manager.get_text_scale_value()
    assert_almost_eq(scale_value, 1.3, 0.01, "Large scale should be 1.3x")

## ACCESS-005: Test screen shake toggle
func test_screen_shake_toggle():
    assert_true(accessibility_manager.screen_shake_enabled, "Screen shake should be enabled by default")

    accessibility_manager.set_screen_shake_enabled(false)
    assert_false(accessibility_manager.screen_shake_enabled, "Should disable screen shake")

    accessibility_manager.set_screen_shake_enabled(true)
    assert_true(accessibility_manager.screen_shake_enabled, "Should re-enable screen shake")

## ACCESS-006: Test keyboard navigation toggle
func test_keyboard_navigation_toggle():
    assert_true(accessibility_manager.keyboard_navigation_enabled, "Keyboard nav should be enabled by default")

    accessibility_manager.set_keyboard_navigation_enabled(false)
    assert_false(accessibility_manager.keyboard_navigation_enabled, "Should disable keyboard navigation")

    accessibility_manager.set_keyboard_navigation_enabled(true)
    assert_true(accessibility_manager.keyboard_navigation_enabled, "Should re-enable keyboard navigation")

## ACCESS-007: Test WCAG AA contrast validation (4.5:1 text, 3:1 UI)
func test_wcag_text_contrast_pass():
    var black = Color(0, 0, 0)
    var white = Color(1, 1, 1)

    var passes = accessibility_manager.validate_contrast_ratio(black, white, true)
    assert_true(passes, "Black on white should pass WCAG AA text contrast (21:1)")

    var ratio = accessibility_manager.get_contrast_ratio(black, white)
    assert_gt(ratio, 4.5, "Contrast ratio should exceed 4.5:1 for text")

func test_wcag_text_contrast_fail():
    var light_gray = Color(0.8, 0.8, 0.8)
    var white = Color(1, 1, 1)

    var passes = accessibility_manager.validate_contrast_ratio(light_gray, white, true)
    assert_false(passes, "Light gray on white should fail WCAG AA text contrast")

    var ratio = accessibility_manager.get_contrast_ratio(light_gray, white)
    assert_lt(ratio, 4.5, "Contrast ratio should be below 4.5:1")

func test_wcag_ui_contrast_pass():
    var dark_gray = Color(0.4, 0.4, 0.4)
    var white = Color(1, 1, 1)

    var passes = accessibility_manager.validate_contrast_ratio(dark_gray, white, false)
    assert_true(passes, "Dark gray on white should pass WCAG AA UI contrast (3:1)")

    var ratio = accessibility_manager.get_contrast_ratio(dark_gray, white)
    assert_gt(ratio, 3.0, "Contrast ratio should exceed 3:1 for UI")

func test_wcag_ui_contrast_fail():
    var medium_gray = Color(0.6, 0.6, 0.6)
    var white = Color(1, 1, 1)

    var passes = accessibility_manager.validate_contrast_ratio(medium_gray, white, false)
    assert_false(passes, "Medium gray on white should fail WCAG AA UI contrast")

## Test relative luminance calculation
func test_relative_luminance_black():
    var black = Color(0, 0, 0)
    var luminance = accessibility_manager.calculate_relative_luminance(black)
    assert_almost_eq(luminance, 0.0, 0.001, "Black should have 0 luminance")

func test_relative_luminance_white():
    var white = Color(1, 1, 1)
    var luminance = accessibility_manager.calculate_relative_luminance(white)
    assert_almost_eq(luminance, 1.0, 0.001, "White should have 1.0 luminance")

## Test settings persistence
func test_save_and_load_settings():
    accessibility_manager.set_colorblind_mode(AccessibilityManager.ColorblindMode.DEUTERANOPIA)
    accessibility_manager.set_text_scale(AccessibilityManager.TextScale.LARGE)
    accessibility_manager.set_screen_shake_enabled(false)

    accessibility_manager.save_settings()

    # Create new manager and load
    var new_manager = AccessibilityManager.new()
    add_child_autoqfree(new_manager)
    new_manager.load_settings()

    assert_eq(new_manager.colorblind_mode, AccessibilityManager.ColorblindMode.DEUTERANOPIA,
        "Should load saved colorblind mode")
    assert_eq(new_manager.text_scale, AccessibilityManager.TextScale.LARGE,
        "Should load saved text scale")
    assert_false(new_manager.screen_shake_enabled, "Should load saved screen shake setting")

## Test reset to defaults
func test_reset_to_defaults():
    accessibility_manager.set_colorblind_mode(AccessibilityManager.ColorblindMode.PROTANOPIA)
    accessibility_manager.set_text_scale(AccessibilityManager.TextScale.SMALL)
    accessibility_manager.set_screen_shake_enabled(false)
    accessibility_manager.set_keyboard_navigation_enabled(false)

    accessibility_manager.reset_to_defaults()

    assert_eq(accessibility_manager.colorblind_mode, AccessibilityManager.ColorblindMode.NORMAL,
        "Should reset colorblind mode to normal")
    assert_eq(accessibility_manager.text_scale, AccessibilityManager.TextScale.NORMAL,
        "Should reset text scale to normal")
    assert_true(accessibility_manager.screen_shake_enabled, "Should reset screen shake to enabled")
    assert_true(accessibility_manager.keyboard_navigation_enabled, "Should reset keyboard nav to enabled")

## Test signal emissions
func test_accessibility_signals():
    var signal_watcher = watch_signals(accessibility_manager)

    accessibility_manager.set_colorblind_mode(AccessibilityManager.ColorblindMode.TRITANOPIA)
    assert_signal_emitted(accessibility_manager, "accessibility_setting_changed",
        "Should emit accessibility_setting_changed")
    assert_signal_emitted(accessibility_manager, "colorblind_mode_changed",
        "Should emit colorblind_mode_changed")

    accessibility_manager.set_text_scale(AccessibilityManager.TextScale.LARGE)
    assert_signal_emitted(accessibility_manager, "text_scale_changed",
        "Should emit text_scale_changed")

## Test TextScaler utility
func test_text_scaler_initialization():
    TextScaler.initialize(accessibility_manager)
    assert_not_null(TextScaler.accessibility_manager, "TextScaler should be initialized")

func test_text_scaler_apply_to_label():
    TextScaler.initialize(accessibility_manager)
    test_label.set_meta("original_font_size", 16)

    accessibility_manager.set_text_scale(AccessibilityManager.TextScale.LARGE)
    TextScaler.apply_to_label(test_label)

    var expected_size = int(16 * 1.3)
    var actual_size = test_label.get_theme_font_size("font_size")
    assert_eq(actual_size, expected_size, "Label font should be scaled to 1.3x")

## Integration test: Full accessibility workflow
func test_full_accessibility_workflow():
    # Start with defaults
    assert_eq(accessibility_manager.colorblind_mode, AccessibilityManager.ColorblindMode.NORMAL)

    # Apply accessibility settings
    accessibility_manager.set_colorblind_mode(AccessibilityManager.ColorblindMode.DEUTERANOPIA)
    accessibility_manager.set_text_scale(AccessibilityManager.TextScale.LARGE)
    accessibility_manager.set_screen_shake_enabled(false)

    # Verify all settings applied
    assert_eq(accessibility_manager.colorblind_mode, AccessibilityManager.ColorblindMode.DEUTERANOPIA)
    assert_eq(accessibility_manager.text_scale, AccessibilityManager.TextScale.LARGE)
    assert_false(accessibility_manager.screen_shake_enabled)

    # Save and reload
    accessibility_manager.save_settings()
    accessibility_manager.reset_to_defaults()
    accessibility_manager.load_settings()

    # Verify persistence
    assert_eq(accessibility_manager.colorblind_mode, AccessibilityManager.ColorblindMode.DEUTERANOPIA)
    assert_eq(accessibility_manager.text_scale, AccessibilityManager.TextScale.LARGE)
    assert_false(accessibility_manager.screen_shake_enabled)

## Performance test: Ensure accessibility features don't impact performance
func test_performance_colorblind_shader():
    var start_time = Time.get_ticks_msec()

    for i in range(100):
        accessibility_manager.set_colorblind_mode(AccessibilityManager.ColorblindMode.DEUTERANOPIA)
        accessibility_manager.set_colorblind_mode(AccessibilityManager.ColorblindMode.NORMAL)

    var elapsed = Time.get_ticks_msec() - start_time
    assert_lt(elapsed, 1000, "Colorblind mode switching should be fast (< 1000ms for 200 switches)")
