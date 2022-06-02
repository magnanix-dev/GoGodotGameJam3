extends 'Generic.gd'

func enter():
	speed = owner.settings.hunt_max_speed
	duration = rand_range(owner.settings.hunt_duration_min, owner.settings.hunt_duration_max)
	var target_found = look_target()
	var iterated = 0
	if not target_found:
#		print("Cannot find player, leaving hunt...")
		next = "idle"
		if randf() <= owner.settings.whimsy:
			next = "wander"
		emit_signal("finished", next)
		return
	elif target_distance < owner.settings.range_min:
		direction = -target_direction.rotated(Vector3.UP, rad2deg(rand_range(-owner.settings.hunt_spread/2, owner.settings.hunt_spread/2)))
		iterated = 0
		while not check_direction(direction) and iterated < 20:
			direction = -target_direction.rotated(Vector3.UP, rad2deg(rand_range(-owner.settings.hunt_spread/2, owner.settings.hunt_spread/2)))
			iterated += 1
	else:
		direction = target_direction.rotated(Vector3.UP, rad2deg(rand_range(-owner.settings.hunt_spread/2, owner.settings.hunt_spread/2)))
		iterated = 0
		while not check_direction(direction) and iterated < 20:
			direction = target_direction.rotated(Vector3.UP, rad2deg(rand_range(-owner.settings.hunt_spread/2, owner.settings.hunt_spread/2)))
			iterated += 1
#	print("Hunting direction: ", direction)
	next = "hunt"
	if randf() <= owner.settings.shoot_repeat_chance and target_distance <= owner.settings.range_max and target_distance >= owner.settings.range_min:
		emit_signal("finished", "shoot")
	
	# Handle animations here
	if owner.animations:
		owner.animations.play(owner.animation_map["walk"])

func update(delta):
	look_toward(owner.mesh, direction, delta * look_speed)
	var target_found = look_target()
	if not target_found:
		if randf() <= owner.settings.whimsy:
			next = "wander"
		else:
			next = "idle"
	elif target_distance <= owner.settings.range_max and target_distance >= owner.settings.range_min:
		next = "shoot"
	move(speed, direction)
	duration -= delta
	if duration <= 0.0:
		emit_signal("finished", next)

func move(speed, direction):
	velocity = direction.normalized() * speed
	owner.move_and_slide(velocity, Vector3.UP)
