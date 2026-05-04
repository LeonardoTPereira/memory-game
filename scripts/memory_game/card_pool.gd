class_name CardPool
extends RefCounted


const MASTER_POOL: Array[Texture2D] = [
	preload("res://assets/memory_game/card_fronts/card_001.png"),
	preload("res://assets/memory_game/card_fronts/card_002.png"),
	preload("res://assets/memory_game/card_fronts/card_003.png"),
	preload("res://assets/memory_game/card_fronts/card_004.png"),
	preload("res://assets/memory_game/card_fronts/card_005.png"),
	preload("res://assets/memory_game/card_fronts/card_006.png"),
	preload("res://assets/memory_game/card_fronts/card_007.png"),
	preload("res://assets/memory_game/card_fronts/card_008.png"),
	preload("res://assets/memory_game/card_fronts/card_009.png"),
	preload("res://assets/memory_game/card_fronts/card_010.png"),
	preload("res://assets/memory_game/card_fronts/card_011.png"),
	preload("res://assets/memory_game/card_fronts/card_012.png"),
	preload("res://assets/memory_game/card_fronts/card_013.png"),
	preload("res://assets/memory_game/card_fronts/card_014.png"),
	preload("res://assets/memory_game/card_fronts/card_015.png"),
	preload("res://assets/memory_game/card_fronts/card_016.png"),
	preload("res://assets/memory_game/card_fronts/card_017.png"),
	preload("res://assets/memory_game/card_fronts/card_018.png"),
	preload("res://assets/memory_game/card_fronts/card_019.png"),
	preload("res://assets/memory_game/card_fronts/card_020.png"),
	preload("res://assets/memory_game/card_fronts/card_021.png"),
	preload("res://assets/memory_game/card_fronts/card_022.png"),
	preload("res://assets/memory_game/card_fronts/card_023.png"),
	preload("res://assets/memory_game/card_fronts/card_024.png"),
	preload("res://assets/memory_game/card_fronts/card_025.png"),
	preload("res://assets/memory_game/card_fronts/card_026.png"),
	preload("res://assets/memory_game/card_fronts/card_027.png"),
	preload("res://assets/memory_game/card_fronts/card_028.png"),
	preload("res://assets/memory_game/card_fronts/card_029.png"),
	preload("res://assets/memory_game/card_fronts/card_030.png"),
	preload("res://assets/memory_game/card_fronts/card_031.png"),
	preload("res://assets/memory_game/card_fronts/card_032.png"),
	preload("res://assets/memory_game/card_fronts/card_033.png"),
	preload("res://assets/memory_game/card_fronts/card_034.png"),
	preload("res://assets/memory_game/card_fronts/card_035.png"),
	preload("res://assets/memory_game/card_fronts/card_036.png"),
	preload("res://assets/memory_game/card_fronts/card_037.png"),
	preload("res://assets/memory_game/card_fronts/card_038.png"),
	preload("res://assets/memory_game/card_fronts/card_039.png"),
	preload("res://assets/memory_game/card_fronts/card_040.png"),
	preload("res://assets/memory_game/card_fronts/card_041.png"),
	preload("res://assets/memory_game/card_fronts/card_042.png"),
	preload("res://assets/memory_game/card_fronts/card_043.png"),
	preload("res://assets/memory_game/card_fronts/card_044.png"),
	preload("res://assets/memory_game/card_fronts/card_045.png"),
	preload("res://assets/memory_game/card_fronts/card_046.png"),
	preload("res://assets/memory_game/card_fronts/card_047.png"),
	preload("res://assets/memory_game/card_fronts/card_048.png"),
	preload("res://assets/memory_game/card_fronts/card_049.png"),
	preload("res://assets/memory_game/card_fronts/card_050.png")
]


func get_random_pairs(count: int) -> Array[Texture2D]:
	if count < 0:
		push_error("CardPool.get_random_pairs: count cannot be negative")
		return []

	if count > MASTER_POOL.size():
		push_error("CardPool.get_random_pairs: count cannot be greater than master pool size")
		return []

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	var available_indices: Array[int] = []
	for index: int in MASTER_POOL.size():
		available_indices.append(index)

	var selected_pairs: Array[Texture2D] = []
	for _i: int in count:
		var picked_position: int = rng.randi_range(0, available_indices.size() - 1)
		var texture_index: int = available_indices[picked_position]
		selected_pairs.append(MASTER_POOL[texture_index])
		available_indices.remove_at(picked_position)

	return selected_pairs
