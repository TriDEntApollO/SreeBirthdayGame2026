extends NodeState

@export var player: Sree
@export var animated_sprite_2d: AnimatedSprite2D
@export var speed: int = 80


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	var direction: Vector2 = GameInputEvent.movement_input()
	
	match direction:
		Vector2.UP:
			animated_sprite_2d.play("Walk back")
		Vector2.DOWN:
			animated_sprite_2d.play("Walk front")
		Vector2.LEFT:
			animated_sprite_2d.play("Walk left")
		Vector2.RIGHT:
			animated_sprite_2d.play("Walk right")
	
	if direction != Vector2.ZERO:
		player.player_direction = direction
	
	player.velocity = direction * speed
	player.move_and_slide()


func _on_next_transitions() -> void:
	if not GameInputEvent.is_movement_input() or not GameState.can_move:
		transition.emit("Idle")
		return


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
