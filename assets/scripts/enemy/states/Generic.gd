extends 'res://assets/scripts/shared/State.gd'

var speed = 0.0
var velocity = Vector3.ZERO
var direction = Vector3.ZERO

var duration = 0.0
var next = ""

var target_direction = false

func check_direction(dir):
	var ray = owner.eyes
	var check = (dir * owner.settings.collision_avoid_distance) - ray.global_transform.origin
	owner.Line.DrawRay(ray.global_transform.origin, check, Color.white, 0.1)
	
	ray.force_raycast_update()
	if ray.is_colliding():
		return false
	return true

func look_target():
	var target = owner.target
	var ray = owner.eyes

	if target:
		var dir = (target.global_transform.origin + Vector3(0, 0.3, 0)) - ray.global_transform.origin
		ray.cast_to = dir
		
		owner.Line.DrawRay(ray.global_transform.origin, dir, Color.white, 0.1)
		
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			owner.label.text = collider.name
			owner.test.global_transform.origin = ray.get_collision_point()
			if collider.is_in_group("player"):
				owner.label.text += "\nshould be hunting!"
				target_direction = (target.global_transform.origin - owner.global_transform.origin).normalized()
				owner.label.text += "\n " + str(target_direction)
				return owner.global_transform.origin.distance_to(target.global_transform.origin)
			else:
				owner.label.text += "\ncannot find player!"
				owner.label.text += "\n " + str(ray.get_collision_point())
				target_direction = false
				return false
	return false
