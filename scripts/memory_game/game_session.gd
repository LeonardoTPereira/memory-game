class_name GameSession
extends Control


const CardScript := preload("res://scripts/memory_game/card.gd")


signal pair_matched(pair_id: int)
signal wrong_guess_made
signal game_finished(final_score: int)


@export var card_scene: PackedScene = preload("res://scenes/memory_game/card.tscn")
@export var mismatch_flip_delay_seconds: float = 0.2


var _board_manager: BoardManager = BoardManager.new()
var _cards_by_index: Array[Variant] = []
var _pending_cards: Array[Variant] = []
var _wrong_guess_count: int = 0
var _is_game_finished: bool = false


@onready var _score_label: Label = get_node_or_null("MarginContainer/VBox/Header/ScoreLabel")
@onready var _wrong_label: Label = get_node_or_null("MarginContainer/VBox/Header/WrongGuessesLabel")
@onready var _feedback_label: Label = get_node_or_null("MarginContainer/VBox/FeedbackLabel")
@onready var _board_grid: GridContainer = get_node_or_null("MarginContainer/VBox/BoardGrid")


func _ready() -> void:
	if not _board_manager.pair_matched.is_connected(_on_pair_matched):
		_board_manager.pair_matched.connect(_on_pair_matched)
	if not _board_manager.wrong_guess.is_connected(_on_wrong_guess):
		_board_manager.wrong_guess.connect(_on_wrong_guess)
	if not _board_manager.game_finished.is_connected(_on_game_finished):
		_board_manager.game_finished.connect(_on_game_finished)
	_update_ui()


func configure_rng_seed(seed_value: int) -> void:
	_board_manager.configure_rng_seed(seed_value)


func set_mismatch_flip_delay_seconds(delay_seconds: float) -> void:
	mismatch_flip_delay_seconds = max(0.0, delay_seconds)


func start_game(difficulty: String, pair_pool: Array[int]) -> void:
	var board_values: Array[int] = _board_manager.setup_game(difficulty, pair_pool)
	_cards_by_index.clear()
	_pending_cards.clear()
	_wrong_guess_count = 0
	_is_game_finished = false
	_build_board_ui(board_values, difficulty)
	_set_feedback_text("")
	_update_ui()


func get_board_snapshot() -> Array[int]:
	return _board_manager.get_board()


func get_card_at(index: int) -> Variant:
	if index < 0 or index >= _cards_by_index.size():
		return null
	return _cards_by_index[index]


func get_feedback_text() -> String:
	if _feedback_label == null:
		return ""
	return _feedback_label.text


func get_score_label_text() -> String:
	if _score_label == null:
		return ""
	return _score_label.text


func is_game_finished() -> bool:
	return _is_game_finished


func _build_board_ui(board_values: Array[int], difficulty: String) -> void:
	if _board_grid == null:
		return
	for child: Node in _board_grid.get_children():
		_board_grid.remove_child(child)
		child.queue_free()

	var grid_size: Vector2i = _board_manager.get_grid_size(difficulty)
	_board_grid.columns = grid_size.x

	for index: int in range(board_values.size()):
		var card: Variant = _spawn_card()
		card.configure(board_values[index], index)
		card.card_selected.connect(_on_card_selected)
		_cards_by_index.append(card)
		_board_grid.add_child(card)


func _spawn_card() -> Variant:
	if card_scene != null:
		var instance: Node = card_scene.instantiate()
		if instance != null and instance.has_method("configure") and instance.has_method("trigger_select"):
			return instance
	return CardScript.new()


func _on_card_selected(card: Variant) -> void:
	if _is_game_finished:
		return
	if _pending_cards.has(card):
		return
	if _pending_cards.size() >= 2:
		return

	card.flip_face_up()
	_pending_cards.append(card)
	_board_manager.select_card(card.board_index)


func _on_pair_matched(pair_id: int) -> void:
	for card: Variant in _pending_cards:
		if card.pair_id == pair_id:
			card.set_matched()
	_pending_cards.clear()
	_set_feedback_text("CORRETO")
	_update_ui()
	pair_matched.emit(pair_id)


func _on_wrong_guess() -> void:
	_wrong_guess_count += 1
	_set_feedback_text("ERRADO")
	_update_ui()
	wrong_guess_made.emit()
	_flip_back_pending_cards_after_delay()


func _on_game_finished(final_score: int) -> void:
	_is_game_finished = true
	_set_feedback_text("FINAL")
	_update_score_label(final_score)
	game_finished.emit(final_score)


func _flip_back_pending_cards_after_delay() -> void:
	var cards_to_reset: Array[Variant] = _pending_cards.duplicate()
	_pending_cards.clear()
	await get_tree().create_timer(mismatch_flip_delay_seconds).timeout
	for card: Variant in cards_to_reset:
		if is_instance_valid(card) and card.face_state == CardScript.FaceState.FACE_UP:
			card.flip_face_down()


func _set_feedback_text(value: String) -> void:
	if _feedback_label != null:
		_feedback_label.text = value


func _update_ui() -> void:
	var score: int = ScoreCalculator.calculate(_board_manager.get_pairs_matched(), _board_manager.get_guesses())
	_update_score_label(score)
	if _wrong_label != null:
		_wrong_label.text = "Wrong: %d" % _wrong_guess_count


func _update_score_label(score: int) -> void:
	if _score_label != null:
		_score_label.text = "Score: %d" % score
