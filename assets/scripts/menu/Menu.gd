extends Control

func _on_play_pressed():
	get_tree().change_scene("res://assets/scenes/development/Testing.tscn")

func _on_options_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
