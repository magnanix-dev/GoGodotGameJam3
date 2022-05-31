extends Spatial

signal hit(velocity, pos, norm)

var weapon : Weapon
var call_func = "fire_primary"
var settings : Resource
var evolutions = []

var active = false
var safety_timer = 0.0
var base_speed = 0.0
var speed = 0.0
var base_direction = Vector3.ZERO
var direction = Vector3.ZERO

var last_pos = Vector3.ZERO

onready var ray = $RayCast

var Line = preload("res://assets/scripts/development/DrawLine3D.gd").new()

func execute():
	# Do evolution mutations here
	print(evolutions)
	for e in evolutions:
		match e.name:
			"duplicate":
				if weapon.has_method(call_func):
					for n in range(e.count):
						weapon.call(call_func, global_transform.origin, base_direction)
	# Testing:
	# connect("hit", self, "_on_hit_bounce")
	add_child(Line)
	visible = true
	active = true
	safety_timer = 3.0

func move(pos, dir):
	base_speed = settings.speed
	speed = base_speed
	if settings.speed_variance:
		speed = clamp(rand_range(speed-(settings.speed_variance/2), speed+(settings.speed_variance/2)), 1, 9999)
	global_transform.origin = pos
	base_direction = dir
	direction = base_direction
	if settings.spread > 0.0:
		var offset = deg2rad(rand_range(-settings.spread*0.5, settings.spread*0.5))
		direction = dir.rotated(Vector3.UP, offset)
	last_pos = global_transform.origin

func _physics_process(delta):
	if active:
		var _velocity = direction * (delta * speed)
		translation += _velocity
		var distance = last_pos - global_transform.origin
		
		ray.cast_to = distance 
		ray.global_transform.origin = last_pos
		
		Line.DrawRay(last_pos, distance, Color.white, 0.1)
		
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			print("Bullet hit: ", collider)
			global_transform.origin = ray.get_collision_point()
			active = false
			visible = false
			emit_signal("hit", _velocity, ray.get_collision_point(), ray.get_collision_normal())
		
		last_pos = translation
		safety_timer -= delta
		if safety_timer <= 0.0:
			active = false
			visible = false

func _on_hit_bounce(vel, pos, norm):
	direction = vel.bounce(norm).normalized() #(vel * -1).normalized()
	visible = true
	active = true
	safety_timer = 3.0
