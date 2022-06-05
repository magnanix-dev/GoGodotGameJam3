extends Control

signal evolution_selected(setting)

export (PackedScene) var select
export (Array, bool) var option_status
export (Array, Resource) var options

export (Resource) var zone_settings

onready var row = $Row

func _ready():
	var i = 0
	for option in options:
		var s = select.instance()
		s.evolution = option
		s.disabled = !option_status[i]
		s.type = "primary"
		if randf() <= 0.5:
			s.type = "secondary"
		s.connect("pressed", self, "_on_option_pressed", [s.type, s.evolution])
		var col = VBoxContainer.new()
		col.alignment = BoxContainer.ALIGN_CENTER
		col.add_child(s)
		row.add_child(col)
		i += 1

func _on_option_pressed(type, evolution):
	match type:
		"primary":
			Global.primary_evolutions.append(evolution)
		"secondary":
			Global.secondary_evolutions.append(evolution)
	Global.move_zones()
