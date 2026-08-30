class_name CakeScene
extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var cake: Node2D = $Cake
@onready var cake_action: ActionComponent = Ui.action_component
@onready var transition: ColorRect = Ui.get_node("Transition")
@onready var knife: RigidBody2D = $Knife
@onready var confetti: Node2D = $CanvasLayer/Confetti
@onready var cake_event_sfx: AudioStreamPlayer2D = $CakeEventSFX
@onready var birthday_music: AudioStreamPlayer2D = $BirthdayMusic

static var animate_cake: AnimationPlayer
static var cake_slice: RigidBody2D
static var knife_grabbed: bool = false
static var cake_grabbed: bool = false
static var feed_left: int = 0


var outline_color: Color = Color(0.815, 0.671, 0.847, 1.0)
var dialogue_file = preload("res://dialogue/conversations/cake_event.dialogue")

func _ready() -> void:
	animate_cake = $CakeSlice/AnimateCake
	cake_slice = $CakeSlice
	cake_slice.hide()
	
	for feedable in get_tree().get_nodes_in_group("Feedables"):
		feedable.finished_feed_event.connect(finished_feed_event)
		feed_left += 1
		
	$Characters/RamenPaglu.set_instance_shader_parameter("line_color", outline_color)
	$Characters/PorkPaglu.set_instance_shader_parameter("line_color", outline_color)
	$Characters/Appa.set_instance_shader_parameter("line_color", outline_color)
	$Characters/Omma.set_instance_shader_parameter("line_color", outline_color)
	$Characters/Upasana.set_instance_shader_parameter("line_color", outline_color)
	
	await GameState.delay(0.5)
	initiate_event()


func initiate_event() -> void:
	birthday_music.play()
	await GameState.delay(1.5)
	EventManager.add_task()
	Ui.dialogue_balloon.start(dialogue_file, "blow", [self])
	await DialogueManager.dialogue_ended
	await GameState.delay(0.5)
	cake_action.set_action("Blow Candle", blow_candle)


func blow_candle() -> void:
	GameState.game_cursor_on = true
	cake_event_sfx.stream = GameState.sfx["blow_candle"]
	cake_event_sfx.play()
	await cake_event_sfx.finished
	
	cake.blow_candle()
	cake.can_cut = true
	knife.is_grabable = true
	confetti.pop()
	await get_tree().create_timer(0.5).timeout
	cake_action.set_action("Cut Cake", cut_cake)
	cake_action.disable_action()
	EventManager.finish_task(EventManager.task_ids.blow_candles)
	EventManager.add_task()
	EventManager.add_task()
	Ui.dialogue_balloon.start(dialogue_file, "cut")


func cut_cake() -> void:
	cake_event_sfx.stream = GameState.sfx["clapping"]
	cake_event_sfx.play()
	
	await transition.fade_in()
	cake.can_cut = false
	knife.is_grabable = false
	cake.cut()
	cake_slice.show()
	knife.reset()
	cake_slice.is_grabable = true
	for feedable in get_tree().get_nodes_in_group("Feedables"):
		feedable.is_feedable = true
	
	await GameState.delay(0.5)
	await transition.fade_out()
	
	EventManager.finish_task(EventManager.task_ids.cut_cake)
	EventManager.add_task()
	EventManager.add_task()

func finished_feed_event() -> void:
	var tween := create_tween()
	tween.tween_property(birthday_music, "volume_db", -30.0, 1.5)
	
	EventManager.finish_task(EventManager.task_ids.feed_everyone)
	cake_event_sfx.stream = GameState.sfx["interact"]
	cake_event_sfx.play()
	GameState.delay(0.3)
	cake_slice.hide()
	cake_slice.is_grabable = false
	EventManager.end_event(EventManager.event_ids.cake_event)
	GameState.game_cursor_on = true
	
	await tween.finished
	birthday_music.stop()
