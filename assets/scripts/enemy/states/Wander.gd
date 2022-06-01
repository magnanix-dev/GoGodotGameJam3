extends 'Generic.gd'

func enter():
	speed = owner.settings.wander_max_speed
	velocity = Vector3.ZERO
	duration = rand_range(owner.settings.wander_duration_min, owner.settings.wander_duration_max)
	if direction == Vector3.ZERO: direction = Vector3.RIGHT
#	var valid = false
#	while not valid:
	direction = direction.rotated(Vector3.UP, deg2rad(rand_range(0, 360)))
#		valid = check_direction(direction)
	owner.mesh.look_at(direction, Vector3.UP)
	next = "idle"
	
	# Handle animations here
	if owner.animations:
		owner.animations.play("walk")

func update(delta):
	if look_target() and randf() <= owner.settings.aggression:
		next = "hunt"
	move(speed, direction)
	duration -= delta
	if duration <= 0.0:
		if next == "idle" and randf() <= owner.settings.whimsy:
			next = "wander"
		emit_signal("finished", next)

func move(speed, direction):
	velocity = direction.normalized() * speed
	owner.move_and_slide(velocity, Vector3.UP)