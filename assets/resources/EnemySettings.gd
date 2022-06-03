extends Resource
class_name EnemySettings

export (String) var name = ""

export (Resource) var weapon_settings

export (PackedScene) var mesh
export var health = 2

export var can_drop_exp = true
export (Array, Dictionary) var loot_table

export var aggression = 0.33
export var whimsy = 0.5

export var collision_avoid_distance = 1

export var range_min = 5
export var range_max = 15

export var wander_max_speed = 1

export var idle_duration_min = 0.5
export var idle_duration_max = 2
export var wander_duration_min = 0.5
export var wander_duration_max = 2
export var hunt_duration_min = 0.5
export var hunt_duration_max = 2
export var hunt_max_speed = 1
export var hunt_spread = 90
export var shoot_duration_min = 0.5
export var shoot_duration_max = 2
export var shoot_repeat_chance = 0.125
