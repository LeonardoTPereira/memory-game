class_name GameSession
extends Control


const CardScript := preload("res://scripts/memory_game/card.gd")
const HintControllerScript := preload("res://scripts/memory_game/hint_controller.gd")
const ScoreOverlayScene := preload("res://scenes/memory_game/score_overlay.tscn")
const MainMenuScene := preload("res://scenes/memory_game/main_menu.tscn")
const CORRECT_SOUND := preload("res://assets/memory_game/audio/correct_sound.tres")
const WRONG_SOUND := preload("res://assets/memory_game/audio/wrong_sound.tres")
const CORRECT_PARTICLES := preload("res://assets/memory_game/particles/correct_particles.tscn")
const WRONG_PARTICLES := preload("res://assets/memory_game/particles/wrong_particles.tscn")


signal pair_matched(pair_id: int)
signal wrong_guess_made
signal game_finished(final_score: int)


@export var card_scene: PackedScene = preload("res://scenes/memory_game/card.tscn")
@export var mismatch_flip_delay_seconds: float = 0.2


var _cards_by_index: Array[Variant] = []
var _pending_cards: Array[Variant] = []
var _wrong_guess_count: int = 0
var _is_game_finished: bool = false
var _difficulty: String = "easy"
var _last_pairs_matched: int = 0
var _hint_controller: HintController = HintControllerScript.new()
var _feedback_tween: Tween
var _score_overlay: Control


@onready var _board_manager: BoardManager = get_node_or_null("BoardManager")
@onready var _input_navigator: Node = get_node_or_null("InputNavigator")
@onready var _pair_counter_label: Label = get_node_or_null("MarginContainer/VBox/TopPanel/PairCounterLabel")
@onready var _guess_counter_label: Label = get_node_or_null("MarginContainer/VBox/TopPanel/GuessCounterLabel")
@onready var _hint_button: Button = get_node_or_null("MarginContainer/VBox/TopPanel/HintButton")
@onready var _return_button: Button = get_node_or_null("MarginContainer/VBox/TopPanel/ReturnButton")
@onready var _feedback_label: Label = get_node_or_null("MarginContainer/VBox/FeedbackLabel")
@onready var _board_grid: GridContainer = get_node_or_null("MarginContainer/VBox/BoardGrid")
@onready var _feedback_fx_root: Node2D = get_node_or_null("FeedbackFX")
@onready var _sfx_player: AudioStreamPlayer = get_node_or_null("SfxPlayer")


func _ready() -> void:
	if _board_manager == null:
		push_error("GameSession: BoardManager node not found")
		return
	_hint_controller.set_board_manager(_board_manager)
	if not _hint_controller.hint_eligibility_changed.is_connected(_on_hint_eligibility_changed):
		_hint_controller.hint_eligibility_changed.connect(_on_hint_eligibility_changed)
	if not _hint_controller.hint_used.is_connected(_on_hint_used):
		_hint_controller.hint_used.connect(_on_hint_used)
	if not _board_manager.pair_matched.is_connected(_on_pair_matched):
		_board_manager.pair_matched.connect(_on_pair_matched)
	if not _board_manager.wrong_guess_made.is_connected(_on_wrong_guess):
		_board_manager.wrong_guess_made.connect(_on_wrong_guess)
	if not _board_manager.game_finished.is_connected(_on_game_finished):
		_board_manager.game_finished.connect(_on_game_finished)
	if _return_button != null and not _return_button.pressed.is_connected(_on_return_pressed):
		_return_button.pressed.connect(_on_return_pressed)
	if _hint_button != null:
		if not _hint_button.pressed.is_connected(_on_hint_button_pressed):
			_hint_button.pressed.connect(_on_hint_button_pressed)
		_hint_button.disabled = true
	if _feedback_label != null:
		_feedback_label.visible = false
	_update_ui()


func configure_rng_seed(seed_value: int) -> void:
	if _board_manager != null:
		_board_manager.configure_rng_seed(seed_value)


func set_mismatch_flip_delay_seconds(delay_seconds: float) -> void:
	mismatch_flip_delay_seconds = max(0.0, delay_seconds)


func start_game(difficulty: String, pair_pool: Array[int] = []) -> void:
	_difficulty = difficulty
	var effective_pair_pool: Array[int] = pair_pool
	if effective_pair_pool.is_empty():
		effective_pair_pool = _build_default_pair_pool(difficulty)
	var board_values: Array[int] = _board_manager.setup_game(difficulty, pair_pool)
	if board_values.is_empty():
		board_values = _board_manager.setup_game(difficulty, effective_pair_pool)
	_hint_controller = HintControllerScript.new()
	_hint_controller.set_board_manager(_board_manager)
	if not _hint_controller.hint_eligibility_changed.is_connected(_on_hint_eligibility_changed):
		_hint_controller.hint_eligibility_changed.connect(_on_hint_eligibility_changed)
	if not _hint_controller.hint_used.is_connected(_on_hint_used):
		_hint_controller.hint_used.connect(_on_hint_used)
	_cards_by_index.clear()
	_pending_cards.clear()
	_wrong_guess_count = 0
	_is_game_finished = false
	_last_pairs_matched = 0
	_build_board_ui(board_values, difficulty)
	_set_feedback_text("")
	if _feedback_label != null:
		_feedback_label.visible = false
	if _hint_button != null:
		_hint_button.disabled = true
	if _score_overlay != null and is_instance_valid(_score_overlay):
		_score_overlay.queue_free()
		_score_overlay = null
	_update_ui()
	if _input_navigator != null and _input_navigator.has_method("set_cards"):
		_input_navigator.call("set_cards", _cards_by_index)
		if _input_navigator.has_method("set_game_session"):
			_input_navigator.call("set_game_session", self)


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
	if _pair_counter_label == null:
		return ""
	return _pair_counter_label.text


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
		if card.has_method("set_card_textures"):
			card.set_card_textures(null, null)
		if card.has_method("set_focus_highlighted"):
			card.set_focus_highlighted(false)
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
	_last_pairs_matched = _board_manager.get_pairs_matched()
	_play_feedback("CORRETO", Color(0.25, 0.9, 0.35, 1.0), CORRECT_SOUND, CORRECT_PARTICLES)
	_update_ui()
	pair_matched.emit(pair_id)


func _on_wrong_guess() -> void:
	_wrong_guess_count += 1
	_hint_controller.register_wrong_guess()
	_play_feedback("ERRADO", Color(0.95, 0.25, 0.25, 1.0), WRONG_SOUND, WRONG_PARTICLES)
	_update_ui()
	wrong_guess_made.emit()
	_flip_back_pending_cards_after_delay()


func _on_game_finished(final_score: int) -> void:
	_is_game_finished = true
	_set_feedback_text("FINAL")
	if _pair_counter_label != null:
		_pair_counter_label.text = "Pairs: %d (final score: %d)" % [_board_manager.get_pairs_matched(), final_score]
	_show_score_overlay(final_score)
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
	if _pair_counter_label != null:
		_pair_counter_label.text = "Pairs: %d" % _board_manager.get_pairs_matched()
	if _guess_counter_label != null:
		_guess_counter_label.text = "Guesses: %d" % _board_manager.get_guesses()


func apply_focus_to_card(card: Variant) -> void:
	for current: Variant in _cards_by_index:
		if current != null and current.has_method("set_focus_highlighted"):
			current.set_focus_highlighted(current == card)


func activate_focused_card(card: Variant) -> void:
	if card == null:
		return
	if card.has_method("trigger_select"):
		card.trigger_select()


func _on_return_pressed() -> void:
	var menu: Node = MainMenuScene.instantiate()
	get_tree().root.add_child(menu)
	queue_free()


func _on_hint_eligibility_changed(enabled: bool) -> void:
	if _hint_button != null:
		_hint_button.disabled = not enabled


func _on_hint_button_pressed() -> void:
	if _is_game_finished:
		return
	var indices: Array[int] = _hint_controller.use_hint()
	if indices.is_empty() and _hint_button != null:
		_hint_button.disabled = not _hint_controller.is_hint_enabled()


func _on_hint_used(pair_indices: Array[int]) -> void:
	for index: int in pair_indices:
		var card: Variant = get_card_at(index)
		if card != null and card.has_method("show_hint_highlight"):
			card.show_hint_highlight(1.2)
	if _hint_button != null:
		_hint_button.disabled = true


func _play_feedback(text_value: String, color: Color, sound_stream: AudioStream, particle_scene: PackedScene) -> void:
	_set_feedback_text(text_value)
	if _feedback_label != null:
		if _feedback_tween != null:
			_feedback_tween.kill()
		_feedback_label.visible = true
		_feedback_label.modulate = color
		_feedback_tween = create_tween()
		_feedback_tween.tween_property(_feedback_label, "modulate:a", 0.0, 0.9)
		_feedback_tween.tween_callback(func() -> void:
			if _feedback_label != null:
				_feedback_label.visible = false
		)
	_spawn_feedback_particles(particle_scene)
	_play_sound(sound_stream)


func _spawn_feedback_particles(scene: PackedScene) -> void:
	if scene == null:
		return
	var particle_node: Node = scene.instantiate()
	if particle_node == null:
		return
	if _feedback_fx_root != null:
		_feedback_fx_root.add_child(particle_node)
		var world_position: Vector2 = global_position + (size * 0.5)
		if _board_grid != null:
			world_position = _board_grid.global_position + (_board_grid.size * 0.5)
		if particle_node is Node2D:
			particle_node.global_position = world_position
	else:
		add_child(particle_node)
	if particle_node.has_method("set"):
		particle_node.set("emitting", true)
	var clear_timer: SceneTreeTimer = get_tree().create_timer(1.5)
	clear_timer.timeout.connect(func() -> void:
		if is_instance_valid(particle_node):
			particle_node.queue_free()
	)


func _play_sound(stream: AudioStream) -> void:
	if _sfx_player == null or stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.play()


func _show_score_overlay(final_score: int) -> void:
	if _score_overlay != null and is_instance_valid(_score_overlay):
		_score_overlay.queue_free()
		_score_overlay = null
	if ScoreOverlayScene == null:
		return
	var overlay_instance: Node = ScoreOverlayScene.instantiate()
	if overlay_instance == null:
		return
	if overlay_instance is Control:
		_score_overlay = overlay_instance
		add_child(_score_overlay)
		if _score_overlay.has_signal("return_requested") and not _score_overlay.return_requested.is_connected(_on_return_pressed):
			_score_overlay.return_requested.connect(_on_return_pressed)
		if _score_overlay.has_method("show_score"):
			_score_overlay.call("show_score", final_score)
	else:
		overlay_instance.queue_free()


func _build_default_pair_pool(difficulty: String) -> Array[int]:
	var grid: Vector2i = _board_manager.get_grid_size(difficulty)
	var pair_count: int = (grid.x * grid.y) >> 1
	var values: Array[int] = []
	for pair_id: int in range(1, pair_count + 1):
		values.append(pair_id)
	return values
