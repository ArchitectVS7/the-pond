extends CanvasLayer
class_name BossDialogue

@export var display_time: float = 3.0
@export var font_size: int = 16
@export var fade_duration: float = 0.3

@onready var dialogue_panel: Panel = $DialoguePanel
@onready var dialogue_label: Label = $DialoguePanel/Label

var dialogue_queue: Array[String] = []
var is_displaying: bool = false

func _ready() -> void:
	visible = false
	if dialogue_label:
		dialogue_label.add_theme_font_size_override("font_size", font_size)

func show_dialogue(text: String) -> void:
	dialogue_queue.append(text)
	if not is_displaying:
		_process_queue()

func _process_queue() -> void:
	if dialogue_queue.is_empty():
		is_displaying = false
		return

	is_displaying = true
	dialogue_label.text = dialogue_queue[0]

	# Fade in
	modulate.a = 0
	visible = true
	var tween_in = create_tween()
	tween_in.tween_property(self, "modulate:a", 1.0, fade_duration)
	await tween_in.finished

	# Display
	await get_tree().create_timer(display_time).timeout

	# Fade out
	var tween_out = create_tween()
	tween_out.tween_property(self, "modulate:a", 0.0, fade_duration)
	await tween_out.finished

	visible = false
	dialogue_queue.pop_front()
	_process_queue()

func clear_queue() -> void:
	dialogue_queue.clear()
	visible = false
	is_displaying = false
