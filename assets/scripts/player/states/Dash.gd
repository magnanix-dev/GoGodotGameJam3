extends 'Motion.gd'

var animation = "dash"
export (Resource) var settings
export var dash_power : float = 1024
export var dash_duration : float = 0.25
export var dash_cooldown : float = 1.5

var enter_move_direction = Vector3.ZERO
var enter_mouse_direction = Vector3.ZERO

var dash_time = 0.0

var dash_timer

func enter():
	owner.allow_dash = false
	if not dash_timer:
		dash_timer = Timer.new()
		dash_timer.connect("timeout", owner, "_on_dash_timer_timeout")
		add_child(dash_timer)
	dash_timer.start(dash_cooldown)
	enter_move_direction = get_input_direction()
	enter_mouse_direction = (owner.mouse_position - owner.global_transform.origin).normalized()
	dash_time = dash_duration
	
	if owner.animations:
		owner.animations.play(owner.animation_map[animation])

func update(delta):
	if enter_move_direction != Vector3.ZERO: #Global.settings.dash_direction:
		move(enter_move_direction * dash_power * delta)
	else:
		move(enter_mouse_direction * (dash_power * delta))
	dash_time -= (1/dash_duration) * delta
	if Global.debug: print(dash_time)
	if dash_time <= 0.0:
		emit_signal("finished", "previous")

func move(velocity):
	owner.move_and_slide(velocity, Vector3.UP)
