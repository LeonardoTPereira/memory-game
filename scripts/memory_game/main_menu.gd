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
	_configure_focus_chain()
	_connect_hover_focus(_easy_button)
	_connect_hover_focus(_medium_button)
	_connect_hover_focus(_hard_button)
	if _easy_button != null:
		_easy_button.grab_focus.call_deferred()


func _connect_button(button: Button, difficulty: String) -> void:
	if button == null:
		return
	if not button.pressed.is_connected(_on_difficulty_pressed.bind(difficulty)):
		button.pressed.connect(_on_difficulty_pressed.bind(difficulty))


func _connect_hover_focus(button: Button) -> void:
	if button == null:
		return
	if not button.mouse_entered.is_connected(_on_button_mouse_entered.bind(button)):
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))


func _configure_focus_chain() -> void:
	if _easy_button == null or _medium_button == null or _hard_button == null:
		return
	_easy_button.focus_neighbor_bottom = _easy_button.get_path_to(_medium_button)
	_medium_button.focus_neighbor_top = _medium_button.get_path_to(_easy_button)
	_medium_button.focus_neighbor_bottom = _medium_button.get_path_to(_hard_button)
	_hard_button.focus_neighbor_top = _hard_button.get_path_to(_medium_button)


func _on_button_mouse_entered(button: Button) -> void:
	if button != null:
		button.grab_focus()


func _on_difficulty_pressed(difficulty: String) -> void:
	var board: Node = GameBoardScene.instantiate()
	get_tree().root.add_child(board)
	if board.has_method("start_game"):
		board.call("start_game", difficulty)
	queue_free()
