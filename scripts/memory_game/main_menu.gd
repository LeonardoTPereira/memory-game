extends Control
class_name MainMenu

signal start_game_requested

@onready var _start_button: Button = %StartButton


func _ready() -> void:
	if _start_button != null and not _start_button.pressed.is_connected(_on_start_pressed):
		_start_button.pressed.connect(_on_start_pressed)


func _on_start_pressed() -> void:
	start_game_requested.emit()
