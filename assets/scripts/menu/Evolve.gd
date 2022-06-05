extends Control

onready var rotate_model = $Viewport/RotateModel

func _ready():
	rotate_model.settings = Global.player_settings
	rotate_model.update_settings()

func _on_skip_pressed():
	Global.move_zones()
