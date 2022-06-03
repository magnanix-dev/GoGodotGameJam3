extends Position3D
class_name Weapon

signal fire_projectile(dir, mag)
signal cooldown()

export (Resource) var settings
var evolutions = []

var allow = true
var timer : Timer
var input = ""

var managers = []
var dead_managers = []
var projectiles = []
var dead_projectiles = []

onready var projectile_pool = $Projectiles
onready var manager_pool = $Managers

func _ready():
	pass

func initialize():
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	initialize_managers(32)
	initialize_projectiles(128)

func _process(delta):
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

func cooldown(duration = 0.2):
	if allow:
		allow = false
		timer.start(duration)
		emit_signal("cooldown")

func prepare(key = ""):
	if allow:
		input = key
		cooldown(settings.cooldown)
#		if Global.debug: print("Weapon: Prepared.")
		execute()

func execute():
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
