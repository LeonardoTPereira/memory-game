class_name InputNavigator
extends Node


var _cards: Array[Variant] = []
var _focused_index: int = -1
var _game_session: Node


func set_cards(cards: Array) -> void:
	_cards = cards
	if _cards.is_empty():
		_focused_index = -1
		return
	_focused_index = _find_first_focusable_index()
	_apply_focus()


func set_game_session(game_session: Node) -> void:
	_game_session = game_session
	_apply_focus()


func set_focused_index(index: int) -> void:
	if _cards.is_empty():
		_focused_index = -1
		return
	if index >= 0 and index < _cards.size() and _is_focusable(index):
		_focused_index = index
	else:
		_focused_index = _find_first_focusable_index()
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
	if _focused_index < 0 or not _is_focusable(_focused_index):
		_focused_index = _find_first_focusable_index()
		_apply_focus()
		return
	var rows: int = int(ceil(float(_cards.size()) / float(columns)))
	var current_row: int = int(floor(float(_focused_index) / float(columns)))
	var current_col: int = _focused_index % columns
	var target_row: int = current_row + delta.y
	var target_col: int = current_col + delta.x
	while target_row >= 0 and target_row < rows and target_col >= 0 and target_col < columns:
		var target_index: int = _resolve_index(target_row, target_col, columns)
		if target_index >= 0 and _is_focusable(target_index):
			_focused_index = target_index
			_apply_focus()
			return
		target_row += delta.y
		target_col += delta.x


func _activate_focused_card() -> void:
	if _focused_index < 0 or _focused_index >= _cards.size():
		return
	if not _is_focusable(_focused_index):
		_focused_index = _find_first_focusable_index()
		_apply_focus()
		return
	if _game_session != null and _game_session.has_method("activate_focused_card"):
		_game_session.call("activate_focused_card", _cards[_focused_index])


func _apply_focus() -> void:
	if _focused_index < 0 or _focused_index >= _cards.size():
		return
	if _game_session != null and _game_session.has_method("apply_focus_to_card"):
		_game_session.call("apply_focus_to_card", _cards[_focused_index])
	var card: Variant = _cards[_focused_index]
	if card is Control and not card.has_focus():
		card.grab_focus.call_deferred()


func _get_columns() -> int:
	if _game_session != null:
		var grid: GridContainer = _game_session.get_node_or_null("MarginContainer/VBox/BoardGrid")
		if grid != null and grid.columns > 0:
			return grid.columns
	return 4


func _find_first_focusable_index() -> int:
	for index: int in range(_cards.size()):
		if _is_focusable(index):
			return index
	return -1


func _is_focusable(index: int) -> bool:
	if index < 0 or index >= _cards.size():
		return false
	var card: Variant = _cards[index]
	if card == null:
		return false
	if card is BaseButton:
		return not card.disabled
	return true


func _resolve_index(row: int, col: int, columns: int) -> int:
	var row_start: int = row * columns
	if row_start >= _cards.size():
		return -1
	var max_col: int = mini(columns - 1, (_cards.size() - 1) - row_start)
	var resolved_col: int = mini(col, max_col)
	return row_start + resolved_col
