extends Control

var current_hp = 0
var max_hp = 0

onready var bar = $Bar
onready var current_label = $HealthLabel/CurrentHealth
onready var max_label = $HealthLabel/MaxHealth
onready var tween = $Tween

func _ready():
	Global.connect("health_changed", self, "_update_health")
	_update_health(Global.player_health, Global.player_health_max)

func _update_health(_current, _max):
	tween.interpolate_property(bar, "max_value", max_hp, _max, 0.5)
	tween.start()
	tween.interpolate_property(bar, "value", current_hp, _current, 0.5)
	tween.start()
	current_hp = _current
	max_hp = _max
	current_label.text = str(current_hp)
	max_label.text = str(max_hp)
