## TestArena Controller
##
## Manages the test arena for COMBAT-001 development.
## Displays FPS counter and handles quit input.
extends Node2D

@onready var fps_label: Label = $UI/FPSLabel


func _ready() -> void:
	# Set window title for development
	DisplayServer.window_set_title("Pond Conspiracy - COMBAT-001 Test Arena")


func _process(_delta: float) -> void:
	# Handle ESC to quit
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()


func _on_fps_timer_timeout() -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
