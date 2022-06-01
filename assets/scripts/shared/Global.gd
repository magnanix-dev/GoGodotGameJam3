extends Node
#class_name Global

signal player_changed

var player = null

func set_player(object):
	player = object
	emit_signal("player_changed", player)
