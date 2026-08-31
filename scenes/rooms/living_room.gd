extends Node2D

@onready var cake: Node2D = $Cake
@onready var dining_table: Sprite2D = $RoomTilemap/Decor/DiningTable
@onready var cake_event_interactable: Interactable = $CakeEventInteractable
@onready var bday_decor: Node2D = $RoomTilemap/BdayDecor

func _ready() -> void:
	bday_decor.hide()
	cake_event_interactable.on_interact = _on_cake_event_interact
	EventManager.event_start.connect(_on_event_start)


func _on_event_start(event_id: int) -> void:
	if event_id == EventManager.event_ids.pre_dining_event:
		bday_decor.show()


func _on_cake_event_interact() -> void:
	await EventManager.finish_task(EventManager.task_ids.start_cake_event)
	EventManager.start_event()


func _on_walk_in_body_entered(_body: Node2D) -> void:
	if (EventManager.has_event_started(EventManager.event_ids.pre_dining_event)
		and not EventManager.has_event_started(EventManager.event_ids.dining_event)
	):
		await EventManager.finish_task(EventManager.task_ids.go_to_dining)
		await EventManager.add_task()
		EventManager.start_event()
		await GameState.delay(2.5)
		cake_event_interactable.is_interactable = true
