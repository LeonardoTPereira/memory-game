extends GdUnitTestSuite


const BoardManagerScript := preload("res://scripts/memory_game/board_manager.gd")


func test_setup_game_generates_easy_medium_and_hard_grid_sizes() -> void:
	var manager = BoardManagerScript.new()
	var pool: Array[int] = _build_pair_pool(50)

	var easy_board: Array[int] = manager.setup_game("easy", pool)
	var medium_board: Array[int] = manager.setup_game("medium", pool)
	var hard_board: Array[int] = manager.setup_game("hard", pool)

	assert_that(easy_board.size()).is_equal(16)
	assert_that(medium_board.size()).is_equal(36)
	assert_that(hard_board.size()).is_equal(64)


func test_shuffle_algorithm_is_seeded_and_not_sequential_layout() -> void:
	var pool: Array[int] = _build_pair_pool(50)
	var manager_a = BoardManagerScript.new()
	var manager_b = BoardManagerScript.new()

	manager_a.configure_rng_seed(12345)
	manager_b.configure_rng_seed(12345)
	var board_a: Array[int] = manager_a.setup_game("easy", pool)
	var board_b: Array[int] = manager_b.setup_game("easy", pool)

	assert_that(board_a).is_equal(board_b)
	assert_that(board_a).is_not_equal(_unshuffled_layout(8))


func test_match_validation_emits_pair_matched_for_two_matching_flips() -> void:
	var manager = BoardManagerScript.new()
	manager.configure_rng_seed(321)
	manager.setup_game("easy", _build_pair_pool(50))

	var pair_match_counter: Dictionary = {"value": 0}
	manager.pair_matched.connect(func(_pair_id: int) -> void:
		pair_match_counter["value"] = int(pair_match_counter["value"]) + 1
	)

	var pair_indices: Array[int] = _find_matching_pair_indices(manager.get_board())
	manager.select_card(pair_indices[0])
	manager.select_card(pair_indices[1])

	assert_that(int(pair_match_counter["value"])).is_equal(1)
	assert_that(manager.get_pairs_matched()).is_equal(1)


func test_match_validation_emits_wrong_guess_for_mismatch() -> void:
	var manager = BoardManagerScript.new()
	manager.configure_rng_seed(999)
	manager.setup_game("easy", _build_pair_pool(50))

	var wrong_guess_counter: Dictionary = {"value": 0}
	manager.wrong_guess.connect(func() -> void:
		wrong_guess_counter["value"] = int(wrong_guess_counter["value"]) + 1
	)

	var mismatch_indices: Array[int] = _find_mismatch_indices(manager.get_board())
	manager.select_card(mismatch_indices[0])
	manager.select_card(mismatch_indices[1])

	assert_that(int(wrong_guess_counter["value"])).is_equal(1)
	assert_that(manager.get_pairs_matched()).is_equal(0)


func test_game_finished_emits_when_all_pairs_are_matched() -> void:
	var manager = BoardManagerScript.new()
	manager.configure_rng_seed(4242)
	manager.setup_game("easy", _build_pair_pool(50))

	var game_finished_counter: Dictionary = {"value": 0}
	manager.game_finished.connect(func(_final_score: int) -> void:
		game_finished_counter["value"] = int(game_finished_counter["value"]) + 1
	)

	var pair_map: Dictionary = _pair_indices_map(manager.get_board())
	for pair_id: int in pair_map.keys():
		var indices: Array[int] = pair_map[pair_id]
		manager.select_card(indices[0])
		manager.select_card(indices[1])

	assert_that(int(game_finished_counter["value"])).is_equal(1)
	assert_that(manager.is_game_finished()).is_true()


func test_reset_game_clears_board_and_progress() -> void:
	var manager = BoardManagerScript.new()
	manager.setup_game("easy", _build_pair_pool(50))

	var mismatch_indices: Array[int] = _find_mismatch_indices(manager.get_board())
	manager.select_card(mismatch_indices[0])
	manager.select_card(mismatch_indices[1])
	manager.reset_game()

	assert_that(manager.get_board().size()).is_equal(0)
	assert_that(manager.get_pairs_matched()).is_equal(0)
	assert_that(manager.get_guesses()).is_equal(0)
	assert_that(manager.is_game_finished()).is_false()


func _build_pair_pool(size: int) -> Array[int]:
	var pool: Array[int] = []
	for id: int in range(1, size + 1):
		pool.append(id)
	return pool


func _unshuffled_layout(pair_count: int) -> Array[int]:
	var values: Array[int] = []
	for id: int in range(1, pair_count + 1):
		values.append(id)
		values.append(id)
	return values


func _find_matching_pair_indices(board: Array[int]) -> Array[int]:
	for i: int in range(board.size()):
		for j: int in range(i + 1, board.size()):
			if board[i] == board[j]:
				return [i, j]
	return []


func _find_mismatch_indices(board: Array[int]) -> Array[int]:
	for i: int in range(board.size()):
		for j: int in range(i + 1, board.size()):
			if board[i] != board[j]:
				return [i, j]
	return []


func _pair_indices_map(board: Array[int]) -> Dictionary:
	var pair_map: Dictionary = {}
	for index: int in range(board.size()):
		var pair_id: int = board[index]
		if not pair_map.has(pair_id):
			pair_map[pair_id] = []
		(pair_map[pair_id] as Array).append(index)
	return pair_map
