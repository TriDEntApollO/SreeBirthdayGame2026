extends Node2D

@onready var interactable: Interactable = $TakeCakeInteractable


func _ready() -> void:
	hide()
	interactable.is_interactable = false
	interactable.on_interact = _on_interact
	interactable.add_outline($Cake)
	interactable.add_outline($Plate)
	EventManager.task_updated.connect(_on_task_update)
	EventManager.event_start.connect(_on_event_start)


func _on_interact() -> void:
	hide()
	Ui.inventory_show_cake(true)
	await EventManager.finish_task(EventManager.task_ids.take_cake)
	await EventManager.add_task()
	await EventManager.add_task()


func _on_task_update(task_id: int) -> void:
	if task_id == EventManager.task_ids.take_cake:
		interactable.is_interactable = true


func _on_event_start(event_id: int) -> void:
	if event_id == EventManager.event_ids.pre_dining_event:
		show()
