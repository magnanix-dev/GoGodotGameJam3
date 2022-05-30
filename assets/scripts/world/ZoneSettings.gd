extends Resource
class_name ZoneSettings

export (PackedScene) var player
export (Array, PackedScene) var pickups
export (Array, PackedScene) var enemies

export var size = Vector2(30, 30)
export var cell_size = 32

export var pickups_total = 3
export var pickups_distance = 10

export var ground_maximum = 110
export var ground_minimum = 70

export var walkers_maximum = 5
export var walkers_create_chance = 0.02
export var walkers_delete_chance = 0.01
export var walkers_distance = 5
export var walkers_2x_chance = 0.25
export var walkers_3x_chance = 0.0

export var enemy_spawn_chance = 0.11
export var enemy_spawn_minimum = 10
export var enemy_spawn_distance = 10

export var world_material : SpatialMaterial
