class_name GiftBoxPopUp
extends CanvasLayer

# Gifts
@onready var makeup: Sprite2D = $Control/PanelContainer/MarginContainer/VBoxContainer/GiftContainer/Gifts/Makeup
@onready var perfume: Sprite2D = $Control/PanelContainer/MarginContainer/VBoxContainer/GiftContainer/Gifts/Perfume
@onready var cat: Sprite2D = $Control/PanelContainer/MarginContainer/VBoxContainer/GiftContainer/Gifts/Cat
@onready var painting: Sprite2D = $Control/PanelContainer/MarginContainer/VBoxContainer/GiftContainer/Gifts/Painting

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var button: Button = $Control/PanelContainer/MarginContainer/VBoxContainer/Button
@onready var animated_sprite_2d: AnimatedSprite2D = $Control/PanelContainer/MarginContainer/VBoxContainer/AnimatedSprite2D

static var animation_done: bool = false

func _ready() -> void:
	var color: Color = Color(0.113, 0.0, 0.151, 1.0)
	animated_sprite_2d.set_instance_shader_parameter("line_color", color)
	_reset()


func _reset() -> void:
	hide()
	makeup.hide()
	perfume.hide()
	cat.hide()
	painting.hide()
	
	animation_player.play("RESET")
	animation_done = false

func give_gift(gift: String) -> void:

	match gift:
		"cat":
			cat.show()
		"perfume":
			perfume.show()
		"makeup":
			makeup.show()
		"painting":
			painting.show()
	
	show()
	animation_player.play("GiftOpen")
	Ui.play_sfx("recieved")
	await animation_player.animation_finished
	animation_done = true
	
	await button.pressed
	
	animation_player.play("Fade")
	await animation_player.animation_finished
	_reset()
