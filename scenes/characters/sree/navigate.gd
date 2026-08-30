extends NodeState

@export var player: Sree
@export var animated_sprite_2d: AnimatedSprite2D
@export var speed: int = 80


func _on_physics_process(_delta: float) -> void:
	var next_position := player.navigation_agent.get_next_path_position()
	var direction := player.global_position.direction_to(next_position)

	if direction != Vector2.ZERO:
		player.player_direction = direction

	player.velocity = direction * speed
	player.move_and_slide()

	_update_animation(direction)


func _update_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animated_sprite_2d.play("Walk right")
		else:
			animated_sprite_2d.play("Walk left")
	else:
		if direction.y > 0:
			animated_sprite_2d.play("Walk front")
		else:
			animated_sprite_2d.play("Walk back")


func _on_next_transitions() -> void:
	if player.navigation_agent.is_navigation_finished():
		player.reached_destination()
		transition.emit("Idle")
		return


func _on_enter() -> void:
	print("Entered navigation")


func _on_exit() -> void:
	player.velocity = Vector2.ZERO
	animated_sprite_2d.stop()
