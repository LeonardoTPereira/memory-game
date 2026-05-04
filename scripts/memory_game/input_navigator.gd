class_name InputNavigator
extends Node


var _cards: Array = []
var _focused_index: int = -1
var _game_session: Node


func set_cards(cards: Array) -> void:
	_cards = cards
	if _cards.is_empty():
		_focused_index = -1
		return
	_focused_index = 0
	_apply_focus()


func set_game_session(game_session: Node) -> void:
	_game_session = game_session
	_apply_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _cards.is_empty():
		return
	if event.is_action_pressed("ui_left"):
		_move_focus(Vector2i(-1, 0))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_move_focus(Vector2i(1, 0))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_move_focus(Vector2i(0, -1))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_move_focus(Vector2i(0, 1))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_activate_focused_card()
		get_viewport().set_input_as_handled()


func _move_focus(delta: Vector2i) -> void:
	var columns: int = _get_columns()
	if columns <= 0:
		return
	var rows: int = int(ceil(float(_cards.size()) / float(columns)))
	var current_row: int = int(floor(float(_focused_index) / float(columns)))
	var current_col: int = _focused_index % columns
	var target_row: int = clampi(current_row + delta.y, 0, rows - 1)
	var target_col: int = clampi(current_col + delta.x, 0, columns - 1)
	var target_index: int = (target_row * columns) + target_col
	if target_index >= _cards.size():
		target_index = _cards.size() - 1
	_focused_index = target_index
	_apply_focus()


func _activate_focused_card() -> void:
	if _focused_index < 0 or _focused_index >= _cards.size():
		return
	if _game_session != null and _game_session.has_method("activate_focused_card"):
		_game_session.call("activate_focused_card", _cards[_focused_index])


func _apply_focus() -> void:
	if _focused_index < 0 or _focused_index >= _cards.size():
		return
	if _game_session != null and _game_session.has_method("apply_focus_to_card"):
		_game_session.call("apply_focus_to_card", _cards[_focused_index])


func _get_columns() -> int:
	if _game_session != null:
		var grid: GridContainer = _game_session.get_node_or_null("MarginContainer/VBox/BoardGrid")
		if grid != null and grid.columns > 0:
			return grid.columns
	return 4
