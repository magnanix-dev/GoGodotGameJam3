extends Node
#class_name Global

signal seed_changed
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
var exp_value = get_difficulty()
var exp_object = preload("res://assets/scenes/pickups/Experience.tscn")
var exp_container

var pending_evolutions = []

var game_over = false
var zone_settings = null
var zone = preload("res://assets/scenes/world/Zone.tscn")

var debug = false
var debug_seed = null
var _seed = null

var loader = null
var load_scene = null
var wait_frames = 1
var time_max = 100
var current_scene = null
var loading = preload("res://assets/scenes/ui/Loading.tscn")

func _ready():
	if(_seed == null):
		randomize_seed()

func clean():
	player = null
	player_health = 0
	player_health_max = 0
	player_health_set = false
	player_settings = null
	primary_evolutions = []
	secondary_evolutions = []
	tertiary_evolutions = []
	ui = null
	difficulty = 1
	exp_level = 1
	exp_current = 1.0
	exp_next = 50.0
	exp_base = 50.0
	exp_build = (8.0/10.0) # Alter this to feel good on zone completion
	exp_solve = (10.0/8.0) # Alter this to feel good on zone completion
	exp_value = get_difficulty()
	exp_container = null
	pending_evolutions = []
	game_over = false
	zone_settings = null
	
	loader = null
	load_scene = null
	wait_frames = 1
	time_max = 100
	current_scene = null
	
	randomize_seed()

func randomize_seed():
	if debug_seed != null:
		_seed = debug_seed
	else:
		randomize()
		_seed = randi() % 1000000
	seed(_seed)
	emit_signal("seed_changed", _seed)

func get_difficulty():
	return difficulty + floor(difficulty*1.0 / exp_level*1.0)

func set_player(object):
	player = object
	emit_signal("player_changed", player)

func set_player_settings(settings):
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
	return exp_value # potentially change this to something more complex

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

func evolve():
	if pending_evolutions.size() > 0:
		get_tree().change_scene("res://assets/scenes/menu/Evolve.tscn")
	else:
		move_zones()

func move_zones():
	if game_over:
		get_tree().change_scene("res://assets/scenes/menu/GameOver.tscn")
	else:
		if zone_settings:
			difficulty += 1
			exp_value = get_difficulty()
			get_tree().change_scene_to(zone)
