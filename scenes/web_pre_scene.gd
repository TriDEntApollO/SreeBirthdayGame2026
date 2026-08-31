extends Control

@onready var load_button: Button = $Button
@onready var mobile_warning: Control = $MobileWarning
@onready var close: UiMenuButton = $MobileWarning/PanelContainer/MarginContainer/VBoxContainer/Close
@onready var preferable: Control = $Preferable
@onready var continue_button: UiMenuButton = $Preferable/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Continue
@onready var download: UiMenuButton = $Preferable/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Download


func _ready() -> void:
	mobile_warning.hide()
	preferable.hide()
	load_button.pressed.connect(_show_preferable)
	continue_button.pressed.connect(_on_load)
	download.pressed.connect(_on_download)
	
	if not OS.has_feature("web"):
		load_button.hide()
		await GameState.quit_to_start_menu()
		return
	
	if is_mobile_device():
		close.pressed.connect(_exit)
		show_mobile_warning()


func _on_download() -> void:
	OS.shell_open("https://tridentapollo.itch.io/sreebirthdaygame2026")


func _show_preferable() -> void:
	preferable.show()


func _on_load() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	GameState.quit_to_start_menu()


func _exit() -> void:
	mobile_warning.hide()
	get_tree().quit()

func is_mobile_device() -> bool:
	if not OS.has_feature("web"):
		return false

	var navigator := JavaScriptBridge.get_interface("navigator")

	var user_agent: String = navigator.userAgent.to_lower()

	return (
		"android" in user_agent
		or "iphone" in user_agent
		or "ipad" in user_agent
		or "ipod" in user_agent
	)


func show_mobile_warning() -> void:
	load_button.hide()
	mobile_warning.show()
