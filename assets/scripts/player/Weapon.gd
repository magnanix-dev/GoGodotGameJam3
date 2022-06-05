extends Position3D
class_name Weapon

signal fire_projectile(dir, mag)
signal cooldown()
signal ability_pressed()
signal ability_released()

export (Resource) var settings
var evolutions = []

var allow = true
var timer : Timer
var input = ""
var aiming = false
var pressed = false

var managers = []
var dead_managers = []
var projectiles = []
var dead_projectiles = []

onready var projectile_pool = $Projectiles
onready var manager_pool = $Managers

onready var label = $Label

var Line = preload("res://assets/scripts/development/DrawLine3D.gd").new()

func _ready():
	pass

func initialize():
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	initialize_managers(32)
	initialize_projectiles(128)
	add_child(Line)

func _process(delta):
	if Input.is_action_just_pressed(input) and not pressed:
		emit_signal("ability_pressed")
		pressed = true
	if Input.is_action_just_released(input) and pressed:
		emit_signal("ability_released")
		pressed = false
	if input == "primary":
		label.text = "\n" + input + ": " + str(allow)
	if input == "secondary":
		label.text = "\n\n" + input + ": " + str(allow)
	if aiming:
		if owner.animations:
			owner.animations["parameters/Aiming/blend_amount"] = 1.0
		Line.DrawRay(owner.global_transform.origin + Vector3(0, owner.aim_offset.y, 0) + (-global_transform.basis.z * owner.aim_offset.z), -global_transform.basis.z * 50, Color.red, delta * 0.5)
	else:
		if owner.animations and owner.animations.get("parameters/Aiming/blend_amount"):
			owner.animations["parameters/Aiming/blend_amount"] = 0.0
	clean()

func initialize_managers(amount):
	for n in range(amount):
		var m = ProjectileManager.new()
		m.active = false
		m.weapon = self
		m.apply_settings(settings)
		dead_managers.push_back(m)
		manager_pool.add_child(m)

func initialize_projectiles(amount):
	if settings.object:
		for n in range(amount):
			var b = settings.object.instance()
			b.active = false
			dead_projectiles.push_back(b)
			projectile_pool.add_child(b)

func cooldown(duration = 0.2, emit = true):
	if allow:
		allow = false
		timer.start(duration)
		if emit: emit_signal("cooldown")

func prepare(key = ""):
	if allow:
		input = key
#		if Global.debug: print("Weapon: Prepared.")
		execute()

func execute(bypass = false):
	if allow or bypass:
		var m = dead_managers[0]
		dead_managers.pop_front()
		managers.append(m)
		m.evolutions = evolutions
	#	if Global.debug: print("Weapon: Executed.")
		m.execute()

func request_projectile():
	var b = dead_projectiles[0]
	dead_projectiles.pop_front()
	projectiles.append(b)
	return b

func _on_timer_timeout():
	allow = true

func clean():
	var removals = []
	for i in range(projectiles.size()):
		if not projectiles[i].active:
			removals.push_back(i)
			dead_projectiles.push_back(projectiles[i])
	for i in range(removals.size()):
		projectiles.remove(removals[i])
	removals.clear()
	for i in range(managers.size()):
		if not managers[i].active:
			managers[i].projectiles.clear()
			removals.push_back(i)
			dead_managers.push_back(managers[i])
	for i in range(removals.size()):
		managers.remove(removals[i])
	removals.clear()
