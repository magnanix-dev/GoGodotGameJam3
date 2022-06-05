extends TextureButton

var evolution
var type = "primary"

onready var title_label = $Title
onready var type_label = $Type
onready var details_label = $Details

var base_colour = null

func _ready():
	if disabled:
		mouse_default_cursor_shape = CURSOR_ARROW
		modulate = Color(1.0,1.0,1.0,0.5)
	else:
		modulate = Color(1.0,1.0,1.0,1.0)
	title_label.set("custom_colors/font_color", Color.black)
	type_label.set("custom_colors/font_color", Color.black)
	details_label.set("custom_colors/font_color", Color.black)
	base_colour = title_label.get("custom_colors/font_color")

func initialize():
	title_label.text = evolution.title
	type_label.text = type.capitalize()
	details_label.text = evolution.details

func _on_hover():
	if not disabled:
		title_label.set("custom_colors/font_color", Color.white)
		type_label.set("custom_colors/font_color", Color.white)
		details_label.set("custom_colors/font_color", Color.white)

func _on_leave():
	title_label.set("custom_colors/font_color", base_colour)
	type_label.set("custom_colors/font_color", base_colour)
	details_label.set("custom_colors/font_color", base_colour)
