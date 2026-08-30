extends Node2D


@onready var interactable: Interactable = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	interactable.on_interact = _on_interact
	interactable.is_interactable = true
	interactable.add_outline(sprite_2d)
	

func _on_interact() -> void:
	GameState.can_move = false
	GameState.add_collectable()
	await Ui.collectable_found.found()
	hide()
	GameState.can_move = true
	queue_free()
	
