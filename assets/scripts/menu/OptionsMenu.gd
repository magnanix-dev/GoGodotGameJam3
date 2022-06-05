extends Control

signal back_pressed

onready var music_option = $Node2D/Title/VBoxContainer/ToggleMusic
onready var sfx_option = $Node2D/Title/VBoxContainer/ToggleSFX
onready var back_option = $Node2D/Title/VBoxContainer/Back

export var show_back = true

func _process(delta):
	if Global.play_music:
		music_option.text = "Music: ON"
	else:
		music_option.text = "Music: OFF"
	if Global.play_sound:
		sfx_option.text = "SFX: ON"
	else:
		sfx_option.text = "SFX: OFF"
	back_option.visible = show_back

func _on_music_pressed():
	Global.button_pressed()
	Global.toggle_music()
	
func _on_sfx_pressed():
	Global.button_pressed()
	Global.toggle_sound()

func _on_back_pressed():
	Global.button_pressed()
	emit_signal("back_pressed")
