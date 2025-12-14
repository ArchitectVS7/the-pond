## data_log_card.gd
## Visual card component for displaying data logs on the conspiracy board
## Handles discovered/undiscovered states and preview text

class_name DataLogCard extends Control

## Signals
signal card_clicked(card: DataLogCard)
signal drag_started(card: DataLogCard)
signal drag_ended(card: DataLogCard)
signal discovery_changed(card: DataLogCard, is_discovered: bool)

## Tunable Parameters
@export_group("Card Appearance")
## Width of the card in pixels
@export var card_width: int = 200:
	set(value):
		card_width = value
		_update_card_size()

## Height of the card in pixels
@export var card_height: int = 150:
	set(value):
		card_height = value
		_update_card_size()

## Maximum characters to show in preview before truncation
@export var preview_max_chars: int = 80

## Opacity when card is undiscovered (0.0 - 1.0)
@export_range(0.0, 1.0) var undiscovered_alpha: float = 0.3

@export_group("Drag Settings (BOARD-006)")
## Pixels of movement before drag activates (prevents accidental drags on clicks)
@export var drag_threshold: float = 5.0

## Opacity while dragging (visual feedback)
@export_range(0.0, 1.0) var drag_opacity: float = 0.8

@export_group("Colors")
## Background color for discovered cards
@export var discovered_color: Color = Color(0.92, 0.88, 0.78, 1.0)  # Paper beige

## Background color for undiscovered cards
@export var undiscovered_color: Color = Color(0.3, 0.3, 0.3, 0.3)

## Title text color
@export var title_color: Color = Color(0.1, 0.1, 0.1, 1.0)

## Preview text color
@export var preview_color: Color = Color(0.2, 0.2, 0.2, 1.0)

## Data log resource containing the content
@export var data: DataLogResource:
	set(value):
		data = value
		_update_display()

## Node references
@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var preview_label: Label = $Panel/MarginContainer/VBoxContainer/PreviewLabel

## Internal state (BOARD-006 drag-drop system)
var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _mouse_down_position: Vector2 = Vector2.ZERO
var _has_moved_threshold: bool = false
var _original_z_index: int = 0


func _ready() -> void:
	_update_card_size()
	_update_display()
	_setup_input()
	# Store original z-index for drag-drop (BOARD-006)
	_original_z_index = z_index
	# Setup accessibility (BOARD-015)
	_setup_accessibility()


## Setup input handling for clicks and drags
func _setup_input() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)


## Handle GUI input events (BOARD-006 enhanced drag-drop)
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				_on_mouse_pressed(mouse_event.global_position)
			else:
				_on_mouse_released()
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_on_mouse_dragged(event.global_position)


## Handle mouse press (BOARD-006)
func _on_mouse_pressed(global_pos: Vector2) -> void:
	# Prepare for potential drag
	_mouse_down_position = global_pos
	_drag_offset = global_position - global_pos
	_has_moved_threshold = false


## Handle mouse release (BOARD-006)
func _on_mouse_released() -> void:
	if _is_dragging:
		# End drag
		_end_drag()
	elif not _has_moved_threshold:
		# This was a click, not a drag
		card_clicked.emit(self)


## Handle mouse drag (BOARD-006)
func _on_mouse_dragged(global_pos: Vector2) -> void:
	# Check if we've moved past threshold to start drag
	var distance = _mouse_down_position.distance_to(global_pos)

	if not _has_moved_threshold and distance > drag_threshold:
		_has_moved_threshold = true
		_start_drag()

	# Update position if dragging
	if _is_dragging:
		global_position = global_pos + _drag_offset


## Start dragging the card (BOARD-006)
func _start_drag() -> void:
	if _is_dragging:
		return

	_is_dragging = true

	# Bring to top (z-index update per acceptance criteria)
	z_index = 100

	# Reduce opacity for visual feedback
	var target_alpha = drag_opacity
	if data and not data.discovered:
		target_alpha *= undiscovered_alpha
	modulate.a = target_alpha

	# Emit signal
	drag_started.emit(self)


## End dragging the card (BOARD-006)
func _end_drag() -> void:
	if not _is_dragging:
		return

	_is_dragging = false

	# Restore z-index
	z_index = _original_z_index

	# Restore opacity
	if data and data.discovered:
		modulate.a = 1.0
	else:
		modulate.a = undiscovered_alpha

	# Emit signal for snap detection (handled by parent board)
	drag_ended.emit(self)


## Update card size based on parameters
func _update_card_size() -> void:
	if not is_inside_tree():
		return

	custom_minimum_size = Vector2(card_width, card_height)
	size = Vector2(card_width, card_height)


## Update visual display based on data and discovery state
func _update_display() -> void:
	if not is_inside_tree() or not data:
		return

	# Update title
	if title_label:
		title_label.text = data.title if data.discovered else "???"
		title_label.modulate = title_color

	# Update preview
	if preview_label:
		if data.discovered:
			preview_label.text = data.get_preview(preview_max_chars)
			preview_label.modulate = preview_color
		else:
			preview_label.text = "[LOCKED]"
			preview_label.modulate = Color(0.5, 0.5, 0.5, 0.7)

	# Update panel appearance
	if panel:
		_update_panel_style()


## Update panel visual style based on discovery state
func _update_panel_style() -> void:
	if not panel:
		return

	var style_box := StyleBoxFlat.new()

	if data and data.discovered:
		# Discovered state - paper texture appearance
		style_box.bg_color = discovered_color
		style_box.border_width_left = 2
		style_box.border_width_top = 2
		style_box.border_width_right = 2
		style_box.border_width_bottom = 2
		style_box.border_color = Color(0.4, 0.3, 0.2, 1.0)
		style_box.corner_radius_top_left = 4
		style_box.corner_radius_top_right = 4
		style_box.corner_radius_bottom_left = 4
		style_box.corner_radius_bottom_right = 4
		modulate.a = 1.0
	else:
		# Undiscovered state - faded/locked appearance
		style_box.bg_color = undiscovered_color
		style_box.border_width_left = 1
		style_box.border_width_top = 1
		style_box.border_width_right = 1
		style_box.border_width_bottom = 1
		style_box.border_color = Color(0.5, 0.5, 0.5, 0.5)
		style_box.corner_radius_top_left = 4
		style_box.corner_radius_top_right = 4
		style_box.corner_radius_bottom_left = 4
		style_box.corner_radius_bottom_right = 4
		modulate.a = undiscovered_alpha

	panel.add_theme_stylebox_override("panel", style_box)


## Set the discovered state of this card
func set_discovered(value: bool) -> void:
	if not data:
		return

	var was_discovered = data.discovered
	data.discovered = value
	_update_display()

	if was_discovered != value:
		discovery_changed.emit(self, value)


## Get the discovered state
func is_discovered() -> bool:
	return data and data.discovered


## Get the data log ID
func get_data_id() -> String:
	return data.id if data else ""


## Get the full text content
func get_full_text() -> String:
	return data.full_text if data and data.discovered else ""


## Animate discovery effect
func play_discovery_animation() -> void:
	if not data or not data.discovered:
		return

	# Simple fade-in animation
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15)
	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)


## Setup accessibility properties (BOARD-015)
func _setup_accessibility() -> void:
	# Set accessibility name based on data
	if data:
		accessibility_name = "Data Log Card: " + (data.title if data.discovered else "Undiscovered")
		_update_accessibility_state()
	else:
		accessibility_name = "Data Log Card"
		accessibility_description = "Empty data log card"


## Update accessibility description based on state (BOARD-015)
func _update_accessibility_state() -> void:
	if not data:
		return

	if data.discovered:
		accessibility_description = "Discovered data log: " + data.title + ". Press Enter to view details."
	else:
		accessibility_description = "Undiscovered data log. Locked content."
