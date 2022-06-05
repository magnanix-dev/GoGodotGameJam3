extends KinematicBody

onready var pickup = $Pickup

var allow_pickup = false
var spawn_direction = Vector3()
var spawn_rotation = Vector3()
var spawn_speed = 25
var spawn_rotation_speed = 0.5
var spawn_time = 2

var vacuum_pickup = false
var vacuum_target = Vector3()
var vacuum_speed = -150
var vacuum_accumulated_speed = 300

onready var mesh = $Mesh

var value : float = 1.0

func _ready():
	# set exp value based on game difficulty
	# value = Global.experience_amount()
	spawn_direction = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1))
	spawn_rotation = Vector3(0, rand_range(0, TAU), 0)

func _physics_process(delta):
	mesh.rotate_z(delta * 0.7)
	spawn_time -= delta
	if spawn_time >= 0.0:
		rotation += spawn_rotation * (delta * spawn_rotation_speed)
		move_and_slide(spawn_direction * (spawn_speed * delta))
	else:
		allow_pickup = true
	if allow_pickup and vacuum_pickup and is_instance_valid(vacuum_target):
		var direction = (vacuum_target.global_transform.origin - global_transform.origin).normalized()
		move_and_slide(direction * (vacuum_speed * delta))
		vacuum_speed += vacuum_accumulated_speed * delta

func pull(target):
	vacuum_target = target
	allow_pickup = true
	vacuum_pickup = true
	set_collision_mask_bit(0, false)

func pickup(target):
	Global.increase_exp(value)
	queue_free()
