extends 'res://assets/scripts/shared/State.gd'

var previous_animation = ""

func enter():
	if owner.animations:
		previous_animation = owner.animations.current_animation
		owner.animations.play(owner.animation_map["stagger"])

func _on_animation_finished(animation):
	if previous_animation != "shoot": owner.animations.play(previous_animation)
	emit_signal("finished", "previous")
