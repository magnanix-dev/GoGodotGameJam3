extends 'res://assets/scripts/shared/State.gd'

var look_speed = 10
var speed = 0.0
var velocity = Vector3.ZERO
var direction = Vector3.ZERO

var duration = 0.0
var next = ""

var target_direction = false
var target_distance = 0.0

func look_toward(origin, direction, delta):
	var t = origin.global_transform.looking_at(origin.global_transform.origin + direction, Vector3.UP)
	var a = Quat(origin.global_transform.basis)
	var b = Quat(t.basis)
	var c = a.slerp(b, delta)
	origin.transform.basis = Basis(c)

func check_direction(dir):
	var ray = owner.plan
	var speed_duration = (speed) * duration
	var check = ((dir * owner.settings.collision_avoid_distance) + (dir * speed_duration) + Vector3(0, ray.global_transform.origin.y, 0))
	ray.cast_to = check
	
	#owner.Line.DrawRay(ray.global_transform.origin, check, Color.blue, 1)
	
	ray.force_raycast_update()
	if ray.is_colliding():
		return false
	return true

func look_target():
	var target = owner.target
	var ray = owner.eyes
	target_direction = false
	target_distance = 0.0

	if target:
		
		var dir = (target.global_transform.origin + Vector3(0, 0.3, 0)) - ray.global_transform.origin
		ray.cast_to = dir
		
		#owner.Line.DrawRay(ray.global_transform.origin, dir, Color.white, 0.1)
		
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			owner.label.text = collider.name
			owner.eyes_debug_target.global_transform.origin = ray.get_collision_point()
			if collider.is_in_group("player"):
				target_direction = (target.global_transform.origin - owner.global_transform.origin).normalized()
				target_distance = owner.global_transform.origin.distance_to(target.global_transform.origin)
				owner.label.text += "\nshould be hunting!"
				owner.label.text += "\n " + str(target_direction)
				return true
			else:
				owner.label.text += "\ncannot find player!"
				owner.label.text += "\n " + str(ray.get_collision_point())
				return false
	return false
