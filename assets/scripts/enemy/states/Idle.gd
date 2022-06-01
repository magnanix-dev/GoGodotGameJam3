extends 'Generic.gd'

func enter():
	duration = rand_range(owner.settings.idle_duration_min, owner.settings.idle_duration_max)
	# @TODO: Make sure that the direction selected is valid, this while loop seems to break the game at present.
#	var valid = false
#	while not valid:
	direction = direction.rotated(Vector3.UP, deg2rad(rand_range(0, 360)))
#		valid = check_direction(direction)
	owner.mesh.look_at(direction, Vector3.UP)
	next = "idle"
	
	# Handle animations here
	if owner.animations:
		owner.animations.play("idle")

func update(delta):
	if look_target() and randf() <= owner.settings.aggression:
		next = "hunt"
	elif next == "idle" and randf() <= owner.settings.whimsy:
		next = "wander"
	duration -= delta
	if duration <= 0.0:
		emit_signal("finished", next)
