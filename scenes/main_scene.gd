extends Node2D

@onready var sree: Sree = $HouseScene/Charcters/Sree
@onready var house_scene: Node2D = $HouseScene
@onready var living_room: Node2D = $HouseScene/MainMap.living_room
@onready var transition: ColorRect = Ui.transition

# Characters
@onready var omma: Node2D = $HouseScene/Charcters/Omma
@onready var appa: Node2D = $HouseScene/Charcters/Appa
@onready var porkpaglu: Node2D = $HouseScene/Charcters/Porkpaglu
@onready var ramenpaglu: Node2D = $HouseScene/Charcters/Ramenpaglu
@onready var upasana: Node2D = $HouseScene/Charcters/Upasana

@onready var omma_and_appa: Node2D = $HouseScene/Charcters/OmmaAndAppa

var npcs: Array

var cake_scene_instance: CakeScene
var cake_event_scene = preload("res://scenes/map/CakeEvent.tscn")


func _ready() -> void:
	sree.hide()
	sree.set_interact(false)
	GameState.can_move = false
	GameState.hide_cursor()
	npcs = [omma, appa, porkpaglu, ramenpaglu, upasana]
	omma_and_appa.set_outline(omma.animated_sprite_2d)
	omma_and_appa.set_outline(appa.animated_sprite_2d)
	
	for npc in npcs:
		living_room.cake_event_interactable.add_outline(npc.animated_sprite_2d)
	living_room.cake_event_interactable.add_outline(living_room.dining_table)
	
	EventManager.event_start.connect(_on_event_start)
	EventManager.event_end.connect(_on_event_end)
	Ui.play_music("in_game_music")
	
	# Start alarm Delayed
	await GameState.delay(1)
	EventManager.start_event()
	Ui.action_component.set_action("Wake Up", wake_up)


func wake_up() -> void:
	await transition.fade_in()
	
	sree.global_position = GameState.get_position("BedSree")
	sree.show()
	EventManager.end_event(EventManager.event_ids.wake_up_event)
	
	await transition.fade_out()
	
	Ui.inventory.show()
	sree.set_interact(true)
	GameState.can_move = true
	await EventManager.add_task()
	EventManager.start_event()


func start_cake_event() -> void:
	GameState.can_move = false
	sree.set_interact(false)
	cake_scene_instance = cake_event_scene.instantiate()
	await Ui.transition.fade_in()
	
	Ui.pause_music(true)
	#GameState.show_cursor()
	sree.camera.enabled = false
	Ui.play_sfx("light_match")
	house_scene.hide()
	house_scene.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(cake_scene_instance)
	cake_scene_instance.camera.enabled = true
	
	await Ui.transition.fade_out()
	
func end_cake_event() -> void:
	await Ui.transition.fade_in()
	
	Ui.pause_music(false)
	sree.camera.enabled = true
	cake_scene_instance.camera.enabled = false
	house_scene.show()
	house_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	cake_scene_instance.queue_free()
	sree.global_position = GameState.get_position("TableSree")
	await Ui.transition.fade_out()
	
	GameState.can_move = true
	GameState.hide_cursor()
	sree.set_interact(true)
	
	
	await EventManager.add_task()
	await EventManager.add_task()
	

func _on_event_start(event_id: int) -> void:
	if event_id == EventManager.event_ids.cake_event:
		start_cake_event()

func _on_event_end(event_id: int) -> void:
	if event_id == EventManager.event_ids.cake_event:
		end_cake_event()
	if event_id == EventManager.event_ids.ending_event:
		GameState.quit_to_start_menu()
