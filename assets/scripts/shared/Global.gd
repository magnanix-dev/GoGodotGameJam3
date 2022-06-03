extends Node
#class_name Global

signal player_settings_changed
signal evolutions_changed
signal player_changed
signal health_changed

var player = null
var player_health = 0
var player_health_max = 0
var player_health_set = false

var player_settings : Resource

var primary_evolutions = []
var secondary_evolutions = []
var tertiary_evolutions = []

var debug = false

func set_player(object):
	player = object
	emit_signal("player_changed", player)

func set_player_settings(settings):
	print("Set Player Settings...")
	player_settings = settings
	emit_signal("player_settings_changed", settings)

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
