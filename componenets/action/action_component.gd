class_name ActionComponent
extends Node2D

@onready var action_prompt: PanelContainer = $ActionPrompt
@onready var label: Label = $ActionPrompt/MarginContainer/HboxContainer/Label


var can_do_action: bool = false
var perform: Callable = func():
	pass

func _ready() -> void:
	action_prompt.modulate.a = 0.0


func set_action(action: String, call_back: Callable) -> void:
	can_do_action = true
	perform = call_back
	label.text = "to " + action
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(action_prompt, "modulate:a", 1.0, 0.3)

func enable_action() -> void:
	can_do_action = true
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(action_prompt, "modulate:a", 1.0, 0.3)

func disable_action() -> void:
	can_do_action = false
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(action_prompt, "modulate:a", 0.0, 0.3)

func _process(_delta: float) -> void:
	if GameInputEvent.action() and can_do_action:
		can_do_action = false
		perform.call()
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(action_prompt, "modulate:a", 0.0, 0.3)
