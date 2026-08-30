extends Node2D

@onready var sree: Sree = $".."
@onready var interact_prompt: Node2D = $InteractPrompt
@onready var interact_label: Label = $InteractPrompt/PanelContainer/MarginContainer/HBoxContainer/Label
@onready var panel_container: PanelContainer = $InteractPrompt/PanelContainer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


var active_prompt: Node2D = null
var focused_interaction = null
var current_interactions := []
var can_interact: bool = true

func _ready() -> void:
	interact_prompt.hide()

func _sort_by_nearest(area1, area2):
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

func _show_prompt(interaction: Interactable) -> void:
	if interaction.prompt:
		interact_prompt.hide()
		active_prompt = interaction.prompt
		active_prompt.show()
	else:
		active_prompt = interact_prompt
		active_prompt.show()


func _hide_prompt() -> void:
	if active_prompt:
		active_prompt.hide()

	active_prompt = null


func _process(_delta: float) -> void:
	# Interact with the currently focused interaction.
	if GameInputEvent.interact() and can_interact and focused_interaction:
		can_interact = false

		var interaction: Interactable = focused_interaction
		interact_prompt.hide()
		interaction.unfocus()
		focused_interaction = null
		sree.turn_towards(interaction.global_position)
		audio_stream_player_2d.play()

		await interaction.interact()

		#if is_instance_valid(interaction) and interaction.is_interactable:
			#interaction.focus()
		can_interact = true

	if not can_interact:
		return

	# Only consider interactions that are currently enabled.
	var available_interactions: Array[Interactable] = []

	for interaction: Interactable in current_interactions:
		if not interaction.is_interactable:
			continue

		if interaction.collectable:
			if not _can_collect(interaction):
				continue

		available_interactions.append(interaction)

	# Nothing usable is in range.
	if available_interactions.is_empty():
		if focused_interaction:
			focused_interaction.unfocus()
			focused_interaction = null

		_hide_prompt()
		return

	# Nearest interaction first.
	available_interactions.sort_custom(_sort_by_nearest)

	var new_focus: Interactable = available_interactions[0]

	# Change focus only when necessary.
	if focused_interaction != new_focus:
		if focused_interaction:
			focused_interaction.unfocus()

		focused_interaction = new_focus
		focused_interaction.focus()

	interact_label.text = "to " + new_focus.interactable_name
	panel_container.reset_size()
	panel_container.position = -panel_container.size / 2.0
	_show_prompt(new_focus)


func _can_collect(interaction: Interactable) -> bool:
	if global_position.distance_squared_to(interaction.global_position) > 500.0:
		return false

	return sree.is_facing_position(interaction.global_position)

func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)


func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
	if area == focused_interaction:
		focused_interaction.unfocus()
		focused_interaction = null
