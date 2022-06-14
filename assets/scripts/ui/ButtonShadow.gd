tool
extends Label

func _process(delta):
	if Engine.editor_hint:
		text = get_parent().text
