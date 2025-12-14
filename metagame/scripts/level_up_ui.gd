extends CanvasLayer
class_name LevelUpUI

## Level-up UI that presents 3 random mutation choices
## Pauses game and resumes on selection

signal mutation_selected(mutation: MutationResource)

@export var options_count: int = 3
@export var card_width: int = 200
@export var card_height: int = 280
@export var card_spacing: int = 40
@export var animation_duration: float = 0.3

@onready var card_container: HBoxContainer = $CenterContainer/CardContainer
@onready var title_label: Label = $TitleLabel
@onready var background_overlay: ColorRect = $BackgroundOverlay

var mutation_pool: Array[MutationResource] = []
var current_options: Array[MutationResource] = []

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Setup background overlay
	if background_overlay:
		background_overlay.color = Color(0, 0, 0, 0.7)

## Show level-up screen with available mutations
func show_level_up(available_mutations: Array[MutationResource]) -> void:
	mutation_pool = available_mutations
	_select_random_options()
	_create_cards()
	_animate_in()
	get_tree().paused = true
	visible = true

	EventBus.level_up_shown.emit()

## Select random options from mutation pool
func _select_random_options() -> void:
	current_options.clear()
	var pool_copy = mutation_pool.duplicate()
	pool_copy.shuffle()

	for i in range(min(options_count, pool_copy.size())):
		current_options.append(pool_copy[i])

## Create mutation cards dynamically
func _create_cards() -> void:
	# Clear existing cards
	for child in card_container.get_children():
		child.queue_free()

	# Create new cards
	for mutation in current_options:
		var card = preload("res://metagame/scenes/MutationCard.tscn").instantiate()
		card.setup(mutation)
		card.selected.connect(_on_card_selected.bind(mutation))
		card_container.add_child(card)

## Handle card selection
func _on_card_selected(mutation: MutationResource) -> void:
	mutation_selected.emit(mutation)

	# Emit event bus signal
	EventBus.mutation_selected.emit(mutation.to_dict())

	_animate_out()

## Fade in animation
func _animate_in() -> void:
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, animation_duration)

## Fade out animation
func _animate_out() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, animation_duration)
	tween.tween_callback(_hide_and_resume)

## Hide UI and resume game
func _hide_and_resume() -> void:
	visible = false
	get_tree().paused = false
	EventBus.level_up_hidden.emit()
