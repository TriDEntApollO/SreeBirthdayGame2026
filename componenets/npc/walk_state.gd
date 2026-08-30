extends NodeState

@export var character: NPC
@onready var navigation_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"


func _ready() -> void:
	#navigation_agent.velocity_computed.connect(_on_velocity_computed)
	pass

func _update_animation() -> void:
	var direction := character.npc_direction

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


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	var next_position := navigation_agent.get_next_path_position()
	character.npc_direction = character.global_position.direction_to(next_position)

	character.velocity = character.npc_direction * character.npc_speed
	_update_animation()
	
	character.move_and_slide()


#func _on_velocity_computed(safe_velocity: Vector2) -> void:
	#character.velocity = safe_velocity
	#
	#if safe_velocity.length_squared() > 0.0:
		#character.npc_direction = safe_velocity.normalized()
	#
	#character.move_and_slide()

func _on_next_transitions() -> void:
	if character.navigation_agent.is_navigation_finished():
		character.reached_destination()
		transition.emit("Idle")


func _on_enter() -> void:
	_update_animation()


func _on_exit() -> void:
	animated_sprite_2d.stop()
