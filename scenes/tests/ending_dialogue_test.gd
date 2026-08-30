extends Node2D


@onready var sree: Sree = $Sree
@onready var cat: StaticBody2D = $Cat
@onready var ramenpaglu: Node2D = $Ramenpaglu

func _ready() -> void:
	cat.set_enabled(true)
	cat.interactable.is_interactable = true
	ramenpaglu.character.face_direction("right")
	ramenpaglu.gift_boxes.show()
	ramenpaglu.all_tasks_done = true
	ramenpaglu.set_character_enabled(true)
	ramenpaglu.interactable.is_interactable = true
	GameState.can_move = true
