extends CanvasLayer

@onready var game_dialogue_balloon: CanvasLayer = $GameDialogueBalloon
@onready var tasks_outline: Control = $TasksOutline
@onready var inventory_outline: Control = $InventoryOutline
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dialogue_path = "res://scenes/tutorial/tutorial.dialogue"
enum stages {
	action,
	down,
	left,
	right,
	up, 
	interact,
}


func _reset() -> void:
	hide()
	tasks_outline.hide()
	inventory_outline.hide()
	game_dialogue_balloon.hide()
	game_dialogue_balloon.end_dialogue()
	
func _ready() -> void:
	hide()
	tasks_outline.hide()
	inventory_outline.hide()
	EventManager.event_start.connect(_on_event_start)
	EventManager.event_end.connect(_on_event_end)
	
	#start_tutorial()


func start_tutorial():
	if not GameState.tutorial:
		queue_free()
		return

	show()
	game_dialogue_balloon.show()
	game_dialogue_balloon.start(load(dialogue_path), "start", [self])


func end_tutorial():
	_reset()
	GameState.tutorial = false
	GameState.game_cursor_on = false
	GameState.hide_cursor()


func wait_completion(stage: int):
	match stage:
		stages.action:
			while (not GameInputEvent.action()):
				await get_tree().process_frame
		stages.down:
			await _wait_for_movement(Vector2.DOWN)
		stages.left:
			await _wait_for_movement(Vector2.LEFT)
		stages.right:
			await _wait_for_movement(Vector2.RIGHT)
		stages.up:
			await _wait_for_movement(Vector2.UP)
		stages.interact:
			while (not GameInputEvent.interact()):
				await get_tree().process_frame
		


func _wait_for_movement(direction: Vector2, required_time: float = 0.3) -> void:
	var held_time := 0.0

	while held_time < required_time:
		var movement := GameInputEvent.movement_input()
		if movement.dot(direction) > 0:
			held_time += get_process_delta_time()
		else:
			held_time = 0.0

		await get_tree().process_frame


func _on_event_start(event_id: int) -> void:
	if event_id == EventManager.event_ids.start_day_event and GameState.tutorial:
		await GameState.delay(0.5)
		start_tutorial()
	
func _on_event_end(event_id: int) -> void:
	if event_id == EventManager.event_ids.start_day_event:
		end_tutorial()
