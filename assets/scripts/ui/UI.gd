extends Control

export (PackedScene) var action

onready var action_bar = $ActionBar

var abilities = []

func _ready():
	Global.set_ui(self)

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
