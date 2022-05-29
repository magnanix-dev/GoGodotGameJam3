extends KinematicBody

signal changed_state

var stack = []
var current = null

onready var map = {
	'idle': $States/Idle,
	'move': $States/Move,
	'stagger': $States/Stagger,
	'death': $States/Death,
}

onready var camera_pivot = $Pivot

func _ready():
	for node in $States.get_children():
		node.connect("finished", self, "_change_state")
	stack.push_front($States/Idle)
	current = stack[0]
	_change_state("idle")

func _physics_process(delta):
	current.update(delta)

func _input(event):
	if event.is_action_pressed("primary"):
		pass

func _change_state(state):
	if current: current.exit()
	
	if state == "previous":
		stack.pop_front()
	elif state in ["stagger"]:
		stack.push_front(map[state])
	else:
		var new = map[state]
		stack[0] = new
	
	current = stack[0]
	if state != "previous":
		current.enter()
	
	emit_signal("changed_state", stack)
