extends Spatial
class_name Zone

export (Resource) var settings

onready var _dynamic = $Dynamic
onready var _static = $Static

onready var map = $Dynamic/Map
onready var generator = $Static/Generator
onready var loading = $Loading

var enemy_count = 0

var arrow
var arrow_dist = 0.0
var arrow_in = false
var entry_gate
var exit_gate

var zone_ended = false

var player

func _ready():
	loading.visible = true
	if Global.zone_settings:
		settings = Global.zone_settings
	else:
		Global.game_over = true
		Global.move_zones()
	yield(initialize(), "completed")
	generator.generate_lightmaps()
	if Global.player:
		_set_player(Global.player)
	else:
		Global.connect("player_set", self, "_set_player")
	loading.visible = false

func _set_player(object):
	player = object

func initialize():
	
	generator.gridmap = map
	
	generator.size = settings.size
	generator.cell_size = settings.cell_size

	generator.pickups_total = settings.pickups_total
	generator.pickups_distance = settings.pickups_distance

	generator.ground_maximum = settings.ground_maximum
	generator.ground_minimum = settings.ground_minimum

	generator.walkers_maximum = settings.walkers_maximum
	generator.walkers_create_chance = settings.walkers_create_chance
	generator.walkers_delete_chance = settings.walkers_delete_chance
	generator.walkers_distance = settings.walkers_distance
	generator.walkers_2x_chance = settings.walkers_2x_chance
	generator.walkers_3x_chance = settings.walkers_3x_chance

	generator.enemy_spawn_chance = settings.enemy_spawn_chance
	generator.enemy_spawn_minimum = settings.enemy_spawn_minimum
	generator.enemy_spawn_distance = settings.enemy_spawn_distance
	
	generator.outside_environmental_spawn_chance = settings.outside_environmental_spawn_chance
	generator.inside_environmental_spawn_chance = settings.inside_environmental_spawn_chance
	
	generator.world_material = settings.world_material
	generator.texture_width = settings.texture_width
	generator.tile_type_texture = settings.tile_type_texture
	
	yield(generator.initialize(), "completed")
	
	if settings.player:
		var _player = settings.player.instance()
		_player.global_transform.origin = vector2_to_3(generator.spawn_point + Vector2(0.5, 0.5))
		_dynamic.add_child(_player)
	
	if settings.gate:
		entry_gate = settings.gate.instance()
		entry_gate.global_transform.origin = vector2_to_3(generator.spawn_point + Vector2(0.5, 0.5))
		#entry_gate.rotate_y(generator.spawn_dir.angle())
		#entry_gate.look_at(vector2_to_3(generator.spawn_point), Vector3.UP)
		_dynamic.add_child(entry_gate)
		entry_gate.initialize()
		entry_gate.close()
		
		exit_gate = settings.gate.instance()
		exit_gate.global_transform.origin = vector2_to_3(generator.exit_point + Vector2(0.5, 0.5))
		#exit_gate.rotate_y(generator.exit_dir.angle())
		_dynamic.add_child(exit_gate)
		exit_gate.initialize()
		exit_gate.close()
		
		entry_gate.look_at(exit_gate.global_transform.origin, Vector3.UP)
		exit_gate.look_at(entry_gate.global_transform.origin, Vector3.UP)
	
#	if settings.pickups:
#		for p in settings.pickups:
#			var _pickup_pos = generator.pickup_points.pop_front()
#			var _pickup = p.instance()
#			_pickup.global_transform.origin = vector2_to_3(_pickup_pos)
#			_dynamic.add_child(_pickup)
	var health_augment_chance = ((Global.player_health_max - Global.player_health) / Global.player_health_max) * 0.5
	if settings.pickup_health_object != null and randf() <= (settings.pickup_health_chance + health_augment_chance):
		var _pickup_pos = generator.pickup_points.pop_front()
		var _pickup = settings.pickup_health_object.instance()
		_pickup.global_transform.origin = vector2_to_3(_pickup_pos + Vector2(0.5, 0.5))
		_dynamic.add_child(_pickup)
	
	if settings.pickup_exp_object != null and randf() <= (settings.pickup_exp_chance):
		var _pickup_pos = generator.pickup_points.pop_front()
		var _pickup = settings.pickup_exp_object.instance()
		_pickup.global_transform.origin = vector2_to_3(_pickup_pos + Vector2(0.5, 0.5))
		_dynamic.add_child(_pickup)
	
	if settings.enemies and settings.enemy:
		var _enemies = settings.enemies.duplicate()
		for e in generator.enemy_spawn_points:
			if generator.grid[e.x][e.y] == generator.tile.ground:
				_enemies.shuffle()
				var _enemy = settings.enemy.instance()
				_enemy.global_transform.origin = vector2_to_3(e + Vector2(0.5, 0.5))
				_dynamic.add_child(_enemy)
				_enemy.settings = _enemies[0]
				_enemy.initialize()
				_enemy.connect("death", self, "_on_enemy_death")
				enemy_count += 1
	
	if settings.outside_environmentals:
		var _environmentals = settings.outside_environmentals.duplicate()
		for o in generator.environmental_outside_spawn_points:
			_environmentals.shuffle()
			var _env = _environmentals[0].instance()
			_env.global_transform.origin = vector2_to_3(o + Vector2(rand_range(0, 1), rand_range(0, 1)), 1)
			_dynamic.add_child(_env)
			_env.rotate_y(deg2rad(rand_range(0, 360)))
	
	if settings.inside_environmentals:
		var _environmentals = settings.inside_environmentals.duplicate()
		for i in generator.environmental_inside_spawn_points:
			_environmentals.shuffle()
			var _env = _environmentals[0].instance()
			_env.global_transform.origin = vector2_to_3(i + Vector2(rand_range(0, 1), rand_range(0, 1)))
			_dynamic.add_child(_env)
			_env.rotate_y(deg2rad(rand_range(0, 360)))
	
	yield(get_tree(), "idle_frame")

func _process(delta):
	if zone_ended:
		if player and exit_gate:
			point_to_exit(delta)

func point_to_exit(delta):
	if arrow_in and arrow_dist <= 1.0:
		arrow_dist += delta * 3
	if not arrow_in and arrow_dist >= 0.0:
		arrow_dist -= delta * 3
	if arrow_dist <= 0.0:
		arrow_in = true
	elif arrow_dist >= 1.0:
		arrow_in = false
	var target = (exit_gate.target_point.global_transform.origin - player.global_transform.origin).normalized()
	target += target * (arrow_dist * 0.5)
	arrow.global_transform.origin = player.global_transform.origin + target
	arrow.look_at(exit_gate.target_point.global_transform.origin, Vector3.UP)

func end_zone():
	exit_gate.connect("player_entered", self, "_on_player_entered")
	exit_gate.open()
	arrow = settings.arrow.instance()
	_dynamic.add_child(arrow)
	zone_ended = true

func exit_zone():
	if settings.next_zone_settings:
		Global.zone_settings = settings.next_zone_settings
		Global.evolve()
	else:
		Global.game_over = true
		Global.move_zones()

func vector2_to_3(vector, elevation = 0):
	return Vector3(vector.x, elevation, vector.y)

func _on_player_entered(object):
	exit_zone()

func _on_enemy_death():
	enemy_count -= 1
	if enemy_count <= 0:
		end_zone()
