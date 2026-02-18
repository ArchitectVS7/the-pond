extends Control
class_name PollutionMeter
## Visual pollution meter on HUD showing environmental damage
## Epic-005: Pollution Index UI - Complete implementation with mutation system stubs

# ============================================================================
# STORY POLLUTION-001: ProgressBar-based pollution meter
# ============================================================================

## Meter dimensions and positioning
@export var meter_width: int = 150
@export var meter_height: int = 20
@export var meter_position: Vector2 = Vector2(20, 20)
@export var fill_direction: int = 0  # 0=left-to-right

## Current pollution value (0-100)
var pollution_value: float = 0.0:
	set(value):
		pollution_value = clamp(value, 0.0, 100.0)
		_update_meter()

@onready var progress_bar: ProgressBar = $ProgressBar

# ============================================================================
# STORY POLLUTION-002: Color coding (green/yellow/red)
# ============================================================================

## Color thresholds and appearance
@export var color_low: Color = Color.GREEN
@export var color_mid: Color = Color.YELLOW
@export var color_high: Color = Color.RED
@export var threshold_low: float = 0.33
@export var threshold_high: float = 0.67
@export var color_lerp_enabled: bool = true

# ============================================================================
# STORY POLLUTION-003: Tooltip with ecosystem messages
# ============================================================================

## Tooltip messages by severity
@export var message_low: String = "The pond is healthy. Keep it that way!"
@export var message_mid: String = "Pollution is building up... The frogs are worried."
@export var message_high: String = "CRITICAL: Ecosystem in danger! Corporate greed is killing the pond!"
@export var tooltip_delay: float = 0.5

# ============================================================================
# STORY POLLUTION-004: Mutation binding stubs (pending EPIC-006)
# ============================================================================

## Tunable mutation weights (will be used when EPIC-006 is complete)
@export var pollution_per_mutation: float = 15.0
@export var oil_mutation_weight: float = 1.5
@export var toxic_mutation_weight: float = 1.2
@export var mercury_mutation_weight: float = 2.0
@export var max_pollution: float = 100.0

## Stub: Track pollution mutations
var _pollution_mutation_count: int = 0

# ============================================================================
# STORY POLLUTION-005: Event system stubs
# ============================================================================

## Animation settings for pollution updates
@export var update_animation: bool = true
@export var pulse_duration: float = 0.3
@export var pulse_scale: float = 1.1

# ============================================================================
# Lifecycle Methods
# ============================================================================

func _ready() -> void:
	custom_minimum_size = Vector2(meter_width, meter_height)
	position = meter_position

	# Initialize progress bar
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = pollution_value

	# Set up tooltip
	tooltip_text = _get_tooltip_message()

	_update_meter()

	# Connect to EventBus when mutation system is ready (EPIC-006)
	# This is a stub - will be activated when EventBus.mutation_selected signal exists
	# Connect to EventBus when mutation system is ready (EPIC-006)
	if EventBus.has_signal("mutation_selected"):
		EventBus.mutation_selected.connect(_on_mutation_selected)

# ============================================================================
# STORY POLLUTION-001: Core meter update logic
# ============================================================================

func _update_meter() -> void:
	if not is_node_ready():
		return

	progress_bar.value = pollution_value
	tooltip_text = _get_tooltip_message()
	_update_color()

	# Emit signal for other systems
	# Emit signal for other systems
	# EventBus is an autoload, so we access it directly
	if EventBus.has_signal("pollution_changed"):
		EventBus.pollution_changed.emit(int(pollution_value))

# ============================================================================
# STORY POLLUTION-002: Color coding implementation
# ============================================================================

func _update_color() -> void:
	var normalized = pollution_value / 100.0
	var target_color: Color

	if normalized <= threshold_low:
		if color_lerp_enabled:
			target_color = color_low.lerp(color_mid, normalized / threshold_low)
		else:
			target_color = color_low
	elif normalized <= threshold_high:
		if color_lerp_enabled:
			var t = (normalized - threshold_low) / (threshold_high - threshold_low)
			target_color = color_mid.lerp(color_high, t)
		else:
			target_color = color_mid
	else:
		if color_lerp_enabled:
			var t = (normalized - threshold_high) / (1.0 - threshold_high)
			target_color = color_high.lerp(Color.DARK_RED, t)
		else:
			target_color = color_high

	# Update ProgressBar StyleBox fill color
	var style = StyleBoxFlat.new()
	style.bg_color = target_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	progress_bar.add_theme_stylebox_override("fill", style)

	# Update background
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	progress_bar.add_theme_stylebox_override("background", bg_style)

# ============================================================================
# STORY POLLUTION-003: Tooltip system
# ============================================================================

func _get_tooltip_message() -> String:
	var normalized = pollution_value / 100.0
	if normalized <= threshold_low:
		return message_low
	elif normalized <= threshold_high:
		return message_mid
	else:
		return message_high

func _make_custom_tooltip(for_text: String) -> Object:
	var label = Label.new()
	label.text = _get_tooltip_message()
	label.add_theme_font_size_override("font_size", 14)

	# Add styling
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(label)

	return panel

# ============================================================================
# STORY POLLUTION-004: Mutation calculation stubs
# ============================================================================

## Calculate pollution from mutations array (stub for EPIC-006)
func calculate_pollution_from_mutations(mutations: Array) -> float:
	var total = 0.0
	for mutation in mutations:
		if mutation.has("type") and mutation.type == "pollution":
			var weight = 1.0
			match mutation.get("subtype", ""):
				"oil":
					weight = oil_mutation_weight
				"toxic":
					weight = toxic_mutation_weight
				"mercury":
					weight = mercury_mutation_weight
			total += pollution_per_mutation * weight
	return min(total, max_pollution)

## Stub method for testing without mutation system
func set_pollution_mutations(count: int) -> void:
	_pollution_mutation_count = count
	pollution_value = count * pollution_per_mutation

## Manual pollution setter for testing
func set_pollution(value: float) -> void:
	pollution_value = value

# ============================================================================
# STORY POLLUTION-005: Event handling stubs
# ============================================================================

## Handle mutation selection event (stub for EPIC-006)
func _on_mutation_selected(mutation: Dictionary) -> void:
	if mutation.get("type", "") == "pollution":
		_pollution_mutation_count += 1
		pollution_value = calculate_pollution_from_mutations([mutation])
		if update_animation:
			_play_pulse_animation()

## Pulse animation on pollution update
func _play_pulse_animation() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(pulse_scale, pulse_scale), pulse_duration / 2)
	tween.tween_property(self, "scale", Vector2.ONE, pulse_duration / 2)
