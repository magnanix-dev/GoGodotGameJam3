extends Control

onready var animation = $Node2D/Title/Control/AnimationPlayer

func _input(event):
	if event.is_action_pressed("primary"):
		var end = animation.current_animation_length
		animation.seek(end)

func _on_play_pressed():
	get_tree().change_scene("res://assets/scenes/menu/Select.tscn")

func _on_options_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
