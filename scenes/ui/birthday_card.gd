extends CanvasLayer

@onready var birthday_music: AudioStreamPlayer2D = $BirthdayMusicPLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var open: Button = $Control/Open
@onready var close: Button = $Control/Close


func _reset() -> void:
	hide()
	close.hide()
	open.show()
	animation_player.play("RESET")
	birthday_music.stop()


func _ready() -> void:
	_reset()
	open.pressed.connect(open_card)


func show_card() -> void:
	show()
	Ui.pause_music(true)
	birthday_music.play()
	animation_player.play("FadeIn")
	await animation_player.animation_finished
	
	await close.pressed
	
	animation_player.play("FadeOut")
	await animation_player.animation_finished
	birthday_music.stop()
	Ui.pause_music(false)
	hide()


func open_card() -> void:
	Ui.play_sfx("card_open")
	animation_player.play("Open")
	await animation_player.animation_finished
	close.show()
	open.hide()
