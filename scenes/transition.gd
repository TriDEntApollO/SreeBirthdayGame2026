extends ColorRect


func _ready() -> void:
	color.a = 0.0	
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func fade_in(duration: float = 0.8) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "color:a", 1.0, duration)
	
	await tween.finished


func fade_out(duration: float = 0.8) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "color:a", 0.0, duration)
	
	await tween.finished
