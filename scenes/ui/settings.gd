extends Control

@onready var close: Button = $PanelContainer/MarginContainer/VBoxContainer/Close
@onready var fs_button: CheckButton = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/FullScreen/FSButton
@onready var tut_button: CheckButton = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Tutorial/TutButton

@onready var fs_label: Label = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/FullScreen/FsLabel
@onready var tut_label: Label = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Tutorial/TutLabel

func _ready() -> void:
	hide()
	fs_button.toggled.connect(_fullscreen)
	tut_button.toggled.connect(_tutorial)
	close.pressed.connect(hide_settings)
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fs_label.text = "Fullscreen"
		fs_button.set_pressed_no_signal(true)
	else:
		fs_label.text = "Windowed"
		fs_button.set_pressed_no_signal(true)
	
	if GameState.tutorial:
		tut_label.text = "Tutorial (Enabled)"
		tut_button.set_pressed_no_signal(true)
	else:
		tut_label.text = "Tutorial (Disabled)"
		tut_button.set_pressed_no_signal(false)


func show_settings() -> void:
	show()


func hide_settings() -> void:
	hide()


func _fullscreen(toggled_on: bool) -> void:
	if toggled_on:
		fs_label.text = "Fullscreen"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: 
		fs_label.text = "Windowed"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _tutorial(toggled_on: bool) -> void:
		if toggled_on:
			tut_label.text = "Tutorial (Enabled)"
			GameState.tutorial = true
		else: 
			tut_label.text = "Tutorial (Disabled)"
			GameState.tutorial = false
