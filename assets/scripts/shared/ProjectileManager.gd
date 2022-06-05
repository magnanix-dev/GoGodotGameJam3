extends Position3D
class_name ProjectileManager

var weapon

var active = false
var running = false
var projectiles = []
var behaviours = []
var evolutions = null

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
var sequence = 1
var burst = 1
var delay = 0.0
var bounce = 0
var pierce = 0

var slim_cooldown = 1.0
var delay_cooldown = 0.0#weapon.settings.cooldown

func apply_settings(settings):
	speed = settings.speed
	damage = settings.damage
	direction_variance = settings.direction_variance
	speed_variance = settings.speed_variance
	behaviours = settings.behaviours
	delay_cooldown = settings.cooldown

func initialize():
	apply_manager_behaviours()
	apply_manager_evolutions()

func apply_manager_behaviours():
	for b in behaviours:
		match b[0]:
			"sequence":
				var count = b[1]
				var time = b[2]
				sequence = count
				delay = delay_cooldown * time
			"burst":
				var count = b[1]
				var spread = b[2]
				burst = count
				direction_variance += spread
			"bounce":
				var count = b[1]
				bounce = count
			"pierce":
				var count = b[1]
				pierce = count
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

func apply_manager_evolutions():
	if evolutions == null: return
	for e in evolutions:
		var evolution = evolutions[e]
		if evolution.active:
			match e:
				"sequence":
					sequence = evolution.count
					delay = evolution.delay * delay_cooldown
				"burst":
					burst = evolution.count
					direction_variance += evolution.spread
				"bounce":
					bounce = evolution.count
				"pierce":
					pierce = evolution.count
				"charge":
					charge_limit = evolution.limit
					charge_multiplier = evolution.multiplier
					charge_scale_size = evolution.scale
					charge = true
				"auto":
					full_auto = true
				"hefty":
					damage = damage + evolution.count
				"slim":
					slim_cooldown = slim_cooldown + evolution.count

func _process(delta):
	if active:
		global_transform.origin = weapon.global_transform.origin
		global_transform.basis = weapon.global_transform.basis
		if charging:
			charge_duration = clamp(charge_duration + delta, 0.0, charge_limit)
		if not running:
			clean()

func _input(event):
	if weapon.input != "" and charge and Input.is_action_just_released(weapon.input) and weapon.allow and running:
		weapon.aiming = false
		charging = false
		execute()

func execute():
	running = true
	global_transform.origin = weapon.global_transform.origin
	global_transform.basis = weapon.global_transform.basis
	active = true
	charge_damage = 0.0
	if charge and Input.is_action_pressed(weapon.input):
		charging = true
		weapon.aiming = true
		return
	charge_damage = (charge_duration / charge_limit) * (damage * charge_multiplier)
	charge_scale = ((charge_duration / charge_limit) * charge_scale_size) + 1.0
	charge_duration = 0.0
	weapon.cooldown(weapon.settings.cooldown / slim_cooldown)
	var accumulate_dir = Vector3.ZERO
	var dir = -global_transform.basis.z
	var spd = speed
	for n in range(sequence):
		for m in range(burst):
			var p = weapon.request_projectile()
			projectiles.append(p)
			p.manager = self
			p.scale = Vector3(1, 1, 1)
			if charge: p.scale = Vector3(charge_scale, charge_scale, charge_scale)
			var dmg = damage + charge_damage
			if direction_variance: dir = dir.rotated(Vector3.UP, deg2rad(rand_range(-direction_variance/2, direction_variance/2)))
			if speed_variance: spd = clamp(speed + rand_range(-speed_variance/2, speed_variance), 0, 999)
			p.setup(global_transform.origin, dir, spd)
			p.connect("hit", self, "_on_projectile_hit", [p, dmg])
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
				weapon.cooldown(weapon.settings.cooldown / slim_cooldown)
				execute()
			else:
				yield(weapon.timer, "timeout")
				weapon.cooldown(weapon.settings.cooldown / slim_cooldown)
				execute()
	running = false

func clean():
	if not charging:
		var is_active = false
		for p in projectiles:
			if p.active:
				is_active = true
		active = is_active
#	for r in removals:
#		projectiles.erase(r)

func _on_projectile_hit(dir, pos, norm, col, projectile, damage):
	var deactivate = true
	var do_bounce = false
	if not projectile.hits.has(col) and col.has_method("hit"):
		col.call("hit", pos, dir, damage)
		projectile.hits.append(col)
		if pierce > 0:
			pierce -= 1
			deactivate = false
			projectile.lifetime_timer = 3.0
		if bounce > 0:
			do_bounce = true
	if not col.has_method("hit") and bounce > 0:
		do_bounce = true
	if do_bounce:
		var d = dir.bounce(norm).normalized()
		var p = weapon.request_projectile()
		p.manager = self
		p.setup(pos, d, speed)
		if col.has_method("hit"): p.hits.append(col)
		p.connect("hit", self, "_on_projectile_hit", [p, damage])
		p.execute()
		projectiles.append(p)
		bounce -= 1
		deactivate = true
	if deactivate:
		projectile.deactivate()
