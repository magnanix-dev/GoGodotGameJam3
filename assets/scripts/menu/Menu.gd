extends Control

onready var animation = $Node2D/Title/Control/AnimationPlayer
onready var main_menu = $Node2D
onready var options_menu = $OptionsMenu

export (Resource) var menu_music
export (Resource) var starting_zone

func _ready():
	Global.clean()
	Global.zone_settings = starting_zone
	options_menu.connect("back_pressed", self, "_hide_options")
	yield(get_tree().create_timer(0.1), "timeout")
	Global.play_music(menu_music)

func _input(event):
	if event.is_action_pressed("primary"):
		var end = animation.current_animation_length
		animation.seek(end)

func _on_play_pressed():
	Global.button_pressed()
	get_tree().change_scene("res://assets/scenes/menu/Select.tscn")

func _on_options_pressed():
	Global.button_pressed()
	main_menu.visible = false
	options_menu.visible = true

func _hide_options():
	main_menu.visible = true
	options_menu.visible = false

func _on_quit_pressed():
	Global.button_pressed()
	get_tree().quit()
