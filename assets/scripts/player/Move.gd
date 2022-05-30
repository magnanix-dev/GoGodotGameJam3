extends 'Motion.gd'

export var max_speed : float = 6

func enter():
	speed = 0.0
	velocity = Vector3.ZERO
	
	# Handle animations here

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var direction = get_input_direction()
	if not direction:
		emit_signal("finished", "idle")
	speed = max_speed
	move(speed, direction)

func move(speed, direction):
	velocity = direction.normalized() * speed
	owner.move_and_slide(velocity, Vector3.UP)
