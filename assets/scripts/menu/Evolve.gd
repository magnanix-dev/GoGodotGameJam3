extends Control

onready var rotate_model = $Viewport/RotateModel
onready var title_label = $Node2D/Label

func _ready():
	rotate_model.settings = Global.player_settings
	rotate_model.update_settings()
	title_label.text = "Select Evolution\n" + str(Global.pending_evolutions.size())
	Global.pending_evolutions.pop_front()

func _on_skip_pressed():
	Global.button_pressed()
	Global.evolve()
