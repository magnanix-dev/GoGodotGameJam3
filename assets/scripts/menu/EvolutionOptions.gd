extends Control

signal evolution_selected(setting)

export (PackedScene) var select
export (Resource) var zone_settings

var types = ["primary", "primary", "primary", "secondary", "secondary", "secondary", "player"]
onready var row = $Row

func _ready():
	var options = []
	types.shuffle()
	options.append([types[0], Evolutions.get_random_evolution(types.pop_front())])
	options.append([types[0], Evolutions.get_random_evolution(types.pop_front())])
	options.append([types[0], Evolutions.get_random_evolution(types.pop_front())])
	var i = 0
	for option in options:
		var s = select.instance()
		s.evolution = option[1][1]
		s.type = option[0]
		var col = VBoxContainer.new()
		col.alignment = BoxContainer.ALIGN_CENTER
		col.add_child(s)
		row.add_child(col)
		s.initialize()
		s.connect("pressed", self, "_on_option_pressed", [s.type, option[1][0], s.evolution])
		i += 1

func _on_option_pressed(type, key, evolution):
	Global.button_pressed()
	Global.apply_evolution(type, key, evolution)
	Global.evolve()
