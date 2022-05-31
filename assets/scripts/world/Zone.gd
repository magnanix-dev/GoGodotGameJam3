extends Spatial
class_name Zone

export (Resource) var settings

onready var _dynamic = $Dynamic
onready var _static = $Static

onready var generator = $Static/Generator

func _ready():
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
	
	generator.world_material = settings.world_material
	
	yield(generator.initialize(), "completed")
	
	if settings.player:
		var _player = settings.player.instance()
		_player.global_transform.origin = vector2_to_3(generator.spawn_point + Vector2(0.5, 0.5))
		_dynamic.add_child(_player)
	
	if settings.pickups:
		for p in settings.pickups:
			var _pickup_pos = generator.pickup_points.pop_front()
			var _pickup = p.instance()
			_pickup.global_transform.origin = vector2_to_3(_pickup_pos)
			_dynamic.add_child(_pickup)
	
	if settings.enemies:
		var _enemies = settings.enemies.duplicate()
		for e in generator.enemy_spawn_points:
			_enemies.shuffle()
			var _enemy = _enemies[0].instance()
			_enemy.global_transform.origin = vector2_to_3(e)
			_dynamic.add_child(_enemy)

func vector2_to_3(vector):
	return Vector3(vector.x, 0, vector.y)