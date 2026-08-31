# alarm_clock.gd
extends AnimatedSprite2D

@onready var interactable: Interactable = $Interactable
@onready var block_door: StaticBody2D = $"../BlockDoor"
@onready var alarm_sfx: AudioStreamPlayer2D = $AlarmSfx

var clock_state = 1

func _ready() -> void:
	interactable.add_outline(self)
	interactable.on_interact = _on_interact
	EventManager.alarm_tick.connect(advance_time)
	EventManager.event_start.connect(_on_start_event)
	EventManager.task_updated.connect(_on_task_update)
	EventManager.tutorial_finished.connect(_on_tutorial_finished)


func advance_time() -> void:
	clock_state += 1
	frame = clock_state


func _on_start_event(event_id: int) -> void:
	if event_id == EventManager.event_ids.wake_up_event:
		alarm_sfx.play()


func _on_interact() -> void:
	alarm_sfx.stop()
	block_door.collision_layer = 0
	interactable.is_interactable = false
	EventManager.end_event(EventManager.event_ids.start_day_event)
	await EventManager.finish_task(EventManager.task_ids.stop_alarm)
	await EventManager.add_task()
	await EventManager.add_task()


func _on_task_update(task_id: int) -> void:
	if task_id == EventManager.task_ids.stop_alarm and not GameState.tutorial:
		interactable.is_interactable = true


func _on_tutorial_finished() -> void:
	interactable.is_interactable = true
