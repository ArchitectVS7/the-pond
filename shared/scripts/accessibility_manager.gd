extends Node
class_name AccessibilityManager

## Manages all accessibility features for the game
## Handles colorblind modes, text scaling, screen shake, and keyboard navigation

signal accessibility_setting_changed(setting_name: String, value)
signal text_scale_changed(scale: float)
signal colorblind_mode_changed(mode: int)

enum ColorblindMode {
    NORMAL = 0,
    DEUTERANOPIA = 1,  # Red-green (most common)
    PROTANOPIA = 2,     # Red-blind
    TRITANOPIA = 3      # Blue-yellow
}

enum TextScale {
    SMALL = 0,   # 0.8x
    NORMAL = 1,  # 1.0x
    LARGE = 2    # 1.3x
}

# Settings storage
var colorblind_mode: ColorblindMode = ColorblindMode.NORMAL
var text_scale: TextScale = TextScale.NORMAL
var screen_shake_enabled: bool = true
var keyboard_navigation_enabled: bool = true

# Text scale multipliers
const TEXT_SCALE_VALUES = {
    TextScale.SMALL: 0.8,
    TextScale.NORMAL: 1.0,
    TextScale.LARGE: 1.3
}

# WCAG AA Contrast ratios
const WCAG_AA_TEXT_CONTRAST = 4.5  # For normal text
const WCAG_AA_UI_CONTRAST = 3.0    # For UI components

# Shader material for colorblind filter
var colorblind_material: ShaderMaterial

func _ready() -> void:
    load_settings()
    setup_colorblind_shader()
    apply_all_settings()

func setup_colorblind_shader() -> void:
    var shader = load("res://shared/shaders/colorblind_filter.gdshader")
    colorblind_material = ShaderMaterial.new()
    colorblind_material.shader = shader
    colorblind_material.set_shader_parameter("filter_mode", colorblind_mode)
    colorblind_material.set_shader_parameter("filter_strength", 1.0)

## Set colorblind mode
func set_colorblind_mode(mode: ColorblindMode) -> void:
    colorblind_mode = mode
    if colorblind_material:
        colorblind_material.set_shader_parameter("filter_mode", mode)

    # Apply to viewport
    var viewport = get_viewport()
    if mode == ColorblindMode.NORMAL:
        viewport.set_canvas_cull_mask_bit(0, true)
        if viewport.has_meta("colorblind_layer"):
            var layer = viewport.get_meta("colorblind_layer")
            layer.queue_free()
            viewport.remove_meta("colorblind_layer")
    else:
        apply_colorblind_filter_to_viewport(viewport)

    save_settings()
    accessibility_setting_changed.emit("colorblind_mode", mode)
    colorblind_mode_changed.emit(mode)

func apply_colorblind_filter_to_viewport(viewport: Viewport) -> void:
    # Create a ColorRect that covers the viewport with the shader
    var filter_layer: ColorRect

    if viewport.has_meta("colorblind_layer"):
        filter_layer = viewport.get_meta("colorblind_layer")
    else:
        filter_layer = ColorRect.new()
        filter_layer.name = "ColorblindFilter"
        filter_layer.material = colorblind_material
        filter_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        viewport.add_child(filter_layer)
        viewport.set_meta("colorblind_layer", filter_layer)

    # Update size to match viewport
    filter_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    filter_layer.material = colorblind_material

## Set text scale
func set_text_scale(scale: TextScale) -> void:
    text_scale = scale
    var scale_value = TEXT_SCALE_VALUES[scale]

    # Apply to all Labels and RichTextLabels in the scene tree
    apply_text_scale_recursive(get_tree().root, scale_value)

    save_settings()
    accessibility_setting_changed.emit("text_scale", scale)
    text_scale_changed.emit(scale_value)

func apply_text_scale_recursive(node: Node, scale_value: float) -> void:
    if node is Label:
        var label = node as Label
        if not label.has_meta("original_font_size"):
            label.set_meta("original_font_size", label.get_theme_font_size("font_size"))
        var original_size = label.get_meta("original_font_size")
        label.add_theme_font_size_override("font_size", int(original_size * scale_value))

    elif node is RichTextLabel:
        var rtl = node as RichTextLabel
        if not rtl.has_meta("original_font_size"):
            rtl.set_meta("original_font_size", rtl.get_theme_font_size("normal_font_size"))
        var original_size = rtl.get_meta("original_font_size")
        rtl.add_theme_font_size_override("normal_font_size", int(original_size * scale_value))

    for child in node.get_children():
        apply_text_scale_recursive(child, scale_value)

## Get current text scale multiplier
func get_text_scale_value() -> float:
    return TEXT_SCALE_VALUES[text_scale]

## Toggle screen shake
func set_screen_shake_enabled(enabled: bool) -> void:
    screen_shake_enabled = enabled
    save_settings()
    accessibility_setting_changed.emit("screen_shake", enabled)

## Toggle keyboard navigation
func set_keyboard_navigation_enabled(enabled: bool) -> void:
    keyboard_navigation_enabled = enabled
    save_settings()
    accessibility_setting_changed.emit("keyboard_navigation", enabled)

## Validate WCAG AA contrast ratio
func validate_contrast_ratio(color1: Color, color2: Color, is_text: bool = true) -> bool:
    var luminance1 = calculate_relative_luminance(color1)
    var luminance2 = calculate_relative_luminance(color2)

    var lighter = max(luminance1, luminance2)
    var darker = min(luminance1, luminance2)

    var contrast_ratio = (lighter + 0.05) / (darker + 0.05)

    var required_ratio = WCAG_AA_TEXT_CONTRAST if is_text else WCAG_AA_UI_CONTRAST

    return contrast_ratio >= required_ratio

## Calculate relative luminance for WCAG contrast
func calculate_relative_luminance(color: Color) -> float:
    var r = linearize_color_component(color.r)
    var g = linearize_color_component(color.g)
    var b = linearize_color_component(color.b)

    return 0.2126 * r + 0.7152 * g + 0.0722 * b

func linearize_color_component(component: float) -> float:
    if component <= 0.03928:
        return component / 12.92
    else:
        return pow((component + 0.055) / 1.055, 2.4)

## Get contrast ratio between two colors
func get_contrast_ratio(color1: Color, color2: Color) -> float:
    var luminance1 = calculate_relative_luminance(color1)
    var luminance2 = calculate_relative_luminance(color2)

    var lighter = max(luminance1, luminance2)
    var darker = min(luminance1, luminance2)

    return (lighter + 0.05) / (darker + 0.05)

## Apply all current settings
func apply_all_settings() -> void:
    set_colorblind_mode(colorblind_mode)
    set_text_scale(text_scale)

## Save settings to config file
func save_settings() -> void:
    var config = ConfigFile.new()

    config.set_value("accessibility", "colorblind_mode", colorblind_mode)
    config.set_value("accessibility", "text_scale", text_scale)
    config.set_value("accessibility", "screen_shake_enabled", screen_shake_enabled)
    config.set_value("accessibility", "keyboard_navigation_enabled", keyboard_navigation_enabled)

    config.save("user://accessibility_settings.cfg")

## Load settings from config file
func load_settings() -> void:
    var config = ConfigFile.new()
    var err = config.load("user://accessibility_settings.cfg")

    if err != OK:
        return  # Use defaults

    colorblind_mode = config.get_value("accessibility", "colorblind_mode", ColorblindMode.NORMAL)
    text_scale = config.get_value("accessibility", "text_scale", TextScale.NORMAL)
    screen_shake_enabled = config.get_value("accessibility", "screen_shake_enabled", true)
    keyboard_navigation_enabled = config.get_value("accessibility", "keyboard_navigation_enabled", true)

## Reset all settings to defaults
func reset_to_defaults() -> void:
    set_colorblind_mode(ColorblindMode.NORMAL)
    set_text_scale(TextScale.NORMAL)
    set_screen_shake_enabled(true)
    set_keyboard_navigation_enabled(true)
