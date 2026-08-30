extends CanvasLayer

enum ConfirmationAction {
	NONE,
	RESTART,
	QUIT,
}

var confirmation_action: ConfirmationAction = ConfirmationAction.NONE


@onready var resume: Button = $Control/Menu/VBoxContainer/Resume
@onready var restart: Button = $Control/Menu/VBoxContainer/Restart
@onready var controls: Button = $Control/Menu/VBoxContainer/Controls
@onready var settings: Button = $Control/Menu/VBoxContainer/Settings
@onready var quit: Button = $Control/Menu/VBoxContainer/Quit

@onready var close: Button = $Control/ControlsView/Close

@onready var yes: Button = $Control/Confirmation/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Yes
@onready var no: Button = $Control/Confirmation/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/No

@onready var confirmation: Control = $Control/Confirmation
@onready var controls_view: Control = $Control/ControlsView
@onready var settings_menu: Control = $Control/SettingsMenu

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var menu_start_sfx: AudioStreamPlayer2D = $MenuStartSFX

func _ready() -> void:
	hide()
	confirmation.hide()
	controls_view.hide()
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	resume.pressed.connect(_on_resume_pressed)
	restart.pressed.connect(_on_restart_pressed)
	controls.pressed.connect(_on_controls_pressed)
	settings.pressed.connect(_on_settings_pressed)
	quit.pressed.connect(_on_quit_pressed)

	close.pressed.connect(_on_close_pressed)

	yes.pressed.connect(_on_confirmation_yes_pressed)
	no.pressed.connect(_on_confirmation_no_pressed)


func pause() -> void:
	GameState.show_cursor()
	get_tree().paused = true
	show()
	animation_player.play("Open")
	menu_start_sfx.play()


func unpause() -> void:
	animation_player.play("Close")
	await animation_player.animation_finished
	animation_player.play("RESET")
	
	confirmation.hide()
	controls_view.hide()
	settings_menu.hide()
	confirmation_action = ConfirmationAction.NONE
	hide()
	
	if not GameState.game_cursor_on:
		GameState.hide_cursor()
	get_tree().paused = false

func _on_settings_pressed() -> void:
	settings_menu.show_settings()

func _on_resume_pressed() -> void:
	Ui._unpause()


func _on_controls_pressed() -> void:
	controls_view.show()


func _on_close_pressed() -> void:
	controls_view.hide()


func _on_restart_pressed() -> void:
	confirmation_action = ConfirmationAction.RESTART
	confirmation.show()


func _on_quit_pressed() -> void:
	confirmation_action = ConfirmationAction.QUIT
	confirmation.show()


func _on_confirmation_yes_pressed() -> void:
	match confirmation_action:
		ConfirmationAction.RESTART:
			_restart()

		ConfirmationAction.QUIT:
			_quit()

		ConfirmationAction.NONE:
			push_warning("Confirmation pressed without an action")

	confirmation_action = ConfirmationAction.NONE
	confirmation.hide()


func _on_confirmation_no_pressed() -> void:
	confirmation_action = ConfirmationAction.NONE
	confirmation.hide()


func _restart() -> void:
	unpause()
	GameState.reset()
	get_tree().reload_current_scene()


func _quit() -> void:
	hide()
	GameState.quit_to_start_menu()
	get_tree().paused = false
