extends KinematicBody

signal changed_state

export (Resource) var settings

var stack = []
var current = null

var primary_evolutions = []
var secondary_evolutions = []

var health = 0
var animations = false
var target

onready var map = {
	'idle': $States/Idle,
	'wander': $States/Wander,
	'hunt': $States/Hunt,
	'shoot': $States/Shoot,
	'stagger': $States/Stagger,
	'death': $States/Death,
}

var animation_map = {
	"idle": "Idle",
	"walk": "Walk",
	"shoot": "Shoot",
	"stagger": "Stagger",
	"death": "Death",
}

onready var collision_shape = $CollisionShape
onready var primary = $PrimaryWeapon
onready var eyes = $Eyes
onready var plan = $Plan
onready var mesh = $Mesh
onready var mesh_container = $Mesh/Fix
onready var shadow = $Mesh/Shadow

onready var label = $DebugLabel
onready var eyes_debug_target = $DebugEyesTarget

var Line = preload("res://assets/scripts/development/DrawLine3D.gd").new()

func _ready():
	add_child(Line)
	if Global.player:
		_set_target(Global.player)
	else:
		Global.connect("player_set", self, "_set_target")
	if settings.mesh:
		for n in mesh_container.get_children():
			mesh_container.remove_child(n)
			n.queue_free()
		var m = settings.mesh.instance()
		mesh_container.add_child(m)
		animations = m.animations
		animations.connect("animation_finished", self, "_on_animation_finished")
	for node in $States.get_children():
		node.connect("finished", self, "_change_state")
	health = settings.health
	stack.push_front($States/Idle)
	current = stack[0]
	_change_state("idle")

func _set_target(object):
	target = object

func _physics_process(delta):
	current.update(delta)

func _on_animation_finished(animation):
	current._on_animation_finished(animation)

func _change_state(state):
	if current: current.exit()
	
	if state == "previous":
		stack.pop_front()
	elif state in ["stagger", "death"]:
		stack.push_front(map[state])
	else:
		var new = map[state]
		stack[0] = new
		print("New State: ", state)
	
	current = stack[0]
	if state != "previous":
		current.enter()
	
	emit_signal("changed_state", stack)

func hit(point, force, damage):
	take_damage(damage)
	current.emit_signal("finished", "stagger")

func take_damage(damage):
	health -= damage
	if health <= 0:
		current.emit_signal("finished", "death")

#func _on_primary_timer_timeout():
#	allow_primary = true
#	emit_signal("can_primary")
#
#func _on_secondary_timer_timeout():
#	allow_secondary = true
#	emit_signal("can_secondary")
