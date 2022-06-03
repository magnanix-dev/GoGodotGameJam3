extends Area

func hit(point, force, damage):
	if owner.has_method("hit"): owner.hit(point, force, damage)
