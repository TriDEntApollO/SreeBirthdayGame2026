extends Node2D

@onready var omma: Node2D = $Omma
@onready var appa: Node2D = $Appa
@onready var interactable: Interactable = $Interactable

var first_interaction: bool = true
var dialogue_file_path: String = "res://dialogue/conversations/omma_and_appa.dialogue"

func _ready() -> void:
	interactable.interact_once = false
	interactable.on_interact = _on_interact
	interactable.add_outline(omma.animated_sprite_2d)
	interactable.add_outline(appa.animated_sprite_2d)
	EventManager.task_updated.connect(_on_task_update)

func _on_interact() -> void:
	GameState.show_cursor()
	interactable.is_interactable = false
	omma.character.turn_to_sree()
	appa.character.turn_to_sree()
	Ui.dialogue_balloon.start(load(dialogue_file_path), "start", [self])
	await Ui.dialogue_balloon.dialogue_ended
	GameState.hide_cursor()


func _on_task_update(task_id: int) -> void:
	if task_id == EventManager.task_ids.brush_teeth:
		interactable.is_interactable = true
