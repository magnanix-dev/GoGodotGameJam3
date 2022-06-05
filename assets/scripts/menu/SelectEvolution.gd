extends TextureButton

export (Resource) var evolution
export var type = "primary"

onready var left_label = $Left

var base_colour = null

func _ready():
	if disabled:
		mouse_default_cursor_shape = CURSOR_ARROW		
		modulate = Color(1.0,1.0,1.0,0.5)
	else:
		modulate = Color(1.0,1.0,1.0,1.0)
	left_label.set("custom_colors/font_color", Color.black)
	base_colour = left_label.get("custom_colors/font_color")


func _on_hover():
	if not disabled:
		left_label.set("custom_colors/font_color", Color.white)


func _on_leave():
	left_label.set("custom_colors/font_color", base_colour)
