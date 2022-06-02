extends 'Generic.gd'

func enter():
	duration = rand_range(owner.settings.idle_duration_min, owner.settings.idle_duration_max)
	next = "idle"
	
	# Handle animations here
	if owner.animations:
		owner.animations.play(owner.animation_map["idle"])

func update(delta):
	look_toward(owner.mesh, direction, delta * look_speed)
	if look_target() and randf() <= owner.settings.aggression:
		next = "hunt"
	elif next == "idle" and randf() <= owner.settings.whimsy:
		next = "wander"
	duration -= delta
	if duration <= 0.0:
		emit_signal("finished", next)
