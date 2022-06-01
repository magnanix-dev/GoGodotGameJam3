extends 'Generic.gd'

func enter():
	speed = owner.settings.hunt_max_speed
	duration = rand_range(owner.settings.hunt_duration_min, owner.settings.hunt_duration_max)
	var distance = look_target()
	if target_direction:
		direction = target_direction
#	var valid = false
	if not distance:
		print("Cannot find player, leaving HUNT, distance = ", distance)
		next = "idle"
		if randf() <= owner.settings.whimsy:
			next = "wander"
		emit_signal("finished", next)
		return
	elif distance < owner.settings.range_min:
#		while not valid:
		direction = -direction.rotated(Vector3.UP, rad2deg(rand_range(-owner.settings.hunt_spread/2, owner.settings.hunt_spread/2)))
#			valid = check_direction(direction)
	else:
#		while not valid:
		direction = direction.rotated(Vector3.UP, rad2deg(rand_range(-owner.settings.hunt_spread/2, owner.settings.hunt_spread/2)))
#			valid = check_direction(direction)
	print("Hunting direction: ", direction)
	owner.mesh.look_at(direction, Vector3.UP)
	next = "hunt"
	
	# Handle animations here
	if owner.animations:
		owner.animations.play("walk")

func update(delta):
	var distance = look_target()
	if not distance or not direction:
		if randf() <= owner.settings.whimsy:
			next = "wander"
		else:
			next = "idle"
	elif distance <= owner.settings.range_max and distance >= owner.settings.range_min:
		next = "shoot"
	move(speed, direction)
	duration -= delta
	if duration <= 0.0:
		emit_signal("finished", next)

func move(speed, direction):
	velocity = direction.normalized() * speed
	owner.move_and_slide(velocity, Vector3.UP)
