extends Control

signal back_pressed

onready var back_option = $Node2D/Title/Vertical/GoBack/Back

export var show_back = true

func _process(delta):
	back_option.visible = show_back

func _on_back_pressed():
	Global.button_pressed()
	emit_signal("back_pressed")

func _on_master_volume_changed(value):
	Global.set_master_volume(value)

func _on_music_volume_changed(value):
	Global.set_music_volume(value)

func _on_sfx_volume_changed(value):
	Global.set_sfx_volume(value)
