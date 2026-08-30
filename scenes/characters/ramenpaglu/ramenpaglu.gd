extends Node2D

@onready var character: NPC = $NpcComponent
@onready var gift_boxes: Node2D = $NpcComponent/GiftBoxes
@onready var interactable: Interactable = $"NpcComponent/Interactable"
@onready var animated_sprite_2d: AnimatedSprite2D = $NpcComponent/AnimatedSprite2D
@onready var box_1: Sprite2D = $NpcComponent/GiftBoxes/Box1
@onready var box_2: Sprite2D = $NpcComponent/GiftBoxes/Box2
@onready var box_3: Sprite2D = $NpcComponent/GiftBoxes/Box3
@onready var painting_ui: Control = $Painting/Control
@onready var canvas: TextureRect = $Painting/Control/PanelContainer/TextureRect

var painting: bool = false
var all_tasks_done: bool = false
var first_interaction: bool = true
var dialogue_file_path: String = "res://dialogue/conversations/ramenpaglu.dialogue"

var paint_frames: Array = [
	preload("res://assets/images/Sree 0.png"),
	preload("res://assets/images/Sree 1.png"),
	preload("res://assets/images/Sree 2.png"),
	preload("res://assets/images/Sree 3.png"),
	preload("res://assets/images/Sree 4.png"),
	preload("res://assets/images/Sree 5.png"),
	preload("res://assets/images/Sree 6.png"),
	preload("res://assets/images/Sree 7.png"),
]


func _ready() -> void:
	gift_boxes.hide()
	painting_ui.hide()
	painting_ui.modulate.a = 0.0
	set_character_enabled(false)
	character.set_interactale(false)
	interactable.on_interact = _on_interact
	interactable.add_outline(animated_sprite_2d)
	interactable.add_outline(box_1)
	interactable.add_outline(box_2)
	interactable.add_outline(box_3)
	box_1.set_instance_shader_parameter("line_thickness", 10.0)
	box_2.set_instance_shader_parameter("line_thickness", 10.0)
	box_3.set_instance_shader_parameter("line_thickness", 10.0)
	EventManager.task_updated.connect(_on_task_update)
	EventManager.event_start.connect(_on_event_start)
	EventManager.event_end.connect(_on_event_end)

func paint(stage: int) -> void:
	match stage:
		1:
			character.animate_pause = true
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_IN_OUT)
			painting_ui.show()
			tween.tween_property(painting_ui, "modulate:a", 1.0, 0.3)
			await tween.finished
			animated_sprite_2d.play("Painting")
			canvas.texture = paint_frames[0]
		2:
			animated_sprite_2d.play("Painting")
			for i in range(1, 5):
				canvas.texture = paint_frames[i]
				await GameState.delay(1)
		3:
			animated_sprite_2d.play("Painting")
			for i in range(5, 8):
				canvas.texture = paint_frames[i]
				await GameState.delay(1)
		4:
			character.animate_pause = false
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_IN_OUT)
			painting_ui.hide()
			tween.tween_property(painting_ui, "modulate:a", 0.0, 0.3)
			await tween.finished
			animated_sprite_2d.play("Idle right")

func _on_task_update(task_id: int) -> void:
	if task_id == EventManager.task_ids.talk_to_ramenpaglu:
		all_tasks_done = true
		gift_boxes.show()

func set_character_enabled(enabled: bool) -> void:
	visible = enabled
	character.set_enabled(enabled)


func _on_interact() -> void:
	GameState.show_cursor()
	interactable.is_interactable = false
	character.turn_to_sree()
	Ui.dialogue_balloon.start(load(dialogue_file_path), "start", [self])
	await Ui.dialogue_balloon.dialogue_ended
	GameState.hide_cursor()
	character.face_direction("right")

func _on_event_start(event_id: int) -> void:
	if event_id == EventManager.event_ids.pre_dining_event:
		set_character_enabled(true)
	elif event_id == EventManager.event_ids.dining_event:
		character.go_to("DiningRamenPaglu", "right")

func _on_event_end(event_id: int) -> void:
	if event_id == EventManager.event_ids.cake_event:
		character.set_interactale(true)
		character.go_to("BedroomRamenPaglu", "right")
