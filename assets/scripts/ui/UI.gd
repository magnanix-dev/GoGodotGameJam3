extends Control

export (PackedScene) var action

onready var action_bar = $ActionBar
onready var top_bar = $TopBar

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

func _show_ui():
	top_bar.visible = true
	action_bar.visible = true

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
