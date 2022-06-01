extends Spatial

onready var model = $UnformedRelic

func _process(delta):
	model.rotate_y(delta * 0.7)
