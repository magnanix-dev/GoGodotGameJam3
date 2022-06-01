extends Position3D

onready var camera = $Camera
onready var sourcepos = $Source
onready var targetpos = $Target
onready var midpointpos = $Midpoint

export var speed = 20
export var source = Vector3.ZERO
export var target = Vector3.ZERO

var camera_min_distance = 0
var camera_max_distance = 10
var camera_offset = 0.25
var camera_actual_position = Vector3.ZERO

export var shake_duration = 0.05
var shake_timer = 0.0
var shake_direction = Vector3.ZERO
var shake_magnitude = 0.0
# var shake_offset = Vector3.ZERO

func _ready():
	source = owner
	set_as_toplevel(true)
	camera_actual_position = camera.translation

func _physics_process(delta):
	if source.drop_plane:
		var t = source.global_transform.origin + (source.mouse_position - source.global_transform.origin) * camera_offset
		global_transform.origin = lerp(global_transform.origin, t, delta * speed)
	if shake_timer > 0.0:
		camera.translation = camera_actual_position + Vector3((shake_direction.x * shake_magnitude/2), 0, (shake_direction.z * shake_magnitude))
		shake_timer -= delta
	else:
		camera.translation = camera_actual_position

func _on_fire_projectile(dir, mag):
	shake_direction = -dir
	shake_magnitude = mag / 125
	shake_timer = shake_duration
