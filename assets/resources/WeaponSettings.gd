extends Resource
class_name WeaponSettings

export var primary_settings : Resource
export var primary_object : PackedScene
export var primary_cooldown : float
export (Array, Resource) var primary_evolutions

export var secondary_settings : Resource
export var secondary_object : PackedScene
export var secondary_cooldown : float
export (Array, Resource) var secondary_evolutions
