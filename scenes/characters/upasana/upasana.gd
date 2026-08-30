extends Node2D

@onready var character: NPC = $NpcComponent
@onready var interactable: Interactable = $"NpcComponent/Interactable"
@onready var animated_sprite_2d: AnimatedSprite2D = $NpcComponent/AnimatedSprite2D

var first_interaction: bool = true
var dialogue_file_path: String = "res://dialogue/conversations/upasana.dialogue"

func _ready() -> void:
	set_character_enabled(false)
	character.set_interactale(false)
	interactable.on_interact = _on_interact
	interactable.add_outline(animated_sprite_2d)
	EventManager.task_updated.connect(_on_task_update)
	EventManager.event_start.connect(_on_event_start)
	EventManager.event_end.connect(_on_event_end)


func set_character_enabled(enabled: bool) -> void:
	visible = enabled
	character.set_enabled(enabled)


func _on_interact() -> void:
	GameState.show_cursor()
	interactable.is_interactable = false
	character.turn_to_sree()
	Ui.dialogue_balloon.start(load(dialogue_file_path), "start", [self])
	await Ui.dialogue_balloon.dialogue_ended
	GameState.hide_cursor()
	character.face_direction("right")


func _on_task_update(task_id: int) -> void:
	if task_id == EventManager.task_ids.talk_to_upasana:
		character.set_interactale(true)


func _on_event_start(event_id: int) -> void:
	if event_id == EventManager.event_ids.pre_dining_event:
		set_character_enabled(true)
	elif event_id == EventManager.event_ids.dining_event:
		character.go_to("DiningUpasana", "right")


func _on_event_end(event_id: int) -> void:
	if event_id == EventManager.event_ids.cake_event:
		character.go_to("LivingRoomUpasana", "right")
