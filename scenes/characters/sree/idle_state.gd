extends NodeState

@export var player: Sree
@export var animated_sprite_2d: AnimatedSprite2D


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	if player.still:
		return
	
	match player.player_direction:
		Vector2.UP:
			animated_sprite_2d.play("Idle back")
		Vector2.DOWN:
			animated_sprite_2d.play("Idle front")
		Vector2.LEFT:
			animated_sprite_2d.play("Idle left")
		Vector2.RIGHT:
			animated_sprite_2d.play("Idle right")
		_:
			animated_sprite_2d.play("Idle front")


func _on_next_transitions() -> void:
	GameInputEvent.movement_input()
	
	if player.has_destination:
		transition.emit("Navigate")
		print("Navigation started")
		return
		
	if GameInputEvent.is_movement_input() and GameState.can_move:
		transition.emit("Walk")


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
