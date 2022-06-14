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
signal game_over_time

var _paused = false setget set_paused

var player = null
var player_speed_max = 0
var player_health = 0
var player_health_max = 0
var player_health_set = false
var player_settings : Resource

var primary_evolutions = null#Evolutions.new().evolutions
var secondary_evolutions = null#Evolutions.new().evolutions
var player_evolutions = null#Evolutions.new().evolutions

var ui = null

var difficulty = 1

var exp_level : int = 1
var exp_current = 1.0
var exp_next = 50.0
var exp_base = 50.0
var exp_build = (9.0/10.0) # Alter this to feel good on zone completion
var exp_solve = (10.0/9.0) # Alter this to feel good on zone completion
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

var music_player = []
var audio_players = []

var button_sfx = preload("res://assets/sounds/button.wav")

var zonetime = 0.0
var killcount = 0

var won = false

func _ready():
	if(_seed == null):
		randomize_seed()

func clean():
	player = null
	player_speed_max = 0
	player_health = 0
	player_health_max = 0
	player_health_set = false
	player_settings = null
	primary_evolutions = null#Evolutions.evolutions
	secondary_evolutions = null#Evolutions.evolutions
	player_evolutions = null#Evolutions.evolutions
	ui = null
	difficulty = 1
	exp_level = 1
	exp_current = 1.0
	exp_next = 50.0
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
	
	zonetime = 0.0
	killcount = 0
	won = false
	
	for n in music_player:
		if is_instance_valid(n):
			n.queue_free()
			
	for n in audio_players:
		if is_instance_valid(n):
			n.queue_free()
	
	music_player = []
	audio_players = []
	
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

func set_paused(val):
	if ui != null:
		_paused = val
		get_tree().paused = _paused
		ui.options_menu.visible = _paused

func set_master_volume(value):
	if value <= -38.00: value = -255.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	
func set_music_volume(value):
	if value <= -38.00: value = -255.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	
func set_sfx_volume(value):
	if value <= -38.00: value = -255.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)

func play_music(music, volume = -6.0):
	var play = null
	if music_player.size() < 1:
		play = AudioStreamPlayer.new()
		play.autoplay = true
		play.bus = "Music"
		play.pause_mode = Node.PAUSE_MODE_PROCESS
		get_tree().get_root().add_child(play)
		music_player.push_back(play)
	else:
		play = music_player.pop_front()
		music_player.push_back(play)
	play.volume_db = volume
	if play.stream == music and play.is_playing():
		pass
	else:
		play.stream = music
		play.play(true)

func play_sound(sfx, pitch_scale = 1.0, volume = -3.0):
	var play = null
	if audio_players.size() < 10:
		play = AudioStreamPlayer.new()
		play.autoplay = true
		play.bus = "SFX"
		play.pause_mode = Node.PAUSE_MODE_PROCESS
		get_tree().get_root().add_child(play)
		audio_players.push_back(play)
	else:
		play = audio_players.pop_front()
		audio_players.push_back(play)
	play.volume_db = volume
	play.pitch_scale = pitch_scale
	play.stream = sfx
	play.play(0.0)

func button_pressed():
	play_sound(button_sfx)

func set_player(object):
	player = object
	emit_signal("player_changed", player)

func set_player_settings(settings):
	player_settings = settings
	emit_signal("player_settings_changed", settings)

func set_ui(object):
	ui = object
	emit_signal("ui_changed", ui)

func increase_max_speed(amount):
	player_speed_max += amount

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

func increase_max_health(amount):
	player_health += amount
	player_health_max += amount
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

func get_total_exp():
	return pow(exp_level * exp_base, exp_build) + exp_current

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

func apply_evolution(type, key, evolution):
	var e = Evolutions.evolutions[key]
	match type:
		"primary":
			if primary_evolutions == null:
				primary_evolutions = Evolutions.evolutions.duplicate()
			if not primary_evolutions[key].active:
				primary_evolutions[key].active = true
			if e.has("increment"):
				for i in e.increment:
					var inc = e.increment[i]
					primary_evolutions[key][i] += inc
		"secondary":
			if secondary_evolutions == null:
				secondary_evolutions = Evolutions.evolutions.duplicate()
			if not secondary_evolutions[key].active:
				secondary_evolutions[key].active = true
			if e.has("increment"):
				for i in e.increment:
					var inc = e.increment[i]
					secondary_evolutions[key][i] += inc
		"player":
			match key:
				"hefty":
					increase_max_health(e.increment.count)
				"slim":
					increase_max_speed(e.increment.count)

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

func game_over():
	emit_signal("game_over_time")
	Global.game_over = true
	print("Game Over!")
	yield(ui.fade_out(), "completed")
	get_tree().change_scene("res://assets/scenes/menu/GameOver.tscn")
