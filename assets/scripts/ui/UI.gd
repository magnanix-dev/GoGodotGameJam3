extends Control

export (PackedScene) var action

onready var action_bar = $ActionBar
onready var top_bar = $TopBar
onready var zone_name = $ZoneName
onready var fade = $FadeOut
onready var tween = $Tween
onready var options_menu = $OptionsMenu

var abilities = []

func _ready():
	top_bar.visible = false
	action_bar.visible = false
	Global.set_ui(self)
	yield(get_tree().create_timer(1.0), "timeout")
	if Global.player:
		_show_ui()
	else:
		Global.connect("player_changed", self, "_show_ui")
	options_menu.show_back = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Global._paused = !Global._paused
		#options_menu.visible = !options_menu.visible

func show_zone_name():
	zone_name.text = Global.zone_settings.name
	tween.interpolate_property(zone_name, "self_modulate", Color(1,1,1,0.0), Color(1,1,1,1.0), 0.25)
	tween.start()
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(2.0), "timeout")
	tween.interpolate_property(zone_name, "self_modulate", Color(1,1,1,1.0), Color(1,1,1,0.0), 0.125)
	tween.start()

func _show_ui():
	top_bar.visible = true
	action_bar.visible = true

func fade_out():
	fade.visible = true
	tween.interpolate_property(fade, "modulate", Color(0,0,0,0), Color(0,0,0,1.0), 2.0)
	tween.start()
	yield(tween, "tween_completed")

func add_ability(action_name, icon, cooldown, user):
	var removal = []
	for a in abilities:
		if a.action_name == action_name:
			a.queue_free()
			removal.append(a)
	for r in removal:
		abilities.erase(r)
	var new = action.instance()
	new.action_name = action_name
	new.action_icon = icon
	new.cooldown = cooldown
	action_bar.add_child(new)
	new.initialize()
	user.connect("cooldown", new, "_on_cooldown_start")
	user.connect("ability_pressed", new, "_on_ability_pressed")
	user.connect("ability_released", new, "_on_ability_released")
	abilities.append(new)
