extends VBoxContainer

onready var tween = $Tween
onready var icon = $Shadow/BG/Action
onready var bg = $Shadow/BG
onready var flash = $Shadow/BG/Flash

var action_name = ""
var action_icon = null
var cooldown = 0.0
var flash_time = 0.25

func initialize():
	if action_icon != null: icon.set_texture(action_icon)
	bg.self_modulate = Color(0.5, 0.75, 0.125, 1.0)

func _on_ability_pressed():
	tween.interpolate_property(self, "rect_scale", Vector2(1, 1), Vector2(0.75, 0.75), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_ability_released():
	tween.interpolate_property(self, "rect_scale", Vector2(0.75, 0.75), Vector2(1, 1), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_cooldown_start():
	bg.self_modulate = Color(0.75, 0.125, 0.0625, 1.0)
	tween.interpolate_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.13), Color(1.0, 1.0, 1.0, 1.0), cooldown, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property(flash, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), flash_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	bg.self_modulate = Color(0.5, 0.75, 0.125, 1.0)
