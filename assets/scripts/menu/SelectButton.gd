extends TextureButton

export (Resource) var settings

onready var rotate_model = $Viewport/RotateModel
onready var model_sprite = $ModelSprite
onready var model_highlight = $ModelHighlight
onready var left_label = $Left
onready var right_label = $Right

var base_colour = null

func _ready():
	model_highlight.visible = false
	model_highlight.modulate = Color.white
	if disabled:
		mouse_default_cursor_shape = CURSOR_ARROW
		model_sprite.set_modulate(Color.black)
#		left_label.set("custom_colors/font_color", Color.black)
#		right_label.set("custom_colors/font_color", Color.black)
	else:
#		left_label.set("custom_colors/font_color", Color(0.13,0.13,0.13,1))
#		right_label.set("custom_colors/font_color", Color(0.13,0.13,0.13,1))
		pass
	rotate_model.settings = settings
	rotate_model.update_settings()
	if settings.name != "":
		left_label.text = "Type:"
		right_label.text = settings.name
	if settings.primary_settings != null and settings.primary_settings.name != "":
		left_label.text += "\nMain:"
		right_label.text += "\n" + settings.primary_settings.name
	if settings.secondary_settings != null and settings.secondary_settings.name != "":
		left_label.text += "\nAlt:"
		right_label.text += "\n" + settings.secondary_settings.name
	if settings.tertiary_settings != null and settings.tertiary_settings.name != "":
		left_label.text += "\nDash:"
		right_label.text += "\n" + settings.tertiary_settings.name
	else:
		left_label.text += "\nDash:"
		right_label.text += "\nBasic"
	left_label.set("custom_colors/font_color", Color.black)
	right_label.set("custom_colors/font_color", Color.black)
	base_colour = left_label.get("custom_colors/font_color")


func _on_hover():
	if not disabled:
		model_highlight.visible = true
		left_label.set("custom_colors/font_color", Color.white)
		right_label.set("custom_colors/font_color", Color.white)


func _on_leave():
	model_highlight.visible = false
	left_label.set("custom_colors/font_color", base_colour)
	right_label.set("custom_colors/font_color", base_colour)
