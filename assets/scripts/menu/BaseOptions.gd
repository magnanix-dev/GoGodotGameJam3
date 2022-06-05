extends Control

export (PackedScene) var select
export (Array, bool) var option_status
export (Array, Resource) var options

onready var row = $Row

func _ready():
	Global.connect("player_settings_changed", self, "_on_player_settings_changed")
	var i = 0
	for option in options:
		var s = select.instance()
		s.settings = option
		s.disabled = !option_status[i]
		s.connect("pressed", self, "_on_option_pressed", [s.settings])
		var col = VBoxContainer.new()
		col.alignment = BoxContainer.ALIGN_CENTER
		col.add_child(s)
		row.add_child(col)
		i += 1

func _on_option_pressed(settings):
	Global.button_pressed()
	Global.set_player_settings(settings)

func _on_player_settings_changed(_settings):
	Global.move_zones()
#	get_tree().change_scene("res://assets/scenes/development/Testing.tscn")
