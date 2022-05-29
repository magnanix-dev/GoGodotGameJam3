extends Position3D

onready var camera = $Camera

export var speed = 2
export var target = Vector3.ZERO

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	global_transform.origin = lerp(global_transform.origin, target, delta * speed)
