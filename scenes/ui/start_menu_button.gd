class_name StartMenuButton
extends UiMenuButton


@onready var cat: Sprite2D = $Cat
var cat_original_rotation: float

func _ready() -> void:
	cat_original_rotation = cat.rotation
	cat.modulate.a = 0.0
	super()

func _process(_delta: float) -> void:
	cat.rotation = cat_original_rotation - rotation

func _on_mouse_entered() -> void:
	super()
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(cat, "modulate:a", 1.0, 0.1)

func _on_mouse_exited() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(cat, "modulate:a", 0.0, 0.1)
	super()
