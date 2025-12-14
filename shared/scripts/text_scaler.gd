extends Node
class_name TextScaler

## Utility for applying text scaling to UI elements
## Automatically tracks and scales text based on accessibility settings

static var accessibility_manager: AccessibilityManager

## Initialize with accessibility manager reference
static func initialize(manager: AccessibilityManager) -> void:
    accessibility_manager = manager

    if accessibility_manager:
        accessibility_manager.text_scale_changed.connect(_on_text_scale_changed)

## Apply scaling to a specific node and its children
static func apply_to_node(node: Node) -> void:
    if not accessibility_manager:
        return

    var scale_value = accessibility_manager.get_text_scale_value()
    _apply_scale_recursive(node, scale_value)

## Apply scaling to a Label
static func apply_to_label(label: Label) -> void:
    if not accessibility_manager:
        return

    if not label.has_meta("original_font_size"):
        label.set_meta("original_font_size", label.get_theme_font_size("font_size"))

    var original_size = label.get_meta("original_font_size")
    var scale_value = accessibility_manager.get_text_scale_value()
    label.add_theme_font_size_override("font_size", int(original_size * scale_value))

## Apply scaling to a RichTextLabel
static func apply_to_rich_text_label(rtl: RichTextLabel) -> void:
    if not accessibility_manager:
        return

    if not rtl.has_meta("original_font_size"):
        rtl.set_meta("original_font_size", rtl.get_theme_font_size("normal_font_size"))

    var original_size = rtl.get_meta("original_font_size")
    var scale_value = accessibility_manager.get_text_scale_value()
    rtl.add_theme_font_size_override("normal_font_size", int(original_size * scale_value))

## Apply scaling to a Button
static func apply_to_button(button: Button) -> void:
    if not accessibility_manager:
        return

    if not button.has_meta("original_font_size"):
        button.set_meta("original_font_size", button.get_theme_font_size("font_size"))

    var original_size = button.get_meta("original_font_size")
    var scale_value = accessibility_manager.get_text_scale_value()
    button.add_theme_font_size_override("font_size", int(original_size * scale_value))

static func _apply_scale_recursive(node: Node, scale_value: float) -> void:
    if node is Label:
        apply_to_label(node as Label)
    elif node is RichTextLabel:
        apply_to_rich_text_label(node as RichTextLabel)
    elif node is Button:
        apply_to_button(node as Button)

    for child in node.get_children():
        _apply_scale_recursive(child, scale_value)

static func _on_text_scale_changed(scale: float) -> void:
    # Re-apply scaling to all nodes in the scene tree
    if accessibility_manager:
        var root = accessibility_manager.get_tree().root
        _apply_scale_recursive(root, scale)
