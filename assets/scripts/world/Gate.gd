extends Spatial

signal player_entered(object)

onready var mesh = $Mesh
onready var animations = $Mesh/AnimationPlayer
onready var zone = $Mesh/Zone
onready var target_point = $TargetPoint

var open = false

func initialize():
	zone.connect("body_entered", self, "_on_body_enter")
	#zone.connect("area_entered", self, "_on_area_enter")

func open():
	open = true
	animations.play("Open")
	check_collisions()

func close():
	open = false
	animations.play("Closed")

func check_collisions():
	if open:
		var overlaps = zone.get_overlapping_bodies()
		for o in overlaps:
			if o.is_in_group("player"):
				emit_signal("player_entered", o)

func _on_body_enter(object):
	if open and object.is_in_group("player"):
		emit_signal("player_entered", object)

func _on_area_enter(object):
	if open and object.is_in_group("player"):
		emit_signal("player_entered", object)
