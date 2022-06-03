extends 'res://assets/scripts/shared/State.gd'

func enter():
	if owner.animations:
		owner.animations.stop()
		owner.animations.play(owner.animation_map["death"])
	owner.hitbox.disabled = true
	owner.collider.disabled = true

func _on_animation_finished(animation):
	owner.shadow.visible = false
	owner.set_process(false)
	owner.set_physics_process(false)
