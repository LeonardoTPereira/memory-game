extends GdUnitTestSuite


const HINT_CONTROLLER_PATH := "res://scripts/memory_game/hint_controller.gd"


class FakeBoardManager:
	extends RefCounted

	var _pairs: Array[Array]

	func _init(pairs: Array[Array]) -> void:
		_pairs = pairs

	func get_unmatched_pairs() -> Array[Array]:
		return _pairs.duplicate(true)


func test_wrong_guess_counter_increments_on_each_wrong_guess() -> void:
	var controller = _new_hint_controller()

	controller.register_wrong_guess()
	controller.register_wrong_guess()
	controller.register_wrong_guess()

	assert_that(controller.get_wrong_guess_count()).is_equal(3)
	assert_that(controller.is_hint_enabled()).is_false()


func test_hint_enabled_becomes_true_after_ten_wrong_guesses() -> void:
	var controller = _new_hint_controller()

	for _i: int in range(10):
		controller.register_wrong_guess()

	assert_that(controller.get_wrong_guess_count()).is_equal(10)
	assert_that(controller.is_hint_enabled()).is_true()


func test_using_hint_resets_counter_and_disables_hint() -> void:
	var controller = _new_hint_controller()
	var board_manager := FakeBoardManager.new([[1, 2], [7, 8]])
	controller.set_board_manager(board_manager)
	controller.configure_rng_seed(123)
	for _i: int in range(10):
		controller.register_wrong_guess()

	var picked_pair: Array[int] = controller.use_hint()

	assert_that(picked_pair.size()).is_equal(2)
	assert_that(controller.get_wrong_guess_count()).is_equal(0)
	assert_that(controller.is_hint_enabled()).is_false()


func test_use_hint_picks_random_unmatched_pair_from_injected_board_manager() -> void:
	var unmatched_pairs: Array[Array] = [[4, 5], [10, 11], [20, 21]]
	var board_manager := FakeBoardManager.new(unmatched_pairs)
	var controller = _new_hint_controller()
	controller.set_board_manager(board_manager)
	controller.configure_rng_seed(999)
	for _i: int in range(10):
		controller.register_wrong_guess()

	var picked_pair: Array[int] = controller.use_hint()

	assert_that(picked_pair.size()).is_equal(2)
	assert_that(unmatched_pairs).contains(picked_pair)


func _new_hint_controller() -> Variant:
	var script_resource: GDScript = load(HINT_CONTROLLER_PATH)
	return script_resource.new()
