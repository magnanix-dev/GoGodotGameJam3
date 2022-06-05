extends 'Motion.gd'

var animation = "walk"
export var max_speed : float = 4

func enter():
	speed = 0.0
	velocity = Vector3.ZERO
	
	# Handle animations here
	if owner.animations:
		owner.animations["parameters/Movement/blend_amount"] = 1.0

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var direction = get_input_direction()
	if not direction:
		emit_signal("finished", "idle")
	if owner.animations:
		var pos = owner.global_transform.origin
		var mouse = owner.mouse_position
		var mouse_dir_3D = (mouse - pos).normalized()
		var mouse_dir = Vector2(mouse_dir_3D.x, mouse_dir_3D.z)
		var dir = Vector2(direction.x, direction.z)
		var angle = rad2deg(mouse_dir.angle())
		var dot = dir.dot(mouse_dir)
		var cross = dir.cross(mouse_dir)
		owner.animations["parameters/Direction/blend_position"] = Vector2(dot, cross)
	speed = max_speed + (Global.player_speed_max * 0.25)
	move(speed, direction)

func move(speed, direction):
	velocity = direction.normalized() * speed
	owner.move_and_slide(velocity, Vector3.UP)
