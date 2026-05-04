class_name Card
extends Button


signal card_selected(card: Card)


enum FaceState {
	FACE_DOWN,
	FACE_UP,
	MATCHED,
}


var pair_id: int = -1
var board_index: int = -1
var face_state: FaceState = FaceState.FACE_DOWN
var _front_texture: Texture2D
var _back_texture: Texture2D
var _hint_tween: Tween


@onready var _front_face: TextureRect = get_node_or_null("FrontFace")
@onready var _back_face: TextureRect = get_node_or_null("BackFace")
@onready var _focus_highlight: ColorRect = get_node_or_null("FocusHighlight")
@onready var _hint_highlight: ColorRect = get_node_or_null("HintHighlight")


func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	if _focus_highlight != null:
		_focus_highlight.visible = false
	if _hint_highlight != null:
		_hint_highlight.visible = false
	flip_face_down()


func configure(p_new_pair_id: int, p_board_index: int) -> void:
	pair_id = p_new_pair_id
	board_index = p_board_index
	face_state = FaceState.FACE_DOWN
	disabled = false
	button_pressed = false
	text = "?"
	_update_face_visuals()


func set_card_textures(front_texture: Texture2D, back_texture: Texture2D) -> void:
	_front_texture = front_texture
	_back_texture = back_texture
	if _front_face != null:
		_front_face.texture = _front_texture
	if _back_face != null:
		_back_face.texture = _back_texture


func set_focus_highlighted(enabled: bool) -> void:
	if _focus_highlight != null:
		_focus_highlight.visible = enabled


func show_hint_highlight(duration_seconds: float = 1.2) -> void:
	if _hint_highlight == null:
		return
	if _hint_tween != null:
		_hint_tween.kill()
	_hint_highlight.visible = true
	_hint_highlight.modulate = Color(1.0, 1.0, 0.2, 0.25)
	_hint_tween = create_tween()
	_hint_tween.tween_property(_hint_highlight, "modulate:a", 0.95, 0.15)
	_hint_tween.tween_property(_hint_highlight, "modulate:a", 0.25, 0.15)
	_hint_tween.tween_property(_hint_highlight, "modulate:a", 0.95, 0.15)
	_hint_tween.tween_property(_hint_highlight, "modulate:a", 0.25, max(0.3, duration_seconds - 0.45))
	_hint_tween.tween_callback(func() -> void:
		if _hint_highlight != null:
			_hint_highlight.visible = false
	)


func trigger_select() -> void:
	_on_pressed()


func flip_face_up() -> void:
	if face_state == FaceState.MATCHED:
		return
	face_state = FaceState.FACE_UP
	text = str(pair_id)
	_update_face_visuals()


func flip_face_down() -> void:
	if face_state == FaceState.MATCHED:
		return
	face_state = FaceState.FACE_DOWN
	text = "?"
	_update_face_visuals()


func set_matched() -> void:
	face_state = FaceState.MATCHED
	text = str(pair_id)
	disabled = true
	_update_face_visuals()


func get_face_state_name() -> String:
	match face_state:
		FaceState.FACE_DOWN:
			return "FACE_DOWN"
		FaceState.FACE_UP:
			return "FACE_UP"
		FaceState.MATCHED:
			return "MATCHED"
		_:
			return "UNKNOWN"


func _on_pressed() -> void:
	if disabled:
		return
	if face_state != FaceState.FACE_DOWN:
		return
	card_selected.emit(self)


func _update_face_visuals() -> void:
	if _front_face == null or _back_face == null:
		return
	var show_front: bool = face_state != FaceState.FACE_DOWN
	_front_face.visible = show_front
	_back_face.visible = not show_front
