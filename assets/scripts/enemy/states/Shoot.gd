extends 'Generic.gd'

var last_direction = Vector3(1, 0, 1)

func enter():
	var distance = look_target()
	duration = rand_range(owner.settings.shoot_duration_min, owner.settings.shoot_duration_max)
	
	owner.primary.look_at(owner.target.global_transform.origin + Vector3(0, owner.primary.global_transform.origin.y, 0), Vector3.UP)
	owner.primary.prepare()
	
	last_direction = target_direction
	
	# Handle animations here
	if owner.animations:
		owner.animations.play(owner.animation_map["shoot"])

func update(delta):
	look_toward(owner.mesh, last_direction, delta * look_speed)
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
	if target_direction != null and target_direction != Vector3.ZERO:
		last_direction = target_direction

func move(speed, direction):
	velocity = direction.normalized() * speed
	owner.move_and_slide(velocity, Vector3.UP)
