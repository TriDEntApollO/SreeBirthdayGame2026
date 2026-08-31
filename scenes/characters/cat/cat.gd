extends StaticBody2D

@onready var interactable: Interactable = $Interactable
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var meows: Array[AudioStream] = [
	preload("uid://bsyf752mju0o8"),
	preload("uid://bvaqpwl3k42qk"),
	preload("uid://dx85xyvey1ckf"),
	preload("uid://ddx85am5abyix"),
	preload("uid://pdpajxmikdm4"),
]


func _ready() -> void:
	set_enabled(false)
	animated_sprite_2d.material.set_shader_parameter("line_thickness", 2.0)
	interactable.interact_once = false
	interactable.on_interact = _on_interact
	interactable.add_outline(animated_sprite_2d)
	EventManager.event_start.connect(_on_event_start)


func set_enabled(enabled: bool) -> void:
	visible = enabled

	$CollisionShape2D.set_deferred("disabled", not enabled)
	$Interactable/CollisionShape2D.set_deferred("disabled", not enabled)


func _on_interact() -> void:
	interactable.is_interactable = false
	animation_player.play("Shake")
	audio_stream_player_2d.stream = meows.pick_random()
	audio_stream_player_2d.play()
	await audio_stream_player_2d.finished


func _on_event_start(event_id: int) -> void:
	if event_id == EventManager.event_ids.cat_given_event:
		set_enabled(true)
		interactable.is_interactable = true
		EventManager.end_event(EventManager.event_ids.cat_given_event)
