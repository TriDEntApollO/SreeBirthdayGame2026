extends VBoxContainer

@export var bus_name: String

@onready var h_slider: HSlider = $HBoxContainer/HSlider
@onready var volume_label: Label = $HBoxContainer/PanelContainer/Volume
@onready var label: Label = $Label

var bus_index: int


func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	var volume = AudioServer.get_bus_volume_linear(bus_index)
	h_slider.value = volume
	volume_label.text = str(int(volume * 100))
	h_slider.value_changed.connect(_on_value_changed)
	label.text = bus_name + " Volume"
	

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(bus_index, value)
	volume_label.text = str(int(value * 100))
