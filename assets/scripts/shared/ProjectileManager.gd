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

var charge = false
var charge_limit = 1.0
var charge_multiplier = 1.0
var charge_damage = 0.0
var charge_duration = 0.0
var charge_scale_size = 0.5
var charge_scale = 1.0
var charging = false
var full_auto = false
var burst = 1
var delay = 0.0
var bounce = 0

func apply_settings(settings):
	speed = settings.speed
	damage = settings.damage
	direction_variance = settings.direction_variance
	speed_variance = settings.speed_variance
	behaviours = settings.behaviours

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
			"charge":
				var limit = b[1]
				var multiplier = b[2]
				var scalesize = b[3]
				charge_limit = limit
				charge_multiplier = multiplier
				charge_scale_size = scalesize
				charge = true
			"auto":
				full_auto = true
#	if Global.debug: print("Manager: Behaviours applied.")

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
		if charging:
			charge_duration = clamp(charge_duration + delta, 0.0, charge_limit)
		if not running:
			clean()

func _input(event):
	if charge and Input.is_action_just_released(weapon.input) and weapon.allow and running:
		weapon.aiming = false
		charging = false
		execute()

func execute():
	running = true
	global_transform.origin = weapon.global_transform.origin
	global_transform.basis = weapon.global_transform.basis
	active = true
	apply_manager_behaviours()
	charge_damage = 0.0
	if charge and Input.is_action_pressed(weapon.input):
		charging = true
		weapon.aiming = true
		return
	charge_damage = (charge_duration / charge_limit) * (damage * charge_multiplier)
	charge_scale = ((charge_duration / charge_limit) * charge_scale_size) + 1.0
	charge_duration = 0.0
	weapon.cooldown(weapon.settings.cooldown)
	var accumulate_dir = Vector3.ZERO
	for n in range(burst):
		var p = weapon.request_projectile()
		projectiles.append(p)
		p.manager = self
		apply_projectile_behaviours(p)
		apply_projectile_evolutions(p)
		p.scale = Vector3(1, 1, 1)
		if charge: p.scale = Vector3(charge_scale, charge_scale, charge_scale)
		var dir = -global_transform.basis.z
		var spd = speed
		var dmg = damage + charge_damage
		if direction_variance: dir = dir.rotated(Vector3.UP, deg2rad(rand_range(-direction_variance/2, direction_variance/2)))
		if speed_variance: spd = clamp(speed + rand_range(-speed_variance/2, speed_variance), 0, 999)
		p.setup(global_transform.origin, dir, spd, dmg)
#		if Global.debug: print("Projectile: ", n)
		p.execute()
		accumulate_dir += dir
		if delay > 0.0:
			weapon.emit_signal("fire_projectile", dir, spd)
			yield(get_tree().create_timer(delay), "timeout")
	if delay <= 0.0:
		weapon.emit_signal("fire_projectile", accumulate_dir/burst, speed)
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
	if not charging:
		var is_active = false
		for p in projectiles:
			if p.active: is_active = true
	#	if not is_active: if Global.debug: print("No active projectiles!")
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
	
