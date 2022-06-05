extends Spatial

onready var animations = $AnimationPlayer
export var aim_offset = Vector3(0, 0, 0)

func get_aim_offset():
#	if find_node("AimOffset"):
#		aim_offset = get_node("AimOffset").global_transform.origin - global_transform.origin
	return aim_offset
