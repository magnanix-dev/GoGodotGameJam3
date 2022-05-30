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

func _ready():
	source = owner
	set_as_toplevel(true)

func _physics_process(delta):
	if source.drop_plane:
		var t = source.global_transform.origin + (source.mouse_position - source.global_transform.origin) * camera_offset

		global_transform.origin = lerp(global_transform.origin, t, delta * speed)
