class_name NPC
extends CharacterBody2D

@onready var interactable: Interactable = $Interactable
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var interact_prompt: Node2D = $Interactable/InteractPrompt

@export var character_name: String = "Unkown"

var animate_pause: bool = false
var first_interaction: bool = true
var is_interactable: bool = true
var npc_speed: float = 70
var npc_facing: Vector2 = Vector2.DOWN
var npc_direction: Vector2 = Vector2.ZERO
var has_destination: bool = false

var directions = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
}

func _ready() -> void:
		interact_prompt.prompt = "talk with " + character_name

func set_enabled(enabled: bool) -> void:
	visible = enabled

	$CollisionShape2D.set_deferred("disabled", not enabled)
	$Interactable/CollisionShape2D.set_deferred("disabled", not enabled)


func set_interactale(enabled: bool) -> void:
	is_interactable = enabled
	if not has_destination:
		interactable.is_interactable = enabled

func go_to(location: String, face: String) -> void:
	var pos = GameState.get_position(location)
	if pos == null:
		return
		
	interactable.is_interactable = false
	navigation_agent.target_position = pos
	has_destination = true
	npc_facing = directions[face]


func face_direction(direction: String):
	npc_facing = directions[direction]


func reached_destination():
	has_destination = false
	if is_interactable:
		interactable.is_interactable = true


func turn_to_sree() -> void:
	var diff := GameState.sree.global_position - global_position
	
	if abs(diff.x) > abs(diff.y):
		face_direction("right" if diff.x > 0 else "left")
	else:
		face_direction("down" if diff.y > 0 else "up")
