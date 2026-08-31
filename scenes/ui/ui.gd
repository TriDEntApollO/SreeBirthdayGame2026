extends CanvasLayer

@onready var in_game: CanvasLayer = $InGame
@onready var pause_menu: CanvasLayer = $InGame/PauseMenu
@onready var action_component: ActionComponent = $InGame/ActionComponent
@onready var task_list: VBoxContainer = $InGame/TaskContainer/MarginContainer/TaskList
@onready var game_music_player: AudioStreamPlayer2D = $InGame/GameMusicPlayer
@onready var game_sfx_player: AudioStreamPlayer2D = $InGame/GameSfxPlayer
@onready var dialogue_balloon: CanvasLayer = $InGame/GameDialogueBalloon
@onready var gift_box: GiftBoxPopUp = $InGame/GiftBoxPopUp
@onready var collectable_found: CanvasLayer = $InGame/CollectableFound
@onready var video_player: VideoPlayer = $InGame/VideoPlayer
@onready var tutorial: CanvasLayer = $InGame/Tutorial
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#invetory
@onready var inventory: MarginContainer = $InGame/Inventory
@onready var cake_inventory: PanelContainer = $InGame/Inventory/HBoxContainer/Cake
@onready var cake: TextureRect = $InGame/Inventory/HBoxContainer/Cake/MarginContainer/Cake
@onready var plate: TextureRect = $InGame/Inventory/HBoxContainer/Cake/MarginContainer/Plate
@onready var collectables_count: Label = $InGame/Inventory/HBoxContainer/Collectables/MarginContainer/Count
@onready var birthday_card: CanvasLayer = $InGame/BirthdayCard
@onready var perfume: PanelContainer = $InGame/Inventory/HBoxContainer/Perfume
@onready var makeup: PanelContainer = $InGame/Inventory/HBoxContainer/Makeup


@onready var ui_sfx: AudioStreamPlayer2D = $UiSfx

var pause_state = false

var transition: ColorRect
var task = preload("res://scenes/ui/task.tscn")


func reset() -> void:
	pause_state = false

	# UI visibility/state
	inventory.hide()
	cake_inventory.hide()
	makeup.hide()
	perfume.hide()
	dialogue_balloon.hide()
	birthday_card.hide()
	gift_box._reset()
	collectable_found._reset()
	video_player._reset()
	birthday_card._reset()
	dialogue_balloon.end_dialogue()
	#if is_instance_valid(tutorial):
	tutorial._reset()
	

	collectables_count.text = "0"
	inventory_show_cake(false)
	inventory_show_plate(false)

	# Remove tasks
	for child in task_list.get_children():
		child.queue_free()

	# Stop UI media
	ui_sfx.stop()
	game_sfx_player.stop()
	game_music_player.stop()
	video_player._close_player()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	transition = $Transition
	reset()


func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			play_ui_sfx("mouse_click")


func _process(_delta: float) -> void:
	if GameState.start_menu_active:
		return
	#if GameState.window_unfocused:
		#ui_sfx.stream_paused = true
		#return
	#ui_sfx.stream_paused = false
	
	if GameInputEvent.cancel():
		if not pause_state:
			_pause()
		else:
			_unpause()

func _set_focus_audio_paused(paused: bool) -> void:
	ui_sfx.stream_paused = paused
	pause_menu.set_focus_audio_paused(paused)

func _pause() -> void:
	game_sfx_player.stream_paused = true
	pause_state = true
	pause_menu.pause()

func _unpause() -> void:
	await pause_menu.unpause()
	pause_state = false
	game_sfx_player.stream_paused = false


func play_ui_sfx(sfx_name: String) -> void:
	ui_sfx.stream = GameState.sfx[sfx_name]
	ui_sfx.play()

func give_card() -> void:
	await birthday_card.show_card()


func found_collectable() -> void:
	collectables_count.text = str(GameState.collectables_count)


func inventory_show_cake(_show: bool) -> void:
	if _show:
		cake_inventory.show()
		cake.show()
	else:
		cake.hide()


func invetory_show_makeup() -> void:
	makeup.show()


func invetory_show_perfume() -> void:
	perfume.show()

func inventory_show_plate(_show: bool) -> void:
	if _show:
		plate.show()
	else:
		cake_inventory.hide()
		plate.hide()
	

func play_sfx(sfx_name: String) -> void:
	if not GameState.sfx.has(sfx_name):
		push_warning("SFX not found: " + sfx_name)
		return

	var stream: AudioStream = GameState.sfx[sfx_name]
	game_sfx_player.stream = stream
	game_sfx_player.play()
	await game_sfx_player.finished


func stop_sfx():
	game_sfx_player.stop()


func play_music(music_name: String):
	game_music_player.stream = GameState.music[music_name]
	game_music_player.play()


func stop_music():
	game_music_player.stop()


func pause_music(enabled: bool):
	game_music_player.stream_paused = enabled


func add_task(task_name: String) -> Task:
	var new_task: Task = task.instantiate()
	new_task.task_name = task_name
	task_list.add_child(new_task)
	await new_task.start_task()
	
	return new_task


func ui_transition_in() -> void:
	animation_player.play("UiTransitionIn")
	await animation_player.animation_finished

func ui_transition_out() -> void:
	animation_player.play("UiTransitionOut")
	await animation_player.animation_finished
	animation_player.play("RESET")
