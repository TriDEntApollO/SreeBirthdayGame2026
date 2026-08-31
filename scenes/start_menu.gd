extends Node2D

@onready var confirmation: Control = $CanvasLayer/Confirmation
@onready var settings_menu: Control = $CanvasLayer/SettingsMenu
@onready var start_menu_music: AudioStreamPlayer2D = $StartMenuMusic
@onready var thank_you: Control = $CanvasLayer/ThankYou

# Menu Buttons
@onready var start: Button = $CanvasLayer/Buttons/Start
@onready var settings: Button = $CanvasLayer/Buttons/Settings
@onready var quit: Button = $CanvasLayer/Buttons/Quit
@onready var yes: Button = $CanvasLayer/Confirmation/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Yes
@onready var no: Button = $CanvasLayer/Confirmation/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/No

func _ready() -> void:
	thank_you.hide()
	GameState.start_menu_active = true
	GameState.game_cursor_on = true
	_sync_mouse_hover()
	
	GameState.delay(0.5)
	
	Ui.play_ui_sfx("menu_open")
	start_menu_music.play()
	
	start.pressed.connect(_start)
	settings.pressed.connect(_settings)
	quit.pressed.connect(_show_confirmation)
	no.pressed.connect(_cancel)
	yes.pressed.connect(_quit)

func _sync_mouse_hover() -> void:
	await get_tree().process_frame
	var viewport_size := get_viewport().get_visible_rect().size
	var cursor_position := Vector2(viewport_size.x * 0.75, viewport_size.y / 3.0)
	GameState.show_cursor(cursor_position)
	var motion := InputEventMouseMotion.new()
	motion.position = cursor_position
	motion.global_position = cursor_position
	Input.parse_input_event(motion)

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
	if OS.has_feature("web"):
		thank_you.show()
		get_tree().paused = true
	else:
		GameState.exit_game()
