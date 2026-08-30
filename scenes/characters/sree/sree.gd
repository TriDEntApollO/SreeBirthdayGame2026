class_name Sree
extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D
@onready var interacting_component: Node2D = $InteractingComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var still: bool = false
var face_direction: Vector2
var has_destination: bool = false
var player_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	GameState.sree = self
	

func is_facing_position(target_position: Vector2) -> bool:
	var direction := (target_position - global_position).normalized()
	return direction.dot(player_direction) > 0.5
	

func set_still(_still: bool) -> void:
	still = _still
	if still:
		animated_sprite_2d.play("Still")


func set_interact(can_interact: bool) -> void:
	interacting_component.can_interact = can_interact


func turn_towards(location: Vector2) -> void:
	var diff := location - global_position
	
	if abs(diff.x) > abs(diff.y):
		player_direction = Vector2.RIGHT if diff.x > 0 else Vector2.LEFT
	else:
		player_direction = Vector2.DOWN if diff.y > 0 else Vector2.UP


func go_to(location: String, face: Vector2) -> void:
	var pos = GameState.get_position(location)
	if pos == null:
		return
	navigation_agent.target_position = pos
	has_destination = true
	face_direction = face

func reached_destination():
	velocity = Vector2.ZERO
	has_destination = false
	player_direction = face_direction
