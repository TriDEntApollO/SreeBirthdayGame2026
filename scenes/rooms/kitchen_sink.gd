extends Sprite2D

@onready var plate: Sprite2D = $Plate
@onready var interactable: Interactable = $PutPlateInteractable

func _ready() -> void:
	plate.hide()
	interactable.is_interactable = false
	interactable.on_interact = _on_interact
	interactable.add_outline(self)
	EventManager.task_updated.connect(_on_task_update)


func _on_interact() -> void:
	GameState.can_move = false
	interactable.unfocus()
	await Ui.transition.fade_in()
	
	await Ui.play_sfx("plate_clink")
	Ui.inventory_show_plate(false)
	plate.show()
	
	await Ui.transition.fade_out()
	
	GameState.can_move = true
	await EventManager.finish_task(EventManager.task_ids.put_plate_in_sink)
	await EventManager.add_task()


func _on_task_update(task_id: int) -> void:
	if task_id == EventManager.task_ids.put_cake_in_fridge:
		interactable.is_interactable = true
