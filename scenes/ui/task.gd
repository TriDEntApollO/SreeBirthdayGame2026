class_name Task
extends PanelContainer

# UI elements
@onready var task_label: Label = $MarginContainer/HBoxContainer/TaskLabel
@onready var task_sfx: AudioStreamPlayer2D = $TaskSFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@export var task_name: String


func _ready() -> void:
	hide()
	
func start_task():
	task_label.text = task_name
	show()
	task_sfx.stream = GameState.sfx["task_create"]
	task_sfx.play()
	animation_player.play("Create")
	await animation_player.animation_finished

func end_task():
	task_sfx.stream = GameState.sfx["task_finish"]
	task_sfx.play()
	animation_player.play("Finish")
	await animation_player.animation_finished
	hide()
