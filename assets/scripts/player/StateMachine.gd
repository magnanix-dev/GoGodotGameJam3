extends KinematicBody

signal changed_state
signal can_dash
signal can_primary

var stack = []
var current = null

var primary_evolutions = []
var secondary_evolutions = []
var tertiary_evolutions = []

var camera
var drop_plane
var mouse_position

var allow_mouselook = true
var allow_dash = true
#var allow_primary = true
#var allow_secondary = true

onready var map = {
	'idle': $States/Idle,
	'move': $States/Move,
	'dash': $States/Dash,
	'stagger': $States/Stagger,
	'death': $States/Death,
}

onready var camera_pivot = $Pivot
onready var weapon = $Weapon

func _ready():
	for node in $States.get_children():
		node.connect("finished", self, "_change_state")
	stack.push_front($States/Idle)
	current = stack[0]
	_change_state("idle")

func _physics_process(delta):
	if allow_mouselook:
		_mouselook()
	current.update(delta)

func _input(event):
	if event.is_action_pressed("primary"):
		weapon.primary(weapon.global_transform.origin, -weapon.global_transform.basis.z)
	if event.is_action_pressed("secondary"):
		weapon.secondary(weapon.global_transform.origin, -weapon.global_transform.basis.z)
	current.handle_input(event)

func _change_state(state):
	if current: current.exit()
	
	if state == "previous":
		stack.pop_front()
	elif state in ["stagger", "dash"]:
		stack.push_front(map[state])
	else:
		var new = map[state]
		stack[0] = new
	
	current = stack[0]
	if state != "previous":
		current.enter()
	
	emit_signal("changed_state", stack)

func _mouselook():
	if not drop_plane:
		drop_plane = Plane(Vector3(0, 1, 0), global_transform.origin.y)
	var mouse_pos = get_viewport().get_mouse_position()
	if not camera:
		camera = camera_pivot.camera
	mouse_position = drop_plane.intersects_ray(camera.project_ray_origin(mouse_pos), camera.project_ray_normal(mouse_pos)*100)
	
	var target = Vector3(mouse_position.x, global_transform.origin.y, mouse_position.z)
	look_at(target, Vector3.UP)

func _on_dash_timer_timeout():
	allow_dash = true
	emit_signal("can_dash")

#func _on_primary_timer_timeout():
#	allow_primary = true
#	emit_signal("can_primary")
#
#func _on_secondary_timer_timeout():
#	allow_secondary = true
#	emit_signal("can_secondary")
