extends Node2D

@onready var flame_and_smoke: AnimatedSprite2D = $FlameAndSmoke
@onready var cake: Sprite2D = $Cake
@onready var cake_cut: Sprite2D = $CakeCut
@onready var cake_action: ActionComponent = Ui.action_component

var can_cut: bool = false

func _ready() -> void:
	cake_cut.hide()
	cake.material.set_shader_parameter("line_thickness", 8.0)

func blow_candle() -> void:
	flame_and_smoke.play("Smoke")

func cut() -> void:
	cake_cut.show()
	cake.hide()


func _on_area_2d_area_entered(_area: Area2D) -> void:
	if CakeScene.knife_grabbed:
		cake.material.set_shader_parameter("outline_enabled", true)
		cake_action.enable_action()


func _on_area_2d_area_exited(_area: Area2D) -> void:
	cake.material.set_shader_parameter("outline_enabled", false)
	cake_action.disable_action()
