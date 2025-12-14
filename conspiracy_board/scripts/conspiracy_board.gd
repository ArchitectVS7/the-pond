## ConspiracyBoard - Main conspiracy board controller
## Manages the corkboard background and visual effects
class_name ConspiracyBoard
extends Control

## Tunable parameter: Edge darkening intensity
@export_range(0.0, 1.0) var vignette_strength: float = 0.2

## Tunable parameter: Vignette start radius
@export_range(0.0, 1.0) var vignette_radius: float = 0.8

@export_group("Pin Snap Detection (BOARD-007)")
## Distance in pixels within which a card will snap to a pin
@export var snap_distance: float = 50.0

## Duration of the snap animation in seconds
@export var snap_animation_duration: float = 0.1

## Pin positions on the corkboard (configurable at runtime or in editor)
@export var pin_positions: Array[Vector2] = [
	Vector2(200, 200), Vector2(500, 200), Vector2(800, 200),
	Vector2(200, 400), Vector2(500, 400), Vector2(800, 400),
	Vector2(200, 600), Vector2(500, 600), Vector2(800, 600)
]

@export_group("Audio/Visual Feedback (BOARD-010)")
## Duration of the pulse animation when snapping to pin (seconds)
@export var pulse_duration: float = 0.2

## Scale multiplier for pulse effect (1.1 = 10% larger)
@export var pulse_scale: float = 1.1

@export_group("Progress Tracking (BOARD-013)")
## Total number of discoverable data logs
@export var progress_total: int = 7

@export_group("Keyboard Navigation (BOARD-014)")
## Width of focus border for accessibility
@export var focus_border_width: float = 3.0

## Color of focus border for keyboard navigation
@export var focus_border_color: Color = Color.YELLOW

## Node references
@onready var background: ColorRect = $Background
@onready var snap_sound: AudioStreamPlayer = $SnapSound if has_node("SnapSound") else null
@onready var progress_label: Label = $ProgressLabel if has_node("ProgressLabel") else null

## Reference to the vignette shader material (if enabled)
var vignette_material: ShaderMaterial = null

## Keyboard navigation state (BOARD-014)
var focusable_cards: Array[DataLogCard] = []
var current_focus_index: int = -1

## Discovery tracking (BOARD-013)
var discovered_count: int = 0


func _ready() -> void:
	# Set the control to fill the viewport
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Initialize vignette effect if shader is available
	_setup_vignette()

	# Ensure proper rendering order
	background.z_index = -1

	# Connect drag events from all DataLogCard children (BOARD-007)
	_connect_card_signals()

	# Update progress display (BOARD-013)
	_update_progress_display()

	# Setup accessibility (BOARD-015)
	_setup_accessibility()

	# Setup keyboard navigation (BOARD-014)
	_setup_keyboard_navigation()


## Setup vignette shader effect for depth
func _setup_vignette() -> void:
	if background.material and background.material is ShaderMaterial:
		vignette_material = background.material as ShaderMaterial
		_update_vignette_parameters()


## Update vignette shader parameters
func _update_vignette_parameters() -> void:
	if vignette_material:
		vignette_material.set_shader_parameter("vignette_strength", vignette_strength)
		vignette_material.set_shader_parameter("vignette_radius", vignette_radius)


## Set vignette strength at runtime
func set_vignette_strength(strength: float) -> void:
	vignette_strength = clamp(strength, 0.0, 1.0)
	_update_vignette_parameters()


## Set vignette radius at runtime
func set_vignette_radius(radius: float) -> void:
	vignette_radius = clamp(radius, 0.0, 1.0)
	_update_vignette_parameters()


## Get the background color
func get_background_color() -> Color:
	return background.color if background else Color.WHITE


## Set the background color
func set_background_color(color: Color) -> void:
	if background:
		background.color = color


## Connect signals from all DataLogCard children (BOARD-007, BOARD-013)
func _connect_card_signals() -> void:
	for child in get_children():
		if child is DataLogCard:
			var card := child as DataLogCard
			# Connect to drag_ended signal for snap detection
			if not card.drag_ended.is_connected(_on_card_drag_ended):
				card.drag_ended.connect(_on_card_drag_ended)
			# Connect to discovery_changed signal for progress tracking (BOARD-013)
			if not card.discovery_changed.is_connected(_on_card_discovery_changed):
				card.discovery_changed.connect(_on_card_discovery_changed)
			# Track discovered cards
			if card.is_discovered():
				discovered_count += 1
			# Add to focusable cards list (BOARD-014)
			focusable_cards.append(card)


## Handle card drag end event and snap to nearest pin (BOARD-007)
func _on_card_drag_ended(card: DataLogCard) -> void:
	var card_pos := card.global_position
	var closest_pin: Vector2 = Vector2.ZERO
	var closest_dist: float = INF

	# Find the closest pin position
	for pin in pin_positions:
		var dist := card_pos.distance_to(pin)
		if dist < closest_dist:
			closest_dist = dist
			closest_pin = pin

	# Snap if within threshold
	if closest_dist <= snap_distance:
		_snap_card_to_pin(card, closest_pin)
	# Otherwise, card stays where it was dropped (no action needed)


## Snap card to pin with smooth animation (BOARD-007, BOARD-010)
func _snap_card_to_pin(card: DataLogCard, pin: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(card, "global_position", pin, snap_animation_duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Play snap sound and pulse animation (BOARD-010)
	_play_snap_feedback(card)


## Add a card to the board and connect its signals (BOARD-007)
func add_card(card: DataLogCard) -> void:
	add_child(card)
	if not card.drag_ended.is_connected(_on_card_drag_ended):
		card.drag_ended.connect(_on_card_drag_ended)


## Get the nearest pin position to a given position (BOARD-007)
func get_nearest_pin(position: Vector2) -> Vector2:
	var closest_pin: Vector2 = Vector2.ZERO
	var closest_dist: float = INF

	for pin in pin_positions:
		var dist := position.distance_to(pin)
		if dist < closest_dist:
			closest_dist = dist
			closest_pin = pin

	return closest_pin


## Check if a position is within snap distance of any pin (BOARD-007)
func is_within_snap_distance(position: Vector2) -> bool:
	for pin in pin_positions:
		if position.distance_to(pin) <= snap_distance:
			return true
	return false


## Play snap feedback (audio + visual pulse) (BOARD-010)
func _play_snap_feedback(card: DataLogCard) -> void:
	# Play snap sound (placeholder - muted if no audio file)
	if snap_sound and snap_sound.stream:
		snap_sound.play()

	# Play pulse animation
	var pulse_tween := create_tween()
	pulse_tween.set_parallel(true)

	# Scale up
	pulse_tween.tween_property(card, "scale", Vector2(pulse_scale, pulse_scale), pulse_duration * 0.5)
	pulse_tween.set_ease(Tween.EASE_OUT)
	pulse_tween.set_trans(Tween.TRANS_CUBIC)

	# Scale back down
	pulse_tween.chain().tween_property(card, "scale", Vector2.ONE, pulse_duration * 0.5)
	pulse_tween.set_ease(Tween.EASE_IN)
	pulse_tween.set_trans(Tween.TRANS_CUBIC)


## Handle card discovery change (BOARD-013)
func _on_card_discovery_changed(card: DataLogCard, is_discovered: bool) -> void:
	if is_discovered:
		discovered_count += 1
	else:
		discovered_count -= 1

	# Update progress display
	_update_progress_display()


## Update progress label display (BOARD-013)
func _update_progress_display() -> void:
	if progress_label:
		progress_label.text = "%d of %d discovered" % [discovered_count, progress_total]


## Setup accessibility properties (BOARD-015)
func _setup_accessibility() -> void:
	accessibility_name = "Conspiracy Board"
	accessibility_description = "Interactive board for discovering and connecting data logs"


## Setup keyboard navigation (BOARD-014)
func _setup_keyboard_navigation() -> void:
	# Update focusable cards list
	focusable_cards.clear()
	for child in get_children():
		if child is DataLogCard:
			focusable_cards.append(child as DataLogCard)

	# Focus first card if available
	if focusable_cards.size() > 0:
		current_focus_index = 0
		_update_focus_visual()


## Handle keyboard input (BOARD-014)
func _input(event: InputEvent) -> void:
	if focusable_cards.is_empty():
		return

	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed:
			match key_event.keycode:
				KEY_TAB:
					# Cycle through cards
					if key_event.shift_pressed:
						_focus_previous_card()
					else:
						_focus_next_card()
					accept_event()
				KEY_LEFT, KEY_UP:
					# Navigate to previous card
					_focus_previous_card()
					accept_event()
				KEY_RIGHT, KEY_DOWN:
					# Navigate to next card
					_focus_next_card()
					accept_event()
				KEY_ENTER, KEY_SPACE:
					# Activate focused card (open viewer)
					if current_focus_index >= 0 and current_focus_index < focusable_cards.size():
						var card := focusable_cards[current_focus_index]
						if card.is_discovered():
							card.card_clicked.emit(card)
					accept_event()


## Focus next card (BOARD-014)
func _focus_next_card() -> void:
	if focusable_cards.is_empty():
		return

	current_focus_index = (current_focus_index + 1) % focusable_cards.size()
	_update_focus_visual()


## Focus previous card (BOARD-014)
func _focus_previous_card() -> void:
	if focusable_cards.is_empty():
		return

	current_focus_index = (current_focus_index - 1 + focusable_cards.size()) % focusable_cards.size()
	_update_focus_visual()


## Update focus visual indicator (BOARD-014)
func _update_focus_visual() -> void:
	# Clear all focus indicators
	for card in focusable_cards:
		_clear_focus_border(card)

	# Add focus indicator to current card
	if current_focus_index >= 0 and current_focus_index < focusable_cards.size():
		var focused_card := focusable_cards[current_focus_index]
		_draw_focus_border(focused_card)


## Draw focus border on card (BOARD-014)
func _draw_focus_border(card: DataLogCard) -> void:
	# Create a ColorRect border if it doesn't exist
	var border_name := "FocusBorder"
	var border: ColorRect = null

	if card.has_node(border_name):
		border = card.get_node(border_name) as ColorRect
	else:
		border = ColorRect.new()
		border.name = border_name
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(border)

	# Position and style the border
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	border.color = Color.TRANSPARENT

	# Create border using StyleBoxFlat
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_width_left = int(focus_border_width)
	style.border_width_top = int(focus_border_width)
	style.border_width_right = int(focus_border_width)
	style.border_width_bottom = int(focus_border_width)
	style.border_color = focus_border_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4

	border.add_theme_stylebox_override("panel", style)
	border.show()


## Clear focus border from card (BOARD-014)
func _clear_focus_border(card: DataLogCard) -> void:
	var border_name := "FocusBorder"
	if card.has_node(border_name):
		var border := card.get_node(border_name)
		border.hide()
