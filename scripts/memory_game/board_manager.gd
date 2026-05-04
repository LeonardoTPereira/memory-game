class_name BoardManager
extends Node


signal pair_matched(pair_id: int)
signal wrong_guess
signal wrong_guess_made
signal game_finished(final_score: int)


const DIFFICULTY_GRID: Dictionary = {
	"easy": Vector2i(4, 4),
	"medium": Vector2i(6, 6),
	"hard": Vector2i(8, 8),
}


var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _board: Array[int] = []
var _matched_indices: Dictionary = {}
var _flipped_indices: Array[int] = []
var _pairs_matched: int = 0
var _total_pairs: int = 0
var _guesses: int = 0
var _is_game_finished: bool = false


func _init() -> void:
	_rng.randomize()


func configure_rng_seed(seed_value: int) -> void:
	_rng.seed = seed_value


func get_grid_size(difficulty: String) -> Vector2i:
	var key: String = difficulty.to_lower()
	if DIFFICULTY_GRID.has(key):
		return DIFFICULTY_GRID[key]
	return DIFFICULTY_GRID["easy"]


func setup_game(difficulty: String, pair_ids: Array[int]) -> Array[int]:
	var grid: Vector2i = get_grid_size(difficulty)
	var total_cards: int = grid.x * grid.y
	var pair_count: int = total_cards >> 1

	if pair_ids.size() < pair_count:
		push_error("BoardManager.setup_game: insufficient pair ids for selected difficulty")
		reset_game()
		return []

	_board.clear()
	var selected_pairs: Array = pair_ids.slice(0, pair_count)
	for value: Variant in selected_pairs:
		var pair_id: int = int(value)
		_board.append(pair_id)
		_board.append(pair_id)

	_shuffle_board()
	_matched_indices.clear()
	_flipped_indices.clear()
	_pairs_matched = 0
	_total_pairs = pair_count
	_guesses = 0
	_is_game_finished = false
	return get_board()


func select_card(index: int) -> void:
	if _is_game_finished:
		return
	if index < 0 or index >= _board.size():
		return
	if _matched_indices.has(index):
		return
	if _flipped_indices.has(index):
		return

	_flipped_indices.append(index)
	if _flipped_indices.size() == 2:
		_evaluate_selected_pair()


func reset_game() -> void:
	_board.clear()
	_matched_indices.clear()
	_flipped_indices.clear()
	_pairs_matched = 0
	_total_pairs = 0
	_guesses = 0
	_is_game_finished = false


func get_board() -> Array[int]:
	return _board.duplicate()


func get_pairs_matched() -> int:
	return _pairs_matched


func get_guesses() -> int:
	return _guesses


func is_game_finished() -> bool:
	return _is_game_finished


func _evaluate_selected_pair() -> void:
	var first_index: int = _flipped_indices[0]
	var second_index: int = _flipped_indices[1]
	_guesses += 1

	if _board[first_index] == _board[second_index]:
		var pair_id: int = _board[first_index]
		_matched_indices[first_index] = true
		_matched_indices[second_index] = true
		_pairs_matched += 1
		pair_matched.emit(pair_id)

		if _pairs_matched >= _total_pairs and _total_pairs > 0:
			_is_game_finished = true
			var final_score: int = ScoreCalculator.calculate(_pairs_matched, _guesses)
			game_finished.emit(final_score)
	else:
		wrong_guess_made.emit()
		wrong_guess.emit()

	_flipped_indices.clear()


func _shuffle_board() -> void:
	for index: int in range(_board.size() - 1, 0, -1):
		var pick_index: int = _rng.randi_range(0, index)
		var tmp: int = _board[index]
		_board[index] = _board[pick_index]
		_board[pick_index] = tmp
