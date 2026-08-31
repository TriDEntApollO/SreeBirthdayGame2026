class_name UiMenuButton
extends Button

@export var rotation_amount: float = 4.0
@export var rotation_duration: float = 0.1

var original_rotation: float


func _ready() -> void:
	pivot_offset = size / 2
	original_rotation = rotation
	focus_mode = Control.FOCUS_NONE

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	Ui.play_ui_sfx("hover")
	var target_rotation := original_rotation - deg_to_rad(rotation_amount)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", target_rotation, rotation_duration)


func _on_mouse_exited() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", original_rotation, rotation_duration)
