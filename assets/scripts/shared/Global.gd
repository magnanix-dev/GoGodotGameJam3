extends Node
#class_name Global

signal player_settings_changed
signal evolutions_changed
signal player_changed
signal health_changed
signal ui_changed
signal experience_changed
signal level_changed

var player = null
var player_health = 0
var player_health_max = 0
var player_health_set = false
var player_settings : Resource

var primary_evolutions = []
var secondary_evolutions = []
var tertiary_evolutions = []

var ui = null

var difficulty = 1

var exp_level : int = 1
var exp_current = 1.0
var exp_next = 50.0
var exp_base = 50.0
var exp_build = (8.0/10.0) # Alter this to feel good on zone completion
var exp_solve = (10.0/8.0) # Alter this to feel good on zone completion
var exp_object = preload("res://assets/scenes/pickups/Experience.tscn")
var exp_container

var pending_evolutions = []

var debug = false

func set_player(object):
	player = object
	emit_signal("player_changed", player)

func set_player_settings(settings):
	print("Set Player Settings...")
	player_settings = settings
	emit_signal("player_settings_changed", settings)

func set_ui(object):
	ui = object
	emit_signal("ui_changed", ui)

func set_health(amount):
	player_health = amount
	player_health_max = amount
	player_health_set = true
	emit_signal("health_changed", player_health, player_health_max)

func get_health():
	return player_health

func reduce_health(amount):
	player_health -= amount
	emit_signal("health_changed", player_health, player_health_max)

func increase_health(amount):
	player_health += amount
	if player_health > player_health_max:
		player_health = player_health_max
	emit_signal("health_changed", player_health, player_health_max)

func experience_value():
	return difficulty * 10.0 # potentially change this to something more complex

func get_exp_object():
	if get_tree().get_root().find_node("Experience_Container"):
		exp_container = get_tree().get_root().get_node("ExperienceContainer")
	else:
		var node = Node.new()
		node.name = "ExperienceContainer"
		get_tree().get_root().add_child(node)
		exp_container = node
	var instance = exp_object.instance()
	exp_container.add_child(instance)
	return instance
	
func check_level():
	var exp_total = pow(exp_level * exp_base, exp_build) + exp_current
	var level = floor( pow(exp_total, exp_solve) / exp_base )
	if level > exp_level:
		exp_level = level
		emit_signal("level_changed", exp_level)
		pending_evolutions.push_back(exp_level)
		var exp_stored = pow(exp_level * exp_base, exp_build)
		exp_current = exp_total - exp_stored
	exp_next = pow((exp_level + 1) * exp_base, exp_build)

func set_exp(amount):
	exp_current = amount
	check_level()
	emit_signal("experience_changed", exp_current, exp_next, exp_level)

func increase_exp(amount):
	exp_current += amount
	check_level()
	emit_signal("experience_changed", exp_current, exp_next, exp_level)

func reduce_exp(amount):
	exp_current -= amount
	emit_signal("experience_changed", exp_current, exp_next, exp_level)
