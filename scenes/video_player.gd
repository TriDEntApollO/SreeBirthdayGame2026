class_name VideoPlayer
extends CanvasLayer

signal video_player_closed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var video_stream_player: VideoStreamPlayer = $Control/VideoStreamPlayer

# Buttons
@onready var play: TextureButton = $Control/Buttons/Play
@onready var pause: TextureButton = $Control/Buttons/Pause
@onready var stop: TextureButton = $Control/Buttons/Stop
@onready var restart: TextureButton = $Control/Buttons/Restart
@onready var close: TextureButton = $Control/Buttons/Close

var video_stopped: bool = false
var video_stream: VideoStream

func _reset() -> void:
	hide()
	play.hide()
	close.hide()
	animation_player.play("RESET")

func _ready() -> void:
	_reset()
	play.pressed.connect(_resume_video)
	pause.pressed.connect(_pause_video)
	stop.pressed.connect(_stop_video)
	restart.pressed.connect(_restart_video)
	close.pressed.connect(_close_player)
	video_stream_player.finished.connect(_on_video_end)


func play_video(video_name: String) -> void :
	Ui.pause_music(true)
	GameState.show_cursor()
	show()
	play.hide()
	pause.show()
	close.hide()
	video_stopped = false
	video_stream = GameState.video[video_name]
	video_stream_player.stream = video_stream
	
	animation_player.play("RESET")
	animation_player.play("FadeIn")
	await animation_player.animation_finished
	
	video_stream_player.play()
	
	await video_player_closed
	Ui.pause_music(false)


func _pause_video() -> void:
	play.show()
	pause.hide()
	video_stream_player.paused = true


func _resume_video() -> void:
	play.hide()
	pause.show()

	if video_stopped:
		video_stream_player.stream = video_stream
		video_stream_player.show()
		video_stream_player.play()
		video_stopped = false
	else:
		video_stream_player.paused = false


func _stop_video() -> void:
	pause.hide()
	play.show()

	video_stream_player.stop()
	video_stream_player.hide()

	video_stopped = true


func _restart_video() -> void:
	video_stream_player.stop()
	video_stream_player.stream = video_stream
	if video_stopped:
		video_stream_player.show()
		video_stopped = false
	video_stream_player.play()


func _close_player() -> void:
	video_stream = null
	video_stopped = false
	video_stream_player.stop()
	animation_player.play("FadeOut")
	await animation_player.animation_finished
	hide()
	
	video_player_closed.emit()


func _on_video_end():
	pause.hide()
	play.show()
	close.show()
	video_stopped = true
