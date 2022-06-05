extends Control

var current_rate = 1.0
var under_rate = 20.0
var over_rate = 5.0

var current_xp = 1.0
var target_xp = 0.0
var next_xp = 0.0

var post_target_xp = 0.0
var post_next_xp = 0.0

var current_level = 1

var level_ups = []

onready var bar = $Container/Fix/Bar
onready var current_label = $Container/Control/CurrentLevel
onready var tween = $Tween

func _ready():
	Global.connect("experience_changed", self, "_update_experience")
	Global.connect("level_changed", self, "_update_level")
	_update_experience(Global.exp_current, Global.exp_next, Global.exp_level)
	_update_level(Global.exp_level)

func _process(delta):
	if level_ups.size() > 0:
		current_rate = under_rate * current_level
		target_xp = next_xp
		if current_xp >= target_xp:
			var level = level_ups.pop_front()
			current_xp = 0
			current_level = level
	else:
		current_rate = over_rate * current_level
		if post_target_xp > 0.0:
			target_xp = post_target_xp
			post_target_xp = 0.0
		if post_next_xp > 0.0:
			next_xp = post_next_xp
			post_next_xp = 0.0
	if current_xp <= target_xp:
		current_xp = clamp(current_xp + (delta * current_rate), 0.0, target_xp)
	bar.max_value = next_xp
	bar.value = current_xp
	current_label.text = str(floor(current_level))

func _update_experience(_current, _next, _level):
	if _level > current_level:
		post_target_xp = _current
		post_next_xp = _next
	else:
		target_xp = _current
		next_xp = _next

func _update_level(_level):
	if _level > current_level:
		level_ups.push_back(_level)
