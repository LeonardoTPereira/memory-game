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


func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	flip_face_down()


func configure(p_new_pair_id: int, p_board_index: int) -> void:
	pair_id = p_new_pair_id
	board_index = p_board_index
	face_state = FaceState.FACE_DOWN
	disabled = false
	button_pressed = false
	text = "?"


func trigger_select() -> void:
	_on_pressed()


func flip_face_up() -> void:
	if face_state == FaceState.MATCHED:
		return
	face_state = FaceState.FACE_UP
	text = str(pair_id)


func flip_face_down() -> void:
	if face_state == FaceState.MATCHED:
		return
	face_state = FaceState.FACE_DOWN
	text = "?"


func set_matched() -> void:
	face_state = FaceState.MATCHED
	text = str(pair_id)
	disabled = true


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
