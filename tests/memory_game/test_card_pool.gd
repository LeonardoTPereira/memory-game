extends GdUnitTestSuite


func test_get_random_pairs_returns_exact_requested_count() -> void:
	var card_pool: CardPool = CardPool.new()
	var count: int = 8

	var selected_pairs: Array[Texture2D] = card_pool.get_random_pairs(count)

	assert_that(selected_pairs.size()).is_equal(count)


func test_get_random_pairs_returns_distinct_entries_without_repetition() -> void:
	var card_pool: CardPool = CardPool.new()
	var count: int = 50

	var selected_pairs: Array[Texture2D] = card_pool.get_random_pairs(count)
	var seen_pairs: Dictionary = {}

	for pair_texture: Texture2D in selected_pairs:
		assert_that(pair_texture).is_not_null()
		assert_that(seen_pairs.has(pair_texture)).is_false()
		seen_pairs[pair_texture] = true

	assert_that(selected_pairs.size()).is_equal(count)
	assert_that(seen_pairs.size()).is_equal(count)
