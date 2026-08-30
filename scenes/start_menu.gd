extends Node2D

@onready var confirmation: Control = $CanvasLayer/Confirmation
@onready var settings_menu: Control = $CanvasLayer/SettingsMenu
@onready var start_menu_music: AudioStreamPlayer2D = $StartMenuMusic

# Menu Buttons
@onready var start: Button = $CanvasLayer/Buttons/Start
@onready var settings: Button = $CanvasLayer/Buttons/Settings
@onready var quit: Button = $CanvasLayer/Buttons/Quit
@onready var yes: Button = $CanvasLayer/Confirmation/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Yes
@onready var no: Button = $CanvasLayer/Confirmation/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/No

func _ready() -> void:
	GameState.start_menu_active = true
	GameState.game_cursor_on = true
	GameState.show_cursor()
	
	GameState.delay(0.5)
	
	Ui.play_ui_sfx("menu_open")
	start_menu_music.play()
	
	start.pressed.connect(_start)
	settings.pressed.connect(_settings)
	quit.pressed.connect(_show_confirmation)
	no.pressed.connect(_cancel)
	yes.pressed.connect(_quit)

func _start() -> void:
	GameState.game_cursor_on = false
	GameState.hide_cursor()
	GameState.start_game()

func _settings() -> void:
	settings_menu.show_settings()

func _show_confirmation() -> void:
	confirmation.show()

func _cancel() -> void:
	confirmation.hide()

func _quit() -> void:
	GameState.exit_game()
