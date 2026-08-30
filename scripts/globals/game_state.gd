#class_name GameState
extends Node

const CURSOR_PATH := "res://assets/ui/hand_pointer.png"
const CURSOR_SCALE := 2.0
const CURSOR_HOTSPOT := Vector2(11, 6)

const MAIN_SCENE = preload("res://scenes/main_scene.tscn")
const START_MENU_SCENE = preload("res://scenes/start_menu.tscn")


# Sree (Player) Reference
var sree: Sree

# Audio SFX resources
const sfx := {
	"menu_open": preload("res://assets/SFX/menu_open.ogg"),
	"menu_close": preload("res://assets/SFX/menu_close.ogg"),
	"alarm": preload("res://assets/SFX/alarm_clock_old.ogg"),
	"brush_teeth": preload("res://assets/SFX/brush-teeth.ogg"),
	"light_match": preload("res://assets/SFX/match-lighting.ogg"),
	"blow_candle": preload("res://assets/SFX/candle-blowing.ogg"),
	"confetti": preload("res://assets/SFX/confetti-pop.ogg"),
	"clapping": preload("res://assets/SFX/hand-clapping.ogg"),
	"munch": preload("res://assets/SFX/munch.ogg"),
	"interact": preload("res://assets/SFX/interact.ogg"),
	"recieved": preload("res://assets/SFX/recieved.ogg"),
	"collected": preload("res://assets/SFX/collected.ogg"),
	"plate_clink": preload("res://assets/SFX/plate-clink.ogg"),
	"fridge_door": preload("res://assets/SFX/fridge-door.ogg"),
	"card_open": preload("res://assets/SFX/card_open.ogg"),
	"mouse_click": preload("res://assets/SFX/mouse_click.ogg"),
	"hover": preload("res://assets/SFX/hover.ogg"),
	"task_create": preload("res://assets/SFX/task_create.ogg"),
	"task_finish": preload("res://assets/SFX/task_finish.ogg"),
}

const video := {
	"happy_birthday_duck": preload("res://assets/videos/happy_birthday_duck.ogv"),
	"birthday_edit": preload("res://assets/videos/birthday_edit.ogv"),
}

const music := {
	"in_game_music": preload("res://assets/music/in_game_music.ogg"),
	"start_menu": preload("res://assets/music/start_menu.ogg"),
	"pause_menu": preload("res://assets/music/pause_menu.ogg"),
}


# Persistent settings.
# IMPORTANT: reset() must NOT modify this.
var tutorial: bool = true
var start_menu_active = false

# Runtime state
var map_positions: Dictionary = {}
var can_move: bool = false
var collectables_count: int = 0
var game_cursor_on: bool = false

func reset() -> void:
	# Reset runtime game state.
	sree = null
	map_positions.clear()
	can_move = false
	collectables_count = 0
	game_cursor_on = false

	# EventManager owns its own runtime state.
	EventManager.reset()
	# UI reset
	Ui.reset()


func _ready() -> void:
	var image: Image = load(CURSOR_PATH).get_image()

	image.resize(
		int(image.get_width() * CURSOR_SCALE),
		int(image.get_height() * CURSOR_SCALE),
		Image.INTERPOLATE_NEAREST
	)

	var texture := ImageTexture.create_from_image(image)

	Input.set_custom_mouse_cursor(
		texture,
		Input.CURSOR_ARROW,
		CURSOR_HOTSPOT * CURSOR_SCALE
	)
	
	sree = null
	map_positions.clear()
	can_move = false
	collectables_count = 0
	game_cursor_on = false

func start_game() -> void:
	await Ui.ui_transition_in()
	reset()
	start_menu_active = false
	get_tree().change_scene_to_packed(MAIN_SCENE)
	get_tree().paused = false
	await Ui.ui_transition_out()

func quit_to_start_menu() -> void:
	reset()
	await Ui.ui_transition_in()
	start_menu_active = true
	get_tree().change_scene_to_packed(START_MENU_SCENE)
	get_tree().paused = false
	await Ui.ui_transition_out()

func exit_game() -> void:
	get_tree().quit()

func delay(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func register_marker(id: String, marker: Marker2D) -> void:
	map_positions[id] = marker.global_position


func get_position(id: String) -> Variant:
	return map_positions.get(id)


func hide_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func show_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_viewport().warp_mouse(get_viewport().get_visible_rect().size / 2.0)


func add_collectable():
	collectables_count += 1
	Ui.found_collectable()
