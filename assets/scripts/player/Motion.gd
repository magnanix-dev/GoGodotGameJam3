extends 'res://assets/scripts/shared/State.gd'

var speed = 0.0
var velocity = Vector3.ZERO
var allow_mouselook = true

func handle_input(event):
	return .handle_input(event)

func get_input_direction():
	velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	return velocity.normalized()
