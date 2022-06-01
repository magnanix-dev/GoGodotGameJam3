extends Position3D
class_name ProjectileManager

var weapon

var active = false
var running = false
var projectiles = []
var behaviours = []
var evolutions = []

var speed = 0.0
var damage = 0.0

var direction_variance = 0.0
var speed_variance = 0.0

var full_auto = false
var burst = 1
var delay = 0.0
var bounce = 0

func apply_settings(settings, behaviours):
	speed = settings.speed
	damage = settings.damage
	direction_variance = settings.direction_variance
	speed_variance = settings.speed_variance
	behaviours = behaviours

func apply_manager_behaviours():
	for b in behaviours:
		match b[0]:
			"sequence":
				var count = b[1]
				var time = b[2]
				burst = count
				delay = time
			"burst":
				var count = b[1]
				burst = count
			"bounce":
				var count = b[1]
				bounce = count
			"auto":
				full_auto = true
#	print("Manager: Behaviours applied.")

func apply_projectile_behaviours(projectile):
	for b in behaviours:
		match b[0]:
			"bounce":
				projectile.connect("hit", self, "_on_hit_bounce")

func apply_projectile_evolutions(projectile):
	pass

func _process(delta):
	if active:
		global_transform.origin = weapon.global_transform.origin
		global_transform.basis = weapon.global_transform.basis
		if not running:
			clean()

func execute():
	running = true
	global_transform.origin = weapon.global_transform.origin
	global_transform.basis = weapon.global_transform.basis
	active = true
	apply_manager_behaviours()
	var accumulate_dir = Vector3.ZERO
	for n in range(burst):
		var p = weapon.request_projectile()
		projectiles.append(p)
		p.manager = self
		apply_projectile_behaviours(p)
		apply_projectile_evolutions(p)
		var dir = -global_transform.basis.z
		var spd = speed
		if direction_variance: dir = dir.rotated(Vector3.UP, deg2rad(rand_range(-direction_variance/2, direction_variance/2)))
		if speed_variance: spd = clamp(speed + rand_range(-speed_variance/2, speed_variance), 0, 999)
		p.setup(global_transform.origin, dir, spd, damage)
#		print("Projectile: ", n)
		p.execute()
		accumulate_dir += dir
		if delay > 0.0:
			weapon.emit_signal("fire_projectile", dir, spd)
			yield(get_tree().create_timer(delay), "timeout")
	if delay <= 0.0:
		weapon.emit_signal("fire_projectile", accumulate_dir/burst, speed)
#	print("Manager: Executed.")
	if full_auto:
		if Input.is_action_pressed(weapon.input):
			if weapon.allow:
				weapon.cooldown(weapon.settings.cooldown)
				execute()
			else:
				yield(weapon.timer, "timeout")
				weapon.cooldown(weapon.settings.cooldown)
				execute()
	running = false

func clean():
	var is_active = false
	for p in projectiles:
		if p.active: is_active = true
#	if not is_active: print("No active projectiles!")
	active = is_active

func _on_hit_bounce(dir, pos, norm):
	if bounce > 0:
		var d = dir.bounce(norm).normalized()
		var p = weapon.request_projectile()
		p.manager = self
		apply_projectile_behaviours(p)
		apply_projectile_evolutions(p)
		p.setup(pos, dir, speed, damage)
		p.execute()
		projectiles.append(p)
		bounce -= 1
	
