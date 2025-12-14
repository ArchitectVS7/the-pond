extends Control

## Accessibility Settings UI
## Provides interface for configuring all accessibility features

var accessibility_manager: AccessibilityManager

# Node references
@onready var normal_button = $Panel/MarginContainer/VBoxContainer/ColorblindSection/ColorblindOptions/NormalButton
@onready var deuteranopia_button = $Panel/MarginContainer/VBoxContainer/ColorblindSection/ColorblindOptions/DeuteranopiaButton
@onready var protanopia_button = $Panel/MarginContainer/VBoxContainer/ColorblindSection/ColorblindOptions/ProtanopiaButton
@onready var tritanopia_button = $Panel/MarginContainer/VBoxContainer/ColorblindSection/ColorblindOptions/TritanopiaButton

@onready var small_text_button = $Panel/MarginContainer/VBoxContainer/TextScaleSection/TextScaleOptions/SmallButton
@onready var normal_text_button = $Panel/MarginContainer/VBoxContainer/TextScaleSection/TextScaleOptions/NormalButton
@onready var large_text_button = $Panel/MarginContainer/VBoxContainer/TextScaleSection/TextScaleOptions/LargeButton

@onready var screen_shake_check = $Panel/MarginContainer/VBoxContainer/TogglesSection/ScreenShakeCheck
@onready var keyboard_nav_check = $Panel/MarginContainer/VBoxContainer/TogglesSection/KeyboardNavCheck

@onready var rebind_button = $Panel/MarginContainer/VBoxContainer/ControlsSection/RebindButton
@onready var reset_button = $Panel/MarginContainer/VBoxContainer/BottomButtons/ResetButton
@onready var close_button = $Panel/MarginContainer/VBoxContainer/BottomButtons/CloseButton

func _ready() -> void:
    # Get or create accessibility manager
    accessibility_manager = get_node_or_null("/root/AccessibilityManager")
    if not accessibility_manager:
        accessibility_manager = AccessibilityManager.new()
        accessibility_manager.name = "AccessibilityManager"
        get_tree().root.add_child(accessibility_manager)

    # Connect signals
    normal_button.pressed.connect(_on_colorblind_mode_changed.bind(AccessibilityManager.ColorblindMode.NORMAL))
    deuteranopia_button.pressed.connect(_on_colorblind_mode_changed.bind(AccessibilityManager.ColorblindMode.DEUTERANOPIA))
    protanopia_button.pressed.connect(_on_colorblind_mode_changed.bind(AccessibilityManager.ColorblindMode.PROTANOPIA))
    tritanopia_button.pressed.connect(_on_colorblind_mode_changed.bind(AccessibilityManager.ColorblindMode.TRITANOPIA))

    small_text_button.pressed.connect(_on_text_scale_changed.bind(AccessibilityManager.TextScale.SMALL))
    normal_text_button.pressed.connect(_on_text_scale_changed.bind(AccessibilityManager.TextScale.NORMAL))
    large_text_button.pressed.connect(_on_text_scale_changed.bind(AccessibilityManager.TextScale.LARGE))

    screen_shake_check.toggled.connect(_on_screen_shake_toggled)
    keyboard_nav_check.toggled.connect(_on_keyboard_nav_toggled)

    rebind_button.pressed.connect(_on_rebind_controls_pressed)
    reset_button.pressed.connect(_on_reset_pressed)
    close_button.pressed.connect(_on_close_pressed)

    # Load current settings
    load_current_settings()

    # Setup keyboard navigation
    setup_keyboard_navigation()

func load_current_settings() -> void:
    # Set colorblind mode buttons
    match accessibility_manager.colorblind_mode:
        AccessibilityManager.ColorblindMode.NORMAL:
            normal_button.button_pressed = true
        AccessibilityManager.ColorblindMode.DEUTERANOPIA:
            deuteranopia_button.button_pressed = true
        AccessibilityManager.ColorblindMode.PROTANOPIA:
            protanopia_button.button_pressed = true
        AccessibilityManager.ColorblindMode.TRITANOPIA:
            tritanopia_button.button_pressed = true

    # Set text scale buttons
    match accessibility_manager.text_scale:
        AccessibilityManager.TextScale.SMALL:
            small_text_button.button_pressed = true
        AccessibilityManager.TextScale.NORMAL:
            normal_text_button.button_pressed = true
        AccessibilityManager.TextScale.LARGE:
            large_text_button.button_pressed = true

    # Set toggles
    screen_shake_check.button_pressed = accessibility_manager.screen_shake_enabled
    keyboard_nav_check.button_pressed = accessibility_manager.keyboard_navigation_enabled

func setup_keyboard_navigation() -> void:
    # Set up focus neighbors for keyboard navigation
    normal_button.focus_neighbor_bottom = deuteranopia_button.get_path()
    deuteranopia_button.focus_neighbor_top = normal_button.get_path()
    deuteranopia_button.focus_neighbor_bottom = protanopia_button.get_path()
    protanopia_button.focus_neighbor_top = deuteranopia_button.get_path()
    protanopia_button.focus_neighbor_bottom = tritanopia_button.get_path()
    tritanopia_button.focus_neighbor_top = protanopia_button.get_path()

    # Set initial focus
    normal_button.grab_focus()

func _on_colorblind_mode_changed(mode: AccessibilityManager.ColorblindMode) -> void:
    accessibility_manager.set_colorblind_mode(mode)

func _on_text_scale_changed(scale: AccessibilityManager.TextScale) -> void:
    accessibility_manager.set_text_scale(scale)

func _on_screen_shake_toggled(enabled: bool) -> void:
    accessibility_manager.set_screen_shake_enabled(enabled)

func _on_keyboard_nav_toggled(enabled: bool) -> void:
    accessibility_manager.set_keyboard_navigation_enabled(enabled)

func _on_rebind_controls_pressed() -> void:
    # Open control rebinding UI
    # This would open a separate scene for control customization
    print("Control rebinding UI would open here")
    # TODO: Implement control rebinding scene

func _on_reset_pressed() -> void:
    accessibility_manager.reset_to_defaults()
    load_current_settings()

func _on_close_pressed() -> void:
    queue_free()

func _input(event: InputEvent) -> void:
    # Handle keyboard navigation
    if not accessibility_manager.keyboard_navigation_enabled:
        return

    if event.is_action_pressed("ui_cancel"):
        _on_close_pressed()
        accept_event()
