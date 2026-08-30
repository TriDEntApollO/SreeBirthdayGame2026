extends NodeState

@export var character: NPC
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"

func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	if character.animate_pause:
		return
	match character.npc_facing:
		Vector2.DOWN:
			animated_sprite_2d.play("Idle front")
		Vector2.UP:
			animated_sprite_2d.play("Idle back")
		Vector2.LEFT:
			animated_sprite_2d.play("Idle left")
		Vector2.RIGHT:
			animated_sprite_2d.play("Idle right")
		_:
			animated_sprite_2d.play("Idle front")


func _on_next_transitions() -> void:
	if character.has_destination:
		transition.emit("Walk")


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
