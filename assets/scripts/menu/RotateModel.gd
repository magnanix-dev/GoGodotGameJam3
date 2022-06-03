extends Spatial

export (Resource) var settings = null

onready var model = $Model

func _ready():
	update_settings()

func _process(delta):
	model.rotate_y(delta * 0.7)

func update_settings():
	if settings != null and settings.mesh:
		for n in model.get_children():
			model.remove_child(n)
			n.queue_free()
		var m = settings.mesh.instance()
		if m.find_node("AnimationPlayer"):
			m.get_node("AnimationPlayer")["parameters/Movement/blend_amount"] = 0.0
		model.add_child(m)
