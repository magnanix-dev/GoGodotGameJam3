extends Control

onready var rotate_model = $Viewport/RotateModel

func _ready():
	rotate_model.settings = Global.player_settings
	rotate_model.update_settings()

func _on_play_pressed():
	#Global.randomize_seed()
	get_tree().change_scene("res://assets/scenes/menu/Menu.tscn")
