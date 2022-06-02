extends Spatial
class_name Projectile

signal hit(velocity, pos, norm)

var manager

var lifetime_timer = 0.0
var active = false

var speed = 0.0
var direction = Vector3.ZERO
var damage = 0.0

var last = Vector3.ZERO

onready var ray = $RayCast

#var Line = preload("res://assets/scripts/development/DrawLine3D.gd").new()

func activate():
	visible = true
	active = true

func deactivate():
	active = false
	visible = false

func execute(lifetime = 3.0):
	#add_child(Line)
	activate()
	lifetime_timer = lifetime
#	print("Projectile: Executing...")

func setup(pos, dir, spd, dmg):
	global_transform.origin = pos
	direction = dir
	speed = spd
	damage = dmg
	
	last = global_transform.origin

func _physics_process(delta):
	if active:
		translation += direction * (delta * speed)
		
		ray.cast_to = last - global_transform.origin
		ray.global_transform.origin = last
		
		#Line.DrawRay(last, last - global_transform.origin, Color.white, 0.1)
		
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
#			print("Hit: ", collider.name)
			if collider.has_method("hit"):
				collider.call("hit", ray.get_collision_point(), delta * speed, damage)
			global_transform.origin = ray.get_collision_point()
			deactivate()
			emit_signal("hit", direction * (delta * speed), ray.get_collision_point(), ray.get_collision_normal())
		
		last = translation
		lifetime_timer -= delta
		if lifetime_timer <= 0.0:
			deactivate()

#func _on_hit_bounce(vel, pos, norm):
#	direction = vel.bounce(norm).normalized() #(vel * -1).normalized()
#	visible = true
#	active = true
#	lifetime_timer = 3.0
