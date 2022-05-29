extends 'res://assets/scripts/shared/State.gd'

var speed = 0.0
var velocity = Vector3.ZERO
var drop_plane = false

var camera
var camera_base_speed = 10
var camera_min_distance = 0
var camera_max_distance = 10
var camera_offset = 0.25

func handle_input(event):
	return .handle_input(event)

func get_input_direction():
	velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	return velocity.normalized()

func get_mouse_position():
	if not drop_plane:
		drop_plane = Plane(Vector3(0, 1, 0), owner.global_transform.origin.y)
	#print(drop_plane)
	var mouse_pos = get_viewport().get_mouse_position()
	if not camera:
		camera = owner.camera_pivot.camera
	
	return drop_plane.intersects_ray(camera.project_ray_origin(mouse_pos), camera.project_ray_normal(mouse_pos)*100)

func update_look_direction():
	var mouse_position = get_mouse_position()
	var target = Vector3(mouse_position.x, owner.global_transform.origin.y, mouse_position.z) - owner.global_transform.origin
	owner.look_at(target, Vector3.UP)
	var pivot_position = target * camera_offset
	var pivot_distance = pivot_position.distance_to(owner.global_transform.origin)
	if pivot_distance <= camera_min_distance:
		pivot_position = pivot_position.normalized() * camera_min_distance
	elif pivot_distance >= camera_max_distance:
		pivot_position = pivot_position.normalized() * camera_max_distance
	owner.camera_pivot.target = pivot_position
	owner.camera_pivot.speed = camera_base_speed
