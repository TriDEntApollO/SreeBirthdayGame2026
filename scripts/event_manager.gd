extends Node

@warning_ignore("unused_signal")
signal alarm_tick
@warning_ignore("unused_signal")
signal tutorial_finished

signal task_updated
signal event_start
signal event_end

class TaskData:
	var name: String
	var instance: Task
	var finished: bool = false

	func _init(task_name: String) -> void:
		name = task_name
		
class EventData:
	var started: bool = false
	var ended: bool = false

	func _init() -> void:
		pass


enum task_ids {
	stop_alarm,
	brush_teeth,
	talk_to_omma_and_appa,
	go_to_dining,
	start_cake_event,
	blow_candles,
	pick_up_knife,
	cut_cake,
	pick_up_cake_slice,
	feed_everyone,
	talk_to_omma,
	talk_to_appa,
	take_cake,
	put_cake_in_fridge,
	put_plate_in_sink,
	talk_to_omma_2,
	talk_to_porkpaglu,
	talk_to_upasana,
	talk_to_ramenpaglu
}

enum event_ids {
	wake_up_event,
	start_day_event,
	cat_given_event,
	pre_dining_event,
	dining_event,
	cake_event,
	ending_event,
}

var next_task_id: int
var task_data: Dictionary[int, TaskData]

var next_event_id: int
var events_state: Dictionary[int, EventData]

func reset() -> void:
	# Reset task state
	next_task_id = 0

	task_data = {
		task_ids.stop_alarm: TaskData.new("Stop the alarm"),
		task_ids.brush_teeth: TaskData.new("Brush your teeth"),
		task_ids.talk_to_omma_and_appa: TaskData.new("Talk with Omma and Appa"),
		task_ids.go_to_dining: TaskData.new("Go to the dining room"),
		task_ids.start_cake_event: TaskData.new("Join others at the table"),
		task_ids.blow_candles: TaskData.new("Blow out canldes"),
		task_ids.pick_up_knife: TaskData.new("Pick up the knife"),
		task_ids.cut_cake: TaskData.new("Cut the cake with the knife"),
		task_ids.pick_up_cake_slice: TaskData.new("Pick up the cake slice"),
		task_ids.feed_everyone: TaskData.new("Feed cake to everyone"),
		task_ids.talk_to_omma: TaskData.new("Talk with Omma"),
		task_ids.talk_to_appa: TaskData.new("Talk with Appa"),
		task_ids.take_cake: TaskData.new("Take the cake from the table"),
		task_ids.put_cake_in_fridge: TaskData.new("Put the cake in the fridge"),
		task_ids.put_plate_in_sink: TaskData.new("Put the plate in the kitchen sink"),
		task_ids.talk_to_omma_2: TaskData.new("Talk with Omma"),
		task_ids.talk_to_porkpaglu: TaskData.new("Talk with PorkPaglu"),
		task_ids.talk_to_upasana: TaskData.new("Talk with Upasana"),
		task_ids.talk_to_ramenpaglu: TaskData.new("Talk with RamenPaglu")
	}

	# Reset event state
	next_event_id = 0

	events_state.clear()

	for event_id in event_ids.values():
		events_state[event_id] = EventData.new()

func _ready() -> void:
	reset()

func add_task() -> void:
	#print("Added Task: ", task_data[next_task_id].name)
	var data := task_data[next_task_id]

	data.instance = await Ui.add_task(data.name)
	data.finished = false

	task_updated.emit(next_task_id)
	next_task_id += 1

func finish_task(task_id: int) -> void:
	var data := task_data[task_id]

	data.finished = true

	if is_instance_valid(data.instance):
		await data.instance.end_task()
	
	if (
		task_data[task_ids.talk_to_porkpaglu].finished and 
		task_data[task_ids.talk_to_upasana].finished and 
		not task_data[task_ids.talk_to_ramenpaglu].finished
	):
		add_task()
	

func is_task_finished(task_id: int) -> bool:
	return task_data[task_id].finished


func start_event() -> void:
	#print("Started Event: ", event_ids.keys()[next_event_id])
	if next_event_id > 0 and not has_event_ended(next_event_id - 1):
		end_event(next_event_id - 1)
	
	event_start.emit(next_event_id)
	events_state[next_event_id].started = true
	next_event_id += 1

func end_event(event_id: int) -> void:
	#print("Ended Event: ", event_ids.keys()[event_id])
	events_state[event_id].ended = true
	event_end.emit(event_id)

func has_event_started(event_id) -> bool:
	return events_state[event_id].started
	
func has_event_ended(event_id) -> bool:
	return events_state[event_id].ended
