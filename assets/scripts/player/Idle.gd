extends 'Motion.gd'

export var max_speed : float = 450

func enter():
	# Handle animations here
	pass

func handle_input(event):
	return .handle_input(event)

func update(delta):
	update_look_direction()
	var direction = get_input_direction()
	if direction:
		emit_signal("finished", "move")
