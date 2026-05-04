extends GdUnitTestSuite


const GameBoardScene := preload("res://scenes/memory_game/game_board.tscn")


func test_flip_two_cards_match_emits_signal_and_updates_ui() -> void:
	var session: Variant = _new_session()
	_assert_game_session_api(session)
	session.configure_rng_seed(1234)
	session.set_mismatch_flip_delay_seconds(0.02)
	session.start_game("easy", _build_pair_pool(50))

	var pair_matched_counter: Dictionary = {"value": 0}
	session.pair_matched.connect(func(_pair_id: int) -> void:
		pair_matched_counter["value"] = int(pair_matched_counter["value"]) + 1
	)

	var board: Array[int] = session.get_board_snapshot()
	var pair_indices: Array[int] = _find_matching_pair_indices(board)

	session.get_card_at(pair_indices[0]).trigger_select()
	session.get_card_at(pair_indices[1]).trigger_select()

	assert_that(int(pair_matched_counter["value"])).is_equal(1)
	assert_that(session.get_feedback_text()).is_equal("CORRETO")
	assert_that(session.get_score_label_text().contains("Score:")).is_true()
	assert_that(session.get_card_at(pair_indices[0]).get_face_state_name()).is_equal("MATCHED")
	assert_that(session.get_card_at(pair_indices[1]).get_face_state_name()).is_equal("MATCHED")


func test_flip_two_cards_mismatch_flips_back_after_delay() -> void:
	var session: Variant = _new_session()
	_assert_game_session_api(session)
	session.configure_rng_seed(777)
	session.set_mismatch_flip_delay_seconds(0.02)
	session.start_game("easy", _build_pair_pool(50))

	var wrong_guess_counter: Dictionary = {"value": 0}
	session.wrong_guess_made.connect(func() -> void:
		wrong_guess_counter["value"] = int(wrong_guess_counter["value"]) + 1
	)

	var board: Array[int] = session.get_board_snapshot()
	var mismatch_indices: Array[int] = _find_mismatch_indices(board)
	var first_card: Variant = session.get_card_at(mismatch_indices[0])
	var second_card: Variant = session.get_card_at(mismatch_indices[1])

	first_card.trigger_select()
	second_card.trigger_select()

	assert_that(int(wrong_guess_counter["value"])).is_equal(1)
	assert_that(session.get_feedback_text()).is_equal("ERRADO")
	assert_that(first_card.get_face_state_name()).is_equal("FACE_UP")
	assert_that(second_card.get_face_state_name()).is_equal("FACE_UP")

	await await_millis(50)

	assert_that(first_card.get_face_state_name()).is_equal("FACE_DOWN")
	assert_that(second_card.get_face_state_name()).is_equal("FACE_DOWN")


func test_complete_all_pairs_emits_game_finished_signal() -> void:
	var session: Variant = _new_session()
	_assert_game_session_api(session)
	session.configure_rng_seed(999)
	session.set_mismatch_flip_delay_seconds(0.01)
	session.start_game("easy", _build_pair_pool(50))

	var game_finished_counter: Dictionary = {"value": 0}
	session.game_finished.connect(func(_final_score: int) -> void:
		game_finished_counter["value"] = int(game_finished_counter["value"]) + 1
	)

	var pair_map: Dictionary = _pair_indices_map(session.get_board_snapshot())
	for pair_id: int in pair_map.keys():
		var indices: Array[int] = pair_map[pair_id]
		session.get_card_at(indices[0]).trigger_select()
		session.get_card_at(indices[1]).trigger_select()

	assert_that(int(game_finished_counter["value"])).is_equal(1)
	assert_that(session.is_game_finished()).is_true()


func _new_session() -> Variant:
	var scene_instance: Variant = GameBoardScene.instantiate()
	auto_free(scene_instance)
	return scene_instance


func _assert_game_session_api(session: Variant) -> void:
	assert_that(session.has_method("start_game")).is_true()
	assert_that(session.has_method("get_board_snapshot")).is_true()
	assert_that(session.has_method("get_card_at")).is_true()


func _build_pair_pool(size: int) -> Array[int]:
	var pool: Array[int] = []
	for id: int in range(1, size + 1):
		pool.append(id)
	return pool


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
