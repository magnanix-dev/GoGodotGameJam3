extends HSlider

export var bus_name = "Master"

func _ready():
	value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))
