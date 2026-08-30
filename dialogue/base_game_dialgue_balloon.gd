class_name BaseGameDialogueBalloon extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

const VOWELS := ["a", "e", "i", "o", "u"]
const LETTERS := "abcdefghijklmnopqrstuvwxyz"

signal dialogue_ended

@export var text_blip_speed: float = 0.04
@export var text_blip_base_pitch: float = 1.0
@export var text_blip_vowel_bonus: float = 0.2
@export_range(1, 16, 1) var text_blip_pool_size: int = 8

@export var skip: bool = false
@export var hide_on_mutaion: bool = true

## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given title when using balloon as a [Node] in a scene.
@export var start_from_title: String = ""

## If running as a [Node] in a scene then auto start the dialogue.
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
@export var will_block_other_input: bool = true

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

## The button for advancing the dialogue
@onready var next_button: Button = %NextButton

## The Response Menu Container
@onready var response_container: Control = %ResponseContainer

## A sound player for dialogue text blips.
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}
var _text_blip_players: Array[AudioStreamPlayer] = []
var _next_text_blip_player_index: int = 0

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			GameState.can_move = true
			if not GameState.game_cursor_on:
				GameState.game_cursor_on = false
				GameState.hide_cursor()
			dialogue_ended.emit()
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

func _ready() -> void:
	balloon.hide()
	dialogue_label.seconds_per_step = text_blip_speed
	
	_setup_text_blip_players()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)
	
	next_button.pressed.connect(_on_next_button_pressed)
	dialogue_label.spoke.connect(_on_dialogue_label_spoke)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty() or skip:
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)
	

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()


func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		next_button.visible = (
			not dialogue_label.is_typing
			and dialogue_line.responses.size() == 0
			and not "input" in dialogue_line.tags
		)


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		dialogue_line = await dialogue_resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


func end_dialogue() -> void:
	if dialogue_label.dialogue_line != null and dialogue_label.is_typing:
		dialogue_label.skip_typing()
	_stop_text_blips()
	dialogue_line = null
	hide()

## Start some dialogue
func start(with_dialogue_resource: DialogueResource = null, title: String = "", extra_game_states: Array = []) -> void:
	GameState.game_cursor_on = true
	GameState.show_cursor()
	if will_block_other_input:
		GameState.can_move = false
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not title.is_empty():
		start_from_title = title
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_title, temporary_game_states)
	show()


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()
	_stop_text_blips()

	next_button.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	response_container.hide()
	responses_menu.responses = dialogue_line.responses
	#response_container.visible = dialogue_line.responses.size() > 0

	# Show our balloon
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing
	
	# Automatically continue if the line has #input
		if "input" in dialogue_line.tags:
			next(dialogue_line.next_id)
			return
	
	# Wait for next line
	if dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		response_container.show()
	elif dialogue_line.time != "":
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


## Go to the next line
func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)


func _setup_text_blip_players() -> void:
	_text_blip_players.clear()
	_text_blip_players.append(audio_stream_player)

	for i in range(1, text_blip_pool_size):
		var player := AudioStreamPlayer.new()
		player.name = "TextBlipPlayer%d" % i
		player.stream = audio_stream_player.stream
		player.bus = audio_stream_player.bus
		player.volume_db = audio_stream_player.volume_db
		player.pitch_scale = audio_stream_player.pitch_scale
		add_child(player)
		_text_blip_players.append(player)


func _stop_text_blips() -> void:
	for player in _text_blip_players:
		player.stop()


func _get_available_text_blip_player() -> AudioStreamPlayer:
	for offset in range(_text_blip_players.size()):
		var index := (_next_text_blip_player_index + offset) % _text_blip_players.size()
		var player := _text_blip_players[index]
		if not player.playing:
			_next_text_blip_player_index = (index + 1) % _text_blip_players.size()
			return player

	var player := _text_blip_players[_next_text_blip_player_index]
	_next_text_blip_player_index = (_next_text_blip_player_index + 1) % _text_blip_players.size()
	return player


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		if hide_on_mutaion:
			will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		var next_button_was_pressed: bool = skip and event.is_action_pressed(next_action)
		
		if mouse_was_clicked or skip_button_was_pressed or next_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)

func _on_next_button_pressed() -> void:
	if dialogue_label.is_typing:
		dialogue_label.skip_typing()
		return

	if not is_waiting_for_input:
		return

	if dialogue_line.responses.size() > 0:
		return

	next(dialogue_line.next_id)


func _on_dialogue_label_spoke(letter: String, _letter_index: int, _speed: float) -> void:
	var lower := letter.to_lower()
	if not LETTERS.contains(lower):
		return

	var player := _get_available_text_blip_player()
	player.pitch_scale = text_blip_base_pitch
	if VOWELS.has(lower):
		player.pitch_scale += text_blip_vowel_bonus
	player.play()

#endregion
