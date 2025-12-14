extends PanelContainer
class_name MutationCard

## Individual mutation card UI component
## Displays mutation info and handles hover/click interactions

signal selected()

@export var hover_scale: float = 1.05
@export var hover_duration: float = 0.15

@onready var icon_rect: TextureRect = $VBoxContainer/IconRect
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var type_label: Label = $VBoxContainer/TypeLabel
@onready var description_label: RichTextLabel = $VBoxContainer/DescriptionLabel
@onready var pollution_label: Label = $VBoxContainer/PollutionLabel
@onready var synergy_hint_label: Label = $VBoxContainer/SynergyHintLabel

var mutation: MutationResource
var is_hovered: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

## Setup card with mutation data
func setup(mutation_data: MutationResource) -> void:
	mutation = mutation_data

	# Set icon
	if icon_rect and mutation.icon:
		icon_rect.texture = mutation.icon

	# Set name
	if name_label:
		name_label.text = mutation.mutation_name

	# Set type
	if type_label:
		var type_text = MutationResource.MutationType.keys()[mutation.type]
		type_label.text = type_text

		# Color code by type
		match mutation.type:
			MutationResource.MutationType.FROG:
				type_label.modulate = Color.GREEN
			MutationResource.MutationType.POLLUTION:
				type_label.modulate = Color.ORANGE_RED
			MutationResource.MutationType.HYBRID:
				type_label.modulate = Color.PURPLE

	# Set description
	if description_label:
		description_label.text = mutation.description

	# Set pollution cost
	if pollution_label:
		if mutation.pollution_cost > 0:
			pollution_label.text = "Pollution: +" + str(mutation.pollution_cost)
			pollution_label.modulate = Color.ORANGE_RED
			pollution_label.visible = true
		else:
			pollution_label.visible = false

	# Set synergy hint
	if synergy_hint_label:
		if mutation.synergy_hint != "":
			synergy_hint_label.text = "Synergy: " + mutation.synergy_hint
			synergy_hint_label.visible = true
		else:
			synergy_hint_label.visible = false

## Handle mouse hover
func _on_mouse_entered() -> void:
	is_hovered = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * hover_scale, hover_duration)

## Handle mouse exit
func _on_mouse_exited() -> void:
	is_hovered = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, hover_duration)

## Handle click
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit()
