extends CanvasLayer


@onready var found_piece: PanelContainer = $Control/FoundPiece
@onready var found_label: Label = $Control/FoundPiece/MarginContainer/VBoxContainer/HBoxContainer/Found
@onready var button: Button = $Control/FoundPiece/MarginContainer/VBoxContainer/Button
@onready var found_collectable: PanelContainer = $Control/FoundCollectable
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var surprise_button: Button = $Control/FoundCollectable/MarginContainer/VBoxContainer/Button

func _reset() -> void:
	hide()
	found_piece.show()
	found_collectable.hide()
	animation_player.play("RESET")

func _ready() -> void:
	_reset()

func found() -> void:
	GameState.show_cursor()
	found_label.text = str(GameState.collectables_count)
	show()
	animation_player.play("UiPop")
	Ui.play_sfx("collected")
	await button.pressed
	animation_player.play("UiFade")
	await animation_player.animation_finished
	hide()
	if not GameState.game_cursor_on:
		GameState.hide_cursor()
	
	if GameState.collectables_count >= 6:
		await surprise()
	

func surprise() -> void:
	found_piece.hide()
	found_collectable.show()
	GameState.show_cursor()
	show()
	Ui.play_sfx("recieved")
	animation_player.play("UiPop")

	await surprise_button.pressed

	animation_player.play("UiFade")
	await animation_player.animation_finished
	hide()
	if not GameState.game_cursor_on:
		GameState.hide_cursor()
