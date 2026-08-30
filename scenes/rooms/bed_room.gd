extends Node2D


@onready var sree_sleeping: Sprite2D = $SreeSleeping

func _ready() -> void:
	sree_sleeping.show()
	EventManager.event_end.connect(_on_event_end)


func _on_event_end(event_id: int) -> void:
	if event_id == EventManager.event_ids.wake_up_event:
		sree_sleeping.hide()
