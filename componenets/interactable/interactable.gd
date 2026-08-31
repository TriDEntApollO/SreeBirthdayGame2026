class_name Interactable
extends Area2D

@export var prompt: Node2D
@export var interact_once: bool = true
@export var is_interactable: bool = false
@export var interactable_name: String = ""
@export var collectable: bool = false

var outlines: Array[Node2D] = []

var on_interact: Callable = func():
	pass

func _ready() -> void:
	if not prompt:
		prompt = get_node_or_null("InteractPrompt")
		
	if prompt:
		prompt.hide()


func add_outline(node: Node2D) -> void:
	if node == null:
		push_error("Outline Node cannol be 'null'")
		return
	outlines.append(node)

func focus() -> void:
	for outline in outlines:
		outline.material.set_shader_parameter("outline_enabled", true)
	
func unfocus() -> void:
	if prompt:
		prompt.hide()
	for outline in outlines:
		outline.material.set_shader_parameter("outline_enabled", false)

func interact() -> void:
	is_interactable = false
	await on_interact.call()
	if not interact_once:
		is_interactable = true
