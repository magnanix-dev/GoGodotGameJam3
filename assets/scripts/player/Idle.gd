extends 'Motion.gd'

func enter():
	# Handle animations here
	pass

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var direction = get_input_direction()
	if direction:
		emit_signal("finished", "move")
