extends Node2D

@onready var character: NPC = $NpcComponent
@onready var interactable: Interactable = $"NpcComponent/Interactable"
@onready var animated_sprite_2d: AnimatedSprite2D = $NpcComponent/AnimatedSprite2D

var first_interaction: bool = true
var cake_question_done: bool = false
var dialogue_file_path: String = "res://dialogue/conversations/omma.dialogue"

func _ready() -> void:
	character.face_direction("right")
	character.set_interactale(false)
	interactable.on_interact = _on_interact
	interactable.add_outline(animated_sprite_2d) 
	EventManager.task_updated.connect(_on_task_update)
	EventManager.event_start.connect(_on_event_start)
	EventManager.event_end.connect(_on_event_end)


func _on_task_update(task_id: int) -> void:
	if task_id == EventManager.task_ids.talk_to_omma:
		character.set_interactale(true)


func _on_interact() -> void:
	GameState.show_cursor()
	interactable.is_interactable = false
	character.turn_to_sree()
	Ui.dialogue_balloon.start(load(dialogue_file_path), "start", [self])
	await Ui.dialogue_balloon.dialogue_ended
	GameState.hide_cursor()
	character.face_direction("left")


func _on_event_start(event_id: int) -> void:
	if event_id == EventManager.event_ids.pre_dining_event:
		character.go_to("DiningOmma", "left")

func _on_event_end(event_id: int) -> void:
	if event_id == EventManager.event_ids.cake_event:
		character.go_to("MasterBedroomOmma", "left")
