extends 'res://assets/scripts/shared/State.gd'

var speed = 0.0
var velocity = Vector3.ZERO

func handle_input(event):
	if event.is_action_pressed("tertiary") and owner.allow_dash:
		emit_signal("finished", "dash")
	return .handle_input(event)

func get_input_direction():
	velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	return velocity.normalized()
