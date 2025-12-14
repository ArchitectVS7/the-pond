## document_viewer.gd
## BOARD-011: Document viewer popup for displaying data log content
## BOARD-012: TL;DR/Full text toggle functionality
## BOARD-015: Screen reader accessibility support
##
## Displays data log content in a centered popup with smooth animations,
## toggle between summary and full text, and accessibility features.

class_name DocumentViewer extends Control

## Signals
signal viewer_closed()

## Tunable Parameters (BOARD-011)
@export_group("Viewer Dimensions")
## Width of the viewer panel in pixels
@export var viewer_width: int = 600

## Height of the viewer panel in pixels
@export var viewer_height: int = 400

@export_group("Animation Settings")
## Duration of open/close animations in seconds
@export var animation_duration: float = 0.3

## Scale effect when opening (overshoot for bounce effect)
@export var open_scale_overshoot: float = 1.05

## Node references
@onready var overlay: ColorRect = $Overlay
@onready var center_container: CenterContainer = $CenterContainer
@onready var panel: Panel = $CenterContainer/Panel
@onready var title_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/HeaderHBox/TitleLabel
@onready var close_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/HeaderHBox/CloseButton
@onready var toggle_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ToggleButtonHBox/ToggleModeButton
@onready var content_label: RichTextLabel = $CenterContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/ContentLabel

## State
var current_data: DataLogResource = null
var showing_full_text: bool = false


func _ready() -> void:
	# Start hidden
	hide()
	modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)

	# Apply viewer dimensions
	panel.custom_minimum_size = Vector2(viewer_width, viewer_height)

	# Setup accessibility (BOARD-015)
	_setup_accessibility()


## Setup accessibility properties (BOARD-015)
func _setup_accessibility() -> void:
	# Set accessibility name for screen readers
	accessibility_name = "Document Viewer Dialog"
	accessibility_description = "Displays detailed information about discovered data logs"

	# Make sure buttons are accessible
	if close_button:
		close_button.accessibility_name = "Close Document Viewer"
		close_button.accessibility_description = "Close this document and return to the conspiracy board"

	if toggle_button:
		toggle_button.accessibility_name = "Toggle Text View"
		_update_toggle_accessibility()


## Update toggle button accessibility based on current state (BOARD-015)
func _update_toggle_accessibility() -> void:
	if not toggle_button:
		return

	if showing_full_text:
		toggle_button.accessibility_description = "Switch to summary view of this document"
	else:
		toggle_button.accessibility_description = "Switch to full text view of this document"


## Show the viewer with a data log (BOARD-011)
func show_document(data: DataLogResource) -> void:
	if not data or not data.discovered:
		return

	current_data = data
	showing_full_text = false

	# Update content
	_update_content()

	# Update accessibility
	accessibility_description = "Viewing document: " + data.title

	# Show with animation
	show()
	_play_open_animation()


## Update the displayed content based on current state (BOARD-012)
func _update_content() -> void:
	if not current_data:
		return

	# Update title
	title_label.text = current_data.title

	# Update content based on toggle state
	if showing_full_text:
		content_label.text = current_data.full_text
		toggle_button.text = "Show Summary"
	else:
		content_label.text = current_data.summary
		toggle_button.text = "Show Full Text"

	# Update toggle button accessibility
	_update_toggle_accessibility()


## Play open animation (BOARD-011)
func _play_open_animation() -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	# Fade in overlay and viewer
	tween.tween_property(self, "modulate:a", 1.0, animation_duration)

	# Scale animation with overshoot
	tween.tween_property(panel, "scale", Vector2(open_scale_overshoot, open_scale_overshoot), animation_duration * 0.6)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# Scale back to normal
	tween.chain().tween_property(panel, "scale", Vector2.ONE, animation_duration * 0.4)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)


## Play close animation (BOARD-011)
func _play_close_animation() -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, animation_duration)

	# Scale down
	tween.tween_property(panel, "scale", Vector2(0.8, 0.8), animation_duration)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Hide after animation
	tween.finished.connect(func(): hide())


## Close the viewer
func close_viewer() -> void:
	_play_close_animation()
	viewer_closed.emit()


## Handle close button press
func _on_close_button_pressed() -> void:
	close_viewer()


## Handle overlay click (click outside to close) (BOARD-011)
func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			close_viewer()


## Handle toggle mode button press (BOARD-012)
func _on_toggle_mode_button_pressed() -> void:
	if not current_data:
		return

	# Toggle state
	showing_full_text = not showing_full_text

	# Update display
	_update_content()


## Handle keyboard input for accessibility (BOARD-014)
func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed:
			# Escape closes viewer (BOARD-014)
			if key_event.keycode == KEY_ESCAPE:
				close_viewer()
				accept_event()
