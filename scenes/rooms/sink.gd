# sink.gd
extends Sprite2D

@onready var interactable: Interactable = $BrushTeethInteractable


func _ready() -> void:
	interactable.add_outline(self)
	interactable.on_interact = _on_interact
	EventManager.task_updated.connect(_on_task_update)


func _on_interact() -> void:
	interactable.unfocus()
	interactable.is_interactable = false
	GameState.can_move = false
	Ui.play_sfx("brush_teeth")
	await Ui.transition.fade_in()
	await GameState.delay(1)
	await Ui.transition.fade_out()
	GameState.can_move = true
	EventManager.alarm_tick.emit()
	EventManager.finish_task(EventManager.task_ids.brush_teeth)


func _on_task_update(task_id: int) -> void:
	if task_id == EventManager.task_ids.brush_teeth:
		interactable.is_interactable = true
