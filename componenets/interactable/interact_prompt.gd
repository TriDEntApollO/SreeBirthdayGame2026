@tool
extends Node2D

@export var prompt: String = "Interact":
	set(value):
		prompt = value
		call_deferred("_update_prompt")

@onready var label: Label = $PanelContainer/MarginContainer/HBoxContainer/Label


func _ready() -> void:
	_update_prompt()


func _update_prompt() -> void:
	if is_instance_valid(label):
		label.text = "to " + prompt
