extends KinematicBody

func pickup(user):
	Global.increase_health(4)
	queue_free()
