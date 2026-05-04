class_name ScoreOverlay
extends Control


signal return_requested


@export var auto_return_seconds: float = 5.0


@onready var _score_value_label: Label = get_node_or_null("Panel/VBox/ScoreValueLabel")
@onready var _return_button: Button = get_node_or_null("Panel/VBox/ReturnButton")
@onready var _auto_return_timer: Timer = get_node_or_null("AutoReturnTimer")


func _ready() -> void:
	if _return_button != null and not _return_button.pressed.is_connected(_on_return_button_pressed):
		_return_button.pressed.connect(_on_return_button_pressed)
	if _auto_return_timer != null:
		_auto_return_timer.wait_time = max(0.1, auto_return_seconds)
		if not _auto_return_timer.timeout.is_connected(_on_auto_return_timeout):
			_auto_return_timer.timeout.connect(_on_auto_return_timeout)


func show_score(final_score: int) -> void:
	visible = true
	if _score_value_label != null:
		_score_value_label.text = str(final_score)
	if _return_button != null:
		_return_button.grab_focus.call_deferred()
	if _auto_return_timer != null:
		_auto_return_timer.start()


func _on_return_button_pressed() -> void:
	return_requested.emit()


func _on_auto_return_timeout() -> void:
	return_requested.emit()
