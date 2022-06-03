extends 'res://assets/scripts/shared/State.gd'

func enter():
	if owner.animations:
		owner.animations["parameters/Dead/blend_amount"] = 1.0
	owner.allow_mouselook = false
	owner.hitbox.disabled = true
	owner.collider.disabled = true

func _on_animation_finished(animation):
	owner.shadow.visible = false
	owner.set_process(false)
	owner.set_physics_process(false)
