extends KinematicBody

signal changed_state
signal can_dash
signal can_primary

var stack = []
var current = null

export (Resource) var settings

var primary_evolutions = []
var secondary_evolutions = []
var tertiary_evolutions = []

var camera
var drop_plane
var mouse_position
var animations = false
var aim_offset = Vector3.ZERO

var allow_mouselook = true
var allow_dash = true
#var allow_primary = true
#var allow_secondary = true

onready var map = {
	'idle': $States/Idle,
	'move': $States/Move,
	'dash': $States/Dash,
	'death': $States/Death,
}

var animation_map = {
	"idle": "Idle",
	"walk": "Walk",
	"dash": "Dash",
	"shoot": "Shoot",
	"stagger": "Stagger",
	"death": "Death",
}

onready var collider = $Collider
onready var hitbox = $HitBox/HitBoxCollider

onready var camera_pivot = $Pivot
onready var primary = $PrimaryWeapon
onready var secondary = $SecondaryWeapon

onready var mesh_container = $Mesh/Fix
onready var shadow = $Mesh/Shadow

onready var pull = $Pull
onready var pickup = $Pickup

func _ready():
	settings = Global.player_settings
	
	if not Global.player_health_set:
		Global.set_health(settings.health)
	
	if settings.mesh:
		for n in mesh_container.get_children():
			mesh_container.remove_child(n)
			n.queue_free()
		var m = settings.mesh.instance()
		mesh_container.add_child(m)
		aim_offset = m.get_aim_offset()
		animations = m.animations
		animations.connect("animation_finished", self, "_on_animation_finished")
	
	if settings.primary_settings:
		primary.settings = settings.primary_settings
		primary.evolutions = Global.primary_evolutions
	if settings.secondary_settings:
		secondary.settings = settings.secondary_settings
		secondary.evolutions = Global.secondary_evolutions
	if settings.tertiary_settings:
		map['dash'].settings = settings.tertiary_settings
		map['dash'].evolutions = Global.tertiary_evolutions
	
	primary.connect("fire_projectile", camera_pivot, "_on_fire_projectile")
#	primary.connect("fire_projectile", self, "_on_fire_projectile")
	secondary.connect("fire_projectile", camera_pivot, "_on_fire_projectile")
#	secondary.connect("fire_projectile", self, "_on_fire_projectile")
	primary.connect("cooldown", secondary, "cooldown", [0.2, false])
	primary.connect("cooldown", self, "shoot_animation")
	secondary.connect("cooldown", primary, "cooldown", [0.2, false])
	secondary.connect("cooldown", self, "shoot_animation")
	
	primary.initialize()
	secondary.initialize()
	
	if Global.ui:
		_create_ability(Global.ui, "primary", primary.settings.ability_icon, primary.settings.cooldown, primary)
		_create_ability(Global.ui, "secondary", secondary.settings.ability_icon, secondary.settings.cooldown, secondary)
		_create_ability(Global.ui, "tertiary", map["dash"].dash_icon, map["dash"].dash_cooldown, map["dash"])
	else:
		Global.connect("ui_changed", self, "_create_ability", ["primary", primary.settings.ability_icon, primary.settings.cooldown, primary])
		Global.connect("ui_changed", self, "_create_ability", ["secondary", secondary.settings.ability_icon, secondary.settings.cooldown, secondary])
		Global.connect("ui_changed", self, "_create_ability", ["tertiary", map["dash"].dash_icon, map["dash"].dash_cooldown, map["dash"]])
	
	pull.connect("body_entered", self, "_on_pull_item")
	pickup.connect("body_entered", self, "_on_pickup_item")
	pickup.connect("area_entered", self, "_on_pickup_item")
	
	for node in $States.get_children():
		node.connect("finished", self, "_change_state")
	stack.push_front($States/Idle)
	current = stack[0]
	_change_state("idle")
	
	Global.set_player(self)

func _process(delta):
	if Input.is_action_just_pressed("tertiary") and not map["dash"].pressed:
		map["dash"].emit_signal("ability_pressed")
		map["dash"].pressed = true
	if Input.is_action_just_released("tertiary") and map["dash"].pressed:
		map["dash"].emit_signal("ability_released")
		map["dash"].pressed = false

func _physics_process(delta):
	if allow_mouselook:
		_mouselook()
	current.update(delta)

func _input(event):
	if allow_mouselook:
		if event.is_action_pressed("primary") and primary.allow:
			primary.prepare("primary")
			shoot_animation()
		if event.is_action_pressed("secondary") and secondary.allow:
			secondary.prepare("secondary")
			shoot_animation()
	current.handle_input(event)

func _on_animation_finished(animation):
	current._on_animation_finished(animation)
	if animation != current.animation:
		animations.play(animation_map[current.animation])

func _change_state(state):
	if current: current.exit()
	
	if state == "previous":
		stack.pop_front()
	elif state in ["dash"]:
		stack.push_front(map[state])
	else:
		var new = map[state]
		stack[0] = new
	
	current = stack[0]
	if state != "previous":
		current.enter()
	
	emit_signal("changed_state", stack)

func _mouselook():
	if not drop_plane:
		drop_plane = Plane(Vector3(0, 1, 0), global_transform.origin.y)
	var mouse_pos = get_viewport().get_mouse_position()
	if not camera:
		camera = camera_pivot.camera
	mouse_position = drop_plane.intersects_ray(camera.project_ray_origin(mouse_pos), camera.project_ray_normal(mouse_pos)*100)
	
	var target = Vector3(mouse_position.x, global_transform.origin.y, mouse_position.z)
	look_at(target, Vector3.UP)

func _on_dash_timer_timeout():
	allow_dash = true
	emit_signal("can_dash")

func _on_fire_projectile():
	pass

func hit(point, force, damage):
	take_damage(damage)

func take_damage(damage):
	Global.reduce_health(damage)
	if Global.get_health() <= 0:
		current.emit_signal("finished", "death")
	else:
		stagger_animation()
		#current.emit_signal("finished", "stagger")

func shoot_animation():
	animations["parameters/Shooting/active"] = false
	animations["parameters/Shooting_Seek/seek_position"] = 0.0
	animations["parameters/Shooting/active"] = true

func stagger_animation():
	animations["parameters/Staggering/active"] = false
	animations["parameters/Staggering/active"] = true

func _on_pull_item(item):
	if item.has_method("pull"):
		item.pull(self)

func _on_pickup_item(item):
	if item.has_method("pickup"):
		item.pickup(self)

func _create_ability(ui, action_name, icon, cooldown, user):
	ui.add_ability(action_name, icon, cooldown, user)
