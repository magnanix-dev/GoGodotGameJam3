extends Spatial
class_name Projectile

signal hit(velocity, pos, norm)

var manager

var lifetime_timer = 0.0
var active = false

var speed = 0.0
var direction = Vector3.ZERO

var last = Vector3.ZERO

onready var mesh = $Mesh
onready var ray = $RayCast

var hits = []

func activate():
	visible = true
	active = true

func deactivate():
	hits = []
	active = false
	visible = false

func execute(lifetime = 3.0):
	activate()
	lifetime_timer = lifetime

func setup(pos, dir, spd):
	hits = []
	global_transform.origin = pos
	direction = dir
	speed = spd
	
	last = global_transform.origin

func _physics_process(delta):
	if active:
		var old_translation = translation
		
		translation += direction * (delta * speed)
		
		ray.cast_to = old_translation - global_transform.origin # last - global_transform.origin
		ray.global_transform.origin = old_translation # last
		
		if mesh: mesh.look_at(global_transform.origin + direction, Vector3.UP)
		
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			if not hits.has(collider):
				global_transform.origin = ray.get_collision_point()
				emit_signal("hit", direction * (delta * speed), ray.get_collision_point(), ray.get_collision_normal(), collider)
		
#		last = translation
		lifetime_timer -= delta
		if lifetime_timer <= 0.0:
			deactivate()
