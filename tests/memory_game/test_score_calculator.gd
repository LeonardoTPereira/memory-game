extends GdUnitTestSuite


func test_calculate_returns_zero_when_pairs_and_guesses_are_zero() -> void:
	var score: int = ScoreCalculator.calculate(0, 0)

	assert_that(score).is_equal(0)


func test_calculate_uses_max_guard_when_guesses_is_zero() -> void:
	var score: int = ScoreCalculator.calculate(8, 0)

	assert_that(score).is_equal(8000)


func test_calculate_handles_single_guess_case() -> void:
	var score: int = ScoreCalculator.calculate(3, 1)

	assert_that(score).is_equal(3000)


func test_calculate_uses_formula_for_pairs_times_two_guesses() -> void:
	var pairs_matched: int = 8
	var score: int = ScoreCalculator.calculate(pairs_matched, pairs_matched * 2)

	assert_that(score).is_equal(500)
