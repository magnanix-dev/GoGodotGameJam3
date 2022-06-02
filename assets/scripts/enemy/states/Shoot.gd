extends 'Generic.gd'

func enter():
	var distance = look_target()
	duration = rand_range(owner.settings.shoot_duration_min, owner.settings.shoot_duration_max)
	
	owner.primary.look_at(owner.target.global_transform.origin + Vector3(0, owner.primary.global_transform.origin.y, 0), Vector3.UP)
	owner.primary.prepare()
	
	# Handle animations here
	if owner.animations:
		owner.animations.play("shoot")

func update(delta):
	look_toward(owner.mesh, target_direction, delta * look_speed)
	var found_target = look_target()
	if not found_target:
		if randf() <= owner.settings.whimsy:
			next = "wander"
		else:
			next = "idle"
	else:
		next = "hunt"
	if randf() <= owner.settings.shoot_repeat_chance and target_distance <= owner.settings.range_max and target_distance >= owner.settings.range_min:
		next = "shoot"
	duration -= delta
	if duration <= 0.0:
		emit_signal("finished", next)

func move(speed, direction):
	velocity = direction.normalized() * speed
	owner.move_and_slide(velocity, Vector3.UP)
