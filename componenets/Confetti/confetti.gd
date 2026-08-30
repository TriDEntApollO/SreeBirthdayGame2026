extends Node2D

@onready var right_green: CPUParticles2D = $Right/Green
@onready var right_red: CPUParticles2D = $Right/Red
@onready var right_blue: CPUParticles2D = $Right/Blue
@onready var right_yellow: CPUParticles2D = $Right/Yellow
@onready var left_green: CPUParticles2D = $Left/Green
@onready var left_red: CPUParticles2D = $Left/Red
@onready var left_blue: CPUParticles2D = $Left/Blue
@onready var left_yellow: CPUParticles2D = $Left/Yellow


func pop() -> void:
	Ui.play_sfx("confetti")
	right_green.emitting = true
	right_red.emitting = true
	right_blue.emitting = true
	right_yellow.emitting = true
	left_green.emitting = true
	left_red.emitting = true
	left_blue.emitting = true
	left_yellow.emitting = true
