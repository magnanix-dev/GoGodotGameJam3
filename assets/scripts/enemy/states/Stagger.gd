extends 'res://assets/scripts/shared/State.gd'

func enter():
	if owner.animations:
		owner.animations.play("stagger")
