extends Control
class_name MainMenu

const GameBoardScene := preload("res://scenes/memory_game/game_board.tscn")


@onready var _easy_button: Button = %EasyButton
@onready var _medium_button: Button = %MediumButton
@onready var _hard_button: Button = %HardButton


func _ready() -> void:
	_connect_button(_easy_button, "easy")
	_connect_button(_medium_button, "medium")
	_connect_button(_hard_button, "hard")


func _connect_button(button: Button, difficulty: String) -> void:
	if button == null:
		return
	if not button.pressed.is_connected(_on_difficulty_pressed.bind(difficulty)):
		button.pressed.connect(_on_difficulty_pressed.bind(difficulty))


func _on_difficulty_pressed(difficulty: String) -> void:
	var board: Node = GameBoardScene.instantiate()
	get_tree().root.add_child(board)
	if board.has_method("start_game"):
		board.call("start_game", difficulty)
	queue_free()
