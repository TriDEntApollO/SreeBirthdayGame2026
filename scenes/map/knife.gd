class_name Knife
extends RigidBody2D

@onready var boundary_bottom: CollisionShape2D = $"../Boundary/BoundaryBottom"
@onready var grab_prompt: Node2D = $GrabPrompt
@onready var default_position: Vector2 = global_position
@onready var sprite_2d: Sprite2D = $Sprite2D

var first_grab: bool = true

var is_grabable: bool = false
var is_hovered: bool = false
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	grab_prompt.hide()
	contact_monitor = true
	max_contacts_reported = 1
	lock_rotation = true
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

func reset() -> void:
	global_position = default_position
	sprite_2d.material.set_shader_parameter("outline_enabled", false)
	is_hovered = false
	is_dragging = false
	grab_prompt.hide()
	freeze = true
	linear_velocity = Vector2.ZERO
	CakeScene.knife_grabbed = false


func _physics_process(_delta: float) -> void:
	if GameInputEvent.grabbed() and is_grabable:
		if !is_dragging and is_hovered:
			CakeScene.knife_grabbed = true
			is_dragging = true
			freeze = true
			linear_velocity = Vector2.ZERO
			drag_offset = global_position - get_global_mouse_position()
			grab_prompt.hide()
			sprite_2d.material.set_shader_parameter("outline_enabled", false)
			
			if first_grab:
				await EventManager.finish_task(EventManager.task_ids.pick_up_knife)
				first_grab = false
		
		if is_dragging:
			global_position = get_global_mouse_position() + drag_offset
		return

	if is_dragging:
		grab_prompt.show()
		sprite_2d.material.set_shader_parameter("outline_enabled", true)
		CakeScene.knife_grabbed = false
		is_dragging = false
		freeze = false


func is_over_table() -> bool:
	var left := 370
	var right := 1004
	
	return global_position.x > left and global_position.x < right

func _on_mouse_entered() -> void:
	if !is_dragging and is_grabable:
		is_hovered = true
		grab_prompt.show()
		sprite_2d.material.set_shader_parameter("outline_enabled", true)


func _on_mouse_exited() -> void:
	if is_grabable:
		is_hovered = false
		grab_prompt.hide()
		sprite_2d.material.set_shader_parameter("outline_enabled", false)


func _on_body_shape_entered(_body_rid: RID, body: Node, body_shape_index: int, _local_shape_index: int) -> void:
	var shape_owner: int = body.shape_find_owner(body_shape_index)
	var shape_node: Node = body.shape_owner_get_owner(shape_owner)

	if shape_node == boundary_bottom and not is_over_table():
		call_deferred("reset")
