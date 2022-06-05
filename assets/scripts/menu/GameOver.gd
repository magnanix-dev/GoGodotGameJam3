extends Control

onready var rotate_model = $Viewport/RotateModel
onready var won = $Node2D/Won
onready var lost = $Node2D/Lose
onready var stats = $Node2D/Stats

func _ready():
	rotate_model.settings = Global.player_settings
	rotate_model.update_settings()
	if Global.won:
		lost.visible = false
		won.visible = true
	else:
		lost.visible = true
		won.visible = false
	stats.text = "Time Elapsed: " + str(Global.zonetime) + " secs\nTotal Kills: " + str(Global.killcount) + "\nFinal EXP: " + str(floor(Global.get_total_exp())) + " (level " + str(Global.exp_level) + ")\n\nSeed: " + str(Global._seed)

func _on_play_pressed():
	Global.button_pressed()
	get_tree().change_scene("res://assets/scenes/menu/Menu.tscn")
