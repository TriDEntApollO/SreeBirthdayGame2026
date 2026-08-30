extends Node2D

@onready var markers: Node2D = $Markers
@onready var living_room: Node2D = $LivingRoom


func _ready() -> void:
	for marker in markers.get_children():
		if marker is Marker2D:
			GameState.register_marker(marker.name, marker)
