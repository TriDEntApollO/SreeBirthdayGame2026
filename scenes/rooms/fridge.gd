extends Sprite2D

@onready var interactable: Interactable = $PutCakeInteractable


func _ready() -> void:
	interactable.is_interactable = false
	interactable.on_interact = _on_interact
	interactable.add_outline(self)
	EventManager.task_updated.connect(_on_task_update)


func _on_interact() -> void:
	GameState.can_move = false
	interactable.unfocus()
	await Ui.transition.fade_in()
	
	await Ui.play_sfx("fridge_door")
	Ui.inventory_show_cake(false)
	Ui.inventory_show_plate(true)
	
	await Ui.transition.fade_out()
	
	GameState.can_move = true
	EventManager.finish_task(EventManager.task_ids.put_cake_in_fridge)


func _on_task_update(task_id: int) -> void:
	if task_id == EventManager.task_ids.put_cake_in_fridge:
		interactable.is_interactable = true
