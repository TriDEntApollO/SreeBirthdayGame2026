class_name Feedable
extends Node2D

signal finished_feed_event

@export var outline: Node2D
@export var character_name: String = ""

@onready var feed_prompt: Node2D = $CanvasLayer/FeedPrompt
@onready var label: Label = $CanvasLayer/FeedPrompt/Panel/MarginContainer/HboxContainer/Label

var is_hovered: bool = false
var is_feedable: bool = false
var cake_slice_in_range: CakeSlice
var call_back: Callable = func():
	pass

func _ready() -> void:
	label.text = "to Feed " + character_name
	add_to_group("Feedables")
	feed_prompt.hide()
	if outline:
		outline.set_instance_shader_parameter("outline_enabled", false)


func _process(_delta: float) -> void:
	var can_feed_now := is_feedable and is_hovered and cake_slice_in_range != null and cake_slice_in_range.is_dragging

	if can_feed_now:
		feed_prompt.show()
		if outline:
			outline.set_instance_shader_parameter("outline_enabled", true)
	else:
		feed_prompt.hide()
		if outline:
			outline.set_instance_shader_parameter("outline_enabled", false)

	if not can_feed_now:
		return
		
	if GameInputEvent.action():
		var cake_slice := cake_slice_in_range
		is_feedable = false
		is_hovered = false
		cake_slice_in_range = null
		CakeScene.feed_left -= 1
		feed_prompt.hide()
		if outline:
			outline.set_instance_shader_parameter("outline_enabled", false)
		if cake_slice != null:
			cake_slice.freeze = true
			cake_slice.can_drop = false
		Ui.play_sfx("munch")
		CakeScene.animate_cake.play("Feed")
		
		if CakeScene.feed_left <= 0:
			finished_feed_event.emit()

func _on_range_body_entered(body: Node2D) -> void:
	if not is_feedable or not body is CakeSlice:
		return
	
	cake_slice_in_range = body
	is_hovered = true


func _on_range_body_exited(body: Node2D) -> void:
	if not body is CakeSlice:
		return
	
	if cake_slice_in_range == body:
		cake_slice_in_range = null
	is_hovered = false
	feed_prompt.hide()
	if outline:
		outline.set_instance_shader_parameter("outline_enabled", false)
