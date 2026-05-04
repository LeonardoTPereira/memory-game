class_name HintController
extends RefCounted


signal hint_eligibility_changed(enabled: bool)
signal hint_used(pair_indices: Array[int])


const WRONG_GUESSES_FOR_HINT: int = 10


var _wrong_guess_count: int = 0
var _hint_enabled: bool = false
var _board_manager: Object
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init() -> void:
	_rng.randomize()


func configure_rng_seed(seed_value: int) -> void:
	_rng.seed = seed_value


func set_board_manager(board_manager: Object) -> void:
	_board_manager = board_manager


func register_wrong_guess() -> void:
	_wrong_guess_count += 1
	if not _hint_enabled and _wrong_guess_count >= WRONG_GUESSES_FOR_HINT:
		_hint_enabled = true
		hint_eligibility_changed.emit(true)


func is_hint_enabled() -> bool:
	return _hint_enabled


func get_wrong_guess_count() -> int:
	return _wrong_guess_count


func use_hint() -> Array[int]:
	if not _hint_enabled:
		return []
	if _board_manager == null or not _board_manager.has_method("get_unmatched_pairs"):
		return []

	var unmatched_pairs: Array = _board_manager.call("get_unmatched_pairs")
	if unmatched_pairs.is_empty():
		return []

	var pair_index: int = _rng.randi_range(0, unmatched_pairs.size() - 1)
	var selected_pair_raw: Variant = unmatched_pairs[pair_index]
	if not selected_pair_raw is Array:
		return []

	var selected_pair: Array[int] = []
	for value: Variant in selected_pair_raw:
		selected_pair.append(int(value))

	_reset_hint_state()
	hint_used.emit(selected_pair)
	return selected_pair


func _reset_hint_state() -> void:
	_wrong_guess_count = 0
	if _hint_enabled:
		_hint_enabled = false
		hint_eligibility_changed.emit(false)
