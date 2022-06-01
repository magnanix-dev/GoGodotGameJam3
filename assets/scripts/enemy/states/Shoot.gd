extends 'Generic.gd'

func enter():
	var distance = look_target()
	if target_direction: owner.mesh.look_at(target_direction, Vector3.UP)
	owner.primary.look_at(owner.target.global_transform.origin + Vector3(0, owner.primary.global_transform.origin.y, 0), Vector3.UP)
	owner.primary.prepare()
	duration = rand_range(owner.settings.shoot_duration_min, owner.settings.shoot_duration_max)
	
	# Handle animations here
	if owner.animations:
		owner.animations.play("shoot")

func update(delta):
	var distance = look_target()
	if not distance:
		if randf() <= owner.settings.whimsy:
			next = "wander"
		else:
			next = "idle"
	else:
		next = "hunt"
	if randf() <= owner.settings.shoot_repeat_chance and distance <= owner.settings.range_max and distance >= owner.settings.range_min:
		next = "shoot"
	duration -= delta
	if duration <= 0.0:
		emit_signal("finished", next)

func move(speed, direction):
	velocity = direction.normalized() * speed
	owner.move_and_slide(velocity, Vector3.UP)
