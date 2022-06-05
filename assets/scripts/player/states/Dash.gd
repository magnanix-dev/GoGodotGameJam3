extends 'Motion.gd'

signal cooldown
signal ability_pressed
signal ability_released

var animation = "dash"
export (Resource) var settings = null
export (Texture) var dash_icon = null
export var dash_power : float = 512
export var dash_duration : float = 0.5
export var dash_cooldown : float = 1.5

var enter_move_direction = Vector3.ZERO
var enter_mouse_direction = Vector3.ZERO

var dash_time = 0.0

var dash_timer

var pressed = false

func enter():
	owner.allow_mouselook = false
	owner.allow_dash = false
	if not dash_timer:
		dash_timer = Timer.new()
		dash_timer.connect("timeout", owner, "_on_dash_timer_timeout")
		add_child(dash_timer)
	dash_timer.start(dash_cooldown)
	emit_signal("cooldown")
	enter_move_direction = get_input_direction()
	enter_mouse_direction = (owner.mouse_position - owner.global_transform.origin).normalized()
	dash_time = dash_duration
	
	if settings != null:
		dash_icon = settings.ability_icon
		dash_cooldown = settings.cooldown
	
	if owner.animations:
		owner.animations["parameters/Dashing/active"] = false
		owner.animations["parameters/Dashing/active"] = true

func update(delta):
	if enter_move_direction != Vector3.ZERO: #Global.settings.dash_direction:
		move(enter_move_direction * (dash_power * delta))
		owner.look_at(enter_move_direction * dash_power, Vector3.UP)
	else:
		move(enter_mouse_direction * (dash_power * delta))
		owner.look_at(enter_mouse_direction * dash_power, Vector3.UP)
	dash_time -= (1/dash_duration) * delta
	if Global.debug: print(dash_time)
	if dash_time <= 0.0:
		owner.animations["parameters/Dashing/active"] = false
		owner.allow_mouselook = true
		emit_signal("finished", "previous")

func move(velocity):
	owner.move_and_slide(velocity, Vector3.UP)
