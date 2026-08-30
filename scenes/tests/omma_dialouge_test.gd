extends Node2D

@onready var omma: Node2D = $Omma

func _ready():
	GameState.can_move = true
	Ui.inventory.show()
	omma.interactable.is_interactable = true
	EventManager.finish_task(EventManager.task_ids.take_cake)
	EventManager.finish_task(EventManager.task_ids.put_cake_in_fridge)
	EventManager.finish_task(EventManager.task_ids.put_plate_in_sink)
